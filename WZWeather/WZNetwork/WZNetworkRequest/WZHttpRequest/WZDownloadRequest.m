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

@property (nonatomic, assign) BOOL invalidate;

@end

@implementation WZDownloadRequest

NSString * valueForDownloadTasksMDicWithURL(NSURL * url);
void downloadActionWithURLArray(NSArray <NSURL *> * urlArray);

+ (instancetype)downloader {
    WZDownloadRequest *downloader = [[WZDownloadRequest alloc] init];
    return downloader;
}

- (void)wz_downloadWithURLArray:(NSArray <NSURL *>*)urlArray
                     invalidate:(BOOL)boolean
             completedWithError:(wz_downloadTaskDidCompleteWithError _Nullable)completedWithError
               finishedDownload:(wz_downloadTaskDidFinishDownload _Nullable)finishedDownload
                downloadProcess:(wz_downloadTaskDownloadProcess _Nullable)downloadProcess {
    _completedWithError = completedWithError;
    _finishedDownload = finishedDownload;
    _downloadProcess = downloadProcess;
    _invalidate = boolean;
    downloadActionWith(urlArray, self.downloadTasksMDic, self.session);
   
    if (boolean) {
        [self.session finishTasksAndInvalidate];
    }
}

- (void)insertDownloadTasksWithURLArray:(NSArray <NSURL *>*)urlArray {
    downloadActionWith(urlArray, self.downloadTasksMDic, self.session);
}

- (void)finishTasksAndInvalidate {
    [self.session finishTasksAndInvalidate];
}

//已经被下载的文件不会重复下载
void downloadActionWith(NSArray <NSURL *> * urlArray, NSDictionary * downloadTasksMDic, NSURLSession *session) {
   
    //检查文件是否已经被下载
    NSMutableArray <NSURL *>* tmpUrlArray = [NSMutableArray arrayWithArray:urlArray];
    for (NSURL * url in urlArray) {
        if (wz_fileExistsAtPath(wz_filePath(WZSearchPathDirectoryTemporary, url.lastPathComponent))) {
            [tmpUrlArray removeObject:url];
        }
    }
    
    for (NSURL *url in tmpUrlArray) {
        
        if (downloadTasksMDic[valueForDownloadTasksMDicWithURL(url)]) {
            continue;
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.timeoutInterval = 15.0;
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
        
        //添加标识
        [downloadTasksMDic setValue:downloadTask forKey:valueForDownloadTasksMDicWithURL(url)];
        [downloadTask resume];
    }
}

//rule for the downloadTaskMDic
NSString * valueForDownloadTasksMDicWithURL(NSURL * url) {
    return [url path];
}

- (NSURLSessionDownloadTask *)downloadTaskWithURl:(NSURL *)url {
    NSURLSessionDownloadTask *downloadTask = nil;
   
    if (self.downloadTasksMDic[valueForDownloadTasksMDicWithURL(url)]) {
        downloadTask = self.downloadTasksMDic[valueForDownloadTasksMDicWithURL(url)];
    }
    
    return downloadTask;
}


#pragma mark 

//一个task的最终回调
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (_completedWithError) {
        _completedWithError(task, task.currentRequest.URL, error);
    }
    //移除标识
    [self.downloadTasksMDic removeObjectForKey:valueForDownloadTasksMDicWithURL(task.currentRequest.URL)];
}

//获取NSURL中的文件从临时路径，移动到自己保存的一个路径
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    if (_finishedDownload) {
        _finishedDownload(downloadTask, downloadTask.currentRequest.URL, location);
    }
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
    NSLog(@"12345678901234567890-1234567890-1234567890-1234567890 \
          fileOffset: %lld \n expectedTotalBytes :%lld"
          ,fileOffset, expectedTotalBytes);
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
    if ([self.downloadTasksMDic[valueForDownloadTasksMDicWithURL(url)] isKindOfClass:[NSURLSessionDownloadTask class]]) {
        NSURLSessionDownloadTask *downloadTask = self.downloadTasksMDic[valueForDownloadTasksMDicWithURL(url)];
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
    if ([self.downloadTasksMDic[valueForDownloadTasksMDicWithURL(url)] isKindOfClass:[NSURLSessionDownloadTask class]]) {
        NSURLSessionDownloadTask *downloadTask = self.downloadTasksMDic[valueForDownloadTasksMDicWithURL(url)];
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
