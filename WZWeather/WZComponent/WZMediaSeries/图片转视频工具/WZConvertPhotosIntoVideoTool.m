//
//  WZConvertPhotosIntoVideoTool.m
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZConvertPhotosIntoVideoTool.h"
#import <AVFoundation/AVFoundation.h>

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
//    _lock = [[NSLock alloc] init];
}

///中转
//- (CVPixelBufferRef *)copyNextPixelBufferToWrite {
//    //根据变量控制 buffer
//
//     if (_pixelBufferRef == NULL) { return NULL; }
//     NSLog(@"~~~~");
////     _pixelBufferRef = NULL;
//
//     return _pixelBufferRef;
//
//}

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
    _currentProgressTime = kCMTimeZero;
    
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
        //        _adaptor = []
        
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
    
    //信号指向ready状态
    _status = WZConvertPhotosIntoVideoToolStatus_Ready;
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
    
    //恢复状态
}

- (void)startRequestingFrames {
    [self prepareTask];
    
    if (_status != WZConvertPhotosIntoVideoToolStatus_Ready) {
        NSLog(@"error，当前状态并非：ready");
        return;
    }
   
    _status = WZConvertPhotosIntoVideoToolStatus_Converting;
    
    [_writer startWriting];
    [_writer startSessionAtSourceTime:kCMTimeZero];
    
    
    dispatch_queue_t queue = dispatch_queue_create([_queueID UTF8String], NULL);
    [_videoInput requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
        //队列中请求
        NSUInteger curIndex = 0;
        NSUInteger count = self.sources.count;
        while ([_videoInput isReadyForMoreMediaData]) {
          
            CVPixelBufferRef pbf = [[self class] pixelBufferFromCGImage:self.sources[curIndex].CGImage];
            curIndex++;
            if (count <= curIndex) {
                //继续
//                [self finishWriting];
                break;
            } else {
                
            }
            
            if (pbf) {
//                    CVPixelBufferRef* nextPixelBuffer = [self copyNextPixelBufferToWrite];
                if (![_adaptor appendPixelBuffer:pbf withPresentationTime:_currentProgressTime]) {
                    //append  fail
                    NSLog(@"_adaptor append fail");
                } else {
                    //时间根据帧率递增
                    _currentProgressTime = CMTimeAdd(_currentProgressTime, _frameRate);//时间递增
                }
                
//                    CVPixelBufferRelease(*_pixelBufferRef);
//                    _pixelBufferRef = NULL;
            } else if (_finishWritingSignal) {
                [self finishWriting];
                
                break;//退出循环
            } else {
                //waiting 数据
            }
         
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

- (void) testCompressionSession

{
    
  
    NSMutableArray *sources = [NSMutableArray array];
    for (NSUInteger i = 0; i < 8; i++) {
        UIImage *tmp = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"testImage%lu", i] ofType:@"jpg"]];
        [sources addObject:tmp];
    }
    
      NSArray *imageArr = sources;
    
    CGSize size = CGSizeMake(640, 1136);
    
    
    NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    
    
    
    NSError *error = nil;
    
    
    
    unlink([betaCompressionDirectory UTF8String]);
    
    
    
    //----initialize compression engine
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:betaCompressionDirectory]
                                  
                                                           fileType:AVFileTypeQuickTimeMovie
                                  
                                                              error:&error];
    
    NSParameterAssert(videoWriter);
    
    if(error)
        
        NSLog(@"error = %@", [error localizedDescription]);
    
    
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey, nil];
    
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           
                                                           [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                     
                                                                                                                     sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    NSParameterAssert(writerInput);
    
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    
    
    if ([videoWriter canAddInput:writerInput])
        
        NSLog(@"I can add this input");
    
    else
        
        NSLog(@"i can't add this input");
    
    
    
    [videoWriter addInput:writerInput];
    
    
    
    [videoWriter startWriting];
    
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    
    
    //---
    
    // insert demo debugging code to write the same image repeated as a movie
    
    
    
    CGImageRef theImage = [[UIImage imageNamed:@"114.png"] CGImage];
    
    
    
    dispatch_queue_t    dispatchQueue = dispatch_queue_create("mediaInputQueue", NULL);
    
    int __block         frame = 0;
    
    
    
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        
        while ([writerInput isReadyForMoreMediaData])
            
        {
            
            if(++frame >= imageArr.count * 40)
                
            {
                
                [writerInput markAsFinished];
                
                [videoWriter finishWriting];
                
                
                
                break;
                
            }
            
            int idx = frame/40;
            
            
            
            CVPixelBufferRef buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:(__bridge CGImageRef)([imageArr objectAtIndex:idx]) size:size];
            
            if (buffer)
                
            {
                
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame, 20)])
                    
                    NSLog(@"FAIL");
                
                else
                    
                    NSLog(@"Success:%d", frame);
                
                CFRelease(buffer);
                
            }
            
        }
        
    }];
    
    
    
    NSLog(@"outside for loop");
    
}





- (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size

{
    
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

@end
