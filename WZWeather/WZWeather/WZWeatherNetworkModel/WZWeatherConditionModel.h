//
//  WZWeatherConditionModel.h
//  WZWeather
//
//  Created by admin on 17/5/10.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^weatherCondition) (NSDictionary *callBack, NSError *error);

@interface WZWeatherConditionModel : NSObject

+ (void)fetchWeatherConditionWithAreaCity:(NSString *)areaCity weatherConditionCallBack:(weatherCondition)weatherCondition;

@end
