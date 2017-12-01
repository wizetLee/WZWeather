//
//  WZMeidaRateTypeView.m
//  WZWeather
//
//  Created by wizet on 30/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaRateTypeView.h"

#define WZMeidaRateTypeViewCellWH 44.0

@interface WZMediaRateTypeView()

@property (nonatomic, strong) UILabel *errandView;//跑腿的view
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, assign) NSUInteger currentIndex;

@end

@implementation WZMediaRateTypeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    CGFloat WH = WZMeidaRateTypeViewCellWH;
    NSUInteger count = 5;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,  WH * count, WH);
    
    
    for (NSUInteger i = 0; i < count; i++) {
        CGFloat wh = 10.0;
        UIView *decorateView = [[UIView alloc] initWithFrame:CGRectMake(WH / 2 - wh / 2.0 + i * WH, WH / 2 - wh / 2, wh, wh)];
        decorateView.layer.cornerRadius = wh / 2.0;
        decorateView.layer.backgroundColor = [UIColor redColor].CGColor;
        [self addSubview:decorateView];
    }
    
    _errandView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, WH, WH)];
    _errandView.userInteractionEnabled = true;
    _errandView.layer.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5].CGColor;
    _errandView.layer.cornerRadius = WH / 2.0;
    _errandView.textAlignment = NSTextAlignmentCenter;

    [self addSubview:_errandView];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:_tap];
    
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_errandView addGestureRecognizer:_pan];
    
    _currentIndex = 2;
    [self pickNameWithIndex:_currentIndex];
    _errandView.center = CGPointMake(_currentIndex * WZMeidaRateTypeViewCellWH + WZMeidaRateTypeViewCellWH / 2.0, WZMeidaRateTypeViewCellWH / 2.0);
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self];
    CGFloat x = pan.view.center.x + translation.x;
    CGFloat restrictW = WZMeidaRateTypeViewCellWH / 2.0;
    if (x <= restrictW) {
        x = restrictW;
    }
    if (x >= self.frame.size.width - restrictW) {
        x = self.frame.size.width - restrictW;
    }
    pan.view.center = CGPointMake(x, restrictW);
    [pan setTranslation:CGPointZero inView:self];
    
    //取整得到角标
    int index = (int)(pan.view.center.x / WZMeidaRateTypeViewCellWH);
    [self pickNameWithIndex:index];
    if (pan.state == UIGestureRecognizerStateEnded
        || pan.state == UIGestureRecognizerStateCancelled
        || pan.state == UIGestureRecognizerStateFailed) {
        //根据index调整位置
        [UIView animateWithDuration:0.25 animations:^{
            pan.view.center = CGPointMake(index * WZMeidaRateTypeViewCellWH + restrictW, restrictW);
        }];
        
        if (index == _currentIndex) {
            
        } else {
            _currentIndex = index;
            [self pickNameWithIndex:index];
            if ([_delegate respondsToSelector:@selector(mediaRateTypeView:didScrollToIndex:)]) {
                [_delegate mediaRateTypeView:self didScrollToIndex:_currentIndex];
                 NSLog(@"index %d", index);
            }
        }
    }
   
}

- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint locationPoint = [tap locationInView:self];
    CGFloat restrictW = WZMeidaRateTypeViewCellWH / 2.0;
    CGFloat x = locationPoint.x;
    if (x <= restrictW) {
        x = restrictW;
    }
    if (x >= self.frame.size.width - restrictW) {
        x = self.frame.size.width - restrictW;
    }
    //取整得到角标
    int index = (int)(x / WZMeidaRateTypeViewCellWH);
    _currentIndex = index;
    [self pickNameWithIndex:index];
    
    //回调
    if ([_delegate respondsToSelector:@selector(mediaRateTypeView:didScrollToIndex:)]) {
        [_delegate mediaRateTypeView:self didScrollToIndex:_currentIndex];
         NSLog(@"index %d", index);
    }
    
    //调整位置
    [UIView animateWithDuration:0.25 animations:^{
        _errandView.center = CGPointMake(index * WZMeidaRateTypeViewCellWH + restrictW, restrictW);
    }];
   
   
}

- (void)pickNameWithIndex:(NSUInteger)index {
    NSArray <NSString *> *nameArr = @[@"0.25x", @"0.5x", @"1x", @"2x", @"4x"];
    if (nameArr.count > index) {
        _errandView.text = nameArr[index];
    } else {
        _errandView.text = @"";
    }
}

@end
