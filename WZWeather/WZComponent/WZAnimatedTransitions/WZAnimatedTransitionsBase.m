//
//  WZAnimatedTransitionsBase.m
//  WZWeather
//
//  Created by admin on 17/6/19.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZAnimatedTransitionsBase.h"

@interface WZAnimatedTransitionsBase ()



@end

@implementation WZAnimatedTransitionsBase

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 10;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *fromVC = [transitionContext
                                viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext
                              viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    if (!fromVC
        ||!toVC
        ||!containerView) {
        return;
    }
    
    [containerView addSubview:fromVC.view];
    [containerView addSubview:toVC.view];
    
    //完成
    toVC.view.alpha = 0;
    [UIView animateWithDuration:10 animations:^{
        toVC.view.alpha = 1;
        fromVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:true];
    }];
    
}

@end
