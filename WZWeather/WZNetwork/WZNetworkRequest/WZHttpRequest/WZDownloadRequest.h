//
//  WZDownloadRequest.h
//  WZWeather
//
//  Created by admin on 17/5/15.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

//可暂停 暂停重开始 终止

//完成回调 进程回调 错误回调

//文件是否存在

//文件存在是否要重新下载

//多任务下载

//断点下载

//后台下载

//多个任务是同一个URL的 只完成一个任务与另外的任务共享一份缓存

//插入任务

//区分任务

//下载完成  发出通知
//下载失败  发出通知
//插入下载  发出通知

/**
 *  某个task 无论失败还是成功的最终的回调
 *  多任务通过taskIdentifier判定
 *  @param error
 */
typedef void (^wz_downloadTaskDidCompleteWithError)(NSURLSessionTask * _Nullable task, NSURL * _Nullable url, NSError * _Nullable error);

//下载完成后 将源数据从临时路径转移到自定义路径中
typedef void (^wz_downloadTaskDidFinishDownload)(NSURLSessionTask * _Nullable task, NSURL * _Nullable url, NSURL * _Nullable location);

//下载的进程
typedef void (^wz_downloadTaskDownloadProcess)(NSURLSessionDownloadTask * _Nullable downloadTask,
                                               NSURL * _Nullable url,
                                               int64_t bytesWritten,
                                               int64_t totalBytesWritten,
                                               int64_t totalBytesExpectedToWrite);

@interface WZDownloadRequest : NSObject

@property (nonatomic, strong) NSURLSession * _Nullable session;
@property (nonatomic, strong) NSMutableDictionary * _Nullable downloadTasksMDic;


+ (instancetype _Nullable)downloader;

//手动销毁session
- (void)finishTasksAndInvalidate;

- (void)wz_downloadWithURLArray:(NSArray <NSURL * > * _Nullable)urlArray
                     invalidate:(BOOL)boolean
             completedWithError:(wz_downloadTaskDidCompleteWithError _Nullable)completedWithError
               finishedDownload:(wz_downloadTaskDidFinishDownload _Nullable)finishedDownload
                downloadProcess:(wz_downloadTaskDownloadProcess _Nullable)downloadProcess;

// downloadTasksMDic 获取 value 的统一规则
NSString * _Nullable valueForDownloadTasksMDicWithURL(NSURL * _Nullable url);

- (void)suspendAllTask;
- (void)suspendTaskWithURL:(NSURL *_Nullable)url;
- (void)cancelAllTask;
- (void)cancelTaskWithURL:(NSURL *_Nullable)url;
- (void)resumeAllTask;
- (void)resumeTaskWithURL:(NSURL *_Nullable)url;

@end
