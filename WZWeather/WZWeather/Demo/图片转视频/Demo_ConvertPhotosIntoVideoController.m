//
//  DemoConvertPhotosIntoVideoController.m
//  WZWeather
//
//  Created by admin on 22/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "Demo_ConvertPhotosIntoVideoController.h"
#import "WZPureConvertPhotosIntoVideoTool.h"
#import "WZVideoSurfAlert.h"

@interface Demo_ConvertPhotosIntoVideoController ()
{
    WZPureConvertPhotosIntoVideoTool *tool;
    CADisplayLink *link;
    UIImage *targetImage;
    int count;
    int loop;
}
@property (weak, nonatomic) IBOutlet UILabel *addedFrameCountLabel;

@end

@implementation Demo_ConvertPhotosIntoVideoController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [tool cancelWriting];
   
    link.paused = true;
    [link invalidate];
    link = nil;
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    count = 0;
    loop = 0;
    
    //生成一个8张图 240帧 帧率为30 8sec的视频（无过渡效果无音轨）
    tool = [[WZPureConvertPhotosIntoVideoTool alloc] initWithOutputURL:nil outputSize:CGSizeMake(640, 1136) frameRate:CMTimeMake(1.0, 30.0)];
    tool.delegate = (id<WZPureConvertPhotosIntoVideoToolProtocol>)self;
//    {//可取消注释看效果
//        tool.timeIsLimited = true;
//        tool.limitedTime = CMTimeMake(5.0 * 600, 600);
//
//    }
    [tool prepareTask];
    [tool startWriting];
    
    link = [CADisplayLink displayLinkWithTarget:self selector:@selector(test:)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    link.paused = false;
    
}

- (void)test:(CADisplayLink *)link {
    if (count >= 8) {
        //结束写入， 终止定时器
        [tool finishWriting];
        link.paused = true;
        [link invalidate];
        loop = 0;
        count = 0;
   
    } else {
        @autoreleasepool {
            if (loop >= 30) {
                count++;
                loop = 0;
                targetImage = [UIImage imageNamed:[NSString stringWithFormat:@"testImage%d.jpg", count]];
                [tool cleanCache];
            } else {
                if (!targetImage) {
                    targetImage = [UIImage imageNamed:[NSString stringWithFormat:@"testImage0.jpg"]];
                }
                if ([tool hasCache]) {
                    [tool addFrameWithCache];
                } else {
                    [tool addFrameWithImage:targetImage];
                }
                loop++;
            }
        }
    }
}

#pragma mark - WZPureConvertPhotosIntoVideoToolProtocol
- (void)pureconvertPhotosInotViewToolTaskFinished {
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
- (void)pureConvertPhotosInotViewTool:(WZPureConvertPhotosIntoVideoTool *)tool addedFrameCount:(NSUInteger)addedFrameCount {
    //主线程
    _addedFrameCountLabel.text = [NSString stringWithFormat:@"已添加%ld帧", addedFrameCount];
}

@end
