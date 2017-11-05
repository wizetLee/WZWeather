//
//  WZMediaPreviewView.m
//  WZWeather
//
//  Created by 李炜钊 on 2017/11/4.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaPreviewView.h"

@interface WZMediaPreviewView()

@property (nonatomic, strong) GPUImageStillCamera *cameraStillImage;//静态图
@property (nonatomic, strong) GPUImageVideoCamera *cameraVideo;//录像

@end

@implementation WZMediaPreviewView

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
        [self createViews];
    }
    return self;
}

- (void)config {
    _mediaType = WZMediaTypeStillImage;
    //首次 高画质 背面配置
    AVCaptureSessionPreset preset = AVCaptureSessionPresetHigh;
    AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
    GPUImageVideoCamera *tmpCamera = nil;
    if (_mediaType == WZMediaTypeVideo) {
        _cameraVideo = [[GPUImageVideoCamera alloc] initWithSessionPreset:preset cameraPosition:position];
        _cameraCurrent = _cameraVideo;
    } else {
        _cameraStillImage = [[GPUImageStillCamera alloc] initWithSessionPreset:preset cameraPosition:position];
        _cameraCurrent = _cameraVideo;
    }
    //    [_camera startCameraCapture];
    //    [_camera stopCameraCapture];
   
    _cameraCurrent.outputImageOrientation = UIInterfaceOrientationPortrait;//拍照方向
    ///前后摄像头镜像配置
    _cameraCurrent.horizontallyMirrorFrontFacingCamera = false;
    _cameraCurrent.horizontallyMirrorRearFacingCamera = false;
}


- (void)createViews {
    _presentView = [[GPUImageView alloc] initWithFrame:self.bounds];
    [self addSubview:_presentView];
    
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _presentView.frame = self.bounds;
    
}

#pragma mark - Public
- (void)pickMediaType:(WZMediaType)mediaType {
    //断链
    //初始化配置
}

- (void)launchCamera {
    [_cameraCurrent startCameraCapture];
}

- (void)pauseCamera {
    [_cameraCurrent stopCameraCapture];
}

- (void)stopCamera {
    [_cameraCurrent stopCameraCapture];
}

@end
