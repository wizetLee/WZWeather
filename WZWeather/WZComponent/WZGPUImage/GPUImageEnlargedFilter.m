//
//  GPUImageEnlargeFilter.m
//  WZWeather
//
//  Created by 李炜钊 on 2017/12/9.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "GPUImageEnlargedFilter.h"

@interface GPUImageEnlargedFilter() {
     GLint enlargeWeightUniform;
}

@end

@implementation GPUImageEnlargedFilter

- (id)init; {
    if (self = [super initWithFragmentShaderFromFile:@"Enlarged"]) {
        enlargeWeightUniform = [filterProgram uniformIndex:@"enlargeWeight"];
        self.enlargeWeight = 0.1;//默认值为0.1;
    }
    return self;
}

-(void)setEnlargeWeight:(float)enlargeWeight {
    _enlargeWeight = enlargeWeight;
    [self setFloat:enlargeWeight forUniform:enlargeWeightUniform program:filterProgram];//赋值
}


@end
