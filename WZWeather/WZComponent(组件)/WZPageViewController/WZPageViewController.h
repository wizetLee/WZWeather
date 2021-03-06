//
//  WZPageViewController.h
//  WZWeather
//
//  Created by wizet on 17/6/16.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZPageViewAssistController;
@class WZPageViewController;

/**
    UIPageViewController、有一个BUG 多只手指滑动不停顿  滑动到另外一个控制器时，有多个代理是不会动的
    目前的解决方案为:控制手势仅能使用一只手指滑动。
 **/
@protocol WZPageViewControllerProtocol <UIPageViewControllerDelegate>

//控制器角标传出
- (void)pageViewController:(UIPageViewController *)pageViewController showVC:(WZPageViewAssistController *)VC inIndex:(NSInteger)index;

@end

@interface WZPageViewController : UIPageViewController

@property (nonatomic,   weak) id <WZPageViewControllerProtocol> pageViewControllerDelegate;
@property (nonatomic, strong) NSArray <WZPageViewAssistController *> *reusableVCArray;
@property (nonatomic, strong, readonly) WZPageViewAssistController *currentVC;

//初始化展示的目标
- (void)showVCWithIndex:(NSInteger)index animated:(BOOL)animated;

@end
