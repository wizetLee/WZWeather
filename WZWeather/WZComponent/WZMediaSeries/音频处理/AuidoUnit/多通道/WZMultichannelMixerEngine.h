//
//  WZMultichannelMixerEngine.h
//  WZWeather
//
//  Created by admin on 4/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZMultichannelMixerEngine : NSObject

- (void)play;
- (void)stop;
- (void)rePlay;
- (void)graphStart;
- (void)graphStop;

///控制mixerUnit某个input bus是否可用配置
- (void)enableBusInput:(UInt32)busInputNumber isOn:(AudioUnitParameterValue)isOn;
//控制mixerUnit input bus的音量
- (void)setBusInput:(UInt32)busInputNumber volume:(AudioUnitParameterValue)volume;
//控制mixerUnit output bus的音量
- (void)setOutputBusVolume:(AudioUnitParameterValue)volume;


@end
