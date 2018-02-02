//
//  WZConvertPhotosIntoVideoTool.h
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WZConvertPhotosIntoVideoToolStatus) {
    WZConvertPhotosIntoVideoToolStatus_Idle             = 0,
    WZConvertPhotosIntoVideoToolStatus_Ready,
    WZConvertPhotosIntoVideoToolStatus_Completed,
    WZConvertPhotosIntoVideoToolStatus_Failed,
    WZConvertPhotosIntoVideoToolStatus_Converting,
};

@class WZConvertPhotosIntoVideoTool;
@protocol WZConvertPhotosIntoVideoToolProtocol <NSObject>

- (void)convertPhotosInotViewTool:(WZConvertPhotosIntoVideoTool *)tool progress:(CGFloat)progress;

//写入完成的回调
- (void)convertPhotosInotViewTool:(WZConvertPhotosIntoVideoTool *)tool finishWritingWithCompletionHandler:(void (^)())CompletionHandler;

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

@property (nonatomic,   weak) id <WZConvertPhotosIntoVideoToolProtocol>delegate;
@property (nonatomic, assign) WZConvertPhotosIntoVideoToolStatus status;

@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, assign) CMTime frameRate;
@property (nonatomic, assign) CGSize outputSize;



#pragma mark - 以下为未完成
- (void)needAudioInput:(BOOL)boolean;       //是否用音频  在ready状态之前设置好

@end
