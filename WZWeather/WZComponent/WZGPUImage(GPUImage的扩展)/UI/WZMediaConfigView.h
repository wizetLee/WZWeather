//
//  WZMediaConfigView.h
//  WZWeather
//
//  Created by Wizet on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WZMediaConfigView;
#import "WZMediaConfigObject.h"

@protocol WZMediaConfigViewProtocol<NSObject>

- (void)mediaConfigView:(WZMediaConfigView *)view configType:(WZMediaConfigType)type;
- (void)mediaConfigView:(WZMediaConfigView *)view tap:(UITapGestureRecognizer *)tap;

@end


/**
 拍摄 录制的设置配置界面
 */
@interface WZMediaConfigView : UIView

@property (nonatomic,  weak) id<WZMediaConfigViewProtocol> delegate;

@end
