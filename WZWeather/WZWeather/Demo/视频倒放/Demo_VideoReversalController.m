//
//  Demo_VideoReversalController.m
//  WZWeather
//
//  Created by admin on 27/2/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "Demo_VideoReversalController.h"
#import "WZVideoSurfAlert.h"
#import "WZVideoReversalTool.h"

@interface Demo_VideoReversalController () <WZVideoReversalToolProtocol>


@property (nonatomic, strong) WZVideoReversalTool *tool;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation Demo_VideoReversalController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_tool cancelReverseTask];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)playOrigion:(UIButton *)sender {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"05_blackhole" ofType:@"mp4"]];
    AVAsset *asset = [AVAsset assetWithURL:url];
    WZVideoSurfAlert *alert = [[WZVideoSurfAlert alloc] init];
    alert.asset = asset;
    //是没有音轨的
    [alert alertShow];
}
- (IBAction)cancelVideoReversalAction:(UIButton *)sender {
    [_tool cancelReverseTask];
}

- (IBAction)videoReversalAction:(UIButton *)sender {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"05_blackhole" ofType:@"mp4"]];
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    _tool.delegate = nil;
    _tool = nil;
    _tool = [WZVideoReversalTool new];
    _tool.delegate = self;
    [_tool reverseWithAsset:asset];
}

#pragma mark - WZVideoReversalToolProtocol
//进度
- (void)videoReversakTool:(WZVideoReversalTool *)tool reverseProgress:(float)progress; {
    _progressLabel.text = [NSString stringWithFormat:@"%f", progress];
}

//完成
- (void)videoReversakToolReverseSuccessed; {
    WZVideoSurfAlert *alert = [[WZVideoSurfAlert alloc] init];
    alert.asset = [AVAsset assetWithURL:_tool.outputURL];
    //是没有音轨的
    [alert alertShow];
}

//失败
- (void)videoReversakToolReverseFail; {
    NSLog(@"%s", __func__);
}

- (void)videoReversakToolReverseDidCancel; {
    _progressLabel.text = [NSString stringWithFormat:@"已取消合成倒放视频"];
}

@end
