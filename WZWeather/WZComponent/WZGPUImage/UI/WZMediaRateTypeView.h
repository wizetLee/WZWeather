//
//  WZMeidaRateTypeView.h
//  WZWeather
//
//  Created by wizet on 30/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZMediaRateTypeView;
@protocol WZMediaRateTypeViewProtocol <NSObject>

- (void)mediaRateTypeView:(WZMediaRateTypeView *)view didScrollToIndex:(NSUInteger)index;

@end


/**
 拍摄速率调节界面 仿快手
 */
@interface WZMediaRateTypeView : UIView

@property (nonatomic, weak) id<WZMediaRateTypeViewProtocol> delegate;

- (instancetype)init NS_UNAVAILABLE;



@end
