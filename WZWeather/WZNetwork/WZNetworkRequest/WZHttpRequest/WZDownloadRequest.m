//
//  WZDownloadRequest.m
//  WZWeather
//
//  Created by wizet on 17/5/15.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZDownloadRequest.h"

@interface WZDownloadRequest()

@property (nonatomic, strong) NSURLSession * _Nullable session;

@property (nonatomic, assign) NSUInteger maxDownloadNumber;//最大并发数目
@property (nonatomic, assign) NSUInteger currentDownloadNumer;//当前并发数目
@property (nonatomic, strong) DownloadTaskDidCompleteWithError _Nullable completedWithError;
@property (nonatomic, strong) DownloadTaskDidFinishDownload _Nullable finishedDownload;
@property (nonatomic, strong) DownloadTaskDownloadProcess _Nullable downloadProcess;
@property (nonatomic, strong) NSMutableArray <WZDownloadTarget *> * _Nullable downloadTargets;

@end

@implementation WZDownloadRequest

double bytesTransitionKB(int64_t bytes) {
    return bytes / pow(10, 3);
}

double bytesTransitionMB(int64_t bytes) {
    return bytes / pow(10, 6);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxDownloadNumber = 5;
        _currentDownloadNumer = 0;
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDownloadDelegate>)self delegateQueue:[NSOperationQueue mainQueue]];
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
    [self downloadAction:urlArray session:_session];
}

- (void)insertDownloadTasksWithURLArray:(NSArray <NSURL *>*)urlArray {
    
}

//使session无效
- (void)finishTasksAndInvalidate {
    [self.session finishTasksAndInvalidate];
}

- (void)downloadAction:(NSArray <NSURL *> *)urlArray session:(NSURLSession *)session {
    //减少了文件检查步骤
    
    //检查任务url
//    NSMutableArray <NSURL *>* tmpUrlArray = [NSMutableArray arrayWithArray:urlArray];
    for (NSURL *url in urlArray) {
//        //检查文件是否已经被下载
//        if (0/*文件已经被下载*/) {
//            continue;
//        }
    
        //创建任务Target
        WZDownloadTarget *target = [[WZDownloadTarget alloc] init];
        
        //检查任务是否在下载队列
        for (WZDownloadTarget *tmpTarget in _downloadTargets) {
            if ([url.path isEqualToString:tmpTarget.url.path]) {
                target.url = url;
                target.pause = tmpTarget.pause;
                target.task = tmpTarget.task;
                target.resumeData = tmpTarget.resumeData;
                target.downloadRequest = tmpTarget.downloadRequest;
                break;
            }
        }
        
        NSURLSessionDownloadTask *downloadTask = nil;
        if (target.resumeData) {
            //缓存检查并创建断点任务
            downloadTask = [self.session downloadTaskWithURL:url];
            target.resumeData = nil;//清空缓存
            target.task = downloadTask;
        } else if (target.task) {
            
        } else {
            //新建任务
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.timeoutInterval = 15.0;
            downloadTask = [session downloadTaskWithRequest:request];
            target.task = downloadTask;
            target.url = url;
            target.downloadRequest = self;
        }
        
        //存储任务
        [_downloadTargets addObject:target];
        [downloadTask resume];//开始任务;
    }
}

#pragma mark - NSURLSessionDownloadDelegate

//获取NSURL中的文件从临时路径，移动到自己保存的一个路径
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    //任务完成 置空任务
    for (WZDownloadTarget *target in [self matchTargetsWithURL:downloadTask.currentRequest.URL]) {
        target.resumeData = nil;
        target.task = nil;
        target.completion = true;
        target.pause = false;
    }
    
    if (_finishedDownload) {
        _finishedDownload([self matchTargetsWithURL:downloadTask.currentRequest.URL], location);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
   
    for (WZDownloadTarget *target in [self matchTargetsWithURL:downloadTask.currentRequest.URL]) {
        target.totalBytesWritten = totalBytesWritten;
        target.bytesWritten = bytesWritten;
        target.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
    }
    
    if (_downloadProcess) {
        _downloadProcess([self matchTargetsWithURL:downloadTask.currentRequest.URL]);
    }
}

- (NSMutableArray <WZDownloadTarget *>*)matchTargetsWithURL:(NSURL *)url {
    NSMutableArray <WZDownloadTarget *>*array = [NSMutableArray array];
    if ([url isKindOfClass:[NSURL class]]) {
        for (WZDownloadTarget *tmpTarget in _downloadTargets) {
            if ([url.path isEqualToString:tmpTarget.url.path]) {
                [array addObject:tmpTarget];
            }
        }
    }
    return array;
}

//使用resumeData下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

#pragma mark - NSURLSessionTaskDelegate

//一个task的最终回调
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (error) {
        //任务超时终止 保存为缓存
        __block NSData *tmpResumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
        for (WZDownloadTarget *target in [self matchTargetsWithURL:task.currentRequest.URL]) {
            target.task = nil;
            target.pause = true;
            target.resumeData = tmpResumeData;
        }
    }
    
    if (_completedWithError) {
        _completedWithError([self matchTargetsWithURL:task.currentRequest.URL], error);
    }
}

#pragma mark - 任务的暂停 取消

- (void)suspendAllTasks {
    WZDownloadTarget *tmpTarget = nil;
    for (WZDownloadTarget *targetOutskirts in _downloadTargets) {
        if (tmpTarget.pause == true) {
            continue;
        }
         [self suspendTarget:targetOutskirts.url];
    }
}

- (void)suspendTaskWithURL:(NSURL *_Nullable)url {
   [self suspendTarget:url];
}

- (void)suspendTarget:(NSURL *)url {
    __block NSData *tmpResumeData = nil;
    for (WZDownloadTarget *target in [self matchTargetsWithURL:url]) {
        [target.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            tmpResumeData = resumeData;
        }];
        target.task = nil;
        target.pause = true;
        target.resumeData = tmpResumeData;
    }
}

//取消所有任务 consideration
- (void)cancelAllTasks {
    [self cancelTargets:_downloadTargets];
}

//取消此任务
- (void)cancelTaskWithURL:(NSURL *_Nullable)url {
    [self cancelTargets:[self matchTargetsWithURL:url]];
}

- (void)cancelTargets:(NSArray <WZDownloadTarget *>*)array {
    for (WZDownloadTarget *target in array) {
        [target.task cancel];
        target.task = nil;
        target.resumeData = nil;
        target.pause = false;
        target.cancel = true;
    }
}

//恢复所有暂停的任务
- (void)resumeAllTasks {
    for (WZDownloadTarget *targetOutskirts in _downloadTargets) {
        if (targetOutskirts.pause == false) {
            continue;
        }
        [self resumeTasksWithURL:targetOutskirts.url];
    }
}

//恢复暂停的任务
- (void)resumeTaskWithURL:(NSURL *_Nullable)url {
     [self resumeTasksWithURL:url];
}

- (void)resumeTasksWithURL:(NSURL *)url {
    WZDownloadTarget *tmpTarget = nil;
    for (WZDownloadTarget *target in [self matchTargetsWithURL:url]) {
        if (!tmpTarget) {
            tmpTarget = target;
            [self resumeTarget:tmpTarget];
        } else {
            target.task =  tmpTarget.task;
            target.pause = tmpTarget.pause ;
            target.resumeData = tmpTarget.resumeData;
            target.cancel = tmpTarget.cancel;
        }
    }
}

//恢复单个target的任务事件
- (void)resumeTarget:(WZDownloadTarget *)tmpTarget {
    if (tmpTarget.task) {
        
    } else if (tmpTarget.resumeData) {
        tmpTarget.task = [tmpTarget.downloadRequest.session downloadTaskWithResumeData: tmpTarget.resumeData];
    } else if (tmpTarget.url) {
        //新建任务
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tmpTarget.url];
        request.timeoutInterval = 15.0;
        NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithRequest:request];
        tmpTarget.task = downloadTask;
        tmpTarget.downloadRequest = self;
    } else {
        tmpTarget.cancel = true;
    }
    
    if (!tmpTarget.cancel) {
        [tmpTarget.task resume];
        tmpTarget.resumeData = nil;
        tmpTarget.pause = false;
    }
}

#pragma mark - getter & setter

@end
