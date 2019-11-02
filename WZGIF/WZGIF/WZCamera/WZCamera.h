//
//  WZCamera.h
//  WZGIF
//
//  Created by wizet on 2017/7/23.
//  Copyright © 2017年 WZ. All rights reserved.
//
/**
 *  多段视频的合成方案：
        (1)使用moiveFileOutput捕获的若干个文件， 合并成一个
        (2)使用videoDataOutput和audioDataOutput不过buffer写进一个文件中  实时滤镜的使用估计是使用这个方式
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "WZOrientationMonitor.h"
#import "WZCameraProtocol.h" //代理
#import "WZToast.h"//Toast
#import "WZRecordSegment.h"//视频录制的段
#import "WZDisplayLinkSuperviser.h"//计时器
#import "WZMovieWriter.h"//视频写入

#define WZERROR(DOMAIN)   [NSError errorWithDomain:DOMAIN code:-1 userInfo:nil]

/**
 * 录像状态
 */
typedef NS_ENUM(NSUInteger, WZCameraRecordStatus) {
    WZCameraRecordStatusLeisure            = 0,
    WZCameraRecordStatusRecording          = 1,
    WZCameraRecordStatusPause              = 2,
    WZCameraRecordStatusStop = WZCameraRecordStatusLeisure,
    
};

typedef void (^WZCameraRecordingBlock)(NSURL *fileURL, NSError *error);
/**
 *  可以同时拍照和录像
 */
@interface WZCamera : NSObject
//代理
@property (nonatomic, weak) id<WZCameraProtocol> delegate;
//会话
@property (nonatomic, strong) AVCaptureSession *session;
//设备
@property (nonatomic, strong) AVCaptureDevice *currentLensDevice;//默认后置摄像头
@property (nonatomic, strong) AVCaptureDevice *frontLensDevice;
@property (nonatomic, strong) AVCaptureDevice *backLensDevice;
@property (nonatomic, strong) AVCaptureDevice *microphoneDevice;
//输入
@property (strong, nonatomic) AVCaptureDeviceInput *backCameraInput;//后置摄像头输入
@property (strong, nonatomic) AVCaptureDeviceInput *frontCameraInput;//前置摄像头输入
@property (strong, nonatomic) AVCaptureDeviceInput *audioMicInput;//麦克风输入

//输出
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;     //4.0~10.0  1.0后使用photoOutput
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
//@property (nonatomic, strong)  AVCapturePhotoOutput *photoOutput;            //10.0才可用

//连接
@property (strong, nonatomic) AVCaptureConnection *audioConnection;//音频录制连接
@property (strong, nonatomic) AVCaptureConnection *videoConnection;//视频录制连接
@property (strong, nonatomic) AVCaptureConnection *movieFileConnection;//音频录制连接

#pragma mark - UI配置的参数

//预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
//画质预设 default AVCaptureSessionPresetHigh
@property (nonatomic, copy) NSString *sessionPreset;
//录像输出URL
@property (nonatomic, strong) NSURL *recordOutputFileURL;//有默认路径 可自己另外写
//录像的限制时间
@property (nonatomic, assign) CGFloat videoRecordRestrictTime;//录制最长时间 default WZCAMERA_VIDEO_MAX_RECORD_TIME
//录像写入器
@property (nonatomic, strong) WZMovieWriter *movieWriter;
//录像状态
@property (nonatomic, assign) WZCameraRecordStatus recordStatus;

//镜头开启和关闭
- (void)startRunning;
- (void)stopRunning;

//切换闪光灯 PS://还有个自动闪光灯（根据环境光条件自动使用。）
- (BOOL)flashOpen;
- (BOOL)flashClose;
//切换手电筒 PS://还有个自动手电筒（根据环境光条件自动使用。）
- (BOOL)torchOpen;
- (BOOL)torchClose;
//切换镜头
- (BOOL)lensFront;
- (BOOL)lensBack;

//录像
- (void)startRecord;
- (void)pauseRecord;
- (void)resumeRecord;
- (void)stopRecord;
//拍照
- (void)takePhoto:(void (^)(UIImage * image, NSError *error))imageHandler;


//-------------使用系统接口导出视频
//- (BOOL)canRecordingMovieFile;//movieFile是否可用
//- (void)recordMovieFileWithDidStartRecordingBlock:(WZCameraRecordingBlock)didStartRecordingBlock
//                 didFinishRecordingBlock:(WZCameraRecordingBlock)didFinishRecordingBlock; //录像

@end
