//
//  WZVideoFramesTool.m
//  WZWeather
//
//  Created by 李炜钊 on 2018/3/1.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZVideoFramesTool.h"

typedef NS_ENUM(NSUInteger, WZFramesType) {
    WZFramesType_Origion              = 0,
    WZFramesType_1,
    WZFramesType_2,
};

@interface WZVideoFramesTool()
{
    AVAssetReader *assetReader;
    AVAssetWriter *assetWriter;
    
    AVAssetReaderTrackOutput *assetReaderOutput;
    AVAssetWriterInput *assetWriterInput;
    AVAssetWriterInputPixelBufferAdaptor *assetWriterInputAdaptor;
    BOOL strideOffsetAtRight;//默认为向右偏移
    CMTime assetDuration;
}


@property (nonatomic, strong) NSMutableDictionary *outputSetting;
@property (nonatomic, assign) WZVideoReversalToolStatus status;

@property (nonatomic, assign) CGFloat outputFrameRate;      //要求输出的帧率
@property (nonatomic, assign) CGFloat curAssetFrameRate;    //要求输出的帧率
@end

@implementation WZVideoFramesTool

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeNotification];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (void)defaultConfig {
    _outputFrameRate = 25.0;
    _status = WZVideoReversalToolStatus_Idle;
    [self addNotification];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)reverseWithAsset:(AVAsset *)asset {
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    _status = WZVideoReversalToolStatus_converting;
    if (videoTracks.count < 1) {
        NSLog(@"无视轨");
        [self executeReverseTaskFail];
        return;
    }
    assetDuration = asset.duration;
    
    dispatch_queue_t reverseSerialQueue = dispatch_queue_create("videoFramesSerialQueue.wz", NULL);
    dispatch_async(reverseSerialQueue, ^{
        AVAssetTrack *videoTrack = videoTracks.firstObject;
        float fps = videoTrack.nominalFrameRate;//获取帧率
        self.outputSetting = [NSMutableDictionary dictionary];
        self.outputSetting[(__bridge id)kCVPixelBufferPixelFormatTypeKey] = @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange);
        
        NSError *error = nil;
        assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        assetReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:self.outputSetting];
        assetReaderOutput.supportsRandomAccess = true;
        if ([assetReader canAddOutput:assetReaderOutput]) {
            [assetReader addOutput:assetReaderOutput];
        } else {
            [self executeReverseTaskFail];
            NSLog(@"assetReaderOutput 添加失败");
            return;
        }
        
        [assetReader startReading];
        
        CGFloat outputWidth = videoTrack.naturalSize.width;
        CGFloat outputHeight = videoTrack.naturalSize.height;
        //
        _curAssetFrameRate = videoTrack.nominalFrameRate;//当前视频的帧帧率
        
        //需要保存的帧数的时间
        NSMutableArray *revSampleTimes = [[NSMutableArray alloc] init];
        
        CMSampleBufferRef sample;
        int localCount = 0; //记录总帧数
        
#pragma mark  step 1
//装配输出视频的每帧时间
        CMTime frameRate = CMTimeMake(1, _outputFrameRate);
        CMTime currentTime = CMTimeMake(0, frameRate.timescale);
        NSUInteger targetSecond = 10;
        NSUInteger sumOfFrame = targetSecond * ((NSUInteger)_outputFrameRate);
        for (NSUInteger i = 0; i < sumOfFrame; i++) {
            currentTime = CMTimeAdd(currentTime, frameRate);
            [revSampleTimes addObject:[NSValue valueWithCMTime:currentTime]];
        }
        
        NSMutableArray *passDicts = [[NSMutableArray alloc] init];
        
        NSValue *initEventValue = [revSampleTimes objectAtIndex:0];
        CMTime initEventTime = [initEventValue CMTimeValue];
        
        CMTime passStartTime = [initEventValue CMTimeValue];
        CMTime passEndTime = [initEventValue CMTimeValue];
        
        NSValue *timeEventValue, *frameEventValue;
        NSValue *passStartValue, *passEndValue;
        CMTime timeEventTime, frameEventTime;
        
        int numSamplesInPass = 100;//每次保存的次数
        BOOL initNewPass = NO;
        //数据分配
        for (NSInteger i = 0; i < revSampleTimes.count; i++) {
            timeEventValue = [revSampleTimes objectAtIndex:i];
            timeEventTime = [timeEventValue CMTimeValue];
            
            frameEventValue = [revSampleTimes objectAtIndex:(revSampleTimes.count - 1 - i)];
            frameEventTime = [frameEventValue CMTimeValue];
            
            passEndTime = timeEventTime;
            
            if (i % numSamplesInPass == 0) {
                if (i > 0) { //收集每个pass的信息（pass的开始、结束时间，开始帧、结束帧的角标）
                    passStartValue = [NSValue valueWithCMTime:passStartTime];
                    passEndValue = [NSValue valueWithCMTime:passEndTime];
                    NSDictionary *dict = @{
                                           @"passStartTime": passStartValue,
                                           @"passEndTime": passEndValue,
                                           };
                    [passDicts addObject:dict];
                }
                initNewPass = true; //需要创建新的pass
            }
            
            if (initNewPass) { //更新下一个pass的信息
                passStartTime = timeEventTime;
                
                initNewPass = false;
            }
            
            if ([self reverseTaskDidCancel]) { return; }
        }
        
        int totalPasses = (int)ceil((float)revSampleTimes.count / (float)numSamplesInPass);//一共分为多少次执行循环
        
        //处理最后一个pass
        if ((passDicts.count < totalPasses) || (revSampleTimes.count % numSamplesInPass) != 0) {
            passStartValue = [NSValue valueWithCMTime:passStartTime];
            passEndValue = [NSValue valueWithCMTime:passEndTime];
            NSDictionary *dict = @{
                                   @"passStartTime": passStartValue,
                                   @"passEndTime": passEndValue,
                                   };
            [passDicts addObject:dict];
        }
        
        if (!_outputURL) {
            _outputURL = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:@"WZVideoReversalToolFIle.mov"]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:_outputURL.path]) {
                [[NSFileManager defaultManager] removeItemAtURL:_outputURL error:nil];
            }
        }
        
        assetWriter = [[AVAssetWriter alloc] initWithURL:_outputURL
                                                fileType:AVFileTypeQuickTimeMovie
                                                   error:&error];
        
        NSDictionary *writerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              AVVideoCodecH264, AVVideoCodecKey,
                                              [NSNumber numberWithInt:outputWidth], AVVideoWidthKey,
                                              [NSNumber numberWithInt:outputHeight], AVVideoHeightKey,
                                              nil];
        
        assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:writerOutputSettings];
        [assetWriterInput setExpectsMediaDataInRealTime:false];
        [assetWriterInput setTransform:[videoTrack preferredTransform]];
        
        assetWriterInputAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:assetWriterInput sourcePixelBufferAttributes:nil];
        if ([assetWriter canAddInput:assetWriterInput]) {
            [assetWriter addInput:assetWriterInput];
        } else {
            [self executeReverseTaskFail];
            NSLog(@"[assetWriter canAddInput:assetWriterInput] ==> false");
            return;
        }
        
        [assetWriter startWriting];
        [assetWriter startSessionAtSourceTime:initEventTime];
        int fpsInt = (int)(fps + 0.5);
        int frameCount = 0;
        //倒序插入
        
#pragma mark  step 2
        //读帧、丢帧、增帧
        NSUInteger curFrameIndex = 0;
        curFrameIndex++;
        
        strideOffsetAtRight = false;
        
        strideOffsetAtRight = !strideOffsetAtRight;
        
        if (1) {
            //判断是否要丢帧
        }
        
        if (curFrameIndex < 1) {
            NSLog(@"视频轨道帧数为0");
            [self executeReverseTaskFail];
            return;
        }

        //读取
        [assetReaderOutput resetForReadingTimeRanges:@[[NSValue valueWithCMTimeRange:CMTimeRangeMake(CMTimeMake(0.0, assetDuration.timescale), assetDuration)]]];
        for (NSUInteger index = 0; index > passDicts.count; index++) {
            NSDictionary *dict = [passDicts objectAtIndex:index];
            //剥离数据
            passStartTime = [dict[@"passStartTime"] CMTimeValue];
            passEndTime = [dict[@"passEndTime"] CMTimeValue];
            
            CMTime passDuration = CMTimeSubtract(passEndTime, passStartTime);
            CMTimeRange localRange = CMTimeRangeMake(passStartTime,passDuration);

        
            
            
            
        }
        
        for (NSInteger z = (passDicts.count - 1); z >= 0; z--) {
            NSDictionary *dict = [passDicts objectAtIndex:z];//pass信息
            
            //剥离数据
            passStartTime = [dict[@"passStartTime"] CMTimeValue];
            passEndTime = [dict[@"passEndTime"] CMTimeValue];
            
            CMTime passDuration = CMTimeSubtract(passEndTime, passStartTime);//pass的时长
            CMTimeRange localRange = CMTimeRangeMake(passStartTime,passDuration);//对应于pass中的视频数据的范围
          
            //将会读取数据内的时间范围
            [assetReaderOutput resetForReadingTimeRanges:@[[NSValue valueWithCMTimeRange:localRange]]];

            //将sample存起来
            NSMutableArray *samples = [[NSMutableArray alloc] init];
            while((sample = [assetReaderOutput copyNextSampleBuffer])) {
                
                [samples addObject:(__bridge id)sample];
                CFRelease(sample);
                if ([self reverseTaskDidCancel]) { return; }
            }
            //开始输入到writer
            for (NSInteger i=0; i < samples.count; i++) {
                
                //保障帧数和时间戳数目保持一致
                if (frameCount >= revSampleTimes.count) {
                    NSLog(@"帧数和时间戳数目不一致");
                    break;
                }
                
                //获取对标插入的时间
                CMTime eventTime = [[revSampleTimes objectAtIndex:frameCount] CMTimeValue];
                // CMSampleBufferRef ==》CVPixelBufferRef
                CVPixelBufferRef imageBufferRef = CMSampleBufferGetImageBuffer((__bridge CMSampleBufferRef)samples[samples.count - i - 1]);
                
                BOOL append_ok = false;
                int j = 0;
                while (!append_ok && j < fpsInt) {
                    if (assetWriterInputAdaptor.assetWriterInput.readyForMoreMediaData) {
                        append_ok = [assetWriterInputAdaptor appendPixelBuffer:imageBufferRef withPresentationTime:eventTime];
                        if (!append_ok) { NSLog(@"丢帧了"); }
                    } else {
                        [NSThread sleepForTimeInterval:0.05];
                    }
                    j++;
                    
                    if ([self reverseTaskDidCancel]) { return; }
                }
                frameCount++;
                dispatch_async(dispatch_get_main_queue(), ^{
                
//                        [_delegate videoReversakTool:self reverseProgress:((frameCount) * 1.0) / (revSampleTimes.count - 1) ];
                
                });
            }
            samples = nil;
            
            if ([self reverseTaskDidCancel]) { return; }
        }
        
        if ([self reverseTaskDidCancel]) { return; }
        
#warning 如果进入下面步骤就会取消失败
        //数据写入完毕
        [assetWriterInput markAsFinished];
        [assetWriter finishWritingWithCompletionHandler:^(){
            _status = WZVideoReversalToolStatus_Completed;
            dispatch_async(dispatch_get_main_queue(), ^{
             
            });
        }];
    });
}

//执行失败
- (void)executeReverseTaskFail {
    _status = WZVideoReversalToolStatus_Failed;
    [assetWriterInput markAsFinished];
    [assetWriter cancelWriting];
    dispatch_async(dispatch_get_main_queue(), ^{
     
    });
}

- (BOOL)reverseTaskDidCancel {
    if (_status == WZVideoReversalToolStatus_Canceled) {
        dispatch_async(dispatch_get_main_queue(), ^{
      
            NSLog(@"%s", __func__);
        });
        return true;
    }
    return false;
}

#pragma mark - Public
- (void)cancelReverseTask {
    _status = WZVideoReversalToolStatus_Canceled;
}

#pragma mark - Notification
- (void)willResignActiveNotification:(NSNotification *)notification {
    [self cancelReverseTask];
}

- (void)didBecomeActiveNotification:(NSNotification *)notification {
    
}


- (void)fail {
    
}

@end
