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
#import "WZMediaTmpRecordList.h"
#import "WZMediaRecordTimeBar.h"
#import "WZMediaRateTypeView.h"

@interface WZMediaOperationView ()<WZMediaConfigViewProtocol, WZMediaEffectShowProtocol, WZMediaRateTypeViewProtocol>

@property (nonatomic, strong) WZMediaConfigView *configView;            //左手势
@property (nonatomic, strong) WZMediaEffectShow *effectView;            //右手势
@property (nonatomic, strong) UIImageView *catalogueImageView;          //切换相册或者是视频的目录
@property (nonatomic, strong) WZMediaGestureView *gestureView;          //手势层
@property (nonatomic, strong) WZMediaRateTypeView *videoRateTypeView;   //控制录制速率（考虑配置播放速率）
//---------------------------------------通用
///退出拍摄 录影
@property (nonatomic, strong) UIButton *closeBtn;
///切换拍摄 录影 按钮
@property (nonatomic, strong) UIButton *switchBtn;

@property (nonatomic, assign) WZMediaType type;
//---------------------------------------拍摄
///拍摄按钮
@property (nonatomic, strong) UIButton *shootBtn;
@property (nonatomic, strong) UIButton *recordBtn;
//---------------------------------------录制  长按拍摄  单击拍摄
///录影按钮（一个长按事件）
@property (nonatomic, strong) UIView *recordView;//长按拍摄
@property (nonatomic, strong) UIView *recordImageView;//长按拍摄
@property (nonatomic, strong) UILabel *recordTimeLabel;

@property (nonatomic, strong) UIButton *recordView_singleClick;//单击拍摄
///视频合成按钮入口
@property (nonatomic, strong) UIButton *settingBtn;
@property (nonatomic, strong) UIButton *filterBtn;

@property (nonatomic, strong) WZMediaTmpRecordList *recordListView;//保留录制记录的view
//@property (nonatomic, strong) WZMediaRecordTimeBar *recordTimeBar;

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
#pragma mark - Private
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
    
    _gestureView = [[WZMediaGestureView alloc] initWithFrame:self.bounds];
    [self addSubview:_gestureView];
    [self addSubview:self.effectView];
    
    _closeBtn = [[UIButton alloc] init];
    _closeBtn.frame = CGRectMake(0.0, topH, 44.0 * 2, 44.0);
    [_closeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    _closeBtn.backgroundColor = [UIColor yellowColor];
    [self addSubview:_closeBtn];
    [_closeBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _recordTimeLabel = [[UILabel alloc] init];
    _recordTimeLabel.frame = CGRectMake(MACRO_FLOAT_SCREEN_WIDTH - 88.0, topH, 88.0, 44.0);
    _recordTimeLabel.textColor = UIColor.whiteColor;
    [self addSubview:_recordTimeLabel];
    _recordTimeLabel.hidden = true;
    
    CGFloat w = (MACRO_FLOAT_SCREEN_WIDTH- 5*2) / 3.0 ;
    _shootBtn = [[UIButton alloc] init];
    _shootBtn.frame = CGRectMake(0.0, MACRO_FLOAT_SCREEN_HEIGHT - bottomH - 80.0, 80.0, 80.0);
    _shootBtn.center = CGPointMake(MACRO_FLOAT_SCREEN_WIDTH / 2.0, _shootBtn.center.y);
    [_shootBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_shootBtn setBackgroundImage:[UIImage imageNamed:@"2_1#ffffff"] forState:UIControlStateNormal];
    
    [self addSubview:_shootBtn];
    [_shootBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];

//    _recordBtn = [[UIButton alloc] init];
//    _recordBtn.frame = CGRectMake(0.0, MACRO_FLOAT_SCREEN_HEIGHT - bottomH - 80.0, 80.0, 80.0);
//    _recordBtn.center = CGPointMake(MACRO_FLOAT_SCREEN_WIDTH / 2.0, _shootBtn.center.y);
//    [_recordBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"8_1#e67976"] forState:UIControlStateNormal];
    
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
    [_switchBtn setTitle:@"换录像" forState:UIControlStateNormal];
    [_switchBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_switchBtn];
    
    _settingBtn = [[UIButton alloc] init];
    _settingBtn.frame = CGRectMake(MACRO_FLOAT_SCREEN_WIDTH - w, MACRO_FLOAT_SCREEN_HEIGHT - 44, w, 44);
    _settingBtn.backgroundColor = [UIColor magentaColor];
    [_settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [_settingBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_settingBtn];
    
    _filterBtn = [[UIButton alloc] init];
    _filterBtn.frame = CGRectMake(MACRO_FLOAT_SCREEN_WIDTH - w, MACRO_FLOAT_SCREEN_HEIGHT - 44 * 2.0, w, 44);
    _filterBtn.backgroundColor = [UIColor magentaColor];
    [_filterBtn setTitle:@"滤镜" forState:UIControlStateNormal];
    [_filterBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_filterBtn];
    
    {//速率
//        _videoRateTypeView = [[WZMediaRateTypeView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0 * 5, 44.0)];
//        _videoRateTypeView.layer.backgroundColor = [UIColor yellowColor].CGColor;
//        _videoRateTypeView.layer.cornerRadius = 22.0;
//        [self addSubview:_videoRateTypeView];
//        _videoRateTypeView.center = self.center;
//        _videoRateTypeView.delegate = self;
    }
    
//    _recordTimeBar = [[WZMediaRecordTimeBar alloc] initWithFrame:CGRectMake(0.0, 0.0, MACRO_FLOAT_SCREEN_WIDTH, 10.0)];
//    [self addSubview:_recordTimeBar];
    
    [self addSubview:self.configView];//最顶层
}

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
    } else if (sender == _settingBtn) {
        //跳出设置列表
        [UIView animateWithDuration:0.25 animations:^{
            _configView.maxX = MACRO_FLOAT_SCREEN_WIDTH;
            _gestureView.edgePan.enabled = false;
            _gestureView.edgePanR.enabled = false;
        }];
    } else if (sender == _filterBtn) {
        [UIView animateWithDuration:0.25 animations:^{
            [_effectView showPercent:1];
        }];
    }
}

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
                    _gestureView.edgePan.enabled = false;
                    _gestureView.edgePanR.enabled = false;
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
- (void)setGestureDelegate:(id<WZMediaGestureViewProtocol>)gestureDelegate {
    _gestureDelegate = gestureDelegate;
    _gestureView.delegate = gestureDelegate;
    
}

-(WZMediaConfigView *)configView {
    if (!_configView) {
        _configView = [[WZMediaConfigView alloc] initWithFrame:self.bounds];
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
        NSString *musicFilePath = [[NSBundle mainBundle] pathForResource:@"tickta" ofType:@"wav"];//创建音乐文件路径,可以选其他格式
        NSURL *musicURL = [[NSURL alloc] initFileURLWithPath:musicFilePath];
        _timeMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    }
    return _timeMusicPlayer;
}

#pragma mark - Public
//MARK:录制的进度
- (void)recordProgress:(CGFloat)progress {
//    [_recordTimeBar setProgress:progress];
    [_recordTimeLabel setText:[NSString stringWithFormat:@"%f", progress]];
}
//MARK:添加一个录制断点
- (void)addRecordSign {
//    [_recordTimeBar addSign];
}

//MARK:录像 摄影之间的切换
- (void)switchModeWithType:(WZMediaType)type {
    _type = type;
    if (type == WZMediaTypeVideo) {
        //video
        _recordTimeLabel.hidden = _recordTimeLabel.hidden = _recordView.hidden = false;
        _recordTimeLabel.text = nil;
        _shootBtn.hidden = true;
        [_switchBtn setTitle:@"换拍照" forState:UIControlStateNormal];
        
    } else {
        //still image
        _recordTimeLabel.hidden = _recordTimeLabel.hidden = _recordView.hidden = true;
        _shootBtn.hidden = false;
        [_switchBtn setTitle:@"换录像" forState:UIControlStateNormal];
    }
}
#pragma mark - WZMediaRateTypeViewProtocl
- (void)mediaRateTypeView:(WZMediaRateTypeView *)view didScrollToIndex:(NSUInteger)index; {
    if ([_delegate respondsToSelector:@selector(operationView:didScrollToIndex:)]) {
        [_delegate operationView:self didScrollToIndex:index];
    }
}

#pragma mark - WZMediaConfigViewProtocol
- (void)mediaConfigView:(WZMediaConfigView *)view configType:(WZMediaConfigType)type {
    if ([_delegate respondsToSelector:@selector(operationView:configType:)]) {
        [_delegate operationView:self configType:type];
    }
}

- (void)mediaConfigView:(WZMediaConfigView *)view tap:(UITapGestureRecognizer *)tap {
//    _edgePan.enabled = true;
//    _edgePanR.enabled = true;
    _gestureView.edgePan.enabled = true;
    _gestureView.edgePanR.enabled = true;
    [UIView animateWithDuration:0.25 animations:^{
        _configView.maxX = 0.0;
    }];
}

#pragma mark - WZMediaEffectShowProtocol
- (void)mediaEffectShowDidShrinked {
//    _edgePanR.enabled = true;
    _gestureView.edgePanR.enabled = true;
}
//选中了滤镜
- (void)mediaEffectShow:(WZMediaEffectShow *)view didSelectedFilter:(GPUImageFilter *)filter {
    if ([_delegate respondsToSelector:@selector(operationView:didSelectedFilter:)]) {
        [_delegate operationView:self didSelectedFilter:filter];
    }
}
@end
