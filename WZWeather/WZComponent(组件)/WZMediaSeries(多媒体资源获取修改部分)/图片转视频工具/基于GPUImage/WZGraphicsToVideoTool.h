//
//  WZGraphicsToVideoTool.h
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "WZGraphicsToVideoItem.h"
#import "WZGraphicsToVideoFilter.h"

typedef NS_ENUM(NSUInteger, WZGraphicsToVideoToolStatus) {
    WZGraphicsToVideoToolStatus_Idle             = 0,
    WZGraphicsToVideoToolStatus_Ready,
    WZGraphicsToVideoToolStatus_Completed,
    WZGraphicsToVideoToolStatus_Failed,
    WZGraphicsToVideoToolStatus_Canceled,
    WZGraphicsToVideoToolStatus_Converting,
};

@class WZGraphicsToVideoTool;
@protocol WZGraphicsToVideoToolProtocol <NSObject>

//转换进度
- (void)graphicsToVideoTool:(WZGraphicsToVideoTool *)tool progress:(CGFloat)progress;

//已添加的帧数
- (void)graphicsToVideoTool:(WZGraphicsToVideoTool *)tool addedFrameCount:(NSUInteger)addedFrameCount;

//写入完成的回调
- (void)graphicsToVideoToolTaskFinished;

//canceled
- (void)graphicsToVideoToolTaskCanceled;

//fail
//- (void)GraphicsToVideoToolTaskFailed;

@end


/**
 先做预期准备   ready
    1)mov
    2)线程
    3)and so on
 appendbuffer   time++
    1)Image
    2)pixelBuffer
    3)texture
 end
 
 
 考虑新增：
    关于声音？
    提供录制固定时间的接口？
 
 */

@interface WZGraphicsToVideoTool : NSObject 

@property (nonatomic,   weak) id <WZGraphicsToVideoToolProtocol> delegate;
@property (nonatomic, assign, readonly) WZGraphicsToVideoToolStatus status;

///是否应该封闭这些接口
@property (nonatomic, strong, readonly) NSURL *outputURL;
@property (nonatomic, assign) CMTime frameRate;         //default 25 / sec
@property (nonatomic, assign) CGSize outputSize;


- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithOutputURL:(NSURL *)outputURL
                       outputSize:(CGSize)outputSize
                        frameRate:(CMTime)frameRate;//帧率

#pragma mark 录制固定时长的视频需要的配置
@property (nonatomic, assign) BOOL timeIsLimited;   //default：false  录制的时间是限定的，也就是固定了要录制多少帧。
@property (nonatomic, assign) CMTime limitedTime;   //限制的录制时间 it is useful when (timeIsLimited==true)

@property (nonatomic, strong, readonly) NSArray <UIImage *>*sources;  //数据源
@property (nonatomic, strong, readonly) NSMutableArray <WZGraphicsToVideoItem *>*transitionNodeMarr;

- (void)prepareTaskWithPictureSources:(NSArray <UIImage *>*)pictureSources;

- (void)prepareTask;                //开始之前的准备工作

- (void)startWriting;               //开始
- (void)finishWriting;              //完成
- (void)cancelWriting;              //取消


#pragma mark - 未完成
//- (void)needAudioInput:(BOOL)boolean;       //是否用音频  在ready状态之前设置好


@end
