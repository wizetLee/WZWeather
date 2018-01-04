//
//  PCMPlayer.m
//  WZWeather
//
//  Created by 李炜钊 on 2017/12/24.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "PCMPlayer.h"

const uint32_t CONST_BUFFER_SIZE = 0x10000;
#define kInputBus 1
#define kOutputBus 0

@interface PCMPlayer(){
    AudioUnit audioUnit;
    AudioBufferList *buffList;
    NSInputStream *inputSteam;
}

@end

@implementation PCMPlayer

//官方log https://developer.apple.com/library/content/documentation/MusicAudio/Conceptual/AudioUnitHostingGuide_iOS/ConstructingAudioUnitApps/ConstructingAudioUnitApps.html#//apple_ref/doc/uid/TP40009492-CH16-SW1
- (void)printASBD: (AudioStreamBasicDescription) asbd {
    
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    asbd.mBitsPerChannel);
}

- (void)play {

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"abc" withExtension:@"pcm"];
    inputSteam = [NSInputStream inputStreamWithURL:url];
    if (!inputSteam) {
        NSAssert(false, @"文件缺失");
    }
    
    //开启输入流
    [inputSteam open];

    //状态
    NSError *error = nil;
    OSStatus status = noErr;
    
    //配置session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
   
    AudioComponentDescription ioUnitDescription;
    {//配置唯一ID
        ioUnitDescription.componentType = kAudioUnitType_Output;
        ioUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO;
        ioUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    }
    ioUnitDescription.componentFlags = 0;
    ioUnitDescription.componentFlagsMask = 0;
    
    //定义音频单元的动态链接库的引用 The result of the AudioComponentFindNext function is a reference to the dynamically-linkable library that defines the audio unit
    AudioComponent inputComponent = AudioComponentFindNext(NULL //按照系统定义的排序来查找第一个系统音频单元匹配描述
                                                           , &ioUnitDescription);
    //初始化音频单元
    AudioComponentInstanceNew(inputComponent, &audioUnit);//创建

    
//    {//使用AUGraph 替代 AUAudioUnit   官方代码  每一个Audio Processing Graph 有一个确定的 I/O Unit
//        // Declare and instantiate an audio processing graph
//        //
//        AUGraph processingGraph;
//        NewAUGraph (&processingGraph);
//
//        // Add an audio unit node to the graph, then instantiate the audio unit
//
//        AUNode ioNode;
//        //添加一个节点
//        AUGraphAddNode (
//                        processingGraph,
//                        &ioUnitDescription,
//                        &ioNode
//                        );
//        //初始化
//        AUGraphOpen (processingGraph); // indirectly performs audio unit instantiation
//
//        // Obtain a reference to the newly-instantiated I/O unit
//        //得到一个I/O unit的引用
//        AudioUnit ioUnit;
//        AUGraphNodeInfo (
//                         processingGraph,
//                         ioNode,
//                         NULL,
//                         &ioUnit //这里替换为上面的audioUnit
//                         );
//    }
    
    /*
     
     */
    
    // buffer
    buffList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
    buffList->mNumberBuffers = 1;
    buffList->mBuffers[0].mNumberChannels = 1;
    buffList->mBuffers[0].mDataByteSize = CONST_BUFFER_SIZE;
    buffList->mBuffers[0].mData = malloc(CONST_BUFFER_SIZE);
    
   
    UInt32 flag = 1;
    if (flag) {
        ///给Audio Unit配置属性kAudioOutputUnitProperty_EnableIO
        status = AudioUnitSetProperty(audioUnit,
                                      kAudioOutputUnitProperty_EnableIO,
                                      kAudioUnitScope_Output,
                                      kOutputBus,
                                      &flag,
                                      sizeof(flag));
    }
    if (status) {
        NSLog(@"AudioUnitSetProperty error with status:%d", status);
    }
    
    //音频流格式
    //格式配置 这个结构总是在app内或者app与硬件之间修改
    AudioStreamBasicDescription audioStreamFormat = {0};
//    memset(&outputFormat, 0, sizeof(outputFormat));
    
    audioStreamFormat.mSampleRate         = [AVAudioSession sharedInstance].sampleRate;//采样率
    audioStreamFormat.mFormatID           = kAudioFormatLinearPCM;//PCM采样
    audioStreamFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioStreamFormat.mFramesPerPacket    = 1;//每个数据包多少帧
    audioStreamFormat.mChannelsPerFrame   = 1;//1单声道，2立体声
    audioStreamFormat.mBitsPerChannel     = 16;//语音每采样点占用位数
    audioStreamFormat.mBytesPerFrame      = audioStreamFormat.mBitsPerChannel * audioStreamFormat.mChannelsPerFrame / 8;//每帧的bytes数
    audioStreamFormat.mBytesPerPacket     = audioStreamFormat.mBytesPerFrame * audioStreamFormat.mFramesPerPacket;//每个数据包的bytes总数，每帧的bytes数＊每个数据包的帧数
    audioStreamFormat.mReserved           = 0;
    
    
    //信息打印
   [self printASBD:audioStreamFormat];
    
     ///给Audio Unit配置属性 kAudioUnitProperty_StreamFormat
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioStreamFormat,
                                  sizeof(audioStreamFormat));
    if (status) {
        NSLog(@"AudioUnitSetProperty eror with status:%d", status);
    }
    
    //回调处理
    AURenderCallbackStruct playCallback;
    playCallback.inputProc = PlayCallback;//回调过程
    playCallback.inputProcRefCon = (__bridge void *)self;
    ///Audio Unit设置回调属性
    AudioUnitSetProperty(audioUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Input,
                         kOutputBus ,
                         &playCallback,
                         sizeof(playCallback));
    
    OSStatus result = AudioUnitInitialize(audioUnit);
    NSLog(@"result %d", result);
    
    //开始消息传递给I / O单元  开始请求执行pull
    AudioOutputUnitStart(audioUnit);
}

//停止
- (void)stop {
    //停止消息传递给I / O单元
    AudioOutputUnitStop(audioUnit);
    if (buffList != NULL) {
        if (buffList->mBuffers[0].mData) {
            free(buffList->mBuffers[0].mData);
            buffList->mBuffers[0].mData = NULL;
        }
        free(buffList);
        buffList = NULL;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playFinished)]) {
//        __strong typeof (PCMPlayer) *player = self;
        [self.delegate playFinished];
    }
    
    [inputSteam close];
}

///解析出后调用的回调
static OSStatus PlayCallback(void *inRefCon                                 //负责执行render的上下文
                             , AudioUnitRenderActionFlags *ioActionFlags    //提供一个表示unit没有需要处理的音频的标志（注意：静默处理）
                             , const AudioTimeStamp *inTimeStamp            //表示执行回调的时间
                             , UInt32 inBusNumber                           //表示哪一个audio unit bus执行的回调，可根据这个值与对应的audio unit做出相关联的处理
                             , UInt32 inNumberFrames                        //当前回调的slice中的音频样本帧的数目。
                             , AudioBufferList *ioData) {                   //缓冲区的指针。回调时，需要被填充（如果是调整为静默模式，可将缓冲区设置为0，使用memset函数）
    PCMPlayer *player = (__bridge PCMPlayer *)inRefCon;//强转
    
    //pull工作
    ioData->mBuffers[0].mDataByteSize = (UInt32)[player->inputSteam read:ioData->mBuffers[0].mData maxLength:(NSInteger)ioData->mBuffers[0].mDataByteSize];
    
    NSLog(@"out size: %d", ioData->mBuffers[0].mDataByteSize);
    
    if (ioData->mBuffers[0].mDataByteSize <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [player stop];
        });
    }
    return noErr;
}

//暂停输出
- (void)pause {
    //检查状态
    
}

//恢复输出
- (void)resume {
    //检查状态
    
}


//buffer 处理
- (void)dealloc {
    AudioOutputUnitStop(audioUnit);
    AudioUnitUninitialize(audioUnit);
    AudioComponentInstanceDispose(audioUnit);
    
    if (buffList != NULL) {
        free(buffList);
        buffList = NULL;
    }
}

@end
