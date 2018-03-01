//
//  WZVideoRateAdjustmentTool.h
//  WZWeather
//
//  Created by 李炜钊 on 2018/2/28.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>


//一个配置起点和终点
struct WZCompositionRateAdjustmentRange {
    float origin;
    float destination;
};
typedef struct CG_BOXABLE WZCompositionRateAdjustmentRange WZCompositionRateAdjustmentRange;

CG_INLINE WZCompositionRateAdjustmentRange
WZCompositionRateAdjustmentRangeMake(CGFloat origin, CGFloat destination)
{
    WZCompositionRateAdjustmentRange range;
    range.origin = origin;
    range.destination = destination;
    return range;
}

//处理音轨、视轨 的scaleRange => compositioin
@interface WZVideoRateAdjustmentTool : NSObject


/**
 修改资源视轨，音轨的速率

 @param asset 需要处理的资源
 @param rate 变速率(rate > 0)
 @param range 需要变速的时间范围(此处归一化，所以取值[0.0, 1.0])
 @return 返回处理后的资源
 */
+ (AVAsset *)rateAdjustmentWithAsset:(AVAsset *)asset rate:(double)rate range:(struct WZCompositionRateAdjustmentRange)range;

/**
//更改某个轨道（音轨或视轨）的速率

 @param track 目标轨道
 @param rate 变速率(rate > 0)
 @param range 需要变速的时间范围(此处归一化，所以取值[0.0, 1.0])
 @param sourceDuration 轨道所在资源的时长，用于计算
 */
+ (void)rateAdjustmentWithTrack:(AVMutableCompositionTrack *)track rate:(double)rate range:(WZCompositionRateAdjustmentRange)range sourceDuration:(CMTime)sourceDuration;

@end
