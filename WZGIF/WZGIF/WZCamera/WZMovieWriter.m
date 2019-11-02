//
//  WZMovieWriter.m
//  WZGIF
//
//  Created by wizet on 2017/7/30.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMovieWriter.h"
#import <CoreImage/CoreImage.h>

@interface WZMovieWriter()
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;

@property (nonatomic, strong) NSDictionary *videoSettings;
@property (nonatomic, strong) NSDictionary *audioSettings;

@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, assign) BOOL available;
@property (nonatomic, assign) BOOL hasInputed;

@end

@implementation WZMovieWriter


- (instancetype)initWithOutputURL:(NSURL *)outputURL {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings
              audioSettings:(NSDictionary *)audioSettings
                  outputURL:(NSURL *)outputURL {
    if (self = [super init]) {
        _videoSettings = videoSettings;
        _audioSettings = audioSettings;
        self.outputURL = outputURL;
        [self configAssetWriter];
    }
    return self;
}

- (void)configAssetWriter {
    _available = true;
    NSError *error = nil;
    //文件类型为mp4（可以放出接口控制输出文件类型）PS：配合outputURL的输出文件格式
    NSString *fileType = AVFileTypeMPEG4;
    //文件移除
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.outputURL.path]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.outputURL.path error:nil];
    }
    
    _assetWriter = [AVAssetWriter assetWriterWithURL:self.outputURL
                                                fileType:fileType
                                                   error:&error];
    if (!_assetWriter || error) {
        NSLog(@"AVAssetWriter初始化失败：%@", error.description);
        _available = false;
    }
    
    _assetWriterVideoInput =
    [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                   outputSettings:_videoSettings];
    _assetWriterAudioInput =
    [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio
                                   outputSettings:_audioSettings];
    //设置 expectsMediaDataInRealTime 为 true 确保 readyForMoreMediaData 被正确计算
    _assetWriterVideoInput.expectsMediaDataInRealTime = true;
    _assetWriterAudioInput.expectsMediaDataInRealTime = true;
    
    if ([_assetWriter canAddInput:_assetWriterVideoInput]) {
        [_assetWriter addInput:_assetWriterVideoInput];
    } else {
        NSLog(@"videoIntput加入失败");
        _available = false;
    }
    
    if ([_assetWriter canAddInput:_assetWriterAudioInput]) {
        [_assetWriter addInput:_assetWriterAudioInput];
    } else {
        NSLog(@"audioIntput加入失败");
        _available = false;
    }
    
}

- (void)finishWriting {
    if (!_available
        || !_hasInputed) {
        NSLog(@"movie writer 不可用");
        NSError *error = [NSError errorWithDomain:@"未录制成功" code:-1 userInfo:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_delegate respondsToSelector:@selector(movieWriter:finishWritingWithError:MovieOutputURL:)]) {
                [_delegate movieWriter:self finishWritingWithError:error MovieOutputURL:nil];
            }
        });
        return;
    }
    
    [self.assetWriter finishWritingWithCompletionHandler:^{
        NSURL *url = nil;
        NSError *error = nil;
        
        if (self.assetWriter.status == AVAssetWriterStatusCompleted) {
            url = self.assetWriter.outputURL;
            NSLog(@"~~%ld", [NSData dataWithContentsOfURL:self.assetWriter.outputURL].length);
        } else if (self.assetWriter.status == AVAssetWriterStatusFailed) {
            error = self.assetWriter.error;
        }
        if (!error && !url) {
            error = [NSError errorWithDomain:@"录制出错" code:-1 userInfo:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_delegate respondsToSelector:@selector(movieWriter:finishWritingWithError:MovieOutputURL:)]) {
                [_delegate movieWriter:self finishWritingWithError:error MovieOutputURL:url];
            }
        });
    }];
    _available = false;
    _hasInputed = false;
}

- (void)handleSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (!_available) {
        NSLog(@"movie writer 不可用");
        return;
    }
    
    if (!sampleBuffer) {
        return;
    }
    
    //数据是否准备写入
    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        
        //先判断buffer类型
        CMFormatDescriptionRef formatDesc =
        CMSampleBufferGetFormatDescription(sampleBuffer);
        CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDesc);
        //保证视频先写入
        if (self.assetWriter.status == AVAssetWriterStatusUnknown
            && mediaType == kCMMediaType_Video) {
            //获取开始写入的CMTime
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            //开始写入
            [self.assetWriter startWriting];
            [self.assetWriter startSessionAtSourceTime:startTime];
        }
        
        //需要返回一个中断状态 不再能进行写数据的操作 强制返回 必须要重新设置writer
        if (self.assetWriter.status == AVAssetWriterStatusFailed) {
            NSLog(@"writer error %@", self.assetWriter.error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(movieWriter:interruptedWithError:)]) {
                    [_delegate movieWriter:self interruptedWithError:self.assetWriter.error];
                }
            });
            return;
        }
        
        if (mediaType == kCMMediaType_Video) {
            if (self.assetWriterVideoInput.readyForMoreMediaData) {
                if ([self.assetWriterVideoInput appendSampleBuffer:sampleBuffer]) {
                    _hasInputed = true;
                };
                
            }
        } else if (mediaType == kCMMediaType_Audio) {
            if (self.assetWriterAudioInput.isReadyForMoreMediaData) {
                if ([self.assetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
                    _hasInputed = true;
                };
            }
        }
    }
}

#pragma mark - Accessor
- (NSURL *)outputURL {
    if (!_outputURL) {
        
        NSString *filename = [NSString stringWithFormat:@"wizetMovie.%@", @"mp4"];
        //设定存储位置
        NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        NSURL *fileURL = [NSURL fileURLWithPath:myPathList.firstObject];
        fileURL = [fileURL URLByAppendingPathComponent:filename];//配置 文件名字+后缀
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        }
        
        _outputURL = fileURL;
    }
    return _outputURL;
}

@end
