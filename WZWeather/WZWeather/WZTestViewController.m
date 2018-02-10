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
    CADisplayLink *link;
    UIImage *targetImage;
}

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
   
    tool = [[WZConvertPhotosIntoVideoTool alloc] init];
    tool.delegate = (id<WZConvertPhotosIntoVideoToolProtocol>)self;
    tool.outputSize = CGSizeMake(640, 1136);

    NSMutableArray *sources = [NSMutableArray array];
    [tool prepareTask];
//    for (NSUInteger i = 0; i < 8; i++) {
//        UIImage *tmp = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"testImage%lu", i] ofType:@"jpg"]];
//        [sources addObject:tmp];
//        [tool renderWithImage:tmp];
//    }
//    [tool finishWriting];
    
    
//    tool.sources = sources;
//    [tool startRequestingFrames];
    
    
    link = [CADisplayLink displayLinkWithTarget:self selector:@selector(test:)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    link.paused = false;

}


static int count = 0;
static int loop = 0;

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
            } else {
                if (!targetImage) {
                    targetImage = [UIImage imageNamed:[NSString stringWithFormat:@"testImage0.jpg"]];
                }
                [tool renderWithImage:targetImage];
                loop++;
            }
        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

#pragma mark - WZAnimatePageControlProtocol
- (void)pageControl:(WZAnimatePageControl *)pageControl didSelectInIndex:(NSInteger)index; {
    
    NSLog(@"选中 的 index : %ld~~~~currendIndex : %ld", index, [pageControl currentIndex]);
}


#pragma mark - WZConvertPhotosIntoVideoToolProtocol
- (void)convertPhotosInotViewTool:(WZConvertPhotosIntoVideoTool *)tool progress:(CGFloat)progress; {
    NSLog(@"%s", __func__);
}
    

//写入完成的回调
- (void)convertPhotosInotViewToolFinishWriting; {
    NSLog(@"%s", __func__);
    if ([[NSFileManager defaultManager] fileExistsAtPath:tool.outputURL.path]) {
        NSLog(@"111");
        dispatch_async(dispatch_get_main_queue(), ^{
            WZVideoSurfAlert *alert = [[WZVideoSurfAlert alloc] init];
            alert.asset = [AVAsset assetWithURL:tool.outputURL];
            [alert alertShow];
        });
    }
}




@end
