//
//  WZGraphWithSamplerIOController.m
//  WZWeather
//
//  Created by admin on 28/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZGraphWithSamplerIOController.h"

@interface WZGraphWithSamplerIOController ()

@property (weak, nonatomic) IBOutlet UIButton *trombonePresetButton;
@property (weak, nonatomic) IBOutlet UIButton *vibraphonePresetButton;

@property (weak, nonatomic) IBOutlet UIButton *note_0;
@property (weak, nonatomic) IBOutlet UIButton *note_1;
@property (weak, nonatomic) IBOutlet UIButton *note_2;
@property (weak, nonatomic) IBOutlet UIButton *note_3;
@property (weak, nonatomic) IBOutlet UIButton *note_4;
@property (weak, nonatomic) IBOutlet UIButton *note_5;


@property (nonatomic, assign) Float64 graphSampleRate;
@property (nonatomic, assign) AUGraph graph;          //graph
@property (nonatomic, assign) AudioUnit samplerUnit;
@property (nonatomic, assign) AudioUnit ioUnit;

@end

@implementation WZGraphWithSamplerIOController

- (void)dealloc {
    [self applicationWillResignActiveNotification:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNotifications];
    [self configSession];
    [self createViews];
    [self createGraph];
    
    [self loadPreset:_trombonePresetButton];
}
- (void)configSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *audioSessionError = nil;
    [session setCategory: AVAudioSessionCategoryPlayback error: &audioSessionError];
//    [session setPreferredHardwareSampleRate: self.graphSampleRate error: &audioSessionError];
    [session setActive:true error: &audioSessionError];
    self.graphSampleRate = [session sampleRate];
}
- (void)createViews {
    
}
- (void)createGraph {
    AudioComponentDescription acd = {0};
    acd.componentManufacturer     = kAudioUnitManufacturer_Apple;
    acd.componentFlags            = 0;
    acd.componentFlagsMask        = 0;
 
    CheckError(NewAUGraph(&_graph), __func__);
    
     AUNode samplerNode, ioNode;//节点 采样器  input ouput
    {
        //sampler unit 使用采样器单元并且设置为graph的第一个节点
        acd.componentType = kAudioUnitType_MusicDevice;
        acd.componentSubType = kAudioUnitSubType_Sampler;
        
        //Sampler unit node
        CheckError(AUGraphAddNode(_graph, &acd, &samplerNode), __func__);
    }
    {
        //Output unit
        acd.componentType = kAudioUnitType_Output;
        acd.componentSubType = kAudioUnitSubType_RemoteIO;
        //Output unit node
        CheckError(AUGraphAddNode(_graph, &acd, &ioNode), __func__);
    }
    {//graph open
        AUGraphOpen(_graph);
    }
    {//Connect the Sampler unit to the output unit
        AUGraphConnectNodeInput(_graph, samplerNode, 0, ioNode, 0);
    }
    
    {
        AudioComponentDescription tmp = {0};
        //获得对应node的id以及unit
        CheckError(AUGraphNodeInfo(_graph, samplerNode, &tmp, &_samplerUnit), __func__);
        
        CheckError(AUGraphNodeInfo(_graph, ioNode, &tmp, &_ioUnit), __func__);
    }
    
    {//配置、启动graph
        //设置IO unit采样速率 可不配置直接用系统的
        CheckError(AudioUnitInitialize(_ioUnit), __func__);//使生效
        //output bus的采样率
        CheckError(AudioUnitSetProperty(_ioUnit,
                                        kAudioUnitProperty_SampleRate,
                                        kAudioUnitScope_Output,
                                        0,
                                        &_graphSampleRate,
                                        sizeof (_graphSampleRate)), __func__);
        
        //获取IO unit slice中帧数
        UInt32 framesPerSlice = 0;
        UInt32 sampleRatePropertySize = sizeof (self.graphSampleRate);
        CheckError(AudioUnitGetProperty(_ioUnit,
                                        kAudioUnitProperty_MaximumFramesPerSlice,
                                        kAudioUnitScope_Global,
                                        0,
                                        &framesPerSlice,
                                        &sampleRatePropertySize), __func__);
        NSLog(@"MaximumFramesPerSlice : %u", (unsigned int)framesPerSlice);
        
        //设置sampler unit
        CheckError(AudioUnitSetProperty(_samplerUnit,
                                        kAudioUnitProperty_SampleRate,
                                        kAudioUnitScope_Output,
                                        0,
                                        &_graphSampleRate,
                                        sizeof(_graphSampleRate)), __func__);
        
        
        CheckError(AudioUnitSetProperty(_samplerUnit,
                                        kAudioUnitProperty_MaximumFramesPerSlice,
                                        kAudioUnitScope_Global,
                                        0,
                                        &framesPerSlice,
                                        sampleRatePropertySize), __func__);
        
        if (_graph) {
            CheckError(AUGraphInitialize(_graph), __func__);//使生效
            CheckError(AUGraphStart(_graph), __func__);//启动
            CAShow (_graph);//打印内部信息
        }
    }
}

//来自官方demo中的修改
// Load a synthesizer preset file and apply it to the Sampler unit
- (OSStatus) loadSynthFromPresetURL: (NSURL *) presetURL {
    
//    CFDataRef propertyResourceData = 0;
//    Boolean status;
//    SInt32 errorCode = 0;
    OSStatus result = noErr;
    
//    // Read from the URL and convert into a CFData chunk
//    status = CFURLCreateDataAndPropertiesFromResource (
//                                                       kCFAllocatorDefault,
//                                                       (__bridge CFURLRef) presetURL,
//                                                       &propertyResourceData,
//                                                       NULL,
//                                                       NULL,
//                                                       &errorCode
//                                                       );
 
    NSData *data = [NSData dataWithContentsOfURL:presetURL];
    
    // Convert the data object into a property list//data转Plist文件
    CFPropertyListRef presetPropertyList = 0;
    CFPropertyListFormat dataFormat = 0;
    CFErrorRef errorRef = 0;
    presetPropertyList = CFPropertyListCreateWithData (
                                                       kCFAllocatorDefault,
                                                       (CFBridgingRetain(data)),
                                                       kCFPropertyListImmutable,
                                                       &dataFormat,
                                                       &errorRef
                                                       );
    
    // Set the class info property for the Sampler unit using the property list as the value.
    if (presetPropertyList != 0) {
        //配置到sampeler unit 中
        //Tbone中包含音频文件，需要添加这个文件，使用文件目录引用而非创建组是因为aupreset文件写死了路径
        result = AudioUnitSetProperty( _samplerUnit,
                                      kAudioUnitProperty_ClassInfo,
                                      kAudioUnitScope_Global,
                                      0,
                                      &presetPropertyList,
                                      sizeof(CFPropertyListRef)
                                      );
        
        CFRelease(presetPropertyList);
    }
    
    if (errorRef) CFRelease(errorRef);
//    CFRelease (propertyResourceData);
    return result;
}


#pragma mark - Action

- (IBAction)loadPreset:(UIButton *)sender {
    NSString *preset = nil;
    if (_trombonePresetButton == sender) {
        preset = @"Trombone";
    } else {
        preset = @"Vibraphone";
    }
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:preset ofType:@"aupreset"]];
    
    [self loadSynthFromPresetURL:url];
    
    //UI
    _trombonePresetButton.selected = false;
    _vibraphonePresetButton.selected = false;
    sender.selected = true;
}

/*
    0x9
    0x8
 */

- (IBAction)startPlayNote:(UIButton *)sender {
    
    MusicDeviceComponent *inUnit = &_samplerUnit;
    UInt32 inStatus = 0x9 << 4 | 0;
            //https://stackoverflow.com/questions/9113993/explain-some-simple-c-bitshifting-code
    UInt32 inData1 = 0;     //0 < 128
    UInt32 inData2 = 127;   //0 < 128
    UInt32 inOffsetSampleFrame = 0;
    
    if (sender == _note_0) {
        inData1 = 20 * 1;
    } else if (sender == _note_1) {
        inData1 = 20 * 2;
    } else if (sender == _note_2) {
        inData1 = 20 * 3;
    } else if (sender == _note_3) {
        inData1 = 20 * 4;
    } else if (sender == _note_4) {
        inData1 = 20 * 5;
    } else if (sender == _note_5) {
        inData1 = 20 * 6;
    }
    
    //发出声音的事件
    CheckError(MusicDeviceMIDIEvent(*inUnit, inStatus, inData1, inData2, inOffsetSampleFrame), __func__);
}

- (IBAction)stopPlayNote:(UIButton *)sender {
    MusicDeviceComponent *inUnit = &_samplerUnit;
    UInt32 inStatus = 0x8 << 4 | 0;
    UInt32 inData1 = 0;     //0 < 128
    UInt32 inData2 = 0;     //0 < 128
    UInt32 inOffsetSampleFrame = 0;
    if (sender == _note_0) {
        inData1 = 20 * 1;
    } else if (sender == _note_1) {
        inData1 = 20 * 2;
    } else if (sender == _note_2) {
        inData1 = 20 * 3;
    } else if (sender == _note_3) {
        inData1 = 20 * 4;
    } else if (sender == _note_4) {
        inData1 = 20 * 5;
    } else if (sender == _note_5) {
        inData1 = 20 * 6;
    }
    //发出声音的事件
    CheckError(MusicDeviceMIDIEvent(*inUnit, inStatus, inData1, inData2, inOffsetSampleFrame), __func__);
}

#pragma mark - 通知
- (void)registerNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver: self
                           selector: @selector (applicationWillResignActiveNotification:)
                               name: UIApplicationWillResignActiveNotification
                             object: [UIApplication sharedApplication]];
    
    [notificationCenter addObserver: self
                           selector: @selector (applicationDidBecomeActiveNotification:)
                               name: UIApplicationDidBecomeActiveNotification
                             object: [UIApplication sharedApplication]];
}

- (void) applicationWillResignActiveNotification:(NSNotification *)notification {
    [self stopPlayNote:_note_0];
    [self stopPlayNote:_note_1];
    [self stopPlayNote:_note_2];
    [self stopPlayNote:_note_3];
    [self stopPlayNote:_note_4];
    [self stopPlayNote:_note_5];
    
    CheckError(AUGraphStop(_graph), __func__);
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    CheckError(AUGraphStart(_graph), __func__);
}

@end
