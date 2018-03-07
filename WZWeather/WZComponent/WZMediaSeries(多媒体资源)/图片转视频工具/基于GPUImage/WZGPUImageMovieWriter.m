//
//  WZGPUImageMovieWriter.m
//  WZWeather
//
//  Created by wizet on 30/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZGPUImageMovieWriter.h"
#import <AVFoundation/AVFoundation.h>

@interface WZGPUImageMovieWriter()
{
    AVAssetWriter *writer;
    
    
    GLuint movieFramebuffer, movieRenderbuffer;                 //句柄
    
    GLProgram *colorSwizzlingProgram;                           //program 颜色转换着色器程序
    
    GLint colorSwizzlingPositionAttribute, colorSwizzlingTextureCoordinateAttribute; //VSHposition句柄， FSH纹理坐标句柄
    
    GLint colorSwizzlingInputTextureUniform;                    //纹理句柄
    
    GPUImageFramebuffer *firstInputFramebuffer;                 //一个帧的buffer（从摄像头采集一次就输入一次）
    
    CMTime startTime, previousFrameTime, previousAudioTime;
    
    dispatch_queue_t audioQueue, videoQueue;                    //音频队列，视频队列
    BOOL audioEncodingIsFinished, videoEncodingIsFinished;      //编码完成标志
    
    BOOL isRecording;                                           //录制状态
}


@end

@implementation WZGPUImageMovieWriter

- (void)action {
    CGSize videoSize = CGSizeMake(400, 1164);
    NSMutableDictionary *outputSettings = [[NSMutableDictionary alloc] init];
    [outputSettings setObject:AVVideoCodecH264 forKey:AVVideoCodecKey];
    [outputSettings setObject:[NSNumber numberWithInt:videoSize.width] forKey:AVVideoWidthKey];
    [outputSettings setObject:[NSNumber numberWithInt:videoSize.height] forKey:AVVideoHeightKey];
    
    NSURL *movieURL = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:@"wizet.mov"]];
    AVAssetWriter *assetWriter = [[AVAssetWriter alloc] initWithURL:movieURL fileType:AVFileTypeQuickTimeMovie error:nil];
    AVAssetWriterInput *input0 = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    AVAssetWriterInput *input1 = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    NSDictionary *audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                         [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                         [ NSNumber numberWithFloat: [[AVAudioSession sharedInstance] sampleRate]], AVSampleRateKey,
                                         [NSData dataWithBytes:&acl length: sizeof(acl)], AVChannelLayoutKey,
                                         //[ NSNumber numberWithInt:AVAudioQualityLow], AVEncoderAudioQualityKey,
                                         [NSNumber numberWithInt:64000], AVEncoderBitRateKey,
                                         nil];
    
    AVAssetWriterInput *assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
    //    assetWriterAudioInput.expectsMediaDataInRealTime = true;//如果数据源是实时采集的则设置为true
    AVAssetWriterInput *assetWriterAudioInput1 = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
    if ([assetWriter canAddInput:input0]) {
        NSLog(@"input0");
        [assetWriter addInput:input0];
    }
    if ([assetWriter canAddInput:input1]) {
        NSLog(@"input1");
        [assetWriter addInput:input0];
    }
    if ([assetWriter canAddInput:assetWriterAudioInput]) {
        NSLog(@"assetWriterAudioInput");
    }
    if ([assetWriter canAddInput:assetWriterAudioInput1]) {
        NSLog(@"assetWriterAudioInput1");
    }
    
    //关于时间的计算
    NSUInteger frameRate = 25;
    CMTime frameTime = CMTimeMake(0, 600);
    frameTime = CMTimeAdd(frameTime, CMTimeMakeWithSeconds(1.0 / frameRate, 600));
    
}

///开始写入
- (void)startWriting {
    //重新配置writer
    
    if (writer && writer.status == AVAssetWriterStatusWriting) {
        //已经开始了，不能再进入
        return;
    }
    
    AVFileType type = AVFileTypeQuickTimeMovie;
    
    NSURL *outputURL = [NSURL fileURLWithPath:@""];
    NSError *error = nil;
    writer = [[AVAssetWriter alloc] initWithURL:outputURL fileType:type error:&error];
    if (error) {
        NSLog(@"初始化Writer出错：error = %@", error.description);
    }
    
    writer.movieFragmentInterval = CMTimeMake(0.1, 600);//段频率
    
    NSMutableDictionary *outputSettings = NSMutableDictionary.dictionary;
    CGSize outputSize = CGSizeMake(2, 2);//   x % 2 = 0
    outputSettings[AVVideoWidthKey] = @(outputSize.width);
    outputSettings[AVVideoHeightKey] = @(outputSize.height);
    outputSettings[AVVideoCodecKey] = AVVideoCodecH264;
    
    AVAssetWriterInput *writerInput  = [[AVAssetWriterInput alloc] initWithMediaType:type outputSettings:outputSettings];
//    writerInput.expectsMediaDataInRealTime = //是否实时写入 写图片时为false
//    writerInput.transform = //方向修改
    
    NSMutableDictionary *sourcePixelBufferAttributes = NSMutableDictionary.dictionary;
    sourcePixelBufferAttributes[(__bridge id)kCVPixelBufferPixelFormatTypeKey] = @(kCVPixelFormatType_32BGRA);
    sourcePixelBufferAttributes[(__bridge id)kCVPixelBufferWidthKey] = @(outputSize.width);
    sourcePixelBufferAttributes[(__bridge id)kCVPixelBufferHeightKey] = @(outputSize.height);
    
    AVAssetWriterInputPixelBufferAdaptor *writerInputPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributes];
 
    if ([writer canAddInput:writerInput]) {
        [writer addInput:writerInput];
    }
    BOOL needVoice = false;
    if (needVoice) {
        outputSettings = NSMutableDictionary.dictionary;
        
        AudioChannelLayout acl;
        bzero( &acl, sizeof(acl));
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        
        double SampleRate                       = 44100;
        outputSettings[AVFormatIDKey]           = @(kAudioFormatMPEG4AAC);
        outputSettings[AVNumberOfChannelsKey]   = @(1);
        outputSettings[AVSampleRateKey]         = @(SampleRate);
        outputSettings[AVChannelLayoutKey]      = [NSData dataWithBytes:&acl length: sizeof(acl)];
        outputSettings[AVEncoderBitRateKey]     = @(64000);
        
        AVAssetWriterInput *audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:outputSettings];
        
        if ([writer canAddInput:audioInput]) {
            [writer addInput:audioInput];
        }
    }
    
}


#pragma mark -
#pragma mark GPUImageInput protocol

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex; {
    
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex; {
    
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex; {
    
}


@end
