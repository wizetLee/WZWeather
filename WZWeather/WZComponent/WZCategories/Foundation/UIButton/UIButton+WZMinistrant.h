//
//  UIButton+WZMinistrant.h
//  WZWeather
//
//  Created by wizet on 2017/7/2.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+WZMinistrant.h"

@interface UIButton (WZMinistrant)

- (void)wz_setNormalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage;


- (void)wz_setCornerRadius:(CGFloat)cornerRadius;

@end
