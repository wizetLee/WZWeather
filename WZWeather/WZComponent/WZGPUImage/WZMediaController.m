//
//  WZMediaController.m
//  WZWeather
//
//  Created by admin on 17/10/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaController.h"
#import "WZGPUImageStillCamera.h"///静态图 动态录像
typedef NS_ENUM(NSUInteger, WZMediaType) {
    WZMediaTypeStillImage,
    WZMediaTypeVideo,
};


@interface WZMediaController ()

@property (nonatomic, strong) WZGPUImageStillCamera *camera;//静态图 以及录像
@property (nonatomic, assign) WZMediaType mediaType;

@end

@implementation WZMediaController

#pragma mark - ViewController Lifecycle

- (instancetype)init {
    if (self = [super init]) {}
    return self;
}

- (void)loadView {
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
///切换成相机
- (void)assembleStillImage {
    _mediaType = WZMediaTypeStillImage;
    //首次 高画质 背面配置
    AVCaptureSessionPreset preset = AVCaptureSessionPresetHigh;
    AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
    _camera = [[WZGPUImageStillCamera alloc] initWithSessionPreset:preset cameraPosition:position];
//    [_camera startCameraCapture];
//    [_camera stopCameraCapture];
}
//切换为视频模式
- (void)assembleVideo {
    _mediaType = WZMediaTypeVideo;
    
}



@end
