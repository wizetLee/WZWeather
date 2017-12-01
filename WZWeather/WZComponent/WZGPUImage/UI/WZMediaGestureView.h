//
//  WZMediaGestureView.h
//  WZWeather
//
//  Created by wizet on 7/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZMediaGestureView;
@protocol WZMediaGestureViewProtocol<NSObject>

///更新焦点
- (void)gestureView:(WZMediaGestureView *)view updateFocusAtPoint:(CGPoint)point;
///更新曝光点
- (void)gestureView:(WZMediaGestureView *)view updateExposureAtPoint:(CGPoint)point;
///同时更新焦点以及曝光点
- (void)gestureView:(WZMediaGestureView *)view updateFocusAndExposureAtPoint:(CGPoint)point;
///焦距更变
- (void)gestureView:(WZMediaGestureView *)view updateZoom:(CGFloat)zoom;
//边缘手势
- (void)gestureView:(WZMediaGestureView *)view screenEdgePan:(UIScreenEdgePanGestureRecognizer *)screenEdgePan;
@end

@interface WZMediaGestureView : UIView

@property (nonatomic, weak) id<WZMediaGestureViewProtocol> delegate;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePan;//左边缘手势
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePanR;//右边缘手势

@end
