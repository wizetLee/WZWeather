//
//  WZTimeSuperviser.m
//  WZWeather
//
//  Created by admin on 17/5/3.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZTimeSuperviser.h"

@interface WZTimeSuperviser()

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) NSTimer *timer;


@end


@implementation WZTimeSuperviser
- (instancetype)init {
    if (self = [super init]) {
   
    }
    return self;
}

- (void)configTimer {
    [self invalidate];

    _timer = [NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(timer:) userInfo:nil repeats:true];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}

- (void)timer:(NSTimer *)timer {
    [self timerEvent];
}

/**
 *  定时器事件
 */
- (void)timerEvent {
    //执行代理
    
//    NSLog(@"\n self.terminalTime :%lf \n self.duration:%lf"
//          , self.terminalTime, self.duration);
    if (_pause) {
        _pause = false;
    } else {
        if (self.duration != 0.0) {
            if ([self.delegate respondsToSelector:@selector(timeSuperviser:currentTime:)]) {
                [self.delegate timeSuperviser:self currentTime:self.duration];
            }
        }
        
        if (self.terminalTime) {
            NSTimeInterval countDown = (self.terminalTime - self.duration);
            if (countDown > 0.0) {
                //持续时间增加
                //            NSLog(@"\n self.terminalTime :%lf \n self.duration:%lf \n countDown:%lf"
                //                  , self.terminalTime, self.duration, countDown);
                self.duration = self.interval + self.duration;
            } else {
                //终止定时器
                [self timeSuperviserStop];
            }
        }
    }
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
        } else {
            //首次启动
            _duration = 0.0;
        }
        [_timer fire];
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
        [_timer invalidate];
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
