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
   
 
    NSUInteger _frameCount;                //帧数 由limitedTime->frameRate得到
    NSUInteger _addedFrameCount;           //已添加的帧数
    NSUInteger targetFrameCount;           //目标帧数
}


@property (nonatomic, assign) CMTime currentProgressTime;   //当前进度
@property (nonatomic, assign) WZConvertPhotosIntoVideoToolStatus status;  //状态
@property (nonatomic, strong) NSMutableArray <WZConvertPhotosIntoVideoItem *>*itemMArr;  //数据源
@property (nonatomic, strong) NSMutableArray <WZConvertPhotosIntoVideoItem *>*transitionNodeMarr;  //节点

@property (nonatomic, strong) NSURL *outputURL;

@property (nonatomic, strong) dispatch_source_t timerSource;

@property (nonatomic, strong) WZGPUImagePicture *pictureA;
@property (nonatomic, strong) WZGPUImagePicture *pictureB;
@property (nonatomic, strong) WZConvertPhotosIntoVideoFilter *convertPhotosIntoVideoFilter;

//GPUImageMovieWriter存在内存泄漏，处理方案：https://stackoverflow.com/questions/27857330/memory-leak-occurs-when-use-gpuimagemoviewriter-multiple-times
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@property (nonatomic,   weak) WZConvertPhotosIntoVideoItem *curItem;    //临时的item

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
        self.frameRate = frameRate;
        
    }
    return self;
}


#pragma mark - Private
- (void)defaultConfig {
    self.frameRate = CMTimeMake(1, 25);// fbs 25（30也是可以的）
    _frameCount = 0;
    _addedFrameCount = 0;
    
    _timeIsLimited = false; //默认为false
    _limitedTime = CMTimeMake(10 * 600, 600);//默认10sec
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    NSLog(@"%s", __func__);

    for (WZConvertPhotosIntoVideoItem *tmpObj in _itemMArr) {
        tmpObj.leadingImage = nil;
        tmpObj.trailingImage = nil;
    }
    for (WZConvertPhotosIntoVideoItem *tmpObj in _transitionNodeMarr) {
        tmpObj.leadingImage = nil;
        tmpObj.trailingImage = nil;
    }
    
    [_itemMArr removeAllObjects];
    [_transitionNodeMarr removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    

    [self cleanChain];
    [self cleanTimer];
}


- (BOOL)configurable {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Idle
        || _status == WZConvertPhotosIntoVideoToolStatus_Ready) {
        return true;
    }
    NSLog(@"状态出错，设置属性失败");
    return false;
}

//
- (void)addFrameAction {
    //先是代理判断当前进度 决定继续添加buffer 还是停止录制
    
    if (_status == WZConvertPhotosIntoVideoToolStatus_Converting) {
        if (_timeIsLimited
            && _frameCount <= _addedFrameCount) {
            //达到了限制
            return;
        }
        if (targetFrameCount == _addedFrameCount) {
            NSLog(@"超出上限");
            return;
        }
        //录制
        [_curItem updateFrameWithSourceA:_pictureA sourceB:_pictureB filter:_convertPhotosIntoVideoFilter consumer:_movieWriter time:_currentProgressTime];
        _currentProgressTime = CMTimeAdd(_currentProgressTime, _frameRate);//帧位时间偏移更新
        _addedFrameCount++;
        NSLog(@"目标帧数：%ld，已添加帧数 %ld", targetFrameCount, _addedFrameCount);
        if ([_delegate respondsToSelector:@selector(convertPhotosInotViewTool:progress:)]) {
            [_delegate convertPhotosInotViewTool:self progress:(_addedFrameCount * 1.0) / targetFrameCount];
        }
      
    } else if (_status == WZConvertPhotosIntoVideoToolStatus_Completed) {
        //完成
        [self finishWriting];
    }
}

- (void)switchRole {
    if (_curItem == nil && _itemMArr.count) {
        //首次切换某个item
        _curItem = _itemMArr.firstObject;
        [_curItem firstConfigWithSourceA:_pictureA sourceB:_pictureB filter:_convertPhotosIntoVideoFilter consumer:_movieWriter time:_currentProgressTime];
        
    } else {
        if (_curItem == _itemMArr.lastObject) {
            //已经全部配置完成。
            //发出完成视频的消息
            _status = WZConvertPhotosIntoVideoToolStatus_Completed;
        } else {
            //切换到下一个item
            _curItem = _itemMArr[[_itemMArr indexOfObject:_curItem] + 1];
             [_curItem firstConfigWithSourceA:_pictureA sourceB:_pictureB filter:_convertPhotosIntoVideoFilter consumer:_movieWriter time:_currentProgressTime];
        }
    }
}

#pragma mark - Public

- (void)prepareTaskWithPictureSources:(NSArray <UIImage *>*)pictureSources {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Converting) {
        NSLog(@"#warning : 正在合成视频 不可更改数据源");
        return;
    }
    _status = WZConvertPhotosIntoVideoToolStatus_Idle;

    //预设重配
    [_itemMArr removeAllObjects];
    [_transitionNodeMarr removeAllObjects];
    for (WZConvertPhotosIntoVideoItem *tmpObj in _itemMArr) {
        tmpObj.leadingImage = nil;
        tmpObj.trailingImage = nil;
    }
    for (WZConvertPhotosIntoVideoItem *tmpObj in _transitionNodeMarr) {
        tmpObj.leadingImage = nil;
        tmpObj.trailingImage = nil;
    }
    [_transitionNodeMarr removeAllObjects];
    
    _itemMArr = NSMutableArray.array;
    _transitionNodeMarr = NSMutableArray.array;
    
    NSUInteger pictureCount = pictureSources.count;          //图片总量
    NSUInteger transitionFrameCount = 15;                    //过渡效果的帧数
    targetFrameCount = pictureSources.count * 30 * 2;        //任务目标总帧数
    
    NSUInteger nontransitionFrameCount = (targetFrameCount - ((pictureCount -1) * transitionFrameCount)) / pictureCount;                                        //非过渡帧数
    NSUInteger sumFrameCount = targetFrameCount;             //临时计算量
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
            item.transitionType = WZConvertPhotosIntoVideoType_Dissolve;    //配置为none类型
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

    {
        //信号指向ready状态
        _status = WZConvertPhotosIntoVideoToolStatus_Ready;
        [self startWriting];
    }
}

- (void)finishWriting {
    _status = WZConvertPhotosIntoVideoToolStatus_Completed;
    [self cleanTimer];
    [_movieWriter finishRecordingWithCompletionHandler:^{
        if ([_delegate respondsToSelector:@selector(convertPhotosInotViewToolFinishWriting)]) {
            [_delegate convertPhotosInotViewToolFinishWriting];
        }
        
        [self cleanChain];
    }];
}

- (void)startWriting {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Ready) {
        //重配时间
        [self cleanTimer];
        [self cleanChain];
        
        
        _status = WZConvertPhotosIntoVideoToolStatus_Converting;
        
        //原始 sourceA&sourceB -> filter -> writer
        _convertPhotosIntoVideoFilter = [[WZConvertPhotosIntoVideoFilter alloc] init];
        
        _pictureA = [[WZGPUImagePicture alloc] init];
        _pictureB = [[WZGPUImagePicture alloc] init];
        //默认是mov格式
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:_outputURL size:_outputSize];
        
        //链装配
        [_pictureA addTarget:_convertPhotosIntoVideoFilter];
        [_pictureB addTarget:_convertPhotosIntoVideoFilter];
        [_convertPhotosIntoVideoFilter addTarget:_movieWriter];
        
        //首次add 的配置
        [_movieWriter startRecording];
        
        [self switchRole];//初次配置就先设置一次
        //开始进入计时状态
        _currentProgressTime = CMTimeMake(0, _frameRate.timescale);
        
        _timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_timerSource, DISPATCH_TIME_NOW, 1.0 / 60.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);

        dispatch_source_set_event_handler(_timerSource, ^{
            [self addFrameAction];
        });
        dispatch_resume(_timerSource);
        
    } else { NSLog(@"状态出错"); }
}

- (void)cancelWriting {
    [self cleanTimer];
    [_movieWriter cancelRecording];
    [self cleanChain];
}

- (void)cleanChain {
    [_pictureA removeAllTargets];
    [_pictureB removeAllTargets];
   
    [_convertPhotosIntoVideoFilter removeAllTargets];
    _movieWriter.delegate = nil;
    
    _pictureA = nil;
    _pictureB = nil;
    _convertPhotosIntoVideoFilter = nil;
    _movieWriter = nil;
}


- (void)cleanTimer {
    if (_timerSource) {
        dispatch_source_cancel(_timerSource);
        _timerSource = nil;
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
    [self switchRole];
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




@end
