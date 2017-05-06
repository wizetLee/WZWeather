//
//  MainViewController.m
//  WZWeather
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "MainViewController.h"
#import <WebKit/WebKit.h>



@protocol abc <NSObject>

@end

@interface MainViewController ()
{
    int iii;
}

@property (nonatomic, strong)  CTCallCenter *center;
@property (nonatomic, strong) NSTimer *timer;


@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.hidden = true;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self textDefine];
    
//    NSLog(@"%@",[UIDevice currentDevice].identifierForVendor);
//    [[UIColor jk_colorWithHex:0x000000] jk_invertedColor];
//    NSLog(@"%@",[UIDevice jk_macAddress]);
    _center  = [[CTCallCenter alloc] init];
//    NSLog(@"%@",[_center description]);
    __weak typeof(self) weakSelf = self;
    _center.callEventHandler = ^(CTCall *call) {
        NSSet<CTCall*> *callSets = weakSelf.center.currentCalls;
        NSLog(@"%@",callSets);
        NSLog(@"call:%@", [call description]);
    };
    
  
    NSTimeInterval aaaa = 0.1;
    NSTimeInterval bbbb = 0.1;
    if (aaaa > bbbb) {
        NSLog(@"a > b");
    } else if (bbbb > aaaa) {
         NSLog(@"b > a");
    }
    
//    _timer  = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(time) userInfo:nil repeats:true];
//    [_timer fire];
//    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
//进行一个大任务
//    for (int i = 0; i < 10000000; i++) {
//        @autoreleasepool {
//            [[UIView alloc] init];
////            NSLog(@"%d", i);
//        }
//    }
}

- (void)time  {
    NSLog(@"_timer_timer_timer:%d",iii);
    iii += 1;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    Class c = NSClassFromString(@"sViewController");
    id v = [[c alloc] init];
    [self.navigationController pushViewController:v animated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
