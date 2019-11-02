//
//  PCAdjustiveGIFSpeedView.h
//  WZGIF
//
//  Created by admin on 21/7/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PCGIFTrackDirection) {
    PCGIFTrackDirectionForward              = 0,
    PCGIFTrackDirectionBackward             = 1,
    PCGIFTrackDirectionRound                = 2,//消耗内存
};

@protocol PCAdjustiveGIFSpeedViewProtocol <NSObject>

- (void)beginSetSpeedRate;
- (void)commitSetSpeedRate;
- (void)currentSpeedRate:(CGFloat)speedRate;
- (void)currentTrackDirection:(PCGIFTrackDirection)trackDirection;

@end

@interface PCAdjustiveGIFSpeedView : UIView

@property (nonatomic, weak) id<PCAdjustiveGIFSpeedViewProtocol> delegate;
@property (nonatomic, assign) PCGIFTrackDirection tarckDirection;

- (void)currentSpeedRate:(CGFloat)speedRate;//restrict 0.0~1.0
- (CGFloat)viewHeight;//本view的高度限定，用于设备匹配

@end
