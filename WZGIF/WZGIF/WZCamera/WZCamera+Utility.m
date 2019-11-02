//
//  WZCamera+Utility.m
//  WZGIF
//
//  Created by admin on 28/7/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZCamera+Utility.h"

@implementation WZCamera (Utility)

#pragma mark - Class Method
#pragma mark - 设备方向转捕捉摄像方向
+ (AVCaptureVideoOrientation)captureVideoOrientationRelyDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        result = AVCaptureVideoOrientationLandscapeRight;
    } else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
        result = AVCaptureVideoOrientationLandscapeLeft;
    }
    return result;
}

#pragma mark - 去除系统声音（添加文件时勾选add to target）
+ (void)removeSystemSound:(BOOL)boolean {
    if (boolean) {
        static SystemSoundID soundID;
        if (soundID == 0) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"photoShutter2" ofType:@"caf"];
            if (path) {
                NSURL *filePath = [NSURL fileURLWithPath:path];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
            } else {
                NSLog(@"去除系统声音路径为空");
            }
        }
        AudioServicesPlaySystemSound(soundID);
    }
}


#pragma mark - 从图片中直接读取二维码 iOS8.0
+ (NSString *)scQRReaderForImage:(UIImage *)qrimage {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:qrimage.CGImage];
    NSArray *features = [detector featuresInImage:image];
    CIQRCodeFeature *feature = [features firstObject];
    NSString *result = feature.messageString;
    return result;
}

+ (UIImage *)dealSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    UIImage *sampleImage = [[self class] imageFromSamplePlanerPixelBuffer:sampleBuffer];
    //    NSLog(@"%@", sampleImage);
    //    sampleImage.imageOrientation =
    sampleImage = [[self class] imageRotatedByDegrees:90 withimage:sampleImage];
    
    return sampleImage;
}

//采样样本缓存

/** <Error>:
 CGBitmapContextCreateImage: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
 Aug  3 11:22:32  WZGIF[549] <Error>: CGBitmapContextCreateImage: invalid context 0x0. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
*/
+ (UIImage *)imageFromSamplePlanerPixelBuffer:(CMSampleBufferRef)sampleBuffer {
    @autoreleasepool {
        //来自stack over flow 的代码
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        //为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        //                CIImage *CII = [CIImage imageWithCVImageBuffer:imageBuffer];
        //        //        UIImage *imageeee = [UIImage imageWithCIImage:CII];
        //                UIImage *imageeee = [UIImage imageWithCIImage:CII scale:1.0 orientation:UIImageOrientationDown];
        //                return imageeee;
        
        // Lock the base address of the pixel buffer
        //加锁访问此资源
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // Get the number of bytes per row for the plane pixel buffer
        //获取pixel buffer 的基地址
        void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        
        // Get the number of bytes per row for the plane pixel buffer
        //得到pixel buffer 的行字节数
        size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
        // Get the pixel buffer width and height
        //得到pixel buffer 的高宽
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        // Create a device-dependent gray color space
        //创建一个依赖于设备的RGB颜色空间 这里一般是,像素空间的编码格式不对.一般平常用到的是BGRA格式,但是Capture设备直接生成的是YUV格式的.所以会出错.
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // Create a bitmap graphics context with the sample buffer data
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                     bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        
        // Create a Quartz image from the pixel data in the bitmap graphics context
        //根据位图context中的像素数据创建一个Quartz image对象
        
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        // Unlock the pixel buffer
        //解锁pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        // Free up the context and color space
        //释放context 和 color space
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        // Create an image object from the Quartz image
        //使用Quartz image创建一个UIImage
        UIImage *image = [UIImage imageWithCGImage:quartzImage];
        
        // Release the Quartz image
        // 释放Quartz image对象
        CGImageRelease(quartzImage);
        
        return (image);
    }
}

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

//外加：水平翻转（未完成）
//旋转图片（顺时针为+）
+ (UIImage *)imageRotatedByDegrees:(CGFloat)degrees withimage:(UIImage*)image
{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    //重新在bitmap上绘制
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


#pragma mark - SCRecorder 视频合成方案样例
+ (AVMutableComposition *)compositionWithSegments:(NSArray <WZRecordSegment *>*)segments  {
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *audioTrack = nil;
    AVMutableCompositionTrack *videoTrack = nil;
    
    int currentSegment = 0;
    CMTime currentTime = composition.duration;
    for (WZRecordSegment *recordSegment in segments) {
        AVAsset *asset = recordSegment.asset;
        
        NSArray *audioAssetTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
        NSArray *videoAssetTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        
        CMTime maxBounds = kCMTimeInvalid;
        
        CMTime videoTime = currentTime;
        for (AVAssetTrack *videoAssetTrack in videoAssetTracks) {
            if (videoTrack == nil) {
                NSArray *videoTracks = [composition tracksWithMediaType:AVMediaTypeVideo];
                
                if (videoTracks.count > 0) {
                    videoTrack = [videoTracks firstObject];
                } else {
                    videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                    videoTrack.preferredTransform = videoAssetTrack.preferredTransform;
                }
            }
            
            videoTime = [[self class] appendTrack:videoAssetTrack toCompositionTrack:videoTrack atTime:videoTime withBounds:maxBounds];
            maxBounds = videoTime;
        }
        
        CMTime audioTime = currentTime;
        for (AVAssetTrack *audioAssetTrack in audioAssetTracks) {
            if (audioTrack == nil) {
                NSArray *audioTracks = [composition tracksWithMediaType:AVMediaTypeAudio];
                
                if (audioTracks.count > 0) {
                    audioTrack = [audioTracks firstObject];
                } else {
                    audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                }
            }
            
            audioTime = [[self class] appendTrack:audioAssetTrack toCompositionTrack:audioTrack atTime:audioTime withBounds:maxBounds];
        }
        
        currentTime = composition.duration;
        currentSegment++;
    }
    
    return composition;
}


+ (CMTime)appendTrack:(AVAssetTrack *)track toCompositionTrack:(AVMutableCompositionTrack *)compositionTrack atTime:(CMTime)time withBounds:(CMTime)bounds {
    CMTimeRange timeRange = track.timeRange;//通道时间轴的所有的时间的范围
    time = CMTimeAdd(time, timeRange.start);
    
    if (CMTIME_IS_VALID(bounds)) {
        CMTime currentBounds = CMTimeAdd(time, timeRange.duration);
        
        if (CMTIME_COMPARE_INLINE(currentBounds, >, bounds)) {
            timeRange = CMTimeRangeMake(timeRange.start, CMTimeSubtract(timeRange.duration, CMTimeSubtract(currentBounds, bounds)));
        }
    }
    
    if (CMTIME_COMPARE_INLINE(timeRange.duration, >, kCMTimeZero)) {
        NSError *error = nil;
        [compositionTrack insertTimeRange:timeRange ofTrack:track atTime:time error:&error];
        
        if (error != nil) {
            NSLog(@"Failed to insert append %@ track: %@", compositionTrack.mediaType, error);
        } else {
            //        NSLog(@"Inserted %@ at %fs (%fs -> %fs)", track.mediaType, CMTimeGetSeconds(time), CMTimeGetSeconds(timeRange.start), CMTimeGetSeconds(timeRange.duration));
        }
        
        return CMTimeAdd(time, timeRange.duration);
    }
    
    return time;
}

#pragma mark - 根据视频产生GIF (控制视频的录制时间、自定义控制GIF的帧数、控制图片的Size)
+ (void)compositionGIFWithVideoURL:(NSURL *)videoURL savedURL:(NSURL *)savedURL handler:(void (^)(NSURL *savedURL, NSError *error))handler {
    __block NSError *error = nil;
    if (![videoURL isKindOfClass:[NSURL class]]
        && ![[NSFileManager defaultManager] fileExistsAtPath:videoURL.path]) {
        error = WZERROR(@"videoURL 出错");
    }
    
    if (![savedURL isKindOfClass:[NSURL class]]) {
        error = WZERROR(@"saveURL 出错");
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:savedURL.path]) {
        [[NSFileManager defaultManager] removeItemAtPath:savedURL.path error:nil];
    }
    
    if (!error) {
        //获取到视频
        AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
        if (![asset isKindOfClass:[AVURLAsset class]]) {
            error = WZERROR(@"资源类型 出错");
        } else {
            //合成GIF （可有：帧间隔的扩展、循环次数的扩展、）
            CGSize videoSize = CGSizeZero;
            if ([asset tracksWithMediaType:AVMediaTypeVideo].count == 0) {
                error = WZERROR(@"视频通道 出错");
            } else {
                
                videoSize = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject.naturalSize;
                //配置采帧的时间
                
                dispatch_group_t gifQueue = dispatch_group_create();//创建group
                
                dispatch_group_enter(gifQueue);//通知group，下面的任务马上要放到group中执行了。
                //处理“异步中的同步任务”
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //optimalSize 控制gif 的 size
                    //                    gifURL = [self createGIFforTimePoints:timePoints fromURL:videoURL fileProperties:fileProperties frameProperties:frameProperties frameCount:frameCount gifSize:optimalSize];
                    //合成gif 的动作
                    
                    
                    //                      playerItem = [AVPlayerItem playerItemWithAsset:composition];
                    
                    //                    error = WZERROR(@"合成出错");
                    dispatch_group_leave(gifQueue);//通知group，任务已完成，任务从group中移除了。
                });
                
                //任务结束后的回调
                dispatch_group_notify(gifQueue, dispatch_get_main_queue(), ^{
                    handler(savedURL, error);
                });
            }
        }
    }
    
    if (error) {
        savedURL = nil;
    }
    handler(savedURL, error);
}

//获取视频第一帧的图片
+ (void)movieFirstFrameWithMoviePath:(NSString *)moviePath  Handler:(void (^)(UIImage *movieImage))handler {
    NSURL *url = [NSURL fileURLWithPath:moviePath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 60);
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    AVAssetImageGeneratorCompletionHandler generatorHandler =
    ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumbImg = [UIImage imageWithCGImage:im];
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(thumbImg);
                });
            }
        }
    };
    [generator generateCGImagesAsynchronouslyForTimes:
     [NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:generatorHandler];
}

#pragma mark - Instance Method

#pragma mark - 根据编码格式返回文件名后缀
- (NSString *)suggestedFileExtensionAccordingEncodingFileType:(NSString *)fileType {
    
    if (fileType == nil) {
        return nil;
    }
    
    if ([fileType isEqualToString:AVFileTypeMPEG4]) {//MP4就是封装格式。而MPEG4是编码格式
        return @"mp4";
    } else if ([fileType isEqualToString:AVFileTypeAppleM4A]) {//M4A是MPEG-4 音频标准的文件的扩展名。在MPEG4标准中提到，普通的MPEG4文件扩展名是“.mp4”。自从Apple开始在它的iTunes以及 iPod中使用“.m4a”以区别MPEG4的视频和音频文件以来，“.m4a”这个扩展名变得流行了。目前，几乎所有支持MPEG4音频的软件都支持“.m4a”。
        return @"m4a";
    } else if ([fileType isEqualToString:AVFileTypeAppleM4V]) {//M4V是一种应用于网络视频点播网站和移动手持设备的视频格式，是MP4格式的一种特殊类型，其后缀常为.MP4或.M4V，其视频编码采用H264，音频编码采用AAC。
        return @"m4v";
    } else if ([fileType isEqualToString:AVFileTypeQuickTimeMovie]) {//MOV即QuickTime影片格式，它是Apple公司开发的一种音频、视频文件格式，用于存储常用数字媒体类型
        return @"mov";
    } else if ([fileType isEqualToString:AVFileTypeWAVE]) {//WAVE是录音时用的标准的WINDOWS文件格式，，数据本身的格式为PCM或压缩型。同时WAVE在英文中又有波浪的意思，而现在在网络上又延伸出一种挥手再见的新的定义。
        return @"wav";
    } else if ([fileType isEqualToString:AVFileTypeMPEGLayer3]) {//MP3是一种音频压缩技术，其全称是动态影像专家压缩标准音频层面3（Moving Picture Experts Group Audio Layer III），简称为MP3。它被设计用来大幅度地降低音频数据量。利用 MPEG Audio Layer 3 的技术，将音乐以1:10 甚至 1:12 的压缩率，压缩成容量较小的文件，而对于大多数用户来说重放的音质与最初的不压缩音频相比没有明显的下降。
        return @"mp3";
    }
    return nil;
}



@end
