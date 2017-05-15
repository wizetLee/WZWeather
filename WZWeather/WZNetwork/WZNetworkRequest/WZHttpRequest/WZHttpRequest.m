//
//  WZHttpRequest.m
//  WZWeather
//
//  Created by admin on 17/5/11.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZHttpRequest.h"

@implementation WZHttpRequest

+ (NSURLSessionDataTask * _Nullable)wz_taskResumeWithSession:(NSURLSession * _Nullable)session request:(NSURLRequest * _Nullable)request serializationResult:(wz_httpRequestJSONSerializationResult _Nullable)serializationResult {
    NSParameterAssert(session);
    NSParameterAssert(request);
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        wz_JSONSerializationResult(data, response, error, serializationResult);
    }];
    
    //执行task
    if (task) {
        [task resume];
    }
    
    return task;
}

+ (NSURLSessionDownloadTask * _Nullable)wz_downloadResumeWithSession:(NSURLSession * _Nullable)session request:(NSURLRequest * _Nullable)request {
    NSParameterAssert(session);
    NSParameterAssert(request);
    NSURLSessionDownloadTask *downLoadTask = [session downloadTaskWithRequest:request];
    [downLoadTask resume];
    return downLoadTask;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
}
/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

/*
 
 */

//对于数据返回的中转
void wz_JSONSerializationResult(NSData * _Nullable origionData, NSURLResponse * _Nullable response, NSError * _Nullable error, wz_httpRequestJSONSerializationResult serializationResult) {
    NSError *jsonError = error;
    BOOL isArray = false;
    BOOL isDictionary = false;
    BOOL mismatching = false;
    id result = nil;
    
    if (jsonError) {
        
    } else {
        
        result = [NSJSONSerialization JSONObjectWithData:origionData options:NSJSONReadingAllowFragments error:&jsonError];
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            isDictionary = true;
        } else if ([result isKindOfClass:[NSArray class]]) {
            isArray = true;
        } else {
            NSLog(@"JSON 不匹配返回类型");
            mismatching = true;
        }
    }
    
    if (serializationResult) {
        serializationResult(result, isDictionary, isArray, mismatching, jsonError);
    }
}



@end
