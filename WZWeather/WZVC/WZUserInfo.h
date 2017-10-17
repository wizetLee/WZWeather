//
//  WZUserInfo.h
//  WZWeather
//
//  Created by wizet on 17/4/14.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

//单例
/**
 *  获取当前的用户当前所使用设备的所有的信息
 */
@interface WZUserInfo : NSObject
@property (nonatomic, strong) NSString *nickname;
+ (instancetype)shareInstance;

@end
