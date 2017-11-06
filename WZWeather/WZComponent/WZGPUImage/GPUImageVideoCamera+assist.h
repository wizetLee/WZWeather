//
//  GPUImageVideoCamera+assist.h
//  WZWeather
//
//  Created by admin on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <GPUImage/GPUImage.h>


@protocol GPUImageVideoCameraAssistProtocol<NSObject>

- (void)videoCamera:(GPUImageVideoCamera *)camera currentOrientation:(UIDeviceOrientation *)orientation;

@end

typedef NS_ENUM(NSUInteger, GPUImageCameraFlashType) {
    GPUImageCameraFlashType_auto,
    GPUImageCameraFlashType_on,
    GPUImageCameraFlashType_off,
};

typedef NS_ENUM(NSUInteger, GPUImageCameraTorchType) {
    GPUImageCameraTorchType_auto,
    GPUImageCameraTorchType_on,
    GPUImageCameraTorchType_off,
};

@interface GPUImageVideoCamera (assist)

@property (nonatomic, weak) id<GPUImageVideoCameraAssistProtocol> assistDelegate;

- (void)setFlashType:(GPUImageCameraFlashType)type;
- (void)setTorchType:(GPUImageCameraTorchType)type;
///使用陀螺仪检测设备方向
- (void)addCMMotionToMobile;


@end
