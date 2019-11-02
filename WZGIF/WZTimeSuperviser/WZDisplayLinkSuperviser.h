//
//  WZDisplayLinkSuperviser.h
//  WZWeather
//
//  Created by wizet on 17/5/5.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZTimeSuperviser.h"

/**
 * 屏幕刷新频率(FPS)是60H,即z屏幕1sec刷新60次  CADisplayLink是能让我们以屏幕刷新速率为计时频率的定时器
 * 触发器间隔可修改（ps：最快的频率与屏幕的刷新率一样）= duration（1.0 / 60.0） × frameInterval
 *
 */
@interface WZDisplayLinkSuperviser : WZTimeSuperviser

@end
