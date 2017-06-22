//
//  WZAnimatedTransitionsBase.m
//  WZWeather
//
//  Created by admin on 17/6/19.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZAnimatedTransitionsBase.h"

@interface WZAnimatedTransitionsBase ()

@property (nonatomic, assign) BOOL dismissFlag;
@end

@implementation WZAnimatedTransitionsBase

- (WZAnimatedTransitionsBase *)configDismiss {
    _dismissFlag = true;
    return self;
}

- (WZAnimatedTransitionsBase *)configPresent {
    _dismissFlag = false;
    return self;
}

#pragma mark delegate


//配置过渡动画时间
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 2;
}

//配置过渡动画
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

    //call completeTransition when the transition animations complete
    __weak typeof(transitionContext) weakContext = transitionContext;
    __weak typeof(containerView) weakContainer = containerView;
    void (^completeTransition)() = ^(){
        [weakContext completeTransition:![weakContext transitionWasCancelled]];
    };
    CGFloat transitionDuration = [self transitionDuration:transitionContext];
    
    if (_dismissFlag) {
        if (_customDismissAnimations) {
            _customDismissAnimations(transitionDuration, containerView, fromVC.view, toVC.view, completeTransition);
        }
    } else {
        if (_customPrensentAnimations) {
            _customPrensentAnimations(transitionDuration, containerView, fromVC.view, toVC.view, completeTransition);
        }
    }
}

//动画结束后调用
- (void)animationEnded:(BOOL) transitionCompleted {
    NSLog(@"transitionCompleted _____%d", transitionCompleted);
}


@end
