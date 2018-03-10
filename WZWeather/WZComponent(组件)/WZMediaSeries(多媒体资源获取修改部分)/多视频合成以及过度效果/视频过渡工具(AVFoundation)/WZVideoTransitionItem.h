//
//  WZVideoTransitionItem.h
//  PuzzleVideoProject
//
//  Created by wizet on 23/1/18.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

///过渡效果（目前只有几个简单效果）
typedef NS_ENUM(NSUInteger, BIVideoTransitionEffectType) {
    BIVideoTransitionEffectType_None          = 0,
    BIVideoTransitionEffectType_Dissolve,               //溶解
    BIVideoTransitionEffectType_Move_LToR,              //左向右
    BIVideoTransitionEffectType_Move_RToL,
    BIVideoTransitionEffectType_Move_TToB,
    BIVideoTransitionEffectType_Move_BToT,
};


/**
 注意第一个item的startTransitionDuration 为kCMTimeZero
 注意最后一个item的endTransitionDuration 为kCMTimeZero
 videoleap APP中这个item的type 决定与后面视频的过渡配置效果
 **/
///即将用于过渡的item
@interface WZVideoTransitionItem : NSObject

@property (nonatomic, strong) AVAsset *asset;                   //source
@property (nonatomic, assign) BIVideoTransitionEffectType transitionEffectType;//与后下一个视频的过渡效果

@property (nonatomic, assign) CMTime startTransitionDuration;       //与上一个视频的过渡时间
@property (nonatomic, assign) CMTime endTransitionDuration;         //与下一个视频的过渡时间的startTransitionDuration相等

@property (nonatomic, assign, readonly) CMTimeRange timeRange;            //source的有效范围

//插入到轨道的时间片段
@property (nonatomic, assign, readonly) CMTimeRange playthroughTimeRange;           //非过渡的播时间
@property (nonatomic, assign, readonly) CMTimeRange startTransitionTimeRange;       //开始过渡的时间
@property (nonatomic, assign, readonly) CMTimeRange endTransitionTimeRange;         //结束过渡的时间


#warning 需求
//视频的画面属性(偏移量、放大倍数、旋转角度)
//视频的速率属性(速率、倒放、音量)

@end
