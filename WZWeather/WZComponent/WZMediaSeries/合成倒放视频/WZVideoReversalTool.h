//
//  WZVideoReversalTool.h
//  WZWeather
//
//  Created by 李炜钊 on 2018/2/27.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, WZVideoReversalToolStatus) {
    WZVideoReversalToolStatus_Idle              = 0,//空闲状态
    WZVideoReversalToolStatus_converting,
    WZVideoReversalToolStatus_Canceled,
    WZVideoReversalToolStatus_Failed,
    WZVideoReversalToolStatus_Completed,
};

@class WZVideoReversalTool;
@protocol WZVideoReversalToolProtocol <NSObject>

//进度（其实也算不上是进度，因为没有算上前面几个循环的遍历时间，这里的进度仅指的是adaptor添加buffer的进度）
- (void)videoReversakTool:(WZVideoReversalTool *)tool reverseProgress:(float)progress;
//完成
- (void)videoReversakToolReverseSuccessed;
//失败
- (void)videoReversakToolReverseFail;
//取消
- (void)videoReversakToolReverseDidCancel;

@end

//保存为mov格式的视频
@interface WZVideoReversalTool : NSObject

@property (nonatomic, weak) id <WZVideoReversalToolProtocol>delegate;
@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, assign, readonly) WZVideoReversalToolStatus status;

//开始任务
- (void)reverseWithAsset:(AVAsset *)asset;
//取消任务
- (void)cancelReverseTask;

@end
