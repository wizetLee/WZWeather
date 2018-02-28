//
//  Demo_VideoRateAdjustmentController.m
//  WZWeather
//
//  Created by 李炜钊 on 2018/2/28.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "Demo_VideoRateAdjustmentController.h"
#import "WZAnimatePageControl.h"

@interface Demo_VideoRateAdjustmentController ()

@end

@implementation Demo_VideoRateAdjustmentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    NSArray *customDataList = @[@{@"headline" : @"0.25"}
                                , @{@"headline" : @"0.5"}
                                , @{@"headline" : @"1.0"}
                                , @{@"headline" : @"1.5"}
                                , @{@"headline" : @"2.0"}];
    WZAnimatePageControl *page = [WZAnimatePageControl.alloc initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 60.0, [UIScreen mainScreen].bounds.size.width, 60.0) itemContentList:customDataList  itemSize:CGSizeMake(22.0, 22.0)];
    
    page.frame = CGRectMake(0.0, 300, [UIScreen mainScreen].bounds.size.width, 80.0);
    [self.view addSubview:page];
    [page selectedInIndex:2 withAnimation:false];
    page.delegate = (id<WZAnimatePageControlProtocol>)self;
}


#pragma mark - WZAnimatePageControlProtocol
- (void)pageControl:(WZAnimatePageControl *)pageControl didSelectInIndex:(NSInteger)index; {
    
    NSLog(@"选中 的 index : %ld~~~~currendIndex : %ld", index, [pageControl currentIndex]);
}


@end
