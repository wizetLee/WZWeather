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

/**
 *  某个task 无论失败还是成功的最终的回调
 *  多任务通过taskIdentifier判定
 *  @param error
 */

typedef void (^wz_downloadTaskDidCompleteWithError)(NSURLSessionTask * _Nullable task, NSError * _Nullable error);

//下载完成后 将源数据从临时路径转移到自定义路径中
typedef void (^wz_downloadTaskDidFinishDownload)(NSURLSessionTask * _Nullable task, NSURL * _Nullable location);

//下载的进程
typedef void (^wz_downloadTaskDownloadProcess)(NSURLSessionDownloadTask * _Nullable downloadTask,
                                               int64_t bytesWritten,
                                               int64_t totalBytesWritten,
                                               int64_t totalBytesExpectedToWrite);

@interface WZDownloadRequest : NSObject

@property (nonatomic, strong) NSURLSession * _Nullable session;
@property (nonatomic, strong) NSMutableDictionary * _Nullable downloadTasksMDic;

+ (instancetype _Nullable)downloader;

- (void)wz_downloadWithURL:(NSURL * _Nullable)url
      finishWhenInvalidate:(BOOL)boolean
        completedWithError:(wz_downloadTaskDidCompleteWithError _Nullable)completedWithError
          finishedDownload:(wz_downloadTaskDidFinishDownload _Nullable)finishedDownload
           downloadProcess:(wz_downloadTaskDownloadProcess _Nullable)downloadProcess;


- (void)suspendAllTask;
- (void)suspendTaskWithURL:(NSURL *_Nullable)url;
- (void)cancelAllTask;
- (void)cancelTaskWithURL:(NSURL *_Nullable)url;
- (void)resumeAllTask;
- (void)resumeTaskWithURL:(NSURL *_Nullable)url;

@end
