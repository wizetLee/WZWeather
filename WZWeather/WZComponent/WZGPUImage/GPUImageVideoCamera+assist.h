//
//  GPUImageVideoCamera+assist.h
//  WZWeather
//
//  Created by Wizet on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <GPUImage/GPUImage.h>


@protocol GPUImageVideoCameraAssistProtocol<NSObject>


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


- (void)setFlashType:(GPUImageCameraFlashType)type;
- (void)setTorchType:(GPUImageCameraTorchType)type;

//(0,0) ~ (1,1)
- (void)autoFocusAndExposureAtPoint:(CGPoint)point;
- (void)exposureAtPoint:(CGPoint)point;
- (void)continuousFocusAtPoint:(CGPoint)point;



///使用陀螺仪检测设备方向   建议使用一个全局接收通知
- (void)addCMMotionToMobile;


@end
