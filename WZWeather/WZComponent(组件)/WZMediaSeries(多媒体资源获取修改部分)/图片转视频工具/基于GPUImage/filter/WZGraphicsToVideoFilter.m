//
//  WZGraphicsToVideoFilter.m
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZGraphicsToVideoFilter.h"
#import <GLKit/GLKit.h>
#define kMax_Undulated_Count 10
#define kMax_UndulatedCouple_Count ((kMax_Undulated_Count * 2 + 1) * 2)

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


@interface WZGraphicsToVideoFilter()
{
    
    //百叶窗部分
    float undulatedCouple[kMax_UndulatedCouple_Count];
    float undulatedCoupleOrigion[kMax_UndulatedCouple_Count];//原始·存储值
    int undulatedCount;
    int undulatedCoupleCount;
}

@end

@implementation WZGraphicsToVideoFilter

#pragma mark -
#pragma mark Initialization and teardown

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (id)init {
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:@"WZConvertPhotosIntoVideo" ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPathname encoding:NSUTF8StringEncoding error:nil];
    NSString *vertexShaderPathname = [[NSBundle mainBundle] pathForResource:@"WZConvertPhotosIntoVideo" ofType:@"vsh"];
    NSString *vertexShaderString = [NSString stringWithContentsOfFile:vertexShaderPathname encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [self initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString {
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
        filterInputTextureUniform2 = [filterProgram uniformIndex:@"inputImageTexture2"];
        glEnableVertexAttribArray(filterSecondTextureCoordinateAttribute);
        
    });
    [self setBlindsLeavesCount:10];
    
    return self;
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    [filterProgram addAttribute:@"inputTextureCoordinate2"];
#warning 新增属性
    [filterProgram addAttribute:@"position2"];
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

#warning 解决需求：翻转效果、修改顶点的位置
    if (_type == 13 && _progress >= 0.5) {
        //水平翻转
        inputRotation = kGPUImageFlipHorizonal;
    } else {
        //正常水平
        inputRotation = kGPUImageNoRotation;
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
    
    if (![self singleTexture]) {
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, [secondInputFramebuffer texture]);
        glUniform1i(filterInputTextureUniform2, 3);
    }

    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    

//    if (![self singleTexture]) {
#warning 这个坐标可能就要修改一下咯   新增加一个修改坐标的接口啊~~~~~~
        glVertexAttribPointer([filterProgram attributeIndex:@"position2"]
                              , 2               //每个顶点2个数据
                              , GL_FLOAT
                              , 0               //GL_FALSE/*指定当被访问时，固定点数据值是否应该被归一化（GL_TRUE）或者直接转换为固定点值（GL_FALSE）。*/
                              , 0               //指定连续顶点属性之间的偏移量。如果为0，那么顶点属性会被理解为：它们是紧密排列在一起的。初始值为0。
                              
#warning 想要得到旋转，放大缩小等效果，估计就要改顶点坐标的位置了
                              , vertices
                              );
        glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);///可自由配置自定义方向
    
//    }
    glDrawArrays(GL_TRIANGLE_STRIP
                 , 0
                 , 4//一共四个顶点
                 );
    
    [firstInputFramebuffer unlock];
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (![self singleTexture]) {
        [secondInputFramebuffer unlock];
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

//修改顶点坐标啊坐标 和纹理坐标
- (void)calculateTextureCoordinateWithFrame:(CGRect)frame {
    const GLfloat *arr = [[self class] textureCoordinatesForRotation:inputRotation2];
    arr[0];
    arr[1];
    arr[2];
    arr[3];
    arr[4];
    arr[5];
    arr[6];
    arr[7];
}




#pragma mark -
#pragma mark GPUImageInput
//始终按照0~~n的纹理句柄顺序配置
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
    
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if ([self singleTexture]) {
//如果是单通道模式 只更新句柄为0的纹理（也就是所有接收到的buffer都是更新第一个）
//        if (textureIndex == 0)
//        {
            firstInputFramebuffer = newInputFramebuffer;
            hasSetFirstTexture = YES;
            [firstInputFramebuffer lock];
//        }
        return;
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    
    //链的上源更具nextAvailableTextureIndex分配buffer
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
    //通知下一个链节点更新buffer
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if ([self singleTexture]) {
        //如果是单纹理直通，全
        
//            hasReceivedFirstFrame = YES;
            firstFrameTime = frameTime;

//            if (!CMTIME_IS_INDEFINITE(frameTime))//Returns true if the CMTime is indefinite, false if it is not.
//            {
//                if CMTIME_IS_INDEFINITE(secondFrameTime)
//                {
//                    updatedMovieFrameOppositeStillImage = YES;
//                }
//            }
            CMTime passOnFrameTime = firstFrameTime;
            [super newFrameReadyAtTime:passOnFrameTime atIndex:0];//跳转到renderToTextureWithVertices 合并纹理
            hasReceivedFirstFrame = NO;
            hasReceivedSecondFrame = NO;

//        if ((hasReceivedFirstFrame) || updatedMovieFrameOppositeStillImage)
//        {
//            CMTime passOnFrameTime = firstFrameTime;
//            [super newFrameReadyAtTime:passOnFrameTime atIndex:0];
//            hasReceivedFirstFrame = NO;
//            hasReceivedSecondFrame = NO;
//        }

        return;
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    BOOL updatedMovieFrameOppositeStillImage = NO;//感觉不需要这个拦截变量啊~~~
    //双纹理直通
    if (hasReceivedFirstFrame && hasReceivedSecondFrame)//因为这个验证值是在此函数内验证的，如果两个验证值同时为true则说明逻辑出了问题
    {
        return;
    }
    
    
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

#pragma mark - 单双source的切换（根据type）
//根据类型切换单双纹理通道
- (BOOL)singleTexture {
    return (_type == 0 || _type == 2 || _type == 3 || _type == 13 || _type == 24 || _type == 1000 );
}

- (void)setType:(int)type {
    if (_type != type) {
        _type = type;
        [self setInteger:type forUniformName:@"type"];
    }
}



-(void)setProgress:(float)progress {
    _progress = progress;
    [self setFloat:progress forUniformName:@"progress"];
    
    if (_type == 14 || _type == 15) { //百叶窗
        /*
         当时想得太复杂了，其实可以直接使叶子缩小（或则扩大，选择其中之一）就可以了，另外一部分其实根本就不用算
         **/
        
        float coordinateOffset = 1.0 / undulatedCount;
        int odevity = 0;//偶数为扩散 奇数为缩小
        for (int i = 0; i < undulatedCoupleCount; (i = i+2)) {
            if ((odevity % 2) == 0) {
                //扩散
                undulatedCouple[i] = undulatedCoupleOrigion[i] - coordinateOffset * _progress;
                undulatedCouple[i + 1] = undulatedCoupleOrigion[i + 1] + coordinateOffset * _progress;
            } else {
                //缩小
                undulatedCouple[i] = undulatedCoupleOrigion[i] + coordinateOffset * _progress;
                undulatedCouple[i + 1] = undulatedCoupleOrigion[i + 1] - coordinateOffset * _progress;
            }
            odevity++;
        }
        [self setFloatArray:undulatedCouple length:undulatedCoupleCount forUniform:[filterProgram uniformIndex:@"undulatedCouple"] program:filterProgram];
        
    } else if (_type == 16 || _type == 17 || _type == 18 || _type == 19) {
        //权重修改
        float coordinateOffset = 1.0 / undulatedCount;
        int odevity = 0;//偶数为扩散 奇数为缩小
        
        for (int i = 0; i < undulatedCoupleCount; (i = i+2)) {
            // 0 ~ 1.0
            //权重与i相关、达到1.0的顺序不一致
            //i越小 越快到达1.0
            //_progress 使得权重右移
            
            CGFloat weightOffset = (_progress * undulatedCoupleCount);
            CGFloat speed = ((undulatedCoupleCount - ((i + 2.0) - weightOffset) * 1.0) / undulatedCoupleCount);
            speed = pow(speed, 8);
            
            CGFloat tragetProgress = _progress * speed;
            if (tragetProgress < 0) { tragetProgress = 0; }
            if (tragetProgress > 1.0) { tragetProgress = 1.0; }
            
            if ((odevity % 2) == 0) {
                //扩散
                undulatedCouple[i] = undulatedCoupleOrigion[i] - coordinateOffset * tragetProgress;
                undulatedCouple[i + 1] = undulatedCoupleOrigion[i + 1] + coordinateOffset * tragetProgress;
            } else {
                //缩小
                undulatedCouple[i] = undulatedCoupleOrigion[i] + coordinateOffset * tragetProgress;
                undulatedCouple[i + 1] = undulatedCoupleOrigion[i + 1] - coordinateOffset * tragetProgress;
            }
            odevity++;
        }
        [self setFloatArray:undulatedCouple length:undulatedCoupleCount forUniform:[filterProgram uniformIndex:@"undulatedCouple"] program:filterProgram];
        
    } else if (_type == 13) {
        
        CGFloat radians = progress;//0~1.0
        //旋转部分
        GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, radians * M_PI);
        
        //透视部分
        float aspect = 1.0;//contentSize_.width / contentSize_.height;
        GLKMatrix4 perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1, 10.0);
        
        //立体效果(虽然也不是3D)
        GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(0, 0, -1.0);
        GLKMatrix4 result = GLKMatrix4Multiply(translateMatrix, modelViewMatrix);
        result = GLKMatrix4Multiply(perspectiveMatrix, result);
        GPUMatrix4x4 tmp =
        {
            {result.m[0], result.m[1], result.m[2], result.m[3]},
            {result.m[4], result.m[5], result.m[6], result.m[7]},
            {result.m[8], result.m[9], result.m[10], result.m[11]},
            {result.m[12], result.m[13], result.m[14], result.m[15]}
        };
        
        [self setMatrix4f:tmp forUniform:[filterProgram uniformIndex:@"transform"] program:filterProgram];
        
    }
}

//设置叶子数目
- (void)setBlindsLeavesCount:(int)count {
    if (count > kMax_Undulated_Count) {
        count = 10;
    } else if (count < 0) {
        count = 0;
    }
    undulatedCount = count;/////修改叶子的数目  目前为10片叶子
    undulatedCoupleCount = ((undulatedCount * 2 + 1) * 2);
    float coordinateOffset = 1.0 / undulatedCount;
    float coordinateValue = 0.0;
    int odevity = 0;
    for (int i = 0; i < undulatedCoupleCount; (i = i+2)) {
        if (odevity % 2 == 0) {
            undulatedCoupleOrigion[i] = coordinateValue;
            undulatedCoupleOrigion[(i + 1)] = coordinateValue;
        } else {
            undulatedCoupleOrigion[i] = coordinateValue;
            undulatedCoupleOrigion[(i + 1)] = coordinateValue + coordinateOffset;
            coordinateValue = coordinateValue + coordinateOffset;
        }
        odevity++;
    }
    
    odevity = 0;//偶数为扩散 奇数为缩小
    for (int i = 0; i < undulatedCoupleCount; (i = i+2)) {
        if ((odevity % 2) == 0) {
            //扩散
            undulatedCouple[i] = undulatedCoupleOrigion[i] - coordinateOffset * _progress;
            undulatedCouple[i + 1] = undulatedCoupleOrigion[i + 1] + coordinateOffset * _progress;
        } else {
            //缩小
            undulatedCouple[i] = undulatedCoupleOrigion[i] + coordinateOffset * _progress;
            undulatedCouple[i + 1] = undulatedCoupleOrigion[i + 1] - coordinateOffset * _progress;
        }
        odevity++;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        [self setFloat:coordinateOffset forUniformName:@"undulatedCoordinateOffset"];
        [self setInteger:undulatedCount forUniformName:@"undulatedCount"];
        [self setInteger:undulatedCoupleCount forUniformName:@"undulatedCoupleCount"];
        [self setFloatArray:undulatedCouple length:undulatedCoupleCount forUniform:@"undulatedCouple"];
    });
}
@end
