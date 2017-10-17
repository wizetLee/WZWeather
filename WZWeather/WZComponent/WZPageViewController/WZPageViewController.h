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
  有一个BUG 多只手指滑动不停顿  滑动到另外一个控制器时，有多个代理是不会动的
 **/
@protocol WZProtocolPageViewController <UIPageViewControllerDelegate>

//控制器角标传出
- (void)pageViewController:(UIPageViewController *)pageViewController showVC:(WZPageViewAssistController *)VC inIndex:(NSInteger)index;

@end

@interface WZPageViewController : UIPageViewController

@property (nonatomic, weak) id<WZProtocolPageViewController> pageViewControllerDelegate;
@property (nonatomic, strong) NSArray <WZPageViewAssistController *> *reusableVCArray;
@property (nonatomic, strong) WZPageViewAssistController *currentVC;

//初始化展示的目标
- (void)showVCWithIndex:(NSInteger)index animated:(BOOL)animated;

@end
