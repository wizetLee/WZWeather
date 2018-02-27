//
//  WZVideoReversalTool.m
//  WZWeather
//
//  Created by 李炜钊 on 2018/2/27.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZVideoReversalTool.h"

@interface WZVideoReversalTool() {
    AVAssetReader *assetReader;
    AVAssetWriter *assetWriter;
    
    AVAssetReaderTrackOutput *assetReaderOutput;
    AVAssetWriterInput *assetWriterInput;
    AVAssetWriterInputPixelBufferAdaptor *assetWriterInputAdaptor;
}

@end

@implementation WZVideoReversalTool



@end
