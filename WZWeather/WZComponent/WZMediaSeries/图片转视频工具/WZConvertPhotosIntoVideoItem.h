//
//  WZConvertPhotosIntoVideoItem.h
//  WZWeather
//
//  Created by admin on 29/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@protocol WZConvertPhotosIntoVideoItemProtocol<NSObject>

@end

typedef NS_ENUM(NSUInteger, WZConvertPhotosIntoVideoItemType) {
    WZConvertPhotosIntoVideoItemType_Image                  = 0,
    WZConvertPhotosIntoVideoItemType_SampleBuffer,
    WZConvertPhotosIntoVideoItemType_Context,
};


@interface WZConvertPhotosIntoVideoItem : NSObject

@property (nonatomic, assign) WZConvertPhotosIntoVideoItemType type; //default:WZConvertPhotosIntoVideoItemType_Image

@property (nonatomic, strong) UIImage *leadingImage;//source
@property (nonatomic, strong) UIImage *trailingImage;//source

@property (nonatomic, assign) CVPixelBufferRef pixelBufferRef;
@property (nonatomic, assign) CGContextRef contextRef;

@end
