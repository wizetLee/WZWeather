//
//  WZMediaOperationView.m
//  WZWeather
//
//  Created by 李炜钊 on 2017/11/4.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaOperationView.h"
#import "WZMediaEffectShow.h"
#import "WZCameraAssist.h"
#import "WZMediaGestureView.h"

@interface WZMediaOperationView ()<WZMediaConfigViewProtocol, WZMediaEffectShowProtocol>

@property (nonatomic, strong) WZMediaConfigView *configView;//左手势
@property (nonatomic, strong) WZMediaEffectShow *effectView;//右手势
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *pickBtn;

///通过enable 判断是否在配置中`
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePan;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePanR;//右边

@property (nonatomic, strong) AVAudioPlayer *timeMusicPlayer;//倒计时
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
    
    [self addSubview:self.effectView];
    
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
    _edgePanR = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePan:)];
    _edgePan.edges = UIRectEdgeLeft;//有坑...
    _edgePanR.edges = UIRectEdgeRight;
    [self addGestureRecognizer:_edgePan];
    [self addGestureRecognizer:_edgePanR];
    
    
    [self addSubview:self.configView];
    
}

///
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

///边缘手势
- (void)screenEdgePan:(UIScreenEdgePanGestureRecognizer *)pan {
    if (pan.edges == UIRectEdgeLeft) {
        CGFloat restrictCritical = MACRO_FLOAT_SCREEN_WIDTH / 2.0;
        CGPoint curPoint = [pan locationInView:self];
        _configView.maxX  = curPoint.x;
        if (pan.state == UIGestureRecognizerStateEnded
                   || pan.state == UIGestureRecognizerStateCancelled
                   || pan.state == UIGestureRecognizerStateFailed) {
            [UIView animateWithDuration:0.25 animations:^{
                if (curPoint.x > restrictCritical) {
                    _configView.maxX = MACRO_FLOAT_SCREEN_WIDTH;
                    _edgePan.enabled = false;
                    _edgePanR.enabled = false;
                } else {
                    _configView.maxX = 0.0;
                }
            }];
        }
    } else if (pan.edges == UIRectEdgeRight) {
        CGFloat w = 80.0;
        CGPoint curPoint = [pan locationInView:self];
            CGFloat scale = ((curPoint.x - (MACRO_FLOAT_SCREEN_WIDTH - w)) / w);
            if (scale <= 0) {
                [_effectView showPercent:1];
            } else {
                [_effectView showPercent:1 - scale];
            }
       if (pan.state == UIGestureRecognizerStateEnded
                   || pan.state == UIGestureRecognizerStateCancelled
                   || pan.state == UIGestureRecognizerStateFailed) {
           [UIView animateWithDuration:0.25 animations:^{
               if (self.alpha > 0.5) {
                   [_effectView showPercent:1];
                   pan.enabled = false;
               } else {
                   [_effectView showPercent:0];
               }
           }];
        }
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    _edgePan.enabled = true;
    _edgePanR.enabled = true;
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

- (WZMediaEffectShow *)effectView {
    if (!_effectView) {
        _effectView = [[WZMediaEffectShow alloc] initWithFrame:self.bounds];
        _effectView.backgroundColor = [UIColor clearColor];
        _effectView.delegate = self;
    }
    return _effectView;
}

- (void)setSource:(GPUImageOutput *)source {
    self.effectView.inputSource = source;
}

- (AVAudioPlayer *)timeMusicPlayer {
    if (!_timeMusicPlayer) {
        NSString *musicFilePath = [[NSBundle mainBundle] pathForResource:@"tickta" ofType:@"wav"];       //创建音乐文件路径,可以选其他格式
        NSURL *musicURL = [[NSURL alloc] initFileURLWithPath:musicFilePath];
        _timeMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    }
    return _timeMusicPlayer;
}

#pragma mark - WZMediaConfigViewProtocol
- (void)mediaConfigView:(WZMediaConfigView *)view configType:(WZMediaConfigType)type {
    if ([_delegate respondsToSelector:@selector(operationView:configType:)]) {
        [_delegate operationView:self configType:type];
    }
}

#pragma mark - WZMediaEffectShowProtocol
- (void)mediaEffectShowDidShrinked {
    _edgePanR.enabled = true;
}
//选中了滤镜
- (void)mediaEffectShow:(WZMediaEffectShow *)view didSelectedFilter:(GPUImageFilter *)filter {
    if ([_delegate respondsToSelector:@selector(operationView:didSelectedFilter:)]) {
        [_delegate operationView:self didSelectedFilter:filter];
    }
}
@end
