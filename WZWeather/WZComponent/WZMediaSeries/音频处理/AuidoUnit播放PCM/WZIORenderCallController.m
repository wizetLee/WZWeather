//
//  WZIORenderCallController.m
//  WZWeather
//
//  Created by admin on 27/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZIORenderCallController.h"

@interface WZIORenderCallController ()
{
    AudioComponentDescription ioUnitDescription;    //音频信息的唯一ID
    AudioComponent ioComponent;                  //用于创建unit
    AudioUnit audioUnit;                         //unit的引用
    AudioStreamBasicDescription audioStreamFormat;//音频流格式
    double rate;//采样率
}
@end

@implementation WZIORenderCallController


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self start];
}

- (void)setUp {
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];//配置录制和播放模式
    
    //    [session setPreferredSampleRate:rate error:&error];//自定义 会有上限，这个上限根据设备硬件而言
    [session setActive:YES error:&error];
    rate = [session sampleRate];//iPod 6 上 默认是44100  最大值为48000
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    //audio unit 描述 配置唯一ID
    ioUnitDescription.componentType = kAudioUnitType_Output;
    ioUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    ioUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    ioUnitDescription.componentFlags = 0;
    ioUnitDescription.componentFlagsMask = 0;
    
    //The result of the AudioComponentFindNext function is a reference to the dynamically-linkable library that defines the audio unit
    ioComponent = AudioComponentFindNext(NULL, &ioUnitDescription);
    
    //初始化 ioComponment
    CheckError(AudioComponentInstanceNew(ioComponent, &audioUnit), "AudioComponentInstanceNew");
    
    
    //配置audio unit 属性(input scope、output scope、audio stream format)
    [self configProperty];
    
    //初始化 audio unit
    CheckError(AudioUnitInitialize(audioUnit), "AudioUnitInitialize");
  
}

- (void)configProperty {
    
    
    {//配置input scope
        UInt32 flag = 1;
        CheckError(AudioUnitSetProperty(audioUnit,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Input,
                                        1,
                                        &flag,
                                        sizeof(flag)), "kAudioOutputUnitProperty_EnableIO");
    }
    
    
    {//配置output scope
        UInt32 flag = 1;
        CheckError(AudioUnitSetProperty(audioUnit,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Output,
                                        0,
                                        &flag,
                                        sizeof(flag)), "kAudioOutputUnitProperty_EnableIO");
    }
    //
    
    {//配置音频流格式input
        
        audioStreamFormat.mSampleRate         = rate;//采样率
        audioStreamFormat.mFormatID           = kAudioFormatLinearPCM;//PCM采样
        audioStreamFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        audioStreamFormat.mFramesPerPacket    = 1;//每个数据包多少帧
        audioStreamFormat.mChannelsPerFrame   = 1;//1单声道，2立体声
        audioStreamFormat.mBitsPerChannel     = 16;//语音每采样点占用位数
        audioStreamFormat.mBytesPerFrame      = audioStreamFormat.mBitsPerChannel * audioStreamFormat.mChannelsPerFrame / 8;//每帧的bytes数
        audioStreamFormat.mBytesPerPacket     = audioStreamFormat.mBytesPerFrame * audioStreamFormat.mFramesPerPacket;//每个数据包的bytes总数，每帧的bytes数＊每个数据包的帧数
        audioStreamFormat.mReserved           = 0;
        
        CheckError(AudioUnitSetProperty(audioUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &audioStreamFormat,
                                        sizeof(audioStreamFormat)), "kAudioUnitProperty_StreamFormat");
    }
    
    {//配置音频流格式output
        CheckError(AudioUnitSetProperty(audioUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Output,
                                        1,
                                        &audioStreamFormat,
                                        sizeof(audioStreamFormat)), "kAudioUnitProperty_StreamFormat");
    }
    
    ///我们可以在input render中采集数据  在 output render call中调用（在output render call中对数据配置可能会导致缝隙）
    {//output render call
        AURenderCallbackStruct renderCall;
        renderCall.inputProc = outputRenderCall;
        renderCall.inputProcRefCon = (__bridge void *)(self);
        CheckError(AudioUnitSetProperty(audioUnit,
                                        kAudioUnitProperty_SetRenderCallback,
                                        kAudioUnitScope_Input,
                                        0,//output element
                                        &renderCall,
                                        sizeof(renderCall)), "kAudioOutputUnitProperty_SetInputCallback");
    }
}

static Float32 mY1 = 0,mX1 = 0;

OSStatus outputRenderCall(void * inRefCon,
                     AudioUnitRenderActionFlags * ioActionFlags,
                     const AudioTimeStamp * inTimeStamp,
                     UInt32 inBusNumber,
                     UInt32 inNumberFrames,
                     AudioBufferList * __nullable ioData) {
    WZIORenderCallController *VC = (__bridge WZIORenderCallController*)inRefCon;

    
    CheckError(AudioUnitRender(VC->audioUnit,
                               ioActionFlags,
                               inTimeStamp,
                               1,
                               inNumberFrames,
                               ioData), __FUNCTION__);
    
    BOOL silence = false;
    BOOL origion = false;
    if (silence) {
        //保持静默  配置数据为0
        for (UInt32 i=0; i<ioData->mNumberBuffers; ++i) {
            memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize);
        }
    } else if(origion) {
        
        NSLog(@"----------");
        for (UInt32 i = 0; i < inNumberFrames; i++) {
            printf("%d ,%p \n",i ,ioData->mBuffers[i].mData);
        }
    } else {
        //自定义修改的数据达到变声效果
        //Q：如何修改数据？
        //Q：为什么是mBuffers中的第一个元素,此结构体变量中标注数组长度就是1，但是文档中介绍是可变的，什么时候会产生第二个元素呢？
        //一个苹果上的代码:用于在音频信号中去除直流分量
        Float32* tmp_ioData = (Float32*)ioData->mBuffers[0].mData;
        Float32 kDefaultPoleDist = 0.975f;
        for (UInt32 i = 0; i < inNumberFrames; i++) {
            Float32 xCurr = tmp_ioData[i];
            printf("%d---%f \n",i ,xCurr);
            tmp_ioData[i] = (tmp_ioData[i] - mX1 + (kDefaultPoleDist * mY1));
            mX1 = xCurr;
            mY1 = tmp_ioData[i];
        }
    }
    return noErr;
}

- (void)start {
    NSLog(@"started");
    CheckError(AudioOutputUnitStart(audioUnit), "AudioOutputUnitStart");
}

- (void)stop {
    NSLog(@"stopped");
    CheckError(AudioOutputUnitStop(audioUnit), "AudioOutputUnitStop");
}

- (void)dealloc {
    AudioOutputUnitStop(audioUnit);
    AudioUnitUninitialize(audioUnit);
    AudioComponentInstanceDispose(audioUnit);
    //直通流无buffer
}

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



@end
