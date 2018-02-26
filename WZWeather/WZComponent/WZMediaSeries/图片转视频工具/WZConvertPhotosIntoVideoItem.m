//
//  WZConvertPhotosIntoVideoItem.m
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZConvertPhotosIntoVideoItem.h"

@interface WZConvertPhotosIntoVideoItem()

@end

@implementation WZConvertPhotosIntoVideoItem

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
    _transitionType = WZConvertPhotosIntoVideoType_Nontransition;
    _pixelBufferRef = NULL;
    _contextRef = NULL;
}


//首次配置
- (void)firstConfigWithSourceA:(WZGPUImagePicture *)sourceA sourceB:(WZGPUImagePicture *)sourceB filter:(WZConvertPhotosIntoVideoFilter *)filter consumer:(NSObject <GPUImageInput>*)consumer time:(CMTime)time; {
    //换链部分
    [sourceA removeAllTargets];
    [sourceB removeAllTargets];
    [filter removeAllTargets];

    filter.type = (int)_transitionType;
    if (_transitionType == WZConvertPhotosIntoVideoType_Glow) {


    } else if (_transitionType == WZConvertPhotosIntoVideoType_Star) {


    } else {
        [sourceA addTarget:filter];
        [sourceB addTarget:filter];
        [filter addTarget:consumer];
    }

    
    sourceA.sourceImage = self.leadingImage;
    sourceB.sourceImage = self.trailingImage;
}

//持续更新
- (void)updateFrameWithSourceA:(WZGPUImagePicture *)sourceA sourceB:(WZGPUImagePicture *)sourceB filter:(WZConvertPhotosIntoVideoFilter *)filter consumer:(NSObject <GPUImageInput>*)consumer time:(CMTime)time; {
    //更新进度
    [self updateProgress];
    //根据进度配置filter
//    [sourceA processImageWithTime:time];
//     [sourceB processImageWithTime:time];
    switch (_transitionType) {
        case WZConvertPhotosIntoVideoType_None: {
            [sourceA processImageWithTime:time];
        } break;
            
        case WZConvertPhotosIntoVideoType_Dissolve: {
            filter.progress = _progress;
            [sourceA processImageWithTime:time];
            [sourceB processImageWithTime:time];
        } break;
            
        case WZConvertPhotosIntoVideoType_Black:
        case WZConvertPhotosIntoVideoType_White: {
            filter.progress = ((_progress * 2) >= 1)?((1 - (_progress)) * 2) : (_progress * 2);
            if (_progress <= 0.5) {
                [sourceA processImageWithTime:time];
            } else {
                [sourceB processImageWithTime:time];
            }
        } break;
            
        case WZConvertPhotosIntoVideoType_Blur: {
            
        } break;
            
            
        case WZConvertPhotosIntoVideoType_Wipe_LToR: {
            
        } break;
        case WZConvertPhotosIntoVideoType_Wipe_RToL: {
            
        } break;
        case WZConvertPhotosIntoVideoType_Extrusion_TToB: {
            
        } break;
        case WZConvertPhotosIntoVideoType_Extrusion_BToT: {
            
        } break;
            
            
        case WZConvertPhotosIntoVideoType_RollingOver: {
            
        } break;
        case WZConvertPhotosIntoVideoType_V_Blinds: {
            
        } break;
        case WZConvertPhotosIntoVideoType_H_Blinds: {
            
        } break;
            
            
        case WZConvertPhotosIntoVideoType_LToR_Blinds_Gradually: {
            
        } break;
        case WZConvertPhotosIntoVideoType_RToL_Blinds_Gradually: {
            
        } break;
        case WZConvertPhotosIntoVideoType_TToB_Blinds_Gradually: {
            
        } break;
        case WZConvertPhotosIntoVideoType_BToT_Blinds_Gradually: {
            
        } break;
            
            
        case WZConvertPhotosIntoVideoType_Lockwise: {
            
        } break;
        case WZConvertPhotosIntoVideoType_Anticlockwise: {
            
        } break;
        case WZConvertPhotosIntoVideoType_Star: {
            
        } break;
        case WZConvertPhotosIntoVideoType_Glow: {
            
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
    
}

@end
