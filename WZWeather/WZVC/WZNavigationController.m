//
//  WZNavigationController.m
//  WZWeather
//
//  Created by wizet on 29/9/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZNavigationController.h"

@interface WZNavigationController ()

///系统侧滑黑名单:控制器
@property (nonatomic, strong) NSMutableArray <NSString *>* systemSideslipBlacklist;

@end

@implementation WZNavigationController

#pragma mark - ViewController Lifecycle

- (instancetype)init {
    if (self = [super init]) {}
    return self;
}

- (void)loadView {
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.backgroundColor = [UIColor whiteColor];
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
    NSLog(@"%s", __FUNCTION__);
}


// MARK: - Accessor

-(NSMutableArray<NSString *> *)systemSideslipBlacklist {
    if (!_systemSideslipBlacklist) {
        _systemSideslipBlacklist = [NSMutableArray array];
    }
    return _systemSideslipBlacklist;
}

- (void)addToSystemSideslipBlacklist:(NSString *)target {
    if ([target isKindOfClass:[NSString class]]) {
        if (![self.systemSideslipBlacklist containsObject:target]) {
            [self.systemSideslipBlacklist addObject:target];
        }
    }
}

- (BOOL)systemSideslipBlacklistCheckIn:(NSString *)target {
    return [self.systemSideslipBlacklist containsObject:target];
}

@end
