//
//  WZBaseViewController.h
//  WZWeather
//
//  Created by wizet on 17/2/27.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZBaseViewController : UIViewController

@property (nonatomic, strong) NSObject <UIViewControllerAnimatedTransitioning> *modalAnimator;

- (BOOL)customTransitions;

@end
