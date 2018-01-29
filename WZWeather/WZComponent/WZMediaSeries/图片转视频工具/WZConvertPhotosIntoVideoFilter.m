//
//  WZConvertPhotosIntoVideoFilter.m
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZConvertPhotosIntoVideoFilter.h"

NSString *const kGPUImageWZConvertPhotosIntoVideoTextureVertexShaderString = SHADER_STRING
(
 attribute vec4 position;                          //顶点坐标相同
 attribute vec4 inputTextureCoordinate;            //纹理坐标
 attribute vec4 inputTextureCoordinate2;           //纹理坐标
 
 varying vec2 textureCoordinate;                   //传递给fsh
 varying vec2 textureCoordinate2;                  //传递给fsh
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     textureCoordinate2 = inputTextureCoordinate2.xy;
 }
 );


@implementation WZConvertPhotosIntoVideoFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [self initWithVertexShaderFromString:kGPUImageWZConvertPhotosIntoVideoTextureVertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    inputRotation2 = kGPUImageNoRotation;
    
    hasSetFirstTexture = NO;
    
    hasReceivedFirstFrame = NO;
    hasReceivedSecondFrame = NO;
    
    firstFrameCheckDisabled = NO;
    secondFrameCheckDisabled = NO;
    
    firstFrameTime = kCMTimeInvalid;
    secondFrameTime = kCMTimeInvalid;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        //句柄关联
        filterSecondTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate2"];
        filterInputTextureUniform2 = [filterProgram uniformIndex:@"inputImageTexture2"]; // This does assume a name of "inputImageTexture2" for second input texture in the fragment shader
        glEnableVertexAttribArray(filterSecondTextureCoordinateAttribute);
    });
    
    return self;
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    [filterProgram addAttribute:@"inputTextureCoordinate2"];
}

- (void)disableFirstFrameCheck;
{
    firstFrameCheckDisabled = YES;
}

- (void)disableSecondFrameCheck;
{
    secondFrameCheckDisabled = YES;
}

#pragma mark -
#pragma mark Rendering

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        [secondInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];   //buffer 增加引用计数
    }
    
    [self setUniformsForProgramAtIndex:0];//枚举uniformStateRestorationBlocks 调用block 完成一些传值操作（setAndExecuteUniformStateCallbackAtIndex）
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [secondInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform2, 3);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);///可自由配置自定义方向
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    [secondInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

#pragma mark -
#pragma mark GPUImageInput

- (NSInteger)nextAvailableTextureIndex;
{
    if (hasSetFirstTexture)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        firstInputFramebuffer = newInputFramebuffer;
        hasSetFirstTexture = YES;
        [firstInputFramebuffer lock];
    }
    else
    {
        secondInputFramebuffer = newInputFramebuffer;
        [secondInputFramebuffer lock];
    }
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        [super setInputSize:newSize atIndex:textureIndex];
        
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetFirstTexture = NO;
        }
    }
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        inputRotation = newInputRotation;
    }
    else
    {
        inputRotation2 = newInputRotation;
    }
}

- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex;
{
    CGSize rotatedSize = sizeToRotate;
    
    GPUImageRotationMode rotationToCheck;
    if (textureIndex == 0)
    {
        rotationToCheck = inputRotation;
    }
    else
    {
        rotationToCheck = inputRotation2;
    }
    
    if (GPUImageRotationSwapsWidthAndHeight(rotationToCheck))
    {
        rotatedSize.width = sizeToRotate.height;
        rotatedSize.height = sizeToRotate.width;
    }
    
    return rotatedSize;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    // You can set up infinite update loops, so this helps to short circuit them
    
//MARK: - 就在之这里修改了
    if (hasReceivedFirstFrame && hasReceivedSecondFrame)//因为这个验证值是在此函数内验证的，如果两个验证值同时为true则说明逻辑出了问题
    {
        return;
    }
    
    BOOL updatedMovieFrameOppositeStillImage = NO;//感觉不需要这个拦截变量啊~~~
    
    if (textureIndex == 0)
    {
        hasReceivedFirstFrame = YES;
        firstFrameTime = frameTime;
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))//Returns true if the CMTime is indefinite, false if it is not.
        {
            if CMTIME_IS_INDEFINITE(secondFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else
    {
        hasReceivedSecondFrame = YES;
        secondFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    
#pragma mark  判断是否传入下一个链的关键 --- 修改处
    // || (hasReceivedFirstFrame && secondFrameCheckDisabled) || (hasReceivedSecondFrame && firstFrameCheckDisabled)
    if ((hasReceivedFirstFrame && hasReceivedSecondFrame) || updatedMovieFrameOppositeStillImage)
    {
        CMTime passOnFrameTime = (!CMTIME_IS_INDEFINITE(firstFrameTime)) ? firstFrameTime : secondFrameTime;
        [super newFrameReadyAtTime:passOnFrameTime atIndex:0]; // Bugfix when trying to record: always use time from first input (unless indefinite, in which case use the second input)
        hasReceivedFirstFrame = NO;
        hasReceivedSecondFrame = NO;
    }
}
@end
