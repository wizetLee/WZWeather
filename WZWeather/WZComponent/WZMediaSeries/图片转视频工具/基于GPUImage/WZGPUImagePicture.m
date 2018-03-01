//
//  WZGPUImagePicture.m
//  WZWeather
//
//  Created by admin on 22/2/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZGPUImagePicture.h"

@interface WZGPUImagePicture()

@end

@implementation WZGPUImagePicture


- (void)setSourceImage:(UIImage *)sourceImage {
    if (![sourceImage isKindOfClass:[UIImage class]]) {
        return;
    }
    
    if (sourceImage.size.width == 0
        || sourceImage.size.height == 0) {
        return;
    }
    
    hasProcessedImage = NO;
    
    if (_sourceImage != sourceImage) {
        _sourceImage = sourceImage;
        
        CGImageRef newImageSource = sourceImage.CGImage;
        //重新创建纹理
       imageUpdateSemaphore = dispatch_semaphore_create(0);//图片更新信号量
       dispatch_semaphore_signal(imageUpdateSemaphore);//  + 1
        
        // TODO: Dispatch this whole thing asynchronously to move image loading off main thread
        CGFloat widthOfImage = CGImageGetWidth(newImageSource);
        CGFloat heightOfImage = CGImageGetHeight(newImageSource);
        
        pixelSizeOfImage = CGSizeMake(widthOfImage, heightOfImage);
        CGSize pixelSizeToUseForTexture = pixelSizeOfImage;
        
        BOOL shouldRedrawUsingCoreGraphics = NO;
        {//检查尺寸是否超出设备最大的纹理尺寸
            CGSize scaledImageSizeToFitOnGPU = [GPUImageContext sizeThatFitsWithinATextureForSize:pixelSizeOfImage];
            if (!CGSizeEqualToSize(scaledImageSizeToFitOnGPU, pixelSizeOfImage))
            {
                pixelSizeOfImage = scaledImageSizeToFitOnGPU;
                pixelSizeToUseForTexture = pixelSizeOfImage;
                shouldRedrawUsingCoreGraphics = YES;
            }
        }
        
        
        if (self.shouldSmoothlyScaleOutput) {
            // In order to use mipmaps, you need to provide power-of-two textures, so convert to the next largest power of two and stretch to fill
            CGFloat powerClosestToWidth = ceil(log2(pixelSizeOfImage.width));
            CGFloat powerClosestToHeight = ceil(log2(pixelSizeOfImage.height));
            
            pixelSizeToUseForTexture = CGSizeMake(pow(2.0, powerClosestToWidth), pow(2.0, powerClosestToHeight));
            shouldRedrawUsingCoreGraphics = YES;
        }
        
        
        GLubyte *imageData = NULL;
        CFDataRef dataFromImageDataProvider = NULL;
        GLenum format = GL_BGRA;
        
        
        //检查图片的内存分布部分（格式检查）
        if (!shouldRedrawUsingCoreGraphics) {
            /* Check that the memory layout is compatible with GL, as we cannot use glPixelStore to
             * tell GL about the memory layout with GLES.
             */
            //检查图片的内存分布 因为不能使用glPixelStore去检查，所以选择其他的接口检查
            if (CGImageGetBytesPerRow(newImageSource) != CGImageGetWidth(newImageSource) * 4 ||
                CGImageGetBitsPerPixel(newImageSource) != 32 ||
                CGImageGetBitsPerComponent(newImageSource) != 8)
            {
                shouldRedrawUsingCoreGraphics = YES;
            } else {
                /* Check that the bitmap pixel format is compatible with GL */
                CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(newImageSource);
                if ((bitmapInfo & kCGBitmapFloatComponents) != 0) {
                    /* We don't support float components for use directly in GL */
                    shouldRedrawUsingCoreGraphics = YES;
                } else {
                    CGBitmapInfo byteOrderInfo = bitmapInfo & kCGBitmapByteOrderMask;
                    if (byteOrderInfo == kCGBitmapByteOrder32Little) {
                        /* Little endian, for alpha-first we can use this bitmap directly in GL */
                        CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
                        if (alphaInfo != kCGImageAlphaPremultipliedFirst && alphaInfo != kCGImageAlphaFirst &&
                            alphaInfo != kCGImageAlphaNoneSkipFirst) {
                            shouldRedrawUsingCoreGraphics = YES;
                        }
                    } else if (byteOrderInfo == kCGBitmapByteOrderDefault || byteOrderInfo == kCGBitmapByteOrder32Big) {
                        /* Big endian, for alpha-last we can use this bitmap directly in GL */
                        CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
                        if (alphaInfo != kCGImageAlphaPremultipliedLast && alphaInfo != kCGImageAlphaLast &&
                            alphaInfo != kCGImageAlphaNoneSkipLast) {
                            shouldRedrawUsingCoreGraphics = YES;
                        } else {
                            /* Can access directly using GL_RGBA pixel format */
                            format = GL_RGBA;
                        }
                    }
                }
            }
        }
        
        
        if (shouldRedrawUsingCoreGraphics) {//重绘
            // For resized or incompatible image: redraw
            imageData = (GLubyte *) calloc(1, (int)pixelSizeToUseForTexture.width * (int)pixelSizeToUseForTexture.height * 4);
            
            CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
            CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)pixelSizeToUseForTexture.width, (size_t)pixelSizeToUseForTexture.height, 8, (size_t)pixelSizeToUseForTexture.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
            //        CGContextSetBlendMode(imageContext, kCGBlendModeCopy); // From Technical Q&A QA1708: http://developer.apple.com/library/ios/#qa/qa1708/_index.html
            CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, pixelSizeToUseForTexture.width, pixelSizeToUseForTexture.height), newImageSource);
            CGContextRelease(imageContext);
            CGColorSpaceRelease(genericRGBColorspace);
        } else {
            // Access the raw image bytes directly
            dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(newImageSource));
            imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
        }
        
        //更新buffer部分
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            
            outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:pixelSizeToUseForTexture onlyTexture:YES];
            [outputFramebuffer disableReferenceCounting];
            
            glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
            if (self.shouldSmoothlyScaleOutput) {
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            }
            // no need to use self.outputTextureOptions here since pictures need this texture formats and type
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)pixelSizeToUseForTexture.width, (int)pixelSizeToUseForTexture.height, 0, format, GL_UNSIGNED_BYTE, imageData);
            
            if (self.shouldSmoothlyScaleOutput)
            {
                glGenerateMipmap(GL_TEXTURE_2D);
                
#warning  什么是mipmap
                /**
                 在三维计算机图形的贴图渲染中有一个常用的技术被称为Mipmapping。
                 为了加快渲染速度和减少图像锯齿，贴图被处理成由一系列被预先计算和优化过的图片组成的文件,这样的贴图被称为 MIP map 或者 mipmap。这个技术在三维游戏中被非常广泛的使用。“MIP”来自于拉丁语 multum in parvo 的首字母，意思是“放置很多东西的小空间”。Mipmap 需要占用一定的内存空间，同时也遵循小波压缩规则 （wavelet compression）。
                 */
                
                
            }
            glBindTexture(GL_TEXTURE_2D, 0);
        });
        
        
        //内存释放
        if (shouldRedrawUsingCoreGraphics) {
            free(imageData);
        } else {
            if (dataFromImageDataProvider) {
                CFRelease(dataFromImageDataProvider);
            }
        }
        
    }
}


- (void)processImageWithTime:(CMTime)time;
{
    [self processImageWithCompletionHandler:nil time:time];
}

- (BOOL)processImageWithCompletionHandler:(void (^)(void))completion time:(CMTime)time;
{
    hasProcessedImage = YES;
    
    //    dispatch_semaphore_wait(imageUpdateSemaphore, DISPATCH_TIME_FOREVER);
    
    if (dispatch_semaphore_wait(imageUpdateSemaphore, DISPATCH_TIME_NOW) != 0)
    {
        return NO;
    }
    
    __block CMTime blockTime = time;
    runAsynchronouslyOnVideoProcessingQueue(^{
        for (id<GPUImageInput> currentTarget in targets)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            [currentTarget setCurrentlyReceivingMonochromeInput:NO];
            [currentTarget setInputSize:pixelSizeOfImage atIndex:textureIndexOfTarget];
            [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
            if (CMTIME_IS_INDEFINITE(time)) { blockTime = kCMTimeIndefinite;}
            [currentTarget newFrameReadyAtTime:blockTime atIndex:textureIndexOfTarget];
        }
        
        dispatch_semaphore_signal(imageUpdateSemaphore);
        
        if (completion != nil) {
            completion();
        }
    });
    
    return YES;
}

@end
