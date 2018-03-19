//
//  WZGraphicsToVideoFilter.h
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <GPUImage/GPUImage.h>


extern NSString *const kGPUImageWZConvertPhotosIntoVideoTextureVertexShaderString;
@interface WZGraphicsToVideoFilter : GPUImageFilter
{
    GPUImageFramebuffer *secondInputFramebuffer;
    
    GLint filterSecondTextureCoordinateAttribute;
    GLint filterInputTextureUniform2;
    GPUImageRotationMode inputRotation2;
    CMTime firstFrameTime, secondFrameTime;
    
    BOOL hasSetFirstTexture, hasReceivedFirstFrame, hasReceivedSecondFrame;
    BOOL firstFrameCheckDisabled, secondFrameCheckDisabled;
     
}


- (void)disableFirstFrameCheck;     //禁用第一帧
- (void)disableSecondFrameCheck;    //禁用第二帧


//MARK:- custom

//根据type修改纹理的数目
@property (nonatomic, assign) int type; //过渡类型

@property (nonatomic, assign) float progress;//0~1 default:0



@end
