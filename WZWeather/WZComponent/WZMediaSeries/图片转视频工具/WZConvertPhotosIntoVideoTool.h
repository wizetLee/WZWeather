//
//  WZConvertPhotosIntoVideoTool.h
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "WZConvertPhotosIntoVideoItem.h"

typedef NS_ENUM(NSUInteger, WZConvertPhotosIntoVideoToolStatus) {
    WZConvertPhotosIntoVideoToolStatus_Idle             = 0,
    WZConvertPhotosIntoVideoToolStatus_Ready,
    WZConvertPhotosIntoVideoToolStatus_Completed,
    WZConvertPhotosIntoVideoToolStatus_Failed,
    WZConvertPhotosIntoVideoToolStatus_Canceled,
    WZConvertPhotosIntoVideoToolStatus_Converting,
};

@class WZConvertPhotosIntoVideoTool;
@protocol WZConvertPhotosIntoVideoToolProtocol <NSObject>

//转换进度
- (void)convertPhotosInotViewTool:(WZConvertPhotosIntoVideoTool *)tool progress:(CGFloat)progress;

//已添加的帧数
- (void)convertPhotosInotViewTool:(WZConvertPhotosIntoVideoTool *)tool addedFrameCount:(NSUInteger)addedFrameCount;

//写入完成的回调
- (void)convertPhotosInotViewToolFinishWriting;

@end


/**
 先做预期准备   ready
    1)mov
    2)线程
    3)
 appendbuffer   time++
    1)Image
    2)pixelBuffer
    3)texture
 end
 
 
 考虑：
    关于声音？
    提供录制固定时间的接口？
 
 */

@interface WZConvertPhotosIntoVideoTool : NSObject

@property (nonatomic,   weak) id <WZConvertPhotosIntoVideoToolProtocol> delegate;
@property (nonatomic, assign, readonly) WZConvertPhotosIntoVideoToolStatus status;

///是否应该封闭这些接口
@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, assign) CMTime frameRate;         //default 25 / sec
@property (nonatomic, assign) CGSize outputSize;

- (instancetype)initWithOutputURL:(NSURL *)outputURL
                       outputSize:(CGSize)outputSize
                        frameRate:(CMTime)frameRate;//帧率

#pragma mark 录制固定时长的视频需要的配置
@property (nonatomic, assign) BOOL timeIsLimited;   //default：false  录制的时间是限定的，也就是固定了要录制多少帧。
@property (nonatomic, assign) CMTime limitedTime;   //限制的录制时间 it is useful when (timeIsLimited==true)

@property (nonatomic, strong, readonly) NSArray <UIImage *>*sources;  //数据源
@property (nonatomic, strong, readonly) NSMutableArray <WZConvertPhotosIntoVideoItem *>*transitionNodeMarr;

- (void)prepareTaskWithPictureSources:(NSArray <UIImage *>*)pictureSources;

- (void)prepareTask;                //开始之前的准备工作

- (void)startWriting;               //开始
- (void)finishWriting;              //完成
- (void)cancelWriting;              //取消

//add帧
#warning 非常需要解决内存不足的问题（也就是说代价太高昂)，考虑一种低成本的运作方式（当前使用了一个简单的解决方案：对于相同的图片使用缓存加帧，具体方案根据需求变更）
- (void)addFrameWithImage:(UIImage *)image;
- (void)addFrameWithCGImage:(CGImageRef)cgImage;
- (void)addFrameWithSample:(CVPixelBufferRef)buffer;

//利用缓存add帧
- (BOOL)hasCache;
- (void)addFrameWithCache;


#pragma mark - 以下为未完成
//- (void)needAudioInput:(BOOL)boolean;       //是否用音频  在ready状态之前设置好


@end
