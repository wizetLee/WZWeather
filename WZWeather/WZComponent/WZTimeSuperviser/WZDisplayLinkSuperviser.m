//
//  WZDisplayLinkSuperviser.m
//  WZWeather
//
//  Created by wizet on 17/5/5.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZDisplayLinkSuperviser.h"

@interface WZDisplayLinkSuperviser()

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation WZDisplayLinkSuperviser

@synthesize duration = _duration;

- (void)configTimer {
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(dispalyLink:)];
    _displayLink.paused = true;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    _displayLink.frameInterval = 60.0 * _interval;
}

- (void)setInterval:(NSTimeInterval)interval {
    _interval = interval;
    if (_displayLink) {
        _displayLink.frameInterval = 60.0 * _interval;
    }
}

- (void)dispalyLink:(CADisplayLink *)displayLink {
    [self timerEvent];
    //继续计算
}

- (void)fireEvent {
    //开始事件
    if (_displayLink) {
        if (_pause) {
            //恢复启动
        } else {
            _duration = 0.0;
        }
        _displayLink.paused = false;
    }
}

- (void)invalidate {
    //失效事件
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    
}

@end
