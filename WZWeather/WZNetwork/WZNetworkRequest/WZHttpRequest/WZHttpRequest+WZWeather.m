//
//  WZHttpRequest+WZWeather.m
//  WZWeather
//
//  Created by admin on 17/5/11.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZHttpRequest+WZWeather.h"

@implementation WZHttpRequest (WZWeather)


//请求天气详情 
+ (NSURLSessionTask *)wz_requestWeatherConditionWithAreaCity:(NSString *)areaCity serializationResult:(wz_httpRequestJSONSerializationResult)serializationResult {
    NSString *urlString = WZ_YIYUANWEATHER_URLSTRING;
    NSString *area = [NSString stringWithFormat:@"area=%@",areaCity];//@"area=广州市"
    NSString *needMoreDay = @"needMoreDay=1";
    NSString *needIndex = @"needIndex=1";
    NSString *needAlarm = @"needAlarm=1";
    NSString *need3HourForcast = @"need3HourForcast=1";
    //拼接URLString
    urlString = [NSString stringWithFormat:@"%@?%@&%@&%@&%@&%@",urlString,area,needMoreDay,needIndex,needAlarm,need3HourForcast];
    
    //会话 配置
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    //request 配置具有多样性
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"GET";
    request.allHTTPHeaderFields = WZ_YIYUANWEATHER_APPKEY_VALUE_DIC;
    
    return [self wz_taskResumeWithSession:session request:request serializationResult:serializationResult];
   
}

+ (NSURLSessionTask *)wz_requestBiYingWallpaperSerializationResult:(wz_httpRequestJSONSerializationResult)serializationResult {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", WZ_YIYUAN_BIYINGWALLPAPER_URLSTRING, WZ_YIYUAN_GETREQUEST_ID_SIGN];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"GET";
    
    return [self wz_taskResumeWithSession:session request:request serializationResult:serializationResult];;
}

+ (NSURLSessionTask *)wz_requestBaiSiBuDeJieWithType:(WZBaiSiBuDeJieType)type title:(NSString *)title page:(NSUInteger)page SerializationResult:(wz_httpRequestJSONSerializationResult)serializationResult {
    
    
    
    if (!title || ![title isKindOfClass:[NSString class]]) {
        title = @"";
    }
    if (page == 0) {
        page = 1;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@", WZ_YIYUAN_BAISIBUDEJIE_URLSTRING];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
   
    NSString *HTTPBodyString = [NSString stringWithFormat:@"showapi_appid=37942&showapi_sign=e0a142511eb44ab79cd30607a208b758&type=%ld&title=%@&page=%ld", type, title, page];
    NSData *HTTPBody = [HTTPBodyString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = HTTPBody;

    return [self wz_taskResumeWithSession:session request:request serializationResult:serializationResult];;
}


@end
