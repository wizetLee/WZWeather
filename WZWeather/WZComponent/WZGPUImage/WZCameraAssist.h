//
//  WZCameraAssist.h
//  WZWeather
//
//  Created by admin on 7/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZCameraAssist : NSObject

#pragma mark - 去除系统声音（添加文件时勾选add to target）
+ (void)removeSystemSound:(BOOL)boolean;
#pragma mark - 从图片中直接读取二维码 iOS8.0
+ (NSString *)scQRReaderForImage:(UIImage *)qrimage;

@end
