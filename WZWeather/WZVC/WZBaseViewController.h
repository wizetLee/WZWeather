//
//  WZBaseViewController.h
//  WZWeather
//
//  Created by wizet on 17/2/27.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WZAnimatedTransitionsBase;
@class WZInteractiveTransitionsBase;

@interface WZBaseViewController : UIViewController

@property (nonatomic, strong) WZAnimatedTransitionsBase *modalAnimator;
@property (nonatomic, strong) WZInteractiveTransitionsBase *modalInteractor;

- (BOOL)customTransitions;

@end
