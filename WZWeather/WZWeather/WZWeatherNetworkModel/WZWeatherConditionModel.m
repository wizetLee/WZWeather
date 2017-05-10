//
//  WZWeatherConditionModel.m
//  WZWeather
//
//  Created by admin on 17/5/10.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZWeatherConditionModel.h"

@implementation WZWeatherConditionModel

//获得目前所在地址

+ (void)fetchWeatherConditionWithAreaCity:(NSString *)areaCity weatherConditionCallBack:(weatherCondition)weatherCondition {
    [self areaCity:areaCity weatherConditionCallBack:weatherCondition];
}

+ (void)areaCity:(NSString *)areaCity weatherConditionCallBack:(weatherCondition)weatherCondition {
    NSString *httpUrl = @"http://apis.baidu.com/showapi_open_bus/weather_showapi/address";
    NSString *area = [NSString stringWithFormat:@"area=%@",areaCity];//@"area=广州市"
    NSString *needMoreDay = @"needMoreDay=1";
    NSString *needIndex = @"needIndex=1";
    NSString *needAlarm = @"needAlarm=1";
    NSString *need3HourForcast = @"need3HourForcast=1";
    //拼接URLString
    NSString *urlString = [NSString stringWithFormat:@"%@?%@&%@&%@&%@&%@",httpUrl,area,needMoreDay,needIndex,needAlarm,need3HourForcast];
    //转码
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    //会话  配置
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    //请求信息
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    //请求方式
    [request setHTTPMethod:@"GET"];
    //POST 方法 要  setHTTPBody:data   data 要转码(UTF8)
    //首部信息
    [request addValue: @"9254d5a3e7cbd8027be0e56f4f03fe2f" forHTTPHeaderField: @"apikey"];
    
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
        
        if (weatherCondition) {
            weatherCondition(callBackDic,callBackError);
        }
    }];
    //执行task
    [dataTask resume];
}

@end
