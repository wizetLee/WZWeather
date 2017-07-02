//
//  UIView+WZMinistrant.m
//  WZWeather
//
//  Created by wizet on 2017/7/2.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "UIView+WZMinistrant.h"

@implementation UIView (WZMinistrant)
- (void)setCornerRadius:(CGFloat)cornerRadius {
    objc_setAssociatedObject(self, @selector(setCornerRadius:), @(cornerRadius), OBJC_ASSOCIATION_ASSIGN);
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
    return [objc_getAssociatedObject(self, @selector(setCornerRadius:)) floatValue];
}

@end
