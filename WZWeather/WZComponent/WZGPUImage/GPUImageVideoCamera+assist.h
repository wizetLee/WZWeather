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

//MARK:闪光灯
- (void)setFlashType:(GPUImageCameraFlashType)type;
//MARK:手电筒
- (void)setTorchType:(GPUImageCameraTorchType)type;

//MARK:焦点和曝光点[0,0] ~ [1,1]
- (void)autoFocusAndExposureAtPoint:(CGPoint)point;
- (void)exposureAtPoint:(CGPoint)point;
- (void)focusAtPoint:(CGPoint)point;

//MARK:镜头的变焦
- (CGFloat)videoMaxZoomFactor;
- (void)setDeviceZoomFactor:(CGFloat)zoomFactor;

//MARK:设置和获取系统默认的拍摄帧率  慢动作配置之前的原始数据的保存
- (void)setDefaultVideoMaxFrameDuration:(CMTime)defaultVideoMaxFrameDuration;
- (CMTime)defaultVideoMaxFrameDuration;
- (void)setDefaultFormat:(AVCaptureDeviceFormat *)defaultFormat;
- (AVCaptureDeviceFormat *)defaultFormat;

//MARK:使用陀螺仪检测设备方向   建议使用一个全局接收通知
- (void)addCMMotionToMobile;
- (void)configMetadataOutputWithDelegete;


//MARK:在回调中配置设备
- (NSError *)device:(AVCaptureDevice *)device configuration:(void (^)())config;


//MARK:尽量使用低光增强模式
- (void)attemptToUseLowLightMode:(BOOL)boolean;





//MARK:SlowMotonVideoRecorder 中的代码            配置自定义的帧率
- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS;
//MARK:恢复默认帧率
- (void)resetFrameActiveFormat;





@end
