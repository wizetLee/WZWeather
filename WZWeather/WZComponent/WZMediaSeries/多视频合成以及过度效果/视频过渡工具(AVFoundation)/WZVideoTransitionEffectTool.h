//
//  WZVideoTransitionEffectTool.h
//  PuzzleVideoProject
//
//  Created by wizet on 23/1/18.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "WZVideoTransitionItem.h"

/*
 考虑：只使用AVFoundation层面的动画还是使用GPUImage制作相应的视频过渡效果
 */

/**
    1、若干种过渡效果
    2、注意视频过渡时间(不过渡、过渡)，注意过渡时间和视频时间之间的关系
        视频的过渡节点称之为timeline，一个timeline与两个视频段的时间有关联，node的个数 = 总视频段数 - 1
 
    3、回调
        合成开始
        合成进度
        合成完成（失败、成功，抛出合成视频的文件路径）
    4、选择视频域（修改AVMutableVideoCompositionLayerInstruction的layer）
    5、音频（origion only、music only 、mix 、none）
    6、循环播放效果
    7、全屏__非全屏
    8、播放速率：
 */

typedef NS_ENUM(NSUInteger, WZVideoTransitionEffectToolStatus) {
    WZVideoTransitionEffectToolStatus_Idle                = 0,      //空闲状态（资源不足/资源为空）
    WZVideoTransitionEffectToolStatus_Ready,                        //可开始合成
    WZVideoTransitionEffectToolStatus_Completed,                    //合成完毕
    WZVideoTransitionEffectToolStatus_Failed,                       //合成失败
    WZVideoTransitionEffectToolStatus_Converting,                   //正在合成
};

@class WZVideoTransitionEffectTool;
@protocol WZVideoTransitionEffectToolProtocol <NSObject>
///视频合成的进度
- (void)videoTransitionEffectTool:(WZVideoTransitionEffectTool *)tool progress:(float)progress;

///完成情况成功
- (void)videoTransitionEffectTool:(WZVideoTransitionEffectTool *)tool completeWithOutputURL:(NSURL *)outputURL;

///任务失败
- (void)videoTransitionEffectToolTaskFailed;

///任务被取消
- (void)videoTransitionEffectToolTaskCanceled;


@end

@interface WZVideoTransitionEffectTool : NSObject

@property (nonatomic,   weak) id <WZVideoTransitionEffectToolProtocol>delegate;
@property (nonatomic, assign) WZVideoTransitionEffectToolStatus status;
@property (nonatomic, strong) NSURL *outputURL;   //保存的位置  注意:内置的是mp4的文件类型
@property (nonatomic, strong, readonly) NSMutableArray <WZVideoTransitionItem *>*videoSourcesList;//配置过渡效果
@property (nonatomic, assign) CGSize outputSize; //内置为{720,1024}

- (void)startTask;      //开始任务
- (void)cancelTask;     //取消任务

///首次任务前的准备，或者更换了资源，都需要prepareTask（主要是需要吧status设置为ready状态）（以下3个接口功能一样）
//- (void)prepareTask;
- (void)prepareTaskWithAssetSources:(NSArray <AVAsset *> *)sources; //更换数据源之后
- (void)prepareTaskWithItemSources:(NSArray <WZVideoTransitionItem *> *)sources;


@end
