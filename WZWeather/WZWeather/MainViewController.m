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
#import "WZLoopView.h"
#import "WZScrollOptions.h"
#import "UIButton+WZMinistrant.h"
#import "WZSystemDetails.h"
#import "WZMediaController.h"

@interface MainViewController ()

@property (nonatomic,strong) WZScrollOptions *menuView;

@end

@implementation MainViewController

///方法交换
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"导航栏";
    NSMutableArray *tmpArr = [NSMutableArray array];
    for (int i = 0; i <  20; i++) {
        [tmpArr addObject:[NSString stringWithFormat:@"%d", i]];
    }
    WZLoopView *loop = [[WZLoopView alloc] initWithFrame:CGRectMake(0.0, MACRO_FLOAT_STSTUSBAR_AND_NAVIGATIONBAR_HEIGHT, MACRO_FLOAT_SCREEN_WIDTH, 100) images:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", ] loop:true delay:2];
    [self.view addSubview:loop];
    UIButton *button                = [[UIButton alloc] init];
    button.frame                    = CGRectMake(0.0, 300, 100, 50);
    button.layer.backgroundColor    = [UIColor orangeColor].CGColor;
    button.cornerRadius             = button.frame.size.height / 2.0;
    button.layer.shadowColor        = [UIColor blackColor].CGColor;
    button.layer.shadowOffset       = CGSizeMake(5, 5);
    button.layer.shadowOpacity      = 1;
    [button setTitle:@"sssss" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button setImage:[UIImage imageNamed:@"3"] forState:UIControlStateNormal] ;
    [button setImage:[UIImage imageNamed:@"5"] forState:UIControlStateHighlighted];
//    NSLog(@"%lf", button.cornerRadius);
    
    appBuild();
    appVersion();
    appBundleID();
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    [WZHttpRequest loadBiYingImageInfo:^(NSString *BiYingCopyright, NSString *BiYingDate, NSString *BiYingDescription, NSString *BiYingTitle, NSString *BiYingSubtitle, NSString *BiYingImg_1366, NSString *BiYingImg_1920, UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
           imageView.image = image;
        });
    }];//异步加载必应墙纸哦
    
    
}




- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
     NSLog(@"%@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
}


- (void)scrollOptions:(WZScrollOptions *)scrollOptions clickedAtIndex:(NSInteger)index {
    NSLog(@"%ld", index);
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    ///下载页面
    [self.navigationController addToSystemSideslipBlacklist:NSStringFromClass([WZDownloadController class])];
//    WZDownloadController *vc = [[WZDownloadController alloc] init];
    WZMediaController *vc = [WZMediaController new];

    [self.navigationController pushViewController:vc animated:true];
    
}

#pragma mark - WZProtocolPageViewController
//控制器角标传出
- (void)pageViewController:(UIPageViewController *)pageViewController showVC:(WZPageViewAssistController *)VC inIndex:(NSInteger)index {
    NSLog(@"vc-%@=======index-%ld", VC, index);
}

@end
