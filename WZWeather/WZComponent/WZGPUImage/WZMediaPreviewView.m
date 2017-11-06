//
//  WZMediaPreviewView.m
//  WZWeather
//
//  Created by 李炜钊 on 2017/11/4.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaPreviewView.h"

@interface WZMediaPreviewView()<GPUImageVideoCameraAssistProtocol>

@property (nonatomic, strong) GPUImageStillCamera *cameraStillImage;//静态图
@property (nonatomic, strong) GPUImageVideoCamera *cameraVideo;//录像

//内置滤镜
@property (nonatomic, strong) GPUImageCropFilter *cropFilter;


@end

@implementation WZMediaPreviewView

- (instancetype)init {
    if (self = [super init]) {
        [self config];
        [self createViews];
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

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)config {
    _mediaType = WZMediaTypeStillImage;
    //首次 高画质 背面配置
    AVCaptureSessionPreset preset = AVCaptureSessionPresetHigh;
    AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
    if (_mediaType == WZMediaTypeVideo) {
        _cameraVideo = [[GPUImageVideoCamera alloc] initWithSessionPreset:preset cameraPosition:position];
        _cameraCurrent = _cameraVideo;
    } else {
        _cameraStillImage = [[GPUImageStillCamera alloc] initWithSessionPreset:preset cameraPosition:position];
        _cameraCurrent = _cameraStillImage;
    }
    
    //    [_camera stopCameraCapture];
    [_cameraCurrent addCMMotionToMobile];
    _cameraCurrent.assistDelegate = self;
    _cameraCurrent.outputImageOrientation = UIInterfaceOrientationPortrait;//拍照方向
    ///前后摄像头镜像配置
    _cameraCurrent.horizontallyMirrorFrontFacingCamera = false;
    _cameraCurrent.horizontallyMirrorRearFacingCamera = false;
    
    //内建滤镜
    _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, 0.0, 1.0, 1.0)];

    _cropFilter.cropRegion = CGRectMake(0.0, 0.0, 1.0, 1.0);//0~1 自动居中 Q:如何设置1：1  3：4 等图片的尺寸

    [_cameraCurrent addTarget:_cropFilter];
    [_cropFilter addTarget:self.presentView];
    
}

#warning 除非在低分辨率的情况下 才可不停地修改此值， 因为GPUImage内部有做键值对缓存 或者修改源码...
- (void)setCropValue:(CGFloat)value {
    [_cameraCurrent resetBenchmarkAverage];
    [_cropFilter setCropRegion:CGRectMake(0.0, 0.0, 1.0, value)];
}

- (void)pickStillImageWithHandler:(void (^)(UIImage *image))handler {
    ///无效函数
    [_cameraStillImage capturePhotoAsImageProcessedUpToFilter:_cropFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if (handler) {
            handler(processedImage);
        }
    }];
}

- (void)useFilter:(GPUImageFilter *)filter {
    [_cameraCurrent removeAllTargets];
    
    [_cameraCurrent addTarget:filter];
    [filter addTarget:self.presentView];
}

- (void)createViews {
    
    [self addSubview:self.presentView];
    
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _presentView.frame = self.bounds;
    
}

#pragma mark - GPUImageVideoCameraAssistProtocol
- (void)videoCamera:(GPUImageVideoCamera *)camera currentOrientation:(UIDeviceOrientation *)orientation {
    
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

- (void)setFlashType:(GPUImageCameraFlashType)type {
    [_cameraCurrent setFlashType:type];
}

//有声音 无声音


#pragma mark - Accessor
-(GPUImageView *)presentView {
    if (!_presentView) {
        _presentView = [[GPUImageView alloc] initWithFrame:self.bounds];
    }
    return _presentView;
}

@end
