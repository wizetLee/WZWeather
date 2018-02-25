//
//  WZTestViewController.m
//  WZWeather
//
//  Created by admin on 31/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZTestViewController.h"
#import "WZAnimatePageControl.h"
#import "WZConvertPhotosIntoVideoTool.h"
#import "WZVideoSurfAlert.h"

@interface WZTestViewController ()
{
    WZConvertPhotosIntoVideoTool *tool;
}

@end

@implementation WZTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
//
//    NSString *pathWithComponent = [path stringByAppendingPathComponent:@"myy.mp4"];
//
//    NSURL *outputURL = [NSURL fileURLWithPath:pathWithComponent];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:pathWithComponent]) {
//
//    }
   
    tool = [[WZConvertPhotosIntoVideoTool alloc] initWithOutputURL:nil outputSize:CGSizeMake(640, 1136) frameRate:CMTimeMake(1.0, 30.0)];
    tool.delegate = (id<WZConvertPhotosIntoVideoToolProtocol>)self;

//    tool.timeIsLimited = true;
//    tool.limitedTime = CMTimeMake(5.0 * 600, 600);
    
    NSMutableArray *sources = [NSMutableArray array];

//    [tool testStartWriting];
    
    for (NSUInteger i = 0; i < 8; i++) {
        UIImage *tmp = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"testImage%lu", i] ofType:@"jpg"]];
        [sources addObject:tmp];
//        [tool renderWithImage:tmp];
    }
//    [tool finishWriting];
    
    [tool prepareTaskWithPictureSources:sources];
    [tool prepareTask];
    
//    tool.sources = sources;
//    [tool startRequestingFrames];
    
    
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

#pragma mark - WZAnimatePageControlProtocol

//写入完成的回调
- (void)convertPhotosInotViewToolFinishWriting; {
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


@end
