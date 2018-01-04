//
//  WZAVCaptureAudioUnitEngine.m
//  WZWeather
//
//  Created by admin on 2/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZAVCaptureAudioUnitEngine.h"
//#import <AudioToolbox/AudioToolbox.h>
//#import <AVFoundation/AVFoundation.h>




typedef NS_ENUM(NSUInteger, WZCAptureAudioUnitType) {
    WZCAptureAudioUnitType_leisure = 0,
    WZCAptureAudioUnitType_recording,
    WZCAptureAudioUnitType_pause,
//    WZCAptureAudioUnitType_Interrupt,//根据业务需求考虑需不需要中断恢复  个人认为中断了就应该暂停，而并非马上恢复
};


@interface WZAVCaptureAudioUnitEngine()<AVCaptureAudioDataOutputSampleBufferDelegate>
{
    //捕获buffer的组件
    AVCaptureSession *captureSession;
    AVCaptureDeviceInput *captureDeviceInput;
    AVCaptureAudioDataOutput *captureAudioDataOutput;
    
    //garph
    AUGraph                     auGraph;
    AudioUnit                   converterAudioUnit;            //格式转换
//    AudioUnit                   delayAudioUnit;            //均衡器
    AudioChannelLayout          *currentRecordingChannelLayout;//用于指定文件和硬件中的通道布局。
    ExtAudioFileRef             extAudioFile;//用于保存buffer的文件
    
    
    AudioStreamBasicDescription currentInputASBD;//当前捕获buffer的ASBD
    AudioStreamBasicDescription graphOutputASBD;//输出的ASBD
    AudioBufferList             *currentInputAudioBufferList;
    AUOutputBL                  *outputBufferList;//buffer list
    
    double                      currentSampleTime;//当前采样时间 采样间隔
    WZCAptureAudioUnitType      currentType;
}

@property (nonatomic, strong) NSURL *outputURL;


@end

@implementation WZAVCaptureAudioUnitEngine

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        [self configOutputURL];
        [self congfigNotification];
        [self configGraph];
        
        //初始化便开始running
        [self configCaptureSession];
        //启动
        if (!captureSession.running) {
            [captureSession startRunning];
        }
    }
    return self;
}

- (void)configOutputURL {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    _outputURL = [NSURL fileURLWithPath:[docPath stringByAppendingPathComponent:@"wizetAudio.aif"]];
}

- (void)congfigNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActiveNotification)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionRouteChangeNotification:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:[AVAudioSession sharedInstance]];
}


- (void)configGraph {
    //    AudioComponentDescription
    CheckError(NewAUGraph(&auGraph), "NewAUGraph(&auGraph)");
    
//    AudioComponentDescription delayACD = {0};
//    delayACD.componentManufacturer     = kAudioUnitManufacturer_Apple;
//    delayACD.componentFlags            = 0;
//    delayACD.componentFlagsMask        = 0;
//    delayACD.componentType             = kAudioUnitType_Effect;
//    delayACD.componentSubType          = kAudioUnitSubType_Delay;
    
    AudioComponentDescription converterACD = {0};
    converterACD.componentManufacturer     = kAudioUnitManufacturer_Apple;
    converterACD.componentFlags            = 0;
    converterACD.componentFlagsMask        = 0;
    converterACD.componentType             = kAudioUnitType_FormatConverter;
    converterACD.componentSubType          = kAudioUnitSubType_AUConverter;
    
    AUNode converterNode;
//    CheckError(AUGraphAddNode(auGraph, &delayACD, &delayNode), __func__);
    CheckError(AUGraphAddNode(auGraph, &converterACD, &converterNode), "AUGraphAddNode(auGraph, &converterACD, &converterNode)");
    
    //outpur -> input
    //converter -> delay
//    CheckError(AUGraphConnectNodeInput(auGraph, converterNode, 0, delayNode, 0), __func__);
    CheckError(AUGraphOpen(auGraph), "AUGraphOpen(auGraph)");
    
    
    //从节点获取audio unit 以及ACD(唯一ID)
    AudioComponentDescription tmpACD = {0};
    CheckError(AUGraphNodeInfo(auGraph, converterNode, &tmpACD, &converterAudioUnit), "AUGraphNodeInfo(auGraph, converterNode, &tmpACD, &converterAudioUnit)");
//    CheckError(AUGraphNodeInfo(auGraph, delayNode, &tmpACD, &delayAudioUnit), __func__);
    
    //render call
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProc = PushCurrentInputBufferIntoAudioUnit;
    renderCallbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    
    //converterNode提供audio buffers，负责接收来自capture audio Data output的数据
    CheckError(AUGraphSetNodeInputCallback(auGraph, converterNode, 0, &renderCallbackStruct), "AUGraphSetNodeInputCallback(auGraph, converterNode, 0, &renderCallbackStruct)");
    
}

- (void)configCaptureSession {
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    if (audioDevice && audioDevice.connected) {
        NSLog(@"audioDevice.localizedName : %@", audioDevice.localizedName);
    } else {
        NSLog(@"麦克风连接失败");
    }
    
    captureSession = [[AVCaptureSession alloc] init];
    
    NSError *error = nil;
    captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
    //配置输入
    if ([captureSession canAddInput:captureDeviceInput]) {
        [captureSession addInput:captureDeviceInput];
    }
    
    captureAudioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    
    if ([captureSession canAddOutput:captureAudioDataOutput]) {
        [captureSession addOutput:captureAudioDataOutput];
    }
    
    //串行队列
    dispatch_queue_t audioDataOutputQueue = dispatch_queue_create("AudioDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [captureAudioDataOutput setSampleBufferDelegate:self queue:audioDataOutputQueue];
    
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (output == captureAudioDataOutput) {
        //音频
     
        {////主要是为了配置格式
            CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);//CMAudioFormatDescriptionRef
            AudioStreamBasicDescription ASBD = *CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription);
            //数据匹配
            if (currentInputASBD.mChannelsPerFrame != ASBD.mChannelsPerFrame
                || currentInputASBD.mSampleRate != ASBD.mSampleRate) {
                //指定文件和硬件中的通道布局
                
                currentInputASBD = ASBD;
                currentRecordingChannelLayout = (AudioChannelLayout *)CMAudioFormatDescriptionGetChannelLayout(formatDescription, NULL);
                
                //set property
                //设置输入流格式，控制coverter audio unit中的input bus的格式 : 输入scope 输出element0
                CheckError(AudioUnitSetProperty(converterAudioUnit,
                                                kAudioUnitProperty_StreamFormat,
                                                kAudioUnitScope_Input,
                                                0,
                                                &currentInputASBD,
                                                sizeof(currentInputASBD)), "kAudioUnitProperty_StreamFormat");
                
                
               CAStreamBasicDescription outputFormat(currentInputASBD.mSampleRate, currentInputASBD.mChannelsPerFrame, CAStreamBasicDescription::kPCMFormatFloat32/*枚举*/, false);
                graphOutputASBD = outputFormat;//值拷贝
                
                //设置输出流格式，控制coverter audio unit中的output bus的格式 ：输出scope 输出element
                CheckError(AudioUnitSetProperty(converterAudioUnit,
                                                kAudioUnitProperty_StreamFormat,
                                                kAudioUnitScope_Output,
                                                0,
                                                &graphOutputASBD,
                                                sizeof(graphOutputASBD)), "kAudioUnitProperty_StreamFormat");
                
                //设置输出流格式，控制delay audio unit中的output bus的格式
//                CheckError(AudioUnitSetProperty(delayAudioUnit,
//                                                kAudioUnitProperty_StreamFormat,
//                                                kAudioUnitScope_Output,
//                                                0,
//                                                &graphOutputASBD,
//                                                sizeof(graphOutputASBD)), __func__);
                
                //查看状态
                CAShow(auGraph);
            }
        }
       
        if (currentType == WZCAptureAudioUnitType_recording) {
            //得到一个slice的帧数
            CMItemCount numberOfFrames = CMSampleBufferGetNumSamples(sampleBuffer);
            currentSampleTime += (double)numberOfFrames;//用于记录bufferde的帧量
            
            //配置一个时间戳
            AudioTimeStamp timeStamp;
            memset(&timeStamp, 0, sizeof(AudioTimeStamp));
            timeStamp.mSampleTime = currentSampleTime;
            timeStamp.mFlags |= kAudioTimeStampSampleTimeValid;
            
            //创建一个buffer用于存储AU render audio
            if (outputBufferList == NULL) {
                outputBufferList = new AUOutputBL(graphOutputASBD, (UInt32)numberOfFrames);
            }
            outputBufferList->Prepare((UInt32)numberOfFrames);
            
            //初始化AudioBufferList
            currentInputAudioBufferList = CAAudioBufferList::Create(currentInputASBD.mChannelsPerFrame);
            
            size_t bufferListSizeNeededOut;
            CMBlockBufferRef blockBufferOut = nil;
            /**
             Creates an AudioBufferList containing the data from the CMSampleBuffer,
             and a CMBlockBuffer which references (and manages the lifetime of) the
             data in that AudioBufferList.  The data may or may not be copied,
             depending on the contiguity and 16-byte alignment of the CMSampleBuffer's
             data. The buffers placed in the AudioBufferList are guaranteed to be contiguous.
             The buffers in the AudioBufferList will be 16-byte-aligned if
             kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment is passed in.
             */
            CheckError(CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer,
                                                                               &bufferListSizeNeededOut,
                                                                               currentInputAudioBufferList, CAAudioBufferList::CalculateByteSize(currentInputASBD.mChannelsPerFrame),
                                                                               kCFAllocatorSystemDefault,
                                                                               kCFAllocatorSystemDefault,
                                                                               kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
                                                                               &blockBufferOut), __func__);
            AudioUnitRenderActionFlags flags = 0;
            //告诉effect audio unit 开始 render：即将同步调用PushCurrentInputBufferIntoAudioUnit,将填充currentInputAudioBufferList到effect audio unit中
            //delayAudioUnit            此render call 是为了获得输出音频数据
            CheckError(AudioUnitRender(converterAudioUnit, &flags, &timeStamp, 0, (UInt32)numberOfFrames, outputBufferList->ABL()),"AudioUnitRender(converterAudioUnit");
            
            //清理工作
            CFRelease(blockBufferOut);
            CAAudioBufferList::Destroy(currentInputAudioBufferList);//free
            currentInputAudioBufferList = NULL;
            
            //加锁 异步写缓存到文件中
            @synchronized(self) {
                if (extAudioFile) {
                    //可直接写AudioBufferList
                    CheckError(ExtAudioFileWriteAsync(extAudioFile, (UInt32)numberOfFrames, outputBufferList->ABL()), "ExtAudioFileWriteAsync");
                }
            }
        }
    } else {
        NSLog(@"视频");
    }
}
- (void)startCaptureSession {
    if (!captureSession.running) {
        [captureSession startRunning];
    }
}

- (void)stopCaptureSession {
    if (captureSession.running) {
        [captureSession stopRunning];
    }
    //同时也停止录制
    [self stopRecording];
}

- (void)startRecording {
    if (currentType != WZCAptureAudioUnitType_leisure) {
        NSLog(@"状态错误");
        return;
    }
    
    @synchronized(self) {
        //录制开始、配置一个ExtAudioFile、配置same sanple rate 以及channel layout
         CAStreamBasicDescription recordingFormat(currentInputASBD.mSampleRate, currentInputASBD.mChannelsPerFrame, CAStreamBasicDescription::kPCMFormatInt16, true);
        recordingFormat.mFormatFlags |= kAudioFormatFlagIsBigEndian;//大端
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:_outputURL.path]) {
            [[NSFileManager defaultManager] removeItemAtURL:_outputURL error:nil];
        }
        
        //创建存储文件
        CFURLRef URLRef = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)_outputURL.path, kCFURLPOSIXPathStyle, false);
#pragma mark - 需要更改格式：目前为aif
        //https://developer.apple.com/library/content/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html#//apple_ref/doc/uid/TP40003577-CH7-SW1
        CheckError(ExtAudioFileCreateWithURL(URLRef,
                                             kAudioFileAIFFType,
                                             &recordingFormat,
                                             currentRecordingChannelLayout,
                                             kAudioFileFlags_EraseFile,//删除现有文件的option
                                             &extAudioFile), "ExtAudioFileCreateWithURL");
        //输出的数据格式为delay unit传出的格式
       OSErr err =  CheckError(ExtAudioFileSetProperty(extAudioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(graphOutputASBD), &graphOutputASBD), "ExtAudioFileSetProperty");
        
        if (err != noErr) {
            if (extAudioFile) ExtAudioFileDispose(extAudioFile);
            extAudioFile = NULL;
        }
        
        if (CheckError(AUGraphInitialize(auGraph), "AUGraphInitialize(auGraph)") == noErr) {
            if ([_delegate respondsToSelector:@selector(captureAudioUnitEngineStartRecording)]) {
                [_delegate captureAudioUnitEngineStartRecording];
            }
            currentType = WZCAptureAudioUnitType_recording;
            NSLog(@"开始录制");
        }
    }
}

//暂停
- (void)pauseRecording {
    if (currentType == WZCAptureAudioUnitType_recording) {
        NSLog(@"暂停录制");
        if (CheckError(AUGraphUninitialize(auGraph), "AUGraphUninitialize(auGraph)") == noErr) {
            currentType = WZCAptureAudioUnitType_pause;
            //暂停
            if ([_delegate respondsToSelector:@selector(captureAudioUnitEnginePauseRecording)]) {
                [_delegate captureAudioUnitEnginePauseRecording];
            }
        }
    }
}

//恢复
- (void)resumeRecording {
    if (currentType == WZCAptureAudioUnitType_pause) {
        NSLog(@"恢复录制");
        if (CheckError(AUGraphInitialize(auGraph), "AUGraphInitialize(auGraph)") == noErr) {
            currentType = WZCAptureAudioUnitType_recording;
            if ([_delegate respondsToSelector:@selector(captureAudioUnitEngineResumeRecording)]) {
                [_delegate captureAudioUnitEngineResumeRecording];
            }
        }
    }
}

- (void)stopRecording {
    NSLog(@"停止录制");
    if (currentType == WZCAptureAudioUnitType_leisure) {
        return;
    }
    
    //停止并且恢复到空闲状态
    if (CheckError(AUGraphUninitialize(auGraph), "AUGraphUninitialize(auGraph)") == noErr) {
        
        @synchronized(self) {
            if (extAudioFile) {
                // Close the file by disposing the ExtAudioFile
                CheckError(ExtAudioFileDispose(extAudioFile), "保存失败");
                extAudioFile = NULL;
                
            }
        } // @synchronized
        
        //重新设置an audio unit's render state
        //delayAudioUnit
        CheckError(AudioUnitReset(converterAudioUnit, kAudioUnitScope_Global, 0), "AudioUnitReset(converterAudioUnit, kAudioUnitScope_Global, 0)");
        if ([_delegate respondsToSelector:@selector(captureAudioUnitEngineStopRecording)]) {
            [_delegate captureAudioUnitEngineStopRecording];
        }
        currentType = WZCAptureAudioUnitType_leisure;
    }
   
}


- (AudioBufferList *)currentInputAudioBufferList
{
    return currentInputAudioBufferList;
}


/**
    当调用AudioUnitRender()时，会同步调用效果音频单元。
    用于将ATCaptureAudioDataOutput输出到AudioUnit的音频示例输出。
 */
static OSStatus PushCurrentInputBufferIntoAudioUnit(void *                            inRefCon,
                                                    AudioUnitRenderActionFlags *    ioActionFlags,
                                                    const AudioTimeStamp *            inTimeStamp,
                                                    UInt32                            inBusNumber,
                                                    UInt32                            inNumberFrames,
                                                    AudioBufferList *                ioData)
{
    

    WZAVCaptureAudioUnitEngine *self = (__bridge WZAVCaptureAudioUnitEngine *)inRefCon;
    AudioBufferList *ABL = [self currentInputAudioBufferList];
    
    UInt32 bufferIndex, bufferCount = ABL->mNumberBuffers;
    
    if (bufferCount != ioData->mNumberBuffers) return kAudioFormatUnknownFormatError;
    
    //通过音频数据输出将提供的AudioBufferList的数据填充到AudioBufferList输出中
    for (bufferIndex = 0; bufferIndex < bufferCount; bufferIndex++) {
        ioData->mBuffers[bufferIndex].mDataByteSize = ABL->mBuffers[bufferIndex].mDataByteSize;
        ioData->mBuffers[bufferIndex].mData = ABL->mBuffers[bufferIndex].mData;
        ioData->mBuffers[bufferIndex].mNumberChannels = ABL->mBuffers[bufferIndex].mNumberChannels;
    }
    return noErr;
}

#pragma mark - 通知
//不活跃
- (void)applicationWillResignActiveNotification {
    
    //若。。。则。。。
    if (currentType == WZCAptureAudioUnitType_recording) {
        [self pauseRecording];
       
    }
}
//活跃
- (void)applicationDidBecomeActiveNotification {
    
}

- (void)audioSessionRouteChangeNotificatio:(NSNotification *)notification {
    UInt8 reasonValue = [[notification.userInfo valueForKey: AVAudioSessionRouteChangeReasonKey] intValue];
    
    if (AVAudioSessionRouteChangeReasonNewDeviceAvailable == reasonValue
        || AVAudioSessionRouteChangeReasonOldDeviceUnavailable == reasonValue) {
        NSLog(@"CaptureSessionController routeChangeHandler called:");
        (reasonValue == AVAudioSessionRouteChangeReasonNewDeviceAvailable) ? NSLog(@"     NewDeviceAvailable") :
        NSLog(@"     OldDeviceUnavailable");
        [self applicationWillResignActiveNotification];
    }
    
#warning
    /**
     当连接入一个新的设备，流格式会发生变化，当这种流格式发生变化时，可以引起采样率的变化。
     https://developer.apple.com/library/content/qa/qa1777/_index.html#//apple_ref/doc/uid/DTS40013097
     */
}

@end
