//
//  WZMediaController.m
//  WZWeather
//
//  Created by Wizet on 17/10/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaController.h"
#import "WZMediaPreviewView.h"
#import "WZMediaOperationView.h"

#import <AssetsLibrary/AssetsLibrary.h>




@interface WZMediaController ()<WZMediaPreviewViewProtocol, WZMediaOperationViewProtocol>
{
    BOOL sysetmNavigationBarHiddenState;
}


@property (nonatomic, strong) WZMediaPreviewView *mediaPreviewView;
@property (nonatomic, strong) WZMediaOperationView *mediaOperationView;
///------------------随便搭的UI


@end

@implementation WZMediaController

#pragma mark - ViewController Lifecycle

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (instancetype)init {
    if (self = [super init]) {}
    return self;
}

- (void)loadView {
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.backgroundColor = [UIColor whiteColor];
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
  
    CGFloat y = 0.0;
    if (@available(iOS 11.0, *)) {
        y = self.view.safeAreaInsets.bottom;
        NSLog(@"%@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    } else {
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController) {
        sysetmNavigationBarHiddenState = self.navigationController.navigationBarHidden;
        self.navigationController.navigationBarHidden = true;
    }
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
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = sysetmNavigationBarHiddenState;
    }
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

#pragma mark - WZMediaPreviewViewProtocol


#pragma mark - WZMediaOperationViewProtocol
- (void)operationView:(WZMediaOperationView*)view closeBtnAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:true];
    //清空数据
    [_mediaPreviewView stopCamera];
    
}

- (void)operationView:(WZMediaOperationView*)view pickBtnAction:(UIButton *)sender {
#warning 连拍会产生崩溃
    [_mediaPreviewView pickStillImageWithHandler:^(UIImage *image) {
        if (image) {
            NSLog(@"%@", NSStringFromCGSize(image.size));
        }
    }];
}

///配置类型时间
- (void)operationView:(WZMediaOperationView*)view configType:(WZMediaConfigType)type {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    /*
     WZMediaConfigType_none                  = 0,
     
     WZMediaConfigType_canvas_1_multiply_1   = 11,//W multiply H
     WZMediaConfigType_canvas_3_multiply_4   = 12,
     WZMediaConfigType_canvas_9_multiply_16  = 13,
     
     WZMediaConfigType_flash_auto            = 21,
     WZMediaConfigType_flash_off             = 22,
     WZMediaConfigType_flash_on              = 23,
     
     WZMediaConfigType_countDown_10          = 31,//倒计时
     WZMediaConfigType_countDown_3           = 32,
     WZMediaConfigType_countDown_off         = 33,
     */
    switch (type) {
        case WZMediaConfigType_canvas_1_multiply_1: {
            //                切换到选中效果
            CGFloat targetH = screenW / 1.0 * 1.0;//显示在屏幕的控件高度
            CGFloat rateH = targetH / screenH;
            [_mediaPreviewView setCropValue:rateH];
        } break;
        case WZMediaConfigType_canvas_3_multiply_4: {
            CGFloat targetH = screenW / 3.0 * 4.0;//3 ： 4
            CGFloat rateH = targetH / screenH;
            [_mediaPreviewView setCropValue:rateH];
            
        } break;
        case WZMediaConfigType_canvas_9_multiply_16: {
            [_mediaPreviewView setCropValue:1];
        } break;
        case WZMediaConfigType_flash_auto: {
            [_mediaPreviewView setFlashType:GPUImageCameraFlashType_auto];
        } break;
        case WZMediaConfigType_flash_off: {
            [_mediaPreviewView setFlashType:GPUImageCameraFlashType_off];
        } break;
        case WZMediaConfigType_flash_on: {
            [_mediaPreviewView setFlashType:GPUImageCameraFlashType_on];
        } break;
        case WZMediaConfigType_countDown_10: {
            
        } break;
        case WZMediaConfigType_countDown_3: {
            
        } break;
        case WZMediaConfigType_countDown_off: {
            
        } break;
            
        default:
            break;
    }
}

- (void)operationView:(WZMediaOperationView*)view didSelectedFilter:(GPUImageFilter *)filter {
    
    [_mediaPreviewView insertRenderFilter:filter];
}

#pragma mark - Public Method
- (void)createViews {
    //适配iOS 11
    _mediaPreviewView = [[WZMediaPreviewView alloc] initWithFrame:self.view.bounds];
    _mediaPreviewView.delegate = self;
    [self.view addSubview:_mediaPreviewView];
    [_mediaPreviewView launchCamera];//启动
    
    _mediaOperationView = [[WZMediaOperationView alloc] initWithFrame:_mediaPreviewView.bounds];
    _mediaOperationView.delegate = self;
    [self.view addSubview:_mediaOperationView];
    [_mediaOperationView setSource:_mediaPreviewView.cropFilter];
    
}



@end
