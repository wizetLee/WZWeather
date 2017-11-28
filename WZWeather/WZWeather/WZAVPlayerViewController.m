//
//  WZAVPlayerViewController.m
//  WZWeather
//
//  Created by admin on 27/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZAVPlayerViewController.h"
#import "BIVideoEditingClippingView.h"
#import "WZAPLSimpleEditor.h"

/*
 动画 + 视频导出
 */

@interface WZAVPlayerViewController ()<WZAPLSimpleEditorProtocol>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *targetItem;
@property (nonatomic, strong) AVPlayerLayer *previewLayer;
@property (nonatomic, strong) UIView *gestureView;
@property (nonatomic, strong) NSMutableArray *cellMArr;
@property (nonatomic, strong) NSMutableArray *timePointMArr;
@property (nonatomic, strong) NSMutableArray *curBucket;
@property (nonatomic, strong) UIButton *exportButton;
@property (nonatomic, strong) BIVideoEditingClippingView *clipingView;

@property (nonatomic, strong) WZAPLSimpleEditor *editor;
@property (nonatomic, strong) CALayer *containLayer;

@property (nonatomic, strong) UISlider *slider;

@end

@implementation WZAVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     _editor = [[WZAPLSimpleEditor alloc] init];
    _editor.delegate = self;
    _cellMArr = [NSMutableArray array];
    
    AVURLAsset *asset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample_clip1" ofType:@"m4v"]]];
    
    [_editor updateEditorWithVideoAssets:@[asset1]];//得到targetSize
    _containLayer = [self parentLayerWithTargetAssetSize:_editor.targetSize];
    
    _targetItem = [[AVPlayerItem alloc] initWithAsset:asset1];
    if (!_targetItem) return;
    [self dataConfig];
    [self createViews];
}

- (CALayer *)parentLayerWithTargetAssetSize:(CGSize)size {
    CALayer *parentLayer = [[CALayer alloc] init];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    parentLayer.backgroundColor = [UIColor clearColor].CGColor;
        return parentLayer;
}


- (void)dataConfig {

    _player = [[AVPlayer alloc] initWithPlayerItem:_targetItem];
    _previewLayer = [AVPlayerLayer playerLayerWithPlayer:_player] ;
   
}


- (void)createViews {
    CGFloat top = 0.0;
    CGFloat bottom = 0.0;
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
    
    top = MACRO_FLOAT_STSTUSBAR_AND_NAVIGATIONBAR_HEIGHT;
    bottom = MACRO_FLOAT_SAFEAREA_BOTTOM;
    
    CGFloat height = screenH - bottom - top;
    CGSize size = [NSObject wz_fitSizeComparisonWithScreenBound:_targetItem.asset.naturalSize];
    _previewLayer.frame = CGRectMake(0.0, top, size.width, size.height);
    [self.view.layer addSublayer:_previewLayer];
    
    _gestureView =  [[UIView alloc] initWithFrame:_previewLayer.frame];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addSubview:_gestureView];
    _gestureView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.25];
    [_gestureView addGestureRecognizer:pan];
    _gestureView.clipsToBounds = true;

    _exportButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, screenH - bottom - 44.0, 2 * 44.0, 44.0)];
    [self.view addSubview:_exportButton];
    _exportButton.backgroundColor = [UIColor yellowColor];
    [_exportButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_exportButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(40.0, CGRectGetMinY(_exportButton.frame) - 44.0, screenW - 80.0, 44.0)];
    [_slider addTarget:self action:@selector(slider:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider];
    _slider.backgroundColor = [UIColor greenColor];
}

- (void)dealloc {
    [_player pause];
    _player = nil;
}

- (void)slider:(UISlider *)slider {
    ///控制播放进度
    if (_player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        CMTime time = CMTimeMakeWithSeconds(slider.value * CMTimeGetSeconds(_player.currentItem.duration), _player.currentItem.duration.timescale);
        [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

- (void)clickedBtn:(UIButton *)sender {
    
    ///尺寸需要修改
    for (NSMutableArray *tmpMArr in _cellMArr) {
        for (NSDictionary *dic in tmpMArr) {
            CGFloat time =  [dic[@"time"] floatValue];
            CGPoint point = [dic[@"point"] CGPointValue] ;
            CALayer *layer = [CALayer layer];
            layer.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor;
            layer.opacity = 0;
            layer.frame = CGRectMake(0, 0, 40, 40);
            layer.position = point;
            
            CAKeyframeAnimation *baseAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
            baseAnimation.values = @[@0.5f, @0.1, @0.1, @0.0f];
            baseAnimation.keyTimes = @[@0.0f, @0.25f, @0.75f, @1.0f];
            
            baseAnimation.removedOnCompletion = false;
            baseAnimation.beginTime = time;//
            baseAnimation.duration = 3;
            [layer addAnimation:baseAnimation forKey:nil];
            [_containLayer addSublayer:layer];
        }
    }
    
    {////加一个动画
        CALayer *animationLayer = [CALayer layer];
        animationLayer.frame = CGRectMake(0, 0, _editor.targetSize.width, _editor.targetSize.height);
        CALayer *videoLayer = [CALayer layer];
        videoLayer.frame = CGRectMake(0, 0, _editor.targetSize.width, _editor.targetSize.height);
        
        [animationLayer addSublayer:videoLayer];
        
        [animationLayer addSublayer:_containLayer];
        animationLayer.geometryFlipped = true;//确保能被正确渲染（如果没设置 图像会颠倒（也就是坐标紊乱））
        AVVideoCompositionCoreAnimationTool *animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer                  inLayer:animationLayer];
        _editor.videoComposition.animationTool = animationTool;//赋值 CAAnaimtion
    }
    
    __weak typeof(self) weakSelf = self;
    [_editor exportToSandboxDocumentWithFileName:@"myy.mp4" completionHandler:^(AVAssetExportSessionStatus statue, NSURL *fileURL) {
                if (statue == AVAssetExportSessionStatusCompleted) {
                    NSLog(@"导出成功");
                    [WZAPLSimpleEditor saveVideoToLocalWithURL:fileURL completionHandler:^(BOOL success) {
                        if (success) {
                            NSLog(@"保存成功");
                        } else {
                            NSLog(@"保存失败");
                        }
                    }];
                
                    _player = nil;
                    CGRect frame = _previewLayer.frame;
                    _previewLayer = nil;
                    _player = [[AVPlayer alloc] initWithPlayerItem:[_editor playerItem]];
                    _previewLayer = [AVPlayerLayer playerLayerWithPlayer:_player] ;
                    _previewLayer.frame = frame;
                    
                } else {
                    NSLog(@"导出失败");
                }
    }];
}

- (void)wzAPLSimpleEditor:(WZAPLSimpleEditor *)editor currentProgress:(CGFloat)progress {
    [self.exportButton setTitle:[NSString stringWithFormat:@"%lf", progress] forState:UIControlStateNormal];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint curPoint = [pan locationInView:pan.view];
    //粒子动画考试啦
    if (pan.state == UIGestureRecognizerStateBegan) {
        //开始跑

        _timePointMArr = [NSMutableArray array];
        [_cellMArr addObject:_timePointMArr];
        [_player play];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat videoTime = CMTimeGetSeconds(_player.currentTime);//得到视频播放时间
        if (CMTimeGetSeconds(_player.currentItem.duration) - videoTime <= 0) {
            return;
        }
        CGFloat scale = _editor.targetSize.width/ _previewLayer.frame.size.width;
        CGPoint mapPoint = CGPointMake(curPoint.x * scale, curPoint.y * scale);
        
        NSDictionary *dic = @{@"time":[NSNumber numberWithFloat:videoTime], @"point": [NSValue valueWithCGPoint:mapPoint]};
        [_timePointMArr addObject:dic];
        
        //开始加上layer
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor;
        layer.opacity = 0;
        layer.frame = CGRectMake(0, 0, 40, 40);
        layer.position = curPoint;
        CAKeyframeAnimation *baseAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        baseAnimation.values = @[@0.5f, @0.1, @0.1, @0.0f];
        baseAnimation.keyTimes = @[@0.0f, @0.25f, @0.75f, @1.0f];
        
        baseAnimation.removedOnCompletion = false;
        baseAnimation.beginTime = 0;//
        baseAnimation.duration = 3;
        [layer addAnimation:baseAnimation forKey:nil];
        [pan.view.layer addSublayer: layer];
        [_curBucket addObject:layer];
        
//        [parentLayer  addSublayer:layer];
        
    } else if (pan.state == UIGestureRecognizerStateCancelled
               || pan.state == UIGestureRecognizerStateEnded
               || pan.state == UIGestureRecognizerStateFailed) {
        //停跑
        [_player pause];
        
        CFTimeInterval pausedTime = [_containLayer convertTime:CACurrentMediaTime() fromLayer:nil];
        for (CALayer *l in _containLayer.sublayers) {
            l.timeOffset = pausedTime;
            l.speed = 0;
        }
//        _containLayer.speed = 0;
//        _containLayer.timeOffset = pausedTime;
    }
}




@end
