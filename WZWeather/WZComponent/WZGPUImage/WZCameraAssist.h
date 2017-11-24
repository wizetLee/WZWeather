//
//  WZCameraAssist.h
//  WZWeather
//
//  Created by wizet on 7/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZCameraAssist : NSObject

#pragma mark - 去除系统声音（添加文件时勾选add to target）
+ (void)removeSystemSound;
#pragma mark - 从图片中直接读取二维码 iOS8.0
+ (NSString *)scQRReaderForImage:(UIImage *)qrimage;

#pragma mark - 权限检查
+ (void)checkAuthorizationWithHandler:(void (^)(BOOL videoAuthorization, BOOL audioAuthorization, BOOL libraryAuthorization))handler;

#pragma mark  - 打开应用设置项
+ (void)openAppSettings;
@end
