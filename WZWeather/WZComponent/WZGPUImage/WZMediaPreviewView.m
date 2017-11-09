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
    _cameraCurrent.outputImageOrientation = UIInterfaceOrientationPortrait;//拍照方向
    ///前后摄像头镜像配置
    _cameraCurrent.horizontallyMirrorFrontFacingCamera = false;
    _cameraCurrent.horizontallyMirrorRearFacingCamera = false;
    
    //内建滤镜
    _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, 0.0, 1.0, 1.0)];

    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
//     CGFloat targetH = targetW / 1.0 * 1.0;
//    CGFloat targetH = targetW / 3.0 * 4.0;//3 ： 4
    CGFloat targetH = screenW / 9.0 * 16.0;//9 ： 16
    CGFloat rateH = targetH / screenH;
    if (rateH > 1) {
        rateH = 1;
    }
    _cropFilter.cropRegion = CGRectMake(0.0, 0.0, 1.0, rateH);//0~1 自动居中 Q:如何设置1：1  3：4 等图片的尺寸
//
        /*
     1:1
     screenW / screenH
     */
    
    _scaleFilter = [[GPUImageFilter alloc] init];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = [UIScreen mainScreen].bounds.size;
    [_scaleFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(size.width * scale, size.height * scale)];
    //缩减渲染比例 降低渲染成本
    [_cameraCurrent addTarget:_scaleFilter];
    [_scaleFilter addTarget:_cropFilter];
    [_cropFilter addTarget:self.presentView];
    
}

#warning 除非在低分辨率的情况下 才可不停地修改此值， 因为GPUImage内部有做键值对缓存 或者修改源码...
- (void)setCropValue:(CGFloat)value {
    //停止所有渲染的动作
    runSynchronouslyOnVideoProcessingQueue(^{
        
        NSArray *tmpArr = _cropFilter.targets;
        [_cropFilter removeAllTargets];
        
     
        [_cameraCurrent resetBenchmarkAverage];
        [_cropFilter setCropRegion:CGRectMake(0.0, 0.0, 1.0, value)];
        
        for (GPUImageFilter *filter in tmpArr) {
            [_cropFilter addTarget:filter];
        }

    });
}

- (void)pickStillImageWithHandler:(void (^)(UIImage *image))handler {
    ///无效函数
    [_cameraStillImage capturePhotoAsImageProcessedUpToFilter:_cropFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if (handler) {
            handler(processedImage);
        }
    }];
}

- (void)insertRenderFilter:(GPUImageFilter *)filter {
    runSynchronouslyOnVideoProcessingQueue(^{
        


        [_cropFilter removeTarget:self.presentView];//去掉支线
        
//        NSArray *tmpArr = _cropFilter.targets;
//        [_cropFilter removeAllTargets];
//        [GPUImageContext sharedImageProcessingContext];
//        [_cameraCurrent resetBenchmarkAverage];
//
//        for (GPUImageFilter *filter in tmpArr) {
//            [_cropFilter addTarget:filter];
//        }
        if (_insertFilter) {
//            [_cropFilter removeTarget:_insertFilter];
            [_insertFilter removeTarget:self.presentView];
        }
        
        [_cameraCurrent resetBenchmarkAverage];
        _insertFilter = filter;
        [_cropFilter addTarget:_insertFilter];
        [_insertFilter addTarget:self.presentView];
    });

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
    [_cameraCurrent pauseCameraCapture];
}

- (void)resumeCamera {
    [_cameraCurrent resumeCameraCapture];
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
