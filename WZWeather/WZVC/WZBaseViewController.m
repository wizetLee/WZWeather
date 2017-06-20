//
//  WZBaseViewController.m
//  WZWeather
//
//  Created by wizet on 17/2/27.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZBaseViewController.h"

#import "WZAnimatedTransitionsBase.h"
#import "WZInteractiveTransitionsBase.h"
#import "sViewController.h"
@interface WZBaseViewController ()

@end

@implementation WZBaseViewController

#pragma mark - ViewController Lifecycle

- (instancetype)init {
    if (self = [super init]) {}
    return self;
}

- (void)loadView {
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.backgroundColor = [UIColor whiteColor];
    if ([self customTransitions]) {
        self.transitioningDelegate = (id<UIViewControllerTransitioningDelegate>)self;
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
       
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"%@", self);
}

#pragma mark
- (BOOL)customTransitions {
    return true;
}

#pragma mark UIViewControllerTransitioningDelegate 模态动画
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    NSLog(@"%s", __func__);
    return [self.modalAnimator configPresent];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    NSLog(@"%s", __func__);
    return [self.modalAnimator configDismiss];
}

////交互动画
//- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
//    NSLog(@"%s", __func__);
//    return self.modalInteractor;
//}
//
//- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
//    NSLog(@"%s", __func__);
//    return self.modalInteractor;
//}

//- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source NS_AVAILABLE_IOS(8_0) {
//    return nil;
//}

#pragma mark Accessor
- (WZAnimatedTransitionsBase *)modalAnimator {
    if (!_modalAnimator) {
        _modalAnimator = [[WZAnimatedTransitionsBase alloc] init];
        _modalAnimator.customPrensentAnimations = [self presentAnimations];
        _modalAnimator.customDismissAnimations = [self dismissAnimations];
    }
    return _modalAnimator;
}

//- (WZInteractiveTransitionsBase *)modalInteractor {
//    if (!_modalInteractor) {
//        _modalInteractor = [[WZInteractiveTransitionsBase alloc] init];
//    }
//    return _modalInteractor;
//}

#pragma mark 配置自定义模态动画
- (WZCustomAnimatedHandler)presentAnimations {
    WZCustomAnimatedHandler animations =  ^(float transitionDuration, UIView * containerView, UIView * fromView, UIView * toView, void (^completeTransition)()) {
        fromView.alpha = 1;
        toView.alpha = 0;
        [UIView animateWithDuration:transitionDuration animations:^{
            fromView.alpha = 0;
            toView.alpha = 1;
        } completion:^(BOOL finished) {
            if (completeTransition) {completeTransition();};
        }];
    };
    return animations;
}

- (WZCustomAnimatedHandler)dismissAnimations {
    WZCustomAnimatedHandler animations = ^(float transitionDuration, UIView * containerView, UIView * fromView, UIView * toView, void (^completeTransition)()) {
        fromView.alpha = 1;
        toView.alpha = 0;
        [UIView animateWithDuration:transitionDuration animations:^{
            fromView.alpha = 0;
            toView.alpha = 1;
        } completion:^(BOOL finished) {
            if (completeTransition) {completeTransition();};
        }];
    };
    return animations;
}


@end
