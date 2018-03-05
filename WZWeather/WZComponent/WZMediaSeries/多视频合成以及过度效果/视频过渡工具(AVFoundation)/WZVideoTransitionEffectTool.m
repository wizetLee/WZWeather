//
//  WZVideoTransitionEffectTool.m
//  PuzzleVideoProject
//
//  Created by wizet on 23/1/18.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "WZVideoTransitionEffectTool.h"
#import <Photos/Photos.h>
#import "WZVideoTransitionItem.h"


@interface WZVideoTransitionEffectTool()
{
    CMTime _stubbornTransitionTime;//固定的视频过渡时间
    /*为了照顾前后的视频段(视频第一段和最后一段除外)，分别处理“视频时间”与“2*_stubbornTransitionTime的大小”的情况
     这里参照的videoleap APP，过渡时间默认为1s，在视频总时长小于2s时，过渡时间是视频时间的一半
     视频的过渡时间是根据前后两段视频的分别时长来判定的。
     考虑视频变速对过渡时间的影响???
     */
    
    ///配置tool
    AVMutableComposition *_composition;                //合成的部分
    AVMutableVideoComposition *_videoComposition;      //视频的配件
    AVMutableAudioMix *_audioMix;                      //音频的配件
    AVAssetExportSession *_exportSession;
}

@property (nonatomic, strong) NSMutableArray <WZVideoTransitionItem *>*videoSourcesList;    //视频源
//@property (nonatomic, assign) CGSize outputSize;   //输出的视频的尺寸

@end

@implementation WZVideoTransitionEffectTool

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

#pragma mark - Private
- (void)defaultConfig {
    _status = WZVideoTransitionEffectToolStatus_Idle;
    _stubbornTransitionTime = CMTimeMakeWithSeconds(1, 600);
    [self addNotification];
    _outputSize = CGSizeMake(720, 1024);
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)exportToSandboxDocumentWithFileName:(NSString *)fileName completionHandler:(void (^)(AVAssetExportSessionStatus statue , NSURL *fileURL))handler {
    if (!fileName
        || ![fileName containsString:@"."]) {
        NSAssert(false, @"请检查分配的文件名字， 其实这个名字跟选定的Type是相关联的");
    }
    
    if (_composition) {
        if (_outputURL && [_outputURL isFileURL]) {
            
        } else {
            NSLog(@"没有自定义的_outputURL或者_outputURL不合法");
            
            NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
            NSString *pathWithComponent = [path stringByAppendingPathComponent:fileName];
            _outputURL = [NSURL fileURLWithPath:pathWithComponent];
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:_outputURL.path]) {
            [[NSFileManager defaultManager] removeItemAtPath:_outputURL.path error:nil];
        }
        
        AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:[_composition copy] presetName:AVAssetExportPresetHighestQuality];
        _exportSession = exportSession;
        exportSession.outputURL = _outputURL;
        exportSession.videoComposition = [_videoComposition copy];//应该和scale有所冲突
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        _status = WZVideoTransitionEffectToolStatus_Converting;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler(exportSession.status, _outputURL);
                }
                NSError *error = nil;
                if (exportSession.status == AVAssetExportSessionStatusFailed
                    || exportSession.status == AVAssetExportSessionStatusCancelled) {
                    _status = WZVideoTransitionEffectToolStatus_Failed;
                    error = exportSession.error;
                    NSLog(@"导出任务失败：%@", exportSession.error.description);
                    if ([_delegate respondsToSelector:@selector(videoTransitionEffectToolTaskFailed)]) {
                        [_delegate videoTransitionEffectToolTaskFailed];
                    }
                } else if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                    _status = WZVideoTransitionEffectToolStatus_Completed;
                    if ([_delegate respondsToSelector:@selector(videoTransitionEffectTool:completeWithOutputURL:)]) {
                        [_delegate videoTransitionEffectTool:self completeWithOutputURL:_outputURL];
                    }
                }
            });
        }];
        [self monitorExportProgressWithExportSession:exportSession];
    }
}

///监听导出进度
- (void)monitorExportProgressWithExportSession:(AVAssetExportSession *)exportSession {
    if (!exportSession) {return; }
    double delayInSeconds = 0.2;
    int64_t delta = (int64_t)delayInSeconds * NSEC_PER_SEC;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delta);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        AVAssetExportSessionStatus status = exportSession.status;
        if (status == AVAssetExportSessionStatusExporting
            || status == AVAssetExportSessionStatusWaiting) {
            NSLog(@"系统方法视频导出进度：exportSession.progress = %f", exportSession.progress);
         
            ///进度回调
            if ([_delegate respondsToSelector:@selector(videoTransitionEffectTool:progress:)]) {
                [_delegate videoTransitionEffectTool:self progress:exportSession.progress];
            }
            [self monitorExportProgressWithExportSession:exportSession];
            
        } else {}
    });
}

///开始任务前的准备，每次开始任务前，都需要prepareTask（主要是需要吧status设置为ready状态）
- (void)prepareTask {
    _composition                    = [AVMutableComposition composition];
    _videoComposition               = [AVMutableVideoComposition videoComposition];
    _audioMix                       = [AVMutableAudioMix audioMix];
    
    ////计算输出的视频尺寸
    CGSize videoSize                = _outputSize;
    _composition.naturalSize        = videoSize;
    _videoComposition.renderSize    = videoSize;
    //property
    _videoComposition.frameDuration = CMTimeMake(1.0, 30.0); // 30 fps
    _videoComposition.renderScale   = 1.0;
    
    //视频list中size的统一规则要自定义配置
    
    NSMutableArray <WZVideoTransitionItem *>* videoSourcesList = _videoSourcesList;
    
    if (videoSourcesList.count < 2) {
        NSLog(@"小于2个资源，不应当有过渡入口：合成失败");
        return;
    }
    
    AVMutableComposition *composition               = _composition;
    AVMutableVideoComposition *videoComposition     = _videoComposition;
    AVMutableAudioMix *audioMix                     = _audioMix;
    
    AVMutableCompositionTrack *compositionVideoTracks[2];   //自定义的视轨
    AVMutableCompositionTrack *compositionAudioTracks[2];   //自定义的音轨
    
    NSUInteger clipsCount = [videoSourcesList count];                                //资源总量
    CMTimeRange *passThroughTimeRanges  = alloca(sizeof(CMTimeRange) * clipsCount);  //直通时间range
    CMTimeRange *transitionTimeRanges   = alloca(sizeof(CMTimeRange) * clipsCount);  //过渡时间range 
    /*alloca在stack上分配内存，无需手动释放*/
    
    CMTime nextClipStartTime = kCMTimeZero;     //将源插入到目标轨道的时间点
    BOOL needAudioTrack = true;//使用音轨与否
    BOOL hasAudioTrack = false;//使用过音轨与否
    
    {//自定义轨道配置
        compositionVideoTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        compositionVideoTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        if (needAudioTrack) {//需要用到音轨  考虑到有静音的    状态
            compositionAudioTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            compositionAudioTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        }
    }
    
    //--------------->视频音频插入准确的轨道、过渡时间的配置
    for (NSInteger i = 0; i < clipsCount; i++ ) {
        NSInteger alternatingIndex              = i % 2;                     //轨道切换角标
        WZVideoTransitionItem *transitionItem   = [videoSourcesList objectAtIndex:i];
        AVAsset *asset                          = transitionItem.asset;
        
        CMTimeRange timeRangeInAsset = kCMTimeRangeZero;//资源的有效范围
        {//轨道使用策略
            //视轨使用策略
            if ([asset tracksWithMediaType:AVMediaTypeVideo].count == 0) {
                //                NSAssert(0, @"视频视轨缺失，请检查");//采取忽略视轨缺失的集合的还是返回错误状态？
                NSLog(@"某个视频的视轨缺失，请检查（这里应该采取别的策略）");
                return ;
            }
            AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, clipVideoTrack.asset.duration);
            //1、视频的选择范围 2、数据源轨道  3、轨道指定的时间点
            [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
            
            //音频使用策略
            if ([asset tracksWithMediaType:AVMediaTypeAudio].count
                && needAudioTrack) {
                AVAssetTrack *clipAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
                [compositionAudioTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipAudioTrack atTime:nextClipStartTime error:nil];
                hasAudioTrack = true;
            }
        }
        
        //存储直通时间范围（原始范围）
        passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);
        
        {//过渡时间处理策略
            CMTime curTransitionTime = _stubbornTransitionTime;//预设过渡时间
            
            if (i + 1 < clipsCount) {
                WZVideoTransitionItem *curItem  = [videoSourcesList objectAtIndex:i];
                WZVideoTransitionItem *nextItem = [videoSourcesList objectAtIndex:i + 1];
                curItem.endTransitionDuration   = nextItem.startTransitionDuration = curTransitionTime;
                
                if (curItem.transitionEffectType == BIVideoTransitionEffectType_None) {
                    //无过渡
                    curTransitionTime = curItem.endTransitionDuration = nextItem.startTransitionDuration = kCMTimeZero;
                } else {
                    //有过渡
                    CMTime maxTransitionTime = [self maxTransitionTimeWithAsset1:curItem.asset asset2:nextItem.asset];
                    if (CMTimeCompare(maxTransitionTime, curTransitionTime) < 0) {
                        curTransitionTime = curItem.endTransitionDuration = nextItem.startTransitionDuration = maxTransitionTime;//预设与视频时长的冲突解决
                    }
                }
            } //------------------------>得到最终的过渡时间
            
            {//根据过渡时间修改直通时间范围
                if (i > 0) {//1 ~ n
                    //根据transitionDuration判断是否要延迟开场的时间
                    WZVideoTransitionItem *curItem      = [videoSourcesList objectAtIndex:i];
                    CMTime offsetTime                   = curItem.startTransitionDuration;
                    passThroughTimeRanges[i].start      = CMTimeAdd(passThroughTimeRanges[i].start, offsetTime);
                    passThroughTimeRanges[i].duration   = CMTimeSubtract(passThroughTimeRanges[i].duration, offsetTime);
                }
                
                if (i+1 < clipsCount) {// 0 ~ n-1
                    WZVideoTransitionItem *curItem      = [videoSourcesList objectAtIndex:i];
                    CMTime offsetTime                   = curItem.endTransitionDuration;
                    passThroughTimeRanges[i].duration   = CMTimeSubtract(passThroughTimeRanges[i].duration, offsetTime);
                }
            }
            
            //时间偏移计算
            nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
            nextClipStartTime = CMTimeSubtract(nextClipStartTime, curTransitionTime);
            
            //存储过渡节点的时间
            if (i + 1 < clipsCount) {
                transitionTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, curTransitionTime);
            }
        }
    }
    
    //--------------->配置过渡效果
    NSMutableArray *instructions = [NSMutableArray array];
    NSMutableArray *trackMixArray = [NSMutableArray array];
    for (NSInteger i = 0; i < clipsCount; i++) {
        WZVideoTransitionItem *curItem = [videoSourcesList objectAtIndex:i];
        AVAsset *asset = curItem.asset;
        NSInteger alternatingIndex = i % 2;     //轨道切换角标
        
        {//非过渡部分
            AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            
            passThroughInstruction.timeRange = passThroughTimeRanges[i];//配置非过渡时间范围
            
            ///在这里可以更改视频的尺寸
            AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
            
            {//视频方向纠正
                CGAffineTransform transform = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject.preferredTransform;
                [passThroughLayer setTransformRampFromStartTransform:transform toEndTransform:transform timeRange:passThroughInstruction.timeRange];
            }
            
            passThroughInstruction.layerInstructions = @[passThroughLayer];
            [instructions addObject:passThroughInstruction];
        }
        
        {//过渡部分
            if (i + 1 < clipsCount) {
                //                 WZVideoTransitionItem *nextItem = [videoSourcesList objectAtIndex:i + 1];
                AVMutableVideoCompositionInstruction *transitionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
                transitionInstruction.timeRange = transitionTimeRanges[i];//配置过渡范围
                
                AVMutableVideoCompositionLayerInstruction *fromLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
                AVMutableVideoCompositionLayerInstruction *toLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[1 - alternatingIndex]];
                
                {//处理正确的视频的方向
                    CGAffineTransform transform = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject.preferredTransform;
                    [fromLayer setTransformRampFromStartTransform:transform toEndTransform:transform timeRange:transitionInstruction.timeRange];
                    [toLayer setTransformRampFromStartTransform:transform toEndTransform:transform timeRange:transitionInstruction.timeRange];
                }
                
                {//配置过渡效果
                    //使用的溶解效果
                    BOOL useTransitionEffect = true;
                    BIVideoTransitionEffectType curType = curItem.transitionEffectType;
                    if (useTransitionEffect) {
                        [self animationWithFromLayer:fromLayer toLayer:toLayer targetSize:_outputSize transitionTimeRange:transitionTimeRanges[i] targetType:curType];
                    }
                }
                transitionInstruction.layerInstructions = @[toLayer, fromLayer];
                [instructions addObject:transitionInstruction];
                
                {//过渡音效更改
                    if ([asset tracksWithMediaType:AVMediaTypeAudio].count
                        && needAudioTrack) {
                        //降音
                        AVMutableAudioMixInputParameters *trackMix1 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTracks[alternatingIndex]];
                        [trackMix1 setVolumeRampFromStartVolume:1.0 toEndVolume:0.0 timeRange:transitionTimeRanges[i]];
                        [trackMixArray addObject:trackMix1];
                        //增音
                        AVMutableAudioMixInputParameters *trackMix2 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTracks[1 - alternatingIndex]];
                        [trackMix2 setVolumeRampFromStartVolume:0.0 toEndVolume:1.0 timeRange:transitionTimeRanges[i]];
                        [trackMixArray addObject:trackMix2];
                    }
                }
            }
        }
        
        videoComposition.instructions = instructions;
        audioMix.inputParameters = trackMixArray;
    }
    
    //释放准备信号
    _status = WZVideoTransitionEffectToolStatus_Ready;
}

///视频过渡效果
#pragma mark - 自定义的视频过渡效果
- (void)animationWithFromLayer:(AVMutableVideoCompositionLayerInstruction *)fromLayer toLayer:(AVMutableVideoCompositionLayerInstruction *)toLayer targetSize:(CGSize)targetSize transitionTimeRange:(CMTimeRange)transitionTimeRange targetType:(BIVideoTransitionEffectType)targetType {
    switch (targetType) {
        case BIVideoTransitionEffectType_Dissolve: {
            [toLayer setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:transitionTimeRange];
        } break;
        case BIVideoTransitionEffectType_Move_LToR: {
            CGAffineTransform identityTransform = CGAffineTransformIdentity;
            CGFloat videoWidth = targetSize.width;//要获取到需要的尺寸
            CGAffineTransform fromDestTransform =
            CGAffineTransformMakeTranslation(-videoWidth, 0.0);
            
            CGAffineTransform toStartTransform =
            CGAffineTransformMakeTranslation(videoWidth, 0.0);
            
            [fromLayer setTransformRampFromStartTransform:identityTransform
                                           toEndTransform:fromDestTransform
                                                timeRange:transitionTimeRange];
            
            [toLayer setTransformRampFromStartTransform:toStartTransform
                                         toEndTransform:identityTransform
                                              timeRange:transitionTimeRange];
        } break;
        case BIVideoTransitionEffectType_Move_RToL: {
           
            CGAffineTransform identityTransform = CGAffineTransformIdentity;
            CGFloat videoWidth = targetSize.width;//要获取到需要的尺寸
            CGAffineTransform fromDestTransform =
            CGAffineTransformMakeTranslation(videoWidth, 0.0);
            
            CGAffineTransform toStartTransform =
            CGAffineTransformMakeTranslation(-videoWidth, 0.0);
            
            [fromLayer setTransformRampFromStartTransform:identityTransform
                                           toEndTransform:fromDestTransform
                                                timeRange:transitionTimeRange];
            
            [toLayer setTransformRampFromStartTransform:toStartTransform
                                         toEndTransform:identityTransform
                                              timeRange:transitionTimeRange];
            
//             CGFloat videoWidth = targetSize.width;
//            CGRect startRect = CGRectMake(0.0f, 0.0f, videoWidth, videoHeight);
//            CGRect endRect = CGRectMake(0.0f, videoHeight, videoWidth, 0.0f);
//
//            //设置剪裁矩形的变化信息
//            [fromLayer setCropRectangleRampFromStartCropRectangle:startRect
//                                               toEndCropRectangle:endRect
//                                                        timeRange:transitionTimeRange];
        } break;
        case BIVideoTransitionEffectType_Move_TToB: {
            CGAffineTransform identityTransform = CGAffineTransformIdentity;
            CGFloat videoHeight = targetSize.height;//要获取到需要的尺寸
            CGAffineTransform fromDestTransform =
            CGAffineTransformMakeTranslation(0.0, videoHeight);
            
            CGAffineTransform toStartTransform =
            CGAffineTransformMakeTranslation(0.0, -videoHeight);
            
            [fromLayer setTransformRampFromStartTransform:identityTransform
                                           toEndTransform:fromDestTransform
                                                timeRange:transitionTimeRange];
            
            [toLayer setTransformRampFromStartTransform:toStartTransform
                                         toEndTransform:identityTransform
                                              timeRange:transitionTimeRange];
        } break;
        case BIVideoTransitionEffectType_Move_BToT: {
            CGAffineTransform identityTransform = CGAffineTransformIdentity;
            CGFloat videoHeight = targetSize.height;//要获取到需要的尺寸
            CGAffineTransform fromDestTransform =
            CGAffineTransformMakeTranslation(0.0, -videoHeight);
            
            CGAffineTransform toStartTransform =
            CGAffineTransformMakeTranslation(0.0, videoHeight);
            
            [fromLayer setTransformRampFromStartTransform:identityTransform
                                           toEndTransform:fromDestTransform
                                                timeRange:transitionTimeRange];
            
            [toLayer setTransformRampFromStartTransform:toStartTransform
                                         toEndTransform:identityTransform
                                              timeRange:transitionTimeRange];
        } break;
        default:{
            
        }  break;
    }
}

/**
 用于判断个资源的最大的可过渡时间
 @return 返回两个资源的最大的过渡时间(最小值是0 最大值是短的视频的duration的一半)
 */
- (CMTime)maxTransitionTimeWithAsset1:(AVAsset *)asset1 asset2:(AVAsset *)asset2 {
    //-1 = less than, 1 = greater than, 0 = equal)
    int32_t result = CMTimeCompare(asset1.duration, asset2.duration);
    CMTime resultTime = asset1.duration;
    if (result > 0) {
        resultTime = asset2.duration;
    }
    resultTime = CMTimeMake(resultTime.value / 2.0, asset1.duration.timescale);
    return resultTime;
}

+ (void)saveVideoToLocalWithURL:(NSURL *)URL completionHandler:(void (^)(BOOL success))handler {
    if ([[NSFileManager defaultManager] fileExistsAtPath:URL.path]) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:URL];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (handler) {handler(success);}
        }];
    }
}

#pragma mark - Public
- (void)startTask {
    if (_status != WZVideoTransitionEffectToolStatus_Ready) {
        NSLog(@"状态错误：非ready状态");
        return;
    }
    
    [self exportToSandboxDocumentWithFileName:@"wizet.mp4" completionHandler:^(AVAssetExportSessionStatus statue, NSURL *fileURL) {
        [[self class] saveVideoToLocalWithURL:fileURL completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"保存成功");
            } else {
                NSLog(@"保存失败");
            }
        }];
    }];
}

- (void)cancelTask {
    if (_status == WZVideoTransitionEffectToolStatus_Converting) {
        [_exportSession cancelExport];
        if ([_delegate respondsToSelector:@selector(videoTransitionEffectToolTaskCanceled)]) {
            [_delegate videoTransitionEffectToolTaskCanceled];
        }
    } else {
        NSLog(@"状态错误，当前并非在导出视频");
    }
}

- (void)prepareTaskWithAssetSources:(NSArray <AVAsset *> *)sources {
    NSMutableArray <WZVideoTransitionItem *>*tmpMArr = NSMutableArray.array;
    for (AVAsset *tmpAsset in sources) {
        WZVideoTransitionItem *item = WZVideoTransitionItem.alloc.init;
        item.asset = tmpAsset;
        item.transitionEffectType = BIVideoTransitionEffectType_Dissolve;//无过渡效果
        [tmpMArr addObject:item];
    }
    [self prepareTaskWithItemSources:tmpMArr];
}

- (void)prepareTaskWithItemSources:(NSArray <WZVideoTransitionItem *> *)sources {
    [_videoSourcesList removeAllObjects];
    _videoSourcesList = nil;
    _videoSourcesList = [NSMutableArray arrayWithArray:sources];
   
    for (int i = 0; i <_videoSourcesList.count; i++) {
        WZVideoTransitionItem *tmpItem = _videoSourcesList[i];
        if (i == 0) {
             tmpItem.transitionEffectType = BIVideoTransitionEffectType_Move_LToR;
        } else if (i == 1) {
            tmpItem.transitionEffectType = BIVideoTransitionEffectType_Move_RToL;
        } else if (i == 2) {
            tmpItem.transitionEffectType = BIVideoTransitionEffectType_Move_TToB;
        } else if (i == 3) {
            tmpItem.transitionEffectType = BIVideoTransitionEffectType_Move_BToT;
        }
    }
    [self prepareTask];
}


#pragma mark - Notification
- (void)willResignActiveNotification:(NSNotification *)notification {
    NSLog(@"%s", __func__);
    //即将退出后台，如当前有转换任务，cancel掉
    [self cancelTask];
}

- (void)didBecomeActiveNotification:(NSNotification *)notification {
    NSLog(@"%s", __func__);
}

#pragma mark - 废弃部分
- (void)calculateVideoSize {
    //如没手动设置outputSize则取“第一个有size的视频”的size
    if (!CGSizeEqualToSize(_outputSize, CGSizeZero)
        && _videoSourcesList
        && _videoSourcesList.count > 0) {
        
        //       _outputVideoSize = [asset tracks].firstObject.naturalSize;
        for (AVAsset *tmpAsset in _videoSourcesList) {
            _outputSize = [tmpAsset naturalSize];          //或者用视轨的nauralSize
            if (!CGSizeEqualToSize(CGSizeZero, _outputSize)) {continue; };
            BOOL needAdjust = [self judgeNeedAdjustOrientationWithAsset:tmpAsset];;
            if (needAdjust) {//需要调整videoComposition.renderSize 的尺寸
                _outputSize = CGSizeMake(_outputSize.height, _outputSize.width);
            }
            break;
        }
        
    } else {
        NSLog(@"error ： %s", __func__);
    }
}

//判断是否应当转向
- (BOOL)judgeNeedAdjustOrientationWithAsset:(AVAsset *)asset {
    BOOL needAdjust = false;
    if ([asset tracksWithMediaType:AVMediaTypeVideo].count) {
        CGAffineTransform t =  [asset tracksWithMediaType:AVMediaTypeVideo].firstObject.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            needAdjust = true;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            needAdjust = true;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){}
    }
    return needAdjust;
}

@end
