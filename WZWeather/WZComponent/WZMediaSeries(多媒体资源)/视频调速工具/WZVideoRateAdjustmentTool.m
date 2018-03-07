//
//  WZVideoRateAdjustmentTool.m
//  WZWeather
//
//  Created by 李炜钊 on 2018/2/28.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZVideoRateAdjustmentTool.h"



@interface WZVideoRateAdjustmentTool()

@end

@implementation WZVideoRateAdjustmentTool

///检查并约束指定的变速范围
void WZVideoRateAdjustmentToolCheckRange(WZCompositionRateAdjustmentRange *range) {
    if ((*range).origin < 0.0) {
        (*range).origin = 0.0;
    }
    if ((*range).destination < 0.0) {
        (*range).destination = 0.0;
    }
    if ((*range).origin > 1.0) {
        (*range).origin = 1.0;
    }
    if ((*range).destination > 1.0) {
        (*range).destination = 1.0;
    }
    
    if ((*range).destination < (*range).origin) {
        float tmp = (*range).origin;
        (*range).origin  = (*range).destination;
        (*range).destination = tmp;
    }
}

///根据参数修改某轨道的速率
+ (void)rateAdjustmentWithTrack:(AVMutableCompositionTrack *)track rate:(double)rate range:(WZCompositionRateAdjustmentRange)range sourceDuration:(CMTime)sourceDuration {
    if (rate <= 0) { rate = 1.0; NSLog(@"速率配置错误, 修改为内置配置"); }
    WZVideoRateAdjustmentToolCheckRange(&range);
    
    CMTime rateAdjustmentOrigin = CMTimeMake(sourceDuration.value * range.origin, sourceDuration.timescale);
    CMTime rateAdjustmentDestination = CMTimeMake(sourceDuration.value * range.destination, sourceDuration.timescale);
    CMTimeRange targetTimeRange = CMTimeRangeMake(rateAdjustmentOrigin, rateAdjustmentDestination);
    
    CMTime targetDuration = CMTimeMake(CMTimeSubtract(rateAdjustmentDestination, rateAdjustmentOrigin).value / rate, sourceDuration.timescale);
    
    [track scaleTimeRange:targetTimeRange toDuration:targetDuration];
}


+ (AVAsset *)rateAdjustmentWithAsset:(AVAsset *)asset rate:(double)rate range:(WZCompositionRateAdjustmentRange)range {
    //过滤操作
    if (rate <= 0) { rate = 1.0; NSLog(@"速率配置错误, 修改为内置配置"); }
    
    WZVideoRateAdjustmentToolCheckRange(&range);
    
    if (range.origin == range.destination || rate == 1.0) {
        return asset;
    }
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    NSArray <NSString *>*traskTypes = @[AVMediaTypeVideo, AVMediaTypeAudio];
    
    [traskTypes enumerateObjectsUsingBlock:^(NSString *  _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [[asset tracksWithMediaType:type] enumerateObjectsUsingBlock:^(AVAssetTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSError *error = nil;
            AVMutableCompositionTrack *track = [composition addMutableTrackWithMediaType:type preferredTrackID:kCMPersistentTrackID_Invalid];
            [track insertTimeRange:CMTimeRangeMake(CMTimeMake(0.0, asset.duration.timescale), asset.duration) ofTrack:obj atTime:CMTimeMake(0.0, asset.duration.timescale) error:&error];
            if (!error) {
                [self rateAdjustmentWithTrack:track rate:rate range:range sourceDuration:asset.duration];
            } else {
                [composition removeTrack:track];
            }
        }];
    }];
   
   
    return composition;
}

@end

