//
//  Demo_ShaderTestController.m
//  WZWeather
//
//  Created by 李炜钊 on 2018/3/19.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "Demo_ShaderTestController.h"
#import "WZThermalCameraFilter.h"
#import "WZMultiPassGaussianBlurFilter.h"

@interface Demo_ShaderTestController ()

@end

@implementation Demo_ShaderTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    GPUImageView *present = [[GPUImageView alloc] init];
    present.frame = UIScreen.mainScreen.bounds;
    [self.view addSubview:present];
    UIImage *image = [UIImage imageNamed:@"face"];
    
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    WZThermalCameraFilter *filter = WZThermalCameraFilter.alloc.init;
    filter = WZThermalCameraFilter.alloc.init;
//    WZMultiPassGaussianBlurFilter *blurFilter = WZMultiPassGaussianBlurFilter.alloc.init;
    [pic addTarget:filter];
    [filter addTarget:present];
    
    [filter useNextFrameForImageCapture];
    [pic processImage];
}



@end
