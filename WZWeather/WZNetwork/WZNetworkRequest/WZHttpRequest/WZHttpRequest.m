//
//  WZHttpRequest.m
//  WZWeather
//
//  Created by admin on 17/5/11.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZHttpRequest.h"

@implementation WZHttpRequest

+ (NSURLSessionTask * _Nullable)wz_taskResumeWithSession:(NSURLSession * _Nullable)session request:(NSURLRequest * _Nullable)request serializationResult:(wz_httpRequestJSONSerializationResult _Nullable)serializationResult {
    NSParameterAssert(session);
    NSParameterAssert(request);
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        wz_JSONSerializationResult(data, response, error, serializationResult);
    }];
    
    //执行task
    if (task) {
        [task resume];
    }
    
    return task;
}

//对于数据返回的中转
void wz_JSONSerializationResult(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error, wz_httpRequestJSONSerializationResult serializationResult) {
    NSError *jsonError = error;
    BOOL isArray = false;
    BOOL isDictionary = false;
    BOOL mismatching = false;
    id result = nil;
    
    if (jsonError) {
        
    } else {
        
        result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
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
