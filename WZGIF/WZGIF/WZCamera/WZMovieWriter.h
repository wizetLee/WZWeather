//
//  WZMovieWriter.h
//  WZGIF
//
//  Created by wizet on 2017/7/30.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@class WZMovieWriter;
@protocol WZMovieWriterProtocol <NSObject>
@optional

/**
 写入文件完毕

 @param movieWriter 写入器
 @param error 写入出错
 @param movieOutputURL 写入的文件路径
 */
- (void)movieWriter:(WZMovieWriter *)movieWriter finishWritingWithError:(NSError *)error MovieOutputURL:(NSURL *)movieOutputURL;


/**
 写入被中断了

 @param movieWriter 写入器
 @param error 中断错误
 */
- (void)movieWriter:(WZMovieWriter *)movieWriter interruptedWithError:(NSError *)error;

@end

@interface WZMovieWriter : NSObject

@property (nonatomic, weak) id<WZMovieWriterProtocol> delegate;

- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings
              audioSettings:(NSDictionary *)audioSettings
                  outputURL:(NSURL *)outputURL;

- (void)handleSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)finishWriting;

@end
