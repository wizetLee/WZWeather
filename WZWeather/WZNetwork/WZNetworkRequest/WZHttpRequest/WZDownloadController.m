//
//  WZDownloadController.m
//  WZWeather
//
//  Created by admin on 17/5/18.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZDownloadController.h"
#import "WZDownloadRequest.h"
#import "WZDownloadProgressCell.h"

@interface WZDownloadController()

@property (nonatomic, strong) WZVariousTable *table;
@property (nonatomic, strong) WZDownloadRequest * downloader;

@end

@implementation WZDownloadController

- (void)dealloc {
    NSLog(@"ssssssssssssssssssssssssssssssssssss");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray <NSURL *>* tmpUrlArray = [NSMutableArray arrayWithArray:
                                             @[[NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2017/0512/5915658821e22_wpc.mp4"]
                                               , [NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2017/0510/5912b7078356c_wpc.mp4"],
                                               [NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2017/0510/5912b7078356c_wpc.mp4"],
                                               [NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2017/0510/5912b7078356c_wpc.mp4"],
                                               [NSURL URLWithString:@"http://www.eso.org/public/archives/images/publicationtiff40k/eso1242a.tif"]
                                               , [NSURL URLWithString:@"http://wimg.spriteapp.cn/profile/large/2016/07/26/57974925b34a6_mini.jpg"]
                                               , [NSURL URLWithString:@"http://wimg.spriteapp.cn/profile/large/2016/12/26/586059118dd30_mini.jpg"]
                                               , [NSURL URLWithString:@"http://wimg.spriteapp.cn/profile/large/2017/04/26/5900b375744b2_mini.jpg"]]];
    
//    NSMutableArray <NSURL *>* urlArray = [NSMutableArray arrayWithArray:@[[NSURL URLWithString:@"http://wimg.spriteapp.cn/profile/large/2016/12/26/586059118dd30_mini.jpg"]]];
//    
//    __weak typeof(self) weakSelf = self;
    
    __weak typeof(self) weakSelf = self;
    _downloader = [WZDownloadRequest downloader];
    [_downloader downloadWithURLArray:tmpUrlArray completedWithError:^(NSMutableArray<WZDownloadTarget *> *targets, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error.debugDescription);
            //保存为resumeData
            if ([error.userInfo[NSURLSessionDownloadTaskResumeData] isKindOfClass:[NSData class]]) {
                NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
                for (WZDownloadTarget *target in targets) {
                    target.task = nil;
                    target.resumeData = resumeData;
                }
            }
        } else {
            //修改数据源  更新数据源
            for (WZDownloadTarget *target in targets) {
                [weakSelf.downloader.downloadTargets removeObject:target];
            }
            weakSelf.table.datas = weakSelf.downloader.downloadTargets;
            [weakSelf.table reloadData];
            
            
            UILocalNotification *localNote = [[UILocalNotification alloc] init];
            // 2.设置本地通知的内容
            // 2.1.设置通知发出的时间
            localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:3.0];
            // 2.2.设置通知的内容
            localNote.alertBody = @"在干吗你有一条新通知你有一条新通知你有一条新通知你有一条新通知?";
            // 2.3.设置滑块的文字（锁屏状态下：滑动来“解锁”）
            localNote.alertAction = @"解锁你有一条新通知你有一条新通知你有一条新通知你有一条新通知";
            // 2.4.决定alertAction是否生效
            localNote.hasAction = NO;
            // 2.5.设置点击通知的启动图片
            localNote.alertLaunchImage = @"123Abc";
            // 2.6.设置alertTitle
            localNote.alertTitle = @"你有一条新通知你有一条新通知你有一条新通知你有一条新通知你有一条新通知你有一条新通知你有一条新通知你有一条新通知你有一条新通知你有一条新通知你有一条新通知你有一条新通知";
            // 2.7.设置有通知时的音效
            localNote.soundName = @"buyao.wav";
            // 2.8.设置应用程序图标右上角的数字
            localNote.applicationIconBadgeNumber = 999;
            
            // 2.9.设置额外信息
            localNote.userInfo = @{@"type" : @1};
            
            // 3.调用通知
            [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
            
            
            
            
            
            
        }
    } finishedDownload:^(NSMutableArray<WZDownloadTarget *> *targets, NSURL * _Nullable location) {
      
    } downloadProcess:^(NSMutableArray<WZDownloadTarget *> *targets) {
        
    }];
    [self addSubViews];
}

- (void)addSubViews {
    _table = [[WZVariousTable alloc] initWithFrame:CGRectMake(0.0, 64.0, WZSCREEN_WIDTH, WZSCREEN_HEIGHT - 64.0) style:UITableViewStylePlain];
    [self.view addSubview:_table];
    _table.backgroundColor = [UIColor clearColor];
    _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    _table.variousViewDelegate = (id<WZVariousViewDelegate>)self;
    _table.registerCellDic = [NSMutableDictionary dictionaryWithDictionary:
                              @{NSStringFromClass([WZDownloadProgressCell class]):[WZDownloadProgressCell class]}];
    [self.view addSubview:_table];
    
    NSMutableArray *sectiondDatas = [NSMutableArray array];
    [sectiondDatas addObject:_downloader.downloadTargets];
    if (_downloader.downloadTargets) {
        _table.datas = _downloader.downloadTargets;
        [_table reloadData];
    }
}

- (void)variousView:(UIView *)view param:(NSDictionary *)param {
    if ([param[@"data"] isKindOfClass:[WZDownloadTarget class]]) {
        //暂停 开始
        WZDownloadTarget *data = (WZDownloadTarget *)param[@"data"];
        if (data.cancel) {
            NSLog(@"任务已取消了");
        } else {
            if (data.pause) {
                [data.downloadRequest resumeTaskWithURL:data.url];
            } else {
                [data.downloadRequest suspendTaskWithURL:data.url];
            }
        }
        
        for (WZDownloadTarget *target in _downloader.downloadTargets) {
            if (data != target && [target.url.path isEqualToString:data.url.path]) {
                target.pause = data.pause;
            }
        }
        [self.table reloadData];
    }
}



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

@end


