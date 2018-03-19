//
//  WZThermalCameraFilter.m
//  WZWeather
//
//  Created by 李炜钊 on 2018/3/19.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZThermalCameraFilter.h"

@implementation WZThermalCameraFilter

- (id)init {
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:@"ThermalCamera" ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPathname encoding:NSUTF8StringEncoding error:nil];
    NSString *vertexShaderPathname = [[NSBundle mainBundle] pathForResource:@"ThermalCamera" ofType:@"vsh"];
    NSString *vertexShaderString = [NSString stringWithContentsOfFile:vertexShaderPathname encoding:NSUTF8StringEncoding error:nil];
    if (self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString])
    {
        
    }
    
    return self;
}

@end
