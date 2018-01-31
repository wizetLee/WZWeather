#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImageContext.h"

extern NSString *const kGPUImageColorSwizzlingFragmentShaderString;

@protocol GPUImageMovieWriterDelegate <NSObject>

@optional
- (void)movieRecordingCompleted;
- (void)movieRecordingFailedWithError:(NSError*)error;

@end

@interface GPUImageMovieWriter : NSObject <GPUImageInput>
{
    BOOL alreadyFinishedRecording;
    
    NSURL *movieURL;
    NSString *fileType;
	AVAssetWriter *assetWriter;
	AVAssetWriterInput *assetWriterAudioInput;
	AVAssetWriterInput *assetWriterVideoInput;
    AVAssetWriterInputPixelBufferAdaptor *assetWriterPixelBufferInput;   //提供一个CVPixelBufferPool，这个池可分配像素缓冲区
    
    GPUImageContext *_movieWriterContext;           //上下文
    CVPixelBufferRef renderTarget;                  //渲染目标
    CVOpenGLESTextureRef renderTexture;             //渲染纹理

    CGSize videoSize;                               //输出的视频的尺寸
    GPUImageRotationMode inputRotation;             //方向
}

@property(readwrite, nonatomic) BOOL hasAudioTrack;                             //音轨
@property(readwrite, nonatomic) BOOL shouldPassthroughAudio;                    //是否使用直通流（也就是不修改音频的格式等配置）
@property(readwrite, nonatomic) BOOL shouldInvalidateAudioSampleWhenDone;       //完成时使音频无效
@property(nonatomic, copy) void(^completionBlock)(void);                        //录制完成的回调
@property(nonatomic, copy) void(^failureBlock)(NSError*);                       //录制失败的回调
@property(nonatomic, assign) id<GPUImageMovieWriterDelegate> delegate;
@property(readwrite, nonatomic) BOOL encodingLiveVideo;                         //实时的视频编码
@property(nonatomic, copy) BOOL(^videoInputReadyCallback)(void);                //
@property(nonatomic, copy) BOOL(^audioInputReadyCallback)(void);                //
@property(nonatomic, copy) void(^audioProcessingCallback)(SInt16 **samplesRef, CMItemCount numSamplesInBuffer);                                                        //处理回调
@property(nonatomic) BOOL enabled;                                              //是否接通链 ，由链上方
@property(nonatomic, readonly) AVAssetWriter *assetWriter;                      //writer
@property(nonatomic, readonly) CMTime duration;                                 //读取持续时间
@property(nonatomic, assign) CGAffineTransform transform;                       //设置方向
@property(nonatomic, copy) NSArray *metaData;                                   //元数据(AVMetadataItem)
@property(nonatomic, assign, getter = isPaused) BOOL paused;                    //是否暂停（使线程睡眠）
@property(nonatomic, retain) GPUImageContext *movieWriterContext;               //上下文

// Initialization and teardown
- (id)initWithMovieURL:(NSURL *)newMovieURL size:(CGSize)newSize;
- (id)initWithMovieURL:(NSURL *)newMovieURL size:(CGSize)newSize fileType:(NSString *)newFileType outputSettings:(NSDictionary *)outputSettings;

- (void)setHasAudioTrack:(BOOL)hasAudioTrack audioSettings:(NSDictionary *)audioOutputSettings;

// Movie recording
- (void)startRecording;
- (void)startRecordingInOrientation:(CGAffineTransform)orientationTransform;
- (void)finishRecording;
- (void)finishRecordingWithCompletionHandler:(void (^)(void))handler;
- (void)cancelRecording;
- (void)processAudioBuffer:(CMSampleBufferRef)audioBuffer;
- (void)enableSynchronizationCallbacks;

@end
