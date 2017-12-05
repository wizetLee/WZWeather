//
//  WZSlider.h
//  WZWeather
//
//  Created by admin on 5/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZSilder;

@protocol WZSilderProtocol <NSObject>

- (void)silderPanGestureStateBegan;
- (void)silderPanGestureStateChangedWithProgress:(CGFloat)progress;//[0, 1]
- (void)silderPanGestureStateEnd;

@end

@interface WZSilder : UIView

@property (nonatomic, weak) id<WZSilderProtocol> delegate;

- (void)setProgress:(CGFloat)progress;
- (CGFloat)progress;

@end
