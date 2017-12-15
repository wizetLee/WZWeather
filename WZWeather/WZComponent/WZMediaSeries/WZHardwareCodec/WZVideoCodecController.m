//
//  WZVideoCodecController.m
//  WZWeather
//
//  Created by admin on 15/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVideoCodecController.h"
#import <GPUImage/GPUImage.h>
#import <Masonry/Masonry.h>

@interface WZVideoCodecController ()<GPUImageVideoCameraDelegate>

//@property (nonatomic, strong) GPUImageVideoCamera *camera;
//@property (nonatomic, strong) GPUImageView *previewView;

@property (nonatomic , strong) AVCaptureSession *captureSession;           //负责输入和输出设备之间的数据传递
@property (nonatomic , strong) AVCaptureDeviceInput *captureDeviceInput;    //负责从AVCaptureDevice获得输入数据
@property (nonatomic , strong) AVCaptureVideoDataOutput *captureVideoDeviceOutput;
@property (nonatomic , strong) AVCaptureAudioDataOutput *captureAudioDeviceOutput;
@property (nonatomic , strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation WZVideoCodecController

- (void)viewDidLoad {
    [super viewDidLoad];
//    _camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
//    _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
//    _previewView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
//
//    [self.view addSubview:_previewView];
//    [_previewView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.bottom.right.equalTo(self.view);
//    }];
//
//    _camera.delegate = self;
//    [_camera addTarget:_previewView];
//
//    [_camera startCameraCapture];
}

#pragma mark - GPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

@end
