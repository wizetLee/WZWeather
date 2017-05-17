//
//  WZDownloadRequest.m
//  WZWeather
//
//  Created by admin on 17/5/15.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZDownloadRequest.h"

@interface WZDownloadRequest()

@property (nonatomic, strong) NSURLSession * _Nullable session;

@property (nonatomic, strong) DownloadTaskDidCompleteWithError _Nullable completedWithError;
@property (nonatomic, strong) DownloadTaskDidFinishDownload _Nullable finishedDownload;
@property (nonatomic, strong) DownloadTaskDownloadProcess _Nullable downloadProcess;
//@property (nonatomic, strong) NSMutableDictionary <NSString *, NSURLSessionDownloadTask *>* _Nullable downloadTasksMDic;
//@property (nonatomic, strong) NSMutableDictionary <NSString *, NSData *>* _Nullable suspendTasksMDic;
@property (nonatomic, strong) NSMutableArray <WZDownloadTarget *> * _Nullable downloadTargets;

@end

@implementation WZDownloadRequest

NSString * keyForTasksMDicWithURL(NSURL * url);
void downloadActionWithURLArray(NSArray <NSURL *> * urlArray);

- (instancetype)init
{
    self = [super init];
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDownloadDelegate>)self delegateQueue:[NSOperationQueue mainQueue]];
//        _downloadTasksMDic = [NSMutableDictionary dictionary];
//        _suspendTasksMDic = [NSMutableDictionary dictionary];
        _downloadTargets = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)downloader {
    WZDownloadRequest *downloader = [[WZDownloadRequest alloc] init];
    return downloader;
}

- (void)downloadWithURLArray:(NSArray <NSURL *>*)urlArray
             completedWithError:(DownloadTaskDidCompleteWithError _Nullable)completedWithError
               finishedDownload:(DownloadTaskDidFinishDownload _Nullable)finishedDownload
                downloadProcess:(DownloadTaskDownloadProcess _Nullable)downloadProcess {
    _completedWithError = completedWithError;
    _finishedDownload = finishedDownload;
    _downloadProcess = downloadProcess;
//    downloadActionWith(urlArray, _downloadTasksMDic, _session, _downloadTargets);
}


- (void)insertDownloadTasksWithURLArray:(NSArray <NSURL *>*)urlArray {
//    downloadActionWith(urlArray, _downloadTasksMDic, _session, _downloadTargets);
}

//使session无效
- (void)finishTasksAndInvalidate {
    [self.session finishTasksAndInvalidate];
}


- (void)downloadAction:(NSArray <WZDownloadTarget *> *)downloadTarget session:(NSURLSession *)session {
    //减少了文件检查步骤
    
    //检查任务url
    
    for (WZDownloadTarget *traget in downloadTarget) {
        if (traget.resumeData) {
            //存在缓存
        } else {
            if (traget.url) {
                //任务开始
            } else {
                //移除自己
            }
        }
    }
    
}

//已经被下载的文件不会重复下载
void downloadActionWith(NSArray <NSURL *> * urlArray, NSDictionary * downloadTasksMDic, NSURLSession *session , NSMutableArray *downloadTargets) {
   
    //检查文件是否已经被下载
    NSMutableArray <NSURL *>* tmpUrlArray = [NSMutableArray arrayWithArray:urlArray];
    for (NSURL * url in urlArray) {
        if (wz_fileExistsAtPath(wz_filePath(WZSearchPathDirectoryTemporary, url.lastPathComponent))) {
            [tmpUrlArray removeObject:url];
        }
        
    //检查文件是否有缓存
    }
    
    //下载文件
    for (NSURL *url in tmpUrlArray) {
        
        if (downloadTasksMDic[keyForTasksMDicWithURL(url)]) {
            continue;
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.timeoutInterval = 15.0;
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
        
        WZDownloadTarget *target = [[WZDownloadTarget alloc] init];
        target.task = downloadTask;
        
        //存储本任务
        [downloadTargets addObject:target];
    
        //添加标识
        [downloadTasksMDic setValue:downloadTask forKey:keyForTasksMDicWithURL(url)];
        
        [downloadTask resume];
    }
}

//rule for the TaskMDic
NSString * keyForTasksMDicWithURL(NSURL * url) {
    return [url lastPathComponent];
}

- (NSURLSessionDownloadTask *)downloadTaskWithURl:(NSURL *)url {
    NSURLSessionDownloadTask *downloadTask = nil;
   
//    if (self.downloadTasksMDic[keyForTasksMDicWithURL(url)]) {
//        downloadTask = self.downloadTasksMDic[keyForTasksMDicWithURL(url)];
//    }
    
    return downloadTask;
}

#pragma mark NSURLSessionDownloadDelegate

//获取NSURL中的文件从临时路径，移动到自己保存的一个路径
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    if (_finishedDownload) {
        _finishedDownload(downloadTask, downloadTask.currentRequest.URL, location);
    }
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertTitle = @"任务已经完成";
    localNotification.alertBody = downloadTask.currentRequest.URL.lastPathComponent;
//    localNotification.alertAction =
     [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (_downloadProcess) {
        _downloadProcess(downloadTask, downloadTask.currentRequest.URL, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}

double bytesTransitionKB(int64_t bytes) {
    return bytes / pow(10, 3);
}

double bytesTransitionMB(int64_t bytes) {
    return bytes / pow(10, 6);
}

//挂起之后重下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
}

#pragma mark NSURLSessionTaskDelegate

//一个task的最终回调
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    
    NSError *taskError;
    if (error.code == -999) {
        NSLog(@"任务取消");
    } else {
        taskError = error;
    }
//    NSBlockOperation
    if ([error.userInfo[NSURLSessionDownloadTaskResumeData] isKindOfClass:[NSData class]]) {
        //保存到缓存
    } else {
        //移除target
    }
    
    if (_completedWithError) {
        _completedWithError(task, task.currentRequest.URL, taskError);
    }
    
    if (error.code == -1001) {
        NSLog(@"请求超时处理resumeData");
    }
    
    //移除标识
//    [self.downloadTasksMDic removeObjectForKey:keyForTasksMDicWithURL(task.currentRequest.URL)];
}


#pragma mark 任务的暂停 取消

/// 在缓存里获取task
- (NSURLSessionDownloadTask *)getTaskInDownloadTasksMDicWithKey:(NSString *)key {
//    if ([self.downloadTasksMDic[key] isKindOfClass:[NSURLSessionDownloadTask class]]) {
//        return self.downloadTasksMDic[key];
//    }
    return nil;
}

/// 在缓存里获取task
- (NSURLSessionDownloadTask *)getTaskInSuspendTasksMDicWithKey:(NSString *)key {
//    if ([self.suspendTasksMDic[key] isKindOfClass:[NSData class]]) {
//        return [self.session downloadTaskWithResumeData:self.suspendTasksMDic[key]];
//    }
    return nil;
}

- (void)suspendAllTasks {
//    for (NSString *key in self.downloadTasksMDic.allKeys) {
//        [self suspendTaskWithKey:key];
//    }
}

- (void)suspendTaskWithURL:(NSURL *_Nullable)url {
    [self suspendTaskWithKey:keyForTasksMDicWithURL(url)];
}

- (void)suspendTaskWithKey:(NSString *)key {
    NSURLSessionDownloadTask *downloadTask = [self getTaskInDownloadTasksMDicWithKey:key];
    if (downloadTask) {
        __weak typeof(self) weakSelf = self;
        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
//            获得暂停任  务的的数据 存起来并且从 self.downloadTasksMDic 移除
//            [weakSelf.suspendTasksMDic setValue:resumeData forKey:key];
//            [weakSelf.downloadTasksMDic removeObjectForKey:key];
        }];
    }
}

- (void)cancelTaskWithKey:(NSString *)key {
    NSURLSessionDownloadTask *downloadTask = [self getTaskInDownloadTasksMDicWithKey:key];
//    [self.downloadTasksMDic removeObjectForKey:key];
//    downloadTask = [self getTaskInSuspendTasksMDicWithKey:key];
//    [self.suspendTasksMDic removeObjectForKey:key];
    
    if (downloadTask) {
        [downloadTask cancel];
    }
}

//取消所有任务 consideration
- (void)cancelAllTasks {
//    for (NSString *key in self.downloadTasksMDic.allKeys) {
//        [self cancelTaskWithKey:key];
//    }
//    for (NSString *key in self.suspendTasksMDic.allKeys) {
//        [self cancelTaskWithKey:key];
//    }
    
    
    for (WZDownloadTarget *target in _downloadTargets) {
        [target.task cancel];
    }
}
//取消此任务
- (void)cancelTaskWithURL:(NSURL *_Nullable)url {
//    [self cancelTaskWithKey:keyForTasksMDicWithURL(url)];
    //映射到
    if ([url isKindOfClass:[NSURL class]]) {
        for (WZDownloadTarget *target in _downloadTargets) {
            if ([target.url.path isEqualToString:url.path]) {
                [target.task cancel];
            };
        }
    }
}

- (void)resumeTaskWithKey:(NSString *)key {
    NSURLSessionDownloadTask *downloadTask = [self getTaskInSuspendTasksMDicWithKey:key];
//    [self.downloadTasksMDic setValue:downloadTask forKey:key];
//    [self.suspendTasksMDic removeObjectForKey:key];
//    if (downloadTask) {
//        [downloadTask resume];
//    }
}

//恢复所有暂停的任务
- (void)resumeAllTasks {
//    for (NSString *key in self.suspendTasksMDic.allKeys) {
//        [self resumeTaskWithKey:key];
//    }
}
//恢复暂停的任务
- (void)resumeTaskWithURL:(NSURL *_Nullable)url {
    [self resumeTaskWithKey:keyForTasksMDicWithURL(url)];
}

#pragma mark getter & setter

@end
