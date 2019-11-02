//
//  WZRecordSegment.h
//  WZGIF
//
//  Created by admin on 25/7/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/**
 * 摄像  录制的视频的段
 */
@interface WZRecordSegment : NSObject

@property (nonatomic, strong) NSURL *url;//录制的url
@property (nonatomic, readonly) AVAsset *asset;//相册的视频资源
@property (nonatomic, readonly) CMTime duration;//视频的时间
@property (nonatomic, readonly) UIImage *thumbnail;//缩略图
@property (nonatomic, readonly) UIImage *lastImage;//最后一真的图
@property (nonatomic, readonly) float frameRate;//帧率
@property (readonly, nonatomic) NSDictionary *info;//自定义的info
@property (readonly, nonatomic) BOOL fileUrlExists;//检查文件是否存在

@end
