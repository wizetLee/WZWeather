//
//  sViewController.m
//  WZWeather
//
//  Created by admin on 17/4/14.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "sViewController.h"
#import "WZVariousCollectionView.h"
#import "WZDisplayLinkSuperviser.h"
#import "WZGCDTimeSuperviser.h"

#import "B1.h"
#import "T1.h"
#import "T2.h"
#import "T3.h"
@interface sViewController ()
@property (nonatomic, strong) WZVariousCollectionView *cv;
@property (nonatomic, strong) WZVariousCollectionReusableContent *c;
@property (nonatomic, strong) WZVariousCollectionSectionsBaseProvider *p;


@property (nonatomic, strong)  WZTimeSuperviser *timeSuperviser;
@end

@implementation sViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cv = [WZVariousCollectionView staticInitWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    [self.view addSubview:_cv];
    __weak WZVariousCollectionView * weakSelf = _cv;
    _cv.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
         [weakSelf.mj_header endRefreshing];
    }];
//
    _cv.backgroundColor = [UIColor yellowColor];
    
    _cv.registerCellDic = [NSMutableDictionary dictionaryWithDictionary:
                           @{NSStringFromClass([T1 class]):[T1 class]
                             ,NSStringFromClass([T2 class]):[T2 class]
                             ,NSStringFromClass([T3 class]):[T3 class]
                             ,NSStringFromClass([NSObject class]):[NSObject class]}];
    
    NSMutableArray *mArr = [NSMutableArray array];
    
    NSMutableArray *s0 = [NSMutableArray array];
    [mArr addObject:s0];
    for (int i = 0 ; i < 111; i++) {
        B1 *b = [[B1 alloc] init];
        
        [s0 addObject:b];
        NSInteger iii = arc4random() % 4;
        if (iii == 1) {
            b.cellType = NSStringFromClass([T1 class]);
        } else if (iii == 2) {
            b.cellType = NSStringFromClass([T2 class]);
        } else if (iii == 3) {
            b.cellType = NSStringFromClass([NSObject class]);
        } else {
            b.cellType = NSStringFromClass([T3 class]);
        }
    }
    [mArr addObject:[NSObject class]];
    [mArr addObject:[NSObject new]];
    _p = [[WZVariousCollectionSectionsBaseProvider alloc] init];
    UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iiiiii)];
    

    _c = [[WZVariousCollectionReusableContent alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _c.backgroundColor = [UIColor redColor];
    [_c addGestureRecognizer:tg];
    _p.headerContent = _c;
    
    _cv.sectionsProviders = [NSMutableArray arrayWithArray:@[_p,@"sadasd",[NSObject class]]];
    _cv.sectionsDatas = mArr;

    _timeSuperviser = [[WZDisplayLinkSuperviser alloc] init];
    _timeSuperviser.delegate = (id<WZTimeSuperviserDelegate>)self;
    _timeSuperviser.terminalTime = 10.0;
    _timeSuperviser.interval = 1;
    
    [_timeSuperviser timeSuperviserFire];
    
    _cv.frame = CGRectMake(_cv.frame.origin.x, _cv.frame.origin.y, _cv.frame.size.width, 0);
    
    
    //进行一个大任务
//        for (int i = 0; i < 1000; i++) {
//            @autoreleasepool {
//                [[UIView alloc] init];
//                NSLog(@"%d", i);
//            }
//        }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_timeSuperviser) {
        [_timeSuperviser timeSuperviserFire];
    }
}

- (void)timeSuperviser:(WZTimeSuperviser *)timeSuperviser currentTime:(NSTimeInterval)currentTime {
    NSLog(@"currentTime:%lf,interval:%lf", currentTime,[NSDate date].timeIntervalSince1970);
    if (fabs(currentTime - 5.0) < 0.00001) {
        [timeSuperviser timeSuperviserPause];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //需要回到主线程对处理UI
        _cv.frame = CGRectMake(_cv.frame.origin.x, _cv.frame.origin.y, _cv.frame.size.width, currentTime);
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)iiiiii {
    _p.headerData = @"111";
   
}


- (void)dealloc {
    NSLog(@"%s", __func__);
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
