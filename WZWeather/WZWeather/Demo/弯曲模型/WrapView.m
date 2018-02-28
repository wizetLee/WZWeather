//
//  WrapView.m
//  WarpDemo
//
//  Created by admin on 31/10/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "WrapView.h"
#import "GLProgram.h"
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>


///背景图片
#define backgroundImageName @"trees-2920264.jpg"
///混合素材
#define wrapImageName @"lightCross.png"

#define Column (1000)
#define SizeOfVectorTextureCoordinate (Column * 2/*position :x, y*/ * 2/*texture: x, y*/ * 2/*两个点*/ + 4*2)
#define SizeOfIndices  (Column * 3/*位置*/ * 2/*个数*/)

@interface WrapView ()

{
    float new_arrBuffer[SizeOfVectorTextureCoordinate];//顶点坐标值
    int new_indices[SizeOfIndices];//索引值
    CGFloat targetY;//计算非线性方程极大值的依据   0~1
    CGFloat targetX;//计算非线性方程极大值的依据   0~1
    CGFloat incrementX;//计算偏移程度的依据
    CGFloat lastLocationX;
    
    BOOL updating;
    
    int _renderType;
}

@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, strong) GLProgram *programNormal;
@property (nonatomic, strong) GLProgram *programWrap;

@property (nonatomic, assign) GLuint displayRenderbuffer;           //图片的渲染缓存
@property (nonatomic, assign) GLuint displayFramebuffer;            //图片的帧缓存

@property (nonatomic, assign) GLuint outputFrameBuffer;             //需要渲染的目标帧缓存
@property (nonatomic, assign) GLuint outputFrameBufferTexture;      //需要渲染的目标纹理句柄

@property (nonatomic, assign) GLuint sourceImageTexture0;           //渲染图片的纹理句柄
@property (nonatomic, assign) GLuint sourceImageTexture1;           //渲染图片的纹理句柄

@property (nonatomic, assign) CGSize bgPixelSize;                   //最终得到的多图片合成的尺寸
@property (nonatomic, assign) CGSize wrapPixelSize;                 //放置在帧缓存的图片的尺寸

///最终导出的结果
@property (nonatomic, assign) GLuint mixFrameBuffer;                //混合后的目标帧缓存
@property (nonatomic, assign) GLuint mixFrameBufferTexture;         //混合后的目标纹理句柄


///输出图片的VBO
@property (nonatomic, assign) GLuint VBO2;
///显示图片的VBO
@property (nonatomic, assign) GLuint VBO0;
///变化的VBO
@property (nonatomic, assign) GLuint VBO1;
///变化的VBO 索引
@property (nonatomic, assign) GLuint index1;


@end

@implementation WrapView

#pragma mark -
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bgPixelSize = [UIImage imageNamed:backgroundImageName].size;
        _wrapPixelSize = [UIImage imageNamed:wrapImageName].size;           //与视口有关联
        CGSize size = [self fitSizeComparisonWithScreenBound:_bgPixelSize];
        
        self.frame = CGRectMake(0.0, 0.0, size.width, size.height);
        [self wzGLprelude];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self render];
}

- (void)dealloc {
    glDeleteBuffers(1, &_VBO1);
    glDeleteBuffers(1, &_VBO0);
    glDeleteBuffers(1, &_VBO2);
    
    glDeleteFramebuffers(1, &_outputFrameBuffer);
    glDeleteFramebuffers(1, &_displayFramebuffer);
    
    glDeleteTextures(1, &_sourceImageTexture1);
    glDeleteTextures(1, &_outputFrameBufferTexture);
    glDeleteTextures(1, &_sourceImageTexture0);
}



#pragma mark - Private  需要单独配置

- (void)wzGLprelude {
    [self setupLayer];
    [self setupContext];
    [self setupPrograms];
    
    [self destroyFramebuffer:&_outputFrameBuffer];
    [self destroyFramebuffer:&_displayFramebuffer];
    [self destroyFramebuffer:&_mixFrameBuffer];
    [self destroyRenderbuffer:&_displayRenderbuffer];
    
    { //关联渲染缓存到帧缓存
        [self setupRenderbuffer:&_displayRenderbuffer];
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
        [self setupFramebuffer:&_displayFramebuffer];
        
        glBindFramebuffer(GL_FRAMEBUFFER, _displayFramebuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _displayRenderbuffer);
    }
#warning 注意targetSize需要与设备支持尺寸对比修改
    {//关联纹理句柄到帧缓存中
        [self setupFramebuffer:&_outputFrameBuffer];
        CGSize targetSize = CGSizeMake(_wrapPixelSize.width, _wrapPixelSize.height);
        targetSize = [self compareWithEquipmentSupportWithSize:targetSize];
        _outputFrameBufferTexture = [[self class] createTexture2DWithWidth:targetSize.width height:targetSize.height data:NULL];
        
        glBindFramebuffer(GL_FRAMEBUFFER, _outputFrameBuffer);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _outputFrameBufferTexture, 0);
    }

    {//关联纹理句柄到帧缓存中
        [self setupFramebuffer:&_mixFrameBuffer];
        CGSize targetSize = CGSizeMake(_bgPixelSize.width, _bgPixelSize.height);
        targetSize = [self compareWithEquipmentSupportWithSize:targetSize];
        _mixFrameBufferTexture = [[self class] createTexture2DWithWidth:targetSize.width height:targetSize.height data:NULL];
        
        glBindFramebuffer(GL_FRAMEBUFFER, _mixFrameBuffer);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _mixFrameBufferTexture, 0);
    }
    
    [self normalData];
    [self setupVBO0];
    [self setupVBO1];
    [self setupVBO2];
    
    [self renderTextureWithImageName:wrapImageName texture:&_sourceImageTexture0];//把图片绘制到某个纹理当中
    [self renderTextureWithImageName:backgroundImageName texture:&_sourceImageTexture1];//把图片绘制到某个纹理当中
}

- (void)setupVBO1 {
	glGenBuffers(1, &_VBO1);
    glGenBuffers(1, &_index1);
}

- (void)setupVBO0 {
    CGFloat scale = 1.0;
    GLfloat attrArr[] =
    {
        1.0 * scale, 1.0 * scale, 0,     1.0, 0.0,
        1.0 * scale, -1.0 * scale, 0,     1.0, 1.0,
        -1.0 * scale, -1.0 * scale, 0,    0.0, 1.0,
        -1.0 * scale, -1.0 * scale, 0,    0.0, 1.0,
        -1.0 * scale, 1.0 * scale, 0,     0.0, 0.0,
        1.0 * scale, 1.0 * scale, 0,     1.0, 0.0,
    };
    glGenBuffers(1, &_VBO0);
    glBindBuffer(GL_ARRAY_BUFFER, _VBO0);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
}

- (void)setupVBO2 {
    CGFloat scale = 1.0;
    GLfloat attrArr[] =
    {
        1.0 * scale, -1.0 * scale, 0,     1.0, 0.0,
        1.0 * scale, 1.0 * scale, 0,     1.0, 1.0,
        -1.0 * scale, 1.0 * scale, 0,    0.0, 1.0,
        -1.0 * scale, 1.0 * scale, 0,    0.0, 1.0,
        -1.0 * scale, -1.0 * scale, 0,     0.0, 0.0,
        1.0 * scale, -1.0 * scale, 0,     1.0, 0.0,
    };
    glGenBuffers(1, &_VBO2);
    glBindBuffer(GL_ARRAY_BUFFER, _VBO2);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
}

///把纹理贴图绑定到参数纹理当中
- (void)renderTextureWithImageName:(NSString*)fileName texture:(GLuint *)texture {
    // 1获取图片的CGImageRef
    UIImage *image = [UIImage imageNamed:fileName];
    
    {//部分图片的方向需要修改 判断条件为
        if (image.size.width - CGImageGetWidth(image.CGImage) == 0) {
        } else {
            NSAssert(false, @"CGImage图片改变了 需要修改");
        }
    }
    CGImageRef spriteImage = image.CGImage;
    
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    GLubyte *spriteData;
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    //尺寸校验
    CGSize finalSize = [self compareWithEquipmentSupportWithSize:CGSizeMake(width, height)];
    width = finalSize.width;
    height = finalSize.height;
    
    spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte
   
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);

    glEnable(GL_TEXTURE_2D);
    if (glIsTexture(*texture)) {
        
    } else {
        glGenTextures(1, texture);
    }
    glBindTexture(GL_TEXTURE_2D, *texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    //该格式决定颜色和深度的存储值
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
}

- (void)setupPrograms {
    //背景 与 normal合并
    NSArray *attributeStrs = @[@"position", @"textureCoordinate", @"secondTextureCoordinate"];
    _programNormal = [[GLProgram alloc] initWithVertexShaderFilename:@"shaderColourModulationV" fragmentShaderFilename:@"shaderColourModulationF"];
    [self setupProgram:_programNormal attributeArray:attributeStrs];
    
    //扭曲
    _programWrap = [[GLProgram alloc] initWithVertexShaderFilename:@"shaderDefaultV" fragmentShaderFilename:@"shaderDefaultF"];
    attributeStrs = @[@"position", @"textureCoordinate"];//改变这里的position就行了
    [self setupProgram:_programWrap attributeArray:attributeStrs];
}

- (void)render {
    NSArray *attributeStrs = @[@"position", @"textureCoordinate"];
    
    {//帧缓存中
        [_programWrap use];
        glBindFramebuffer(GL_FRAMEBUFFER, _outputFrameBuffer);
        [self clearColor];
#warning - 这个视口配置非常关键...
        CGSize pixelSize = _wrapPixelSize;
        pixelSize = [self compareWithEquipmentSupportWithSize:pixelSize];
        glViewport(0.0, 0.0, pixelSize.width, pixelSize.height);
        
        glBindBuffer(GL_ARRAY_BUFFER, _VBO1);
        glVertexAttribPointer([_programWrap attributeIndex:@"position"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, NULL);
        glVertexAttribPointer([_programWrap attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (float *)NULL + 2);
        
        [self enableAttribute:_programWrap attributeArray:attributeStrs];
        
        //将纹理绑定到帧缓存中
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, _sourceImageTexture0);
        //配置着色器采样器值
        glUniform1i([_programWrap uniformIndex:@"imageTexture"], 2);
        
        ///数据的重新修改绑定以及绘制到帧缓存中
        [self dataChangeAndDraw];
    }
#warning 修改混合类型：因为有些效果是不能放出来的，因此只暴露一种类型在FSH中..
    _renderType = 26;//混合类型
    {//渲染在屏幕当中，
        [_programNormal use];
        glBindFramebuffer(GL_FRAMEBUFFER, _displayFramebuffer);
        [self clearColor];
        [self viewPort];
        glBindBuffer(GL_ARRAY_BUFFER, _VBO0);
        
        attributeStrs = @[@"position", @"textureCoordinate", @"secondTextureCoordinate"];
        glVertexAttribPointer([_programNormal attributeIndex:@"position"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
        
        //在GPUImage中不另外创建VBO，而是直接配置数据的优点：可以方便地匹配 第一第二纹理的纹理坐标
        glVertexAttribPointer([_programNormal attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
        ////修改second的坐标
        glVertexAttribPointer([_programNormal attributeIndex:@"secondTextureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
        [self enableAttribute:_programNormal attributeArray:attributeStrs];
        
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, _outputFrameBufferTexture);
        glUniform1i([_programNormal uniformIndex:@"sourceImage"], 3);
        
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, _sourceImageTexture1);
        glUniform1i([_programNormal uniformIndex:@"secondSourceImage"], 4);
        
        glUniform1f([_programNormal uniformIndex:@"alpha"], 1.0);
        glUniform1i([_programNormal uniformIndex:@"blendType"], _renderType);
        
        //绘制
        glDrawArrays(GL_TRIANGLES, 0, 6);
        //渲染
        [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
}

#pragma mark - Public
- (UIImage *)material {
    {//需要渲染的帧缓存的图片
        glBindFramebuffer(GL_FRAMEBUFFER, _outputFrameBuffer);
        CGSize pixelSize = [UIImage imageNamed:wrapImageName].size;
        pixelSize = [self compareWithEquipmentSupportWithSize:pixelSize];
        CGImageRef imageRef = [self newCGImageFromFramebufferContentsWithTargetImageSize:pixelSize];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        NSLog(@"%@", NSStringFromCGSize(image.size));
        return image;
    }
}

- (UIImage *)mixture {
    {//输出帧缓存 导出最后的图片
        [_programNormal use];
        glBindFramebuffer(GL_FRAMEBUFFER, _mixFrameBuffer);
        [self clearColor];
        
        CGSize pixelSize = _bgPixelSize;
        pixelSize = [self compareWithEquipmentSupportWithSize:pixelSize];
        glViewport(0.0, 0.0, pixelSize.width, pixelSize.height);
        //显示在屏幕上的坐标 与 输出的坐标 Y轴相反
        glBindBuffer(GL_ARRAY_BUFFER, _VBO2);
            NSArray *attributeStrs = @[@"position", @"textureCoordinate", @"secondTextureCoordinate"];
        glVertexAttribPointer([_programNormal attributeIndex:@"position"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
        
        glVertexAttribPointer([_programNormal attributeIndex:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
        glVertexAttribPointer([_programNormal attributeIndex:@"secondTextureCoordinate"], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
        [self enableAttribute:_programNormal attributeArray:attributeStrs];
        
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, _outputFrameBufferTexture);
        glUniform1i([_programNormal uniformIndex:@"sourceImage"], 3);
        
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, _sourceImageTexture1);
        glUniform1i([_programNormal uniformIndex:@"secondSourceImage"], 4);
        
        glUniform1f([_programNormal uniformIndex:@"alpha"], 1.0);
        glUniform1i([_programNormal uniformIndex:@"blendType"], _renderType);
        //绘制
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
    
    {//输出缓存的图片
        glBindFramebuffer(GL_FRAMEBUFFER, _mixFrameBuffer);
        CGSize pixelSize = _bgPixelSize;
        pixelSize = [self compareWithEquipmentSupportWithSize:pixelSize];
        CGImageRef imageRef = [self newCGImageFromFramebufferContentsWithTargetImageSize:pixelSize];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        NSLog(@"%@", NSStringFromCGSize(image.size));
        return image;
    }
}
#pragma mark - 数据计算部分
//数据初始化
- (void)normalData {
    targetY = 0.0;
    incrementX = 0.0;
    updating = false;
    lastLocationX = 0.0;
    
    {
        int tmpIndex = 0;
        int stride = 4;//只保存顶点坐标xy 纹理坐标xy
        CGFloat yfloat = (Column * 1.0);
        CGFloat multiple = 2.0;
        float *arr = (float *)new_arrBuffer;
        ///顶点坐标 纹理坐标
        for (int j = 0; j < Column + 1; j++) {
            for (int i = 0; i < 2; i++) {//2个点为顶点坐标 另外两个点为纹理坐标
                CGFloat positionX = i;
                CGFloat positionY =  j / yfloat;
                
                CGFloat textureX = i;
                CGFloat textureY = j / yfloat;
                
                arr[tmpIndex + 0] = positionX * multiple - 1.0;
                arr[tmpIndex + 1] = positionY * multiple - 1.0;
                
                arr[tmpIndex + 2] = textureX;
                //                arr[tmpIndex + 3] = 1.0 - textureY;//textureY; //纹理坐标跟position坐标Y翻转
                arr[tmpIndex + 3] = textureY;//不用翻转了 上一个zhuo'se'q
                tmpIndex += stride;
            }
        }
        stride = 6;
        tmpIndex = 0;
        ///索引
        for (int i = 0; i < Column; i++) {
            new_indices[tmpIndex + 0] = 1 + i*2;
            new_indices[tmpIndex + 1] = 3 + i*2;
            new_indices[tmpIndex + 2] = 2 + i*2;
            new_indices[tmpIndex + 3] = 2 + i*2;
            new_indices[tmpIndex + 4] = 0 + i*2;
            new_indices[tmpIndex + 5] = 1 + i*2;
            tmpIndex += stride;
        }
    }
    [self gestures];
}

- (void)gestures {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}

///平移手势
- (void)pan:(UIPanGestureRecognizer *)pan {
    if (updating) { return;}
    updating = true;
    ///区分方向
    if (pan.state == UIGestureRecognizerStateBegan) {
        lastLocationX = [pan translationInView:pan.view].x;//拾获最初的角标
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat result = [pan translationInView:pan.view].x - lastLocationX;//方向判别
        //        NSLog(@"%lf", result);
        lastLocationX = [pan translationInView:pan.view].x;//更新位置
        
        //        CGFloat restrictValue = 11.0;
        //        if (result > restrictValue) {
        //            result = restrictValue;
        //        } else if (result < -restrictValue) {
        //            result = -restrictValue;
        //        }
        //
        incrementX = result / pan.view.bounds.size.width;
        /**
         translation.x < 0    向左
         translation.y < 0    向上
         **/
        CGPoint curPoint = [pan locationInView:pan.view];
        targetY = curPoint.y / self.bounds.size.height;//iOS 设备坐标下的0~1.0
        targetX = curPoint.x / self.bounds.size.width;//
        //数据范围
        if (targetY < 0) {targetY = 0.0;}
        if (targetY > 1) {targetY = 1.0;}
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
    }
    if (incrementX != 0.0) {
        [self render];
    }
    
    updating = false;
}

///手势驱动的时候顶点数据的更改
- (void)dataChangeAndDraw {
    {//--------------point : 计算偏移量
        //        CGFloat tmpTargetY = 1.0 - targetY;//取反得到纹理坐标系中的点
        CGFloat tmpTargetY = targetY;
        ///手势对坐标的压缩量
        float xCompreess = 0.0;
        //计算偏移值
        int tmpIndex = 0;
        int stride = 4;//只保存顶点坐标xy 纹理坐标xy
        for (int j = 0; j < Column + 1; j++) {
            //            for (int i = 0; i < 2; i++) {//2个点为顶点坐标 另外两个点为纹理坐标
            //将[0.0, 1.0]区间映射到[-PI, PI]区间上
            xCompreess = j / (Column * 1.0);//0~1.0
            xCompreess = xCompreess * 2 * M_PI ;//0~2PI
            xCompreess = xCompreess - M_PI;//-PI~PI
            
            CGFloat tmpY = tmpTargetY;
            tmpY = tmpY * 2 * M_PI;//映射到[-PI, PI]区间上
            tmpY = tmpY - M_PI;
            
            //作差 得到 图形偏移
            //NSLog(@"图形偏移~%f", cos(xCompreess - tmpY) + 1);
            
            CGFloat degree = xCompreess - tmpY;
            if (degree > M_PI) {
                degree = M_PI;
            } else if (degree < -M_PI) {
                degree = -M_PI;
            }
            
            //                CGFloat tmpComPress = sqrt((cos(degree) + 1)) * incrementX;
            CGFloat tmpComPress =  (pow((cos(degree)), 1) + 1) * incrementX;//更加尖锐
            //
            new_arrBuffer[tmpIndex + 0] = new_arrBuffer[tmpIndex + 0] + tmpComPress;//只修改X坐标  根据j代入相应的非线性方程中 得到偏移量
            tmpIndex += stride;//另一个方向
            new_arrBuffer[tmpIndex + 0] = new_arrBuffer[tmpIndex + 0] + tmpComPress;//只修改X坐标  根据j代入相应的非线性方程中 得到偏移量
            tmpIndex += stride;
            //            }
        }
    }
    
    ///打印数据
    //        for(int i = 0 ; i < SizeOfVectorTextureCoordinate ; i++) {if (i % 4 == 0) {printf("\n"); }
    //            printf("%f ", new_arrBuffer[i]);
    //        }//    printf("\n--------------\n");
    //        for(int i = 0 ; i < Column * 3/*位置*/ * 2/*个数*/ ; i++) {if (i % 3 == 0) { printf("\n"); }
    //            printf("%d ", new_indices[i]);
    //        }printf("\n--------------\n");
    
    //修改VBO PS：倒不如直接赋值到pointer处理 分开两个数组分别处理屏幕坐标和纹理坐标
    glBindBuffer(GL_ARRAY_BUFFER, _VBO1);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * (SizeOfVectorTextureCoordinate) , new_arrBuffer, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _index1);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLint)*SizeOfIndices, new_indices, GL_STATIC_DRAW);
    glDrawElements(GL_TRIANGLES, SizeOfIndices, GL_UNSIGNED_INT, 0);//索引绘制
    
}
#pragma mark - 固定的函数  不必检查
//设备尺寸校验
- (CGSize)compareWithEquipmentSupportWithSize:(CGSize)targetSize {
    
    GLint maxTextureSize = 0;//6S 4096
    CGFloat width = targetSize.width;
    CGFloat height = targetSize.height;
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);//捕获到最大小纹理的size
    BOOL needRedraw = false;
    if (maxTextureSize < width || maxTextureSize < height) {
        needRedraw = true;
    }
    if (needRedraw) {
        CGFloat tmpW = 0.0;
        CGFloat tmpH = 0.0;
        if (width > height) {
            tmpW = maxTextureSize;
            tmpH = height / (width / tmpW);
        } else if (width == height) {
            tmpW = maxTextureSize;
            tmpH = maxTextureSize;
        } else {
            tmpH = maxTextureSize;
            tmpW = width / (height / tmpH);
        }
        width = tmpW;
        height = tmpH;
    }
    return CGSizeMake(width, height);
}


- (void)clearColor {
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
}

///更改图片尺寸
+ (UIImage *)image:(UIImage*)image byScalingToSize:(CGSize)targetSize {
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointZero;
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = targetSize.height;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage ;
}

//启用数组内的顶点属性
- (void)enableAttribute:(GLProgram *)program attributeArray:(NSArray <NSString *>*)attributeArray {
    if ([attributeArray count]) {
        for (NSString *attributeName in attributeArray) {
            glEnableVertexAttribArray([program attributeIndex:attributeName]);
        }
    }
}

- (void)setupLayer {
    self.eaglLayer = (CAEAGLLayer *)self.layer;
    self.eaglLayer.opaque = true;
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    self.eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithBool:false], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
}

///着色器属性绑定 以及 gl程序的链接
- (void)setupProgram:(GLProgram *)program attributeArray:(NSArray <NSString *>*)attributeArray {
    
    if ([attributeArray count]) {
        for (NSString *attributeName in attributeArray) {
            [program addAttribute:attributeName];
        }
    }
    
    if (!program.initialized)
    {
        if (![program link]) {
            NSString *progLog = [program programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [program fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [program vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            program = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
}

- (void)destroyFramebuffer:(GLuint *)framebufferHandle {
    glDeleteFramebuffers(1, framebufferHandle);
    *framebufferHandle = 0;
}
- (void)destroyRenderbuffer:(GLuint *)renderbufferHandle {
    glDeleteRenderbuffers(1, renderbufferHandle);
    *renderbufferHandle = 0;
}

- (void)setupFramebuffer:(GLuint *)framebufferHandle {
    glGenFramebuffers(1, framebufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, *framebufferHandle);
}

- (void)setupRenderbuffer:(GLuint *)renderbufferHandle {
    glGenRenderbuffers(1, renderbufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, *renderbufferHandle);
}

- (CGSize)fitSizeComparisonWithScreenBound:(CGSize)targetSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize imageSize = targetSize;
    CGSize fitSize = targetSize;
    if (imageSize.height != 0.0) {            //宽高比
        CGFloat whRate = imageSize.width / imageSize.height;
        //宽>高
        if (whRate > 1.0) {
            if (imageSize.width > screenSize.width) {
                fitSize.width = screenSize.width;
                fitSize.height = screenSize.width / imageSize.width * imageSize.height;
                
            }
            if (fitSize.height > screenSize.height) {
                fitSize.width = screenSize.height / fitSize.height * fitSize.width;
                fitSize.height = screenSize.height;
                
            }
        } else {
            
            //宽<高
            if (imageSize.height > screenSize.height) {
                fitSize.height = screenSize.height;
                fitSize.width = screenSize.height / imageSize.height * imageSize.width;
            }
            if (fitSize.width > screenSize.width) {
                fitSize.height = screenSize.width / fitSize.width * fitSize.height;
                fitSize.width = screenSize.width;
            }
        }
    }
    
    return fitSize;
}

//裁减和剪切
- (void)viewPort {
    //视图放大倍数
    //设置视口
    GLint backingWidth, backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    glViewport(0.0, 0.0, backingWidth, backingHeight);
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

///默认格式为RGBA
+ (GLuint)createTexture2DWithWidth:(GLsizei )width height:(GLsizei)height data:(void *)data {
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    glBindTexture(GL_TEXTURE_2D, 0);
    return texture;
}

void dataProviderReleaseCallback (void *info, const void *data, size_t size)
{
    free((void *)data);
}

//MARK: - 来自于GPUImage的代码 从帧缓存中获取图片
- (CGImageRef)newCGImageFromFramebufferContentsWithTargetImageSize:(CGSize)size {

    //    glViewport(0, 0, (int)size.width, (int)size.height);
  
    
    __block CGImageRef cgImageFromBytes;
    NSUInteger totalBytesForImage = (int)size.width * (int)size.height * 4;///图片所需要的字节数
    // It appears that the width of a texture must be padded out to be a multiple of 8 (32 bytes) if reading from it using a texture cache
    //如果使用纹理缓存读取纹理，纹理的宽度必须被填充为8(32字节)的倍数
    
    GLubyte *rawImagePixels;
    CGDataProviderRef dataProvider = NULL;
    
    
    rawImagePixels = (GLubyte *)malloc(totalBytesForImage);
    ///手动分配内存并且读取
    
    ///read 图片的size
    glReadPixels(0, 0, (int)size.width, (int)size.height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels);
    dataProvider = CGDataProviderCreateWithData(NULL, rawImagePixels, totalBytesForImage, dataProviderReleaseCallback);///根据指针、字节，在内存中获取data
    
    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();//颜色空间
    ///从数据中提取图片
    cgImageFromBytes = CGImageCreate((int)size.width, (int)size.height
                                     , 8, 32, 4 * (int)size.width, defaultRGBColorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaLast, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    
    //释放
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(defaultRGBColorSpace);
     
    return cgImageFromBytes;
}


@end
