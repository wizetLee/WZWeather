//
//  WZUserInfo.m
//  WZWeather
//
//  Created by wizet on 17/4/14.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZUserInfo.h"

static WZUserInfo *userInfo = nil;

@implementation WZUserInfo

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userInfo =  [[WZUserInfo alloc] init];
    });
    return userInfo;
}

@end
