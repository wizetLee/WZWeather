//
//  WZPureConvertPhotosIntoVideoTool.h
//  WZWeather
//
//  Created by admin on 22/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

typedef NS_ENUM(NSUInteger, WZPureConvertPhotosIntoVideoToolStatus) {
    WZPureConvertPhotosIntoVideoToolStatus_Idle             = 0,
    WZPureConvertPhotosIntoVideoToolStatus_Ready,
    WZPureConvertPhotosIntoVideoToolStatus_Completed,
    WZPureConvertPhotosIntoVideoToolStatus_Failed,
    WZPureConvertPhotosIntoVideoToolStatus_Canceled,
    WZPureConvertPhotosIntoVideoToolStatus_Converting,
};

@class WZPureConvertPhotosIntoVideoTool;
@protocol WZPureConvertPhotosIntoVideoToolProtocol <NSObject>

//写入完成的回调
- (void)puregraphicsToVideoToolTaskFinished;

- (void)puregraphicsToVideoTool:(WZPureConvertPhotosIntoVideoTool *)tool addedFrameCount:(NSUInteger)addedFrameCount;

@end

@interface WZPureConvertPhotosIntoVideoTool : NSObject

@property (nonatomic,   weak) id <WZPureConvertPhotosIntoVideoToolProtocol> delegate;
@property (nonatomic, assign, readonly) WZPureConvertPhotosIntoVideoToolStatus status;

///是否应该封闭这些接口
@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, assign) CMTime frameRate;         //default 25 / sec
@property (nonatomic, assign) CGSize outputSize;

- (instancetype)initWithOutputURL:(NSURL *)outputURL
                       outputSize:(CGSize)outputSize
                        frameRate:(CMTime)frameRate;    //帧率

#pragma mark 录制固定时长的视频需要的配置
@property (nonatomic, assign) BOOL timeIsLimited;   //default：false  录制的时间是限定的，也就是固定了要录制多少帧。
@property (nonatomic, assign) CMTime limitedTime;   //限制的录制时间 it is useful when (timeIsLimited==true)

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
- (void)addFrameWithCache;
- (BOOL)hasCache;
- (void)cleanCache;

@end
