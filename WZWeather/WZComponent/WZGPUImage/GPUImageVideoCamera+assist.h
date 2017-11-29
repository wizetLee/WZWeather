//
//  GPUImageVideoCamera+assist.h
//  WZWeather
//
//  Created by Wizet on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <GPUImage/GPUImage.h>


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

///闪光灯
- (void)setFlashType:(GPUImageCameraFlashType)type;
///手电筒
- (void)setTorchType:(GPUImageCameraTorchType)type;

///焦点和曝光点[0,0] ~ [1,1]
- (void)autoFocusAndExposureAtPoint:(CGPoint)point;
- (void)exposureAtPoint:(CGPoint)point;
- (void)focusAtPoint:(CGPoint)point;

///镜头的变焦
- (CGFloat)videoMaxZoomFactor;
- (void)setDeviceZoomFactor:(CGFloat)zoomFactor;


///使用陀螺仪检测设备方向   建议使用一个全局接收通知
- (void)addCMMotionToMobile;
- (void)configMetadataOutputWithDelegete;


///在回调中配置设备
- (NSError *)device:(AVCaptureDevice *)device configuration:(void (^)())config;


- (void)lowLightMode;
@end
