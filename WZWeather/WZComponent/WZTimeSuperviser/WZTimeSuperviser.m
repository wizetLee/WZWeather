//
//  WZTimeSuperviser.m
//  WZWeather
//
//  Created by admin on 17/5/3.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZTimeSuperviser.h"

@interface WZTimeSuperviser()

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) NSTimeInterval duration;

@end


@implementation WZTimeSuperviser
- (instancetype)init {
    if (self = [super init]) {
   
    }
    return self;
}

- (void)configTimer {
    dispatch_queue_t gobleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, gobleQueue);

    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, self.interval * NSEC_PER_SEC,  0 * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(_timer, ^{
        
        [self timerEvent];
        
    });
}

/**
 *  定时器事件
 */
- (void)timerEvent {
    if ([self.delegate respondsToSelector:@selector(timeSuperviser:currentTime:)]) {
        [self.delegate timeSuperviser:self currentTime:self.duration];
    }
    
    if (self.terminalTime) {
        if (self.duration < self.terminalTime) {
            //执行代理
        } else {
            //终止定时器
            [self timeSuperviserStop];
        }
    }
    
    self.duration = self.interval + self.duration;
}

/**
 *  开启定时器
 */
- (void)timeSuperviserFire {
    [self invalidate];
    
    {
        [self configTimer];
        [self fireEvent];
    }
}

- (void)fireEvent {
    if (_timer) {
        if (_pause) {
            //恢复启动
            _pause = false;
        } else {
            //首次启动
        }
        dispatch_resume(_timer);
    }
}

/**
 *  暂停定时器
 */
- (void)timeSuperviserPause {
    _pause = true;
    [self invalidate];
}

/**
 *  停止定时器
 */
- (void)timeSuperviserStop {
    self.duration = 0;
    [self invalidate];
}

/**
 *  使定时器无效
 */
- (void)invalidate {
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}


#pragma mark setter / getter

- (NSTimeInterval)interval {
    if (_interval == 0.0) {
        return 1.0;
    }
    return _interval;
}



@end
