//
//  WZSlider.h
//  WZWeather
//
//  Created by admin on 5/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZSlider;

@protocol WZSliderProtocol <NSObject>

- (void)sliderPanGestureStateBegan;
- (void)sliderPanGestureStateChangedWithProgress:(CGFloat)progress;//[0, 1]
- (void)sliderPanGestureStateEnd;

@end

@interface WZSlider : UIView

@property (nonatomic, weak) id<WZSliderProtocol> delegate;

- (void)setProgress:(CGFloat)progress;
- (CGFloat)progress;

@end
