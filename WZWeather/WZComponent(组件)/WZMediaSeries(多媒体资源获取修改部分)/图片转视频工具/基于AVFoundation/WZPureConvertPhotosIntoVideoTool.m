//
//  WZPureConvertPhotosIntoVideoTool.m
//  WZWeather
//
//  Created by admin on 22/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZPureConvertPhotosIntoVideoTool.h"

@interface WZPureConvertPhotosIntoVideoTool () {
    AVAssetWriter *_writer;
    AVAssetWriterInputPixelBufferAdaptor *_adaptor;
    AVAssetWriterInput *_videoInput;
    NSUInteger _frameCount;                                  //帧数 由limitedTime->frameRate得到
    CVPixelBufferRef _tmpPBR;
    
    NSUInteger _addedFrameCount;                         //已添加的帧数

}

@property (nonatomic, assign) CMTime currentProgressTime;   //当前进度
@property (nonatomic, assign) WZPureConvertPhotosIntoVideoToolStatus status;

@end

@implementation WZPureConvertPhotosIntoVideoTool
#pragma mark - Initialization
- (instancetype)initWithOutputURL:(NSURL *)outputURL
                       outputSize:(CGSize)outputSize
                        frameRate:(CMTime)frameRate {
    self = [super init];
    if (self) {
        [self defaultConfig];
        
        self.outputSize = outputSize;
        self.frameRate = frameRate;
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
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    if (_tmpPBR) {
        CVPixelBufferRelease(_tmpPBR);
        _tmpPBR = NULL;
    }
    _writer = nil;
    _adaptor = nil;
    _videoInput = nil;
}

- (BOOL)configurable {
    if (_status == WZPureConvertPhotosIntoVideoToolStatus_Idle
        || _status == WZPureConvertPhotosIntoVideoToolStatus_Ready) {
        return true;
    }
    NSLog(@"状态出错，设置属性失败");
    return false;
}

- (void)cleanCache {
    if (_tmpPBR) {
        CVPixelBufferRelease(_tmpPBR);
        _tmpPBR = NULL;
    }
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

#pragma mark - Public
- (void)prepareTask {
    //初始化一些工具
    if (_status != WZPureConvertPhotosIntoVideoToolStatus_Idle) {
        NSLog(@"%s，状态错误", __func__);
        return;
    }
    
    NSError *error = nil;
    {//文件部分
        if (_outputURL && [_outputURL isFileURL]) {} else {
            //使用自定义的路径
            NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:@"WZGraphicsToVideoTool.mov"];
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
        _status = WZPureConvertPhotosIntoVideoToolStatus_Ready;
    }
}

- (void)finishWriting {
    
    _status = WZPureConvertPhotosIntoVideoToolStatus_Completed;
    [_videoInput markAsFinished];
    [_writer finishWritingWithCompletionHandler:^{
        if ([_delegate respondsToSelector:@selector(puregraphicsToVideoToolTaskFinished)]) {
            [_delegate puregraphicsToVideoToolTaskFinished];
        }
    }];
    
    [self cleanCache];
}


- (void)startWriting {
    if (_status == WZPureConvertPhotosIntoVideoToolStatus_Ready) {
        //首次add 的配置
        [_writer startWriting];
        [_writer startSessionAtSourceTime:kCMTimeZero];
        _status = WZPureConvertPhotosIntoVideoToolStatus_Converting;
    } else {
        NSLog(@"状态出错");
    }
}

- (void)cancelWriting {
    [_videoInput markAsFinished];
    [_writer cancelWriting];
    _status = WZPureConvertPhotosIntoVideoToolStatus_Canceled;
    [self cleanCache];
}

- (void)addFrameWithCGImage:(CGImageRef)cgImage {
    if (_status != WZPureConvertPhotosIntoVideoToolStatus_Converting) {
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
            return;
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
    if (_status != WZPureConvertPhotosIntoVideoToolStatus_Converting) {
        return;
    }
    
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
                //时间根据帧率递增，调整当前的进度时间
                _currentProgressTime = CMTimeAdd(_currentProgressTime, _frameRate);//时间递增
                
                if ([_delegate respondsToSelector:@selector(puregraphicsToVideoTool:addedFrameCount:)]) {
                    [_delegate puregraphicsToVideoTool:self addedFrameCount:_addedFrameCount];
                }
            }
            CVPixelBufferUnlockBaseAddress(buffer, 0);
            //            CVPixelBufferRelease(buffer);///初发现 有内存泄漏的情况，原来是buffer没有释放掉(在适当的时候释放).
        } else {
            NSLog(@"丢丢丢丢丢丢丢丢帧啦");
        }
    } else {
        NSLog(@"丢丢丢丢丢丢丢丢帧啦");
    }
    
}

- (BOOL)hasCache {
    return (_tmpPBR)?true:false;
}

- (void)addFrameWithCache {
    if (_tmpPBR) {
        [self addFrameWithSample:_tmpPBR];
    } else {
        NSLog(@"并无缓存");
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

#pragma mark - WZGraphicsToVideoItemProtocol
- (void)itemDidCompleteConversion {
    [self cleanCache];
}


@end
