//
//  Demo_ConvertPhotosIntoVideoUseGPUImageViewController.m
//  WZWeather
//
//  Created by admin on 26/2/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "Demo_ConvertPhotosIntoVideoUseGPUImageViewController.h"
#import "WZConvertPhotosIntoVideoTool.h"
#import "WZVideoSurfAlert.h"

@interface Demo_ConvertPhotosIntoVideoUseGPUImageViewController ()
{
    WZConvertPhotosIntoVideoTool *tool;
    NSMutableArray *sources;
}

@property (nonatomic,   weak) UIButton *btnPointer;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@end

@implementation Demo_ConvertPhotosIntoVideoUseGPUImageViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (tool.status == WZConvertPhotosIntoVideoToolStatus_Converting) {
        [tool cancelWriting];
    }
    tool = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tool = [[WZConvertPhotosIntoVideoTool alloc] initWithOutputURL:nil outputSize:CGSizeMake(640, 1136) frameRate:CMTimeMake(1.0, 30.0)];
    tool.delegate = (id<WZConvertPhotosIntoVideoToolProtocol>)self;
    
    sources = [NSMutableArray array];
    for (NSUInteger i = 0; i < 8; i++) {
        UIImage *tmp = [UIImage imageNamed:[NSString stringWithFormat:@"testImage%lu.jpg", (unsigned long)i]];
        [sources addObject:tmp];
    }
    [tool prepareTaskWithPictureSources:sources];
    
    
    //自动设置参数
    NSArray *typeArr = @[@13, @14, @16, @20, @9, @12, @6, @7];
    for (int i = 0; i < typeArr.count; i++) {
        int type = [typeArr[i] intValue];
        _btnPointer = [self.view viewWithTag:i + 100];
        [self actionWithType:type];
    }
    [self startCompose:nil];
}

#pragma mark - WZAnimatePageControlProtocol

//写入完成的回调
- (void)convertPhotosInotViewToolTaskFinished {
    NSLog(@"%s", __func__);
    if ([[NSFileManager defaultManager] fileExistsAtPath:tool.outputURL.path]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WZVideoSurfAlert *alert = [[WZVideoSurfAlert alloc] init];
            alert.asset = [AVAsset assetWithURL:tool.outputURL];
            //            NSArray<AVAssetTrack *> *tracks =  [alert.asset tracksWithMediaType:AVMediaTypeAudio];
            //是没有音轨的
            [alert alertShow];
        });
    }
}

//转换进度
- (void)convertPhotosInotViewTool:(WZConvertPhotosIntoVideoTool *)tool progress:(CGFloat)progress {
    _progressLabel.text = [NSString stringWithFormat:@"当前进度：%lf", progress];
}

#pragma mark Private
- (IBAction)switchEffect:(UIButton *)sender {
    _btnPointer = sender;
    [self configAlert];
}
- (IBAction)startCompose:(id)sender {
    [tool prepareTask];
}

- (void)configAlert {
    UIAlertController *alert = [[UIAlertController alloc] init];
    NSArray <NSDictionary *>*source = [self.class alertSource];
    NSUInteger count = source.count;
    for (NSUInteger i = 0; i < count; i++) {
        if (i == WZConvertPhotosIntoVideoType_Blur
            || i == WZConvertPhotosIntoVideoType_RToL_Blinds_Gradually
            || i == WZConvertPhotosIntoVideoType_TToB_Blinds_Gradually
            || i == WZConvertPhotosIntoVideoType_BToT_Blinds_Gradually
            || i == WZConvertPhotosIntoVideoType_Star
            || i == WZConvertPhotosIntoVideoType_Glow
            ) {continue;}
        NSDictionary *dic = source[i];
        NSString *value = dic[[NSString stringWithFormat:@"%lu", (unsigned long)i]];
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"效果 :  %@", value] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             [self actionWithType:i];
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }];
    [alert addAction:action];
    
    [self.navigationController presentViewController:alert animated:true completion:^{}];
}

- (void)actionWithType:(NSUInteger)type {
    UIButton *sender = _btnPointer;
    NSUInteger index = sender.tag - 100;
     if (tool.transitionNodeMarr.count > index) {
         
         WZConvertPhotosIntoVideoItem *item = tool.transitionNodeMarr[index];
         item.transitionType = (int)type;//类型
         
         NSString *title = [self.class alertSource][type][[NSString stringWithFormat:@"%lu", (unsigned long)type]];
         [sender setTitle:[NSString stringWithFormat:@"效果为 : %@", title] forState:UIControlStateNormal];
         
     } else {
        [sender setTitle:@"_____" forState:UIControlStateNormal];
     }
}

+ (NSArray <NSDictionary *>*)alertSource {
    NSMutableArray *source = NSMutableArray.array;
    NSDictionary *dic = @{@"0" : @"无"};
    [source addObject:dic];
    
    dic = @{@"1" : @"溶解"};
    [source addObject:dic];
    
    dic = @{@"2" : @"黑"};
    [source addObject:dic];
    
    dic = @{@"3" : @"白"};
    [source addObject:dic];
    
    dic = @{@"4" : @"模糊"};
    [source addObject:dic];
    
    dic = @{@"5" : @"抹_左向右"};
    [source addObject:dic];
    
    dic = @{@"6" : @"抹_右向左"};
    [source addObject:dic];
    
    dic = @{@"7" : @"抹_顶向底"};
    [source addObject:dic];
    
    dic = @{@"8" : @"抹_底向顶"};
    [source addObject:dic];
    
    dic = @{@"9" : @"挤压_左向右"};
    [source addObject:dic];
    
    dic = @{@"10" : @"挤压_右向左"};
    [source addObject:dic];
    
    dic = @{@"11" : @"挤压_顶向底"};
    [source addObject:dic];
    
    dic = @{@"12" : @"挤压_底向顶"};
    [source addObject:dic];
    
    dic = @{@"13" : @"翻转"};
    [source addObject:dic];
    
    dic = @{@"14" : @"百叶窗_水平"};
    [source addObject:dic];
    
    dic = @{@"15" : @"百叶窗_垂直"};
    [source addObject:dic];
    
    dic = @{@"16" : @"逐次百叶窗_左向右"};
    [source addObject:dic];
    
    dic = @{@"17" : @"逐次百叶窗_右向左"};
    [source addObject:dic];

    dic = @{@"18" : @"逐次百叶窗_顶向底"};
    [source addObject:dic];

    dic = @{@"19" : @"逐次百叶窗_底向顶"};
    [source addObject:dic];
    
    dic = @{@"20" : @"顺时针"};
    [source addObject:dic];
    
    dic = @{@"21" : @"逆时针"};
    [source addObject:dic];
    
    dic = @{@"22" : @"星形"};
    [source addObject:dic];

    dic = @{@"23" : @"辉光"};
    [source addObject:dic];
    
    return source;
}
@end
