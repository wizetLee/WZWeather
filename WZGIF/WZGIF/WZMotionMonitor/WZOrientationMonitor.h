//
//  WZOrientationMonitor.h
//  WZGIF
//
//  Created by wizet on 2017/7/23.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit.UIDevice;

@class WZOrientationMonitor;
@protocol  WZOrientationProtocol<NSObject>

@optional
- (void)orientationMonitor:(WZOrientationMonitor *)monitor change:(UIDeviceOrientation)change;

@end

@interface WZOrientationMonitor : NSObject

@property (nonatomic, assign) UIDeviceOrientation orientation;
@property (nonatomic, weak) id<WZOrientationProtocol> delegate;

- (instancetype)initWithDelegate:(id<WZOrientationProtocol>)delegate;
- (void)startMonitor;
- (void)stopMonitor;

@end
