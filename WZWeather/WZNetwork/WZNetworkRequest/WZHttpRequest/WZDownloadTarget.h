//
//  WZDownloadTarget.h
//  WZWeather
//
//  Created by wizet on 17/5/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

//#import "WZVariousCollectionBaseObject.h"

#import "WZVariousBaseObject.h"

@class WZDownloadRequest;
@protocol WZDownloadtargetDelegate <NSObject>

- (void)progressCallBack:(NSDictionary *)callBack;

@end

@interface WZDownloadTarget : WZVariousBaseObject

@property (nonatomic, weak) id<WZDownloadtargetDelegate> delegate;//消息回调
@property (nonatomic, weak) WZDownloadRequest *downloadRequest;
@property (nonatomic, strong) NSURL *url;//任务URL
@property (nonatomic, strong) NSData *resumeData;//缓存数据
@property (nonatomic, strong) NSURLSessionDownloadTask *task;//当前任务

@property (nonatomic, assign) BOOL completion;//任务完成
@property (nonatomic, assign) BOOL pause;//任务暂停
@property (nonatomic, assign) BOOL cancel;//任务取消

@property (nonatomic, assign) int64_t bytesWritten;//本次报文得到的字节
@property (nonatomic, assign) int64_t totalBytesWritten;//当前任务进度
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;//任务总进度

@end
