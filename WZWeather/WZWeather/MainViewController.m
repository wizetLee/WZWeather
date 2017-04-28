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

@property (nonatomic, strong)  CTCallCenter *center;

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
    
//    MKAnnotationView
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
