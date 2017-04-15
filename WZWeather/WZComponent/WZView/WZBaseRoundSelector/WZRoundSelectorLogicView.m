//
//  WZRoundSelectorLogicView.m
//  WZBaseRoundSelector
//
//  Created by admin on 17/3/28.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZRoundSelectorLogicView.h"

@interface WZRoundSelectorLogicView ()

@property (nonatomic, strong) WZRoundRenderLayer *renderLayer;

@end



@implementation WZRoundSelectorLogicView


- (instancetype) initWithFrame:(CGRect)frame
                      curValue:(double)curValue
                      maxValue:(double)maxValue {
    if (self = [super initWithFrame:frame]) {
        if (curValue < 0) {curValue = 0;}
        if (maxValue < 0) {maxValue = 0;}
        if (maxValue < curValue) { maxValue = curValue;};
        _curValue = curValue;
        _maxValue = maxValue;
        
        [self addSubviews];
        
        //分配区域
        if (_curValue <= _maxValue * (1 / 4.0)) {
            _status = 1;
        } else if (_curValue <= _maxValue * (2 / 4.0)) {
            _status = 2;
        } else if (_curValue <= _maxValue * (3 / 4.0)) {
            _status = 3;
        } else if (_curValue <= _maxValue * (4 / 4.0)) {
            _status = 4;
        }
        
    }
    return self;
}

- (void)addSubviews {
    self.backgroundColor = [UIColor clearColor];
    [self.layer addSublayer:self.renderLayer];
}

//手势触发渲染layer
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self caculateAngleWith:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self caculateAngleWith:touches];
}

- (void)caculateAngleWith:(NSSet<UITouch *>*)touches {
    CGPoint curPoint = [[touches anyObject] locationInView:self];
    CGPoint centerRelativeToFatherView = CGPointMake(0.0 + self.frame.size.width / 2.0
                                                     , 0.0 + self.frame.size.height / 2.0);
    //计算tan值
    double currentAngle = atan2(curPoint.y - centerRelativeToFatherView.y
                                , curPoint.x - centerRelativeToFatherView.x);
    
    double renderAngle = currentAngle;
    {//计算之前点的位置的部分
        if ((currentAngle > -M_PI_2 && currentAngle <= 0)   /*-M_PI_2 ~ 0*/ //1 ~ 2
            || (currentAngle > 0 && currentAngle <= M_PI_2)) {
            if (_status == 4) {
                renderAngle =  M_PI * 2;
                _status = 4;
            } else {
                renderAngle = currentAngle + M_PI_2;
                if (currentAngle > -M_PI_2 && currentAngle <= 0) {
                    _status = 1;
                } else {
                    _status = 2;
                }
            }
        } else {                                            // M_PI_2 ~  M_PI_2 * 3  //3 ~ 4
            if (_status == 1) {
                renderAngle = 0;
                _status = 1;
            } else {
                if (currentAngle > M_PI_2 && currentAngle <= M_PI) {
                    _status = 3;
                    if ((curPoint.x - centerRelativeToFatherView.x) == 0) {
                        renderAngle = M_PI;
                    } else {
                        renderAngle = currentAngle + M_PI_2;
                    }
                } else {
                    _status = 4;
                    if ((curPoint.x - centerRelativeToFatherView.x) == 0) {//特殊情况 x ＝ 0
                        renderAngle = M_PI * 2;
                    } else {
                        renderAngle = currentAngle + M_PI_2 * 5;
                    }
                }
            }
        }
    }
    //渲染
    [self renderAngle:renderAngle];
    [self metric:renderAngle / (M_PI * 2.0)];
}

- (void)metric:(double)metric {
  
}

- (void)renderAngle:(double)renderAngle {
    _renderLayer.renderAngle = renderAngle;
}

+ (CGFloat)ratio {
    CGFloat screen6W = 375.0;
    CGFloat acpectAspectRatio = 1.0;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (fabs(screenWidth - 414.0) < 0.2)/*6s、7s*/ {
        acpectAspectRatio = 414.0 / screen6W ;
    } else if (fabs(screenWidth - 320.0) < 0.2) {
        acpectAspectRatio = 320.0 / screen6W;
    } else {
        acpectAspectRatio = screen6W / screen6W;
    }
    return acpectAspectRatio;
}

#pragma mark WZRoundRenderLayerDelegate
- (void)renderPathCurrentPoint:(CGPoint)currentPoint {
    
}

#pragma mark setter & getter

- (WZRoundRenderLayer *)renderLayer {
    if (!_renderLayer) {
        CGFloat radius = self.bounds.size.width > self.bounds.size.height  ? self.bounds.size.height / 2.0: self.bounds.size.width / 2.0 ;
        _renderLayer = [[WZRoundRenderLayer alloc] initWithCircleRadius:radius layerLineWidth:15.0];
        _renderLayer.position = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        _renderLayer.renderLayerDelegate = (id<WZRoundRenderLayerDelegate>)self;
    }
    return _renderLayer;
}


@end
