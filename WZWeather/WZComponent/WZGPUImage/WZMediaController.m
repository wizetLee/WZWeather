//
//  WZMediaController.m
//  WZWeather
//
//  Created by Wizet on 17/10/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaController.h"
#import "WZMediaPreviewView.h"
#import "WZMediaOperationView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <GPUImage/GPUImage.h>
#import <GPUImage/GPUImageMovieComposition.h>

/*
 PS:
     处理好渲染线程和主线程之间的关系，在渲染线程处理数据必要时需要加锁
 */

@interface WZMediaController ()<WZMediaPreviewViewProtocol, WZMediaOperationViewProtocol, WZMediaGestureViewProtocol>
{
    BOOL sysetmNavigationBarHiddenState;
}


@property (nonatomic, strong) WZMediaPreviewView *mediaPreviewView;
@property (nonatomic, strong) WZMediaOperationView *mediaOperationView;
///------------------随便搭的UI


@end

@implementation WZMediaController

#pragma mark - ViewController Lifecycle

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (instancetype)init {
    if (self = [super init]) {}
    return self;
}

- (void)loadView {
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.backgroundColor = [UIColor whiteColor];
    
}
- (void)dadsdsd:(WZMediaPreviewView *)mediaPreviewView {
    WZMediaPreviewView *aa = mediaPreviewView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
  
    CGFloat y = 0.0;
    if (@available(iOS 11.0, *)) {
        y = self.view.safeAreaInsets.bottom;
        NSLog(@"%@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    } else {
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController) {
        sysetmNavigationBarHiddenState = self.navigationController.navigationBarHidden;
        self.navigationController.navigationBarHidden = true;
    }
    [_mediaPreviewView pickMediaType:_mediaPreviewView.mediaType];
    [_mediaPreviewView launchCamera];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mediaPreviewView stopCamera];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = sysetmNavigationBarHiddenState;
    }
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

#pragma mark - WZMediaPreviewViewProtocol
- (void)previewView:(WZMediaPreviewView *)view didCompleteTheRecordingWithFileURL:(NSURL *)fileURL {

    
    //偶尔会出现时间为0  但是确实又可以播放的 可能是文件还没有彻底配置完成
    NSLock *lock = [[NSLock alloc] init];
    [lock tryLock];
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    NSLog(@"________________%lf", CMTimeGetSeconds(asset.duration));
    [lock unlock];
//    if (CMTimeGetSeconds(asset.duration) == 0) {
//        self.navigationController.navigationBarHidden = false;
//        MPMoviePlayerViewController *VC = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
//        [self.navigationController pushViewController:VC animated:true];
//    }
   
}

- (void)previewView:(WZMediaPreviewView *)view audioVideoWriterRecordingCurrentTime:(CMTime)time last:(BOOL)last {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mediaOperationView recordProgress:CMTimeGetSeconds(time) / 15.0];
        if (last) {
            [_mediaOperationView addRecordSign];
        }
    });
}

#pragma mark - WZMediaGestureViewProtocol
///更新焦点
- (void)gestureView:(WZMediaGestureView *)view updateFocusAtPoint:(CGPoint)point; {
    CGPoint targetPoint = [self.mediaPreviewView calculatePointOfInterestWithPoint:point];
    [self.mediaPreviewView.cameraCurrent focusAtPoint:targetPoint];
}
///更新曝光点
- (void)gestureView:(WZMediaGestureView *)view updateExposureAtPoint:(CGPoint)point; {
    CGPoint targetPoint = [self.mediaPreviewView calculatePointOfInterestWithPoint:point];
    [self.mediaPreviewView.cameraCurrent exposureAtPoint:targetPoint];
}

///同时更新焦点以及曝光点
- (void)gestureView:(WZMediaGestureView *)view updateFocusAndExposureAtPoint:(CGPoint)point; {
    CGPoint targetPoint = [self.mediaPreviewView calculatePointOfInterestWithPoint:point];
    
    [self.mediaPreviewView.cameraCurrent autoFocusAndExposureAtPoint:targetPoint];
}

///焦距更变
- (void)gestureView:(WZMediaGestureView *)view updateZoom:(CGFloat)zoom {
    [self.mediaPreviewView setZoom:zoom];
}

//边缘手势
- (void)gestureView:(WZMediaGestureView *)view screenEdgePan:(UIScreenEdgePanGestureRecognizer *)screenEdgePan {
    [self.mediaOperationView screenEdgePan:screenEdgePan];
}
#pragma mark - WZMediaOperationViewProtocol
- (void)operationView:(WZMediaOperationView*)view closeBtnAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:true];
    //清空数据
}

- (void)operationView:(WZMediaOperationView*)view shootBtnAction:(UIButton *)sender {
#warning 连拍会产生崩溃
    
    [_mediaPreviewView pickStillImageWithHandler:^(UIImage *image) {
        if (image) {
            NSLog(@"%@", NSStringFromCGSize(image.size));
        }
    }];
}

///配置类型时间
- (void)operationView:(WZMediaOperationView*)view configType:(WZMediaConfigType)type {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
#warning 这个比例在iPhoneX 需要更改 目前只是修改为屏幕的1:1、4:3、16:9的比例 需要更改
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    /*
     WZMediaConfigType_none                  = 0,
     
     WZMediaConfigType_canvas_1_multiply_1   = 11,//W multiply H
     WZMediaConfigType_canvas_3_multiply_4   = 12,
     WZMediaConfigType_canvas_9_multiply_16  = 13,
     
     WZMediaConfigType_flash_auto            = 21,
     WZMediaConfigType_flash_off             = 22,
     WZMediaConfigType_flash_on              = 23,
     
     WZMediaConfigType_countDown_10          = 31,//倒计时
     WZMediaConfigType_countDown_3           = 32,
     WZMediaConfigType_countDown_off         = 33,
     */
    switch (type) {///有误差
        case WZMediaConfigType_canvas_1_multiply_1: {
            //                切换到选中效果
            CGFloat targetH = screenW / 1.0 * 1.0;//显示在屏幕的控件高度

            CGFloat rateH = targetH / screenH;
            rateH = (int)(rateH * 1000) / 1000.0;
            [_mediaPreviewView setCropValue:rateH];
        } break;
        case WZMediaConfigType_canvas_3_multiply_4: {
            CGFloat targetH = screenW / 3.0 * 4.0;//3 ： 4
            CGFloat rateH = targetH / screenH;
            rateH = (int)(rateH * 100) / 100.0;
            [_mediaPreviewView setCropValue:rateH];
            
        } break;
        case WZMediaConfigType_canvas_9_multiply_16: {
            [_mediaPreviewView setCropValue:1];
        } break;
        case WZMediaConfigType_flash_auto: {
            [_mediaPreviewView setFlashType:GPUImageCameraFlashType_auto];
        } break;
        case WZMediaConfigType_flash_off: {
            [_mediaPreviewView setFlashType:GPUImageCameraFlashType_off];
        } break;
        case WZMediaConfigType_flash_on: {
            [_mediaPreviewView setFlashType:GPUImageCameraFlashType_on];
        } break;
        case WZMediaConfigType_countDown_10: {
            
        } break;
        case WZMediaConfigType_countDown_3: {
            
        } break;
        case WZMediaConfigType_countDown_off: {
            
        } break;
            
        default:
            break;
    }
}

- (void)operationView:(WZMediaOperationView*)view didSelectedFilter:(GPUImageFilter *)filter {
    
    [_mediaPreviewView insertRenderFilter:filter];
}

///录像
- (void)operationView:(WZMediaOperationView*)view startRecordGesture:(UILongPressGestureRecognizer *)gesture {
    [_mediaPreviewView startRecord];
}

- (void)operationView:(WZMediaOperationView*)view endRecordGesture:(UILongPressGestureRecognizer *)gesture {
    [_mediaPreviewView endRecord];
}

- (void)operationView:(WZMediaOperationView*)view breakRecordGesture:(UILongPressGestureRecognizer *)gesture {
    [_mediaPreviewView cancelRecord];
}

///切换摄影 录影
- (void)operationView:(WZMediaOperationView*)view swithToMediaType:(WZMediaType)type {
    [_mediaPreviewView pickMediaType:type];
    [_mediaPreviewView launchCamera];
}

- (void)operationView:(WZMediaOperationView*)view compositionBtnAction:(UIButton *)sender {
    //视频合成的思路
    //先加载视频信息
    //再配置轨道信息
    //视频操作指令和音频指令参数
    //创建GPUImageMovieComposition类
    //设置输出目标为GPUImageMovieWriter并开始处理
    //把处理完毕的数据写入手机
    
    //1、合成单一一个视频  加入渐变效果？  以下代码有较高的准确率
    NSMutableArray *assetMArr = [NSMutableArray array];
    for (NSString *tmpStr in self.mediaPreviewView.moviesNameMarr) {
        AVAsset *asset = [AVAsset assetWithURL:[self.mediaPreviewView movieURLWithMovieName:tmpStr]];
        NSLog(@"~~~~~%lf", CMTimeGetSeconds(asset.duration));
        if (asset) {
            [assetMArr addObject:asset];
        }
    }
    AVMutableComposition *mutableComposition = [[self class] compositionWithSegments:assetMArr];
    NSLog(@"~~~~~%lf", CMTimeGetSeconds(mutableComposition.duration));
    //2、插入视频的编码
}

///输出合成的视频
+ (void)exportWithComposition:(AVComposition *)composition outputURL:(NSURL *)outputURL withProgressHandler:(void (^)(CGFloat progress))handler result:(void (^)(BOOL success))result {
    //    AVMutableComposition *composition = [WZCamera compositionWithSegments:_camera.videoRecordSegmentMArr];
    //    NSLog(@"合成路径!!!:%@", composition);
    //    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:composition];
    //可以用来播放
//    AVMutableComposition *composition;
    if (composition) {
        
    }
    NSString *preset = AVAssetExportPresetHighestQuality;
    AVAssetExportSession *exportSession  = [AVAssetExportSession exportSessionWithAsset:composition presetName:preset];

    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
   __block CGFloat progress = 0.0 ;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        //输出状态查询
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAssetExportSessionStatus status = exportSession.status;
            
            if (status == AVAssetExportSessionStatusExporting) {
                progress = exportSession.progress;
                if (handler) {handler(progress);}//输出进度
            } else if (status == AVAssetExportSessionStatusCompleted) {
                //outputURL 可以保存到相册
                progress = 1.0;
                if (handler) {handler(progress);}//输出进度
                if (result) {result(true);}//输出结果
            } else if(status == AVAssetExportSessionStatusCancelled
                      || status == AVAssetExportSessionStatusFailed){
                NSLog(@"输出出错");
                if (result) { result(false);}//输出结果
            }
        });
    }];
    //输出
    exportSession = nil;//置空
}




#pragma mark - SCRecorder 视频合成方案样例代码 稍有更改
+ (AVMutableComposition *)compositionWithSegments:(NSArray <AVAsset *>*)segments {
    //可变音视频组合
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    //可变音频轨道
    AVMutableCompositionTrack *audioTrack = nil;
    //可变视频轨道
    AVMutableCompositionTrack *videoTrack = nil;
    
  
    CMTime currentTime = composition.duration;
    for (AVAsset *tmpAsset in segments) {
        AVAsset *asset = tmpAsset;
        
        NSArray *audioAssetTracks = [asset tracksWithMediaType:AVMediaTypeAudio];//取出音频轨道
        NSArray *videoAssetTracks = [asset tracksWithMediaType:AVMediaTypeVideo];//取出视频轨道
        
        CMTime maxBounds = kCMTimeInvalid;//最大界限
        
        CMTime videoTime = currentTime;
        
        for (AVAssetTrack *videoAssetTrack in videoAssetTracks) {
            if (videoTrack == nil) {
                NSArray *videoTracks = [composition tracksWithMediaType:AVMediaTypeVideo];
                
                if (videoTracks.count) {
                    videoTrack = [videoTracks firstObject];
                } else {
                    videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                    videoTrack.preferredTransform = videoAssetTrack.preferredTransform;
                }
            }
            
            videoTime = [[self class] appendTrack:videoAssetTrack toCompositionTrack:videoTrack atTime:videoTime withBounds:maxBounds];
            maxBounds = videoTime;
        }
        
        CMTime audioTime = currentTime;
        for (AVAssetTrack *audioAssetTrack in audioAssetTracks) {
            if (audioTrack == nil) {
                NSArray *audioTracks = [composition tracksWithMediaType:AVMediaTypeAudio];
                if (audioTracks.count) {
                    audioTrack = [audioTracks firstObject];
                } else {
                    audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                }
            }
            
            
            audioTime = [[self class] appendTrack:audioAssetTrack toCompositionTrack:audioTrack atTime:audioTime withBounds:maxBounds];
        }
        
        currentTime = composition.duration;//组合的时间、作用于下一个循环的偏移量
    }
    
    return composition;
}


+ (CMTime)appendTrack:(AVAssetTrack *)track toCompositionTrack:(AVMutableCompositionTrack *)compositionTrack atTime:(CMTime)time withBounds:(CMTime)bounds {
    CMTimeRange timeRange = track.timeRange;//通道时间轴的所有的时间的范围
    time = CMTimeAdd(time, timeRange.start);//时间相加
    
    if (CMTIME_IS_VALID(bounds)) {
        CMTime currentBounds = CMTimeAdd(time, timeRange.duration);
        
        if (CMTIME_COMPARE_INLINE(currentBounds, >, bounds)) {
            timeRange = CMTimeRangeMake(timeRange.start, CMTimeSubtract(timeRange.duration, CMTimeSubtract(currentBounds, bounds)));
        }
    }
    
    if (CMTIME_COMPARE_INLINE(timeRange.duration, >, kCMTimeZero)) {
        NSError *error = nil;
        [compositionTrack insertTimeRange:timeRange ofTrack:track atTime:time error:&error];
        
        if (error != nil) {
            NSLog(@"Failed to insert append %@ track: %@", compositionTrack.mediaType, error);
        } else {
            //        NSLog(@"Inserted %@ at %fs (%fs -> %fs)", track.mediaType, CMTimeGetSeconds(time), CMTimeGetSeconds(timeRange.start), CMTimeGetSeconds(timeRange.duration));
        }
        
        return CMTimeAdd(time, timeRange.duration);
    }
    
    return time;
}



#pragma mark - Public Method
- (void)createViews {
    //适配iOS 11
    _mediaPreviewView = [[WZMediaPreviewView alloc] initWithFrame:self.view.bounds];
    _mediaPreviewView.delegate = self;
    [self.view addSubview:_mediaPreviewView];
    [_mediaPreviewView launchCamera];//启动
    
    _mediaOperationView = [[WZMediaOperationView alloc] initWithFrame:_mediaPreviewView.bounds];
    _mediaOperationView.delegate = self;
    _mediaOperationView.gestureDelegate = self;
    [self.view addSubview:_mediaOperationView];
    
    if (_mediaPreviewView.mediaType == WZMediaTypeVideo) {
        //切换UI
        
    }
}



@end
