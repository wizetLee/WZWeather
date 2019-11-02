//
//  WZCamera.m
//  WZGIF
//
//  Created by wizet on 2017/7/23.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZCamera.h"
#import "WZOrientationMonitor.h"
#import "WZCamera+Utility.h"
#define WZCAMERA_SESSION_QUEUE_KEY @"WZCameraSessionQueueKey"
#define WZCAMERA_VIDEO_MAX_RECORD_TIME 10.0

/**
 相机使用配置顺序：
 session 添加 设备的输入  和输入
 设备的输入和输入与设备的类型相关（前 后 麦克风）
 预设设备的格式、针对设备格式的约束参数范围内进行进一步的配置
 配置输出的连接 参数
 */
/**
 AVCaptureSessionPresetInputPriority 代表 capture session 不去控制音频与视频输出设置。而是通过已连接的捕获设备的 activeFormat 来反过来控制 capture session 的输出质量等级。
 可控参数有：
 闪光灯 手电筒 白平衡 控制焦距 ...
 
 */
@interface WZCamera()<WZOrientationProtocol,
WZTimeSuperviserDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate,
AVCaptureAudioDataOutputSampleBufferDelegate,
AVCaptureMetadataOutputObjectsDelegate,
WZMovieWriterProtocol
>

@property (nonatomic, copy) WZCameraRecordingBlock didStartRecordingBlock;//开始录制回调
@property (nonatomic, copy) WZCameraRecordingBlock didFinishRecordingBlock;//结束录制回调
@property (nonatomic, strong) WZOrientationMonitor *orientationMonitor;//方向检测
@property (nonatomic, strong) dispatch_queue_t __nonnull sessionQueue;//串行队列

@property (nonatomic, assign) CMTime timeOffset;//录制的偏移CMTime
@property (nonatomic, assign) CMTime lastVideo;//记录上一次视频数据文件的CMTime
@property (nonatomic, assign) CMTime lastAudio;//记录上一次音频数据文件的CMTime
@property (nonatomic, assign) BOOL interrupted;//中断判断
@property (nonatomic, assign) BOOL restricted;//录像极限判断
@property (nonatomic, assign) BOOL oneMore;//录像极限判断
@property (nonatomic, assign) CMTime startTime;//开始录制的时间
@property (nonatomic, assign) CGFloat currentRecordTime;//当前录制时间

@end

@implementation WZCamera

@synthesize sessionPreset = _sessionPreset;

- (instancetype)init {
    if (self = [super init]) {
        _videoRecordRestrictTime = WZCAMERA_VIDEO_MAX_RECORD_TIME;
        //设备方向判定
        _orientationMonitor = [[WZOrientationMonitor alloc] initWithDelegate:self];
        [_orientationMonitor startMonitor];
        
        //设置预览层  需要自定义位置大小
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspect; // 设置预览时的视频缩放方式
        if ([_previewLayer.connection isVideoOrientationSupported]) {//设置视频的朝向
            [[_previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionWasInterruptedNotification:) name:AVCaptureSessionWasInterruptedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionInterruptionEndedNotification:) name:AVCaptureSessionInterruptionEndedNotification object:nil];
        //    AVCaptureSessionWasInterruptedNotification//
        //    AVCaptureSessionInterruptionEndedNotification
    }
    return self;
}

- (void)dealloc {
    if (_orientationMonitor) {[_orientationMonitor stopMonitor];};
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 方向代理 WZOrientationProtocol
- (void)orientationMonitor:(WZOrientationMonitor *)monitor change:(UIDeviceOrientation)change {
    NSLog(@"%ld", change);
}

#pragma mark - 计时器代理 WZTimeSuperviserDelegate
- (void)timeSuperviser:(WZTimeSuperviser *)timeSuperviser currentTime:(NSTimeInterval)currentTime {
    
}

- (void)timeSuperviserStop {
    
}

#pragma mark - 二维码扫描代理 人脸识别 AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if ([metadataObjects count]) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result;
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            result = metadataObj.stringValue;
            NSLog(@"得到扫描结果 %@", result);
        } else {
            NSLog(@"不是二维码");
        }
    }
    
    //定义了多个用于描述被检测到人脸的属性
//    AVMetadataFaceObject *faceObject = nil;
//    if (faceObject.hasRollAngle) {//人脸倾斜角
//        faceObject.rollAngle;//查询前需要判断
//    }
//    if (faceObject.hasYawAngle) {//人脸偏转角
//        faceObject.yawAngle;//查询前需要判断
//    }
//    faceObject.bounds;//人脸便边界
}

#pragma mark - 视频录制代理 AVCaptureFileOutputRecordingDelegate
//开始录制
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    NSLog(@"开始录制");
    if (_didStartRecordingBlock) {
        _didStartRecordingBlock(fileURL, nil);
    }
}

////结束录制
//- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
//    if (_didFinishRecordingBlock) {
//        _didFinishRecordingBlock(outputFileURL, error);
//    }
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFileURL.path]) {
//        WZRecordSegment *segment = [[WZRecordSegment alloc] init];
//        segment.url = outputFileURL;
//        //保存每次录制的视频段
//        @property (nonatomic, strong) NSMutableArray <WZRecordSegment *>*videoRecordSegmentMArr;
////        [_videoRecordSegmentMArr addObject:segment];
//        NSLog(@"录制的视频的的段数 %@", _videoRecordSegmentMArr);
//        for ( WZRecordSegment *tmpSegment in _videoRecordSegmentMArr) {
//            NSLog(@"tmpSegment.url %@", tmpSegment.url);
//        }
//    }
//    
//    if (error) {
//        NSLog(@"%@",error.debugDescription);
//        //文件保存一次
//    }
//}

//- (void)resetSegemntContainer {
//    _videoRecordSegmentMArr = [NSMutableArray array];
//}

#pragma mark - 视频样本 音频样本 代理 自区分视音频 AVCaptureVideoDataOutputSampleBufferDelegate AVCaptureAudioDataOutputSampleBufferDelegate
//输出样本buffer
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
 
   dispatch_async(dispatch_get_main_queue(), ^{
       if ([_delegate respondsToSelector:@selector(bufferImage:)]) {
           UIImage *image = [WZCamera dealSampleBuffer:sampleBuffer];
           [_delegate bufferImage:image];
       }
   });
    
    if (captureOutput == self.audioDataOutput) {
        //音频类型（编码AAC）
        
    } else if (captureOutput == self.videoDataOutput) {
        //视频类型（编码H.264）
        
        //    NSLog(@"----------------");
        //    NSLog(@"connection.inputPorts:%@", connection.inputPorts);
        //    connection.enabled = false;//停止捕获输出流
        //        _imageView.image = sampleImage;
        //获取样本的图片
        //            UIImage *sampleImage = [[self class] imageFromSamplePlanerPixelBuffer:sampleBuffer];
        //            //    NSLog(@"%@", sampleImage);
        //            //    sampleImage.imageOrientation =
        //            sampleImage = [[self class] imageRotatedByDegrees:90 withimage:sampleImage];
    }

 [self handleSampleBuffer:sampleBuffer];
}

//丢失的帧
- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection NS_AVAILABLE(10_7, 6_0) {
//    NSLog(@"丢帧啦~~~~~");
}

//配置设备
- (NSError *)device:(AVCaptureDevice *)device configuration:(void (^)())config {
    NSError *error = nil;
    if (config) {
        BOOL lockAcquired = [device lockForConfiguration:&error];
        if (!lockAcquired) {
            return error;
        } else {
            config();
            [device unlockForConfiguration];
        }
    } else {
        return error = [NSError errorWithDomain:@"未实现config闭包" code:-1 userInfo:nil];
    }
    return error;
}

#pragma mark - 视频写入代理 WZMovieWriterProtocol
- (void)movieWriter:(WZMovieWriter *)movieWriter finishWritingWithError:(NSError *)error MovieOutputURL:(NSURL *)movieOutputURL {
   if ([_delegate respondsToSelector:@selector(movieWriter:finishWritingWithError:MovieOutputURL:)]) {
       [_delegate movieWriter:self.movieWriter finishWritingWithError:error MovieOutputURL:movieOutputURL];
   }
}

- (void)movieWriter:(WZMovieWriter *)movieWriter interruptedWithError:(NSError *)error {
    //录制被中断 恢复UI未录制前的状态
    //中断录制
    [self stopRecord];
    if ([_delegate respondsToSelector:@selector(movieWriter:interruptedWithError:)]) {
        [_delegate movieWriter:movieWriter interruptedWithError:error];
    }
}

#pragma mark - 处理样本 Process Smaple Buffer
- (void)handleSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    //状态为录制状态时才进行录制
    if (_recordStatus == WZCameraRecordStatusLeisure
        || _recordStatus == WZCameraRecordStatusPause
        || _restricted) {
        //非录像状态直接return;
        return;
    }
    
    BOOL isVideo = true;
    //先判断buffer类型
    CMFormatDescriptionRef formatDesc =
    CMSampleBufferGetFormatDescription(sampleBuffer);
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDesc);
    if (mediaType == kCMMediaType_Video) {
    } else if (mediaType == kCMMediaType_Audio) {
        isVideo = false;
    }
    
    {//录制中断处理
        @synchronized (self) {
            if (_interrupted) {
                if (isVideo) {
                    return;
                }
                
                _interrupted = false;
                
                //计算暂停的时间
                CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);//获取到捕获到buffer的时间
                NSLog(@"%lf", CMTimeGetSeconds(pts));
                
                CMTime last = isVideo ? _lastVideo : _lastAudio;
                if (last.flags & kCMTimeFlags_Valid) {
                    if (_timeOffset.flags & kCMTimeFlags_Valid) {
                        pts = CMTimeSubtract(pts, _timeOffset);
                    }
                    CMTime offset = CMTimeSubtract(pts, last);
                    if (_timeOffset.value == 0) {
                        _timeOffset = offset;
                    }else {
                        _timeOffset = CMTimeAdd(_timeOffset, offset);
                    }
                }
                _lastVideo.flags = 0;
                _lastAudio.flags = 0;
            }
            
            // 增加sampleBuffer的引用计,这样我们可以释放这个或修改这个数据，防止在修改时被释放
            CFRetain(sampleBuffer);
            if (_timeOffset.value > 0) {
                CFRelease(sampleBuffer);
                //根据得到的timeOffset调整
                sampleBuffer = [self adjustTime:sampleBuffer by:_timeOffset];
            }
            
            // 记录暂停上一次录制的时间
            CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            CMTime dur = CMSampleBufferGetDuration(sampleBuffer);
            if (dur.value > 0) {
                pts = CMTimeAdd(pts, dur);
            }
            if (isVideo) {
                _lastVideo = pts;
            }else {
                _lastAudio = pts;
            }
        }
        
        CMTime dur = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        if (self.startTime.value == 0) {
            self.startTime = dur;
        }
#pragma mark - 录制的总时间的计算
        CMTime sub = CMTimeSubtract(dur, self.startTime);
     
        self.currentRecordTime = CMTimeGetSeconds(sub);
        if (self.currentRecordTime < _videoRecordRestrictTime) {
        
        } else {
            if (_oneMore) {
                _oneMore = false;
            } else {
                _restricted = true;
                CFRelease(sampleBuffer);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_delegate respondsToSelector:@selector(recordRestrict)]) {
                        [_delegate recordRestrict];
                    }
                });
                
                return;
            }
        }
        NSLog(@"录制时间：%lf", CMTimeGetSeconds(sub));
        //回调当前的录制时间
       
        
    }
    
    [self.movieWriter handleSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);
}

//调整媒体数据的时间
- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset {
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++) {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

- (void)handleVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer connection:(AVCaptureConnection *)connection {
    
    //Base type for all CoreVideo image buffers
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    //在与CVPicelBuffer 交互之前 必须要获得一个响应内存块的锁
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
//    {//数据交互
//        size_t width = CVPixelBufferGetWidth(imageBuffer);
//        size_t height = CVPixelBufferGetHeight(imageBuffer);
//        
//        //获取像素buffer的基址指针
//        unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
//        
//        unsigned char grayPixel;//灰色像素
//        for (int i = 0; i < width; i++) {//遍历行高
//            for (int j = 0; i < height; j++) {
//                grayPixel = (pixel[0] + pixel[1] + pixel[2]) / 3.0;//RGB像素灰度平均1
//                pixel[0] = pixel[1] = pixel[2] = grayPixel;//
//                pixel += 4;//内存地址变更  bytes per pixel
//            }
//        }
//    }
    
    //释放锁
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    
    //可访问样本的格式信息  含有媒体样本的更多细节
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
//    {
//        CMVideoFormatDescriptionRef videoFormatDescription;
//        CMAudioFormatDescriptionRef audioFormatDescription;
//        CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDescription);
//        if (mediaType == kCMMediaType_Video) {
//            CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//            //处理视频数据
//        } else if (mediaType == kCMMediaType_Audio) {
//            CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
//            //处理音频数据
//        }
//    }
    
//    {//时间信息
//        CMTime timeStamp;
//        //原始的表示时间戳
//        CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//        //输出的表示时间戳
//        CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
//        
//        //解码时间戳
//        CMSampleBufferGetDecodeTimeStamp(sampleBuffer);
//        //输出的解码时间戳
//        CMSampleBufferGetOutputDecodeTimeStamp(sampleBuffer);
//        
//        //    NSLog(@"1:%lf 2:%lf  3:%lf  4:%lf", CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) , CMTimeGetSeconds(CMSampleBufferGetDecodeTimeStamp(sampleBuffer)), CMTimeGetSeconds(CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)) ,CMTimeGetSeconds(CMSampleBufferGetOutputDecodeTimeStamp(sampleBuffer)));
//    }

    
    {//附加的元数据  Attachment:附加的  bearer
//        CMAttachmentBearerRef
        
        //如：可交换图片文件格式（Exif）标签
//         CFDictionaryRef exifAttachments = (CFDictionaryRef)CMGetAttachment(sampleBuffer, kCGImagePropertyExifDictionary, NULL);
//        
    }
    
    //配置输出size 根据比例配置
    
    CGSize outputSize = CGSizeMake(480, 640);
    //压缩设置比率
    //bitrate = 6000000;
    unsigned long bitrate = 500000;//640
    bitrate = 1000000;//1280
//    bitrate = 6000000;//1920
    NSMutableDictionary *compressionSettings = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:bitrate] forKey:AVVideoAverageBitRateKey];
    [compressionSettings setValue:@(1) forKey:AVVideoMaxKeyFrameIntervalKey];
    [compressionSettings setValue:AVVideoProfileLevelH264HighAutoLevel forKey:AVVideoProfileLevelKey];
    //    [compressionSettings setObject:@30 forKey:AVVideoAverageNonDroppableFrameRateKey];
    [compressionSettings setValue:@(false) forKey:AVVideoAllowFrameReorderingKey];
    //    [compressionSettings setObject:AVVideoH264EntropyModeCABAC forKey:AVVideoH264EntropyModeKey];
    [compressionSettings setValue:@(30) forKey:AVVideoExpectedSourceFrameRateKey];
    
    NSMutableDictionary *videoSettings = [NSMutableDictionary dictionary];
    [videoSettings setValue:compressionSettings forKey:AVVideoCompressionPropertiesKey];
    [videoSettings setValue:AVVideoCodecH264 forKey:AVVideoCodecKey];//编码 解码 格式
    [videoSettings setValue:AVVideoScalingModeResizeAspect forKey:AVVideoScalingModeKey];//比例mode
    [videoSettings setValue:@(outputSize.width) forKey:AVVideoWidthKey];//宽度
    [videoSettings setValue:@(outputSize.height) forKey:AVVideoHeightKey];//高度
    
//    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    //配置像素参数
    //规模
//    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
//    NSDictionary *pixelBufferAttributes = @{
//                                            (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
//                                            (id)kCVPixelBufferWidthKey : [NSNumber numberWithInt:dimensions.width],
//                                            (id)kCVPixelBufferHeightKey : [NSNumber numberWithInt:dimensions.height]
//                                            };
    
//    NSError *error = nil;
//    @try {
//        AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings sourceFormatHint:formatDescription];
//        //写进文件里面
//        AVAssetWriterInputPixelBufferAdaptor *dadptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:pixelBufferAttributes];
//    } @catch (NSException *exception) {
//        error = WZERROR(exception.reason);
//    }
    
    
    
}

- (void)handleAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer connection:(AVCaptureConnection *)connection {
    
}


//配置会话
- (void)configurationSession:(void (^)())config {
    if (config) {
        [self.session beginConfiguration];//开始配置
        config();
        [self.session commitConfiguration];//提交配置
    }
}

#pragma mark - 开启镜头 关闭镜头
- (void)startRunning {
    [self.session startRunning];
}

- (void)stopRunning {
    [self.session stopRunning];
}

#pragma mark - 配置闪光灯 切换前后摄像头
//切换闪光灯
- (BOOL)flashOpen {
    BOOL boolean;
    AVCaptureDevice *backLens= self.backLensDevice;
    NSError *error = nil;
    if (backLens.flashMode == AVCaptureFlashModeOff) {
        [backLens lockForConfiguration:&error];
        backLens.flashMode = AVCaptureFlashModeOn;
        [backLens unlockForConfiguration];
    }
    if (!error) {
         boolean = true;
    }
    return boolean;
}
- (BOOL)flashClose {
    BOOL boolean;
    AVCaptureDevice *backLens= self.backLensDevice;
    NSError *error = nil;
    if (backLens.flashMode == AVCaptureFlashModeOn) {
        [backLens lockForConfiguration:&error];
        backLens.flashMode = AVCaptureFlashModeOff;
        [backLens unlockForConfiguration];
    }
    if (!error) {
        boolean = true;
    }
    return boolean;
}
//切换手电筒
- (BOOL)torchOpen {
    BOOL boolean;
    AVCaptureDevice *backLens= self.backLensDevice;
    NSError *error = nil;
    if (backLens.torchMode == AVCaptureTorchModeOff) {
        [backLens lockForConfiguration:&error];
        backLens.torchMode = AVCaptureTorchModeOn;
        [backLens unlockForConfiguration];
    }
    if (!error) {
        boolean = true;
    }
    return boolean;
}
- (BOOL)torchClose {
    BOOL boolean;
    AVCaptureDevice *backLens= self.backLensDevice;
    NSError *error = nil;
    if (backLens.torchMode == AVCaptureTorchModeOn) {
        [backLens lockForConfiguration:&error];
        backLens.torchMode = AVCaptureTorchModeOff;
        [backLens unlockForConfiguration];
    }
    if (!error) {
        boolean = true;
    }
    return boolean;
}

//切换镜头
- (BOOL)lensFront {
    BOOL boolean;
    [self.session stopRunning];
    [self.session removeInput:self.backCameraInput];
    if ([self.session canAddInput:self.frontCameraInput]) {
        [self.session addInput:self.frontCameraInput];
        boolean = true;
    }
    return boolean;
}

- (BOOL)lensBack {
    BOOL boolean;
    [self.session stopRunning];
    [self.session removeInput:self.frontCameraInput];
    if ([self.session canAddInput:self.backCameraInput]) {
        [self.session addInput:self.backCameraInput];
        boolean = true;
    }
    return boolean;
}

#pragma mark - 开始录像 暂停录像 停止录像————读写buffer
- (void)startRecord {
    [self resetRecordStatue];
    
    //拍摄时 注意方向的问题
    AVCaptureVideoOrientation orientation = [[self class] captureVideoOrientationRelyDeviceOrientation:_orientationMonitor.orientation];
    //设置输出连接方向
//#warning - !!!!Need Alter   设置录像的镜头方向的时候会有一丝卡顿
    if ([self.videoConnection isVideoOrientationSupported]) {
        [self.videoConnection setVideoOrientation:orientation];
    }
   
    _recordStatus = WZCameraRecordStatusRecording;
}

- (void)pauseRecord {
    _interrupted = true;
    _recordStatus = WZCameraRecordStatusPause;
}
//恢复录制
- (void)resumeRecord {
    _recordStatus = WZCameraRecordStatusRecording;
}

- (void)stopRecord {
    self.recordStatus = WZCameraRecordStatusStop;
    [self.movieWriter finishWriting];
}

- (void)resetRecordStatue {
    _timeOffset = CMTimeMake(0, 0);
    _startTime = CMTimeMake(0, 0);
    _lastVideo = CMTimeMake(0, 0);
    _lastAudio = CMTimeMake(0, 0);
    _currentRecordTime = 0.0;
    _interrupted = false;
    _restricted = false;
    _oneMore = true;
    
    //deal：
    //判断上一个视频要不要保存
    
    _movieWriter = nil;
}

//开始录像
#pragma mark - 录像 ————使用MovieFileOutput
//- (BOOL)canRecordingMovieFile {
//    if ([self.session.outputs containsObject:self.movieFileOutput]) {
//        return true;
//    }
//    return false;
//}

//- (void)recordMovieFileWithDidStartRecordingBlock:(WZCameraRecordingBlock)didStartRecordingBlock didFinishRecordingBlock:(WZCameraRecordingBlock)didFinishRecordingBlock {
//
//    _didStartRecordingBlock = didStartRecordingBlock;
//    _didFinishRecordingBlock = didFinishRecordingBlock;
//    
//    if (!self.session.isRunning) {
//        [self.session startRunning];
//    }
//    
//    if ([self.movieFileConnection isVideoOrientationSupported]) {
//        self.movieFileConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
//    }
//    
//    //检查连接是否可用 因为可能设置了 AVCaptureSessionPresetPhoto 类型 不兼容 video
//    if (!self.movieFileConnection.active) {
//        if ([self.session canSetSessionPreset:self.sessionPreset]  ) {
//            [self.session setSessionPreset:self.sessionPreset];
//        }
//    }
//    
//    //判断通过用户能否能使用输出
//    if (self.movieFileConnection.active) {
//        //        Float64 TotalSeconds = 30;  //限制拍照时间
//        //        int32_t preferredTimeScale = 30;    //Frames per second 设置fps
//        //        CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);
//        //        _movieFileOutput.maxRecordedDuration = maxDuration;
//        //        _movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
//        [[NSFileManager defaultManager] removeItemAtPath:self.recordOutputFileURL.path error:nil];
//        [self.movieFileOutput startRecordingToOutputFileURL:self.recordOutputFileURL recordingDelegate:(id<AVCaptureFileOutputRecordingDelegate>)self];
//    } else {
//        NSLog(@"connection.active == false 不可使用输出数据");
//    }
//}

//- (void)stopRecordMovieFile {
//    if ([self.movieFileOutput isRecording]) {
//        [self.movieFileOutput stopRecording];
//    }
//}

#pragma mark - 拍照
- (void)takePhoto:(void (^)(UIImage * image, NSError *error))imageHandler {
    if (!self.session.isRunning) {
        [self.session startRunning];
    }

    if (imageHandler) {
        [self takePhotoWithOutput:_stillImageOutput
                deviceOrientation:_orientationMonitor.orientation
                     imageHandler:imageHandler];
    }
}


- (void)takePhotoWithOutput:(AVCaptureStillImageOutput *)output deviceOrientation:(UIDeviceOrientation)orientation imageHandler:(void (^)(UIImage * image, NSError *error))imageHandler {
    if (![output isKindOfClass:[AVCaptureStillImageOutput class]]) {
        return;
    }

    //连接级设置：输出连接
    AVCaptureConnection *connection = [output  connectionWithMediaType:AVMediaTypeVideo];
    AVCaptureVideoOrientation videoOrientation = [[self class] captureVideoOrientationRelyDeviceOrientation:orientation];
    //设置输出连接方向
    [connection setVideoOrientation:videoOrientation];
    //对摄像头的缩放：
//    [connection setVideoScaleAndCropFactor:1];//现在使用videoZoomFactor就可以达到控制缩放的目的
    
    if (!connection.active) {
        //预设更改
        if ([self.session canSetSessionPreset:self.sessionPreset]  ) {
            [self.session setSessionPreset:self.sessionPreset];
        }
    }
    
    if (connection.active) {
        
        [[self class] removeSystemSound:true];
        [output captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageHandler) {
                if (error) {
                    NSLog(@"%@", error.debugDescription);
                    imageHandler(nil, error);
                } else {
                    //处理样本数据
                    NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    
                    //                CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                    //                                                                            imageDataSampleBuffer,kCMAttachmentMode_ShouldPropagate);
                    //                NSDictionary *tmpDic = (__bridge NSDictionary*)attachments;
                    
                    UIImage *image = [UIImage imageWithData:data];
                    imageHandler(image, nil);
                }
            }
        }];
    } else {
        if (imageHandler) {
            imageHandler(nil, [NSError errorWithDomain:@"保存到相册失败, 输出连接不可用" code:-1 userInfo:nil]);
        }
    }
}

#pragma mark - 人脸识别 Core Image 框架 CIDetector CIFaceFeture

#pragma mark - 摄像头的缩放需要调用 lockForConfiguration: 来获取设备的配置属性的独占访问权限。 这将会自动把 capture session 的预设设置为 AVCaptureSessionPresetInputPriority。
- (void)deviceZoomFactor:(CGFloat)zoomFactor {
    self.frontLensDevice.videoZoomFactor = zoomFactor;
    //判断当前设备是前还是后
    CGFloat maxFactor = 0.0;
    if (self.currentLensDevice == self.backLensDevice) {
        maxFactor = self.backLensDevice.activeFormat.videoMaxZoomFactor;//后摄像头最大的缩放等级 缩放等级默认均为1
    } else if (self.currentLensDevice == self.frontLensDevice) {
        maxFactor = self.frontLensDevice.activeFormat.videoMaxZoomFactor;//前摄像头最大的缩放等级
    }
    //可用捕获设备的 activeVideoMinFrameDuration 和 activeVideoMaxFrameDuration 属性设置帧速率，一帧的时长是帧速率的倒数
    //为了确保帧速率恒定，可以将最小与最大的帧时长设置成一样的值
    //self.backLensDevice.activeVideoMinFrameDuration.value
    
    
    if (zoomFactor < 1.0) {
        zoomFactor = 1.0;
    }
    
    if (zoomFactor > maxFactor) {
        zoomFactor = maxFactor;
    }
    NSError *error = [self device:self.currentLensDevice configuration:^{
         [self.currentLensDevice setVideoZoomFactor:zoomFactor];
    }];
    if (error) {
        //缩放失败
        [WZToast toastWithContent:[NSString stringWithFormat:@"缩放失败:%@", error.description]];
    } else {
        //缩放成功
    }
    
    //决定了从哪个点开始放大图像
//    self.currentLensDevice.activeFormat.videoZoomFactorUpscaleThreshold;
    
}

#pragma mark - 配置FPS
///  value / timescale = 1 / 60  即 60FPS   CMTime frameDuration = CMTimeMake(1, 60);
- (void)configDevice:(AVCaptureDevice *)device frameDuration:(CMTime)frameDuration {
    NSError *error;
  
    NSArray *supportedFrameRateRanges = [device.activeFormat videoSupportedFrameRateRanges];
    BOOL frameRateSupported = false;
    for (AVFrameRateRange *range in supportedFrameRateRanges) {
        //一个比较CMTime的宏
        if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) &&
            CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            frameRateSupported = true;
        }
    }
    
    if (frameRateSupported && [device lockForConfiguration:&error]) {
        //为了确保帧速率恒定，可以将最小与最大的帧时长设置成一样的值
        [device setActiveVideoMaxFrameDuration:frameDuration];
        [device setActiveVideoMinFrameDuration:frameDuration];
        [device unlockForConfiguration];
    }
}

///返回与position关联的设备
- (AVCaptureDevice *)deviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}


#pragma mark - Accessor
- (void)setSessionPreset:(NSString *)sessionPreset {
    if ([sessionPreset isKindOfClass:[NSString class]]
        && self.sessionPreset.length == 0) {
        _sessionPreset = sessionPreset;
        if ([self.session canSetSessionPreset:sessionPreset]) {
            [self.session setSessionPreset:sessionPreset];
        } else {
            NSLog(@"%s%@", __func__, @"画质预设失败");
        }
    }
}


///设置了预想的设备格式，可以针对设备格式的约束参数范围内进行进一步的配置
- (NSString *)sessionPreset {
    if (![_sessionPreset isKindOfClass:[NSString class]]
        || _sessionPreset.length == 0) {
        return AVCaptureSessionPreset1920x1080;
    }
    return _sessionPreset;
}

//- (NSURL *)recordOutputFileURL {
//    NSError *error = nil;
//    NSString *videoDocumentPath = [[self class] videoRecordPath:&error];
//    if (error) {
//        NSLog(@"创建文件路径失败：%@", error.debugDescription);
//        return nil;
//    }
//    
//    NSURL *documentsDirURL = [NSURL fileURLWithPath:videoDocumentPath isDirectory:true];
//    //以录制时间为文件名字
//    _recordOutputFileURL = [documentsDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"wizetVideoFile%ld.mp4", _videoRecordSegmentMArr.count]];//以录制的段数为视频的名字
//    
//    return _recordOutputFileURL;
//}

///录制队列
- (dispatch_queue_t)sessionQueue {
    if (!_sessionQueue) {
        //默认配置
        _sessionQueue = dispatch_queue_create("WZCameraSessionQueue.wizet", DISPATCH_QUEUE_SERIAL);//char * 字符数组
        dispatch_queue_set_specific(_sessionQueue, WZCAMERA_SESSION_QUEUE_KEY, "true", nil);//设置特征
        dispatch_set_target_queue(_sessionQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
        // 第一个参数为要设置优先级的queue,第二个参数是参照物，既将第一个queue的优先级和第二个queue的优先级设置一样。
        //以上动作为保障拍视频的流畅性
    }
    return _sessionQueue;
}

///当前摄像头设备
- (AVCaptureDevice *)currentLensDevice {
    if (!_currentLensDevice) {
        _currentLensDevice = self.backLensDevice;
    }
    return _currentLensDevice;
}

///前摄像头设备
- (AVCaptureDevice *)frontLensDevice {
    if (!_frontLensDevice) {
        _frontLensDevice = [self deviceWithPosition:AVCaptureDevicePositionFront];
    }
    return _frontLensDevice;
}
///后摄像头设备
- (AVCaptureDevice *)backLensDevice {
    if (!_backLensDevice) {
        _backLensDevice = [self deviceWithPosition:AVCaptureDevicePositionBack];
    }
    return _backLensDevice;
}
///麦克风设备
- (AVCaptureDevice *)microphoneDevice {
    if (!_microphoneDevice) {
        _microphoneDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    }
    return _microphoneDevice;
}

///捕获后置摄像头输入
- (AVCaptureDeviceInput *)backCameraInput {
    if (!_backCameraInput) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.backLensDevice error:&error];
        if (error) {NSLog(@"获取后置摄像头失败");}
    }
    return _backCameraInput;
}

///捕获前置摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput {
    if (!_frontCameraInput) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.frontLensDevice error:&error];
        if (error) {NSLog(@"获取前置摄像头失败");}
    }
    return _frontCameraInput;
}

///捕获麦克风输入
- (AVCaptureDeviceInput *)audioMicInput {
    if (!_audioMicInput) {
        AVCaptureDevice *mic = self.microphoneDevice;
        NSError *error;
        _audioMicInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
        if (error) { NSLog(@"获取麦克风失败");}
    }
    return _audioMicInput;
}

///视频输出
- (AVCaptureVideoDataOutput *)videoDataOutput {
    if (!_videoDataOutput) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoDataOutput setSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)self queue:self.sessionQueue];
        //录制配置
        NSDictionary *settings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
        //PS:摄像头的初始格式为双平面420v  但是如果是用OpenGL ES时经常会选用BGRA，BGRA这一格式的转换会稍微牺牲一点性能
        
        _videoDataOutput.videoSettings = settings;
        
        //true：当前队列阻塞时总是跳帧处理   false：不跳帧，内存会显著增大
        _videoDataOutput.alwaysDiscardsLateVideoFrames = true;
        
    }
    return _videoDataOutput;
}

///音频输出
- (AVCaptureAudioDataOutput *)audioDataOutput {
    if (!_audioDataOutput) {
        _audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioDataOutput setSampleBufferDelegate:(id<AVCaptureAudioDataOutputSampleBufferDelegate>)self queue:self.sessionQueue];
        
    }
    return _audioDataOutput;
}

///相片输出
- (AVCaptureStillImageOutput *)stillImageOutput {
    if (!_stillImageOutput) {
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
     
    }
    return _stillImageOutput;
}

///二维码 条形码输出
- (AVCaptureMetadataOutput *)metadataOutput {
    if (!_metadataOutput) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:self.sessionQueue];
    }
    return _metadataOutput;
}

///视频文件输出
- (AVCaptureMovieFileOutput *)movieFileOutput {
    if (!_movieFileOutput) {
        _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    }
    return _movieFileOutput;
}

///视频连接
- (AVCaptureConnection *)videoConnection {
    if (!_videoConnection) {
        _videoConnection = [self.videoDataOutput  connectionWithMediaType:AVMediaTypeVideo];
//        AVCaptureVideoOrientation orientation = [[self class] captureVideoOrientationRelyDeviceOrientation:_orientationMonitor.orientation];
//        //设置输出连接方向
//        if ([_videoConnection isVideoOrientationSupported]) {
//            [_videoConnection setVideoOrientation:orientation];
//        }
    }
    return _videoConnection;
}
///音频连接
- (AVCaptureConnection *)audioConnection {
    if (!_audioConnection) {
        _audioConnection = [self.audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
    }
    return _audioConnection;
}

///文件连接
- (AVCaptureConnection *)movieFileConnection {
    if (!_movieFileConnection) {
        _movieFileConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([_movieFileConnection isVideoStabilizationSupported]) {//录制的稳定
            _movieFileConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;//基于格式和帧速率自动匹配模式
        }
    }
    return _movieFileConnection;
}

///会话
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        //输入
        if ([_session canAddInput:self.audioMicInput]) {
            [_session addInput:self.audioMicInput];
        }
        if ([_session canAddInput:self.backCameraInput]) {//默认后置摄像头
            [_session addInput:self.backCameraInput];
        }
        
        //输出
        if ([_session canAddOutput:self.audioDataOutput]) {
            [_session addOutput:self.audioDataOutput];
        }
        if ([_session canAddOutput:self.videoDataOutput]) {
            [_session addOutput:self.videoDataOutput];
        }
       
#warning We can not set movieFileOut and dataOutput at the same time
//        if ([_session canAddOutput:self.movieFileOutput]) {
//            [_session addOutput:self.movieFileOutput];
//        }
        
        if ([_session canAddOutput:self.stillImageOutput]) {
            [_session addOutput:self.stillImageOutput];
        }
//        PS：有朋友遇到：当AVFoundation使用多译码器扫描的时候。二维码是秒杀，但是条形码却经常扫不上。如果去掉二维码的话，条形码扫描又秒杀的情况。
        if ([_session canAddOutput:self.metadataOutput]) {
            [_session addOutput:self.metadataOutput];
            
            //添加输出再设置 type 否则会崩溃
            //秒扫二维码 难以扫条形码
            if (self.metadataOutput.availableMetadataObjectTypes.count) {
                [self.metadataOutput setMetadataObjectTypes:@[
                                                              AVMetadataObjectTypeEAN13Code,
                                                              AVMetadataObjectTypeEAN8Code,
                                                              AVMetadataObjectTypeCode128Code,
                                                              AVMetadataObjectTypeQRCode]];//7.0

            }
            //            AVMetadataObjectTypeFace,//人脸识别
            
            //            //扫条形码
            //            [_metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeEAN13Code,
            //                                                      AVMetadataObjectTypeEAN8Code,
            //                                                      AVMetadataObjectTypeCode128Code]];
            //QR(Quick Response) 二维码的一种
            //EAN13Code EAN8Code Code128条形码
            //扫描范围设置
            //_metadataOutput.rectOfInterest =
        }
        
        //调整画质预设 默认是AVCaptureSessionPresetHigh;  预想的设备格式
        if ([_session canSetSessionPreset:self.sessionPreset]  ) {
            [_session setSessionPreset:self.sessionPreset];
        } AVCaptureVideoStabilizationMode stabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        
        
        //切换一次镜头就要设置一次
        //视频防抖
        if ([self.currentLensDevice.activeFormat isVideoStabilizationModeSupported:stabilizationMode]) {
            [self.videoConnection setPreferredVideoStabilizationMode:stabilizationMode];
        }
        
        //视频 HDR (高动态范围图像)
        [self device:self.currentLensDevice configuration:^{
             self.currentLensDevice.automaticallyAdjustsVideoHDREnabled = true;//留给系统处理;
            //        self.currentLensDevice.videoHDREnabled = false;//自行处理
        }];

    }
    return _session;
}

- (WZMovieWriter *)movieWriter {
    if (!_movieWriter) {
        
        NSString *fileType = AVFileTypeMPEG4;
        //配置输出参数  可以生成与 asset writer 兼容的带有全部键值对的字典。
        
        //GIF： 参数需要尽量设置得低
        //视频： 根据需求、UI更改
        //
        
        NSDictionary *videoSettings =
        [self.videoDataOutput
         recommendedVideoSettingsForAssetWriterWithOutputFileType:fileType];
        /**
         {
             AVVideoCodecKey = avc1;
             AVVideoCompressionPropertiesKey =     {
             AverageBitRate = 128000;
             ExpectedFrameRate = 15;
             MaxKeyFrameIntervalDuration = 1;
             Priority = 80;
             ProfileLevel = "H264_Baseline_3_0";
             RealTime = 1;
             };
             AVVideoHeightKey = 144;
             AVVideoWidthKey = 192;
         }
         */
        NSDictionary *audioSettings =
        [self.audioDataOutput
         recommendedAudioSettingsForAssetWriterWithOutputFileType:fileType];
        /**
         {
             AVEncoderBitRatePerChannelKey = 24000;
             AVFormatIDKey = 1633772320;
             AVNumberOfChannelsKey = 1;
             AVSampleRateKey = 22050;
         }
         */
        
        //或者使用AVOutputSettingsAssistant 进行配置  但会存在一些缺陷
        
        
//        NSDictionary *videoSettings2 = @{};
//        NSDictionary *audioSettings2 = @{};
        
//audio参数(常用)
//        AVFormatIDKey 写入内容的音频格式 如：kAudioFormatMPEG4AAC
//        AVSampleRateKey 采样率 8000  16000 22050 44100
//        AVNumberOfChannelsKey 通道数 1：单声道录制  2：立体声道录制（PS：除非使用外部硬件录制，否则通常应该创建单声道录音）
//        AVLinearPCMBitDepthKey 量化精度，决定数字音频的动态范围 常用:16、24~32为高质量
        
//        AVEncoderAudioQualityKey
//        AVEncoderBitDepthHintKey
        
//video参数
        
        
        //配置输出参数
        _movieWriter = [[WZMovieWriter alloc] initWithVideoSettings:videoSettings audioSettings:audioSettings  outputURL:nil];
        _movieWriter.delegate = self;
    }
    return _movieWriter;
}

#pragma mark - 配置录制的视频保存的路径
+ (NSString *)videoRecordPath:(NSError **)error {
    //输出路径配置
    NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *doucmentStr =[document objectAtIndex:0];
    NSString *videoDocumentPath = [doucmentStr stringByAppendingString:@"/video"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoDocumentPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDocumentPath withIntermediateDirectories:true attributes:nil error:error];
    }
    
    return videoDocumentPath;
}

#pragma mark - 设置文件名
- (NSURL *)fileURL:(NSError **)error {
    
    NSString *extension = [self suggestedFileExtensionAccordingEncodingFileType:AVFileTypeMPEG4];
    
    if (extension != nil && extension.length) {
        //文件需要设定一系列的标志
        NSString *filename = [NSString stringWithFormat:@"WZCameraVideo特定标志.%@", extension];
        
        //设定存储位置
        NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        NSURL *fileURL = [NSURL fileURLWithPath:myPathList.firstObject];
        fileURL = [fileURL URLByAppendingPathComponent:filename];//配置 文件名字+后缀
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
            [[NSFileManager defaultManager] removeItemAtPath:fileURL.path error:nil];
            
        }
        return fileURL;
        
    } else {
        if (error != nil) {
            *error = [NSError errorWithDomain:@"文件扩展后缀为空" code:-1 userInfo:nil];
        }
        return nil;
    }
}


#pragma mark - 中断处理
- (void)interruptedDealing {

}
- (void)willResignActiveNotification:(NSNotification *)notification {
    NSLog(@"%s", __func__);
    //暂停
    [self stopRecord];//保存下来！
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

@end
