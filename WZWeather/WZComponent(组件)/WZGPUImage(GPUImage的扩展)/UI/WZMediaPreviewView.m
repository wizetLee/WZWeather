//
//  WZMediaPreviewView.m
//  WZWeather
//
//  Created by 李炜钊 on 2017/11/4.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaPreviewView.h"
#import "WZGPUImagePreinstall.h"
#import <Vision/Vision.h>

#define MovieFolderName @"WZ_movieFolder"

@interface WZMediaPreviewView()<GPUImageVideoCameraDelegate>

@property (nonatomic, strong) GPUImageStillCamera *cameraStillImage;//静态图采样
@property (nonatomic, strong) GPUImageVideoCamera *cameraVideo;//录像采样

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;//录像机
@property (nonatomic,   weak) GPUImageOutput <GPUImageInput >* trailingOutput;

///用于人脸识别
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) NSMutableDictionary <NSString*, UIView *>*faceMap;

@property (nonatomic, strong) NSString *curRecordingName;//当前正在录制的视频/或是上一次录制好的视频的名字 需要配合上路径访问视频
@property (nonatomic, strong) NSMutableArray *moviesNameMarr;//存名字   URL为 相对路径+名字

@property (nonatomic, assign) CMTime recordStartTime;//开始录制的事件(output sample 的时间)
@property (nonatomic, assign) CMTime recordTotalTime;//一共录制了多少时间

@end

@implementation WZMediaPreviewView

- (instancetype)init {
    if (self = [super init]) {
        [self config];
        [self createViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
        [self createViews];
    }
    return self;
}

- (void)dealloc {
    _cameraVideo.audioEncodingTarget = nil;
    [_cropFilter removeAllTargets];
    [_insertFilter removeAllTargets];
    [_scaleFilter removeAllTargets];
    [_cameraVideo removeAllTargets];
    [_trailingOutput removeAllTargets];
    [_cameraStillImage removeAllTargets];
    NSLog(@"%s",__func__);
}

#pragma mark - Private
- (void)config {
    _faceMap = [NSMutableDictionary dictionary];
    _moviesNameMarr = [NSMutableArray array];
    _timeScaleMArr = [NSMutableArray array];
    _mediaType = WZMediaTypeStillImage;
    _recordStartTime = kCMTimeZero;
    _recordTotalTime = kCMTimeZero;
#warning 最好提前创建好的目录 不然我也不知道会发生什么错误.... 使用懒加载会出现过崩溃的情况
    [[NSFileManager defaultManager] removeItemAtPath:[NSObject wz_filePath:WZSearchPathDirectoryDocument fileName:MovieFolderName] error:nil];
    [NSObject wz_createFolderAtPath:[NSObject wz_filePath:WZSearchPathDirectoryDocument fileName:MovieFolderName]];
    
}

#warning 除非在低分辨率的情况下 才可不停地修改此值， 因为GPUImage内部有做键值对缓存 或者修改源码... 另外的contex单例中的缓存是比较大的 可以考虑适时释放掉那个缓存
- (void)setCropValue:(CGFloat)value {
    //停止所有渲染的动作
    __weak typeof(self) weakSelf = self;
    runSynchronouslyOnVideoProcessingQueue(^{
        
        NSArray *tmpArr = weakSelf.cropFilter.targets;
        [weakSelf.cropFilter removeAllTargets];
        
        [weakSelf.cameraCurrent resetBenchmarkAverage];
        [weakSelf.cropFilter setCropRegion:CGRectMake(0.0, 0.0, 1.0, value)];
        
        for (GPUImageFilter *filter in tmpArr) {
            [weakSelf.cropFilter addTarget:filter];
        }
    });
}

- (void)pickStillImageWithHandler:(void (^)(UIImage *image))handler {

    
//    _cropFilter.outputFrameSize = CGSizeMake(CGFloat width, CGFloat height)
    //自己的图片的大小

//步骤：
//    更换size输出的Size
//    完成后切换回去原来的size
    
    ///先取消缩小比例的滤镜
    __weak typeof(self) weakSelf = self;
    
    GPUImageOutput <GPUImageInput> *tmpFilter = weakSelf.insertFilter;
    if (!tmpFilter) {
        tmpFilter = _cropFilter;
    }

    [_cameraStillImage capturePhotoAsImageProcessedUpToFilter:tmpFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if (handler) {
            handler(processedImage);
        }
       
//        weakSelf.cameraStillImage.currentCaptureMetadata;//照片信息
    }];
}

//MARK:临时插入一个滤镜到镜头链中
- (void)insertRenderFilter:(GPUImageFilter *)filter {
    [_cropFilter removeTarget:_scaleFilter];
    [_trailingOutput removeAllTargets];
    __weak typeof(self) weakSelf = self;
    runSynchronouslyOnVideoProcessingQueue(^{
        
        if (weakSelf.insertFilter) {
            [weakSelf.cropFilter removeTarget:weakSelf.insertFilter];
            [weakSelf.insertFilter removeTarget:weakSelf.scaleFilter];
        }
        
        [weakSelf.cameraCurrent resetBenchmarkAverage];
        weakSelf.insertFilter = filter;
        [weakSelf.cropFilter addTarget:weakSelf.insertFilter];
        [weakSelf.insertFilter addTarget:weakSelf.scaleFilter];
        weakSelf.trailingOutput = filter;
    });

}

- (void)createViews {
    [self addSubview:self.presentView];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _presentView.frame = self.bounds;
}

#pragma mark - GPUImageVideoCameraDelegate
///都是图像的采样
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    [self calculateTimeWith:sampleBuffer];
    
    /// Vision 视觉库的代码
//    if (@available(iOS 11.0, *)) {
//        /*
//         大致流程
//             1、创建不同的request
//             2、生成handler 用以执行request 产生回调
//             3、处理回调结果
//         */
//
//        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//
//        //创建请求句柄
//        VNImageRequestHandler *detectRequestHandler = [[VNImageRequestHandler alloc]initWithCVPixelBuffer:pixelBuffer options:@{}];
//
//        // 探测脸部矩形请求
//        VNDetectFaceRectanglesRequest *detectRequest = [[VNDetectFaceRectanglesRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
//            //回调
//            NSArray *observations = request.results;
//            //监测数据
//            for (VNFaceObservation *observation  in observations) {
//                //位置 尺寸 转换
//                CGSize imageSize = CVImageBufferGetDisplaySize(pixelBuffer);
//                CGRect faceRect = [[self class] convertRect:observation.boundingBox imageSize:imageSize];
//
//                static UIView *tmpView;
//                if (tmpView) {
//                    tmpView.frame = faceRect;
//                } else {
//                    tmpView = [[UIView alloc] init];
//                    tmpView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
//                    [self addSubview:tmpView];
//                    tmpView.frame = faceRect;
//                }
//
//                //精确数据的计算
//                VNFaceLandmarks2D *faceLandmark2D = observation.landmarks;
//
//                NSMutableArray <VNFaceLandmarkRegion2D *>*pointArray = [NSMutableArray array];
//                [pointArray addObject:faceLandmark2D.allPoints];
//                [pointArray addObject:faceLandmark2D.faceContour];
//
//                [pointArray addObject:faceLandmark2D.leftEye];
//                [pointArray addObject:faceLandmark2D.rightEye];
//
//                [pointArray addObject:faceLandmark2D.leftEyebrow];
//                [pointArray addObject:faceLandmark2D.rightEyebrow];
//
//                [pointArray addObject:faceLandmark2D.nose];
//                [pointArray addObject:faceLandmark2D.noseCrest];
//
//                [pointArray addObject:faceLandmark2D.medianLine];
//                [pointArray addObject:faceLandmark2D.outerLips];
//                [pointArray addObject:faceLandmark2D.innerLips];
//
//                [pointArray addObject:faceLandmark2D.leftPupil];
//                [pointArray addObject:faceLandmark2D.rightPupil];
//
//
//                // 遍历所有特征x
//                for (VNFaceLandmarkRegion2D *landmarks2D in pointArray) {
//                    CGPoint points[landmarks2D.pointCount];
//                    // 转换特征的所有点
//                    for (int i = 0; i < landmarks2D.pointCount; i++) {
//                     const CGPoint *point = [landmarks2D pointsInImageOfSize:imageSize];
////                        vector_float2 point = [landmarks2D pointAtIndex:i];
//
//                        CGFloat rectWidth  = imageSize.width * observation.boundingBox.size.width;
//                        CGFloat rectHeight = imageSize.height * observation.boundingBox.size.height;
//                        CGPoint p = CGPointMake( point[i].x * rectWidth + observation.boundingBox.origin.x * imageSize.width
//                                                , observation.boundingBox.origin.y * imageSize.height + point[i].y * rectHeight);
//                        points[i] = p;
//                    }
//                    UIBezierPath *path = [UIBezierPath bezierPath];
//                    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//
//
////                    UIGraphicsBeginImageContextWithOptions(imageSize, false, 1);
////                    CGContextRef context = UIGraphicsGetCurrentContext();
////                    [[UIColor greenColor] set];
////                    CGContextSetLineWidth(context, 2);
////
////                    // 设置翻转
////                    CGContextTranslateCTM(context, 0, imageSize.height);
////                    CGContextScaleCTM(context, 1.0, -1.0);
////
////                    // 设置线类型
////                    CGContextSetLineJoin(context, kCGLineJoinRound);
////                    CGContextSetLineCap(context, kCGLineCapRound);
////
////                    // 设置抗锯齿
////                    CGContextSetShouldAntialias(context, true);
////                    CGContextSetAllowsAntialiasing(context, true);
////
////                    // 绘制
////                    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
//////                    CGContextDrawImage(context, rect, sourceImage.CGImage);
////                    CGContextAddLines(context, points, landmarks2D.pointCount);////画线部分  使用layer画线
////                    CGContextDrawPath(context, kCGPathStroke);
////
////                    // 结束绘制
//////                    sourceImage = UIGraphicsGetImageFromCurrentImageContext();
////                    UIGraphicsEndImageContext();
//                }
//            }
//        }];
//
//        // 发送识别请求
//        NSError *error = nil;
//        [detectRequestHandler performRequests:@[detectRequest] error:&error];
//        if (error) {
//            NSLog(@"%@", error.debugDescription);
//        }
//
//    } else {
//        // Fallback on earlier versions
//    }
    
    
}

/// 转换Rect
+ (CGRect)convertRect:(CGRect)oldRect imageSize:(CGSize)imageSize{
    CGFloat w = oldRect.size.width * imageSize.width;
    CGFloat h = oldRect.size.height * imageSize.height;
    CGFloat x = oldRect.origin.x * imageSize.width;
    CGFloat y = imageSize.height - (oldRect.origin.y * imageSize.height) - h;
    return CGRectMake(x, y, w, h);
}

#pragma mark -
- (void)movieRecordingCompleted; {
    
    NSURL *url = [self movieURLWithMovieName:_curRecordingName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        //要不要保存之类的动作
        NSLog(@"当前录制的文件路径：%@", url.path);
        [_moviesNameMarr addObject:_curRecordingName];
        if ([_delegate respondsToSelector:@selector(previewView:didCompleteTheRecordingWithFileURL:)]) {
            [_delegate previewView:self didCompleteTheRecordingWithFileURL:url];
        }
        //            GPUImageMovie *movie = [[GPUImageMovie alloc] initWithURL:url];//
    } else {
        //保存失败
    }
    
    [_trailingOutput removeTarget:_movieWriter];
    _cameraVideo.audioEncodingTarget = nil;
}
- (void)movieRecordingFailedWithError:(NSError*)error; {
    [_trailingOutput removeTarget:_movieWriter];
    _cameraVideo.audioEncodingTarget = nil;
}

#pragma mark - GPUImageVideoCameraAssistProtocol
- (void)videoCamera:(GPUImageVideoCamera *)camera currentOrientation:(UIDeviceOrientation *)orientation {
    
}

- (void)cleanFaceMap {
    for (UIView *tmpView in _faceMap.allValues) {
        tmpView.alpha = 0;
    }
}

///人脸识别    苹果的算法也有缺陷、太远的距离 不精确
static int stride = 0;
- (void)cameraDidOutputMetadataObjects:(NSArray *)metadataObjects {
   ///建议3 - 5帧作一个检查
    stride++;//步幅
    if (stride == 3) {
        stride = 0;
        return;
    }
    
    if (metadataObjects && metadataObjects.count) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(cleanFaceMap) object:nil];
        [self performSelector:@selector(cleanFaceMap) withObject:nil afterDelay:0.2];

        //移除所有的得到人脸识别的view
        for (UIView *tmpView in _faceMap.allValues) {
            tmpView.alpha = 0;
        }
        //视图/layer的位置尺寸更改
        for (AVMetadataObject *object in metadataObjects) {
            if ( [[object type] isEqual:AVMetadataObjectTypeFace]) {
                
                AVMetadataFaceObject* face = (AVMetadataFaceObject*)object;
                AVMetadataObject *transFace = [_previewLayer transformedMetadataObjectForMetadataObject:face];
                CGRect faceRectangle = transFace.bounds;
                
                  dispatch_async(dispatch_get_main_queue(), ^{
                    UIView *view = _faceMap[[NSString stringWithFormat:@"%ld", face.faceID]];
                    if (!view) {
                        view = [[UIView alloc] initWithFrame:faceRectangle];
                        view.backgroundColor = [UIColor clearColor];
                        view.layer.borderColor = UIColor.greenColor.CGColor;
                        view.layer.borderWidth = 2.0;
                        [self addSubview:view];
                        _faceMap[[NSString stringWithFormat:@"%ld", face.faceID]] = view;
                    } else {
                        view.alpha = 1;
                        view.frame = faceRectangle;
                    }
                      
                });
                //                CGFloat rollAngle = [face rollAngle];//人脸倾斜角
                //                CGFloat yawAngle = [face yawAngle];//人脸偏转角
            }
        }
    } else {
        
    }
}

#pragma mark - Public

- (void)setZoom:(CGFloat)zoom {
    [self.cameraCurrent setDeviceZoomFactor:zoom];
}

- (NSURL *)movieURLWithMovieName:(NSString *)name {
	return [NSURL fileURLWithPath:[[self movieFolder] stringByAppendingPathComponent:name]];
}

- (NSString *)movieFolder {
    return [NSObject wz_filePath:WZSearchPathDirectoryDocument fileName:MovieFolderName];
}

- (void)pickMediaType:(WZMediaType)mediaType {
//    if (_mediaType == mediaType && _cameraStillImage) {return;}
    
    _mediaType = mediaType;
    //断链
    //初始化配置
    //首次 高画质 背面配置
    
    [_cameraCurrent stopCameraCapture];
    
    AVCaptureSessionPreset preset = AVCaptureSessionPresetHigh;
    AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
    if (_mediaType == WZMediaTypeVideo) {
        _cameraVideo = [[GPUImageVideoCamera alloc] initWithSessionPreset:preset cameraPosition:position];
        _cameraCurrent = _cameraVideo;
#warning 如果临时加上音频输出的化 会出现闪烁（因为要更改lock） 所以加在初始化这里
        [_cameraVideo addAudioInputsAndOutputs];///
        
//        AVCaptureVideoStabilizationMode stabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        //视频防抖  使用的过程会产生延时效果 初步判定可能是GPU内部的原因....
//        if ([_cameraCurrent.inputCamera.activeFormat isVideoStabilizationModeSupported:stabilizationMode]) {
//            AVCaptureConnection *videoOutput = [_cameraCurrent videoCaptureConnection];
//            [videoOutput setPreferredVideoStabilizationMode:stabilizationMode];
//        }
        
    } else {
 
        _cameraStillImage = [[GPUImageStillCamera alloc] initWithSessionPreset:preset cameraPosition:position];
        _cameraCurrent = _cameraStillImage;
    }
    
    //视频 HDR (高动态范围图像)
    if ([_cameraCurrent.inputCamera lockForConfiguration:nil]) {
        _cameraCurrent.inputCamera.automaticallyAdjustsVideoHDREnabled = true;//留给系统处理;
        [_cameraCurrent.inputCamera unlockForConfiguration];
    }
    
    //注意layer 因为与session相关 所以也需要重新配置
    _previewLayer = nil;
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.cameraCurrent.captureSession];
    _previewLayer.frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspect; // 设置预览时的视频缩放方式
    if ([_previewLayer.connection isVideoOrientationSupported]) {//设置视频的朝向
        [[_previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
 
    //焦点 曝光
    [self.cameraCurrent autoFocusAndExposureAtPoint:CGPointMake(0.5, 0.5)];//居中
    
    [_cameraCurrent addCMMotionToMobile];
    _cameraCurrent.outputImageOrientation = UIInterfaceOrientationPortrait;//拍照方向
    ///前后摄像头镜像配置
    _cameraCurrent.horizontallyMirrorFrontFacingCamera = false;
    _cameraCurrent.horizontallyMirrorRearFacingCamera = false;
    
    //内建滤镜
    if (!_cropFilter) {
        _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, 0.0, 1.0, 1.0)];
//        CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
//        CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
//        CGFloat targetH = screenW / 9.0 * 16.0;//9 ： 16
//        CGFloat rateH = targetH / screenH;
//        if (rateH > 1) {
//            rateH = 1;
//        }
        _cropFilter.cropRegion = CGRectMake(0.0, 0.0, 1.0, 1.0);//0~1 自动居中 Q:如何设置1：1  3：4 等图片的尺寸
    }
    
    
    if (!_scaleFilter) {
        _scaleFilter = [[GPUImageFilter alloc] init];
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize size = [UIScreen mainScreen].bounds.size;
        [_scaleFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(size.width * scale, size.height * scale)];
    }

    //缩减渲染比例 降低渲染成本
    [_cameraCurrent addTarget:_cropFilter];
    
    GPUImageOutput <GPUImageInput> *tmpFilter = _insertFilter;
    if (!tmpFilter) {
        tmpFilter = _cropFilter;
    }
    
    [tmpFilter addTarget:_scaleFilter];
    [_scaleFilter addTarget:self.presentView];
    
}

///开启镜头
- (void)launchCamera {
    _cameraCurrent.delegate = (id<GPUImageVideoCameraDelegate>)self;
    [_cameraCurrent configMetadataOutputWithDelegete];
    [_cameraCurrent startCameraCapture];
}

- (void)pauseCamera {
    [_cameraCurrent pauseCameraCapture];
}

- (void)resumeCamera {
    [_cameraCurrent resumeCameraCapture];
}

- (void)stopCamera {
    [_cameraCurrent stopCameraCapture];
    
    [_cameraCurrent removeAllTargets];
    [_cameraCurrent removeInputsAndOutputs];
    [_cameraCurrent removeOutputFramebuffer];
}

- (void)setFlashType:(GPUImageCameraFlashType)type {
    [_cameraCurrent setFlashType:type];
}

- (CGPoint)calculatePointOfInterestWithPoint:(CGPoint)point {
    if (!_previewLayer) {return  CGPointZero;}
    return [_previewLayer captureDevicePointOfInterestForPoint:point];
}

#pragma mark - 视频录制部分
/**
 
 需求：
     若干段视频，可重录上一段（数组，多段录制）
     有方向性的录制
 
 */
/**
 视频录制开始之前的动作

 @param movieName 将要保存的名字
 @param outputSize 输出的尺寸
 @param trailingOutput source   PS：source一般使用crop，因为录制出源视频，是对之后的视频处理是有帮助的哦~~~
 */
- (void)prepareRecordWithMovieName:(NSString *)movieName outputSize:(CGSize)outputSize trailingOutPut:(GPUImageOutput <GPUImageInput >*)trailingOutput {
    if (!trailingOutput && !_trailingOutput) {
        trailingOutput = _cropFilter;
        _trailingOutput = trailingOutput;
    }
    
    if (CGSizeEqualToSize(outputSize, CGSizeZero)) {
        outputSize = _cropFilter.outputFrameSize;
    }
    
    NSURL *url = [self movieURLWithMovieName:movieName];
    _curRecordingName = movieName;
    
    //录制前检查录制文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    
	_movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:outputSize];
    _movieWriter.encodingLiveVideo = true;
    _movieWriter.delegate = self;
    ///已经配置完毕的链
    [_trailingOutput addTarget:_movieWriter];
    
    //开启声音采集 an expensive operation ........ https://stackoverflow.com/questions/30251784/gpuimagemoviewriter-black-frame-caused-by-audioencodingtarget
    _movieWriter.hasAudioTrack = true;
    _movieWriter.shouldPassthroughAudio = true;
    _cameraVideo.audioEncodingTarget = _movieWriter;//因为重新配置了输出和输入operation
}

///计算录像的总时间
- (void)calculateTimeWith:(CMSampleBufferRef)sampleBuffer {
    if (_recording) {
        //得到时间
        //        CMTime duration = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        CMTime duration = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
        if (CMTimeCompare(_recordStartTime, kCMTimeZero) == 0) {
            _recordStartTime = CMTimeMake(duration.value, duration.timescale);
        }
        CMTime progressTime = CMTimeSubtract(duration , _recordStartTime);//有点误差， 需要录制完之后再校对一次吧
        if (_recording) {
            progressTime = CMTimeAdd(_recordTotalTime, progressTime);//加上之前拍照的总时间数目
            //回调出去
            
            if ([_delegate respondsToSelector:@selector(previewView:audioVideoWriterRecordingCurrentTime:last:)]) {
                [_delegate previewView:self audioVideoWriterRecordingCurrentTime:progressTime last:false];
            }
        }
    } else {
        
    }
}

- (void)startRecordTimeConfig {
    _recordStartTime = kCMTimeZero;
}

- (void)resetTotalTime {
    _recordTotalTime = kCMTimeZero;
    for (NSString *fileName in _moviesNameMarr) {
        NSURL *url = [self movieURLWithMovieName:fileName];
        if ([url isKindOfClass:[NSURL class]]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
                AVAsset *asset = [AVAsset assetWithURL:url];
                _recordTotalTime = CMTimeAdd(_recordTotalTime, asset.duration);
            }
        }
    }
}

- (void)endRecordTimeConfig {
//    结算总时间
    sleep(0.1);//为了准确获取时间
    [self resetTotalTime];//看本地资源的事件可能为0 导致输出的time为0
    if ([_delegate respondsToSelector:@selector(previewView:audioVideoWriterRecordingCurrentTime:last:)]) {
        [_delegate previewView:self audioVideoWriterRecordingCurrentTime:_recordTotalTime last:true];//传回准确的总拍摄时间
    }
}

- (void)startRecord {
    ///时间配置
    [self startRecordTimeConfig];
    
    ///相机配置
    _cameraVideo.outputImageOrientation = UIInterfaceOrientationPortrait;//拍照方向
    _cameraVideo.horizontallyMirrorFrontFacingCamera = NO;
    _cameraVideo.horizontallyMirrorRearFacingCamera = NO;
    ///带变量的文件名
    
    [self prepareRecordWithMovieName:[self newMovieName] outputSize:CGSizeZero trailingOutPut:nil];
    if (_movieWriter) {
       
//        _movieWriter startRecordingInOrientation:(CGAffineTransform)
        /////录制方向变更
        [_movieWriter startRecording];
        _recording = true;
        
       
    } else {
        NSLog(@"请注意：movie writer 还没配置完成");
    }
}


//- (void)pauseRecord {
//    _movieWriter.paused = true;
//}
//
//- (void)resumeRecord {
//    _movieWriter.paused = false;
//}

///文件的录取
- (NSString *)newMovieName {
    NSString *movieName = [NSString stringWithFormat:@"recordMovie%ld.m4v", _moviesNameMarr.count];
    return movieName;
}

///取消录制
- (void)cancelRecord {
    _recording = false;
    if (_movieWriter) {
        [_movieWriter finishRecordingWithCompletionHandler:^{
            NSURL *url = [self movieURLWithMovieName:_curRecordingName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
                //要不要保存之类的动作
                NSLog(@"当前录制的文件路径：%@", url.path);
                [_moviesNameMarr addObject:_curRecordingName];
                if ([_delegate respondsToSelector:@selector(previewView:didCompleteTheRecordingWithFileURL:)]) {
                    [_delegate previewView:self didCompleteTheRecordingWithFileURL:url];
                }
                //            GPUImageMovie *movie = [[GPUImageMovie alloc] initWithURL:url];//
            } else {
                //保存失败
            }
            
            //清除
            [_trailingOutput removeTarget:_movieWriter];
            _cameraVideo.audioEncodingTarget = nil;
        }];
//        _movieURL.path;//一般都会有内容的 要不要 外部决定
    }
}

///结束录制
- (void)endRecord {
    _recording = false;
    if (_movieWriter && _curRecordingName) {
        [self cancelRecord];
    }
    ///时间重新配置 因为时间 每暂停一次 都会增加误差  但是下面这个设置是有所风险的
//    [self endRecordTimeConfig];
}

#pragma mark - Accessor
- (GPUImageView *)presentView {
    if (!_presentView) {
        _presentView = [[GPUImageView alloc] initWithFrame:self.bounds];
    }
    return _presentView;
}

@end
