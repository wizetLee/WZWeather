//
//  WZHttpRequest+WZWeather.h
//  WZWeather
//
//  Created by wizet on 17/5/11.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZHttpRequest.h"

#define WZ_YIYUANWEATHER_APPKEY_VALUE_DIC @{@"apikey": @"9254d5a3e7cbd8027be0e56f4f03fe2f"}
#define WZ_YIYUANWEATHER_URLSTRING @"http://apis.baidu.com/showapi_open_bus/weather_showapi/address"

//yiyuan应用的appid 和 密匙
#define WZ_YIYUAN_APPKEY_VALUE_DIC @{@"showapi_appid":@"37942", @"showapi_sign":@"e0a142511eb44ab79cd30607a208b758"}
#define WZ_YIYUAN_GETREQUEST_ID_SIGN @"?showapi_appid=37942&showapi_sign=e0a142511eb44ab79cd30607a208b758"
//必应每日壁纸
#define WZ_YIYUAN_BIYINGWALLPAPER_URLSTRING @"http://route.showapi.com/1287-1"
//百思不得姐查询接口
#define WZ_YIYUAN_BAISIBUDEJIE_URLSTRING @"http://route.showapi.com/255-1"


/*
    id或名称->查未来15天预报
    http://route.showapi.com/9-9
    参数  area  地名

    id或名称->查询24小时预报
    http://route.showapi.com/9-8
    参数  area  地名
    
    必应每日壁纸
    http://route.showapi.com/1287-1
 
   
    //百思不得姐查询接口
    http://route.showapi.com/255-1
    type=10 图片
    type=29 段子
    type=31 声音
    type=41 视频
    title
    page
 */

typedef NS_ENUM(NSUInteger, WZBaiSiBuDeJieType) {
    WZBaiSiBuDeJieType_image = 10,
    WZBaiSiBuDeJieType_cross_talk = 29,
    WZBaiSiBuDeJieType_audio = 31,
    WZBaiSiBuDeJieType_video = 41,
};

@interface WZHttpRequest (WZWeather)

//天气
+ (NSURLSessionTask *)requestWeatherConditionWithAreaCity:(NSString *)areaCity serializationResult:(HttpRequestJSONSerializationResult)serializationResult;

//必应每日壁纸
+ (NSURLSessionTask *)requestBiYingWallpaperSerializationResult:(HttpRequestJSONSerializationResult)serializationResult;

//百思不得姐
+ (NSURLSessionTask *)requestBaiSiBuDeJieWithType:(WZBaiSiBuDeJieType)type title:(NSString *)title page:(NSUInteger)page SerializationResult:(HttpRequestJSONSerializationResult)serializationResult;


@end
