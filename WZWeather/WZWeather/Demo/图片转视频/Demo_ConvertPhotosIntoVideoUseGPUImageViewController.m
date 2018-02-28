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
}
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
    
    NSMutableArray *sources = [NSMutableArray array];
    for (NSUInteger i = 0; i < 8; i++) {
//        UIImage *tmp = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"testImage%lu", i] ofType:@"jpg"]];
        UIImage *tmp = [UIImage imageNamed:[NSString stringWithFormat:@"testImage%lu.jpg", (unsigned long)i]];
        [sources addObject:tmp];
    }
    
    [tool prepareTaskWithPictureSources:sources];
    [tool prepareTask];
    
}

#pragma mark - WZAnimatePageControlProtocol

//写入完成的回调
- (void)convertPhotosInotViewToolTaskFinished; {
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
- (void)convertPhotosInotViewTool:(WZConvertPhotosIntoVideoTool *)tool progress:(CGFloat)progress; {
    _progressLabel.text = [NSString stringWithFormat:@"当前进度：%lf", progress];
}

@end
