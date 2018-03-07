//
//  WZHttpRequest+WZWeather.m
//  WZWeather
//
//  Created by wizet on 17/5/11.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZHttpRequest+WZWeather.h"

@implementation WZHttpRequest (WZWeather)

//请求天气详情 
+ (NSURLSessionTask *)requestWeatherConditionWithAreaCity:(NSString *)areaCity serializationResult:(HttpRequestJSONSerializationResult)serializationResult {
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
    
    return [self taskResumeWithSession:session request:request serializationResult:serializationResult];
}

+ (NSURLSessionTask *)requestBiYingWallpaperSerializationResult:(HttpRequestJSONSerializationResult)serializationResult {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", WZ_YIYUAN_BIYINGWALLPAPER_URLSTRING, WZ_YIYUAN_GETREQUEST_ID_SIGN];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"GET";
    
    return [self taskResumeWithSession:session request:request serializationResult:serializationResult];;
}

+ (NSURLSessionTask *)requestBaiSiBuDeJieWithType:(WZBaiSiBuDeJieType)type title:(NSString *)title page:(NSUInteger)page SerializationResult:(HttpRequestJSONSerializationResult)serializationResult {
    
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

    return [self taskResumeWithSession:session request:request serializationResult:serializationResult];;
}


//必应
+ (void)loadBiYingImageInfo:(void(^)(NSString *BiYingCopyright,
                                     NSString *BiYingDate,
                                     NSString *BiYingDescription,
                                     NSString *BiYingTitle,
                                     NSString *BiYingSubtitle,
                                     NSString *BiYingImg_1366,
                                     NSString *BiYingImg_1920,
                                     UIImage *image))info {
    
    //    ///必应墙纸   //确定当前为wifi网络环境使用 图片废流量...
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *BiYingCopyrightKey = @"BiYingCopyrightKey";
    NSString *BiYingDateKey = @"BiYingDateKey";
    NSString *BiYingDescriptionKey = @"BiYingDescriptionKey";
    NSString *BiYingTitleKey = @"BiYingTitleKey";
    NSString *BiYingSubtitleKey = @"BiYingSubtitleKey";
    NSString *BiYingImg_1366Key = @"BiYingImg_1366Key";
    NSString *BiYingImg_1920Key = @"BiYingImg_1920Key";
    //确定当前的图片路径正确  否则要加载图片
    NSString *BiYingHighDefinitionSaveImageNamePrefix = @"BiYingHighDefinitionSaveImageName";
    
    __block NSString *BiYingHighDefinitionSavePath = nil;
    
    //Wifi预览高清大图
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    [NSUserDefaults resetStandardUserDefaults];
    
    if ([[defaults valueForKey:BiYingDateKey] isEqualToString:[formatter stringFromDate:currentDate]]) {
        //确定当前时间对应JSON格式
        
        //确定本地图片的正确性
        BiYingHighDefinitionSavePath = [NSObject wz_filePath:WZSearchPathDirectoryDocument fileName:[NSString stringWithFormat:@"%@%@",BiYingHighDefinitionSaveImageNamePrefix, [defaults valueForKey:BiYingDateKey]]];
     
        if ([BiYingHighDefinitionSavePath isEqualToString:[NSObject wz_filePath:WZSearchPathDirectoryDocument fileName:[NSString stringWithFormat:@"%@%@",BiYingHighDefinitionSaveImageNamePrefix, [formatter stringFromDate:currentDate]]]]) {
            //不用加载
            if (info) {
                info([defaults valueForKey:BiYingCopyrightKey],
                     [defaults valueForKey:BiYingDateKey],
                     [defaults valueForKey:BiYingDescriptionKey],
                     [defaults valueForKey:BiYingTitleKey],
                     [defaults valueForKey:BiYingSubtitleKey],
                     [defaults valueForKey:BiYingImg_1366Key],
                     [defaults valueForKey:BiYingImg_1920Key],
                     [UIImage imageWithData:[NSData dataWithContentsOfFile:BiYingHighDefinitionSavePath]]);
            }
        } else {
            //需要加载 异步下载
            if ([defaults valueForKey:BiYingImg_1920Key]) {
                NSURL * newUrl = [NSURL URLWithString:[defaults valueForKey:BiYingImg_1920Key]];
                [self downLoadURL:newUrl writeToFilePath:BiYingHighDefinitionSavePath handler:^(BOOL success) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //UI
                            if ([[NSFileManager defaultManager] fileExistsAtPath:BiYingHighDefinitionSavePath]) {
                                if (info) {
                                    info([defaults valueForKey:BiYingCopyrightKey],
                                         [defaults valueForKey:BiYingDateKey],
                                         [defaults valueForKey:BiYingDescriptionKey],
                                         [defaults valueForKey:BiYingTitleKey],
                                         [defaults valueForKey:BiYingSubtitleKey],
                                         [defaults valueForKey:BiYingImg_1366Key],
                                         [defaults valueForKey:BiYingImg_1920Key],
                                         [UIImage imageWithData:[NSData dataWithContentsOfFile:BiYingHighDefinitionSavePath]]);
                                }
                            }
                        });
                    }
                }];
            }
        }
    } else {
        [WZHttpRequest requestBiYingWallpaperSerializationResult:^(id  _Nullable result, BOOL isDictionaty, BOOL isArray, BOOL mismatching, NSError * _Nullable error) {
            if (!error && isDictionaty) {
                NSLog(@"%@", (NSDictionary *)result);
                NSDictionary *showapi_res_bodyDic = result[@"showapi_res_body"];
                if ([showapi_res_bodyDic isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dataDic = (NSDictionary *)showapi_res_bodyDic[@"data"];
                    if ([dataDic isKindOfClass:[NSDictionary class]]) {
                        
                        if ([dataDic[@"copyright"] isKindOfClass:[NSString class]]) {
                            [defaults setValue:dataDic[@"copyright"] forKey:BiYingCopyrightKey];
                        }
                        if ([dataDic[@"date"] isKindOfClass:[NSString class]]) {
                            [defaults setValue:dataDic[@"date"] forKey:BiYingDateKey];
                        }
                        if ([dataDic[@"description"] isKindOfClass:[NSString class]]) {
                            [defaults setValue:dataDic[@"description"] forKey:BiYingDescriptionKey];
                        }
                        if ([dataDic[@"img_1366"] isKindOfClass:[NSString class]]) {
                            [defaults setValue:dataDic[@"img_1366"] forKey:BiYingImg_1366Key];
                        }
                        if ([dataDic[@"img_1920"] isKindOfClass:[NSString class]]) {
                            [defaults setValue:dataDic[@"img_1920"] forKey:BiYingImg_1920Key];
                        }
                        if ([dataDic[@"subtitle"] isKindOfClass:[NSString class]]) {
                            [defaults setValue:dataDic[@"subtitle"] forKey:BiYingSubtitleKey];
                        }
                        if ([dataDic[@"title"] isKindOfClass:[NSString class]]) {
                            [defaults setValue:dataDic[@"title"] forKey:BiYingTitleKey];
                        }
                        [defaults synchronize];
                        
                        NSString *BiYingHighDefinitionSaveImageNamePrefix = @"BiYingHighDefinitionSaveImageName";
                        if ([defaults valueForKey:BiYingDateKey]) {
                            //保存路径
                            BiYingHighDefinitionSavePath = [NSObject wz_filePath:WZSearchPathDirectoryDocument fileName:[NSString stringWithFormat:@"%@%@",BiYingHighDefinitionSaveImageNamePrefix, [defaults valueForKey:BiYingDateKey]]];
                            if ([defaults valueForKey:BiYingImg_1920Key]) {
                                ///下载流程
                                NSURL * newUrl = [NSURL URLWithString:[defaults valueForKey:BiYingImg_1920Key]];
                                
                                [self downLoadURL:newUrl writeToFilePath:BiYingHighDefinitionSavePath handler:^(BOOL success) {
                                    if (success) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            //UI
                                            if ([[NSFileManager defaultManager] fileExistsAtPath:BiYingHighDefinitionSavePath]) {
                                                if (info) {
                                                    info([defaults valueForKey:BiYingCopyrightKey],
                                                         [defaults valueForKey:BiYingDateKey],
                                                         [defaults valueForKey:BiYingDescriptionKey],
                                                         [defaults valueForKey:BiYingTitleKey],
                                                         [defaults valueForKey:BiYingSubtitleKey],
                                                         [defaults valueForKey:BiYingImg_1366Key],
                                                         [defaults valueForKey:BiYingImg_1920Key],
                                                         [UIImage imageWithData:[NSData dataWithContentsOfFile:BiYingHighDefinitionSavePath]]);
                                                }
                                            }
                                        });
                                    }
                                }];
                            }
                        } else {
                            //日期出错
                        }
                    }
                }
            }
        }];
    }
}


+ (void)downLoadURL:(NSURL *)url writeToFilePath:(NSString *)path handler:(void (^)(BOOL success))handler {
    [self asyncDownloadImageWithURL:url complete:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UIImage *image = [UIImage imageWithData:data];
        BOOL s = false;
        if ([image isKindOfClass:[UIImage class]]) {
            //确定是图片 保存本地 更新 内容
            if ([data writeToFile:path atomically:true]) {
                NSLog(@"保存成功");
                s = true;
            } else {
                NSLog(@"保存失败");
            }
        } else {
            //数据错误
            NSLog(@"图片下载出错：%@", error.description);
        }
        if (handler) {
            handler(s);
        }
    }];
}

+ (NSURLSessionDataTask *)asyncDownloadImageWithURL:(NSURL *)url complete:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))complete {
    if ([url isKindOfClass:[NSURL class]]) {
        NSMutableURLRequest *requset = [NSMutableURLRequest requestWithURL:url];                                [requset setHTTPMethod:@"GET"];
        NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration] delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        NSURLSessionDataTask *dataTask = [delegateFreeSession dataTaskWithRequest:requset completionHandler:complete];
        [dataTask resume];
        return dataTask;
    } else {
        return nil;
    }
}

@end
