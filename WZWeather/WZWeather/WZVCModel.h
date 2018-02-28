//
//  WZVCModel.h
//  WZWeather
//
//  Created by admin on 22/2/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZDownloadController.h"
#import "WZPageViewController.h"
#import "WZPageViewAssistController.h"
#import "WZAVPlayerViewController.h"
#import "WZPhotoCatalogueController.h"
#import "WZVideoPickerController.h"
#import "WZAudioCodecController.h"
#import "WZVideoCodecController.h"
#import "WZMediaController.h"
#import "WZTestViewController.h"

#pragma mark - Demo
#import "Demo_ConvertPhotosIntoVideoController.h"
#import "Demo_ConvertPhotosIntoVideoUseGPUImageViewController.h"
#import "Demo_AnimatePageControlViewController.h"
#import "Demo_WrapViewController.h"
#import "Demo_VideoReversalController.h"
#import "Demo_VideoRateAdjustmentController.h"

typedef NS_ENUM(NSUInteger, WZVCModelTransitionType) {
    WZVCModelTransitionType_Custom,
    WZVCModelTransitionType_Push,
    WZVCModelTransitionType_Push_FromNib,
    WZVCModelTransitionType_Present,
    WZVCModelTransitionType_Present_FromNib,
};

@interface WZVCModel : NSObject

@property (nonatomic, strong) NSString *headline;

@property (nonatomic, strong) Class VCClass;

@property (nonatomic, assign) WZVCModelTransitionType type;


+ (NSArray *)source;

@end
