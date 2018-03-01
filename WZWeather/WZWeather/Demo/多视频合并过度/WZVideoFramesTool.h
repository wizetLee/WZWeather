//
//  WZVideoFramesTool.h
//  WZWeather
//
//  Created by 李炜钊 on 2018/3/1.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZVideoReversalTool.h"


@interface WZVideoFramesTool : NSObject

@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, assign, readonly) WZVideoReversalToolStatus status;

@end
