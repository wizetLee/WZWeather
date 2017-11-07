//
//  WZNavigationController.h
//  WZWeather
//
//  Created by wizet on 29/9/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZNavigationController : UINavigationController

///系统侧滑的黑名单加入到黑名单
- (void)addToSystemSideslipBlacklist:(NSString *)target;
///检查是否在系统侧滑的黑名单中
- (BOOL)systemSideslipBlacklistCheckIn:(NSString *)target;

@end
