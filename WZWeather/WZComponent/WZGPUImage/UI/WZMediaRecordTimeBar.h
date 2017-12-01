//
//  WZMediaRecordTimeBar.h
//  WZWeather
//
//  Created by wizet on 21/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

///录制的进度视图
@interface WZMediaRecordTimeBar : UIView
///进度指示
- (void)setProgress:(CGFloat)progress;
///暂停标记
- (void)addSign;
///状态还原
- (void)formatting;

@end
