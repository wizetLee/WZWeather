//
//  WZConvertPhotosIntoVideoFilter.h
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <GPUImage/GPUImage.h>

extern NSString *const kGPUImageWZConvertPhotosIntoVideoTextureVertexShaderString;
@interface WZConvertPhotosIntoVideoFilter : GPUImageFilter
{
    GPUImageFramebuffer *secondInputFramebuffer;
    
    GLint filterSecondTextureCoordinateAttribute;
    GLint filterInputTextureUniform2;
    GPUImageRotationMode inputRotation2;
    CMTime firstFrameTime, secondFrameTime;
    
    BOOL hasSetFirstTexture, hasReceivedFirstFrame, hasReceivedSecondFrame;
    BOOL firstFrameCheckDisabled, secondFrameCheckDisabled;
}

@property (nonatomic, assign) NSUInteger frameRate;//帧率
@property (nonatomic, assign) CMTime curFrameTime;
/*
 if (_frameRate) {
    CMTimeAdd(_curFrameTime, CMTimeMakeWithSeconds(1.0 / _frameRate, 1000));//帧率自增
 }
 */

- (void)disableFirstFrameCheck;     //禁用第一帧检查    有什么用
- (void)disableSecondFrameCheck;    //禁用第二帧检查

@end
