//
//  sViewController.m
//  WZWeather
//
//  Created by admin on 17/4/14.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "sViewController.h"
#import "WZVariousCollectionView.h"

#import "B1.h"
#import "T1.h"
#import "T2.h"
#import "T3.h"
@interface sViewController ()
@property (nonatomic, strong) WZVariousCollectionView *cv;
@property (nonatomic, strong) WZVariousCollectionReusableContent *c;
@property (nonatomic, strong) WZVariousCollectionSectionsBaseProvider *p;
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
    
    _p.headerData = @"1";
    _c = [[WZVariousCollectionReusableContent alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _c.backgroundColor = [UIColor redColor];
    [_c addGestureRecognizer:tg];
    _p.headerContent = _c;
    
    _cv.sectionsProviders = [NSMutableArray arrayWithArray:@[_p,@"sadasd",[NSObject class]]];
    _cv.sectionsDatas = mArr;
}


- (void)iiiiii {
    _p.headerData = @"111";
   
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
