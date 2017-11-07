//
//  WZBaseAlert.h
//  WZAlert
//
//  Created by Wizet on 21/9/17.
//  Copyright © 2017年 Wizet. All rights reserved.
//

#import "WZGleaminglyAlert.h"

@interface WZGleaminglyAlert()

@property (nonatomic, strong) UIView *bgView;                       //背景颜色层

@end

@implementation WZGleaminglyAlert

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createViews];
    }
    return self;
}

#pragma mark - Public Method
- (void)clickBackgroundToDismiss:(BOOL)boolean {
    for (UIGestureRecognizer *gesture in _bgView.gestureRecognizers) {
        [_bgView removeGestureRecognizer:gesture];
    }
    if (boolean) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [_bgView addGestureRecognizer:tap];
    }
}

- (void)show {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)alertDismissWithAnimated:(BOOL)animated {
    [UIView animateWithDuration:animated?0.25:0.0 animations:^{
        self.alpha = 0.0;
    }];
}

- (void)createViews {
    self.alpha = 0.0;
    self.frame = CGRectZero;
    _bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];;
    _bgView.backgroundColor = [self curtainColor];
    [self addSubview:_bgView];
}

#pragma mark - Private Method
- (void)tap:(UITapGestureRecognizer *)tap {
	[self alertDismissWithAnimated:true];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:[UIScreen mainScreen].bounds];
}

///背景颜色
- (UIColor *)curtainColor {
    return [[UIColor blackColor] colorWithAlphaComponent:0.5];
}

@end
