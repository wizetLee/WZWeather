//
//  WZMediaConfigObject.h
//  WZWeather
//
//  Created by Wizet on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVariousBaseObject.h"

typedef NS_ENUM(NSUInteger, WZMediaConfigType) {
    WZMediaConfigType_none                  = 0,
    
    WZMediaConfigType_canvas_1_multiply_1   = 11,//W multiply H
    WZMediaConfigType_canvas_3_multiply_4   = 12,
    WZMediaConfigType_canvas_9_multiply_16  = 13,
    
    WZMediaConfigType_flash_auto            = 21,
    WZMediaConfigType_flash_off             = 22,
    WZMediaConfigType_flash_on              = 23,
    
    WZMediaConfigType_countDown_10          = 31,//倒计时
    WZMediaConfigType_countDown_3           = 32,
    WZMediaConfigType_countDown_off         = 33,
    
    
    
    
};

@interface WZMediaConfigObject : WZVariousBaseObject

@property (nonatomic, strong) NSString *headline;//标题
@property (nonatomic, assign) NSUInteger type;// 1:画幅   2:闪光灯  3:倒计时
@property (nonatomic, assign) WZMediaConfigType selectedType;//选中的类型



@end
