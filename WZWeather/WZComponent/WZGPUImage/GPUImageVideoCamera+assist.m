//
//  GPUImageVideoCamera+assist.m
//  WZWeather
//
//  Created by admin on 6/11/17.
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

-(void)setAssistDelegate:(id<GPUImageVideoCameraAssistProtocol>)assistDelegate {
    objc_setAssociatedObject(self, @selector(setAssistDelegate:), assistDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<GPUImageVideoCameraAssistProtocol>)assistDelegate {
   return objc_getAssociatedObject(self, @selector(setAssistDelegate:));
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
            if ([self.assistDelegate respondsToSelector:@selector(videoCamera:currentOrientation:)]) {
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
                [self.assistDelegate videoCamera:self currentOrientation:orientation];
            }
        }];
    }
}

@end
