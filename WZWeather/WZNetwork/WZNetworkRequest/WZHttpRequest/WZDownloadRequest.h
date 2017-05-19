//
//  WZDownloadRequest.h
//  WZWeather
//
//  Created by wizet on 17/5/15.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZDownloadTarget.h"

//可暂停 暂停重开始 终止

//完成回调 进程回调 错误回调

//文件是否存在

//文件存在是否要重新下载

//多任务下载

//断点下载

//后台下载

//多个任务是同一个URL的
//目前: 显示多个任务 只完成一个任务与另外的任务共享一份缓存
//或有需求: 只显示单个任务, 

//插入任务

//区分任务

//下载完成  发出通知
//下载失败  发出通知
//插入下载  发出通知

//控制并发数量

//单例？

typedef void (^DownloadTaskDidCompleteWithError)(NSMutableArray <WZDownloadTarget *>* _Nullable targets, NSError * _Nullable error);

//下载完成后 将源数据从临时路径转移到自定义路径中
typedef void (^DownloadTaskDidFinishDownload)(NSMutableArray <WZDownloadTarget *>* _Nullable targets, NSURL * _Nullable location);

//下载的进程
typedef void (^DownloadTaskDownloadProcess)(NSMutableArray <WZDownloadTarget *>* _Nullable targets);

@interface WZDownloadRequest : NSObject

@property (nonatomic, strong, readonly) NSMutableArray <WZDownloadTarget *> * _Nullable downloadTargets;
@property (nonatomic, strong, readonly) NSURLSession * _Nullable session;

+ (instancetype _Nullable)downloader;

- (void)downloadWithURLArray:(NSArray <NSURL * > * _Nullable)urlArray
             completedWithError:(DownloadTaskDidCompleteWithError _Nullable)completedWithError
               finishedDownload:(DownloadTaskDidFinishDownload _Nullable)finishedDownload
                downloadProcess:(DownloadTaskDownloadProcess _Nullable)downloadProcess;

- (void)suspendAllTasks;
- (void)suspendTaskWithURL:(NSURL *_Nullable)url;
- (void)cancelAllTasks;
- (void)cancelTaskWithURL:(NSURL *_Nullable)url;
- (void)resumeAllTasks;
- (void)resumeTaskWithURL:(NSURL *_Nullable)url;

double bytesTransitionKB(int64_t bytes);
double bytesTransitionMB(int64_t bytes);




@end
