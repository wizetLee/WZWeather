//
//  WZMediaOperationView.m
//  WZWeather
//
//  Created by 李炜钊 on 2017/11/4.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaOperationView.h"


@interface WZMediaOperationView ()<WZMediaConfigViewProtocol>

@property (nonatomic, strong) WZMediaConfigView *configView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *pickBtn;

///通过enable 判断是否在配置中
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePan;

@end

@implementation WZMediaOperationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)createViews {
    self.clipsToBounds = true;
    
    CGFloat topH = 0.0, bottomH = 0.0;
    if (@available(iOS 11.0, *)) {
        if (MACRO_SYSTEM_IS_IPHONE_X) {
            topH = 24.0;
            bottomH = 34.0;
        }
    }
    
    _closeBtn = [[UIButton alloc] init];
    _closeBtn.frame = CGRectMake(0.0, topH, 44.0 * 2, 44.0);
    [_closeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    _closeBtn.backgroundColor = [UIColor yellowColor];
    [self addSubview:_closeBtn];
    [_closeBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _pickBtn = [[UIButton alloc] init];
    _pickBtn.frame = CGRectMake(0.0, MACRO_FLOAT_SCREEN_HEIGHT - bottomH - 44.0, 44.0 * 2, 44.0);
    _pickBtn.center = CGPointMake(MACRO_FLOAT_SCREEN_WIDTH / 2.0, _pickBtn.center.y);
    [_pickBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_pickBtn setTitle:@"拍照" forState:UIControlStateNormal];
    _pickBtn.backgroundColor = [UIColor yellowColor];
    [self addSubview:_pickBtn];
    [_pickBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePan:)];
    _edgePan.edges = UIRectEdgeLeft;
    [self addGestureRecognizer:_edgePan];
    
    
    [self addSubview:self.configView];
   
}

- (void)clickedBtn:(UIButton *)sender {
    if (sender == _closeBtn) {
        if ([_delegate respondsToSelector:@selector(operationView:closeBtnAction:)]) {
            [_delegate operationView:self closeBtnAction:sender];
        }
    } else if (sender == _pickBtn) {
        if ([_delegate respondsToSelector:@selector(operationView:pickBtnAction:)]) {
            [_delegate operationView:self pickBtnAction:sender];
        }
    }
}


- (void)screenEdgePan:(UIScreenEdgePanGestureRecognizer *)pan {
  
    CGFloat restrictCritical = MACRO_FLOAT_SCREEN_WIDTH / 2.0;
    CGPoint curPoint = [pan locationInView:self];
    _configView.maxX  = curPoint.x;
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        
    } else if (pan.state == UIGestureRecognizerStateEnded
               || pan.state == UIGestureRecognizerStateCancelled
               || pan.state == UIGestureRecognizerStateFailed) {
        [UIView animateWithDuration:0.25 animations:^{
            if (curPoint.x > restrictCritical) {
                _configView.maxX = MACRO_FLOAT_SCREEN_WIDTH;
   
                _edgePan.enabled = false;
            } else {
                _configView.maxX = 0.0;
            }
        }];
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    _edgePan.enabled = true;
    [UIView animateWithDuration:0.25 animations:^{
        _configView.maxX = 0.0;
    }];
}

#pragma mark - Accessor
-(WZMediaConfigView *)configView {
    if (!_configView) {
        _configView = [[WZMediaConfigView alloc] initWithFrame:self.bounds];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [_configView addGestureRecognizer:tap];
        _configView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.25];
        _configView.maxX = 0;
        _configView.delegate = self;
        
    }
    return _configView;
}

#pragma mark - WZMediaConfigViewProtocol
- (void)mediaConfigView:(WZMediaConfigView *)view configType:(WZMediaConfigType)type {
    if ([_delegate respondsToSelector:@selector(operationView:configType:)]) {
        [_delegate operationView:self configType:type];
    }
}
@end
