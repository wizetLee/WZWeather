//
//  WZVideoSurfAlert.m
//  WZWeather
//
//  Created by admin on 5/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVideoSurfAlert.h"
#import "WZVideoSurfSlider.h"

@interface WZVideoSurfAlert()<WZSliderProtocol>


@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *previewLayer;

@property (nonatomic, strong) WZVideoSurfSlider *wz_slider;
@property (nonatomic, strong) UIView *layerContainerView;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) id timeObserver;//监听播放速度的监听者 记得要移除
@property (nonatomic, assign) BOOL isPlaying;//是否正在播放

@end

@implementation WZVideoSurfAlert

//MARK: 布局
- (void)alertContent {
    [super alertContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionWasInterruptedNotification:) name:AVCaptureSessionWasInterruptedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionInterruptionEndedNotification:) name:AVCaptureSessionInterruptionEndedNotification object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    if (_playerItem && CMTimeCompare(_playerItem.duration, kCMTimeZero) > 0 ) {
        [_previewLayer removeFromSuperlayer];
        _previewLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
//        NSLog(@"资源尺寸 ： %@", NSStringFromCGSize(_playerItem.asset.naturalSize));
//        CGSize size = [NSObject wz_fitSizeComparisonWithScreenBound:_playerItem.asset.naturalSize];
        _layerContainerView = [[UIView alloc] initWithFrame:self.bounds];
        _layerContainerView.backgroundColor = [UIColor clearColor];
        _previewLayer.frame = _layerContainerView.bounds;
        [self addSubview:_layerContainerView];
        [_layerContainerView.layer addSublayer:_previewLayer];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [_layerContainerView addGestureRecognizer:tap];
       
        _wz_slider = [[WZVideoSurfSlider alloc] initWithFrame:CGRectMake(20.0, MACRO_FLOAT_SCREEN_HEIGHT - MACRO_FLOAT_SAFEAREA_BOTTOM - 44.0 - 20.0 - 44 - 20, MACRO_FLOAT_SCREEN_WIDTH - 40.0, 44.0)];
        _wz_slider.backgroundColor = UIColor.greenColor;
        _wz_slider.delegate = self;
        [self addSubview:_wz_slider];
        
        UILabel *leftLabel =  [[UILabel alloc] initWithFrame:CGRectMake(0.0, -22.0, 88.0, 22.0)];
        UILabel *rightLabel =[[UILabel alloc] initWithFrame:CGRectMake(_wz_slider.frame.size.width - 88.0, -22.0, 88.0, 22.0)];
        leftLabel.font = [UIFont boldSystemFontOfSize:12.0];
        leftLabel.backgroundColor = [UIColor clearColor];
        leftLabel.textColor = [UIColor whiteColor];
        [_wz_slider addSubview:leftLabel];
        rightLabel.font = [UIFont boldSystemFontOfSize:12.0];
        rightLabel.backgroundColor = [UIColor clearColor];
        rightLabel.textColor = [UIColor whiteColor];
        [_wz_slider addSubview:rightLabel];
        rightLabel.textAlignment = NSTextAlignmentRight;
        leftLabel.text = @"0.0sec";
        rightLabel.text = [NSString stringWithFormat:@"%.2lfsec", CMTimeGetSeconds(_asset.duration)];
        
//        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, [[UIApplication sharedApplication] statusBarFrame].size.height, 88.0, 44.0)];
//        _closeButton.backgroundColor = [UIColor redColor];
//        [_closeButton setTitle:@"退出" forState:UIControlStateNormal];
//        [_closeButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_closeButton];
    } else {
        return;
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        [self alertDismissWithAnimated:true];
    }
}

- (void)clickedBtn:(UIButton *)sender {
    [self alertDismissWithAnimated:true];
}

//MARK: rewrite 重写父类逻辑
- (void)alertShow {
    if (!_asset) {
        NSAssert(false, @"资源缺失");
        return;
    }
    [super alertShow];
}

- (void)alertDismissWithAnimated:(BOOL)animated; {
    [self playerRemoveTimeObserver];
    [_previewLayer removeFromSuperlayer];
    _previewLayer = nil;
    [_player pause];
    _player = nil;
    [super alertDismissWithAnimated:animated];
}

- (void)beginningAnimationComletion {
    [_player play];
    __weak typeof(self) weakSelf = self;
    [self playerTimeObserverWithTimeHandler:^(CMTime time) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.wz_slider setProgress:CMTimeGetSeconds(time) / CMTimeGetSeconds(weakSelf.asset.duration)];
        });
    }];
}

- (CGFloat)bgViewAlpha {
    return 1;
}
- (CGFloat)beginAnimationTime {
    return 0.25;
}

- (void)dealloc {
    [_player pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __func__);
}

//MARK: Accessor
- (void)setAsset:(AVAsset *)asset {
    if (asset == _asset) {
        return;
    }
    
    _asset = asset;
    _playerItem = [[AVPlayerItem alloc] initWithAsset:_asset];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    //处理视图
}

//MARK: - WZSliderProtocol
- (void)sliderPanGestureStateBegan; {
    [_player pause];
}

- (void)sliderPanGestureStateChangedWithProgress:(CGFloat)progress; {
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(_asset.duration) * progress, _asset.duration.timescale);
    [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)sliderPanGestureStateEnd; {
    [_player play];
}



#pragma mark - 中断处理
- (void)interruptedDealing {
    
}

- (void)willResignActiveNotification:(NSNotification *)notification {
    NSLog(@"%s", __func__);
    //暂停
    
}

//应用外处理
- (void)didBecomeActiveNotification:(NSNotification *)notification {
    NSLog(@"%s", __func__);
}
- (void)willEnterForegroundNotification:(NSNotification *)notification {
    NSLog(@"%s", __func__);
}

//应用内处理 录制中断
- (void)captureSessionWasInterruptedNotification:(NSNotification *)notification {
    NSLog(@"%s", __func__);
}
- (void)captureSessionInterruptionEndedNotification:(NSNotification *)notification {
    NSLog(@"%s", __func__);
}



//MARK: - 视频进度监听和控制 循环播放等处理
//MARK: 这个通知实现无线循环播放
- (void)playerItemDidPlayToEndTimeNotification:(NSNotification *)notification {
    NSLog(@"%s", __func__);
    //暂停
    [_player seekToTime:kCMTimeZero];
    [_player play];
}

- (void)playerRemoveTimeObserver {
      [_player removeTimeObserver:_timeObserver];
}

- (void)playerTimeObserverWithTimeHandler:(void (^)(CMTime time))handler {
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, 600) queue:nil usingBlock:^(CMTime time) {
        //可以在此处理 配置一个循环播放的设置
        if (handler) {
            handler(time);
        }
    }];
}

@end
