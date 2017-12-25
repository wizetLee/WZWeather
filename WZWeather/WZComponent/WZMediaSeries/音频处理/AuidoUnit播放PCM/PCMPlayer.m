//
//  PCMPlayer.m
//  WZWeather
//
//  Created by 李炜钊 on 2017/12/24.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "PCMPlayer.h"

const uint32_t CONST_BUFFER_SIZE = 0x10000;
#define INPUT_BUS 1
#define OUTPUT_BUS 0

@interface PCMPlayer(){
    AudioUnit audioUnit;
    AudioBufferList *buffList;
    NSInputStream *inputSteam;
}

@end

@implementation PCMPlayer

void logAudioStreamBasicDescription(AudioStreamBasicDescription ASBD) {
    char formatID[5];
    UInt32 mFormatID = CFSwapInt32HostToBig(ASBD.mFormatID);
    bcopy (&mFormatID, formatID, 4);
    formatID[4] = '\0';
    printf("Sample Rate:         %10.0f\n",  ASBD.mSampleRate);
    printf("Format ID:           %10s\n",    formatID);
    printf("Format Flags:        %10X\n",    (unsigned int)ASBD.mFormatFlags);
    printf("Bytes per Packet:    %10d\n",    (unsigned int)ASBD.mBytesPerPacket);
    printf("Frames per Packet:   %10d\n",    (unsigned int)ASBD.mFramesPerPacket);
    printf("Bytes per Frame:     %10d\n",    (unsigned int)ASBD.mBytesPerFrame);
    printf("Channels per Frame:  %10d\n",    (unsigned int)ASBD.mChannelsPerFrame);
    printf("Bits per Channel:    %10d\n",    (unsigned int)ASBD.mBitsPerChannel);
    printf("\n");
}

- (void)play {

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"abc" withExtension:@"pcm"];
    inputSteam = [NSInputStream inputStreamWithURL:url];
    if (!inputSteam) {
        NSAssert(false, @"文件缺失");
    }
    
    //开启流
    [inputSteam open];

    //状态
    NSError *error = nil;
    OSStatus status = noErr;
    
    //配置为播放模式
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

    
//    {//使用AUGraph 替代 AUAudioUnit   官方代码
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
//        //得到一个I/O unit 的引用
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
        status = AudioUnitSetProperty(audioUnit
                                      , kAudioOutputUnitProperty_EnableIO
                                      , kAudioUnitScope_Output
                                      , OUTPUT_BUS
                                      , &flag
                                      , sizeof(flag));
    }
    if (status) {
        NSLog(@"AudioUnitSetProperty error with status:%d", status);
    }
    
    //格式配置
    AudioStreamBasicDescription outputFormat;
    memset(&outputFormat, 0, sizeof(outputFormat));
    outputFormat.mSampleRate       = 44100;
    outputFormat.mFormatID         = kAudioFormatLinearPCM;
    outputFormat.mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger;
    outputFormat.mFramesPerPacket  = 1;
    outputFormat.mChannelsPerFrame = 1;
    outputFormat.mBytesPerFrame    = 2;
    outputFormat.mBytesPerPacket   = 2;
    outputFormat.mBitsPerChannel   = 16;
    
    //信息打印
    logAudioStreamBasicDescription(outputFormat);
    
     ///给Audio Unit配置属性 kAudioUnitProperty_StreamFormat
    status = AudioUnitSetProperty(audioUnit
                                  ,  kAudioUnitProperty_StreamFormat
                                  ,  kAudioUnitScope_Input
                                  ,  OUTPUT_BUS
                                  ,  &outputFormat
                                  , sizeof(outputFormat));
    if (status) {
        NSLog(@"AudioUnitSetProperty eror with status:%d", status);
    }
    
    //回调处理
    AURenderCallbackStruct playCallback;
    playCallback.inputProc = PlayCallback;//互调过程
    playCallback.inputProcRefCon = (__bridge void *)self;
    ///Audio Unit设置回调属性
    AudioUnitSetProperty(audioUnit
                         , kAudioUnitProperty_SetRenderCallback
                         , kAudioUnitScope_Input
                         , OUTPUT_BUS
                         , &playCallback
                         , sizeof(playCallback));
    
    OSStatus result = AudioUnitInitialize(audioUnit);
    NSLog(@"result %d", result);
    
    
    //开始输出
    AudioOutputUnitStart(audioUnit);
}

//停止
- (void)stop {
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
static OSStatus PlayCallback(void *inRefCon
                             , AudioUnitRenderActionFlags *ioActionFlags
                             , const AudioTimeStamp *inTimeStamp
                             , UInt32 inBusNumber
                             , UInt32 inNumberFrames
                             , AudioBufferList *ioData) {
    PCMPlayer *player = (__bridge PCMPlayer *)inRefCon;//强转
    
    ioData->mBuffers[0].mDataByteSize = (UInt32)[player->inputSteam read:ioData->mBuffers[0].mData maxLength:(NSInteger)ioData->mBuffers[0].mDataByteSize];;
    NSLog(@"out size: %d", ioData->mBuffers[0].mDataByteSize);
    
    if (ioData->mBuffers[0].mDataByteSize <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [player stop];
        });
    }
    return noErr;
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
