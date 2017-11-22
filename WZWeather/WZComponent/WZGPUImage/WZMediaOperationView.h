//
//  WZMediaOperationView.h
//  WZWeather
//
//  Created by 李炜钊 on 2017/11/4.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
#import "WZMediaConfigView.h"
#import "WZGPUImagePreinstall.h"
#import "WZMediaGestureView.h"

@class WZMediaOperationView;
@protocol WZMediaOperationViewProtocol<NSObject>

@optional

- (void)operationView:(WZMediaOperationView*)view closeBtnAction:(UIButton *)sender;
- (void)operationView:(WZMediaOperationView*)view shootBtnAction:(UIButton *)sender;
- (void)operationView:(WZMediaOperationView*)view compositionBtnAction:(UIButton *)sender;
- (void)operationView:(WZMediaOperationView*)view configType:(WZMediaConfigType)type;
- (void)operationView:(WZMediaOperationView*)view didSelectedFilter:(GPUImageFilter *)filter;


///切换摄影 录影
- (void)operationView:(WZMediaOperationView*)view swithToMediaType:(WZMediaType)type;

///录像
- (void)operationView:(WZMediaOperationView*)view startRecordGesture:(UILongPressGestureRecognizer *)gesture;
- (void)operationView:(WZMediaOperationView*)view endRecordGesture:(UILongPressGestureRecognizer *)gesture;
- (void)operationView:(WZMediaOperationView*)view breakRecordGesture:(UILongPressGestureRecognizer *)gesture;




@end

@interface WZMediaOperationView : UIView

@property (nonatomic, weak) id<WZMediaOperationViewProtocol> delegate;
@property (nonatomic, weak) id<WZMediaGestureViewProtocol> gestureDelegate;

///切换为对应的UI
- (void)switchModeWithType:(WZMediaType)type;

///录制进度
- (void)recordProgress:(CGFloat)progress;
///录制记录
- (void)addRecordSign;

- (void)screenEdgePan:(UIScreenEdgePanGestureRecognizer *)pan;
@end
