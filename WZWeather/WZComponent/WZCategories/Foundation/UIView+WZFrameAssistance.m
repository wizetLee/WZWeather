//
//  UIView+WZFrameAssistance.m
//  WZWeather
//
//  Created by wizet on 2017/7/1.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "UIView+WZFrameAssistance.h"

@implementation UIView (WZFrameAssistance)

- (CGFloat)x {
    return self.frame.origin.x;
}
- (void)setX:(CGFloat)x {
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}


- (CGFloat)y {
    return self.frame.origin.y;
}
- (void)setY:(CGFloat)y {
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}


- (CGFloat)width {
    return self.frame.size.width;
}
- (void)setWidth:(CGFloat)width {
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}


- (CGFloat)height {
    return self.frame.size.height;
}
- (void)setHeight:(CGFloat)height {
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}


- (CGFloat)centerX {
    return self.center.x;
}
- (void)setCenterX:(CGFloat)x {
    self.center = CGPointMake(x, self.center.y);
}


- (CGFloat)centerY {
    return self.center.y;
}
- (void)setCenterY:(CGFloat)y {
    self.center = CGPointMake(self.center.x, y);
}


- (CGFloat)maxX {
    return self.x + self.width;
}
- (void)setMaxX:(CGFloat)maxX {
    self.x = maxX - self.width;
}


- (CGFloat)minX {
    return self.x;
}
- (void)setMinX:(CGFloat)minX {
    self.x = minX;
}


- (CGFloat)maxY {
    return self.y + self.height;
}
- (void)setMaxY:(CGFloat)maxY {
    self.y = maxY - self.height;
}


- (CGFloat)minY {
    return self.y;
}
- (void)setMinY:(CGFloat)minY {
    self.y = minY;
}

@end
