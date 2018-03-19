//
//  WZGraphicsToVideoItem.h
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "WZGraphicsToVideoFilter.h"
#import "WZGPUImagePicture.h"

@protocol WZGraphicsToVideoItemProtocol<NSObject>

//此item已被转换完成，告诉tool准备下一个item的转化
- (void)itemDidCompleteConversion;

@end

typedef NS_ENUM(NSUInteger, WZGraphicsToVideoItemType) {
    WZGraphicsToVideoItemType_Image                  = 0,
//    WZGraphicsToVideoItemType_SampleBuffer,
//    WZGraphicsToVideoItemType_Context,
};

///过渡效果list
typedef NS_ENUM(int, WZGraphicsToVideoType) {

    WZGraphicsToVideoType_None           = 0,    //效果就是 无
    WZGraphicsToVideoType_Dissolve,              //溶解、交叉叠化
    WZGraphicsToVideoType_Black,                 //闪黑2
    WZGraphicsToVideoType_White,                 //闪白3
    WZGraphicsToVideoType_Blur,                  //模糊4

    WZGraphicsToVideoType_Wipe_LToR,             //左向右呈现  抹
    WZGraphicsToVideoType_Wipe_RToL,             //右向左呈现
    WZGraphicsToVideoType_Wipe_TToB,             //上向下呈现
    WZGraphicsToVideoType_Wipe_BToT,             //下向上呈现  8
    
    WZGraphicsToVideoType_Extrusion_LToR,        //左向右呈现   挤压
    WZGraphicsToVideoType_Extrusion_RToL,        //右向左呈现
    WZGraphicsToVideoType_Extrusion_TToB,        //上向下呈现
    WZGraphicsToVideoType_Extrusion_BToT,        //下向上呈现  12
    
    WZGraphicsToVideoType_RollingOver,           //翻转       13
    WZGraphicsToVideoType_V_Blinds,              //（垂直）百叶窗      14
    WZGraphicsToVideoType_H_Blinds,              //（水平）百叶窗      15
    WZGraphicsToVideoType_LToR_Blinds_Gradually, //（左向右）逐次百叶窗   16~29
    WZGraphicsToVideoType_RToL_Blinds_Gradually,
    WZGraphicsToVideoType_TToB_Blinds_Gradually,
    WZGraphicsToVideoType_BToT_Blinds_Gradually,
    
    WZGraphicsToVideoType_Lockwise,              //顺时针      20
    WZGraphicsToVideoType_Anticlockwise,         //逆时针      21
    WZGraphicsToVideoType_Star,                  //星形        22
    WZGraphicsToVideoType_Glow,                  //辉光        23
    //以上为过渡效果类型
    //以下为非过渡类型
    WZGraphicsToVideoType_Nontransition  = 1000,    //内部非过渡类型 不建议为过渡类型节点使用此类型
};


@interface WZGraphicsToVideoItem : NSObject

@property (nonatomic,   weak) id<WZGraphicsToVideoItemProtocol> delegate;

@property (nonatomic, assign) WZGraphicsToVideoType transitionType;//default:WZGraphicsToVideoType_Nontransition 非过渡类型

@property (nonatomic, strong) UIImage *leadingImage;        //source  -->texture -->pixelBufferRef
@property (nonatomic, strong) UIImage *trailingImage;       //source

@property (nonatomic, assign) CVPixelBufferRef pixelBufferRef;
@property (nonatomic, assign) CGContextRef contextRef;

@property (nonatomic, assign) NSUInteger frameCount;                        //此Item占据的帧数
@property (nonatomic, assign, readonly) NSUInteger framePointer;            //当前扫到的位置
@property (nonatomic, assign, readonly) float progress;                     //扫描进度


//首次配置链
- (void)firstConfigWithSourceA:(WZGPUImagePicture *)sourceA sourceB:(WZGPUImagePicture *)sourceB filter:(WZGraphicsToVideoFilter *)filter consumer:(NSObject <GPUImageInput>*)consumer time:(CMTime)time;

//持续更新frame
- (void)updateFrameWithSourceA:(WZGPUImagePicture *)sourceA sourceB:(WZGPUImagePicture *)sourceB filter:(WZGraphicsToVideoFilter *)filter consumer:(NSObject <GPUImageInput>*)consumer time:(CMTime)time;

- (void)resetItemStatus;
@end
