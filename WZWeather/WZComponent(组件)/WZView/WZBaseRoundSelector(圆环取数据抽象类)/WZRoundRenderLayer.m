//
//  WZRoundRenderLayer.m
//  WZBaseRoundSelector
//
//  Created by wizet on 17/3/28.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZRoundRenderLayer.h"

@interface WZRoundRenderLayer ()

@property (nonatomic, strong) CAShapeLayer *surfaceLayer;
@property (nonatomic, strong) CAShapeLayer *bottomLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) UIBezierPath *renderBezierPath;

@property (nonatomic, assign) CGFloat circleRadius;
@property (nonatomic, assign) CGFloat layerLineWidth;

@end


@implementation WZRoundRenderLayer


- (instancetype)initWithCircleRadius:(CGFloat)circleRadius layerLineWidth:(CGFloat)layerLineWidth {
    if (self = [super init]) {
        _circleRadius = circleRadius;
        _layerLineWidth = layerLineWidth;
        self.frame = CGRectZero;
 
        UIBezierPath *tmpBezierPath = [UIBezierPath bezierPath];
        CGFloat circleWH = _circleRadius - _layerLineWidth / 2.0;
        [tmpBezierPath addArcWithCenter:CGPointMake(_circleRadius, _circleRadius)
                                 radius:circleWH
                             startAngle:-M_PI_2
                               endAngle:M_PI_2 * 3.0
                              clockwise:true];
        
        self.bottomLayer.path = tmpBezierPath.CGPath;
        self.surfaceLayer.path = tmpBezierPath.CGPath;
        self.surfaceLayer.mask = self.maskLayer;
        [self addSublayer:self.bottomLayer];
        [self addSublayer:self.surfaceLayer];

    }
    return self;
}

//frame 的size 由 _circleRadius 决定
- (void)setFrame:(CGRect)frame {
    [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, _circleRadius * 2.0, _circleRadius * 2.0)];
}

#pragma mark - Accessor

- (CAShapeLayer *)surfaceLayer {
    if (!_surfaceLayer) {
        _surfaceLayer = [CAShapeLayer layer];
        _surfaceLayer.fillColor = [UIColor clearColor].CGColor;
        _surfaceLayer.strokeColor = MACRO_COLOR_HEX(0xffc529).CGColor;
        _surfaceLayer.lineWidth = _layerLineWidth;
        _surfaceLayer.lineCap = @"round";
    }
    return _surfaceLayer;
}


- (CAShapeLayer *)bottomLayer {
    if (!_bottomLayer) {
        _bottomLayer = [CAShapeLayer layer];
        _bottomLayer.fillColor = [UIColor clearColor].CGColor;
        _bottomLayer.strokeColor = MACRO_COLOR_HEX(0xfff8ea).CGColor;
        _bottomLayer.lineWidth = _layerLineWidth;
        _bottomLayer.lineCap = @"round";
    }
    return _bottomLayer;
}


- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.strokeColor = [UIColor whiteColor].CGColor;
        _maskLayer.fillColor = [UIColor clearColor].CGColor;
        _maskLayer.lineWidth = _layerLineWidth;
        _maskLayer.lineCap = @"round";
    }
    return _maskLayer;
}


- (UIBezierPath *)renderBezierPath {
    if (!_renderBezierPath) {
        _renderBezierPath = [UIBezierPath bezierPath];
    }
    return _renderBezierPath;
}

- (void)setRenderAngle:(double)renderAngle {
    if (renderAngle < 0) {
        renderAngle = 0;
    }
    if (renderAngle > M_PI * 2.0) {
        renderAngle = M_PI * 2.0;
    }
    renderAngle = renderAngle - M_PI_2;
    _renderAngle = renderAngle;
    
    CGFloat circleWH =  _circleRadius - _layerLineWidth / 2.0;
    [self.renderBezierPath removeAllPoints];
    [_renderBezierPath addArcWithCenter:CGPointMake(_circleRadius, _circleRadius)
                               radius:circleWH
                           startAngle:- M_PI_2
                             endAngle:_renderAngle
                            clockwise:1];
    self.maskLayer.path = _renderBezierPath.CGPath;
    if ([self.renderLayerDelegate respondsToSelector:@selector(renderPathCurrentPoint:)]) {
        [self.renderLayerDelegate renderPathCurrentPoint:_renderBezierPath.currentPoint];
    }
}


@end
