//
//  WZSlider.m
//  WZWeather
//
//  Created by admin on 5/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZSilder.h"

@interface WZSilder()

@property (nonatomic, strong) UIImageView *thumbView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@end

@implementation WZSilder

//MARK: 滑动视图宽度
- (CGFloat)thumbWidth {
    return 15.0;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    [self addSubview:self.thumbView];
    _thumbView.frame = CGRectMake(0.0, 0.0, _thumbView.frame.size.width, _thumbView.frame.size.height);
    _thumbView.backgroundColor = UIColor.orangeColor;
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:_tap];
    
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:_pan];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self];
    CGFloat x = _thumbView.center.x + translation.x;
    CGFloat restrictW = [self thumbWidth] / 2.0;//控制操控杆所在范围
    if (x <= restrictW) {
        x = restrictW;
    }
    if (x >= self.frame.size.width - restrictW) {
        x = self.frame.size.width - restrictW;
    }
    _thumbView.center = CGPointMake(x, _thumbView.center.y);
    [pan setTranslation:CGPointZero inView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(silderPanGestureStateBegan)]) {
            [_delegate silderPanGestureStateBegan];
        }
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if ([_delegate respondsToSelector:@selector(silderPanGestureStateChangedWithProgress:)]) {
            [_delegate silderPanGestureStateChangedWithProgress:[self progress]];
        }
         NSLog(@"%lf", [self progress]);
    } else if (pan.state == UIGestureRecognizerStateEnded
        || pan.state == UIGestureRecognizerStateCancelled
        || pan.state == UIGestureRecognizerStateFailed) {
        if ([_delegate respondsToSelector:@selector(silderPanGestureStateEnd)]) {
            [_delegate silderPanGestureStateEnd];
        }
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint locationPoint = [tap locationInView:self];
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGFloat x = locationPoint.x;
        CGFloat restrictW = [self thumbWidth] / 2.0;
        if (x <= restrictW) {
            x = restrictW;
        }
        if (x >= self.frame.size.width - restrictW) {
            x = self.frame.size.width - restrictW;
        }
        _thumbView.center = CGPointMake(x, _thumbView.center.y);
        if ([_delegate respondsToSelector:@selector(silderPanGestureStateChangedWithProgress:)]) {
            [_delegate silderPanGestureStateChangedWithProgress:[self progress]];
           
        }
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
//    重设
    
}

#pragma mark - Public

- (void)setProgress:(CGFloat)progress {
    CGFloat x = ([self thumbWidth] / 2.0) + (self.frame.size.width - [self thumbWidth]) * progress;
    _thumbView.center = CGPointMake(x, _thumbView.center.y);
}

- (CGFloat)progress {
    CGFloat x = _thumbView.center.x;
    return (x - [self thumbWidth] / 2.0) / (self.frame.size.width - [self thumbWidth]);
}

//MARK: - Accessor
- (UIImageView *)thumbView {
    if (!_thumbView) {
        _thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, [self thumbWidth], self.frame.size.height)];
        _thumbView.userInteractionEnabled = true;
    }
    return _thumbView;
}


@end
