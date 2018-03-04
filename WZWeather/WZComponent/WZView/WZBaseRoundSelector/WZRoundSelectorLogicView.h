//
//  WZRoundSelectorLogicView.h
//  WZBaseRoundSelector
//
//  Created by wizet on 17/3/28.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZRoundRenderLayer.h"

typedef NS_ENUM(NSInteger, WZRSStatus) {
    WZRSStatusOnFirstArea    = 1,
    WZRSStatusOnSecondArea   = 2,
    WZRSStatusOnThirdArea    = 3,
    WZRSStatusOnFourthArea   = 4
};

/*
  4 |   1
 ___|____
    |
  3 |   2
 **/

/**
 *  renderlayer 总是居中     抽象类，使用其子类
 */
@interface WZRoundSelectorLogicView : UIView

{
    WZRSStatus _status;
}

@property (nonatomic, assign) double curValue;
@property (nonatomic, assign, readonly) double maxValue;

@property (nonatomic, assign) WZRSStatus status;


- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype) initWithFrame:(CGRect)frame
                      curValue:(double)curValue
                      maxValue:(double)maxValue;

/**
 *  圈移动的角度
 *
 *  @param metric 角度值
 */
- (void)metric:(double)metric;

/**
 *  按照渲染角度渲染
 *
 *  @param renderAngle range (0,1)
 */
- (void)renderAngle:(double)renderAngle;

@end
