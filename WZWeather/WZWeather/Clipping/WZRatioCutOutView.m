//
//  WZRatioCutOutView.m
//  WZTestDemo
//
//  Created by wizet on 22/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "WZRatioCutOutView.h"

@interface WZRatioCutOutView()

@property (nonatomic, strong) UIView *leadView;
@property (nonatomic, strong) UIView *trailView;

@property (nonatomic, strong) CALayer *internalLayer;
@property (nonatomic, strong) CALayer *surfaceLayer;

@property (nonatomic, strong) CALayer *leadMaskView;
@property (nonatomic, strong) CALayer *trailMaskView;

@property (nonatomic, strong) UIImageView *leadViewImage;
@property (nonatomic, strong) UIImageView *trailViewImage;

@property (nonatomic, assign) BOOL  moveable;

@end

@implementation WZRatioCutOutView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

+ (CGFloat)handleW  {
    return 44.0;
}

- (void)updateView {
    CGFloat handleWH = 44.0;
    _leadView.frame = CGRectMake(0.0, 0.0, handleWH, self.frame.size.height);
    _trailView.frame = CGRectMake(self.frame.size.width - handleWH, 0.0, handleWH, self.frame.size.height);
    _leadMaskView.frame = CGRectMake(0.0, _leadView.frame.origin.y, 0.0, _leadView.frame.size.height);
    _trailMaskView.frame = CGRectMake(CGRectGetWidth(self.frame), _trailView.frame.origin.y, 0.0, _trailView.frame.size.height);
}

- (void)createViews {
    _moveable = true;
    _minimumRestrictRatio = 0.1;//百分之10
    CGFloat handleWH = 44.0;
    _leadView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, handleWH, self.frame.size.height)];
    _trailView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - handleWH, 0.0, handleWH, self.frame.size.height)];
   
    _leadViewImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, handleWH / 2.0, CGRectGetHeight(_leadView.frame))];
    _trailViewImage = [[UIImageView alloc] initWithFrame:CGRectMake(handleWH / 2.0, 0.0, handleWH / 2.0, CGRectGetHeight(_leadView.frame))];
    [_leadView addSubview:_leadViewImage];
    [_trailView addSubview:_trailViewImage];
    _leadViewImage.backgroundColor = [UIColor redColor];
    _trailViewImage.backgroundColor = [UIColor greenColor];
    
    _internalLayer = [CALayer layer];
    _internalLayer.frame = CGRectMake(handleWH / 2.0, 0.0, self.frame.size.width - handleWH, self.frame.size.height);
    _surfaceLayer = [CALayer layer];
    _internalLayer.frame = _internalLayer.frame;
    [self.layer addSublayer:_internalLayer];
    [self.layer addSublayer:_surfaceLayer];
    
    _leadMaskView = [CALayer layer];
    _leadMaskView.frame = CGRectMake(0.0, _leadView.frame.origin.y, 0.0, _leadView.frame.size.height);
    
//    [[UIView alloc] initWithFrame:CGRectMake(0.0, _leadView.frame.origin.y, 0.0, _leadView.frame.size.height)];
    _trailMaskView = [CALayer layer];
//    [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame), _trailView.frame.origin.y, 0.0, _trailView.frame.size.height)];
    _trailMaskView.frame = CGRectMake(CGRectGetWidth(self.frame), _trailView.frame.origin.y, 0.0, _trailView.frame.size.height);
    _leadMaskView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5].CGColor;
    _trailMaskView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5].CGColor;
    [self.layer addSublayer:_leadMaskView];
    [self.layer addSublayer:_trailMaskView];
//    [self addSubview:_leadMaskView];
//    [self addSubview:_trailMaskView];
    [self addSubview:_leadView];
    [self addSubview:_trailView];
    
    _trailView.backgroundColor = [UIColor clearColor];
    _leadView.backgroundColor = [UIColor clearColor];
//    _surfaceLayer.backgroundColor = [UIColor blueColor].CGColor;
//    _internalLayer.backgroundColor = [UIColor yellowColor].CGColor;
    
    UIPanGestureRecognizer *panLeading = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    UIPanGestureRecognizer *panTrading = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_leadView addGestureRecognizer:panLeading];
    [_trailView addGestureRecognizer:panTrading];
    
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress:)];
//    [self addGestureRecognizer:longPress];
}
#pragma mark - Public Method



#pragma mark - Private Method
- (void)pan:(UIPanGestureRecognizer *)pan {
    if (!_moveable) {return;}
    CGPoint currentPoint = [pan translationInView:self];
//    pan.view.transform = CGAffineTransformTranslate(pan.view.transform, currentPoint.x, currentPoint.y);只改变layer
    
//    NSLog(@"center :%@", NSStringFromCGPoint(pan.view.center));
    CGFloat targetX = currentPoint.x + pan.view.center.x;
    CGFloat viewW = pan.view.bounds.size.width;
    
    [CATransaction begin];
    [CATransaction setDisableActions:true];
    if (pan.view == _leadView) {
        if (targetX < CGRectGetWidth(pan.view.frame) / 2.0) {
            targetX = CGRectGetWidth(pan.view.frame) / 2.0;
        }
        if (_trailView.center.x - targetX <= (CGRectGetWidth(self.frame) - viewW) *_minimumRestrictRatio) {
            targetX = _trailView.center.x - (CGRectGetWidth(self.frame) - viewW) *_minimumRestrictRatio;
        }
        _leadMaskView.frame = CGRectMake(_leadMaskView.frame.origin.x, _leadMaskView.frame.origin.y, targetX, _leadMaskView.frame.size.height);
        
    } else if (pan.view == _trailView) {
        if (targetX > (CGRectGetWidth(self.frame)) -  CGRectGetWidth(pan.view.frame) / 2.0) {
            targetX = (CGRectGetWidth(self.frame)) -  CGRectGetWidth(pan.view.frame) / 2.0;
        }
        if (targetX - _leadView.center.x <= (CGRectGetWidth(self.frame) - viewW) *_minimumRestrictRatio) {
            targetX = _leadView.center.x + (CGRectGetWidth(self.frame) - viewW) *_minimumRestrictRatio;
        }
        _trailMaskView.frame = CGRectMake(targetX, _trailMaskView.frame.origin.y, (CGRectGetWidth(self.frame) - targetX), _trailMaskView.frame.size.height);
    }
    [CATransaction commit];
    
    pan.view.center = CGPointMake(targetX, pan.view.center.y);
    [pan setTranslation:CGPointZero inView:self];
//    if (pan.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"%f__%f", self.leadView.center.x, self.trailView.center.x);
        if ([_delegate respondsToSelector:@selector(ratioCutOutView:leadingRatio:trailingRatio:leadingDrive:)]) {
            [_delegate ratioCutOutView:self leadingRatio:(_leadView.center.x - viewW / 2.0) / (CGRectGetWidth(self.frame) - viewW) trailingRatio:(_trailView.center.x - viewW / 2.0) / (CGRectGetWidth(self.frame) - viewW) leadingDrive:(pan.view == _leadView)];
        }
    
//    NSLog(@"%f__%f", (_leadView.center.x - viewW / 2.0) / (CGRectGetWidth(self.frame) - viewW)
//          , (_trailView.center.x - viewW / 2.0) / (CGRectGetWidth(self.frame) - viewW));
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(ratioCutOutViewBeginClipping)]) {
            [_delegate ratioCutOutViewBeginClipping];
        }
    }
    
	if (pan.state == UIGestureRecognizerStateEnded) {
        if ([_delegate respondsToSelector:@selector(ratioCutOutViewFinishClipping)]) {
            [_delegate ratioCutOutViewFinishClipping];
        }
	}
}

//- (void)longpress:(UILongPressGestureRecognizer *)longPress {
//    CGFloat viewW = _trailView.bounds.size.width;
//    if ((_leadView.center.x - viewW / 2.0) / (CGRectGetWidth(self.frame) - viewW) < 0.000001
//        && (_trailView.center.x - viewW / 2.0) / (CGRectGetWidth(self.frame) - viewW) > 0.999999) {
//        return;
//    }
//    //trailing heading 一起滑动
//}

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    } else {
        return hitView;
    }
}

#pragma mark - Accessor
- (void)setMinimumRestrictRatio:(CGFloat)minimumRestrictRatio {
    if (minimumRestrictRatio > 1.0) {
        _minimumRestrictRatio = 1.0;
    } else if (minimumRestrictRatio < 0.0 ) {
        _minimumRestrictRatio = 0.0;
    } else {
        _minimumRestrictRatio = minimumRestrictRatio;
    }
}

- (void)moveable:(BOOL)boolean {
    _moveable = boolean;
}

//居中处理
- (void)constantRatio:(CGFloat)ratio {
    [self moveable:false];
    if (ratio > 1.0) {
        ratio = 1.0;
    } else if (ratio < 0) {
        ratio = 0;
    }
        ///平分数据位置
    [CATransaction begin];
    [CATransaction setDisableActions:true];
    CGFloat targetX = 0.0;
    CGFloat viewW = _leadView.bounds.size.width;
    CGFloat scaleW = CGRectGetWidth(self.frame) - viewW;
    targetX = (1 - ratio) * scaleW / 2.0;
    targetX  = targetX + viewW / 2.0;
    _leadView.center = CGPointMake(targetX, _leadView.center.y);
    _leadMaskView.frame = CGRectMake(_leadMaskView.frame.origin.x, _leadMaskView.frame.origin.y, targetX, _leadMaskView.frame.size.height);
    
    targetX = (1 - ratio) * scaleW / 2.0;
    targetX  = CGRectGetWidth(self.bounds) - targetX - viewW / 2.0;
    _trailView.center = CGPointMake(targetX, _trailView.center.y);
    _trailMaskView.frame = CGRectMake(targetX, _trailMaskView.frame.origin.y, (CGRectGetWidth(self.frame) - targetX), _trailMaskView.frame.size.height);
        
//        NSLog(@"%f__%f", (_leadView.center.x - viewW / 2.0) / (CGRectGetWidth(self.frame) - viewW)
//              , (_trailView.center.x - viewW / 2.0) / (CGRectGetWidth(self.frame) - viewW));
    [CATransaction commit];
}



@end


