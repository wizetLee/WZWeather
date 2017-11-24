//
//  UIView+WZMinistrant.m
//  WZWeather
//
//  Created by wizet on 2017/7/2.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "UIView+WZMinistrant.h"

@implementation UIView (WZMinistrant)
- (void)setWz_cornerRadius:(CGFloat)cornerRadius {
    objc_setAssociatedObject(self, @selector(setWz_cornerRadius:), @(cornerRadius), OBJC_ASSOCIATION_ASSIGN);
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)wz_cornerRadius {
    return [objc_getAssociatedObject(self, @selector(setWz_cornerRadius:)) floatValue];
}



@end
