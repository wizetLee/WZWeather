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

//切换完控制器数据等传出
//控制器角标传出



@end

@interface WZPageViewController : UIPageViewController

@property (nonatomic, weak) id<WZProtocol_PageViewController> delegate_pageViewController;
@property (nonatomic, strong) NSArray <WZPageViewAssistController *>*reusableVCArray;

- (void)createViews;

@end
