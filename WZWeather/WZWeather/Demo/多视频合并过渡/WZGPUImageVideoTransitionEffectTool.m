//
//  WZGPUImageVideoTransitionEffectTool.m
//  WZWeather
//
//  Created by admin on 28/2/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZGPUImageVideoTransitionEffectTool.h"

//帧率补偿类型
typedef NS_ENUM(NSUInteger, WZVideoFrameRateProcessingType) {
    WZVideoFrameRateProcessingType_None               = 0,
    WZVideoFrameRateProcessingType_Increase,
    WZVideoFrameRateProcessingType_Decrease,
};

@interface WZGPUImageVideoTransitionEffectTool()
{
    AVAssetReader *assetReader;
    AVAssetWriter *assetWriter;
    
    AVAssetReaderTrackOutput *assetReaderOutput;
    AVAssetWriterInput *assetWriterInput;
    AVAssetWriterInputPixelBufferAdaptor *assetWriterInputAdaptor;
    
    int outputRate;//输出的帧率  多的就减帧 少了就补帧
}

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) NSArray <AVAsset *>*sources;

@end

@implementation WZGPUImageVideoTransitionEffectTool

- (void)defaultConfig {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLink:)];
    
}

- (void)displayLink:(CADisplayLink *)displayLink {
    
}

@end
