//
//  WZGraphicsToVideoItem.m
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZGraphicsToVideoItem.h"

@interface WZGraphicsToVideoItem()

@end

@implementation WZGraphicsToVideoItem

//- (void)dealloc {
//    NSLog(@"%s", __func__);
//}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultConfig];//configuration
    }
    return self;
}

- (void)defaultConfig {
    _transitionType = WZGraphicsToVideoType_Nontransition;
    _pixelBufferRef = NULL;
    _contextRef = NULL;
}


//首次配置
- (void)firstConfigWithSourceA:(WZGPUImagePicture *)sourceA sourceB:(WZGPUImagePicture *)sourceB filter:(WZGraphicsToVideoFilter *)filter consumer:(NSObject <GPUImageInput>*)consumer time:(CMTime)time; {
    //换链部分
    [sourceA removeAllTargets];
    [sourceB removeAllTargets];
    [filter removeAllTargets];

    filter.type = (int)_transitionType;
    if (_transitionType == WZGraphicsToVideoType_Glow) {


    } else if (_transitionType == WZGraphicsToVideoType_Star) {


    } else {
        [sourceA addTarget:filter];
        [sourceB addTarget:filter];
        [filter addTarget:consumer];
    }

    
    sourceA.sourceImage = self.leadingImage;
    sourceB.sourceImage = self.trailingImage;
}

//持续更新
- (void)updateFrameWithSourceA:(WZGPUImagePicture *)sourceA sourceB:(WZGPUImagePicture *)sourceB filter:(WZGraphicsToVideoFilter *)filter consumer:(NSObject <GPUImageInput>*)consumer time:(CMTime)time; {
    //更新进度
    [self updateProgress];
    //根据进度配置filter
//    [sourceA processImageWithTime:time];
//     [sourceB processImageWithTime:time];
    switch (_transitionType) {
        case WZGraphicsToVideoType_None: {
            [sourceA processImageWithTime:time];
        } break;
            
        case WZGraphicsToVideoType_Dissolve: {
            filter.progress = _progress;
            [sourceA processImageWithTime:time];
            [sourceB processImageWithTime:time];
        } break;
            
        
        case WZGraphicsToVideoType_Black:
        case WZGraphicsToVideoType_White: {
            filter.progress = ((_progress * 2) >= 1)?((1 - (_progress)) * 2) : (_progress * 2);
            if (_progress <= 0.5) {
                [sourceA processImageWithTime:time];
            } else {
                [sourceB processImageWithTime:time];
            }
        } break;
        case WZGraphicsToVideoType_RollingOver: {
            filter.progress = _progress;
            if (_progress <= 0.5) {
                [sourceA processImageWithTime:time];
            } else {
                [sourceB processImageWithTime:time];
            }
        } break;
            
        case WZGraphicsToVideoType_Blur: {
            
        } break;
            
            
        case WZGraphicsToVideoType_Wipe_LToR:
        case WZGraphicsToVideoType_Wipe_RToL:
        case WZGraphicsToVideoType_Wipe_TToB:
        case WZGraphicsToVideoType_Wipe_BToT:
        case WZGraphicsToVideoType_Extrusion_LToR:
        case WZGraphicsToVideoType_Extrusion_RToL:
        case WZGraphicsToVideoType_Extrusion_TToB:
        case WZGraphicsToVideoType_Extrusion_BToT: {
            filter.progress = _progress;
            [sourceA processImageWithTime:time];
            [sourceB processImageWithTime:time];
        } break;
            
       
        case WZGraphicsToVideoType_V_Blinds:
        case WZGraphicsToVideoType_H_Blinds: {
            filter.progress = _progress;
            [sourceA processImageWithTime:time];
            [sourceB processImageWithTime:time];
        } break;
            
            
        case WZGraphicsToVideoType_LToR_Blinds_Gradually:
        case WZGraphicsToVideoType_RToL_Blinds_Gradually:
        case WZGraphicsToVideoType_TToB_Blinds_Gradually:
        case WZGraphicsToVideoType_BToT_Blinds_Gradually: {
            filter.progress = _progress;
            [sourceA processImageWithTime:time];
            [sourceB processImageWithTime:time];
        } break;
        
        case WZGraphicsToVideoType_Anticlockwise:
        case WZGraphicsToVideoType_Lockwise: {
            filter.progress = _progress;
            [sourceA processImageWithTime:time];
            [sourceB processImageWithTime:time];
        } break;
       
        case WZGraphicsToVideoType_Star: {
            
        } break;
        case WZGraphicsToVideoType_Glow: {
            
        } break;
            
        default: {
            //nontransition或其他的情况只传句柄为0的buffer
             [sourceA processImageWithTime:time];
        } break;
    }
    
    //之后是告知外界、这个item的信息已全部被读取了
    if (_progress >= 1) {
        if ([_delegate respondsToSelector:@selector(itemDidCompleteConversion)]) {
            [_delegate itemDidCompleteConversion];
        }
    }
}

- (void)updateProgress {
    _framePointer++;
    if (_frameCount) {
        _progress = (_framePointer * 1.0) / _frameCount;
      
    } else {
        _progress = 0.0;
    }
}

#pragma mark - Public
- (void)resetItemStatus {
    _framePointer = 0;
    _progress = 0;
}

@end
