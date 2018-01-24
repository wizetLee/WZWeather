/*
     File: APLSimpleEditor.m
 Abstract: Simple editor setups an AVMutableComposition using supplied clips and time ranges. It also setups AVVideoComposition to add a crossfade transition.
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "WZAPLSimpleEditor.h"
#import <CoreMedia/CoreMedia.h>
#import <Photos/Photos.h>

@interface WZAPLSimpleEditor ()

@property (nonatomic, readwrite, retain) NSArray <AVAsset *>*clips; // array of AVURLAssets
@property (nonatomic, readwrite, retain) NSArray <NSValue *>*clipTimeRanges; // array of CMTimeRanges stored in NSValues.
@property (nonatomic, readwrite, retain) AVMutableComposition *composition;
@property (nonatomic, readwrite, retain) AVMutableVideoComposition *videoComposition;
@property (nonatomic, readwrite, retain) AVMutableAudioMix *audioMix;

///custom
@property (nonatomic, strong) NSMutableArray <AVAsset *>*clips_mut;//存储资源集合
@property (nonatomic, strong) NSMutableArray <NSValue *>*clipTimeRanges_mut;//存储时间
@property (nonatomic, assign) CGSize targetSize;
@property (nonatomic, assign) CMTime lastDuration;//去排位在奇数的资源的过渡时间

@end

@implementation WZAPLSimpleEditor

- (void)buildTransitionComposition:(AVMutableComposition *)composition andVideoComposition:(AVMutableVideoComposition *)videoComposition andAudioMix:(AVMutableAudioMix *)audioMix
{
	CMTime nextClipStartTime = kCMTimeZero;
	NSInteger i;
	NSUInteger clipsCount = [self.clips count];
	
	// Make transitionDuration no greater than half the shortest clip duration.
	CMTime transitionDuration = self.transitionDuration;

	//分别配置两条 视轨 和 音轨
	// Add two video tracks and two audio tracks.
	AVMutableCompositionTrack *compositionVideoTracks[2];
	AVMutableCompositionTrack *compositionAudioTracks[2];
	compositionVideoTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	compositionVideoTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
	CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * clipsCount);  //在stack上分配内存
	CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * clipsCount);   //无需手动释放

    BOOL useAudioTrack = true;
    
    //检查是否需要用到音轨
    for (i = 0; i < clipsCount; i++ ) {
        AVAsset *asset = [self.clips objectAtIndex:i];
        if ([asset tracksWithMediaType:AVMediaTypeAudio].count == 0) {
            //有一个视频没有音轨的话所有视频的音轨都不使用音轨
            useAudioTrack = false;
        }
    }
    
    if (useAudioTrack) {
        compositionAudioTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        compositionAudioTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    }

	// Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
	for (i = 0; i < clipsCount; i++ ) {
        //交替使用音轨和视轨
		NSInteger alternatingIndex = i % 2; // alternating targets: 0, 1, 0, 1, ...
		AVAsset *asset = [self.clips objectAtIndex:i];
		NSValue *clipTimeRange = [self.clipTimeRanges objectAtIndex:i];
		CMTimeRange timeRangeInAsset = clipTimeRange ? [clipTimeRange CMTimeRangeValue] : CMTimeRangeMake(kCMTimeZero, [asset duration]);
//      CMTimeRange timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, clipVideoTrack.asset.duration)
//        NSLog(@"时长 %@", [NSValue valueWithCMTimeRange:timeRangeInAsset]);
        if ([asset tracksWithMediaType:AVMediaTypeVideo].count == 0) {
            NSAssert(0, @"视频视轨缺失，请检查");
            return ;
        }
        
		AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        //插入到视轨
        /**
         1、视频的选择范围
         2、数据源轨道
         3、轨道指定的时间点
         */
		[compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
        
//        NSLog(@"视频的插入时间:%@", [NSValue valueWithCMTime:nextClipStartTime]);
#pragma mark 可能不存在音轨 所以有所省缺  如果视频中有音轨不存在 那么可能会导致视频合成的失败 目前的解释为（有多余的没有被使用到的音轨导致这个问题）
        //插入到音轨
        if ([asset tracksWithMediaType:AVMediaTypeAudio].count
            && useAudioTrack) {
            AVAssetTrack *clipAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            [compositionAudioTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipAudioTrack atTime:nextClipStartTime error:nil];
        }
		
		// Remember the time range in which this clip should pass through.
		// Second clip begins with a transition.
		// First clip ends with a transition.
		// Exclude those transitions from the pass through time ranges.
		passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);

//MARK: - transitionDuration的判断
        if (CMTIME_COMPARE_INLINE(self.transitionDuration, ==, kCMTimeZero)) {//过渡时间为0
            transitionDuration = kCMTimeZero;
        } else if (CMTIME_COMPARE_INLINE(asset.duration, <=, CMTimeAdd(transitionDuration, transitionDuration))) {//个人设定：如果视频的时间小于等过渡时间的2倍则不使用过渡效果(其实等于也是可行的)
            transitionDuration = kCMTimeZero;
        }
        
#pragma mark  当不满足 "前后的视频"的duration都大于2倍的过渡时间，不允许进行过渡效果
        {//过渡间隔部分
            {//读取资源时间，判断是否可过渡
                if (i + 1 < clipsCount) {
                    AVAsset *nextAsset= [self.clips objectAtIndex:i + 1];
                    if (CMTIME_COMPARE_INLINE(nextAsset.duration, >=, CMTimeAdd(transitionDuration, transitionDuration))
                        && CMTIME_COMPARE_INLINE(asset.duration, >=, CMTimeAdd(transitionDuration, transitionDuration))) {
                        self.transitionsEnabledMArr[i] = @(1);
                        //可过渡
                    } else {
                        //不可过渡
                        self.transitionsEnabledMArr[i] = @(0);
                        transitionDuration = kCMTimeZero;
                    }
                }
            }
            {//重新适配pass 和 transition时间点
                if (i != 0 && i % 2 != 0) { //0 1 2 3 4 5 奇数
                    transitionDuration = _lastDuration;
                } else {
                    _lastDuration = transitionDuration;
                }
                
                if (i > 0) {
                    //根据transitionDuration判断是否要延迟开场的时间
                    passThroughTimeRanges[i].start = CMTimeAdd(passThroughTimeRanges[i].start, transitionDuration);
                    CMTime time = passThroughTimeRanges[i].duration;
                    //通过的时间 = 视频的总时间 - 上一个过渡时间
                    passThroughTimeRanges[i].duration = CMTimeSubtract(time, transitionDuration);
                }
                
                if (i+1 < clipsCount) {
                    CMTime time = passThroughTimeRanges[i].duration;
                    ///减掉过渡时间
                    passThroughTimeRanges[i].duration = CMTimeSubtract(time, transitionDuration);
                }
            }
        }
//MARK: - transitionDuration的判断

		// The end of this clip will overlap the start of the next by transitionDuration.
		// (Note: this arithmetic falls apart if timeRangeInAsset.duration < 2 * transitionDuration.)
		nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
		nextClipStartTime = CMTimeSubtract(nextClipStartTime, transitionDuration);
		
		// Remember the time range for the transition to the next item.
		if (i + 1 < clipsCount) { //n段视频 有n-1个过渡状态
			transitionTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, transitionDuration);
//            NSLog(@"过渡时间 : %@", [NSValue valueWithCMTimeRange:transitionTimeRanges[i]]);
		}
	}
	
	// Set up the video composition if we are to perform crossfade transitions between clips.
	NSMutableArray *instructions = [NSMutableArray array];
	NSMutableArray *trackMixArray = [NSMutableArray array];
	
	// Cycle between "pass through A", "transition from A to B", "pass through B"

///层指令设置
    for (i = 0; i < clipsCount; i++ ) {
        NSInteger alternatingIndex = i % 2; // alternating targets
        AVAsset *assert = self.clips[alternatingIndex];

///非视频过渡部分
        {
            // Pass through clip i.
            AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            
            passThroughInstruction.timeRange = passThroughTimeRanges[i];
            
//            NSLog(@"pass: %@", [NSValue valueWithCMTimeRange:passThroughInstruction.timeRange]);
            ///在这里可以更改视频的尺寸
            AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];

            {///视频方向纠正
                CGAffineTransform transform = [assert tracksWithMediaType:AVMediaTypeVideo].firstObject.preferredTransform;
                [passThroughLayer setTransformRampFromStartTransform:transform toEndTransform:transform timeRange:passThroughInstruction.timeRange];
            }
            
            passThroughInstruction.layerInstructions = @[passThroughLayer];
            [instructions addObject:passThroughInstruction];
        }
        
        //少了一次的计算量 因为最后一段是不用过渡的
        if (i+1 < clipsCount) {
///视频过渡部分
            {
                AVMutableVideoCompositionInstruction *transitionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
                transitionInstruction.timeRange = transitionTimeRanges[i];//配置过渡范围
                AVMutableVideoCompositionLayerInstruction *fromLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
                AVMutableVideoCompositionLayerInstruction *toLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[1-alternatingIndex]];
                
                {//处理正确的视频的方向
                    [fromLayer setTransformRampFromStartTransform:[assert tracksWithMediaType:AVMediaTypeVideo].firstObject.preferredTransform toEndTransform:[assert tracksWithMediaType:AVMediaTypeVideo].firstObject.preferredTransform timeRange:transitionInstruction.timeRange];
                    [toLayer setTransformRampFromStartTransform:[assert tracksWithMediaType:AVMediaTypeVideo].firstObject.preferredTransform toEndTransform:[assert tracksWithMediaType:AVMediaTypeVideo].firstObject.preferredTransform timeRange:transitionInstruction.timeRange];
                }
                
                {///配置过渡效果
                    ///这个角标
                    if (self.transitionTypeMArr.count > i) {
                        [self animationWithFromLayer:fromLayer toLayer:toLayer targetSize:self.targetSize transitionTimeRange:transitionTimeRanges[i] targetType:[self.transitionTypeMArr[i] unsignedIntegerValue]];
                    } else {
                        //使用默认类型的过渡效果（溶解）
                        //Fade in the toLayer by setting a ramp from 0.0 to 1.0.
                        [toLayer setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:transitionTimeRanges[i]];//溶解呈现
                    }
                }
                transitionInstruction.layerInstructions = @[toLayer, fromLayer];
                [instructions addObject:transitionInstruction];
            }

///更改视频过渡的音量
             AVAsset *assert = self.clips[alternatingIndex];
             if ([assert tracksWithMediaType:AVMediaTypeAudio].count && useAudioTrack) {
                 {//过渡时期 分别对两个视频的音轨进行更改
                     //Add AudioMix to fade in the volume ramps
                     AVMutableAudioMixInputParameters *trackMix1 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTracks[alternatingIndex]];
                     
                     ///音量设置
                     [trackMix1 setVolumeRampFromStartVolume:1.0 toEndVolume:0.0 timeRange:transitionTimeRanges[i]];//降音
                     
                     [trackMixArray addObject:trackMix1];
                     
                     AVMutableAudioMixInputParameters *trackMix2 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTracks[1 - alternatingIndex]];
                     
                     [trackMix2 setVolumeRampFromStartVolume:0.0 toEndVolume:1.0 timeRange:transitionTimeRanges[i]];//增音
                     
                     //发生了异常 时间算得有点问题 有点偏差也会错 当然这句代码其实是可以省略的
                     //                NSLog(@"~~~~%@", [NSValue valueWithCMTimeRange:passThroughTimeRanges[i + 1]]);
                     //                [trackMix2 setVolumeRampFromStartVolume:1.0 toEndVolume:1.0 timeRange:passThroughTimeRanges[i + 1]];//保持音量
                     
                     [trackMixArray addObject:trackMix2];
                 }
             }
        }
    }

//    NSLog(@"视频片段数目:(非过渡+过渡) %ld", instructions.count);//一直都会是奇数
    videoComposition.instructions = instructions;//把需要过渡的片段加入到资源集合中
    audioMix.inputParameters = trackMixArray;
 
//    for (AVVideoCompositionInstruction *ins in instructions) {
//        NSLog(@"%@", [NSValue valueWithCMTimeRange:ins.timeRange]);
//    }
}

///视频过渡效果
- (void)animationWithFromLayer:(AVMutableVideoCompositionLayerInstruction *)fromLayer toLayer:(AVMutableVideoCompositionLayerInstruction *)toLayer targetSize:(CGSize)targetSize transitionTimeRange:(CMTimeRange)transitionTimeRange targetType:(NSUInteger)targetType {
               switch (targetType) {
        case APLSimpleEditorTransitionType_Push: {
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
        case APLSimpleEditorTransitionType_Wipe: {
            CGFloat videoWidth = targetSize.width;
            CGFloat videoHeight = targetSize.height;
            
            CGRect startRect = CGRectMake(0.0f, 0.0f, videoWidth, videoHeight);
            CGRect endRect = CGRectMake(0.0f, videoHeight, videoWidth, 0.0f);
            
            [fromLayer setCropRectangleRampFromStartCropRectangle:startRect
                                               toEndCropRectangle:endRect
                                                        timeRange:transitionTimeRange];
        } break;
            
        default:{
            [toLayer setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:transitionTimeRange];
        }  break;
    }
}

//更新过渡节点状态
- (void)updateTransitionsStatus {
    for (int i = 0; i < self.clips.count - 1; i++) {
        [self.transitionTypeMArr addObject:@(0)];     //初始配置为无过渡类型
        [self.transitionsEnabledMArr addObject:@(1)]; //初始配置皆可过渡
    }
}

///配置composition
- (void)buildCompositionObjectsForPlayback {
	if ( (self.clips == nil) || [self.clips count] == 0 ) {
		self.composition = nil;
		self.videoComposition = nil;
		return;
	}
    [self updateTransitionsStatus];
    
	AVMutableComposition *composition = [AVMutableComposition composition];
	AVMutableVideoComposition *videoComposition = nil;
	AVMutableAudioMix *audioMix = nil;
	
#warning 处理视频尺寸的步骤， 会影响到合成视屏的尺寸
    {//如果没有自定义targetSize视频尺寸则使用第一个视频资源的尺寸作为输出尺寸 且处理好正确的视屏尺寸
        if (CGSizeEqualToSize(self.targetSize, CGSizeZero)) {
            self.targetSize = [[self.clips objectAtIndex:0] naturalSize];
//            [[self.clips objectAtIndex:0] tracksWithMediaType:AVMediaTypeVideo].firstObject.naturalSize
            //正常方向
            AVAsset *asset = [self.clips objectAtIndex:0];
            BOOL needAdjust = false;
            if ([asset tracksWithMediaType:AVMediaTypeVideo].count) {
                CGAffineTransform t =  [asset tracksWithMediaType:AVMediaTypeVideo].firstObject.preferredTransform;
                if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
                    needAdjust = true;
                }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
                    needAdjust = true;
                }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
                }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){}
                if (needAdjust) {
                    //需要调整videoComposition.renderSize 的尺寸
                    self.targetSize = CGSizeMake(self.targetSize.height, self.targetSize.width);
                } else {
                    //无需调整 不处理尺寸
                }
            }
        }
    }
   
    CGSize videoSize = self.targetSize;
	composition.naturalSize = videoSize;
	
	// With transitions:
	// Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
	// Set up the video composition to cycle between "pass through A", "transition from A to B",
	// "pass through B"
	
	videoComposition = [AVMutableVideoComposition videoComposition];
	audioMix = [AVMutableAudioMix audioMix];

    videoComposition.renderSize = videoSize;//取第一个视频的大小 这里需要修改，个人的设定为（必须所有尺寸统一才可合成，不然需要适配一套规则）
	[self buildTransitionComposition:composition andVideoComposition:videoComposition andAudioMix:audioMix];
	
	if (videoComposition) {
		// Every videoComposition needs these properties to be set:
        videoComposition.frameDuration = CMTimeMake(1.0, 30.0); // 30 fps
		videoComposition.renderSize = videoSize;
        videoComposition.renderScale = 1.0;
	}
	
    self.composition = composition;
    self.videoComposition = videoComposition;
    self.audioMix = audioMix;
    
//    //合成时间暴增
//    [self addAnimationToolAnimate];
}

#pragma mark - Accessor
- (NSMutableArray *)transitionTypeMArr {
    if (!_transitionTypeMArr) {
        _transitionTypeMArr = [NSMutableArray array];
    }
    return _transitionTypeMArr;
}

- (NSMutableArray *)transitionsEnabledMArr {
    if (!_transitionsEnabledMArr) {
        _transitionsEnabledMArr = [NSMutableArray array];
    }
    return _transitionsEnabledMArr;
}

- (AVPlayerItem *)playerItem {
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[self.composition copy]];
    AVMutableVideoComposition *videoComposition = [self.videoComposition copy];
    videoComposition.animationTool = nil;
    playerItem.videoComposition = videoComposition;
    playerItem.audioMix = [self.audioMix copy];
    
    //    AVSynchronizedLayer *synchronizedLayer = [AVSynchronizedLayer synchronizedLayerWithPlayerItem:playerItem]
    //    [synchronizedLayer addSubLayer:]//add上动画的layer 那个layer 要缩减到屏幕的比例  在AVPlayer上才会看得到
    return playerItem;
}

@end

@implementation WZAPLSimpleEditor(assist)

///导出
- (void)exportToSandboxDocumentWithFileName:(NSString *)fileName completionHandler:(void (^)(AVAssetExportSessionStatus statue , NSURL *fileURL))handler {
    if (!fileName
        || ![fileName containsString:@"."]) {
        NSAssert(false, @"请检查分配的文件名字， 其实这个名字跟选定的Type是相关联的");
    }
    
    if (self.composition) {
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
        
        NSString *pathWithComponent = [path stringByAppendingPathComponent:fileName];
        
        NSURL *outputURL = [NSURL fileURLWithPath:pathWithComponent];
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.path]) {
            [[NSFileManager defaultManager] removeItemAtPath:outputURL.path error:nil];
        }
    
        AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:[self.composition copy] presetName:AVAssetExportPresetHighestQuality];
        exportSession.outputURL = outputURL;
        
        exportSession.videoComposition = [self.videoComposition copy];//应该和scale有所冲突
        exportSession.outputFileType = AVFileTypeMPEG4;
        NSLog(@"%@", NSHomeDirectory());
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler(exportSession.status, outputURL);
                }
                NSError *error = nil;
                if (exportSession.status == AVAssetExportSessionStatusFailed
                    || exportSession.status == AVAssetExportSessionStatusCancelled) {
                    [self currentProgress:0.0];
                    error = exportSession.error;
                    NSLog(@"出错提示：%@", exportSession.error.description);
                } else if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                    [self currentProgress:1.0];
                }
                
                if ([_delegate respondsToSelector:@selector(wzAPLSimpleEditor:exportCompleted:)]) {
                    [_delegate wzAPLSimpleEditor:self exportCompleted:error];
                }
            });
        }];
        [self monitorExportProgressWithExportSession:exportSession];
    }
}

///监听导出进度
- (void)monitorExportProgressWithExportSession:(AVAssetExportSession *)exportSession {
    if (!exportSession) {return; }
    double delayInSeconds = 0.1;
    int64_t delta = (int64_t)delayInSeconds * NSEC_PER_SEC;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delta);
    __weak typeof(self) weakSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        
        AVAssetExportSessionStatus status = exportSession.status;
        
        if (status == AVAssetExportSessionStatusExporting
            || status == AVAssetExportSessionStatusWaiting) {
            [weakSelf currentProgress:exportSession.progress];
            [weakSelf monitorExportProgressWithExportSession:exportSession];
            ///进度回调
        } else {}
    });
}

- (void)currentProgress:(CGFloat)progress {
    NSLog(@"progress: %f", progress);
    if ([_delegate respondsToSelector:@selector(wzAPLSimpleEditor:currentProgress:)]) {
        [_delegate wzAPLSimpleEditor:self currentProgress:progress];
    }
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

///资源更新
- (void)updateEditorWithVideoAssets:(NSArray <AVAsset *>*)assets {
    dispatch_group_t dispatchGroup = nil;
    NSArray *assetKeysToLoadAndTest = nil;
    
    for (AVAsset *tmpAsset in assets) {
        if (CMTIME_IS_VALID(tmpAsset.duration)
            && CMTIME_COMPARE_INLINE(tmpAsset.duration, >, kCMTimeZero)) {
            [self loadAsset:tmpAsset withKeys:assetKeysToLoadAndTest usingDispatchGroup:dispatchGroup];
        }
    }
    [self synchronizeWithEditor];
}


- (void)loadAsset:(AVAsset *)asset withKeys:(NSArray *)assetKeysToLoad usingDispatchGroup:(dispatch_group_t)dispatchGroup {
    if (!self.clipTimeRanges_mut) {
        self.clipTimeRanges_mut = [NSMutableArray array];
    }
    
    if (!self.clips_mut) {
        self.clips_mut = [NSMutableArray array];
    }
    
    [self.clips_mut addObject:asset];
    [self.clipTimeRanges_mut addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)]];
}

//
- (void)synchronizeWithEditor
{
    // Clips
    self.clips = self.clips_mut;
    self.clipTimeRanges = self.clipTimeRanges_mut;
    BOOL transitionsEnabled = true;
    
    // Transitions
    //过渡时间为1sec
    if (transitionsEnabled) {
        self.transitionDuration = CMTimeMakeWithSeconds(1.0, 600);
    } else {
        self.transitionDuration = kCMTimeZero;
    }

    [self buildCompositionObjectsForPlayback];
}

//MARK: 配置动画的类型（多用于自定义）
- (CALayer *)animationToolLayerWithTargetSize:(CGSize)targetSize {
    //可以做一些动画之类的
    CALayer *parentLayer = [CALayer layer];
    parentLayer.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.25].CGColor;
    parentLayer.frame = CGRectMake(0, 0, targetSize.width, targetSize.height);
//    parentLayer.opacity = 0.0f;
    
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.values = @[@0.0f, @1.0, @1.0f, @0.0f];
    animation.keyTimes = @[@0.0f, @0.25f, @0.75f, @1.0f];
    
//    animation.beginTime = AVCoreAnimationBeginTimeAtZero;//如果期望在一开始就做这个动画
    ///开始时间
    animation.beginTime = 1;//CMTimeGetSeconds(self.startTimeInTimeline);
    ///动画持续时间
    animation.duration = 1;//CMTimeGetSeconds(self.timeRange.duration);
    animation.removedOnCompletion = false;
    
//    [parentLayer addAnimation:animation forKey:nil];//加入动画
    
//    NSUInteger count = CMTimeGetSeconds(self.composition.duration) / 0.25;
//    for (int i = 0; i < count; i++) {
//        CALayer *layer = [CALayer layer];
//        layer.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor;
//        layer.opacity = 0;
//        layer.frame = CGRectMake(i + 20, 5, 20, 20);
//        CAKeyframeAnimation *baseAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
//        baseAnimation.values = @[@0.5f, @0.5, @0.1, @0.0f];
//        baseAnimation.keyTimes = @[@0.0f, @0.25f, @0.75f, @1.0f];
//        
//        baseAnimation.removedOnCompletion = false;
//        baseAnimation.beginTime = i * 0.25;//动画间隔
//        baseAnimation.duration = 3;
//        [layer addAnimation:baseAnimation forKey:nil];
//      
//        [parentLayer addSublayer:layer];
//      
//    }
    
    return parentLayer;
}

///增加animationToola动画（水印，自定义动画等操作）
- (void)addAnimationToolAnimate {
    //#warning 加上CoreAnimation的动画 解析的效率有点差
    //    {///加上这一段 layer 动画 简直慢到爆炸   效率让人痴迷...
    //        CALayer *animationLayer = [CALayer layer];
    //        animationLayer.frame = CGRectMake(0, 0, self.targetSize.width, self.targetSize.height);
    //
    //        CALayer *videoLayer = [CALayer layer];
    //        videoLayer.frame = CGRectMake(0, 0, self.targetSize.width, self.targetSize.height);
    //
    //        [animationLayer addSublayer:videoLayer];
    //
    //        [animationLayer addSublayer:[self animationToolLayerWithTargetSize:self.targetSize]];
    //
    //        animationLayer.geometryFlipped = true;//确保能被正确渲染（如果没设置图像会颠倒（也就是坐标紊乱））
    //        AVVideoCompositionCoreAnimationTool *animationTool =
    //        [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
    //                                                                                                     inLayer:animationLayer];
    //        videoComposition.animationTool = animationTool;//赋值 CAAnaimtion
    //    }
    //
    //
    //
    //    [self exportToSandboxDocumentWithFileName:@"my.mp4" completionHandler:^(AVAssetExportSessionStatus statue, NSURL *fileURL) {
    //        if (statue == AVAssetExportSessionStatusCompleted) {
    //            NSLog(@"导出成功");
    //            [self saveVideoToLocalWithURL:fileURL completionHandler:^(BOOL success) {
    //                if (success) {
    //                    NSLog(@"保存成功");
    //                } else {
    //                    NSLog(@"保g");
    //                }
    //            }];
    //        } else {
    //            NSLog(@"导出失败");
    //        }
    //    }];
}
@end



