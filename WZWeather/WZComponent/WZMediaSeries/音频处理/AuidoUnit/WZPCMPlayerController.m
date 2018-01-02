//
//  WZPCMPlayerController.m
//  WZWeather
//
//  Created by 李炜钊 on 2017/12/24.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZPCMPlayerController.h"
#import "PCMPlayer.h"

@interface WZPCMPlayerController ()<PCMPlayerProtocol>

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) PCMPlayer *player;

@end

@implementation WZPCMPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
}

- (void)createViews {
    _playButton = [UIButton new];
    _playButton.frame = CGRectMake(0.0, 100.0, 88.0, 44.0);
    [self.view addSubview:_playButton];
    [_playButton addTarget:self action:@selector(clickedAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playButton setTitle:@"播放" forState:UIControlStateNormal];
    [_playButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _playButton.backgroundColor = [UIColor yellowColor];
}

- (void)clickedAction:(UIButton *)sender {
     sender.hidden = true;
    _player = [PCMPlayer new];
    _player.delegate = self;
    [_player play];
}

#pragma mark - PCMPlayerProtocol

- (void)playFinished {
    _playButton.hidden = false;
    _player.delegate = nil;
    _player = nil;
}


@end
