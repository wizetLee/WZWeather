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
@interface WZAVCaptureToAudioUnitController ()

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
    _pauseBtn.enabled = false;
    _stopBtn.enabled = false;
    _resumeBtn.enabled = false;
    _playBtn.enabled = false;
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
    _recordBtn.enabled = false;
    _stopBtn.enabled = true;
    _resumeBtn.enabled = false;
    _playBtn.enabled = false;
    _pauseBtn.enabled = true;
}
- (void)captureAudioUnitEngineStopRecording {
    _recordBtn.enabled = true;
    _stopBtn.enabled = false;
    _resumeBtn.enabled = false;
    _playBtn.enabled = true;
    _pauseBtn.enabled = false;
}

- (void)captureAudioUnitEnginePauseRecording {
    _recordBtn.enabled = false;
    _stopBtn.enabled = true;
    _resumeBtn.enabled = true;
    _playBtn.enabled = false;
    _pauseBtn.enabled = false;
}
- (void)captureAudioUnitEngineResumeRecording {
    _recordBtn.enabled = false;
    _stopBtn.enabled = true;
    _resumeBtn.enabled = false;
    _playBtn.enabled = false;
    _pauseBtn.enabled = true;
}


@end
