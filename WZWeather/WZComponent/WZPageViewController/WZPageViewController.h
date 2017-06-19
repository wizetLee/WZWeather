//
//  WZPageViewController.h
//  WZWeather
//
//  Created by admin on 17/6/16.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZPageViewAssistController;
@class WZPageViewController;

@protocol WZProtocol_PageViewController <UIPageViewControllerDelegate>

//控制器角标传出
- (void)pageViewController:(UIPageViewController *)pageViewController showVC:(WZPageViewAssistController *)VC inIndex:(NSInteger)index;

@end

@interface WZPageViewController : UIPageViewController

@property (nonatomic, weak) id<WZProtocol_PageViewController> delegate_pageViewController;
@property (nonatomic, strong) NSArray <WZPageViewAssistController *> *reusableVCArray;
@property (nonatomic, strong) WZPageViewAssistController *currentVC;

//初始化展示的目标
- (void)showVCWithIndex:(NSInteger)index animated:(BOOL)animated;

@end
