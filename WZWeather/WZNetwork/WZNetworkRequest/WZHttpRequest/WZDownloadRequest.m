//
//  WZDownloadRequest.m
//  WZWeather
//
//  Created by admin on 17/5/15.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZDownloadRequest.h"

@interface WZDownloadRequest()

@property (nonatomic, strong) wz_downloadTaskDidCompleteWithError _Nullable completedWithError;
@property (nonatomic, strong) wz_downloadTaskDidFinishDownload _Nullable finishedDownload;
@property (nonatomic, strong) wz_downloadTaskDownloadProcess _Nullable downloadProcess;

@end

@implementation WZDownloadRequest

+ (instancetype)downloader {
    WZDownloadRequest *downloader = [[WZDownloadRequest alloc] init];
    return downloader;
}

//是否加上一个已下载block
- (void)wz_downloadWithURL:(NSURL * _Nullable)url
      finishWhenInvalidate:(BOOL)boolean
        completedWithError:(wz_downloadTaskDidCompleteWithError _Nullable)completedWithError
          finishedDownload:(wz_downloadTaskDidFinishDownload _Nullable)finishedDownload
           downloadProcess:(wz_downloadTaskDownloadProcess _Nullable)downloadProcess {
    _completedWithError = completedWithError;
    _finishedDownload = finishedDownload;
    _downloadProcess = downloadProcess;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 15.0;
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request];
    
    //添加标识
    [self.downloadTasksMDic setValue:downloadTask forKey:[url path]];
    
    [downloadTask resume];
    if (boolean) {
        [self.session finishTasksAndInvalidate];
    }
}


#pragma mark 

//一个task的最终回调
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (_completedWithError) {
        _completedWithError(task, error);
    }
    //移除标识
    [self.downloadTasksMDic removeObjectForKey:task.currentRequest.URL.path];
}

//获取NSURL中的文件从临时路径，移动到自己保存的一个路径
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    if (_finishedDownload) {
        _finishedDownload(downloadTask, location);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
//    NSLog(@" bytesWritten: %lf\
//          \n totalBytesWritten :%lf \
//          \n totalBytesExpectedToWrite:%lf"
//          ,bytesWritten / 1000.0
//          , totalBytesWritten  / 1000.0
//          ,totalBytesExpectedToWrite / 1000.0 );
    
    //本次下载的字节数
    //当前task已下载的字节数
    //本次任务下载的字节数
    
    if (_downloadProcess) {
        _downloadProcess(downloadTask ,bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
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
    NSLog(@"fileOffset: %lld \n expectedTotalBytes :%lld",fileOffset, expectedTotalBytes);
}

- (void)suspendAllTask {
    for (NSString *key in self.downloadTasksMDic.allKeys) {
        if ([self.downloadTasksMDic[key] isKindOfClass:[NSURLSessionDownloadTask class]]) {
            NSURLSessionDownloadTask *downloadTask = self.downloadTasksMDic[key];
            [downloadTask suspend];
        }
    }
}

- (void)suspendTaskWithURL:(NSURL *_Nullable)url {
    if ([self.downloadTasksMDic[[url path]] isKindOfClass:[NSURLSessionDownloadTask class]]) {
        NSURLSessionDownloadTask *downloadTask = self.downloadTasksMDic[[url path]];
        [downloadTask suspend];
    }
}

- (void)cancelAllTask {
    
}

- (void)cancelTaskWithURL:(NSURL *_Nullable)url {
    
}

- (void)resumeAllTask {
    for (NSString *key in self.downloadTasksMDic.allKeys) {
        if ([self.downloadTasksMDic[key] isKindOfClass:[NSURLSessionDownloadTask class]]) {
            NSURLSessionDownloadTask *downloadTask = self.downloadTasksMDic[key];
            [downloadTask resume];
        }
    }
}

- (void)resumeTaskWithURL:(NSURL *_Nullable)url {
    if ([self.downloadTasksMDic[[url path]] isKindOfClass:[NSURLSessionDownloadTask class]]) {
        NSURLSessionDownloadTask *downloadTask = self.downloadTasksMDic[[url path]];
        [downloadTask resume];
    }
}


#pragma mark getter & setter

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDownloadDelegate>)self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return _session;
}

- (NSMutableDictionary *)downloadTasksMDic {
    if (!_downloadTasksMDic) {
        _downloadTasksMDic = [NSMutableDictionary dictionary];
    }
    return _downloadTasksMDic;
}

@end
