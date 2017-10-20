//
//  WZBaseViewController.h
//  WZWeather
//
//  Created by wizet on 17/2/27.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZNavigationController.h"
@class WZAnimatedTransitionsBase;
@class WZInteractiveTransitionsBase;

@interface WZBaseViewController : UIViewController
///重载系统属性 指定由WZNavigationController 跳转到本控制器
@property (nonatomic, strong, readonly) WZNavigationController *navigationController;

@property (nonatomic, strong) WZAnimatedTransitionsBase *modalAnimator;
@property (nonatomic, strong) WZInteractiveTransitionsBase *modalInteractor;


- (BOOL)customTransitions;

@end
