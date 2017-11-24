//
//  UIView+WZMinistrant.h
//  WZWeather
//
//  Created by wizet on 2017/7/2.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WZMinistrant)

/**
 *  UIView的圆角设置
 */
@property (nonatomic, assign) CGFloat wz_cornerRadius;//圆角设置

/**
 *  设置View layer的cornerRadius
 *
 *  @param cornerRadius
 */
- (void)setWz_cornerRadius:(CGFloat)cornerRadius;

/**
 *  返回View layer的cornerRadius
 *
 *  @return cornerRadius
 */
- (CGFloat)wz_cornerRadius;


@end
