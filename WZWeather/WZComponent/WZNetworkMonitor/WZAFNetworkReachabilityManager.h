//
//  WZAFNetworkReachabilityManager.h
//  WZWeather
//
//  Created by admin on 17/4/26.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface WZAFNetworkReachabilityManager : AFNetworkReachabilityManager

+ (void)beginMonitoring;

@end
