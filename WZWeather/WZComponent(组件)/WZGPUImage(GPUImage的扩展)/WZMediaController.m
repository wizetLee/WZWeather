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
#import <Photos/Photos.h>

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

@property (nonatomic, assign) CMTime currentRecordTime;

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_mediaPreviewView pickMediaType:_mediaPreviewView.mediaType];
    [_mediaPreviewView launchCamera];
    
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
#pragma mark -
#pragma mark - WZMediaPreviewViewProtocol
//MARK:完成录制的回调
- (void)previewView:(WZMediaPreviewView *)view didCompleteTheRecordingWithFileURL:(NSURL *)fileURL {

    //偶尔会出现时间为0  但是确实又可以播放的 可能是文件还没有彻底配置完成
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    NSLog(@"拍摄完成，本次拍摄拍摄时间为：%lf", CMTimeGetSeconds(asset.duration));
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"操作选取" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"保存本地" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileURL];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
              
            }];
        } else {
          
        }
    }];
    [alertC addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"预览导出效果" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        WZVideoSurfAlert *alert = [[WZVideoSurfAlert alloc] init];
        alert.asset = asset;
        [alert alertShow];
    }];
    [alertC addAction:action];
    [self presentViewController:alertC animated:true completion:^{}];
}

//MARK:录制时间的回调
- (void)previewView:(WZMediaPreviewView *)view audioVideoWriterRecordingCurrentTime:(CMTime)time last:(BOOL)last {
    _currentRecordTime = time;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mediaOperationView recordProgress:CMTimeGetSeconds(time)];
       
    });
}
#pragma mark -
#pragma mark - WZMediaGestureViewProtocol
//MARK:更新焦点
- (void)gestureView:(WZMediaGestureView *)view updateFocusAtPoint:(CGPoint)point; {
    CGPoint targetPoint = [self.mediaPreviewView calculatePointOfInterestWithPoint:point];
    [self.mediaPreviewView.cameraCurrent focusAtPoint:targetPoint];
}
//MARK:更新曝光点
- (void)gestureView:(WZMediaGestureView *)view updateExposureAtPoint:(CGPoint)point; {
    CGPoint targetPoint = [self.mediaPreviewView calculatePointOfInterestWithPoint:point];
    [self.mediaPreviewView.cameraCurrent exposureAtPoint:targetPoint];
}

//MARK:同时更新焦点以及曝光点
- (void)gestureView:(WZMediaGestureView *)view updateFocusAndExposureAtPoint:(CGPoint)point; {
    CGPoint targetPoint = [self.mediaPreviewView calculatePointOfInterestWithPoint:point];
    
    [self.mediaPreviewView.cameraCurrent autoFocusAndExposureAtPoint:targetPoint];
}

//MARK:焦距更变
- (void)gestureView:(WZMediaGestureView *)view updateZoom:(CGFloat)zoom {
    [self.mediaPreviewView setZoom:zoom];
}

//MARK:边缘手势
- (void)gestureView:(WZMediaGestureView *)view screenEdgePan:(UIScreenEdgePanGestureRecognizer *)screenEdgePan {
    [self.mediaOperationView screenEdgePan:screenEdgePan];
}
#pragma mark -
#pragma mark - WZMediaOperationViewProtocol
//MARK:录像速率调节
- (void)operationView:(WZMediaOperationView*)view didScrollToIndex:(NSUInteger)index {
    if (self.mediaPreviewView.recording) {
        [self addNode];
        self.mediaPreviewView.lastTimeScaleType = index;
    } else {
        
    }
}
//MARK:退出相机事件
- (void)operationView:(WZMediaOperationView*)view closeBtnAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:true];
    //清空数据
}

//MARK:拍照事件
- (void)operationView:(WZMediaOperationView*)view shootBtnAction:(UIButton *)sender {
    self.view.userInteractionEnabled = false;
    [_mediaPreviewView pickStillImageWithHandler:^(UIImage *image) {
        if (image) {
            NSLog(@"%@", NSStringFromCGSize(image.size));
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *tmpImageView = [[UIImageView alloc] initWithImage:image];
                CGFloat hw = [UIScreen mainScreen].bounds.size.width * 2.0 / 3;
                tmpImageView.frame = CGRectMake(0.0, 0.0,  hw, hw);
                tmpImageView.contentMode = UIViewContentModeScaleAspectFit;
                tmpImageView.center = self.view.center;
                [self.view addSubview:tmpImageView];
                
                [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    tmpImageView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [tmpImageView removeFromSuperview];
                    self.view.userInteractionEnabled = true;
                }];
            });
        }
    }];
}

//MARK:配置类型时间事件
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
            CGFloat rateH = targetH / (targetH / (9 / 16.0));
            [_mediaPreviewView setCropValue:rateH];
        } break;
        case WZMediaConfigType_canvas_3_multiply_4: {
            CGFloat targetH = screenW / 3.0 * 4.0;//3 ： 4
            
            CGFloat rateH = targetH / (screenW / (9 / 16.0));
//            rateH = (int)(rateH * 100) / 100.0;
            [_mediaPreviewView setCropValue:rateH];
            
        } break;
        case WZMediaConfigType_canvas_9_multiply_16: {
            [_mediaPreviewView setCropValue:1.0];
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
//MARK:选中滤镜事件
- (void)operationView:(WZMediaOperationView*)view didSelectedFilter:(GPUImageFilter *)filter {
    [_mediaPreviewView insertRenderFilter:filter];
}

//MARK:开始录像事件
- (void)operationView:(WZMediaOperationView*)view startRecordGesture:(UILongPressGestureRecognizer *)gesture {
    [_mediaPreviewView startRecord];
}
//MARK:结束录像事件
- (void)operationView:(WZMediaOperationView*)view endRecordGesture:(UILongPressGestureRecognizer *)gesture {
    [_mediaPreviewView endRecord];
    
    //结束录制的时候要再记录一次self.mediaPreviewView.timeScaleMArr
//    [self addNode];
    NSLog(@"%@", self.mediaPreviewView.timeScaleMArr);
}

- (void)operationView:(WZMediaOperationView*)view breakRecordGesture:(UILongPressGestureRecognizer *)gesture {
    [_mediaPreviewView cancelRecord];
}

//MARK:切换摄影 录影
- (void)operationView:(WZMediaOperationView*)view swithToMediaType:(WZMediaType)type {
    [_mediaPreviewView pickMediaType:type];
    [_mediaPreviewView launchCamera];
}

//MARK:视频合成点击事件
- (void)operationView:(WZMediaOperationView*)view compositionBtnAction:(UIButton *)sender {
    //视频合成的思路
    //先加载视频信息
    //再配置轨道信息
    //视频操作指令和音频指令参数
    //创建GPUImageMovieComposition类
    //设置输出目标为GPUImageMovieWriter并开始处理
    //把处理完毕的数据写入手机j   
    //1、合成单一一个视频  加入渐变效果？  以下代码有较高的准确率
//    NSMutableArray *assetMArr = [NSMutableArray array];
//    for (NSString *tmpStr in self.mediaPreviewView.moviesNameMarr) {
//        AVAsset *asset = [AVAsset assetWithURL:[self.mediaPreviewView movieURLWithMovieName:tmpStr]];
//        NSLog(@"~~~~~%lf", CMTimeGetSeconds(asset.duration));
//        if (asset) {
//            [assetMArr addObject:asset];
//        }
//    }
//    AVMutableComposition *mutableComposition = [[self class] compositionWithSegments:assetMArr];
//    NSLog(@"~~~~~%lf", CMTimeGetSeconds(mutableComposition.duration));

    
}

//MARK:输出合成的视频
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
    
    
    //     exportSession.timeRange =   ;//配置时间范围
    
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
    
}

//MARK:增加速率变换的时间节点
- (void)addNode {
    //每转一次就生成一个新的记录对象
    if (CMTimeCompare(_currentRecordTime, kCMTimeZero) != 0) {
        CMTime leadingTime = kCMTimeZero;
        CMTime trailintTime = _currentRecordTime;
        //切换的起点
        if (self.mediaPreviewView.timeScaleMArr.count != 0) {
            NSDictionary *dic = self.mediaPreviewView.timeScaleMArr.lastObject;
            leadingTime =  [dic[@"trailintTime"] CMTimeValue];//上一次的位置
        } else {
            self.mediaPreviewView.lastTimeScaleType = 2;
        }
        
        //leading
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        tmpDic[@"leadingTime"] = [NSValue valueWithCMTime:leadingTime]; //开始位置
        tmpDic[@"trailintTime"] = [NSValue valueWithCMTime:trailintTime];//结束位置
        tmpDic[@"type"] = [NSNumber numberWithUnsignedInteger:self.mediaPreviewView.lastTimeScaleType];//速率类型
        [self.mediaPreviewView.timeScaleMArr addObject:tmpDic];
    }
}


#pragma mark -
#pragma mark - Private Method
- (void)createViews {
    self.view.backgroundColor = [UIColor blackColor];
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
    } else {
        
    }
}
#pragma mark -
#pragma mark - Public Method


@end
