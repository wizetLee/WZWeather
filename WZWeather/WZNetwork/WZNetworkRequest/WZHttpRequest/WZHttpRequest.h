//
//  WZHttpRequest.h
//  WZWeather
//
//  Created by admin on 17/5/11.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

//统一的返回类型
typedef void (^HttpRequestJSONSerializationResult)(id _Nullable result, BOOL isDictionaty, BOOL isArray, BOOL mismatching, NSError * _Nullable error);

typedef void(^HttpRequestSessionRequest)(NSURLSession * _Nullable session, NSMutableURLRequest * _Nullable request);




@interface WZHttpRequest : NSObject

// GET  POST  DELETE  PUT  and so on.

void JSONSerializationResult(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error, HttpRequestJSONSerializationResult _Nullable serializationResult);

//自定义配置的请求 并且立即执行 返回的是dataTask
+ (NSURLSessionDataTask * _Nullable)taskResumeWithSession:(NSURLSession * _Nullable)session request:(NSURLRequest * _Nullable)request serializationResult:(HttpRequestJSONSerializationResult _Nullable)serializationResult;

//+ (NSURLSessionDownloadTask * _Nullable) 


@end
