//
//  MainViewController.m
//  WZWeather
//
//  Created by wizet on 17/2/27.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "MainViewController.h"
#import "WZDownloadController.h"
#import "WZPageViewController.h"
#import "WZPageViewAssistController.h"
@interface MainViewController ()



@end

@implementation MainViewController

//+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector bySwizzledSelector:(SEL)swizzledSelector{
//    Class class = [self class];
//    //原有方法
//    Method originalMethod = class_getInstanceMethod(class, originalSelector);
//    //替换原有方法的新方法
//    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//    //先尝试給源SEL添加IMP，这里是为了避免源SEL没有实现IMP的情况
//    BOOL didAddMethod = class_addMethod(class,originalSelector,
//                                        method_getImplementation(swizzledMethod),
//                                        method_getTypeEncoding(swizzledMethod));
//    if (didAddMethod) {//添加成功：说明源SEL没有实现IMP，将源SEL的IMP替换到交换SEL的IMP
//        class_replaceMethod(class,swizzledSelector,
//                            method_getImplementation(originalMethod),
//                            method_getTypeEncoding(originalMethod));
//    } else {//添加失败：说明源SEL已经有IMP，直接将两个SEL的IMP交换即可
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
//}
//
//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self methodSwizzlingWithOriginalSelector:@selector(viewWillAppear:) bySwizzledSelector:@selector(sure_viewWillDisappear:)];
//    });
//}
//
//- (void)sure_viewWillDisappear:(BOOL)animated {
//    [self sure_viewWillDisappear:animated];
//}

#pragma mark - ViewController Lifecycle

- (instancetype)init {
    if (self = [super init]) {}
    return self;    
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    //
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
    
}

#pragma mark touchesBegan

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
//    Class c = NSClassFromString(@"WZDownloadController");
    Class c = NSClassFromString(@"sViewController");
    
//    Class c = NSClassFromString(@"WZPageViewController");
    id v = [[c alloc] init];
    ((UIViewController *)v).view.backgroundColor = [UIColor yellowColor];
    [self presentViewController:v animated:true completion:^{
        NSLog(@"finished!");
    }];
//    WZPageViewAssistController *V0 = [WZPageViewAssistController new];
//    WZPageViewAssistController *V1 = [WZPageViewAssistController new];
//    WZPageViewAssistController *V2 = [WZPageViewAssistController new];
//    V0.view.backgroundColor = [UIColor yellowColor];
//    V2.view.backgroundColor = [UIColor magentaColor];
//    V1.view.backgroundColor = [UIColor orangeColor];
//    
//    ((WZPageViewController *)v).reusableVCArray = @[V0, V1, V2];
//    ((WZPageViewController *)v).delegate_pageViewController = (id<WZProtocol_PageViewController>)self;
//    [self.navigationController pushViewController:v animated:true];
}

//控制器角标传出
- (void)pageViewController:(UIPageViewController *)pageViewController showVC:(WZPageViewAssistController *)VC inIndex:(NSInteger)index {
    NSLog(@"vc-%@=======index-%ld", VC, index);
    
}

@end
