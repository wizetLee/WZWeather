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
    CTCallCenter *center = [[CTCallCenter alloc] init];
    NSLog(@"%@",[center description]);
    
    center.callEventHandler = ^(CTCall *call) {
        NSLog(@"call:%@", [call description]);
    };
    
}

//- (void)textDefine {
//    NSLog(@"%lf",SCREEN_WIDTH);
//    NSLog(@"%lf",SCREEN_HEIGHT);
//    NSLog(@"%lf",STATUS_BAR_HEIGHT);
//    NSLog(@"%lf",NAVIGATIONBAR_HEIGHT);
//    NSLog(@"%lf",ORIGION_Y_WITH_NAVIGATION);
//    NSLog(@"%lf",ORIGION_Y_WITHOUT_NAVIGATION);
//}

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
