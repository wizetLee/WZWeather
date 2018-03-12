//
//  WZConvertPhotosIntoVideoItem.h
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "WZConvertPhotosIntoVideoFilter.h"
#import "WZGPUImagePicture.h"

@protocol WZConvertPhotosIntoVideoItemProtocol<NSObject>

//此item已被转换完成，告诉tool准备下一个item的转化
- (void)itemDidCompleteConversion;

@end

typedef NS_ENUM(NSUInteger, WZConvertPhotosIntoVideoItemType) {
    WZConvertPhotosIntoVideoItemType_Image                  = 0,
//    WZConvertPhotosIntoVideoItemType_SampleBuffer,
//    WZConvertPhotosIntoVideoItemType_Context,
};

///过渡效果list
typedef NS_ENUM(int, WZConvertPhotosIntoVideoType) {

    WZConvertPhotosIntoVideoType_None           = 0,    //效果就是 无
    WZConvertPhotosIntoVideoType_Dissolve,              //溶解、交叉叠化
    WZConvertPhotosIntoVideoType_Black,                 //闪黑2
    WZConvertPhotosIntoVideoType_White,                 //闪白3
    WZConvertPhotosIntoVideoType_Blur,                  //模糊4

    WZConvertPhotosIntoVideoType_Wipe_LToR,             //左向右呈现  抹
    WZConvertPhotosIntoVideoType_Wipe_RToL,             //右向左呈现
    WZConvertPhotosIntoVideoType_Wipe_TToB,             //上向下呈现
    WZConvertPhotosIntoVideoType_Wipe_BToT,             //下向上呈现  8
    
    WZConvertPhotosIntoVideoType_Extrusion_LToR,        //左向右呈现   挤压
    WZConvertPhotosIntoVideoType_Extrusion_RToL,        //右向左呈现
    WZConvertPhotosIntoVideoType_Extrusion_TToB,        //上向下呈现
    WZConvertPhotosIntoVideoType_Extrusion_BToT,        //下向上呈现  12
    
    WZConvertPhotosIntoVideoType_RollingOver,           //翻转       13
    WZConvertPhotosIntoVideoType_V_Blinds,              //（垂直）百叶窗      14
    WZConvertPhotosIntoVideoType_H_Blinds,              //（水平）百叶窗      15
    WZConvertPhotosIntoVideoType_LToR_Blinds_Gradually, //（左向右）逐次百叶窗   16~29
    WZConvertPhotosIntoVideoType_RToL_Blinds_Gradually,
    WZConvertPhotosIntoVideoType_TToB_Blinds_Gradually,
    WZConvertPhotosIntoVideoType_BToT_Blinds_Gradually,
    
    WZConvertPhotosIntoVideoType_Lockwise,              //顺时针      20
    WZConvertPhotosIntoVideoType_Anticlockwise,         //逆时针      21
    WZConvertPhotosIntoVideoType_Star,                  //星形        22
    WZConvertPhotosIntoVideoType_Glow,                  //辉光        23
    //以上为过渡效果类型
    //以下为非过渡类型
    WZConvertPhotosIntoVideoType_Nontransition  = 1000,    //内部非过渡类型 不建议为过渡类型节点使用此类型
};


@interface WZConvertPhotosIntoVideoItem : NSObject

@property (nonatomic,   weak) id<WZConvertPhotosIntoVideoItemProtocol> delegate;

@property (nonatomic, assign) WZConvertPhotosIntoVideoType transitionType;//default:WZConvertPhotosIntoVideoType_Nontransition 非过渡类型

@property (nonatomic, strong) UIImage *leadingImage;        //source  -->texture -->pixelBufferRef
@property (nonatomic, strong) UIImage *trailingImage;       //source

@property (nonatomic, assign) CVPixelBufferRef pixelBufferRef;
@property (nonatomic, assign) CGContextRef contextRef;

@property (nonatomic, assign) NSUInteger frameCount;                        //此Item占据的帧数
@property (nonatomic, assign, readonly) NSUInteger framePointer;            //当前扫到的位置
@property (nonatomic, assign, readonly) float progress;                     //扫描进度


//首次配置链
- (void)firstConfigWithSourceA:(WZGPUImagePicture *)sourceA sourceB:(WZGPUImagePicture *)sourceB filter:(WZConvertPhotosIntoVideoFilter *)filter consumer:(NSObject <GPUImageInput>*)consumer time:(CMTime)time;

//持续更新frame
- (void)updateFrameWithSourceA:(WZGPUImagePicture *)sourceA sourceB:(WZGPUImagePicture *)sourceB filter:(WZConvertPhotosIntoVideoFilter *)filter consumer:(NSObject <GPUImageInput>*)consumer time:(CMTime)time;

- (void)resetItemStatus;
@end
