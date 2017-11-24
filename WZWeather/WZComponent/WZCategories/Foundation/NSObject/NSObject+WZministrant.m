//
//  NSObject+WZministrant.m
//  WZWeather
//
//  Created by wizet on 24/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "NSObject+WZministrant.h"

@implementation NSObject (WZministrant)

+ (UIViewController *)wz_currentViewController {
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    NSLog(@"--- ABCGADPlugin --- getCurrentVC --- result : %@ ", result);
    return result;
}

@end
