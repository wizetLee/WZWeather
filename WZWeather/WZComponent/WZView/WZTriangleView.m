//
//  WZTriangleView.m
//  WZSettingPicker
//
//  Created by admin on 16/12/26.
//  Copyright © 2016年 WZ. All rights reserved.
//

#import "WZTriangleView.h"

@implementation WZTriangleView

@synthesize bgColor = _bgColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeSubviews];
    }
    return self;
}

- (void)initializeSubviews {
    self.backgroundColor = [UIColor clearColor];
    
    if (_triangleLayer) {
        [_triangleLayer removeFromSuperlayer];
    }
    _triangleLayer = [CAShapeLayer layer];
    [_triangleLayer setFillColor:self.bgColor.CGColor];
    [self.layer addSublayer:_triangleLayer];
    [self getPath];
}

- (void)getPath {
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(0.0
                                          , self.frame.size.height)];
    [trianglePath addLineToPoint:CGPointMake(self.frame.size.width
                                             , self.frame.size.height)];
    [trianglePath addLineToPoint:CGPointMake(self.frame.size.width / 2.0 +_verticalPointOffsetX
                                             , 0.0)];
    _triangleLayer.path = trianglePath.CGPath;
}


#pragma mark setter & getter
- (void)setVerticalPointOffsetX:(CGFloat)verticalPointOffsetX {
    _verticalPointOffsetX = verticalPointOffsetX;
    [self getPath];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self initializeSubviews];
}

- (void)setBgColor:(UIColor *)bgColor {
    if ([bgColor isKindOfClass:[UIColor class]]) {
        _bgColor = bgColor;
        if (_triangleLayer) {
             [_triangleLayer setFillColor:_bgColor.CGColor];
        }
    }
}

- (UIColor *)bgColor {
    if (!_bgColor) {
        _bgColor = [UIColor blackColor];
    }
    return _bgColor;
}

@end
