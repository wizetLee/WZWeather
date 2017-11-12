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

@class WZMediaOperationView;
@protocol WZMediaOperationViewProtocol<NSObject>

@optional

- (void)operationView:(WZMediaOperationView*)view closeBtnAction:(UIButton *)sender;
- (void)operationView:(WZMediaOperationView*)view pickBtnAction:(UIButton *)sender;
- (void)operationView:(WZMediaOperationView*)view configType:(WZMediaConfigType)type;
- (void)operationView:(WZMediaOperationView*)view didSelectedFilter:(GPUImageFilter *)filter;

@end

@interface WZMediaOperationView : UIView

@property (nonatomic, weak) id<WZMediaOperationViewProtocol> delegate;
- (void)setSource:(GPUImageOutput *)source;

@end