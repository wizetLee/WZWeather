//
//  WZGPUImageMovieWriter.h
//  WZWeather
//
//  Created by wizet on 30/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>

@protocol WZGPUImageMovieWriterProtocol

//结束

//失败

@end

@interface WZGPUImageMovieWriter : NSObject<GPUImageInput>
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


@end
