//
//  GPUImageEnlargeFilter.h
//  WZWeather
//
//  Created by 李炜钊 on 2017/12/9.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <GPUImage/GPUImage.h>

/**
 自定义的GPUImage扩展。扩大效果。仿抖音
 */
@interface GPUImageEnlargedFilter : GPUImageFilter

/**
 扩大权重设置
 */
@property (nonatomic, assign) float enlargeWeight;//0.0~0.1  效果比较好

@end
