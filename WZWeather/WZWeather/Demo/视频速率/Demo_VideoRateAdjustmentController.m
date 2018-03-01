//
//  Demo_VideoRateAdjustmentController.m
//  WZWeather
//
//  Created by 李炜钊 on 2018/2/28.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "Demo_VideoRateAdjustmentController.h"
#import "WZVideoSurfAlert.h"
#import "WZAnimatePageControl.h"
#import "WZVideoRateAdjustmentTool.h"
#import "WZMediaFetcher.h"
@interface Demo_VideoRateAdjustmentController ()
{
    WZVideoRateAdjustmentTool *tool;
}
@end

@implementation Demo_VideoRateAdjustmentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *customDataList = @[@{@"headline" : @"0.25"}
                                , @{@"headline" : @"0.5"}
                                , @{@"headline" : @"1.0"}
                                , @{@"headline" : @"1.5"}
                                , @{@"headline" : @"2.0"}];
    WZAnimatePageControl *page = [WZAnimatePageControl.alloc initWithFrame:
                                  CGRectMake(0.0
                                             , [UIScreen mainScreen].bounds.size.height - 60.0
                                             , [UIScreen mainScreen].bounds.size.width
                                             , 60.0)
                                                           itemContentList:customDataList  itemSize:CGSizeMake(22.0, 22.0)];
    
    page.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 80.0, [UIScreen mainScreen].bounds.size.width, 80.0);
    [self.view addSubview:page];
    [page selectedInIndex:2 withAnimation:false];
    page.delegate = (id<WZAnimatePageControlProtocol>)self;
    
  
}


#pragma mark - WZAnimatePageControlProtocol
- (void)pageControl:(WZAnimatePageControl *)pageControl didSelectInIndex:(NSInteger)index; {
    
    NSLog(@"选中 的 index : %ld~~~~currendIndex : %ld", index, [pageControl currentIndex]);
    double rate = 1.0;
    if (index == 0) {
        rate = 0.25;
    } else if (index == 1) {
        rate = 0.5;
    } else if (index == 3) {
        rate = 1.5;
    } else if (index == 4) {
        rate = 2.0;
    }
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"curnane" ofType:@"mp4"]];
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    //可修改变速范围 和变速速率
    asset = [WZVideoRateAdjustmentTool rateAdjustmentWithAsset:asset rate:rate range:WZCompositionRateAdjustmentRangeMake(0.0, 1.0)];
    WZVideoSurfAlert *alert = [[WZVideoSurfAlert alloc] init];
    alert.asset = asset;
    [alert alertShow];
}


@end
