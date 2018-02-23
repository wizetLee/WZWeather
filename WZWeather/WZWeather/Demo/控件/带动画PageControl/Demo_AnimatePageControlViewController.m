//
//  Demo_AnimatePageControlViewController.m
//  WZWeather
//
//  Created by admin on 23/2/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "Demo_AnimatePageControlViewController.h"
#import "WZAnimatePageControl.h"

@interface Demo_AnimatePageControlViewController ()

@end

@implementation Demo_AnimatePageControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *customDataList = @[@{@"headline" : @"1"}, @{@"headline" : @"2"}, @{@"headline" : @"3"}, @{@"headline" : @"4"}];
    WZAnimatePageControl *page = [WZAnimatePageControl.alloc initWithFrame:CGRectMake(0.0, 200, [UIScreen mainScreen].bounds.size.width, 60.0) itemContentList:customDataList  itemSize:CGSizeMake(22.0, 22.0)];
    
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
