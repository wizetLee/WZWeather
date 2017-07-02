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
#import "A.h"
#import "A+A.h"
#import "UIButton+WZMinistrant.h"

@interface MainViewController ()

@property (nonatomic,strong) WZScrollOptions *menuView;
@property (nonatomic,strong) A *a;
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
    NSMutableArray *tmpArr = [NSMutableArray array];
    for (int i = 0; i <  20; i++) {
        [tmpArr addObject:[NSString stringWithFormat:@"%d", i]];
    }
    WZLoopView *loop = [[WZLoopView alloc] initWithFrame:CGRectMake(0.0, 64.0, MACRO_FLOAT_SCREEN_WIDTH, 100) images:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", ] loop:true delay:2];
    [self.view addSubview:loop];

    
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(0.0, 300, 100, 50);
    button.layer.backgroundColor = [UIColor orangeColor].CGColor;
    [button setTitle:@"sssss" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button setImage:[UIImage imageNamed:@"3"] forState:UIControlStateNormal] ;
    [button setImage:[UIImage imageNamed:@"5"] forState:UIControlStateHighlighted];
    button.cornerRadius = button.frame.size.height / 2.0;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(5, 5);
    button.layer.shadowOpacity = 1;
    NSLog(@"%lf", button.cornerRadius);
    
    _a = [A new];
    _a.string = @"aaaaa";
    [_a addObserver:self forKeyPath:@"string"
            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    // 创建滚动菜单栏
//    self.menuView = [[WZScrollOptions alloc]initWithFrame:CGRectMake(0, 64.0, self.view.width, 30)];
//    [self.view addSubview:self.menuView];
//    self.menuView.scrollOptionsDelegate = (id<WZProtocol_scrollOptions>)self;
//    self.menuView.titleArray = @[@"button0",@"button加长加长版",@"button2",@"button0",@"button加长加长版",@"button2",@"button0",@"button加长加长版",@"button2",@"button0",@"button加长加长版",@"button2",];
//    [self.menuView selectedIndex:200];
//    self.menuView.textFont = [UIFont systemFontOfSize:20];
    dispatch_group_t g = dispatch_group_create();
    dispatch_queue_t q = dispatch_get_main_queue();

    dispatch_group_async(g, q, ^{
        NSLog(@"1");
    });
    dispatch_group_async(g, q, ^{
        NSLog(@"2");
    });
    dispatch_group_async(g, q, ^{
        NSLog(@"3");
//        for (int i = 0; i < 10000; i ++) {
//            NSLog(@"11111");
//        }
    });
    dispatch_group_async(g, q, ^{
        NSLog(@"4");
    });
    dispatch_group_async(g, q, ^{
        NSLog(@"5");
    });
    dispatch_group_async(g, q, ^{
        NSLog(@"6");
    });
    dispatch_group_async(g, q, ^{
        NSLog(@"7");
    });
    dispatch_group_async(g, q, ^{
        NSLog(@"8");
    });
    dispatch_group_async(g, q, ^{
        NSLog(@"9");
    });
//    dispatch_group_notify(g, dispatch_get_main_queue(), ^{
//        NSLog(@"done");
//    });
    long result = dispatch_group_wait(g, dispatch_time(DISPATCH_TIME_NOW, DISPATCH_TIME_FOREVER));
    if (result == 0) {
        NSLog(@"eeeee");
    } else {
        NSLog(@"weijiesu");
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); //- 1
    //逻辑 code
    dispatch_semaphore_signal(semaphore);// +1
    
}




- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@", change);
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
//    WZDownloadController *vc = [[WZDownloadController alloc] init];
//    [self.navigationController pushViewController:vc animated:true];
    _a.string = @"bbbbb";
}

#pragma mark WZProtocol_PageViewController
//控制器角标传出
- (void)pageViewController:(UIPageViewController *)pageViewController showVC:(WZPageViewAssistController *)VC inIndex:(NSInteger)index {
    NSLog(@"vc-%@=======index-%ld", VC, index);
}

@end
