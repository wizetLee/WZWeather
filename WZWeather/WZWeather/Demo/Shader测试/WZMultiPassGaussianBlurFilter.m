//
//  WZMultiPassGaussianBlurFilter.m
//  WZWeather
//
//  Created by 李炜钊 on 2018/3/20.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZMultiPassGaussianBlurFilter.h"

@implementation WZMultiPassGaussianBlurFilter

- (id)init {
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:@"WZMultiPassGaussianBlur" ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPathname encoding:NSUTF8StringEncoding error:nil];
    NSString *vertexShaderPathname = [[NSBundle mainBundle] pathForResource:@"WZMultiPassGaussianBlur" ofType:@"vsh"];
    NSString *vertexShaderString = [NSString stringWithContentsOfFile:vertexShaderPathname encoding:NSUTF8StringEncoding error:nil];
    if (self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString])
    {
        
    }
    
    return self;
}

@end
