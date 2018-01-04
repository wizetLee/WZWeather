//
//  WZAVCaptureToAudioUnitController.m
//  WZWeather
//
//  Created by admin on 2/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZAVCaptureToAudioUnitController.h"
#import "WZAVCaptureAudioUnitEngine.h"

/**
 录制的时间管理
 
 
 */
@interface WZAVCaptureToAudioUnitController ()<WZAVCaptureAudioUnitEngineProtocol>

@property (nonatomic, strong) WZAVCaptureAudioUnitEngine *captureEngine;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *resumeBtn;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation WZAVCaptureToAudioUnitController

- (void)viewDidLoad {
    [super viewDidLoad];
    _captureEngine = WZAVCaptureAudioUnitEngine.alloc.init;
    _captureEngine.delegate = self;
    _pauseBtn.hidden = true;
    _stopBtn.hidden = true;
    _resumeBtn.hidden = true;
    _playBtn.hidden = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
//开始录制
- (IBAction)record:(UIButton *)sender {
    [_captureEngine startRecording];
}
//暂停
- (IBAction)pause:(UIButton *)sender {
    [_captureEngine pauseRecording];
}

//停止
- (IBAction)stop:(UIButton *)sender {
    [_captureEngine stopRecording];
}
//播放
- (IBAction)play:(UIButton *)sender {
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_captureEngine.outputURL error:nil];
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}
//恢复
- (IBAction)resume:(UIButton *)sender {
    [_captureEngine resumeRecording];
}

- (void)captureAudioUnitEngineStartRecording {
    _recordBtn.hidden = true;
    _stopBtn.hidden = false;
    _resumeBtn.hidden = true;
    _playBtn.hidden = true;
    _pauseBtn.hidden = false;
}
- (void)captureAudioUnitEngineStopRecording {
    _recordBtn.hidden = false;
    _stopBtn.hidden = true;
    _resumeBtn.hidden = true;
    _playBtn.hidden = false;
    _pauseBtn.hidden = true;
}

- (void)captureAudioUnitEnginePauseRecording {
    _recordBtn.hidden = true;
    _stopBtn.hidden = false;
    _resumeBtn.hidden = false;
    _playBtn.hidden = true;
    _pauseBtn.hidden = true;
}
- (void)captureAudioUnitEngineResumeRecording {
    _recordBtn.hidden = true;
    _stopBtn.hidden = false;
    _resumeBtn.hidden = true;
    _playBtn.hidden = true;
    _pauseBtn.hidden = false;
}


@end
