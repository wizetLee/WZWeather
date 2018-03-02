//
//  WZAppActiveNoticeProtocol.h
//  WZWeather
//
//  Created by admin on 2/3/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

///APP挂起通知协议
@protocol WZAppActiveNoticeProtocol <NSObject>

@public

///加入通知 (initial 处)
- (void)addAppActiveNotification;
///移除通知（dealloc 处）
- (void)removeAppActiveNotification;

- (void)willResignActiveNotification:(NSNotification *)notification;

- (void)didBecomeActiveNotification:(NSNotification *)notification;

@end


//- (void)removeAppActiveNotification {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
//}


//- (void)addAppActiveNotification {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
//}

//#pragma mark - AppActiveNotification
//- (void)willResignActiveNotification:(NSNotification *)notification {
//
//}


//- (void)didBecomeActiveNotification:(NSNotification *)notification {
//
//}

