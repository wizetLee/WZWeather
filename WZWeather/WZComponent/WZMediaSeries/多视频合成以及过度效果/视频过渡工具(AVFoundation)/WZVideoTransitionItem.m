//
//  WZVideoTransitionItem.m
//  PuzzleVideoProject
//
//  Created by wizet on 23/1/18.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "WZVideoTransitionItem.h"

@implementation WZVideoTransitionItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _asset = nil;
        _transitionEffectType = BIVideoTransitionEffectType_None;
        _startTransitionDuration = kCMTimeZero;
        _endTransitionDuration = kCMTimeZero;
    }
    return self;
}

#pragma mark - Accessor

- (CMTimeRange)timeRange {
    if (_asset) {
        return CMTimeRangeMake(kCMTimeZero, _asset.duration);
    }
    return kCMTimeRangeInvalid;//kCMTimeRangeZero
}

- (CMTimeRange)playthroughTimeRange {
    CMTimeRange range = self.timeRange;
    if (self.transitionEffectType != BIVideoTransitionEffectType_None) {
        range.start = CMTimeAdd(range.start, self.startTransitionDuration);//开始点延后
        range.duration = CMTimeSubtract(range.duration, self.startTransitionTimeRange.duration);//整体时间减少
    }
    if (self.transitionEffectType != BIVideoTransitionEffectType_None) {
        range.duration = CMTimeSubtract(range.duration, self.endTransitionDuration);//整体时间减少
    }
    return range;
}

- (CMTimeRange)endTransitionTimeRange {
    if (self.transitionEffectType != BIVideoTransitionEffectType_None) {
        CMTime beginTransitionTime = CMTimeSubtract(self.timeRange.duration, self.endTransitionDuration);//减掉
        return CMTimeRangeMake(beginTransitionTime, self.endTransitionDuration);
    }
    return CMTimeRangeMake(self.timeRange.duration, kCMTimeZero);
}

- (CMTimeRange)startTransitionTimeRange {
    if (self.transitionEffectType != BIVideoTransitionEffectType_None) {
        return CMTimeRangeMake(kCMTimeZero, self.startTransitionDuration);
    }
    return CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
}

@end
