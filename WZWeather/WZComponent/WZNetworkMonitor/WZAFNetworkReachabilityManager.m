//
//  WZAFNetworkReachabilityManager.m
//  WZWeather
//
//  Created by admin on 17/4/26.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZAFNetworkReachabilityManager.h"

//导入CoreTelephony frameWork
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


@implementation WZAFNetworkReachabilityManager

+ (void)beginMonitoring {
    [[WZAFNetworkReachabilityManager sharedManager] startMonitoring];
    [[WZAFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"网络不可用");
        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
            
            
            CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
            if (currentRadioAccessTechnology)
            {
                if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE])
                {
                  
                }
                else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS])
                {
                   
                }
                else
                {
                  
                }
               
                
            }
       
            
            
            
            NSLog(@"蜂窝网络");
        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            NSLog(@"wifi网络");
        } else {
            NSLog(@"未知网络状态");
        }
    }];
}


//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
//        NSInteger status = [info[AFNetworkingReachabilityNotificationStatusItem] integerValue];
//开始网络监听
//- (void)networkStatusChange:(NSNotification *)notification {
//    NSDictionary *info = (NSDictionary *)notification.userInfo;
//    if ([info[AFNetworkingReachabilityNotificationStatusItem] isKindOfClass:[NSNumber class]]) {
//        NSInteger status = [info[AFNetworkingReachabilityNotificationStatusItem] integerValue];
//        if (status == AFNetworkReachabilityStatusNotReachable) {
//            NSLog(@"网络不可用");
//        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
//            NSLog(@"蜂窝网络");
//        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
//            NSLog(@"wifi网络");
//        } else {
//            NSLog(@"未知网络状态");
//        }
//    }
//    
//}

@end
