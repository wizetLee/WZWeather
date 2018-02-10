//
//  WZConvertPhotosIntoVideoTool.m
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZConvertPhotosIntoVideoTool.h"
#import <AVFoundation/AVFoundation.h>
//参考
//http://blog.sina.com.cn/s/blog_a45145650102v8t0.html
@interface WZConvertPhotosIntoVideoTool()
{
    AVAssetWriter *_writer;
    AVAssetWriterInputPixelBufferAdaptor *_adaptor;
    AVAssetWriterInput *_audioInput;
    AVAssetWriterInput *_videoInput;
    NSString *_queueID;
//    CVPixelBufferRef *_pixelBufferRef;
    CVPixelBufferRef *_pixelBufferRef;
    BOOL _finishWritingSignal;                              //需要停止输入的信号
    
    NSUInteger _frameCount;                                  //帧数 由limitedTime->frameRate得到
    
//    NSLock *_lock;                                           //mutex lock
    
    CVPixelBufferRef wrotePixelBuffer;
}

@property (nonatomic, assign) CMTime currentProgressTime;   //当前进度

@end

@implementation WZConvertPhotosIntoVideoTool

#pragma mark - Initialization
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
    _frameRate = CMTimeMake(1, 25);// fbs 25（30也是可以的）
    _finishWritingSignal = false;
    _frameCount = 0;
    _queueID = @"wizet.serial.queue";
    _pixelBufferRef = NULL;

}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

//addBuffer
- (void)addPixelBufferRef:(CVPixelBufferRef *)sbf {
   
        CVPixelBufferRef pixelBuffer = NULL;
        OSStatus err = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _adaptor.pixelBufferPool, &pixelBuffer);
        @synchronized (self){
            _pixelBufferRef = &pixelBuffer;//赋值在这个地址
            *_pixelBufferRef = *sbf;
            if (err && _pixelBufferRef) {
                CVPixelBufferRelease(*(_pixelBufferRef));
            } else {
                
            }
        }
}

#pragma mark - Public
- (void)prepareTask {
    //初始化一些工具
    
    if (_status != WZConvertPhotosIntoVideoToolStatus_Idle) {
        NSLog(@"add 失败，状态错误");
        return;
    }
    
    NSError *error = nil;
    _currentProgressTime = CMTimeMake(0, 25);
    
    {//文件部分
        if (_outputURL && [_outputURL isFileURL]) {} else {
            //使用自定义的路径
            NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:@"WZConvertPhotosIntoVideoTool.mov"];
            _outputURL = [NSURL fileURLWithPath:filePath];
        }
        
        if (_outputURL && [[NSFileManager defaultManager] fileExistsAtPath:_outputURL.path]) {
            [[NSFileManager defaultManager] removeItemAtURL:_outputURL error:nil];
        }
    }
    
    {//写入工具部分
        AVFileType fileType = AVFileTypeQuickTimeMovie;
        _writer = [[AVAssetWriter alloc] initWithURL:_outputURL fileType:fileType error:&error];

        NSMutableDictionary *outputSettings = NSMutableDictionary.dictionary;
        CGSize outputSize = _outputSize;//   x % 2 = 0
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
        //首次add 的配置
        [_writer startWriting];
        [_writer startSessionAtSourceTime:kCMTimeZero];
        _currentProgressTime = CMTimeMake(0, 30);
        _status = WZConvertPhotosIntoVideoToolStatus_Converting;
    }
}

- (void)finishWriting {
    [_videoInput markAsFinished];
    [_writer finishWritingWithCompletionHandler:^{
        if ([_delegate respondsToSelector:@selector(convertPhotosInotViewToolFinishWriting)]) {
            [_delegate convertPhotosInotViewToolFinishWriting];
        }
    }];
    
    //恢复状态
}
- (void)cancelWriting {
    [_videoInput markAsFinished];
    [_writer cancelWriting];
    _status = WZConvertPhotosIntoVideoToolStatus_Canceled;
    //恢复状态
}

- (CVPixelBufferRef)getPixelBufferRef {
    CVPixelBufferRef pixelBuffer = NULL;
    OSStatus err = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _adaptor.pixelBufferPool, &pixelBuffer);
    if (err) {
         CVPixelBufferRelease(pixelBuffer);
        return NULL;
    }
    return pixelBuffer;
}


//先从pool中得到buffer
- (void)renderWithImage:(UIImage *)image {
    CGSize imageSize = image.size;
    
    CVPixelBufferRef pbr = [self getPixelBufferRef];
    if (pbr == NULL) {
        NSMutableDictionary *pixelBufferAttributes = NSMutableDictionary.alloc.init;
        pixelBufferAttributes[(__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey] = @(true);
        pixelBufferAttributes[(__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey] = @(true);
        CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault
                                              , imageSize.width
                                              , imageSize.height
                                              , kCVPixelFormatType_32ARGB
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
        CGImageRef imageRef = image.CGImage;
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
        
        [self renderWithSample:pbr];
    } else {
        NSLog(@"丢帧啦");
    }
}

- (void)renderWithSample:(CVPixelBufferRef)buffer {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Ready) {
        
        //首次add 的配置
        [_writer startWriting];
        [_writer startSessionAtSourceTime:kCMTimeZero];
        _currentProgressTime = CMTimeMake(0, 30);
        _status = WZConvertPhotosIntoVideoToolStatus_Converting;
    } else if (_status == WZConvertPhotosIntoVideoToolStatus_Converting) {
       
        //计算时间
    }
    
    if ([_videoInput isReadyForMoreMediaData]) {
        if (buffer) {
            CVPixelBufferLockBaseAddress(buffer, 0);
            if (![_adaptor appendPixelBuffer:buffer withPresentationTime:_currentProgressTime]) {
                NSLog(@"_adaptor append fail");
            } else {
                //时间根据帧率递增
                _currentProgressTime = CMTimeAdd(_currentProgressTime, CMTimeMake(1, 30));//时间递增
            }
            CVPixelBufferUnlockBaseAddress(buffer, 0);
            CVPixelBufferRelease(buffer);///初发现 有内存泄漏的情况，原来是buffer没有释放掉
        } else {
             NSLog(@"丢丢丢丢丢丢丢丢帧啦");
        }
    } else {
        NSLog(@"丢丢丢丢丢丢丢丢帧啦");
    }
}

- (void)startRequestingFrames {
    [self prepareTask];
    
    if (_status != WZConvertPhotosIntoVideoToolStatus_Ready) {
        NSLog(@"error，当前状态并非：ready");
        return;
    }

    [_writer startWriting];
    [_writer startSessionAtSourceTime:kCMTimeZero];
    
    _status = WZConvertPhotosIntoVideoToolStatus_Converting;
   

    dispatch_queue_t queue = dispatch_queue_create([_queueID UTF8String], NULL);
    [_videoInput requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
        //队列中请求
        NSUInteger curIndex = 0;
        NSUInteger count = self.sources.count;
        while ([_videoInput isReadyForMoreMediaData]) {
          
//            CVPixelBufferRef pbf = [[self class] pixelBufferFromCGImage:self.sources[curIndex].CGImage];
            CVPixelBufferRef pbf = [self pixelBufferFromCGImage:self.sources[curIndex].CGImage size:self.sources[curIndex].size];
            curIndex++;
            if (count <= curIndex) {
                //继续
                [self finishWriting];
                break;
            } else {
                
            }
  
            if (pbf) {
                CVPixelBufferLockBaseAddress(pbf, 0);
//                    CVPixelBufferRef* nextPixelBuffer = [self copyNextPixelBufferToWrite];
              
                if (![_adaptor appendPixelBuffer:pbf withPresentationTime:_currentProgressTime]) {
                    //append  fail
                    NSLog(@"_adaptor append fail");
                } else {
                    //时间根据帧率递增
                    _currentProgressTime = CMTimeAdd(_currentProgressTime, _frameRate);//时间递增
                }
                
                CVPixelBufferUnlockBaseAddress(pbf, 0);
//                    CVPixelBufferRelease(*_pixelBufferRef);
//                    _pixelBufferRef = NULL;
                
            } else if (_finishWritingSignal) {
                [self finishWriting];
                
                break;//退出循环
            } else {
                //waiting 数据
            }
       
             //传出代理说明当前可接受下一个数据的传入
        }
    }];
}

//考虑：转线程
- (void)addFrameWithUIImage:(UIImage *)image {
    if (![image isKindOfClass:[UIImage class]]) { return; }
    [self addFrameWithCGImage:image.CGImage];
}
- (void)addFrameWithCGImage:(CGImageRef)image {
    CVPixelBufferRef pixelBufferRef = [[self class] pixelBufferFromCGImage:image];
    [self addFrameWithPixelBufferRef:&pixelBufferRef];
}
- (void)addFrameWithPixelBufferRef:(CVPixelBufferRef *)pixelBufferRef {
    if (pixelBufferRef == NULL) return;
    [self addPixelBufferRef:pixelBufferRef];
}

#pragma mark - Accessor
- (void)setFrameRate:(CMTime)frameRate {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Converting) {
        NSLog(@"设置失败，当前正在录制");
        return;
    }
    _frameRate = frameRate;
    //重新配置需要录入的帧数
    if (_timeIsLimited) {
        _frameCount = 0;
        _frameCount = (NSUInteger)(CMTimeGetSeconds(_limitedTime) / CMTimeGetSeconds(_frameRate));
        //        NSUInteger count = (NSUInteger)(CMTimeGetSeconds(CMTimeMakeWithSeconds(10, 6)) / CMTimeGetSeconds(CMTimeMake(1, 25)));//如果10Sec
    }
}

- (void)setOutputURL:(NSURL *)outputURL {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Converting) {
        NSLog(@"设置失败，当前正在录制");
        return;
    }
    _outputURL = outputURL;
}

- (void)setLimitedTime:(CMTime)limitedTime {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Converting) {
        NSLog(@"设置失败，当前正在录制");
        return;
    }
    _limitedTime = limitedTime;
}

- (void)setTimeIsLimited:(BOOL)timeIsLimited {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Converting) {
        NSLog(@"设置失败，当前正在录制");
        return;
    }
    
    [[NSDateFormatter new] dateFromString:@""];
    _timeIsLimited = timeIsLimited;
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

- (void)renderAtTime:(CMTime)time {
    if (_status == WZConvertPhotosIntoVideoToolStatus_Ready) {
        //首次render
        
    } else if (_status == WZConvertPhotosIntoVideoToolStatus_Converting) {
        //正在写入
        
    }
}


// from : https://zhuanlan.zhihu.com/p/24762605?utm_medium=social&utm_source=weibo
+ (UIImage*)uiImageFromPixelBuffer:(CVPixelBufferRef)pbr {
    CIImage* ciImage = [CIImage imageWithCVPixelBuffer:pbr];
    
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(true)}];
    
    CGRect rect = CGRectMake(0, 0, CVPixelBufferGetWidth(pbr), CVPixelBufferGetHeight(pbr));
    CGImageRef videoImage = [context createCGImage:ciImage fromRect:rect];
    
    UIImage *image = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    return image;
}

@end
