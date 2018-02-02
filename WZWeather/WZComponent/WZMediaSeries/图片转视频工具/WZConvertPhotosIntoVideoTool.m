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
    CMSampleBufferRef _sampleBufferRef;
    
    BOOL _finishWritingSignal;                              //需要停止输入的信号
}

@property (nonatomic, assign) CMTime currentProgressTime;   //当前进度

@end

@implementation WZConvertPhotosIntoVideoTool

- (void)defaultConfig {
    _frameRate = CMTimeMake(1, 25);// fbs 25（30也是可以的）
    _finishWritingSignal = false;
    _queueID = @"wizet.serial.queue";
}



- (void)startTask {
    
}

- (void)addPixel:(CVPixelBufferRef)pbr {
//    _adaptor appendPixelBuffer:(nonnull CVPixelBufferRef) withPresentationTime:_currentProgressTime
    if (_status != WZConvertPhotosIntoVideoToolStatus_Converting) {
        NSLog(@"add 失败，状态错误");
        return;
    }
    _currentProgressTime = CMTimeAdd(_currentProgressTime, _frameRate);//时间递增
    
    dispatch_queue_t queue = dispatch_queue_create([_queueID UTF8String], NULL);
    [_videoInput requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
        //队列中请求
        while ([_videoInput isReadyForMoreMediaData]) {
            CMSampleBufferRef nextSampleBuffer = *[self copyNextSampleBufferToWrite];
            _sampleBufferRef = NULL;
            if (nextSampleBuffer) {
                [_videoInput appendSampleBuffer:nextSampleBuffer];
                CFRelease(nextSampleBuffer);
            } else if (_finishWritingSignal) {
                [self finishWriting];
                
                
                break;
            } else {
                //waiting 数据
            }
        }
    }];
}

- (void)finishWriting {
    [_videoInput markAsFinished];
    [_writer finishWritingWithCompletionHandler:^{
        
    }];
}

- (CMSampleBufferRef *)copyNextSampleBufferToWrite {
    //根据变量控制 buffer
    return &_sampleBufferRef;
}


//addBuffer
- (void)addSampleBufferRef:(CMSampleBufferRef)sbf {
    _sampleBufferRef = sbf;
}

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
            NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:@"wizet.mov"];
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
        
//
    }
}

@end
