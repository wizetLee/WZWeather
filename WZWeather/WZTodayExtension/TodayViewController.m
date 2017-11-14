//
//  TodayViewController.m
//  WZTodayExtension
//
//  Created by wizet on 17/4/28.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>


@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setPreferredContentSize:CGSizeMake(1, 300)];
    
    self.view.backgroundColor = [UIColor yellowColor];
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor greenColor];
    [btn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickedBtn:(UIButton *)sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//iOS 10
//- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
//    
//    if(activeDisplayMode == NCWidgetDisplayModeCompact) {
//        
//        // 尺寸只设置高度即可，因为宽度是固定的，设置了也不会有效果
//        
//        self.preferredContentSize = CGSizeMake(0, 110);
//        
//    } else {
//        
//        self.preferredContentSize = CGSizeMake(0, 310);
//        
//    }
//}

#pragma mark NCWidgetProviding
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark 

@end
