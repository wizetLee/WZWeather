//
//  GPUImageVideoCamera+assist.m
//  WZWeather
//
//  Created by Wizet on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//
#import <CoreMotion/CoreMotion.h>
#import "GPUImageVideoCamera+assist.h"
@interface GPUImageVideoCamera()

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

///自动对焦 以及 自动曝光、曝光点自定义
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
    if ([tmpDevice isExposurePointOfInterestSupported]
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
    if ([tmpDevice isExposurePointOfInterestSupported]
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
- (void)continuousFocusAtPoint:(CGPoint)point {
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


@end
