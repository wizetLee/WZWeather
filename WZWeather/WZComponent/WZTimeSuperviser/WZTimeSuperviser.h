//
//  WZTimeSuperviser.h
//  WZWeather
//
//  Created by admin on 17/5/3.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WZTimeSuperviser;

@protocol  WZTimeSuperviserDelegate <NSObject>

- (void)timeSuperviser:(WZTimeSuperviser *)timeSuperviser currentTime:(NSTimeInterval)currentTime;


@end

@interface WZTimeSuperviser : NSObject
{
    NSTimeInterval _interval;
    BOOL _pause;
}
/**
 *  定时器间隔 默认是1s
 */
@property (nonatomic, assign) NSTimeInterval interval;

/**
 *  可查看是否处于暂停状态
 */
@property (nonatomic, assign, readonly) BOOL pause;

/**
 *  持续时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval duration;

/**
 *  回调代理
 */
@property (nonatomic, weak) id<WZTimeSuperviserDelegate> delegate;


- (void)timeSuperviserFire;

- (void)timeSuperviserPause;

- (void)timeSuperviserStop;


@end
