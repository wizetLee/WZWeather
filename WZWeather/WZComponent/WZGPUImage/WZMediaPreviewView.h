//
//  WZMediaPreviewView.h
//  WZWeather
//
//  Created by 李炜钊 on 2017/11/4.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GPUImage/GPUImage.h>
#import "WZGPUImagePreinstall.h"
#import "GPUImageVideoCamera+assist.h"

@class WZMediaPreviewView;

@protocol WZMediaPreviewViewProtocol <NSObject>

@optional
- (void)previewView:(WZMediaPreviewView *)view;


@end

@interface WZMediaPreviewView : UIView

@property (nonatomic, weak) id<WZMediaPreviewViewProtocol> delegate;

@property (nonatomic, strong) GPUImageVideoCamera *cameraCurrent;//当前的镜头
@property (nonatomic, assign) WZMediaType mediaType;
@property (nonatomic, strong) GPUImageView *presentView;

- (void)pickMediaType:(WZMediaType)mediaType;
- (void)setFlashType:(GPUImageCameraFlashType)type;

- (void)launchCamera;
- (void)pauseCamera;
- (void)stopCamera;

- (void)setCropValue:(CGFloat)value;
- (void)pickStillImageWithHandler:(void (^)(UIImage *image))handler;



@end
