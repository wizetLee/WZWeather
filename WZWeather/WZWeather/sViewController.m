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


@end

@implementation sViewController

- (void)dealloc {
    
    NSLog(@"ssssssssssss");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [WZHttpRequest wz_requestBiYingWallpaperSerializationResult:^(id  _Nullable JSONData, BOOL isDictionaty, BOOL isArray, BOOL mismatching, NSError * _Nullable error) {
//        if (isDictionaty) {
//            NSDictionary *dic = (NSDictionary *)JSONData;
//            NSLog(@"%@", dic);
//        } else {
//            NSLog(@"返回类型不匹配");
//        }
//    }];

    
    
//    [WZHttpRequest wz_requestBaiSiBuDeJieWithType:WZBaiSiBuDeJieType_video title:@"" page:1 SerializationResult:^(id  _Nullable JSONData, BOOL isDictionaty, BOOL isArray, BOOL mismatching, NSError * _Nullable error) {
//        if (isDictionaty) {
//            NSDictionary *dic = (NSDictionary *)JSONData;
//            NSLog(@"%@", dic);
//        } else {
//            NSLog(@"返回类型不匹配");
//        }
//    }];
    
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    
//    [manager POST:@"" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//    }];
    
    
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDownloadDelegate>)self delegateQueue:[NSOperationQueue mainQueue]];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2017/0512/5915658821e22_wpc.mp4"]];
//    
//    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];
//    [task resume];
//    //当前的session 未完成的任务 等待完成再使得session无效  未开始的task 将不会execute
//    [session finishTasksAndInvalidate];
//
//    /*
//     http://wimg.spriteapp.cn/profile/large/2016/07/26/57974925b34a6_mini.jpg
//     http://wimg.spriteapp.cn/profile/large/2016/12/26/586059118dd30_mini.jpg
//     http://wimg.spriteapp.cn/profile/large/2017/04/26/5900b375744b2_mini.jpg
//     http://mvideo.spriteapp.cn/video/2017/0510/5912b7078356c_wpc.mp4
//     http://mvideo.spriteapp.cn/video/2017/0513/cf36e7a4-3793-11e7-a69d-1866daeb0df1_wpc.mp4
//     http://mvideo.spriteapp.cn/video/2017/0512/5915658821e22_wpc.mp4
    
        http://www.eso.org/public/archives/images/publicationtiff40k/eso1242a.tif
//     */
//    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
    [self.view addSubview:_timeLabel];
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btn setFrame:CGRectMake(0, 100, 100, 100)];
    _btn.backgroundColor = [UIColor orangeColor];
    [_btn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn];
    //检查文件是否已经存在
   
    NSMutableArray <NSURL *>* tmpUrlArray = [NSMutableArray arrayWithArray:
  @[[NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2017/0512/5915658821e22_wpc.mp4"]
    , [NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2017/0510/5912b7078356c_wpc.mp4"]
    , [NSURL URLWithString:@"http://wimg.spriteapp.cn/profile/large/2016/07/26/57974925b34a6_mini.jpg"]
    , [NSURL URLWithString:@"http://wimg.spriteapp.cn/profile/large/2016/12/26/586059118dd30_mini.jpg"]
    , [NSURL URLWithString:@"http://wimg.spriteapp.cn/profile/large/2017/04/26/5900b375744b2_mini.jpg"]]];
    
    NSMutableArray <NSURL *>* urlArray = [NSMutableArray arrayWithArray:@[[NSURL URLWithString:@"http://www.eso.org/public/archives/images/publicationtiff40k/eso1242a.tif"]]];
    
//    for (NSURL * url in tmpUrlArray) {
//        if (wz_fileExistsAtPath(wz_filePath(WZSearchPathDirectoryTemporary, url.lastPathComponent))) {
//            [urlArray removeObject:url];
//        }
//    }
    
    __weak typeof(self) weakSelf = self;
    _downloader = [WZDownloadRequest downloader];
    [_downloader downloadWithURLArray:urlArray completedWithError:^(NSURLSessionTask * _Nullable task, NSURL * _Nullable url, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error.debugDescription);
        }
    } finishedDownload:^(NSURLSessionTask * _Nullable task, NSURL * _Nullable url, NSURL * _Nullable location) {

      /*
       //文件路径迁移 并且重命名文件
       NSError * fileManagerError;
       if ([[NSFileManager defaultManager] moveItemAtPath:location.path toPath:wz_filePath(WZSearchPathDirectoryTemporary, url.lastPathComponent) error:&fileManagerError]) {
       } else {
       NSLog(@"fileManagerError:%@", fileManagerError);
       }
       if (fileManagerError) {
       //[[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDownloadTaskDidFailToMoveFileNotification object:downloadTask userInfo:fileManagerError.userInfo];
       //文件迁移失败措施
       }
       */
    } downloadProcess:^(NSURLSessionDownloadTask * _Nullable downloadTask, NSURL * _Nullable url, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
//        if ([url.path isEqualToString:[urlArray[0] path]]) {
//            weakSelf.timeLabel.text = [NSString stringWithFormat:@"%lf", totalBytesWritten / 1000.0];
//
//            NSLog(@"11111111111");
//        } else if ([downloadTask.currentRequest.URL.path isEqualToString:[urlArray[1] path]]) {
//            NSLog(@"22222222222");
//        } else if ([downloadTask.currentRequest.URL.path isEqualToString:[urlArray[2] path]]) {
//            NSLog(@"33333333333");
//        } else {
//            NSLog(@"else");
//        }
        
    NSLog(@" bytesWritten: %lf\
                          \n totalBytesWritten :%lf \
                          \n totalBytesExpectedToWrite:%lf"
                          ,bytesWritten / 1000.0
                          , totalBytesWritten  / 1000.0
                          ,totalBytesExpectedToWrite / 1000.0);
        weakSelf.timeLabel.text = [NSString stringWithFormat:@"%lf", totalBytesWritten / 1000.0];
    }];
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
