//
//  WZConvertPhotosIntoVideoTool.m
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZConvertPhotosIntoVideoTool.h"
#import <AVFoundation/AVFoundation.h>
#import "WZGPUImagePicture.h"

//参考
//http://blog.sina.com.cn/s/blog_a45145650102v8t0.html
@interface WZConvertPhotosIntoVideoTool()<WZConvertPhotosIntoVideoItemProtocol>
{
    AVAssetWriter *_writer;
    AVAssetWriterInputPixelBufferAdaptor *_adaptor;
    AVAssetWriterInput *_audioInput;
    AVAssetWriterInput *_videoInput;
 
    NSUInteger _frameCount;                                  //帧数 由limitedTime->frameRate得到
    
//    NSLock *_lock;                                           //mutex lock
    
   
    CVPixelBufferRef _tmpPBR;
    
    NSUInteger _addedFrameCount;                         //已添加的帧数
    
    NSUInteger targetFrameCount;            //目标帧数
    
    
    
    GPUImageFramebuffer *firstInputFramebuffer;
}


@property (nonatomic, assign) CMTime currentProgressTime;   //当前进度
@property (nonatomic, assign) WZConvertPhotosIntoVideoToolStatus status;  //状态
@property (nonatomic, strong) NSArray <UIImage *>*sources;  //数据源
@property (nonatomic, strong) NSMutableArray <WZConvertPhotosIntoVideoItem *>*itemMArr;  //数据源
@property (nonatomic, strong) NSMutableArray <WZConvertPhotosIntoVideoItem *>*transitionNodeMarr;  //数据源

@property (nonatomic, strong) WZGPUImagePicture *pictureA;
@property (nonatomic, strong) WZGPUImagePicture *pictureB;

@property (nonatomic, strong) WZConvertPhotosIntoVideoFilter *convertPhotosIntoVideoFilter;

@end

@implementation WZConvertPhotosIntoVideoTool

#pragma mark - Initialization
- (instancetype)initWithOutputURL:(NSURL *)outputURL
                       outputSize:(CGSize)outputSize
                        frameRate:(CMTime)frameRate {
    self = [super init];
    if (self) {
        [self defaultConfig];
        
        _outputSize = outputSize;
        _frameRate = frameRate;
        

    }
    return self;
}



- (instancetype)init {
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

#pragma mark - Private
- (void)defaultConfig {
    _frameRate = CMTimeMake(1, 25);// fbs 25（30也是可以的）
    _frameCount = 0;
    _addedFrameCount = 0;
    
    _timeIsLimited = false; //默认为false
    _limitedTime = CMTimeMake(10 * 600, 600);//默认10sec
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    if (_tmpPBR) {
        CVPixelBufferRelease(_tmpPBR);
        _tmpPBR = NULL;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)configurable {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Idle
        || _status == WZConvertPhotosIntoVideoToolStatus_Ready) {
        return true;
    }
    NSLog(@"状态出错，设置属性失败");
    return false;
}

#pragma mark - Public

- (void)prepareTaskWithPictureSources:(NSArray <UIImage *>*)pictureSources {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Converting) {
        NSLog(@"#warning : 正在合成视频 不可更改数据源");
        return;
    }
    _status = WZConvertPhotosIntoVideoToolStatus_Idle;
    _sources = pictureSources.copy;
    //预设重配
    [self retsetConfig];
    
    _itemMArr = NSMutableArray.array;
    _transitionNodeMarr = NSMutableArray.array;
    
    NSUInteger pictureCount = pictureSources.count;          //图片总量
    NSUInteger transitionFrameCount = 15;                    //过渡效果的帧数
    targetFrameCount = 250;                                  //任务目标总帧数
    
    NSUInteger nontransitionFrameCount = (targetFrameCount - ((pictureCount -1) * transitionFrameCount)) / pictureCount;                                                //非过渡帧数
    NSUInteger sumFrameCount = targetFrameCount;              //临时计算量
    //由于分割的问题 多出来的 几帧会加载最后的图片上
    for (NSUInteger i = 0; i < pictureCount; i++) {
        //平滑点
        WZConvertPhotosIntoVideoItem *item = [[WZConvertPhotosIntoVideoItem alloc] init];
        item.delegate = self;
        item.leadingImage = pictureSources[i];
        [_itemMArr addObject:item];
        item.frameCount = nontransitionFrameCount;
        sumFrameCount -= nontransitionFrameCount;
        
        if (i < (pictureCount - 1)) {
            //过渡点
            item = [[WZConvertPhotosIntoVideoItem alloc] init];
            item.delegate = self;
            item.leadingImage = pictureSources[i];
            item.trailingImage = pictureSources[i + 1];
//            item.transitionType = BIConvertPhotosIntoVideoType_None;    //默认转换类型
            item.frameCount = transitionFrameCount;
            sumFrameCount -= transitionFrameCount;
            
            [_itemMArr addObject:item];
            [_transitionNodeMarr addObject:item];                        //链接上这个数据以便在外部修改
        } else {
            //计算多出的帧加载最后的图片(item)上
            if (_itemMArr.lastObject) {
                _itemMArr.lastObject.frameCount += sumFrameCount;
                sumFrameCount = 0;
            }
        }
    }
    
}

- (void)retsetConfig {
    
    _convertPhotosIntoVideoFilter = [[WZConvertPhotosIntoVideoFilter alloc] init];
    
    _pictureA = [[WZGPUImagePicture alloc] init];
    _pictureB = [[WZGPUImagePicture alloc] init];
    
    [_pictureA processImage];//传递缓存  size是根据图片来output的.
    [_pictureB processImage];//传递缓存
    
    [_pictureA addTarget:_convertPhotosIntoVideoFilter atTextureLocation:0];
    [_pictureB addTarget:_convertPhotosIntoVideoFilter atTextureLocation:1];
}

- (void)prepareTask {
    //初始化一些工具
    if (_status != WZConvertPhotosIntoVideoToolStatus_Idle) {
        NSLog(@"%s，状态错误", __func__);
        return;
    }
    
    NSError *error = nil;
    {//文件部分
        if (_outputURL && [_outputURL isFileURL]) {} else {
            //使用自定义的路径
            NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:@"WZConvertPhotosIntoVideoTool.mov"];
            _outputURL = [NSURL fileURLWithPath:filePath];
        }
        
        if (_outputURL && [[NSFileManager defaultManager] fileExistsAtPath:_outputURL.path]) {
            [[NSFileManager defaultManager] removeItemAtURL:_outputURL error:&error];
        }
        if (error) {
            NSLog(@"文件移除出错，%@", error.debugDescription);
        }
    }
    
    {//写入工具部分
        AVFileType fileType = AVFileTypeQuickTimeMovie;
        _writer = [[AVAssetWriter alloc] initWithURL:_outputURL fileType:fileType error:&error];

        NSMutableDictionary *outputSettings = NSMutableDictionary.dictionary;
        CGSize outputSize = _outputSize;//   x % 2 = 0 （尺寸最好是2的倍数）
        outputSettings[AVVideoWidthKey] = @(outputSize.width);
        outputSettings[AVVideoHeightKey] = @(outputSize.height);
        outputSettings[AVVideoCodecKey] = AVVideoCodecH264;
        _videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
        _videoInput.expectsMediaDataInRealTime = false;//实时（看需求）
        
        if ([_writer canAddInput:_videoInput]) {
            [_writer addInput:_videoInput];
        } else {
            NSLog(@"配置失败");
            return;
        }
        
        NSMutableDictionary *sourcePixelBufferAttributes = NSMutableDictionary.dictionary;
        sourcePixelBufferAttributes[(__bridge id)kCVPixelBufferPixelFormatTypeKey] = @(kCVPixelFormatType_32BGRA);
        sourcePixelBufferAttributes[(__bridge id)kCVPixelBufferWidthKey] = @(outputSize.width);
        sourcePixelBufferAttributes[(__bridge id)kCVPixelBufferHeightKey] = @(outputSize.height);
        //        sourcePixelBufferAttributes[(__bridge id)kCVPixelBufferCGBitmapContextCompatibilityKey] = @(true);
        AVAssetWriterInputPixelBufferAdaptor *writerInputPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:_videoInput sourcePixelBufferAttributes:sourcePixelBufferAttributes];
        _adaptor = writerInputPixelBufferAdaptor;
    }
    
    {
        //信号指向ready状态
        _status = WZConvertPhotosIntoVideoToolStatus_Ready;
        [self startWriting];
    }
}

- (void)finishWriting {
    _status = WZConvertPhotosIntoVideoToolStatus_Completed;
    [_videoInput markAsFinished];
    [_writer finishWritingWithCompletionHandler:^{
        if ([_delegate respondsToSelector:@selector(convertPhotosInotViewToolFinishWriting)]) {
            [_delegate convertPhotosInotViewToolFinishWriting];
        }
    }];
    
    [self cleanCache];
}

- (void)startWriting {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Ready) {
        //首次add 的配置
        [_writer startWriting];
        [_writer startSessionAtSourceTime:kCMTimeZero];
        _status = WZConvertPhotosIntoVideoToolStatus_Converting;
    } else {
        NSLog(@"状态出错");
    }
}

- (void)cancelWriting {
    [_videoInput markAsFinished];
    [_writer cancelWriting];
    _status = WZConvertPhotosIntoVideoToolStatus_Canceled;
    
    [self cleanCache];
}

//从buffer池中获取pixelBufferRef
- (CVPixelBufferRef)getPixelBufferRef {
    CVPixelBufferRef pixelBuffer = NULL;
    OSStatus err = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _adaptor.pixelBufferPool, &pixelBuffer);
    if (err) {
         CVPixelBufferRelease(pixelBuffer);
        return NULL;
    }
    return pixelBuffer;
}

- (BOOL)hasCache {
    if (_tmpPBR) {
        return true;
    }
    return false;
}

- (void)cleanCache {
    if (_tmpPBR) {
        CVPixelBufferRelease(_tmpPBR);
        _tmpPBR = NULL;
    }
}

- (void)addFrameWithCache {
    if (_tmpPBR) {
        [self addFrameWithSample:_tmpPBR];
    } else {
        NSLog(@"并无缓存");
    }
}

- (void)dasdasd:(CVPixelBufferRef)pixelBufferRef {
    //纹理绘制到pixelBufferRef中
    
}

- (void)addFrameWithCGImage:(CGImageRef)cgImage {
    if (_status != WZConvertPhotosIntoVideoToolStatus_Converting) {
        return;
    }
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage));
    CVPixelBufferRef pbr = [self getPixelBufferRef];
    if (pbr == NULL) {
        NSMutableDictionary *pixelBufferAttributes = NSMutableDictionary.alloc.init;
        pixelBufferAttributes[(__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey] = @(true);
        pixelBufferAttributes[(__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey] = @(true);
        CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault
                                              , imageSize.width
                                              , imageSize.height
                                              , kCVPixelFormatType_32BGRA
                                              , (__bridge CFDictionaryRef)pixelBufferAttributes
                                              , &pbr);
        if (status == kCVReturnSuccess && pbr != NULL) {
            NSLog(@"自创建PixelBuffer");
        } else {
            NSLog(@"自创建PixelBuffer失败");
        }
    }
    
    if (pbr) {
        //把image绘进pbr
        CGImageRef imageRef = cgImage;
        CVPixelBufferLockBaseAddress(pbr, 0);
        void *pxdata = CVPixelBufferGetBaseAddress(pbr);
        
        NSParameterAssert(pxdata != NULL);
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(pxdata
                                                     , _outputSize.width
                                                     , _outputSize.height
                                                     , 8
                                                     , 4 * _outputSize.width
                                                     , rgbColorSpace
                                                     , kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little);
        //(CGBitmapInfo)kCGImageAlphaPremultipliedFirst
        CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
        
        CGColorSpaceRelease(rgbColorSpace);
        CGContextRelease(context);
        
        CVPixelBufferUnlockBaseAddress(pbr, 0);
        [self addFrameWithSample:pbr];
        
        //刷新_tmpPBR
        [self cleanCache];
        _tmpPBR = pbr;
        
    } else {
        NSLog(@"丢帧啦");
    }
}

//先从pool中得到buffer
- (void)addFrameWithImage:(UIImage *)image {
    [self addFrameWithCGImage:image.CGImage];
}

- (void)addFrameWithSample:(CVPixelBufferRef)buffer {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Converting) {
        //计算时间
        
        if (_timeIsLimited
            && _frameCount <= _addedFrameCount) {
            //有时间限制 此时达到时间的最大值，之后添加的帧都会丢掉
            NSLog(@"已达到录制时间的最大值");
            return;
        }
        if ([_videoInput isReadyForMoreMediaData]) {
            if (buffer) {
                CVPixelBufferLockBaseAddress(buffer, 0);
                if (![_adaptor appendPixelBuffer:buffer withPresentationTime:_currentProgressTime]) {
                    NSLog(@"_adaptor append fail");
                } else {
                    _addedFrameCount++;
                    NSLog(@"已添加%ld帧", _addedFrameCount);
                    //时间根据帧率递增，调整当前的进度时间
                    _currentProgressTime = CMTimeAdd(_currentProgressTime, _frameRate);//时间递增
                }
                CVPixelBufferUnlockBaseAddress(buffer, 0);
                //            CVPixelBufferRelease(buffer);///初发现 有内存泄漏的情况，原来是buffer没有释放掉(在适当的时候释放).
            } else {
                NSLog(@"丢丢丢丢丢丢丢丢帧啦");
            }
        } else {
            NSLog(@"丢丢丢丢丢丢丢丢帧啦");
        }
    } else {
        NSLog(@"%s, 状态出错", __func__);
    }
}

#pragma mark - Accessor
- (void)setFrameRate:(CMTime)frameRate {
    if ([self configurable]) {
        _frameRate = frameRate;
        _currentProgressTime = CMTimeMake(0, _frameRate.timescale);
        //如果时间限制 需要重新配置总共录入的帧数
       
        _frameCount = (NSUInteger)(CMTimeGetSeconds(_limitedTime) / CMTimeGetSeconds(_frameRate));
       //        NSUInteger count = (NSUInteger)(CMTimeGetSeconds(CMTimeMakeWithSeconds(10, 6)) / CMTimeGetSeconds(CMTimeMake(1, 25)));//如果10Sec
    }
}

- (void)setOutputURL:(NSURL *)outputURL {
   if ([self configurable]) {
    _outputURL = outputURL;
   }
}

- (void)setLimitedTime:(CMTime)limitedTime {
    if ([self configurable]) {
        _limitedTime = limitedTime;
        _frameCount = (NSUInteger)(CMTimeGetSeconds(_limitedTime) / CMTimeGetSeconds(_frameRate));
    }
}

- (void)setTimeIsLimited:(BOOL)timeIsLimited {
    if ([self configurable]) {
        _timeIsLimited = timeIsLimited;
    }
}

#pragma mark - WZConvertPhotosIntoVideoItemProtocol
- (void)itemDidCompleteConversion {
    [self cleanCache];
    //准备下一个item的配置
}

#pragma mark - addition
//from : https://zhuanlan.zhihu.com/p/24762605?utm_medium=social&utm_source=weibo
+ (UIImage*)uiImageFromPixelBuffer:(CVPixelBufferRef)pbr {
    CIImage* ciImage = [CIImage imageWithCVPixelBuffer:pbr];
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(true)}];
    CGRect rect = CGRectMake(0, 0, CVPixelBufferGetWidth(pbr), CVPixelBufferGetHeight(pbr));
    CGImageRef videoImage = [context createCGImage:ciImage fromRect:rect];
    UIImage *image = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    return image;
}

// from：https://github.com/nancy-tar/OpencvCamera/blob/5bbd713ebab57bfad13f6b72829269d94529a722/OpencvCamera/ImageManager.mm
//warning 是否需要计算设备支持的尺寸
+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image {
    CVPixelBufferRef pxbuffer = NULL;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    size_t width =  CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    size_t bytesPerRow = CGImageGetBytesPerRow(image);
    
    CFDataRef  dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(image));
    GLubyte  *imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault,
                                 width,
                                 height,
                                 kCVPixelFormatType_32BGRA,
                                 imageData,bytesPerRow,
                                 NULL,
                                 NULL,
                                 (__bridge CFDictionaryRef)options,
                                 &pxbuffer);
    CFRelease(dataFromImageDataProvider);
    
    return pxbuffer;
}


+ (CMSampleBufferRef)sampleBufferFromPixelBuffer:(CVPixelBufferRef)pixelBuffer// withTime:(CMTime)time withDescription:(CMFormatDescriptionRef)description
{
    
    CMSampleBufferRef newSampleBuffer = NULL;
    CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(
                                                 NULL, pixelBuffer, &videoInfo);
    CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
                                       pixelBuffer,
                                       true,
                                       NULL,
                                       NULL,
                                       videoInfo,
                                       &timimgInfo,
                                       &newSampleBuffer);
    
    return newSampleBuffer;
}

- (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    // CVReturn status = CVPixelBufferPoolCreatePixelBuffer(NULL, adaptor.pixelBufferPool, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    
    NSParameterAssert(context);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

#pragma mark - Notification
- (void)willResignActiveNotification:(NSNotification *)notification {
    NSLog(@"%s", __func__);
    //暂停
    
}

//应用外处理
- (void)didBecomeActiveNotification:(NSNotification *)notification {
    NSLog(@"%s", __func__);
}



#pragma mark - GPUImageInput

//获取新的buffer
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex; {
    //得到新的buffer..
    NSLog(@"%s", __func__);
}
- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex; {
    NSLog(@"%s", __func__);
    firstInputFramebuffer = newInputFramebuffer;
}
//- (NSInteger)nextAvailableTextureIndex;
- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex; {
    NSLog(@"%s", __func__);
}
- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex; {
    NSLog(@"%s", __func__);
}

- (void)endProcessing; {
    NSLog(@"%s", __func__);
}



- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue; {
    NSLog(@"%s", __func__);
}

@end
