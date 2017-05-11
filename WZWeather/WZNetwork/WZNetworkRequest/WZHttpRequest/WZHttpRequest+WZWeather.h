//
//  WZHttpRequest+WZWeather.h
//  WZWeather
//
//  Created by admin on 17/5/11.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZHttpRequest.h"

#define WZ_YIYUANWEATHER_APPKEY_VALUE_DIC @{@"apikey": @"9254d5a3e7cbd8027be0e56f4f03fe2f"}
#define WZ_YIYUANWEATHER_URLSTRING @"http://apis.baidu.com/showapi_open_bus/weather_showapi/address"

//应用的appid 和 密匙
#define WZ_YIYUAN_APPKEY_VALUE_DIC @{@"showapi_appid":@"37942", @"showapi_sign":@"e0a142511eb44ab79cd30607a208b758"}
#define WZ_YIYUAN_GETREQUEST_ID_SIGN @"?showapi_appid=37942&showapi_sign=e0a142511eb44ab79cd30607a208b758"
//必应每日壁纸
#define WZ_YIYUAN_BIYINGWALLPAPER_URLSTRING @"http://route.showapi.com/1287-1"

/*
    id或名称->查未来15天预报
    http://route.showapi.com/9-9
    参数  area  地名

    id或名称->查询24小时预报
    http://route.showapi.com/9-8
    参数  area  地名
 
    http://route.showapi.com/1287-1
 
 */

@interface WZHttpRequest (WZWeather)
//天气
+ (NSURLSessionTask *)wz_requestWeatherConditionWithAreaCity:(NSString *)areaCity serializationResult:(wz_httpRequestJSONSerializationResult)serializationResult;

//必应每日壁纸
+ (NSURLSessionTask *)wz_requestBiYingWallpaperserializationResult:(wz_httpRequestJSONSerializationResult)serializationResult;

@end
