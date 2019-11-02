//
//  WZMotionMonitor.m
//  WZGIF
//
//  Created by wizet on 2017/7/23.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMotionMonitor.h"

@interface WZMotionMonitor ()

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation WZMotionMonitor

#pragma mark - DeviceMotion拉数据
- (CMDeviceMotion *)useDeviceMotionPull {
    if ([self.motionManager isDeviceMotionAvailable]
        && [self.motionManager isDeviceMotionActive]){
        //更新频率是100Hz
        self.motionManager.deviceMotionUpdateInterval = 0.01;
        [self.motionManager startDeviceMotionUpdates];
        CMDeviceMotion *deviceMotion = _motionManager.deviceMotion;
       
        return deviceMotion;
    } else {
        return nil;
    }
}

#pragma mark - 加速计拉数据
- (CMAccelerometerData *)useAccelerometerPull {
    if ([self.motionManager isAccelerometerAvailable]
        && [self.motionManager isAccelerometerActive]){
        self.motionManager.accelerometerUpdateInterval = 0.01;
        [self.motionManager startAccelerometerUpdates];
        CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
        NSLog(@"X = %.04f",accelerometerData.acceleration.x);
        NSLog(@"Y = %.04f",accelerometerData.acceleration.y);
        NSLog(@"Z = %.04f",accelerometerData.acceleration.z);
        return accelerometerData;
    } else {
        return nil;
    }
}

#pragma mark - 陀螺仪拉数据
- (CMGyroData *)useGyrpPull {
    if ([self.motionManager isGyroAvailable]
        && [self.motionManager isGyroActive]) {
        self.motionManager.gyroUpdateInterval = 0.01;
        [self.motionManager startGyroUpdates];
        CMGyroData *gyroData = _motionManager.gyroData;
        NSLog(@"Gyro Rotation x = %.04f", gyroData.rotationRate.x);
        NSLog(@"Gyro Rotation y = %.04f", gyroData.rotationRate.y);
        NSLog(@"Gyro Rotation z = %.04f", gyroData.rotationRate.z);
        return gyroData;
    } else {
        return nil;
    }
}

#pragma mark - 磁力计拉数据
- (CMMagnetometerData *)useMagnetometerPull {
    if ([self.motionManager isMagnetometerAvailable]
        && [self.motionManager isMagnetometerActive]) {
        self.motionManager.magnetometerUpdateInterval = 0.01;
        [self.motionManager startMagnetometerUpdates];
        CMMagnetometerData *magnetometer = _motionManager.magnetometerData;
        NSLog(@"MagnetometerData magneticField x = %.04f", magnetometer.magneticField.x);
        NSLog(@"MagnetometerData magneticField y = %.04f", magnetometer.magneticField.y);
        NSLog(@"MagnetometerData magneticField z = %.04f", magnetometer.magneticField.z);
        return magnetometer;
    } else {
        return nil;
    }
}

#pragma mark - DevieMotion推数据
- (BOOL)useDevieMotionWithHandler:(CMDeviceMotionHandler)handler {
    if ([self.motionManager isDeviceMotionAvailable]){
        //更新频率是100Hz
        self.motionManager.deviceMotionUpdateInterval = 0.01;
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [self.motionManager startDeviceMotionUpdatesToQueue:queue
                                                withHandler:handler];
        return true;
    } else {
        return false;
    }
}


#pragma mark - 加速度计推数据
- (BOOL)useAccelerometerPushWithHandler:(CMAccelerometerHandler)handler {
    if ([self.motionManager isAccelerometerAvailable]
        && [self.motionManager isAccelerometerActive]){
        self.motionManager.accelerometerUpdateInterval = 0.01;
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [self.motionManager startAccelerometerUpdatesToQueue:queue
                                                 withHandler:handler];
        return true;
    } else {
        NSLog(@"加速计不可用");
        return false;
    }
}

#pragma mark - 陀螺仪推数据
- (BOOL)useGyroPushWithHandler:(CMGyroHandler)handler {
    if ([self.motionManager isGyroAvailable]
        && [self.motionManager isGyroActive]){
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        self.motionManager.gyroUpdateInterval = 0.01;
        [self.motionManager startGyroUpdatesToQueue:queue
                                        withHandler:handler];
        return true;
    } else {
        NSLog(@"陀螺仪不可用");
        return false;
    }
}

#pragma mark - 磁力计推数据
- (BOOL)useMagnetometerPushWithHandler:(CMMagnetometerHandler)handler {
    if ([self.motionManager isMagnetometerAvailable]
        && [self.motionManager isMagnetometerActive]) {
        self.motionManager.accelerometerUpdateInterval = 0.01;
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [self.motionManager startMagnetometerUpdatesToQueue:queue
                                                withHandler:handler];
        return true;
    } else {
        return false;
    }
}

#pragma mark - 停止更新
//停止DeviceMotion
- (void)stopDeviceMotionUpdates {
    [self.motionManager stopDeviceMotionUpdates];
}
//停止陀螺仪
- (void)stopGyroUpdates {
    [self.motionManager stopGyroUpdates];
}
//停止磁力计
- (void)stopMagnetometerUpdates {
    [self.motionManager stopMagnetometerUpdates];
}
//停止加速计
- (void)stopAccelerometerUpdates {
    [self.motionManager stopAccelerometerUpdates];
}


#pragma mark - Accessor
- (CMMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}


@end
