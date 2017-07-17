//
//  UIButton+WZMinistrant.m
//  WZWeather
//
//  Created by wizet on 2017/7/2.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "UIButton+WZMinistrant.h"

@implementation UIButton (WZMinistrant)

- (void)setNormalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage {
    if ([normalImage isKindOfClass:[UIImage class]]) {
        [self setImage:normalImage forState:UIControlStateNormal];
    }
    if ([highlightedImage isKindOfClass:[UIImage class]]) {
        [self setImage:highlightedImage forState:UIControlStateHighlighted];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    objc_setAssociatedObject(self, @selector(setCornerRadius:), @(cornerRadius), OBJC_ASSOCIATION_ASSIGN);
    self.imageView.layer.cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    
}


@end
