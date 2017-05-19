//
//  WZAFNetworkReachabilityManager.h
//  WZWeather
//
//  Created by wizet on 17/4/26.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "WZCTTelephonyNetworkInfo.h"

@interface WZAFNetworkReachabilityManager : AFNetworkReachabilityManager

@property (nonatomic, strong) WZCTTelephonyNetworkInfo *networkInfo;

+ (void)beginMonitoring;

@end
