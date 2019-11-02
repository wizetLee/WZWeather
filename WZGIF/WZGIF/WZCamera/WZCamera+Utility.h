//
//  WZCamera+Utility.h
//  WZGIF
//
//  Created by admin on 28/7/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZCamera.h"

@interface WZCamera (Utility)
#pragma mark - Class Method
#pragma mark - 设备方向转捕捉摄像方向
+ (AVCaptureVideoOrientation)captureVideoOrientationRelyDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
#pragma mark - 去除系统声音（添加文件时勾选add to target）
+ (void)removeSystemSound:(BOOL)boolean;
#pragma mark - 从图片中直接读取二维码 iOS8.0
+ (NSString *)scQRReaderForImage:(UIImage *)qrimage;

//旋转图片（顺时针为+）
//+ (UIImage *)imageRotatedByDegrees:(CGFloat)degrees withImage:(UIImage*)image;
//出来样本
+ (UIImage *)dealSampleBuffer:(CMSampleBufferRef)sampleBuffer;
//采样样本缓存
+ (UIImage *)imageFromSamplePlanerPixelBuffer:(CMSampleBufferRef)sampleBuffer;
//合成视频 若干段视频合成一段视频
+ (AVMutableComposition *)compositionWithSegments:(NSArray <WZRecordSegment *>*)segments;

#pragma mark - Instance Method

#pragma mark - 根据编码格式返回文件名后缀
- (NSString *)suggestedFileExtensionAccordingEncodingFileType:(NSString *)fileType;

//输出配置接口

@end
