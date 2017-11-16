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
@property (nonatomic, assign) BOOL recording;//正在录制

//内置滤镜 按照链顺序
@property (nonatomic, strong) GPUImageCropFilter *cropFilter;//
@property (nonatomic, strong) GPUImageFilter *scaleFilter;
@property (nonatomic, strong) GPUImageFilter *insertFilter;
@property (nonatomic, strong) GPUImageView *presentView;
/*
     source -> crop -> 选中的滤镜s -> scale -> present
                    -> 选中的滤镜s -> 图片
                    -> 选中的滤镜s -> 视频
 */


@property (nonatomic, strong) NSMutableArray *moviesNameContainer;//存名字   URL为 相对路径+名字


- (void)pickMediaType:(WZMediaType)mediaType;
- (void)setFlashType:(GPUImageCameraFlashType)type;

- (void)launchCamera;
- (void)pauseCamera;
- (void)resumeCamera;
- (void)stopCamera;

// 后两个参数如果不设置 默认为 crop滤镜的配置
- (void)prepareRecordWithMovieName:(NSString *)movieName outputSize:(CGSize)outputSize trailingOutPut:(GPUImageOutput <GPUImageInput >*)trailingOutput;
- (void)startRecord;
- (void)cancelRecord;
- (void)endRecord;

- (void)insertRenderFilter:(GPUImageFilter *)filter;//插入滤镜
- (void)setCropValue:(CGFloat)value;
- (void)pickStillImageWithHandler:(void (^)(UIImage *image))handler;

- (NSString *)movieFolder;

@end
