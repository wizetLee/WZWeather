//
//  WZRatioCutOutView.h
//  WZTestDemo
//
//  Created by wizet on 22/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class WZRatioCutOutView;
@protocol WZRatioCutOutViewProtocol<NSObject>

///抛出比例
- (void)ratioCutOutView:(WZRatioCutOutView *)view leadingRatio:(CGFloat)leadingRatio trailingRatio:(CGFloat)trailingRatio leadingDrive:(BOOL)leadingDrive;
- (void)ratioCutOutViewBeginClipping;
- (void)ratioCutOutViewFinishClipping;

@end


@interface WZRatioCutOutView : UIView

@property (nonatomic, weak) id<WZRatioCutOutViewProtocol> delegate;

///设置能得到的的最小比例值 默认值为0.1 也就是百分之10的比率/// 0 ~ 1
@property (nonatomic, assign) CGFloat minimumRestrictRatio;

- (instancetype)init NS_UNAVAILABLE;//要用initWithFrame
///滑动
- (void)moveable:(BOOL)boolean;//defaul is true;
///设置不可动的预设范围
- (void)constantRatio:(CGFloat)ratio;
///更新视图
- (void)updateView;
///把手宽度
+ (CGFloat)handleW;

@end



