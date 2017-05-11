//
//  WZHttpRequest.h
//  WZWeather
//
//  Created by admin on 17/5/11.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^wz_httpRequestResult)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

typedef void (^wz_httpRequestJSONSerializationResult)(id _Nullable JSONData, BOOL isDictionaty, BOOL isArray, BOOL mismatching, NSError * _Nullable error);

@interface WZHttpRequest : NSObject

// GET  POST  DELETE  PUT  and so on.

void wz_JSONSerializationResult(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error, wz_httpRequestJSONSerializationResult _Nullable serializationResult);

//GET请求
+ (NSURLSessionTask * _Nullable)wz_httpGETRequestWithURL:(NSURL * _Nullable)url httpHeaderField:(NSDictionary<NSString *, NSString *> * _Nullable)httpHeaderField result:(wz_httpRequestResult _Nullable)result;

+ (NSURLSessionTask * _Nullable)wz_httpGETRequestWithURLString:(NSString * _Nullable)URLString httpHeaderField:(NSDictionary<NSString *, NSString *> * _Nullable)httpHeaderField result:(wz_httpRequestResult _Nullable)result;

//POST请求
+ (NSURLSessionTask * _Nullable)wz_httpPOSTRequestWithURL:(NSURL * _Nullable)url httpHeaderField:(NSDictionary<NSString *, NSString *> * _Nullable)  httpHeaderField:(NSDictionary<NSString *, NSString *> * _Nullable)
httpHeaderField result:(wz_httpRequestResult _Nullable)result;


@end
