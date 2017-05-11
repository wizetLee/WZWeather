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
    
    return [self wz_httpGETRequestWithURLString:urlString httpHeaderField:WZ_YIYUANWEATHER_APPKEY_VALUE_DIC result:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        /*
         NSJSONReadingOptions:
         NSJSONReadingMutableContainers -> 返回可变类型
         NSJSONReadingMutableLeaves -> 返回容器内叶子是可变类型
         NSJSONReadingAllowFragments －>  只要是符合JSON格式的都可以返回
         */
        wz_JSONSerializationResult(data, response, error, serializationResult);
      
    }];
}

+ (NSURLSessionTask *)wz_requestBiYingWallpaperserializationResult:(wz_httpRequestJSONSerializationResult)serializationResult {
     NSString *urlString = [NSString stringWithFormat:@"%@%@", WZ_YIYUAN_BIYINGWALLPAPER_URLSTRING, WZ_YIYUAN_GETREQUEST_ID_SIGN];
    return [self wz_httpGETRequestWithURLString:urlString httpHeaderField:nil result:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        wz_JSONSerializationResult(data, response, error, serializationResult);
    }];
}


@end
