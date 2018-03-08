//
//  WZAVPlayerViewController.m
//  WZWeather
//
//  Created by admin on 27/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZAVPlayerViewController.h"
#import "WZVideoEditingClippingView.h"
#import "WZAPLSimpleEditor.h"
#import "WZMediaFetcher.h"

/*
 动画 + 视频导出
 */

@interface WZAVPlayerViewController ()<WZVideoEditingClippingViewProtocol, WZRatioCutOutViewProtocol>

@property (nonatomic, strong) AVAsset *asset;
//  AVQueuePlayer //播放多段视频
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *targetItem;
@property (nonatomic, strong) AVPlayerLayer *previewLayer;
@property (nonatomic, strong) UIButton *exportButton;
@property (nonatomic, strong) WZVideoEditingClippingView *clipingView;


///播放时间的判定
@property (nonatomic, assign) CMTime startTime;//播放始端
@property (nonatomic, assign) CMTime endTime;//播放末端

@property (nonatomic, strong) id timeObserver;  //监听播放速度的监听者 记得要移除
@property (nonatomic, assign) BOOL dragging;    //判断是否正在拖动中 主要用于监听播放进度内的回调处理
@property (nonatomic, assign) BOOL recyclable;  //是否可循环播放 主要用于监听播放进度内的回调处理 在其他的seekTime操作前要将其设置为false 否则会与监听播放进度内的回调处理有所冲突 在play之前重新设置为false

@end

@implementation WZAVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    AVURLAsset *asset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"curnane" ofType:@"mp4"]]];
    _asset = asset1;
    
    _startTime = kCMTimeZero;//默认0开始
    _targetItem = [[AVPlayerItem alloc] initWithAsset:asset1];
    _endTime = asset1.duration;//默认读到结束
    
    NSAssert(_targetItem, @"资源丢失");
    if (!_targetItem) return;
    [self dataConfig];
    [self createViews];
    
    //禁用侧拉返回
    [self.navigationController addToSystemSideslipBlacklist:NSStringFromClass([self class])];
}

- (void)dealloc {
    [_player removeTimeObserver:_timeObserver];
    [_player pause];
    _player = nil;
}

#pragma mark - Private
//MARK: 配置asset等
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
    
    {
        CGSize size = [NSObject wz_fitSizeComparisonWithScreenBound:_targetItem.asset.naturalSize];
        _previewLayer.frame = CGRectMake(0.0, top, size.width, size.height);
        [self.view.layer addSublayer:_previewLayer];
    }
    {
        _exportButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, screenH - bottom - 44.0, 2 * 44.0, 44.0)];
        [self.view addSubview:_exportButton];
        _exportButton.backgroundColor = [UIColor yellowColor];
        [_exportButton setTitle:@"开始剪裁" forState:UIControlStateNormal];
        [_exportButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_exportButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        _clipingView = [[WZVideoEditingClippingView alloc] initWithFrame:CGRectMake(0.0, _exportButton.minY - 70, screenW, 70.0)];
        _clipingView.delegate = self;
        _clipingView.asset = self.player.currentItem.asset;
        [self.view addSubview:_clipingView];
    }
}

- (void)clickedBtn:(UIButton *)sender {
//    [self saveVideoWithAnimationTool];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(UIScreen.mainScreen.bounds.size.width / 2.0 , UIScreen.mainScreen.bounds.size.height / 2.0)];
    [SVProgressHUD show];
    self.view.userInteractionEnabled = false;
    //剪裁
    [self videoClippingWithAsset:_asset leadingTime:_startTime trailingTime:_endTime];
}


//MARK:- WZRatioCutOutViewProtocol
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
    
    //切换Player的播放位置
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
            if (error) { NSLog(@"删除文件夹失败"); return;};
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
        if (CMTimeCompare(leadingTime, trailingTime) >= 0) {
            NSAssert(false, @"截取视频段的必须有有一个适合的时间段");
        }
        
        CMTime durationTime = CMTimeSubtract(trailingTime, leadingTime);
        CMTimeRange range = CMTimeRangeMake(leadingTime, durationTime);///剪裁的位置
        
        exportSession.timeRange = range;///配置剪裁的位置
        if (CMTimeCompare(range.duration, _asset.duration) == 0) {
            //考虑直接返回原视频，但实际开发的时候，会有其他的一些操作，而非单纯地处理剪裁
            NSLog(@"时间与原视频一样");
        }
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
                    [weakSelf exportcompletedWithURL:exportSession.outputURL];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showProgress:progress];
    });
}
//MARK: 剪裁失败
- (void)exportFail {
    self.view.userInteractionEnabled = true;
    [SVProgressHUD dismiss];
}
//MARK: 剪裁完成
- (void)exportcompletedWithURL:(NSURL *)URL {

    self.view.userInteractionEnabled = true;
    [SVProgressHUD dismiss];
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"操作选取" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"保存本地" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [WZMediaFetcher saveVideoWithURL:URL completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [WZToast toastWithContent:@"保存成功"];
                });
            }
        }];
    }];
    [alertC addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"预览导出效果" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      
        WZVideoSurfAlert *alert = [[WZVideoSurfAlert alloc] init];
        alert.asset = [AVAsset assetWithURL:URL];
        [alert alertShow];
    }];
    [alertC addAction:action];
    
    [self presentViewController:alertC animated:true completion:^{
        
    }];
    
}





//加一个animationTool 可以加水印，或者其他的coreAnimation的动画特效
- (void)addAnimationToComposition:(AVMutableVideoComposition *)composition withOutptuSize:(CGSize)outputSize containLayer:(CALayer *)containLayer {
    {////加一个动画
        CALayer *animationLayer = [CALayer layer];
        animationLayer.frame = CGRectMake(0, 0, outputSize.width, outputSize.height);
        CALayer *videoLayer = [CALayer layer];
        videoLayer.frame = CGRectMake(0, 0, outputSize.width, outputSize.height);
        
        [animationLayer addSublayer:videoLayer];
        
        [animationLayer addSublayer:containLayer]; //承载了动画部分
        animationLayer.geometryFlipped = true;//确保能被正确渲染（如果没设置 图像会颠倒（也就是坐标紊乱））
        AVVideoCompositionCoreAnimationTool *animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer                  inLayer:animationLayer];
        
        composition.animationTool = animationTool;//赋值 CAAnaimtion
    }
}



@end
