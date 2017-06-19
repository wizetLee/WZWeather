//
//  WZAnimatedTransitionsBase.h
//  WZWeather
//
//  Created by admin on 17/6/19.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WZAnimatedTransitionsContextBlock)(UIView * __nonnull containerView, UIView * __nonnull fromView, UIView * __nonnull toView);

@interface WZAnimatedTransitionsBase : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) WZAnimatedTransitionsContextBlock begin;

@end
