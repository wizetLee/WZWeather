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

@interface WZAVPlayerViewController ()<WZAPLSimpleEditorProtocol, BIVideoEditingClippingViewProtocol, WZRatioCutOutViewProtocol>

@property (nonatomic, strong) AVAsset *asset;
//  AVQueuePlayer //播放多段视频
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

///播放时间的判定
@property (nonatomic, assign) CMTime startTime;//播放始端
@property (nonatomic, assign) CMTime endTime;//播放末端


@property (nonatomic, strong) id timeObserver;//监听播放速度的监听者 记得要移除
@property (nonatomic, assign) BOOL dragging;//判断是否正在拖动中 主要用于监听播放进度内的回调处理
@property (nonatomic, assign) BOOL recyclable;//是否可循环播放 主要用于监听播放进度内的回调处理 在其他的seekTime操作前要将其设置为false 否则会与监听播放进度内的回调处理有所冲突 在play之前重新设置为false

@end

@implementation WZAVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     _editor = [[WZAPLSimpleEditor alloc] init];
    _editor.delegate = self;
    _cellMArr = [NSMutableArray array];
    
    AVURLAsset *asset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample_clip1" ofType:@"m4v"]]];
    _asset = asset1;
    [_editor updateEditorWithVideoAssets:@[asset1]];//得到targetSize
    
    ///获得一个与合成的视频一样大的幕布
    _containLayer = [self parentLayerWithTargetAssetSize:_editor.targetSize];
    
    _startTime = kCMTimeZero;//默认0开始
    _targetItem = [[AVPlayerItem alloc] initWithAsset:asset1];
    _endTime = asset1.duration;//默认读到结束
    
    NSAssert(_targetItem, @"资源丢失");
    if (!_targetItem) return;
    [self dataConfig];
    [self createViews];
    
    [self.navigationController addToSystemSideslipBlacklist:NSStringFromClass([self class])];
}

//MARK: 动画载体layer的size匹配
- (CALayer *)parentLayerWithTargetAssetSize:(CGSize)size {
    CALayer *parentLayer = [[CALayer alloc] init];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    parentLayer.backgroundColor = [UIColor clearColor].CGColor;
    return parentLayer;
}

//MARK: 配置asset等
- (void)dataConfig {
    _player = [[AVPlayer alloc] initWithPlayerItem:_targetItem];
    
    
    
    __weak typeof(self) weakSelf = self;
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, 600) queue:nil usingBlock:^(CMTime time) {
     //可以在此处理 配置一个循环播放的设置
        ///循环播放
      
        if (!weakSelf.dragging && weakSelf.recyclable) {
            if (CMTimeCompare(weakSelf.endTime, kCMTimeZero) != 0) {
                int reuslt = CMTimeCompare(time, weakSelf.endTime);
                if (reuslt == 0
                    || reuslt > 0) {
                    
                    [weakSelf.player pause];
                    ///没找到特别好的方法 暂时使用一个延时播放  利用CPU速度比较快的特点
                    [[weakSelf class] cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(delayPlay) object:nil];
                    [weakSelf performSelector:@selector(delayPlay) withObject:0 afterDelay:0.1];
                 
                }
                //在停止之前也会
            }
        }
    }];
    _previewLayer = [AVPlayerLayer playerLayerWithPlayer:_player] ;
   
}
- (void)delayPlay {
    NSLog(@"——————————————————————————————倒带");
    [_player seekToTime:_startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [_player play];
}

- (void)createViews {
    CGFloat top = 0.0;
    CGFloat bottom = 0.0;
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
    
    top = MACRO_FLOAT_STSTUSBAR_AND_NAVIGATIONBAR_HEIGHT;
    bottom = MACRO_FLOAT_SAFEAREA_BOTTOM;
    
    CGFloat height = screenH - bottom - top;
    
    {
        CGSize size = [NSObject wz_fitSizeComparisonWithScreenBound:_targetItem.asset.naturalSize];
        _previewLayer.frame = CGRectMake(0.0, top, size.width, size.height);
        [self.view.layer addSublayer:_previewLayer];
    }
    
    {
        _gestureView =  [[UIView alloc] initWithFrame:_previewLayer.frame];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self.view addSubview:_gestureView];
        _gestureView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.25];
        [_gestureView addGestureRecognizer:pan];
        _gestureView.clipsToBounds = true;
    }

    {
        _exportButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, screenH - bottom - 44.0, 2 * 44.0, 44.0)];
        [self.view addSubview:_exportButton];
        _exportButton.backgroundColor = [UIColor yellowColor];
        [_exportButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_exportButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        _clipingView = [[BIVideoEditingClippingView alloc] initWithFrame:CGRectMake(0.0, _exportButton.minY - 70, screenW, 70.0)];
        _clipingView.delegate = self;
        _clipingView.asset = self.player.currentItem.asset;
        [self.view addSubview:_clipingView];
    }
}

- (void)dealloc {
    [_player removeTimeObserver:_timeObserver];
    [_player pause];
    _player = nil;
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
            
            } else {
                NSLog(@"导出失败");
            }
    }];
    
    
    //剪裁
//    [self videoClippingWithAsset:_asset leadingTime:_startTime trailingTime:_endTime];
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
        _recyclable = true;
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
        
    }
}

//MARK:- 滑动剪裁控件产生的代理
- (void)ratioCutOutView:(WZRatioCutOutView *)view leadingRatio:(CGFloat)leadingRatio trailingRatio:(CGFloat)trailingRatio leadingDrive:(BOOL)leadingDrive; {
//    NSLog(@"leadingRatio : %f", leadingRatio);
//    NSLog(@"trailingRatio : %f", trailingRatio);
    CMTime tmpTime = kCMTimeZero;
    if (leadingDrive) {
        _startTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(_asset.duration) * leadingRatio, _asset.duration.timescale);
        tmpTime = _startTime;
    } else {
        _endTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(_asset.duration) * trailingRatio, _asset.duration.timescale);
        tmpTime = _endTime;
    }
    
    if (_player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [_player seekToTime:tmpTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }

}
- (void)ratioCutOutViewBeginClipping; {
    //停止播放
    _dragging = true;
    _recyclable = false;
    NSLog(@"--------------------------拖拽开始");
}
- (void)ratioCutOutViewFinishClipping; {
    //可以开始播放
    _dragging = false;
    NSLog(@"--------------------------拖拽完毕");
}

/**
 关于AVPlayer
     调整速率rate
 ***/
//MARK:- 视频剪裁
- (void)videoClippingWithAsset:(AVAsset *)asset leadingTime:(CMTime)leadingTime trailingTime:(CMTime)trailingTime {
    NSAssert(CMTimeGetSeconds(asset.duration), @"资源为空");
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    {//配路径
        NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpClipping.mp4"];//临时文件路径
        NSURL *URL = [NSURL fileURLWithPath:tmpPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:&error];
            if (error) { NSLog(@"删除文件夹失败"); ; return;};
        }
        
        exportSession.outputURL = URL;//配置输出路径
        exportSession.outputFileType = AVFileTypeMPEG4;//配置输出文件的类型}
    }
    
    {//配截取的时间
    
        //a < b -1     0        a > b  1
        if (CMTimeCompare(leadingTime, _asset.duration) >= 0) {
            NSAssert(false, @"截取视频的开始时间必须小于视频的总时长");
        }
        if (CMTimeCompare(trailingTime, _asset.duration) > 0) {
            NSAssert(false, @"截取视频的末端时间必须小于视频的总时长");
        }
        if (CMTimeCompare(leadingTime, trailingTime) <= 0) {
            NSAssert(false, @"截取视频段的必须有有一个适合的时间段");
        }
        
        CMTime durationTime = CMTimeSubtract(trailingTime, leadingTime);
        CMTimeRange range = CMTimeRangeMake(leadingTime, durationTime);///剪裁的位置
        
        exportSession.timeRange = range;///配置剪裁的位置
    }
    
    
    {//导出
        __weak typeof(self) weakSelf = self;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (exportSession.status == AVAssetExportSessionStatusFailed) {
                } else if (exportSession.status == AVAssetExportSessionStatusCancelled
                           ||exportSession.status == AVAssetExportSessionStatusFailed) {
                    //导出失败的动作
                    [weakSelf exportFail];
                } else if (exportSession.status == AVAssetExportSessionStatusCompleted) {
//                    exportSession.outputURL
                    //导出成功的动作
                    [weakSelf exportcompleted];
                }
            });
        }];
    }
    
    //导出速率监听
    [self monitorExportProgressWithExportSession:exportSession];
}

//MARK: 监听剪裁进度
- (void)monitorExportProgressWithExportSession:(AVAssetExportSession *)exportSession {
    
    if (!exportSession) {
        return;
    }
    double delayInSeconds = 0.1;
    int64_t delta = (int64_t)delayInSeconds * NSEC_PER_SEC;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delta);
    __weak typeof(self) weakSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        
        AVAssetExportSessionStatus status = exportSession.status;
        
        if (status == AVAssetExportSessionStatusExporting
            || status == AVAssetExportSessionStatusWaiting) {
            [weakSelf clippingProgress:exportSession.progress];
            [weakSelf monitorExportProgressWithExportSession:exportSession];
            ///进度回调
        } else {
            
        }
    });
}
//MARK: 剪裁进度回调
- (void)clippingProgress:(CGFloat)progress {
    
}
//MARK: 剪裁失败
- (void)exportFail {
    
}
//MARK: 剪裁完成
- (void)exportcompleted {
    
}

//MARK: 根据某一个数据匹配对应的视频的播放速率
//MARK: 新增一个属性用于调整速率
- (void)sss:(AVMutableComposition *)composition {
    if (![composition isKindOfClass:[AVMutableComposition class]]) { return;}
    
    ///修改视频的播放速率
    NSArray<AVMutableCompositionTrack *> *tracks = composition.tracks;
    for (AVMutableCompositionTrack *track in tracks) {
        double videoScaleFactor = 0.5;
        CMTime videoDuration = composition.duration;
        [track scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration)
                   toDuration:CMTimeMake(videoDuration.value*videoScaleFactor, videoDuration.timescale)];
    }
}



@end
