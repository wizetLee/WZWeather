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
#import "WZMediaTmpRecordList.h"
#import "WZMediaRecordTimeBar.h"

@interface WZMediaOperationView ()<WZMediaConfigViewProtocol, WZMediaEffectShowProtocol>

@property (nonatomic, strong) WZMediaConfigView *configView;//左手势
@property (nonatomic, strong) WZMediaEffectShow *effectView;//右手势
@property (nonatomic, strong) UIImageView *catalogueImageView;//切换相册或者是视频的目录

//---------------------------------------通用
///退出拍摄 录影
@property (nonatomic, strong) UIButton *closeBtn;
///切换拍摄 录影 按钮
@property (nonatomic, strong) UIButton *switchBtn;

@property (nonatomic, assign) WZMediaType type;
//---------------------------------------拍摄
///拍摄按钮
@property (nonatomic, strong) UIButton *shootBtn;
//---------------------------------------录制
///录影按钮（一个长按事件）
@property (nonatomic, strong) UIView *recordView;
///视频合成按钮入口
@property (nonatomic, strong) UIButton *compositionBtn;

@property (nonatomic, strong) WZMediaTmpRecordList *recordListView;//保留录制记录的view
@property (nonatomic, strong) WZMediaRecordTimeBar *recordTimeBar;

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
        if (MACRO_SYSTEM_IS_IPHONE_X) 
        {
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
    
    
    CGFloat w = (MACRO_FLOAT_SCREEN_WIDTH- 5*2) / 3.0 ;
    _shootBtn = [[UIButton alloc] init];
    _shootBtn.frame = CGRectMake(0.0, MACRO_FLOAT_SCREEN_HEIGHT - bottomH - 44.0, w, 44.0);
    _shootBtn.center = CGPointMake(MACRO_FLOAT_SCREEN_WIDTH / 2.0, _shootBtn.center.y);
    [_shootBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_shootBtn setTitle:@"拍照" forState:UIControlStateNormal];
    _shootBtn.backgroundColor = [UIColor yellowColor];
    [self addSubview:_shootBtn];
    [_shootBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];

    
    _recordView = [[UIView alloc] init];
    _recordView.frame = _shootBtn.frame;
    _recordView.backgroundColor = [UIColor redColor];
    _recordView.hidden = true;
    [self addSubview:_recordView];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress addTarget:self action:@selector(longPress:)];
    [_recordView addGestureRecognizer:longPress];
    
    
    _switchBtn = [[UIButton alloc] init];
    _switchBtn.frame = CGRectMake(0.0, MACRO_FLOAT_SCREEN_HEIGHT - 44, w, 44);
    _switchBtn.backgroundColor = [UIColor magentaColor];
    [_switchBtn setTitle:@"切换" forState:UIControlStateNormal];
    [_switchBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_switchBtn];
    
    _compositionBtn =
    _compositionBtn = [[UIButton alloc] init];
    _compositionBtn.frame = CGRectMake(MACRO_FLOAT_SCREEN_WIDTH - w, MACRO_FLOAT_SCREEN_HEIGHT - 44, w, 44);
    _compositionBtn.backgroundColor = [UIColor magentaColor];
    [_compositionBtn setTitle:@"合成" forState:UIControlStateNormal];
    [_compositionBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_compositionBtn];
    
#warning Why it need two edge gesture.....
    _edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePan:)];
    _edgePan.edges = UIRectEdgeLeft;
    _edgePanR = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePan:)];
    _edgePan.edges = UIRectEdgeLeft;
    _edgePanR.edges = UIRectEdgeRight;
    [self addGestureRecognizer:_edgePan];
    [self addGestureRecognizer:_edgePanR];
    
    
    _recordTimeBar = [[WZMediaRecordTimeBar alloc] initWithFrame:CGRectMake(0.0, 0.0, MACRO_FLOAT_SCREEN_WIDTH, 10.0)];
    [self addSubview:_recordTimeBar];
    
    [self addSubview:self.configView];
    
}

///
- (void)clickedBtn:(UIButton *)sender {
    if (sender == _closeBtn) {
        if ([_delegate respondsToSelector:@selector(operationView:closeBtnAction:)]) {
            [_delegate operationView:self closeBtnAction:sender];
        }
    } else if (sender == _shootBtn) {
        if ([_delegate respondsToSelector:@selector(operationView:shootBtnAction:)]) {
            [_delegate operationView:self shootBtnAction:sender];
        }
    } else if (sender == _switchBtn) {
        WZMediaType targetType = WZMediaTypeStillImage;
        
        if (_type == WZMediaTypeVideo) {
        } else {
            targetType = WZMediaTypeVideo;
        }
        
        if ([_delegate respondsToSelector:@selector(operationView:swithToMediaType:)]) {
            [_delegate operationView:self swithToMediaType:targetType];
        }
        [self switchModeWithType:targetType];
    } else if (sender == _compositionBtn) {
        //合成
        //这个功能不应该这里
        ///若干个视频
        
        ///
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

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.view == _recordView) {
        if (longPress.state == UIGestureRecognizerStateBegan) {
            _recordView.backgroundColor = [UIColor greenColor];
            //开始录制
            if ([_delegate respondsToSelector:@selector(operationView:startRecordGesture:)]) {
                [_delegate operationView:self startRecordGesture:longPress];
            }
        } else if (longPress.state == UIGestureRecognizerStateEnded
                   || longPress.state == UIGestureRecognizerStateCancelled
                   || longPress.state == UIGestureRecognizerStateFailed) {
            _recordView.backgroundColor = [UIColor redColor];
            //结束录制
            if (longPress.state == UIGestureRecognizerStateEnded) {
                //传结束代理
                if ([_delegate respondsToSelector:@selector(operationView:endRecordGesture:)]) {
                    [_delegate operationView:self endRecordGesture:longPress];
                }
            } else {
                //传终止代理
                if ([_delegate respondsToSelector:@selector(operationView:breakRecordGesture:)]) {
                    [_delegate operationView:self breakRecordGesture:longPress];
                }
            }
        }
    }
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

- (AVAudioPlayer *)timeMusicPlayer {
    if (!_timeMusicPlayer) {
        NSString *musicFilePath = [[NSBundle mainBundle] pathForResource:@"tickta" ofType:@"wav"];       //创建音乐文件路径,可以选其他格式
        NSURL *musicURL = [[NSURL alloc] initFileURLWithPath:musicFilePath];
        _timeMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    }
    return _timeMusicPlayer;
}

#pragma mark - Public

- (void)recordProgress:(CGFloat)progress {
    [_recordTimeBar setProgress:progress];
}

- (void)addRecordSign {
    [_recordTimeBar addSign];
}

- (void)switchModeWithType:(WZMediaType)type {
    _type = type;
    if (type == WZMediaTypeVideo) {
        //video
        _recordView.hidden = false;
        _shootBtn.hidden = true;
        
    } else {
        //still image
        _recordView.hidden = true;
        _shootBtn.hidden = false;
        
    }
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
