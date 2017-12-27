//
//  WZIOPassThroughViewController.m
//  WZWeather
//
//  Created by admin on 26/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZIOPassThroughViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>


#define kInputBus 1 
#define kOutputBus 0


/**
    一个声音的直流
 */
@interface WZIOPassThroughViewController ()
{
    AudioComponentDescription ioUnitDescription;    //音频信息的唯一ID
    AudioComponent ioComponent;                  //用于创建unit
    AudioUnit audioUnit;                         //unit的引用
    AudioStreamBasicDescription audioStreamFormat;//音频流格式
    double rate;//采样率
}

@end

@implementation WZIOPassThroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
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
    OSStatus res = AudioComponentInstanceNew(ioComponent, &audioUnit);
    if (noErr != res) {
        [self showErrorStatus:res];
    }
    
    //配置audio unit 属性(input scope、output scope、audio stream format)
    [self configProperty];
    
    //初始化 audio unit
    OSStatus err = AudioUnitInitialize(audioUnit);
    if (noErr != err) {
        [self showErrorStatus:err];
    }
    
    //audio unit的连接
    /*
     This structure contains the information needed to make a connection between a source
     and destination audio unit.
     配置在input element上
     传播audio stream format
     */
    AudioUnitConnection connection;
    connection.sourceAudioUnit = audioUnit; //连接源
    connection.destInputNumber = 0;         //目标音频单元的输入元素，用于连接
    connection.sourceOutputNumber = 1;      //源音频单元的输出元素，用于连接
    err = AudioUnitSetProperty(audioUnit,
                               kAudioUnitProperty_MakeConnection,//sets the kAudioUnitProperty_MakeConnection property in the input scope of the destination audio unit.
                               kAudioUnitScope_Input,
                               0,
                               &connection,
                               sizeof(connection)
                               );
    if (noErr != err) {
        [self showErrorStatus:err];
    }
}

- (void)configProperty {

    {//配置input scope
        UInt32 flag = 1;
        OSStatus err = AudioUnitSetProperty(audioUnit,
                                            kAudioOutputUnitProperty_EnableIO,
                                            kAudioUnitScope_Input,
                                            kInputBus,
                                            &flag,
                                            sizeof(flag));
        if (noErr != err) {
            [self showErrorStatus:err];
        }
    }
    
    
//    {//配置output scope
//        UInt32 flag = 1;
//        OSStatus err = AudioUnitSetProperty(audioUnit,
//                                            kAudioOutputUnitProperty_EnableIO,
//                                            kAudioUnitScope_Output,
//                                            kOutputBus,
//                                            &flag,
//                                            sizeof(flag));
//        if (noErr != err) {
//            [self showErrorStatus:err];
//        }
//    }
//
    
//    {//配置音频流格式
//
//        audioStreamFormat.mSampleRate         = rate;//采样率
//        audioStreamFormat.mFormatID           = kAudioFormatLinearPCM;//PCM采样
//        audioStreamFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
//        audioStreamFormat.mFramesPerPacket    = 1;//每个数据包多少帧
//        audioStreamFormat.mChannelsPerFrame   = 1;//1单声道，2立体声
//        audioStreamFormat.mBitsPerChannel     = 16;//语音每采样点占用位数
//        audioStreamFormat.mBytesPerFrame      = audioStreamFormat.mBitsPerChannel * audioStreamFormat.mChannelsPerFrame / 8;//每帧的bytes数
//        audioStreamFormat.mBytesPerPacket     = audioStreamFormat.mBytesPerFrame * audioStreamFormat.mFramesPerPacket;//每个数据包的bytes总数，每帧的bytes数＊每个数据包的帧数
//        audioStreamFormat.mReserved           = 0;
//
//
//        OSStatus err = AudioUnitSetProperty(audioUnit,
//                                            kAudioUnitProperty_StreamFormat,
//                                            kAudioUnitScope_Input,
//                                            kOutputBus,
//                                            &audioStreamFormat,
//                                            sizeof(audioStreamFormat));
//
//        if (noErr != err) {
//            [self showErrorStatus:err];
//        }
////        [self printASBD:audioStreamFormat];
//    }
    
}

- (void)start {
    NSLog(@"started");
    OSStatus err = AudioOutputUnitStart(audioUnit);
    if (noErr != err) {
        [self showErrorStatus:err];
    }
}

- (void)stop {
    NSLog(@"stopped");
    OSStatus err = AudioOutputUnitStop(audioUnit);
    if (noErr != err) {
        [self showErrorStatus:err];
    }
}

//显示错误
- (void)showErrorStatus:(OSStatus)status
{
    NSString *text = nil;
    switch (status) {
        case kAudioUnitErr_CannotDoInCurrentContext: text = @"kAudioUnitErr_CannotDoInCurrentContext"; break;
        case kAudioUnitErr_FailedInitialization: text = @"kAudioUnitErr_FailedInitialization"; break;
        case kAudioUnitErr_FileNotSpecified: text = @"kAudioUnitErr_FileNotSpecified"; break;
        case kAudioUnitErr_FormatNotSupported: text = @"kAudioUnitErr_FormatNotSupported"; break;
        case kAudioUnitErr_IllegalInstrument: text = @"kAudioUnitErr_IllegalInstrument"; break;
        case kAudioUnitErr_Initialized: text = @"kAudioUnitErr_Initialized"; break;
        case kAudioUnitErr_InstrumentTypeNotFound: text = @"kAudioUnitErr_InstrumentTypeNotFound"; break;
        case kAudioUnitErr_InvalidElement: text = @"kAudioUnitErr_InvalidElement"; break;
        case kAudioUnitErr_InvalidFile: text = @"kAudioUnitErr_InvalidFile"; break;
        case kAudioUnitErr_InvalidOfflineRender: text = @"kAudioUnitErr_InvalidOfflineRender"; break;
        case kAudioUnitErr_InvalidParameter: text = @"kAudioUnitErr_InvalidParameter"; break;
        case kAudioUnitErr_InvalidProperty: text = @"kAudioUnitErr_InvalidProperty"; break;
        case kAudioUnitErr_InvalidPropertyValue: text = @"kAudioUnitErr_InvalidPropertyValue"; break;
        case kAudioUnitErr_InvalidScope: text = @"kAudioUnitErr_InvalidScope"; break;
        case kAudioUnitErr_NoConnection: text = @"kAudioUnitErr_NoConnection"; break;
        case kAudioUnitErr_PropertyNotInUse: text = @"kAudioUnitErr_PropertyNotInUse"; break;
        case kAudioUnitErr_PropertyNotWritable: text = @"kAudioUnitErr_PropertyNotWritable"; break;
        case kAudioUnitErr_TooManyFramesToProcess: text = @"kAudioUnitErr_TooManyFramesToProcess"; break;
        case kAudioUnitErr_Unauthorized: text = @"kAudioUnitErr_Unauthorized"; break;
        case kAudioUnitErr_Uninitialized: text = @"kAudioUnitErr_Uninitialized"; break;
        case kAudioUnitErr_UnknownFileType: text = @"kAudioUnitErr_UnknownFileType"; break;
        default: text = @"unknown error";
    }
    NSLog(@"TRANSLATED_ERROR = %i = %@", (int)status, text);
}

- (void)dealloc {
    AudioOutputUnitStop(audioUnit);
    AudioUnitUninitialize(audioUnit);
    AudioComponentInstanceDispose(audioUnit);
    //直通流无buffer
}

- (IBAction)start:(id)sender {
    [self start];
}
- (IBAction)stop:(id)sender {
    [self stop];
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
