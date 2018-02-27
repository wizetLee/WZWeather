//
//  WZVCModel.m
//  WZWeather
//
//  Created by admin on 22/2/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZVCModel.h"

@interface WZVCModel()

@end

@implementation WZVCModel

+ (NSArray *)source {
    NSMutableArray *_sources = NSMutableArray.array;
    
    WZVCModel *VCModel = WZVCModel.alloc.init;
    VCModel.VCClass = WZTestViewController.class;
    VCModel.headline = @"WZTestViewController 临时测试专用";
    [_sources addObject:VCModel];
    
    VCModel = WZVCModel.alloc.init;
    VCModel.VCClass = WZMediaController.class;
    VCModel.headline = @"跳转到：拍摄、录像";
    [_sources addObject:VCModel];
    
    
    VCModel = WZVCModel.alloc.init;
    VCModel.VCClass = WZAVPlayerViewController.class;
    VCModel.headline = @"播放和animationTool测试";
    [_sources addObject:VCModel];
    
    VCModel = WZVCModel.alloc.init;
    VCModel.VCClass = WZPhotoCatalogueController.class;
    VCModel.headline = @"图片选取";
    [_sources addObject:VCModel];
    
    VCModel = WZVCModel.alloc.init;
    VCModel.VCClass = WZVideoPickerController.class;
    VCModel.headline = @"视频选取、合并、删除";
    [_sources addObject:VCModel];
    
    VCModel = WZVCModel.alloc.init;
    VCModel.VCClass = Demo_ConvertPhotosIntoVideoController.class;
    VCModel.type = WZVCModelTransitionType_Push_FromNib;
    VCModel.headline = @"图片转视频demo";
    [_sources addObject:VCModel];
    
    VCModel = WZVCModel.alloc.init;
    VCModel.VCClass = Demo_ConvertPhotosIntoVideoUseGPUImageViewController.class;
    VCModel.type = WZVCModelTransitionType_Push_FromNib;
    VCModel.headline = @"图片转视频(GPUImage)demo";
    [_sources addObject:VCModel];
    
    VCModel = WZVCModel.alloc.init;
    VCModel.VCClass = Demo_AnimatePageControlViewController.class;
    VCModel.type = WZVCModelTransitionType_Push_FromNib;
    VCModel.headline = @"AnimatePageControlDemo";
    [_sources addObject:VCModel];
    
    VCModel = WZVCModel.alloc.init;
    VCModel.VCClass = Demo_WrapViewController.class;
    VCModel.type = WZVCModelTransitionType_Push_FromNib;
    VCModel.headline = @"弯曲模型";
    [_sources addObject:VCModel];
    
    VCModel = WZVCModel.alloc.init;
    VCModel.VCClass = Demo_VideoReversalController.class;
    VCModel.type = WZVCModelTransitionType_Push_FromNib;
    VCModel.headline = @"视频倒放";
    [_sources addObject:VCModel];
    
    return _sources;
}

@end
