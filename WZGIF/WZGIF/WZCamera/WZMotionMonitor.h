//
//  WZMotionMonitor.h
//  WZGIF
//
//  Created by wizet on 2017/7/23.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface WZMotionMonitor : NSObject

- (CMDeviceMotion *)useDeviceMotionPull;
- (CMAccelerometerData *)useAccelerometerPull;
- (CMGyroData *)useGyrpPull;
- (CMMagnetometerData *)useMagnetometerPull;

- (BOOL)useDevieMotionWithHandler:(CMDeviceMotionHandler)handler;
- (BOOL)useAccelerometerPushWithHandler:(CMAccelerometerHandler)handler;
- (BOOL)useGyroPushWithHandler:(CMGyroHandler)handler;
- (BOOL)useMagnetometerPushWithHandler:(CMMagnetometerHandler)handler;

- (void)stopDeviceMotionUpdates;
- (void)stopGyroUpdates;
- (void)stopMagnetometerUpdates;
- (void)stopAccelerometerUpdates;

@end
