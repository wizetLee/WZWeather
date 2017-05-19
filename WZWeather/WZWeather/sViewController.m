//
//  sViewController.m
//  WZWeather
//
//  Created by wizet on 17/4/14.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "sViewController.h"
#import "WZVariousCollectionView.h"
#import "WZDisplayLinkSuperviser.h"
#import "WZGCDTimeSuperviser.h"
#import "WZDownloadRequest.h"
#import "WZDownloadProgressCell.h"
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

@property (nonatomic, strong) WZVariousTable *table;

@end

@implementation sViewController

#pragma mark - ViewController Lifecycle

- (instancetype)init {
    if (self = [super init]) {}
    return self;
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
}

@end
