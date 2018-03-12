//
//  WZBlackWhiteMaskTwoInputFilter.h
//  WZWeather
//
//  Created by admin on 23/2/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface WZBlackWhiteMaskTwoInputFilter : GPUImageTwoInputFilter

@property (nonatomic, assign) int type;//移除黑色部分  移除白色部分 

@end
