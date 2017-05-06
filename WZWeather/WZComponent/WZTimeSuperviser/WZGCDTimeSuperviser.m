//
//  WZGCDTimeSuperviser.m
//  WZWeather
//
//  Created by wizet on 17/5/6.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZGCDTimeSuperviser.h"

@interface WZGCDTimeSuperviser()

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) NSTimeInterval duration;

@end

@implementation WZGCDTimeSuperviser

@synthesize duration = _duration;

- (void)configTimer {
    [self invalidate];
    
    dispatch_queue_t gobleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, gobleQueue);
    
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, self.interval * NSEC_PER_SEC,  0 * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(_timer, ^{
        //定时器事件
        [self timerEvent];
        
    });
}

- (void)fireEvent {
    if (_timer) {
        if (_pause) {
            //恢复启动
        } else {
            //首次启动
            _duration = 0.0;
        }
        dispatch_resume(_timer);
    }
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


@end
