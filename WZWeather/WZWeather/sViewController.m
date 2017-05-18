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
#import "WZDownloadRequest.h"
#import "WZDownloadProgressCell.h"
#import "B1.h"
#import "T1.h"
#import "T2.h"
#import "T3.h"
@interface sViewController ()
@property (nonatomic, strong) WZVariousCollectionView *cv;
@property (nonatomic, strong) WZVariousCollectionReusableContent *c;
@property (nonatomic, strong) WZVariousCollectionSectionsBaseProvider *p;

@property (nonatomic, strong) WZTimeSuperviser *timeSuperviser;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) WZDownloadRequest * downloader;
@property (nonatomic, strong)  NSProgress *progress;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) WZVariousTable *table;

@end

@implementation sViewController

- (void)dealloc {
    NSLog(@"ssssssssssssssssssssssssssssssssssss");
}

- (void)viewDidLoad {
    [super viewDidLoad];

//     http://wimg.spriteapp.cn/profile/large/2016/07/26/57974925b34a6_mini.jpg
//     http://wimg.spriteapp.cn/profile/large/2016/12/26/586059118dd30_mini.jpg
//     http://wimg.spriteapp.cn/profile/large/2017/04/26/5900b375744b2_mini.jpg
//     http://mvideo.spriteapp.cn/video/2017/0510/5912b7078356c_wpc.mp4
//     http://mvideo.spriteapp.cn/video/2017/0513/cf36e7a4-3793-11e7-a69d-1866daeb0df1_wpc.mp4
//     http://mvideo.spriteapp.cn/video/2017/0512/5915658821e22_wpc.mp4
//     http://www.eso.org/public/archives/images/publicationtiff40k/eso1242a.tif
    
    
//    [self sss];
    [self download];
    _table = [[WZVariousTable alloc] initWithFrame:CGRectMake(0.0, 64.0, WZSCREEN_WIDTH, WZSCREEN_HEIGHT - 64.0) style:UITableViewStylePlain];
    [self.view addSubview:_table];
    _table.backgroundColor = [UIColor clearColor];
    _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _table.datas = _downloader.downloadTargets;
    _table.variousViewDelegate = (id<WZVariousViewDelegate>)self;
    _table.registerCellDic = [NSMutableDictionary dictionaryWithDictionary:
                              @{NSStringFromClass([WZDownloadProgressCell class]):[WZDownloadProgressCell class]}];
    [self.view addSubview:_table];
    [_table reloadData];
    

}

- (void)download {
    
//    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
//    [self.view addSubview:_timeLabel];
//    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_btn setFrame:CGRectMake(0, 100, 100, 100)];
//    _btn.backgroundColor = [UIColor orangeColor];
//    [_btn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_btn];
    
    NSMutableArray <NSURL *>* tmpUrlArray = [NSMutableArray arrayWithArray:
                                             @[[NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2017/0512/5915658821e22_wpc.mp4"]
                                               , [NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2017/0510/5912b7078356c_wpc.mp4"]
                                               , [NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2017/0510/5912b7078356c_wpc.mp4"]
                                               , [NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2017/0510/5912b7078356c_wpc.mp4"]
                                               , [NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2017/0510/5912b7078356c_wpc.mp4"]
                                               , [NSURL URLWithString:@"http://wimg.spriteapp.cn/profile/large/2016/07/26/57974925b34a6_mini.jpg"]
                                               , [NSURL URLWithString:@"http://wimg.spriteapp.cn/profile/large/2016/12/26/586059118dd30_mini.jpg"]
                                               , [NSURL URLWithString:@"http://wimg.spriteapp.cn/profile/large/2017/04/26/5900b375744b2_mini.jpg"]]];
    
    NSMutableArray <NSURL *>* urlArray = [NSMutableArray arrayWithArray:@[[NSURL URLWithString:@"http://www.eso.org/public/archives/images/publicationtiff40k/eso1242a.tif"]]];
    
    
    __weak typeof(self) weakSelf = self;
    _downloader = [WZDownloadRequest downloader];
    [_downloader downloadWithURLArray:tmpUrlArray completedWithError:^(NSMutableArray<WZDownloadTarget *> *targets, NSError * _Nullable error) {
//        NSLog(@"%@",error);
        NSLog(@"%@",targets);
    } finishedDownload:^(NSMutableArray<WZDownloadTarget *> *targets, NSURL * _Nullable location) {
        NSLog(@"%@",targets);
    } downloadProcess:^(NSMutableArray<WZDownloadTarget *> *targets) {
         NSLog(@"%@",targets);
    }];
    
    NSMutableArray *sectiondDatas = [NSMutableArray array];
    [sectiondDatas addObject:_downloader.downloadTargets];
//    _cv.sectionsDatas = sectiondDatas;
    
}


- (void)clickedBtn:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        //停止
        [_downloader suspendAllTasks];
    } else {
        //开始
        [_downloader resumeAllTasks];
    }
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

- (void)sss {
    _cv = [WZVariousCollectionView createWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    [self.view addSubview:_cv];
    __weak WZVariousCollectionView * weakSelf = _cv;
    _cv.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf.mj_header endRefreshing];
    }];
    //
    _cv.backgroundColor = [UIColor yellowColor];
    
    _cv.registerCellDic = [NSMutableDictionary dictionaryWithDictionary:
                           @{NSStringFromClass([WZDownloadProgressCell class]):[WZDownloadProgressCell class]}];
    
//    NSMutableArray *mArr = [NSMutableArray array];
//    
//    NSMutableArray *s0 = [NSMutableArray array];
//    [mArr addObject:s0];
//    for (int i = 0 ; i < 111; i++) {
//        B1 *b = [[B1 alloc] init];
//        
//        [s0 addObject:b];
//        NSInteger iii = arc4random() % 4;
//        if (iii == 1) {
//            b.cellType = NSStringFromClass([T1 class]);
//        } else if (iii == 2) {
//            b.cellType = NSStringFromClass([T2 class]);
//        } else if (iii == 3) {
//            b.cellType = NSStringFromClass([NSObject class]);
//        } else {
//            b.cellType = NSStringFromClass([T3 class]);
//        }
//    }
//    [mArr addObject:[NSObject class]];
//    [mArr addObject:[NSObject new]];
    _p = [[WZVariousCollectionSectionsBaseProvider alloc] init];
    UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iiiiii)];
    
    
    _c = [[WZVariousCollectionReusableContent alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _c.backgroundColor = [UIColor redColor];
    [_c addGestureRecognizer:tg];
    _p.headerContent = _c;
    _cv.sectionsProviders = [NSMutableArray arrayWithArray:@[_p,@"sadasd",[NSObject class]]];
//    _cv.sectionsDatas = mArr;
    
    _cv.frame = CGRectMake(_cv.frame.origin.x, _cv.frame.origin.y, _cv.frame.size.width, 0);
}

- (void)iiiiii {
     NSLog(@"111111111");
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
