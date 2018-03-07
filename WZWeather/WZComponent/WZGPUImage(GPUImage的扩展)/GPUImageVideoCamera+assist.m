//
//  GPUImageVideoCamera+assist.m
//  WZWeather
//
//  Created by Wizet on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//
#import <CoreMotion/CoreMotion.h>
#import "GPUImageVideoCamera+assist.h"
@interface GPUImageVideoCamera()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) CMMotionManager *motionManager;                   // 手机方向检查

@end

@implementation GPUImageVideoCamera (assist)


- (void)setFlashType:(GPUImageCameraFlashType)type {
    //判断为后面镜头 前镜头则默认为关闭状态
    AVCaptureDevice *lens = self.inputCamera;
    NSError *error = nil;
    if (self.inputCamera == [self deviceWithPosition:AVCaptureDevicePositionFront]) {
        [lens lockForConfiguration:&error];
        lens.flashMode = AVCaptureFlashModeOff;
        lens.torchMode = AVCaptureTorchModeOff;
        [lens unlockForConfiguration];
    } else if (self.inputCamera == [self deviceWithPosition:AVCaptureDevicePositionBack]) {
        NSError *error = nil;
        [lens lockForConfiguration:&error];
        lens.torchMode = AVCaptureTorchModeOff;
        if (type == GPUImageCameraFlashType_on) {
            lens.flashMode = AVCaptureFlashModeOn;
        } else if (type == GPUImageCameraFlashType_auto) {
            lens.flashMode = AVCaptureFlashModeAuto;
        } else {
            lens.flashMode = AVCaptureFlashModeOff;
        }
        [lens unlockForConfiguration];
    }
}

- (void)setTorchType:(GPUImageCameraTorchType)type {
    //判断为后面镜头 前镜头则默认为关闭状态
    AVCaptureDevice *lens = self.inputCamera;
    NSError *error = nil;
    if (self.inputCamera == [self deviceWithPosition:AVCaptureDevicePositionFront]) {
        [lens lockForConfiguration:&error];
        lens.flashMode = AVCaptureFlashModeOff;
        lens.torchMode = AVCaptureTorchModeOff;
        [lens unlockForConfiguration];
    } else if (self.inputCamera == [self deviceWithPosition:AVCaptureDevicePositionBack]) {
        NSError *error = nil;
        [lens lockForConfiguration:&error];
        lens.torchMode = AVCaptureTorchModeOff;
        if (type == GPUImageCameraTorchType_on) {
            lens.torchMode = AVCaptureTorchModeOn;
        } else if (type == GPUImageCameraTorchType_auto) {
            lens.torchMode = AVCaptureTorchModeAuto;
        } else {
            lens.torchMode = AVCaptureTorchModeOff;
        }
        [lens unlockForConfiguration];
    }
}

///返回与position关联的设备
- (AVCaptureDevice *)deviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}


#pragma mark - Accessor
- (CMMotionManager *)motionManager {
    return objc_getAssociatedObject(self, @selector(setMotionManager:));
}

- (void)setMotionManager:(CMMotionManager *)motionManager {
    objc_setAssociatedObject(self, @selector(setMotionManager:), motionManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setDefaultFormat:(AVCaptureDeviceFormat *)defaultFormat {
    objc_setAssociatedObject(self, @selector(setDefaultFormat:), defaultFormat, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AVCaptureDeviceFormat *)defaultFormat {
    return objc_getAssociatedObject(self, @selector(setDefaultFormat:));
}

- (void)setDefaultVideoMaxFrameDuration:(CMTime)defaultVideoMaxFrameDuration {
    objc_setAssociatedObject(self, @selector(setDefaultVideoMaxFrameDuration:), [NSValue valueWithCMTime:defaultVideoMaxFrameDuration], OBJC_ASSOCIATION_ASSIGN);
}

- (CMTime)defaultVideoMaxFrameDuration {
    return [objc_getAssociatedObject(self, @selector(setDefaultVideoMaxFrameDuration:)) CMTimeValue];
}

///使用陀螺仪检测设备方向
- (void)addCMMotionToMobile {
    self.motionManager = [[CMMotionManager alloc] init];
    if (self.motionManager.isAccelerometerAvailable) {
        self.motionManager.accelerometerUpdateInterval = 1.0/3.0; // 1秒钟采样5次
        //得到一个检查方向的回调
        __weak typeof(self) weakSelf = self;
        
        [ self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            CMAcceleration acceleration = weakSelf.motionManager.accelerometerData.acceleration;
           
                UIDeviceOrientation orientation = UIDeviceOrientationPortrait;
                if (acceleration.x < -0.8 && (0.5>acceleration.y >-0.8)) {
                    orientation = UIDeviceOrientationLandscapeLeft;
                    //左边
                } else if (acceleration.x > 0.8 && (0.5>acceleration.y >-0.2)) {
                    orientation = UIDeviceOrientationLandscapeRight;
                    //右边
                } else if((0.7>=acceleration.x >=-0.7) && acceleration.y > 0.9) {
                    orientation = UIDeviceOrientationPortraitUpsideDown;
                    //颠倒
                } else if((0.3>=acceleration.x >=-0.3) && acceleration.y < -0.7) {
                    orientation = UIDeviceOrientationPortrait;
                    //正面
                }
        }];
    }
}

///自动对焦 以及 自动曝光 点的自定义
- (void)autoFocusAndExposureAtPoint:(CGPoint)point
{
    AVCaptureDevice *tmpDevice = self.inputCamera;
    if ([tmpDevice isFocusPointOfInterestSupported]
        && [tmpDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([tmpDevice lockForConfiguration:&error]) {
            [tmpDevice setFocusPointOfInterest:point];
            [tmpDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [tmpDevice unlockForConfiguration];
        } else {
            NSLog(@"自动对焦错误：%@",[error description]);
        }
    }
    if ([tmpDevice isExposurePointOfInterestSupported]//是否支持对一个兴趣点进行聚焦
        && [tmpDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([tmpDevice lockForConfiguration:&error]) {
            [tmpDevice setExposurePointOfInterest:point];
            [tmpDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [tmpDevice unlockForConfiguration];
        } else {
            NSLog(@"自动曝光错误：%@",[error description]);
        }
    }
}

//曝光量自动变更、曝光点自定义 setExposurePointOfInterest ： A value of (0,0) indicates that the camera should adjust exposure based on the top left corner of the image, while a value of (1,1) indicates that it should adjust exposure based on the bottom right corner.
- (void)exposureAtPoint:(CGPoint)point {
    AVCaptureDevice *tmpDevice = self.inputCamera;
    if ([tmpDevice isExposurePointOfInterestSupported]//是否支持对一个兴趣点进行曝光
        && [tmpDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([tmpDevice lockForConfiguration:&error]) {
            [tmpDevice setExposurePointOfInterest:point];
            [tmpDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [tmpDevice unlockForConfiguration];
        } else {
            NSLog(@"定点曝光错误：%@",[error description]);
        }
    }
}

//定点对焦 setFocusPointOfInterest ： A value of (0,0) indicates that the camera should focus on the top left corner of the image, while a value of (1,1) indicates that it should focus on the bottom right.
- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *tmpDevice = self.inputCamera;
    if ([tmpDevice isFocusPointOfInterestSupported]
        && [tmpDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error;
        if ([tmpDevice lockForConfiguration:&error]) {
            [tmpDevice setFocusPointOfInterest:point];
            [tmpDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            // [tmpDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            [tmpDevice unlockForConfiguration];
        } else {
            NSLog(@"定点对焦错误：%@",[error description]);
        }
    }
}

///人像识别 二维码
- (void)configMetadataOutputWithDelegete {
    [self.captureSession beginConfiguration];
    AVCaptureMetadataOutput *_metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    if ([self.captureSession canAddOutput:_metadataOutput]) {
        [self.captureSession addOutput:_metadataOutput];
        NSArray* supportTypes = _metadataOutput.availableMetadataObjectTypes;
        if ([supportTypes containsObject:AVMetadataObjectTypeFace]) {
            [_metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
            [_metadataOutput setMetadataObjectsDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)self queue:dispatch_get_main_queue()];
            
        }
    }
    [self.captureSession commitConfiguration];
}

#pragma mark - 二维码扫描代理 人脸识别 AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
//    if ([metadataObjects count]) {
//        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
//        NSString *result;
//        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
//            result = metadataObj.stringValue;
//            NSLog(@"得到扫描结果 %@", result);
//        }
//    }
    {
        
        if ([self.delegate respondsToSelector:@selector(cameraDidOutputMetadataObjects:)]) {
            [self.delegate performSelector:@selector(cameraDidOutputMetadataObjects:) withObject:metadataObjects];
        }
    }
}

- (void)captureMetadataObject:(AVMetadataFaceObject *)object {
    
}

// 透视投影
static CATransform3D PerspectiveTransformMake(CGFloat eyePosition)
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / eyePosition;
    return transform;
}

- (CGFloat)videoMaxZoomFactor {
    return self.inputCamera.activeFormat.videoMaxZoomFactor;
}

///经过映射的变焦
- (void)setDeviceZoomFactor:(CGFloat)zoomFactor {
    CGFloat maxFactor = [self videoMaxZoomFactor];
    //iPod 6  =  95.625
    
    zoomFactor = 1 + zoomFactor * maxFactor / 10.0;// 除以10.0的操作是为了 缩减放大因子 因为放得太大对客户而言是无用功
    [self deviceZoomFactor:zoomFactor];
}

//标准的变焦
- (void)deviceZoomFactor:(CGFloat)zoomFactor {
   
    CGFloat maxFactor = [self videoMaxZoomFactor];//摄像头最大的缩放等级 缩放等级默认均为1
 
    //可用捕获设备的 activeVideoMinFrameDuration 和 activeVideoMaxFrameDuration 属性设置帧速率，一帧的时长是帧速率的倒数
    //为了确保帧速率恒定，可以将最小与最大的帧时长设置成一样的值
    //self.backLensDevice.activeVideoMinFrameDuration.value
    
    if (zoomFactor < 1.0) {
        zoomFactor = 1.0;
    }
    if (zoomFactor > maxFactor) {
        zoomFactor = maxFactor;
    }
    NSError *error = [self device:self.inputCamera configuration:^{
        [self.inputCamera setVideoZoomFactor:zoomFactor];
    }];
    if (error) {
        //缩放失败
        [WZToast toastWithContent:[NSString stringWithFormat:@"缩放失败:%@", error.description]];
    } else {
        //缩放成功
    }

    //    self.device.activeFormat.videoZoomFactorUpscaleThreshold;
}

//配置设备
- (NSError *)device:(AVCaptureDevice *)device configuration:(void (^)())config {
    NSError *error = nil;
    if (config) {
        BOOL lockAcquired = [device lockForConfiguration:&error];
        if (!lockAcquired) {
            return error;
        } else {
            config();
            [device unlockForConfiguration];
        }
    } else {
        return error = [NSError errorWithDomain:@"未实现config闭包" code:-1 userInfo:nil];
    }
    return error;
}


//MARK:尽量使用低光增强模式
- (void)attemptToUseLowLightMode:(BOOL)boolean {
    //使用一种特殊的低光增强模式来提高图像质量
    if (self.inputCamera.lowLightBoostSupported) {
        self.inputCamera.automaticallyEnablesLowLightBoostWhenAvailable = true;
    }
}


//MARK:SlowMotionVideoRecorder 中的代码 配置到自定义的帧率  慢动作 一般是120FPS 或者是 240FPS
- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS {
    
    //保存原始设置
    if (CMTimeCompare(self.defaultVideoMaxFrameDuration, kCMTimeZero) == 0) {
        [self setDefaultFormat:self.inputCamera.activeFormat];
        [self setDefaultVideoMaxFrameDuration:self.inputCamera.activeVideoMaxFrameDuration];
    }
    
    //记录拍摄状态
    BOOL isRunning = self.captureSession.isRunning;
    [self stopCameraCapture];
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceFormat *selectedFormat = nil;
    int32_t maxWidth = 0;
    AVFrameRateRange *frameRateRange = nil;
    
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            
            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth) {
                
                selectedFormat = format;
                frameRateRange = range;
                maxWidth = width;
            }
        }
    }
    
    if (selectedFormat) {
        
        if ([videoDevice lockForConfiguration:nil]) {
            NSLog(@"selected format:%@", selectedFormat);
            videoDevice.activeFormat = selectedFormat;
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            [videoDevice unlockForConfiguration];
        }
    }
    
    //恢复拍摄状态
    if (isRunning) {
        [self startCameraCapture];
    }
}

//MARK:恢复默认帧率
- (void)resetFrameActiveFormat {
    //保存原始设置
    if (CMTimeCompare(self.defaultVideoMaxFrameDuration, kCMTimeZero) == 0) {
        BOOL isRunning = self.captureSession.isRunning;
        
        if (isRunning) {
            [self.captureSession stopRunning];
        }
        
        AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [videoDevice lockForConfiguration:nil];
        videoDevice.activeFormat = self.defaultFormat;
        videoDevice.activeVideoMaxFrameDuration = self.defaultVideoMaxFrameDuration;
        [videoDevice unlockForConfiguration];
        
        if (isRunning) {
            [self.captureSession startRunning];
        }
    }
}

@end
