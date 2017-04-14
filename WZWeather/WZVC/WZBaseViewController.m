//
//  WZBaseViewController.m
//  WZWeather
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZBaseViewController.h"

@interface WZBaseViewController ()

@end

@implementation WZBaseViewController

- (instancetype)init {
    if (self = [super init]) {
      
    }
    return self;
}

- (void)dealloc {
    NSLog(@"viewController:%s",__func__);
}

- (void)loadView {
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
