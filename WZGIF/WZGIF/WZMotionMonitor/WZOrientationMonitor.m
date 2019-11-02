//
//  WZOrientationMonitor.m
//  WZGIF
//
//  Created by wizet on 2017/7/23.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZOrientationMonitor.h"
#import "WZMotionMonitor.h"

@interface WZOrientationMonitor()

@property (nonatomic, strong) WZMotionMonitor *motionMonitor;

@end

@implementation WZOrientationMonitor

#pragma mark - Initialization
- (instancetype)initWithDelegate:(id<WZOrientationProtocol>)delegate {
    if (self = [super init]) {
        if ([delegate respondsToSelector:@selector(orientationMonitor:change:)]) {
            _delegate = delegate;
        }
    }
    return self;
}

- (void)stopMonitor {
    [_motionMonitor stopDeviceMotionUpdates];
}

//sensitive 灵敏度
static const float WZOrientationMonitorSensitive = 0.77;
- (void)startMonitor {
    [self.motionMonitor useDevieMotionWithHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        [self performSelectorOnMainThread:@selector(deviceMotion:) withObject:motion waitUntilDone:YES];
    }];
}

- (void)deviceMotion:(CMDeviceMotion *)motion {
    if ([_delegate respondsToSelector:@selector(orientationMonitor:change:)]) {
        double x = motion.gravity.x;
        double y = motion.gravity.y;
        if (y < 0 ) {
            if (fabs(y) > WZOrientationMonitorSensitive
                && _orientation != UIDeviceOrientationPortrait) {
                _orientation = UIDeviceOrientationPortrait;
                [_delegate orientationMonitor:self change:_orientation];
            }
        } else {
            if (y > WZOrientationMonitorSensitive
                && _orientation != UIDeviceOrientationPortraitUpsideDown) {
                _orientation = UIDeviceOrientationPortraitUpsideDown;
                [_delegate orientationMonitor:self change:_orientation];
            }
        }
        
        if (x < 0 ) {
            if (fabs(x) > WZOrientationMonitorSensitive) {
                if (_orientation != UIDeviceOrientationLandscapeLeft) {
                    _orientation = UIDeviceOrientationLandscapeLeft;
                    [_delegate orientationMonitor:self change:_orientation];
                }
            }
        } else {
            if (x > WZOrientationMonitorSensitive
                && _orientation != UIDeviceOrientationLandscapeRight) {
                _orientation = UIDeviceOrientationLandscapeRight;
                [_delegate orientationMonitor:self change:_orientation];
            }
        }
    }
}

#pragma mark - Accessor

- (WZMotionMonitor *)motionMonitor {
    if (!_motionMonitor) {
        _motionMonitor = [[WZMotionMonitor alloc] init];
    }
    return _motionMonitor;
}

@end
