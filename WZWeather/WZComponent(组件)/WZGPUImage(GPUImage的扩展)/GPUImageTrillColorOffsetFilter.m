//
//  GPUImageEnlargeFilter.m
//  WZWeather
//
//  Created by 李炜钊 on 2017/12/9.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "GPUImageTrillColorOffsetFilter.h"

@interface GPUImageTrillColorOffsetFilter() {
     GLint enlargeWeightUniform;
    float awagValue;//摇摆位置
}

@end

@implementation GPUImageTrillColorOffsetFilter

- (id)init; {
    if (self = [super initWithFragmentShaderFromFile:@"TrillColorOffset"]) {
        enlargeWeightUniform = [filterProgram uniformIndex:@"enlargeWeight"];
        self.enlargeWeight = 0.0;//默认值为0.1;
    }
    return self;
}

-(void)setEnlargeWeight:(float)enlargeWeight {
    _enlargeWeight = enlargeWeight;
    [self setFloat:enlargeWeight forUniform:enlargeWeightUniform program:filterProgram];//赋值
}

#pragma mark - GPUImageInput
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    
    if (_autoAlternate) {
        [self autoModifyEnlargeWeight];
    }
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    //渲染到纹理到目标顶点坐标
    [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
    
    //更新链下方的buffer信息
    [self informTargetsAboutNewFrameAtTime:frameTime];
}

- (void)autoModifyEnlargeWeight {
    if (self.enlargeWeight <= 0.0) {
        awagValue = 0.1;
    } else if (self.enlargeWeight >= 1.0) {
        awagValue = -0.1;
    }
    self.enlargeWeight = self.enlargeWeight + awagValue;
}

@end
