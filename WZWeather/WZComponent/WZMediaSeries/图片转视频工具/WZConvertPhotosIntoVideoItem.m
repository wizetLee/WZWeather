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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultConfig];//configuration
    }
    return self;
}

- (void)defaultConfig {
    _type = WZConvertPhotosIntoVideoItemType_Image;
    _pixelBufferRef = NULL;
    _contextRef = NULL;
}


@end
