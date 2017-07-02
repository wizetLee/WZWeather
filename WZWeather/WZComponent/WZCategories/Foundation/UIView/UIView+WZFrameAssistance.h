//
//  UIView+WZFrameAssistance.h
//  WZWeather
//
//  Created by wizet on 2017/7/1.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WZFrameAssistance)

- (CGFloat)x;
- (void)setX:(CGFloat)x;

- (CGFloat)y;
- (void)setY:(CGFloat)y;

- (CGFloat)width;
- (void)setWidth:(CGFloat)width;

- (CGFloat)height;
- (void)setHeight:(CGFloat)height;

- (CGFloat)centerX;
- (void)setCenterX:(CGFloat)x;

- (CGFloat)centerY;
- (void)setCenterY:(CGFloat)y;

- (CGFloat)maxX;
- (void)setMaxX:(CGFloat)maxX;

- (CGFloat)minX;
- (void)setMinX:(CGFloat)minX;

- (CGFloat)maxY;
- (void)setMaxY:(CGFloat)maxY;

- (CGFloat)minY;
- (void)setMinY:(CGFloat)minY;

@end
