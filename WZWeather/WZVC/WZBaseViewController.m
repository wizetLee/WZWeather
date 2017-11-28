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
    if (@available (iOS 11.0, *)) {
        //iOS 对于automaticallyAdjustsScrollViewInsets废弃操作的更改
    }
    
//    if ([self customTransitions]) {
//        self.transitioningDelegate = (id<UIViewControllerTransitioningDelegate>)self;
//        self.modalInteractor.gesture = [self addScreenEdgePanGestureRecognizer:self.view edges:UIRectEdgeLeft];
//    };
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
    ///可以在此处控制系统侧滑白名单
    if ([self.navigationController systemSideslipBlacklistCheckIn:NSStringFromClass([self class])]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = false;
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = true;
    }
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

#pragma mark - Public Method

#pragma marks -
- (BOOL)customTransitions {
    return false;
}

#pragma mark - UIViewControllerTransitioningDelegate 模态动画

// 添加手势的方法
- (UIScreenEdgePanGestureRecognizer *)addScreenEdgePanGestureRecognizer:(UIView *)view edges:(UIRectEdge)edges{
    UIScreenEdgePanGestureRecognizer * edgePan =// [[UIScreenEdgePanGestureRecognizer alloc] init];
    [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgePanGesture:)]; // viewController和SecondViewController的手势都由self管理
    edgePan.edges = edges;
    [view addGestureRecognizer:edgePan];
    return edgePan;
}

- (void)edgePanGesture:(UIScreenEdgePanGestureRecognizer *)edge {
    if (edge.state == UIGestureRecognizerStateBegan) {
        WZBaseViewController *vc = [[WZBaseViewController alloc] init];
        vc.view.backgroundColor = [UIColor greenColor];
        [self presentViewController:vc animated:true completion:^{
            NSLog(@"presenet completion");
        }];
    } else  if (edge.state == UIGestureRecognizerStateEnded) {
    } else {
    }
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    NSLog(@"%s", __func__);
    return [self.modalAnimator configPresent];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    NSLog(@"%s", __func__);
    return [self.modalAnimator configDismiss];
}

//交互动画
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

#pragma mark - Accessor
- (WZNavigationController *)navigationController
{
    if (super.navigationController) {
        NSAssert([super.navigationController isKindOfClass:[WZNavigationController class]], @"NavigationController 类型错误");
    }
    return (WZNavigationController *)super.navigationController;
}

- (WZAnimatedTransitionsBase *)modalAnimator {
    if (!_modalAnimator) {
        _modalAnimator = [[WZAnimatedTransitionsBase alloc] init];
        _modalAnimator.customPrensentAnimations = [self presentAnimations];
        _modalAnimator.customDismissAnimations = [self dismissAnimations];
    }
    return _modalAnimator;
}

- (WZInteractiveTransitionsBase *)modalInteractor {
    if (!_modalInteractor) {
        _modalInteractor = [[WZInteractiveTransitionsBase alloc] init];
    }
    return _modalInteractor;
}



#pragma mark - 配置自定义模态动画
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
