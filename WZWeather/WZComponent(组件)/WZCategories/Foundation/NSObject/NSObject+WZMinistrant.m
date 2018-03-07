//
//  NSObject+WZministrant.m
//  WZWeather
//
//  Created by wizet on 24/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "NSObject+WZMinistrant.h"

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

///这里的范围指的是安全区的边界范围
+ (CGSize)wz_fitSizeComparisonWithScreenBound:(CGSize)targetSize {
    CGFloat top = MACRO_FLOAT_STSTUSBAR_AND_NAVIGATIONBAR_HEIGHT;
    CGFloat bottom = MACRO_FLOAT_SAFEAREA_BOTTOM;
    CGFloat height = UIScreen.mainScreen.bounds.size.width - bottom - top;
    CGSize screenSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, height);
    CGSize imageSize = targetSize;
    CGSize fitSize = targetSize;
    if (imageSize.height != 0.0) {            //宽高比
        CGFloat whRate = imageSize.width / imageSize.height;
        //宽>高
        if (whRate > 1.0) {
            if (imageSize.width > screenSize.width) {
                fitSize.width = screenSize.width;
                fitSize.height = screenSize.width / imageSize.width * imageSize.height;
                
            }
            if (fitSize.height > screenSize.height) {
                fitSize.width = screenSize.height / fitSize.height * fitSize.width;
                fitSize.height = screenSize.height;
                
            }
        } else {
            
            //宽<高
            if (imageSize.height > screenSize.height) {
                fitSize.height = screenSize.height;
                fitSize.width = screenSize.height / imageSize.height * imageSize.width;
            }
            if (fitSize.width > screenSize.width) {
                fitSize.height = screenSize.width / fitSize.width * fitSize.height;
                fitSize.width = screenSize.width;
            }
        }
    }
    
    return fitSize;
}

@end
