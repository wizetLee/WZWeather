//
//  WZVideoCodecController.m
//  WZWeather
//
//  Created by admin on 15/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVideoCodecController.h"
#import <GPUImage/GPUImage.h>
#import <Masonry/Masonry.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AudioToolbox/AudioToolbox.h>

@interface WZVideoCodecController ()<GPUImageVideoCameraDelegate>
{
    VTCompressionSessionRef compressionSession;
    NSInteger frameCount;
    NSData *sps;
    NSData *pps;
    FILE *fp;
    BOOL enabledWriteVideoFile;
}
@property (nonatomic, strong) GPUImageVideoCamera *camera;
@property (nonatomic, strong) GPUImageView *previewView;

///编码部分
@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation WZVideoCodecController

- (void)viewDidLoad {
    [super viewDidLoad];
    _camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _previewView = [[GPUImageView alloc] initWithFrame:self.view.bounds];

    [self.view addSubview:_previewView];
    [_previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];

    _camera.delegate = self;
    [_camera addTarget:_previewView];
    
    
    //初始化保存文件
    NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) lastObject] stringByAppendingPathComponent:@"wizetTest.h264"];
    [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    [[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:file];
    [self createVideoToolBox];
    
    //启动相机
    [_camera startCameraCapture];
}

#pragma mark - GPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    //得到buffer
    
    
}

- (void)createVideoToolBox {
    //事前配置
    CGSize videoSize = CGSizeMake(480, 640);
    OSStatus status = VTCompressionSessionCreate(NULL
                                                 , videoSize.width
                                                 , videoSize.height
                                                 , kCMVideoCodecType_H264
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , videoCompressionOutputCallBack
                                                 , (__bridge void *)self//callback
                                                 , &compressionSession);//会话赋值
    if (status != noErr) {
        NSAssert(0, @"配置出错啦");
        return;
    }
    
    ///设置最大关键帧间隔 可设定为fps的2倍
    int frameIntrtval = 10.0;
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval
                         , (__bridge CFTypeRef)@(frameIntrtval));
    // 设置实时编码输出（避免延迟）
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
    
    //指定已编码的比特流的概要和级别。
    VTSessionSetProperty(compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Main_AutoLevel);
    
}


void videoCompressionOutputCallBack() {
    
}

@end
