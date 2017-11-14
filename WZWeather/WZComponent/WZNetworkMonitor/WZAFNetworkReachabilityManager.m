//
//  WZAFNetworkReachabilityManager.m
//  WZWeather
//
//  Created by wizet on 17/4/26.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZAFNetworkReachabilityManager.h"

//导入CoreTelephony frameWork
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


@implementation WZAFNetworkReachabilityManager

+ (void)beginMonitoring {
    [[WZAFNetworkReachabilityManager sharedManager] startMonitoring];
    [[WZAFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        [WZAFNetworkReachabilityManager sharedManager].networkInfo.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier) {
            //运营商更换
            //                    carrier.carrierName
            //                    carrier.mobileCountryCode
            //                    carrier.mobileNetworkCode
            //                    carrier.isoCountryCode
            //                    carrier.allowsVOIP
            NSLog(@"运营商更换");
        };
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"网络不可用");
             //抛出回调
            [WZToast toastWithContent:@"请打开网络设置：\n设置->蜂窝移动网络->使用无线局域网与蜂窝移动的应用->选择任意一个应用->切换它的数据使用类型->回到当前App就会出现使用数据的选项" duration:15];//换成Alert
        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
            NSLog(@"蜂窝网络变更");
            #ifdef __IPHONE_7_0
            //不使用[WZAFNetworkReachabilityManager sharedManager].networkInfo
            //因为当从app回到主界面再回到app会得不到 currentRadioAccessTechnology

            WZCTTelephonyNetworkInfo *networkInfo = [[WZCTTelephonyNetworkInfo alloc] init];
            NSString *currentRadioAccessTechnology = networkInfo.currentRadioAccessTechnology;
                if (currentRadioAccessTechnology) {
                    if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                        //4G
                        NSLog(@"4G");
                    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]
                               || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                        //2G
                        NSLog(@"2G");
                    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]
                               || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]
                               || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]
                               || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]
                               || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]
                               || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]
                               || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]
                               || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]){
                        //3G
                        NSLog(@"3G");
                    } else {
                        NSLog(@"新网络类型, 注意更新");
                        //新类型
                    }
                }
            #else
                NSLog(@"蜂窝网络");
            #endif
        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            NSLog(@"wifi网络");
        } else {
            NSLog(@"未知网络状态");
        }
    }];
}

//Accessor
- (WZCTTelephonyNetworkInfo *)networkInfo {
    if (!_networkInfo) {
        _networkInfo = [[WZCTTelephonyNetworkInfo alloc] init];
    }
    return _networkInfo;
}

@end
