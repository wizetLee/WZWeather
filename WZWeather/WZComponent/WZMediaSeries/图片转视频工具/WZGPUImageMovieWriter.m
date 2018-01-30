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
                                         [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                         [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
                                         [ NSNumber numberWithFloat: [[AVAudioSession sharedInstance] sampleRate] ], AVSampleRateKey,
                                         [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
                                         //[ NSNumber numberWithInt:AVAudioQualityLow], AVEncoderAudioQualityKey,
                                         [ NSNumber numberWithInt: 64000 ], AVEncoderBitRateKey,
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
}


#pragma mark -
#pragma mark GPUImageInput protocol

@end
