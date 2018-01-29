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

/***
     关于视频录制的时间：参考抖音 15s短视频
 

 ****/
@class WZMediaPreviewView;

@protocol WZMediaPreviewViewProtocol <NSObject>

@optional
///完成了一份视频的录制
- (void)previewView:(WZMediaPreviewView *)view didCompleteTheRecordingWithFileURL:(NSURL *)fileURL;
///录制的时间回调 最后的时间会稍微有点波动，但最后输出的是正确的时间
- (void)previewView:(WZMediaPreviewView *)view audioVideoWriterRecordingCurrentTime:(CMTime)time last:(BOOL)last;

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

//MARK: 段落速率的匹配 用于在视频合成的时候修改视频的速率(scale)
@property (nonatomic, strong) NSMutableArray *timeScaleMArr;
@property (nonatomic, assign) NSUInteger lastTimeScaleType;//记录上一次的类型

//MARK: 录制下来的视频的临时路径
@property (nonatomic, strong, readonly) NSMutableArray *moviesNameMarr;

//MARK: 切换摄影模式(录像、拍照)
- (void)pickMediaType:(WZMediaType)mediaType;
//MARK: 切换闪光灯
- (void)setFlashType:(GPUImageCameraFlashType)type;

//MARK: 开启摄像头
- (void)launchCamera;
//MARK: 暂停摄像头
- (void)pauseCamera;
//MARK: 恢复摄像头
- (void)resumeCamera;
//MARK: 停止摄像头
- (void)stopCamera;

//MARK: 调用startRecord之前的预设   后两个参数如果不设置 默认为crop滤镜的配置
- (void)prepareRecordWithMovieName:(NSString *)movieName outputSize:(CGSize)outputSize trailingOutPut:(GPUImageOutput <GPUImageInput >*)trailingOutput;

//MARK: 之所以录制成为多个文件，是因为需求中有一个需求 删除上可以删除录制过程中某一段自己不满意的视频段落
//MARK: 开始录制
- (void)startRecord;
//- (void)pauseRecord;
//- (void)resumeRecord;
//MARK: 取消录制
- (void)cancelRecord;
//MARK: 结束录制
- (void)endRecord;

//MARK: 插入滤镜
- (void)insertRenderFilter:(GPUImageFilter *)filter;
//MARK: 设置拍摄比例
- (void)setCropValue:(CGFloat)value;
//MARK: 拍照动作
- (void)pickStillImageWithHandler:(void (^)(UIImage *image))handler;

//MARK: 设置焦距
- (void)setZoom:(CGFloat)zoom;
//MARK: 用于计算焦点曝光点
- (CGPoint)calculatePointOfInterestWithPoint:(CGPoint)point;
//MARK: 文件夹路径
- (NSString *)movieFolder;
//MARK: 使用文件名合成路径
- (NSURL *)movieURLWithMovieName:(NSString *)name;

@end
