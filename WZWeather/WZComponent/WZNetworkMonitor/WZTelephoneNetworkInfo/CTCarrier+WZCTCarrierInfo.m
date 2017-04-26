//
//  CTCarrier+WZCTCarrierInfo.m
//  WZWeather
//
//  Created by admin on 17/4/26.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "CTCarrier+WZCTCarrierInfo.h"

@implementation CTCarrier (WZCTCarrierInfo)

- (void)wzCarrireInfo {
    NSLog(@"carrierName :%@ \n mobileCountryCode :%@ \n mobileNetworkCode :%@ \n isoCountryCode :%@", self.carrierName, self.mobileCountryCode, self.mobileNetworkCode, self.isoCountryCode);
    /*
     
     isoCountryCode 国家代码表
     VoIP（Voice over Internet Protocol）简而言之就是将模拟信号（Voice）数字化
     */
}

@end
