//
//  WZHttpRequest.m
//  WZWeather
//
//  Created by admin on 17/5/11.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZHttpRequest.h"

@implementation WZHttpRequest


+ (NSURLSessionTask *)wz_httpGETRequestWithURL:(NSURL *)url httpHeaderField:(NSDictionary<NSString *, NSString *> *)httpHeaderField result:(wz_httpRequestResult)result {
 
    NSAssert(url && [url isKindOfClass:[NSURL class]] , @"URL 错误");
    
    //会话  配置
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    //请求信息
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    //请求方式
    [request setHTTPMethod:@"GET"];
    //POST 方法 要  setHTTPBody:data   data 要转码(UTF8)
    //首部信息
    if ([httpHeaderField isKindOfClass:[NSDictionary class]]) {
        request.allHTTPHeaderFields = httpHeaderField;
    }
    
    request.allHTTPHeaderFields = httpHeaderField;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //返回数据
        NSError *callBackError = nil;
        NSDictionary *callBackDic = nil;
        if (error) {
            callBackError = error;
        } else {
            NSError *JSONError;
            NSDictionary *callBack = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
            if (!error) {
                callBackDic = callBack;
            } else {
                callBackError = JSONError;
            }
        }
        
        if (result) {
            result(data, response, error);
        }
    }];
    //执行task
    [dataTask resume];
    return dataTask;
}

+ (NSURLSessionTask *) wz_httpGETRequestWithURLString:(NSString *)URLString httpHeaderField:(NSDictionary<NSString *, NSString *> *)httpHeaderField result:(wz_httpRequestResult)result {
    //非true 就会断言
    NSAssert(URLString && [URLString isKindOfClass:[NSString class]] && ![URLString isEqualToString:@""], @"urlString 错误");
    
    URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:URLString];
   return [[self class] wz_httpGETRequestWithURL:url httpHeaderField:httpHeaderField result:result];
}


void wz_JSONSerializationResult(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error, wz_httpRequestJSONSerializationResult serializationResult) {
    NSError *jsonError = error;
    BOOL isArray = false;
    BOOL isDictionary = false;
    BOOL mismatching = false;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    if (jsonError) {
        
    } else {
        if ([result isKindOfClass:[NSDictionary class]]) {
            isDictionary = true;
        } else if ([result isKindOfClass:[NSArray class]]) {
            isArray = true;
        } else {
            NSLog(@"JSON 不匹配返回类型");
            mismatching = true;
        }
    }
    
    serializationResult(result, isDictionary, isArray, mismatching, jsonError);
}




@end
