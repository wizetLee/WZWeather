//
//  WZAVPlayerViewController.m
//  WZWeather
//
//  Created by admin on 27/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZAVPlayerViewController.h"
#import "BIVideoEditingClippingView.h"

@interface WZAVPlayerViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *targetItem;
@property (nonatomic, strong) AVPlayerLayer *previewLayer;
@property (nonatomic, strong) UIView *gestureView;

@property (nonatomic, strong) BIVideoEditingClippingView *clipingView;

@end

@implementation WZAVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AVURLAsset *asset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample_clip1" ofType:@"m4v"]]];
    _targetItem = [[AVPlayerItem alloc] initWithAsset:asset1];
    if (!_targetItem) return;
    [self dataConfig];
    [self createViews];
}


- (void)dataConfig {

    
    _player = [[AVPlayer alloc] initWithPlayerItem:_targetItem];
    _previewLayer = [AVPlayerLayer playerLayerWithPlayer:_player] ;
    
}


- (void)createViews {
    CGFloat top = 0.0;
    CGFloat bottom = 0.0;
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
    
    top = MACRO_FLOAT_STSTUSBAR_AND_NAVIGATIONBAR_HEIGHT;
    bottom = MACRO_FLOAT_SAFEAREA_BOTTOM;
    
    CGFloat height = screenH - bottom - top;
    CGSize size = [NSObject wz_fitSizeComparisonWithScreenBound:_targetItem.asset.naturalSize];
    _previewLayer.frame = CGRectMake(0.0, top, size.width, size.height);
    [self.view.layer addSublayer:_previewLayer];
    
    _gestureView =  [[UIView alloc] initWithFrame:_previewLayer.frame];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addSubview:_gestureView];
    _gestureView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    [_gestureView addGestureRecognizer:pan];
    
    

    
    
    
}

- (void)dealloc {
    [_player pause];
    _player = nil;
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    //粒子动画考试啦
    
    
}




@end
