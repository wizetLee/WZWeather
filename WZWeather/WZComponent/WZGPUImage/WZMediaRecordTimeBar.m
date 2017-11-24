//
//  WZMediaRecordTimeBar.m
//  WZWeather
//
//  Created by wizet on 21/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaRecordTimeBar.h"

@interface WZMediaRecordTimeBar()

@property (nonatomic, strong) CALayer *maskLayer;

@end

@implementation WZMediaRecordTimeBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    _maskLayer = [CALayer layer];
    [self.layer addSublayer:_maskLayer];
    _maskLayer.frame = CGRectMake(0.0, 0.0, 0.0, self.height);
    _maskLayer.backgroundColor = MACRO_COLOR_RGB(123, 123, 123).CGColor;
}

- (void)setProgress:(CGFloat)progress {
    if (progress > 1) {
        progress = 1;
    } else if (progress < 0) {
        progress = 0;
    }
    
    _maskLayer.frame = CGRectMake(0.0, 0.0, self.frame.size.width * progress, self.frame.size.height);
    
};

- (void)addSign {
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(_maskLayer.frame.size.width - self.height / 3.0, 0.0 , self.height / 3.0 , self.height);
    layer.backgroundColor = [UIColor blackColor].CGColor;
    [_maskLayer addSublayer:layer];
}

- (void)formatting {
    for (CALayer *tmpLayer in _maskLayer.sublayers) {
        [tmpLayer removeFromSuperlayer];
    }
    _maskLayer.frame = CGRectMake(0.0, 0.0, 0.0, self.height); 
}

@end
