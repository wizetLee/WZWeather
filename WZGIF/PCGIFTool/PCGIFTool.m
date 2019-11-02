//
//  PCGIFTool.m
//  WZGIF
//
//  Created by admin on 21/7/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "PCGIFTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation PCGIFItem

- (void)setTargetImage:(UIImage *)targetImage {
    if ([targetImage isKindOfClass:[UIImage class]]) {
        _targetImage = targetImage;
    }
}

- (NSTimeInterval)interval {
    if (fabs(_interval) <= 0.000001) {
        return PCGIFITEM_DEFAULT_INTERVAL;
    } else {
        return _interval;
    }
}

@end

@implementation PCGIFTool

#pragma mark - 创建GIF(按照需要定制)
#warning - Keep GIF‘s Images Size 保持gif的image的尺寸一致
+ (void)createGIFWithURL:(NSURL*)URL items:(NSArray <PCGIFItem *>*)items loopCount:(NSUInteger)loopCount {
    if ([items count] == 0) {
        return;
    }
    
    NSMutableArray <UIImage *>*imageMArr = [NSMutableArray array];
    NSMutableArray <NSNumber *>*intervalMArr = [NSMutableArray array];
    for (PCGIFItem *item in items) {
        if ([item isKindOfClass:[PCGIFItem class]]) {
            if ([item.targetImage isKindOfClass:[UIImage class]]) {
                [imageMArr addObject:item.targetImage];
                [intervalMArr addObject:[NSNumber numberWithDouble:item.interval]];
            }
        }
    }
    
    {//制作GIF
        size_t count = imageMArr.count;
        NSUInteger GIFLoopCount = loopCount;
        
        CGImageDestinationRef distination = [[self class] distinationWithURL:URL count:count loopCount:GIFLoopCount properties:[[self class] filePropertiesWithLoopCount:loopCount]];
        
        if (distination) {
            //取图
            for (int i = 0; i < imageMArr.count; i++) {
                UIImage *image = imageMArr[i];//帧图
                NSTimeInterval delayTime = [intervalMArr[i] doubleValue];//gif帧之间的间隔
                CGImageRef imageRef = image.CGImage;
                if (imageRef) {
                    CGImageDestinationAddImage(distination, imageRef, (__bridge CFDictionaryRef)[[self class] framePropertiesWithDelayTime:delayTime]);
                }
            }
            
            CGImageDestinationFinalize(distination);
            CFRelease(distination);
        }
    }
}

+ (void)createGIFWithURL:(NSURL*)URL images:(NSArray <UIImage *>*)images loopCount:(NSUInteger)loopCount linearInterval:(NSTimeInterval)linearInterval {
    if ([images count] == 0) {
        return;
    }
    
    NSMutableArray <UIImage *>*imageMArr = [NSMutableArray array];
    for (UIImage *image in images) {
        if ([image isKindOfClass:[UIImage class]]) {
            [imageMArr addObject:image];
        }
    }
    
    {//制作GIF
        size_t count = imageMArr.count;
        NSUInteger GIFLoopCount = loopCount;
        
        CGImageDestinationRef distination = [[self class] distinationWithURL:URL count:count loopCount:GIFLoopCount properties:[[self class] filePropertiesWithLoopCount:loopCount]];
        
        if (distination) {
            //取图
            for (int i = 0; i < imageMArr.count; i++) {
                UIImage *image = imageMArr[i];//帧图
                CGImageRef imageRef = image.CGImage;
                if (imageRef) {
                    CGImageDestinationAddImage(distination, imageRef, (__bridge CFDictionaryRef)[[self class] framePropertiesWithDelayTime:linearInterval]);
                }
            }
            CGImageDestinationFinalize(distination);
            CFRelease(distination);
        }
    }
}

//应当提取 文件属性接口
+ (CGImageDestinationRef)distinationWithURL:(NSURL *)URL count:(size_t)count loopCount:(NSUInteger)loopCount properties:(NSDictionary *)properties {
    CGImageDestinationRef distination;
    //类型制定为GIF类型  Note that if `url' already exists, it will be overwritten.
    distination = CGImageDestinationCreateWithURL((__bridge CFURLRef)URL, kUTTypeGIF, count, NULL);
    
    //ImageIO: setProperties:1513: image destination cannot be changed once an image was added
    CGImageDestinationSetProperties(distination, (__bridge CFDictionaryRef)properties);
    return distination;
}

#pragma mark - 拆解GIF 同步操作
/**
 GIF拆解 同步操作

 @param URL GIF文件路径
 @param handler 拆解完成的回调
 */
+ (void)destructGIFWithURL:(NSURL *)URL handler:(void (^)(NSURL *url, NSMutableArray <UIImage *>*frames, NSMutableArray <NSNumber *>*delayTimes, CGFloat totalTime, CGFloat gifWidth, CGFloat gifHeight, NSUInteger loopCount))handler {
    if (![URL isKindOfClass:[NSURL class]]) {
        return;
    }
   
    if (handler) {
        NSMutableArray *frames = [NSMutableArray array];
        NSMutableArray *delayTimes = [NSMutableArray array];
        CGFloat totoalTime;
        CGFloat gifWidth;
        CGFloat gifHeight;
        NSUInteger loopCount;
        getFrameInfo(((__bridge CFURLRef)URL), frames, delayTimes, &totoalTime, &gifWidth, &gifHeight, &loopCount);
        handler(URL, frames, delayTimes, totoalTime, gifWidth, gifHeight, loopCount);
    }
    
}

/**
 GIF拆解接口
 
 @param url gif路径
 @param frames 帧容器：返回帧
 @param delayTimes 帧间隔
 @param totalTime gif动画总时间
 @param gifWidth gif的高
 @param gifHeight gif的宽度
 @param loopCount 循环次数
 */
void getFrameInfo(CFURLRef url, NSMutableArray <UIImage *>*frames, NSMutableArray *delayTimes, CGFloat *totalTime, CGFloat *gifWidth, CGFloat *gifHeight, NSUInteger *loopCount) {
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL(url, NULL);
    
    //帧数
    size_t frameCount = CGImageSourceGetCount(gifSource);
    //获取GIFImage的基本数据
    NSDictionary *gifProperties = (__bridge NSDictionary *) CGImageSourceCopyProperties(gifSource, NULL);
    //由GIFImage的基本数据获取gif数据
    NSDictionary *gifDictionary =[gifProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary];
    //循环次数
    *loopCount = [[gifDictionary objectForKey:(NSString*)kCGImagePropertyGIFLoopCount] integerValue];
    CFRelease((__bridge CFTypeRef)(gifProperties));
    
    for (size_t i = 0; i < frameCount; ++i) {
        //得到每一帧的CGImage
        CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        [frames addObject:[UIImage imageWithCGImage:frame]];
        CGImageRelease(frame);
        
        //帧图片信息
        NSDictionary *frameDict = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL);
        
        //帧图片尺寸
        if (gifWidth != NULL && gifHeight != NULL) {
            *gifWidth = [[frameDict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
            *gifHeight = [[frameDict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
        }
        
        //由每一帧的图片信息获取gif信息
        NSDictionary *gifDict = [frameDict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
        //取出每一帧的delaytime
        [delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
        
        if (totalTime) {
            //帧间隔
            *totalTime = *totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
        }
        CFRelease((__bridge CFTypeRef)(frameDict));
    }
    CFRelease(gifSource);
}

//#pragma mark - 从一段视频中精确地获取若干张图片
//+ (NSArray <UIImage *>*)divideVideoIntoImagesWithURL:(NSURL *)URL imagesCount:(unsigned short int)imagesCount {
//    if (![URL isKindOfClass:[NSURL class]]) {
//        return nil;
//    }
//    AVAsset *asset = [AVAsset assetWithURL:URL];
//    if (![asset isKindOfClass:[AVURLAsset class]]) {
//        return nil;
//    }
//     CGFloat videoLength = (CGFloat)asset.duration.value/asset.duration.timescale;//算得不准确
//    
//    return nil;
//}

#pragma mark - 视频转图片数组  稍微会有点误差(原因 videoLength 经过了四舍五入) PS：：效率低下 不如直接在在buffer中取图片
/**
 视频转化为图片数组  synchronize
 @param URL 资源视频路径
 @param framesPerSecond FPS 帧每秒
 @return 拆解出的图片
 */
+ (NSArray <UIImage *>*)divideVideoIntoImagesWithURL:(NSURL *)URL framesPerSecond:(unsigned short int)framesPerSecond {
    if (![URL isKindOfClass:[NSURL class]]) {
        return nil;
    }
    AVAsset *asset = [AVAsset assetWithURL:URL];
    if (![asset isKindOfClass:[AVURLAsset class]]) {
        return nil;
    }
    
    //通过视频通道获取帧的尺寸
    //    CGSize frameSize = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
    //获取视频的长度
    CGFloat videoLength = (CGFloat)asset.duration.value/asset.duration.timescale;//精度有点问题
    //videoLength 的四舍五入
    if ((videoLength - (int)videoLength) >= 0.5) {
        videoLength = ceil(videoLength);
    } else {
        videoLength = floor(videoLength);
    }
    
    //得到总帧数
    CGFloat frameCount = videoLength * framesPerSecond;
    //获取视频取帧的频率
    CGFloat frequency = videoLength / (frameCount);//+1的原因：浮点偏差
    
    //时间计算
    NSMutableArray *timePoints = [NSMutableArray array];
    for (int i = 0; i < frameCount; ++i) {
        CGFloat seconds = frequency * i;
//        NSLog(@"%lf, %lf",seconds,ceil(videoLength));
        CMTime time = CMTimeMakeWithSeconds(seconds, ceil(videoLength));
        [timePoints addObject:[NSValue valueWithCMTime:time]];
    }
    
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];//视频通道
    generator.appliesPreferredTrackTransform = true;
    
    CMTime tolerance = CMTimeMakeWithSeconds(0.001, ceil(videoLength));
    generator.requestedTimeToleranceBefore = tolerance;
    generator.requestedTimeToleranceAfter = tolerance;
    
    //图片容器
    NSMutableArray <UIImage *>*tmpImages = [NSMutableArray array];
    NSError *error = nil;
    CGImageRef previousImageRefCopy = nil;
    for (NSValue *time in timePoints) {
        CGImageRef imageRef;
        imageRef = [generator copyCGImageAtTime:[time CMTimeValue] actualTime:nil error:&error];
        
        if (error) {
            NSLog(@"复制图片出错：%@", error);
        }
        if (imageRef) {
            CGImageRelease(previousImageRefCopy);
            previousImageRefCopy = CGImageCreateCopy(imageRef);
        } else if (previousImageRefCopy) {
            imageRef = CGImageCreateCopy(previousImageRefCopy);
        } else {
            NSLog(@"复制出错失败了，复制前一帧图片也出错了");
            return nil;
        }
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [tmpImages addObject:image];
        CGImageRelease(imageRef);
    }
    CGImageRelease(previousImageRefCopy);
    
    return tmpImages;
}


#pragma mark - 配置gif文件属性接口
+ (NSDictionary *)filePropertiesWithLoopCount:(NSUInteger)loopCount {
    NSMutableDictionary *gifProperties = [NSMutableDictionary dictionary];
    gifProperties[(NSString*)kCGImagePropertyGIFHasGlobalColorMap] = @(true);//全局颜色列表
//    gifProperties[(NSString*)kCGImagePropertyGIFImageColorMap] = @(true);//
    gifProperties[(NSString*)kCGImagePropertyColorModel] = (NSString*)kCGImagePropertyColorModelRGB;
    gifProperties[(NSString*)kCGImagePropertyDepth] = @(8);
    gifProperties[(NSString*)kCGImagePropertyGIFLoopCount] = @(loopCount);

    NSMutableDictionary *fileProperties = [NSMutableDictionary dictionary];
    fileProperties[(NSString*)kCGImagePropertyGIFDictionary] = gifProperties;
    
    return fileProperties;
}

#pragma mark - 配置gif帧属性接口
+ (NSDictionary *)framePropertiesWithDelayTime:(float)delayTime {
    NSMutableDictionary *gifProperties = [NSMutableDictionary dictionary];
    gifProperties[(NSString *)kCGImagePropertyGIFDelayTime] = @(delayTime);
    
//     const uint8_t colorTable[9] = { 0, 0, 0, 128, 128, 128, 255, 255, 255};
//     NSData* colorTableData = [NSData dataWithBytes: colorTable length:9];
//     gifProperties[(NSString *)kCGImagePropertyGIFImageColorMap] = colorTableData;
    //自定义局部颜色列表的色彩  控制图片的颜色
    // Color tables are arrays of 8-bit bytes from 0 (deepest black) to 255 (brightest white)
    // with each color's intensity grouped in 3's for a total of 9 values.
    // The format is interpreted as hex values.
//    const uint8_t colorTable[9] = { 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF };
    //                            {   White Bytes  }, {   Red Bytes  }, {   Blue Bytes  }
    NSMutableDictionary *frameProperties = [NSMutableDictionary dictionary];
    
    frameProperties[(NSString *)kCGImagePropertyGIFDictionary]  = gifProperties;
    frameProperties[(NSString *)kCGImagePropertyColorModel]  = (NSString *)kCGImagePropertyColorModelRGB;
    
    return frameProperties;
}


#pragma mark - gif保存的名字
+ (NSString *)gifSavePathWithName:(NSString *)name {
    if (![name isKindOfClass:[NSString class]]
        || (name.length == 0)) {
        return nil;
    }
   NSString *savePath =  [self getFilePathWithPath:[self getDocumentPathByAppendingString:@"gif"] byAppendingPathComponent:[NSString stringWithFormat:@"%@.gif", name]];
    
    return savePath;
}

#pragma mark - 文件路径接口
//文件的创建
+ (NSString *)getFilePathWithPath:(NSString *)path byAppendingPathComponent:(NSString *)str {
    if ([path isKindOfClass:[NSString class]]
        && [str isKindOfClass:[NSString class]]
        && path.length
        && str.length) {
        return [path stringByAppendingPathComponent:str];
    }
    return nil;
}

//Documentc创建文件夹 且获取文件夹路径
+ (NSString *)getDocumentPathByAppendingString:(NSString *)aString {
    if ([aString isKindOfClass:[NSString class]] && aString.length) {
        //创建一个文件路径
        NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        NSString *doucmentStr =[document objectAtIndex:0];
        NSString *path = [doucmentStr stringByAppendingPathComponent:aString];//拼接文件夹
        NSError *error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:&error];
        }
        if (error) {
            return nil;
        }
        return path;
    }
    return nil;
}

#pragma mark - 图片裁剪
+ (UIImage *)image:(UIImage*)image ZoomToSize:(CGSize)size {
    if (![image isKindOfClass:[UIImage class]]) {
        return nil;
    }
    
    UIImage *sourceImage = image;
    UIImage *newImage = nil;

    UIGraphicsBeginImageContext(size);

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointZero;
    thumbnailRect.size.width  = size.width;
    thumbnailRect.size.height = size.height;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage ;
}

@end
