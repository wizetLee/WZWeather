//
//  WZMediaGestureView.m
//  WZWeather
//
//  Created by admin on 7/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaGestureView.h"

@interface WZMediaGestureView()

@property (nonatomic, strong) UIImageView *focusPointer;        //焦点
@property (nonatomic, strong) UIImageView *exposurePointer;     //曝光
@property (nonatomic, assign) CGFloat zoomScale;

@end

@implementation WZMediaGestureView

- (void)createViews {
    self.backgroundColor = [UIColor clearColor];
    _focusPointer = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 66, 66)];
    _focusPointer.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.75];
    _exposurePointer = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 33, 33)];
    _exposurePointer.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.75];
    _exposurePointer.userInteractionEnabled = true;
    _focusPointer.userInteractionEnabled = true;
    [self addSubview:_focusPointer];
    [self addSubview:_exposurePointer];
    _focusPointer.alpha = 0.0;
    _exposurePointer.alpha = 0.0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
    _focusPointer.center = self.center;
    _exposurePointer.center = self.center;
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self addGestureRecognizer:pinch];
}

#pragma mark - gesture
static BOOL focusPointerAndExposurePointerAnimating = false;
///单机手势
- (void)tap:(UITapGestureRecognizer *)tap {
    [_focusPointer.layer removeAnimationForKey:@"blink"];
    [_exposurePointer.layer removeAnimationForKey:@"blink"];
    
    _focusPointer.alpha = 1;
    _exposurePointer.alpha = 1;
    //取消动画
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animation) object:nil];
    if (focusPointerAndExposurePointerAnimating) {
        return;
    }
    CGPoint curPoint = [tap locationInView:self];
    focusPointerAndExposurePointerAnimating = true;
    
    //控制位置
    
    CAAnimationGroup *groupAnimtion = [[self class] groupAnimationWithOrigionPoint:_focusPointer.center destinationPoint:curPoint];
    groupAnimtion.delegate = (id<CAAnimationDelegate>)self;
    [_focusPointer.layer addAnimation:groupAnimtion forKey:@"focusPointerGroupAnimation"];
    
    groupAnimtion = [[self class] groupAnimationWithOrigionPoint:_exposurePointer.center destinationPoint:curPoint];
    groupAnimtion.delegate = (id<CAAnimationDelegate>)self;
    [_exposurePointer.layer addAnimation:groupAnimtion forKey:@"exposurePointerGroupAnimation"];
    
    [self performSelector:@selector(mix:) withObject:[NSValue valueWithCGPoint:curPoint] afterDelay:groupAnimtion.duration];
    
}

+ (CAAnimationGroup *)groupAnimationWithOrigionPoint:(CGPoint)origionPoint destinationPoint:(CGPoint)destinationPoint {
    CAKeyframeAnimation *keyframe1 = [CAKeyframeAnimation animation];
    keyframe1.keyPath = @"position";
    keyframe1.keyTimes = @[@(0), @(1)];
    keyframe1.values = @[[NSValue valueWithCGPoint:origionPoint]
                         , [NSValue valueWithCGPoint:destinationPoint]];
    
    CAKeyframeAnimation *keyframe2 = [CAKeyframeAnimation animation];
    keyframe2.keyPath = @"transform";
    keyframe2.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 0.0)],
                         [NSValue valueWithCATransform3D:CATransform3DIdentity],
                         ];
    keyframe2.keyTimes = @[@(0.0), @(0.5), @(1)];
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[keyframe1, keyframe2];
    groupAnimation.duration = 0.35;
    groupAnimation.removedOnCompletion = false;
    groupAnimation.fillMode = kCAFillModeForwards;//保持动画结束后的状态
    
    return groupAnimation;
}

//更改真实位置
- (void)mix:(NSValue *)value {
    CGPoint curPoint = value.CGPointValue;
    _exposurePointer.layer.transform = CATransform3DIdentity;
    _focusPointer.layer.transform = CATransform3DIdentity;
    _exposurePointer.center = curPoint;
    _focusPointer.center = curPoint;
    //   blink
    [self blink];
}

///闪烁动画
- (void)blink {
    [_focusPointer.layer removeAnimationForKey:@"blink"];
    [_exposurePointer.layer removeAnimationForKey:@"blink"];
    CAKeyframeAnimation *keyframe4 = [CAKeyframeAnimation animation];
    keyframe4.keyPath = @"opacity";
    keyframe4.keyTimes = @[@(0.0), @(0.25), @(0.35), @(0.50), @(0.65), @(1)];
    keyframe4.values = @[@(1), @(0), @(1), @(0), @(1), @(0)];
    keyframe4.duration = 0.75;
    [_focusPointer.layer addAnimation:keyframe4 forKey:@"blink"];
    [_exposurePointer.layer addAnimation:keyframe4 forKey:@"blink"];
    
    //启动隐藏
    [self performSelector:@selector(hide) withObject:nil afterDelay:keyframe4.duration];
}

//闪烁完毕的隐藏动画
- (void)hide {
    [UIView animateWithDuration:0.25 animations:^{
        _focusPointer.alpha = 0;
        _exposurePointer.alpha = 0;
    }];
    NSLog(@"---%@", NSStringFromCGRect(_focusPointer.frame));
    NSLog(@"---%@", NSStringFromCGRect(_exposurePointer.frame));
}

///平移手势
- (void)pan:(UIPanGestureRecognizer *)pan {
    //取消上个动画的隐藏
    UIView *locatedView = [pan view];
    //    CGPoint curPoint = [pan locationInView:self];
    //    CGPoint translation = [pan translationInView:self];//获取平移手势的拖拽姿态
    if (locatedView == _focusPointer
        || locatedView == _exposurePointer) {
        [self moveFocusExposureWithPan:pan];
    }
}

///捏合手势
static float lastPinchScale = 0.0;
- (void)pinch:(UIPinchGestureRecognizer *)pinch {
    if (_zoomScale == 0) {_zoomScale = 1.0;}
    if (lastPinchScale - 0.000001 > 0) {
        if (lastPinchScale - pinch.scale > 0) {
            //在缩小
            _zoomScale -= 0.02;
        } else {
            //在增大
            _zoomScale += 0.02;
        }
        if (_zoomScale <= 1.0) {
            _zoomScale = 1.0;
        } else if (_zoomScale >= 4.0) {
            _zoomScale = 4.0;
        }
        //代理处缩放的比例
//        if ([self.delegate respondsToSelector:@selector(cameraGestureView:pinchScale:)]) {
//            [self.delegate cameraGestureView:self pinchScale:_zoomScale];
//        }
    }
    lastPinchScale = pinch.scale;
}

///移动焦点、曝光点
- (void)moveFocusExposureWithPan:(UIPanGestureRecognizer *)pan {
    UIView *locatedView = [pan view];
    CGPoint curPoint = [pan locationInView:self];
    CGPoint translation = [pan translationInView:self];//获取平移手势的拖拽姿态
    
    [_focusPointer.layer removeAnimationForKey:@"blink"];
    [_exposurePointer.layer removeAnimationForKey:@"blink"];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    
    if (curPoint.y < 0
        || curPoint.y > self.bounds.size.height) {
        //越界
    } else {
        //位移
        locatedView.center = CGPointMake(locatedView.center.x + translation.x, locatedView.center.y + translation.y);
        
        [pan setTranslation:CGPointZero inView:self];//重置平移手势的姿态
        if (pan.state == UIGestureRecognizerStateChanged) {
            //传出代理
            //传出曝光点或者是聚焦点的位置
            if (locatedView == _focusPointer) {
//                if ([_delegate respondsToSelector:@selector(cameraGestureView:focus:)]) {
//                    [_delegate cameraGestureView:self focus:locatedView.center];
//                }
            } else if (locatedView == _exposurePointer) {
//                if ([_delegate respondsToSelector:@selector(cameraGestureView:exposure:)]) {
//                    [_delegate cameraGestureView:self exposure:locatedView.center];
//                }
            }
        }
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) { [self blink]; }//做一个小动画
    
}

@end
