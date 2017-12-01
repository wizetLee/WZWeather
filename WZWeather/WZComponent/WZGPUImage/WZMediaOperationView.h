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


typedef NS_ENUM(NSUInteger, WZMediaViewScaleMode) {
    WZMediaViewScaleMode_none               = 0,//1
    WZMediaViewScaleMode_slow_1,//0.25
    WZMediaViewScaleMode_slow_2,//0.5
    WZMediaViewScaleMode_normal,//1
    WZMediaViewScaleMode_fast_1,//2
    WZMediaViewScaleMode_fast_2,//4
};

@class WZMediaOperationView;
@protocol WZMediaOperationViewProtocol<NSObject>

@optional

//MARK:UI事件
- (void)operationView:(WZMediaOperationView*)view closeBtnAction:(UIButton *)sender;
- (void)operationView:(WZMediaOperationView*)view shootBtnAction:(UIButton *)sender;
- (void)operationView:(WZMediaOperationView*)view compositionBtnAction:(UIButton *)sender;
- (void)operationView:(WZMediaOperationView*)view configType:(WZMediaConfigType)type;
- (void)operationView:(WZMediaOperationView*)view didSelectedFilter:(GPUImageFilter *)filter;
- (void)operationView:(WZMediaOperationView*)view scaleMode:(NSUInteger)mode;

//MARK:切换角标
- (void)operationView:(WZMediaOperationView*)view didScrollToIndex:(NSUInteger)index;

//MARK:切换摄影 录影
- (void)operationView:(WZMediaOperationView*)view swithToMediaType:(WZMediaType)type;

//MARK:录像 手势
- (void)operationView:(WZMediaOperationView*)view startRecordGesture:(UILongPressGestureRecognizer *)gesture;
- (void)operationView:(WZMediaOperationView*)view endRecordGesture:(UILongPressGestureRecognizer *)gesture;
- (void)operationView:(WZMediaOperationView*)view breakRecordGesture:(UILongPressGestureRecognizer *)gesture;



@end

@interface WZMediaOperationView : UIView

@property (nonatomic, weak) id<WZMediaOperationViewProtocol> delegate;
@property (nonatomic, weak) id<WZMediaGestureViewProtocol> gestureDelegate;

//MARK:录像 摄影之间的切换I
- (void)switchModeWithType:(WZMediaType)type;
//MARK:录制进度
- (void)recordProgress:(CGFloat)progress;
//MARK:录制记录
- (void)addRecordSign;
//MARK:边缘手势
- (void)screenEdgePan:(UIScreenEdgePanGestureRecognizer *)pan;
@end
