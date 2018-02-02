//
//  WZTestViewController.m
//  WZWeather
//
//  Created by admin on 31/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZTestViewController.h"
#import "WZAnimatePageControl.h"


@interface WZTestViewController ()


@end

@implementation WZTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = UIColor.whiteColor;
//
//        WZAnimatePageControl *page = [WZAnimatePageControl.alloc initWithFrame:CGRectMake(0.0, 200, [UIScreen mainScreen].bounds.size.width, 60.0)
//                                                 itemContentList: @[@{@"headline": @"1"}
//                                                                    ,@{@"headline": @"2"}
//                                                                    ,@{@"headline": @"3"}
//                                                                    ,@{@"headline": @"4"}
//                                                                    ,@{@"headline": @"5"}
//                                                                    ]
//                                                        itemSize:CGSizeMake(22.0, 22.0)];
//
//        page.frame = CGRectMake(0.0, 300, [UIScreen mainScreen].bounds.size.width, 80.0);
//        [self.view addSubview:page];
//        [page selectedInIndex:2 withAnimation:false];
//         page.delegate = (id<WZAnimatePageControlProtocol>)self;
//
//
//    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
//
//    NSString *pathWithComponent = [path stringByAppendingPathComponent:@"myy.mp4"];
//
//    NSURL *outputURL = [NSURL fileURLWithPath:pathWithComponent];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:pathWithComponent]) {
//
//    }
   
NSUInteger aa = (NSUInteger)(CMTimeGetSeconds(CMTimeMakeWithSeconds(10, 6)) / CMTimeGetSeconds(CMTimeMake(1, 25)));
    NSLog(@"%lu", (unsigned long)aa);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}


- (void)pageControl:(WZAnimatePageControl *)pageControl didSelectInIndex:(NSInteger)index; {
    
    NSLog(@"选中 的 index : %ld~~~~currendIndex : %ld", index, [pageControl currentIndex]);
}




@end
