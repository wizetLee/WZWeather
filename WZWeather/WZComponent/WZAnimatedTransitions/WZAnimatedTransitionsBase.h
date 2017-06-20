//
//  WZAnimatedTransitionsBase.h
//  WZWeather
//
//  Created by admin on 17/6/19.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WZCustomAnimatedHandler)(float transitionDuration, UIView * containerView, UIView * fromView, UIView * toView, void (^completeTransition)());

@interface WZAnimatedTransitionsBase : NSObject
<UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) WZCustomAnimatedHandler customPrensentAnimations;
@property (nonatomic, strong) WZCustomAnimatedHandler customDismissAnimations;

- (WZAnimatedTransitionsBase *)configDismiss;
- (WZAnimatedTransitionsBase *)configPresent;

@end
