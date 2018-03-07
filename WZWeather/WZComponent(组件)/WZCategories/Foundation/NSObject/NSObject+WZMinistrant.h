//
//  NSObject+WZministrant.h
//  WZWeather
//
//  Created by wizet on 24/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (WZministrant)


//MARK:- 获取当前视图所在的视图控制器
+ (UIViewController *)wz_currentViewController;

//计算与screen之间的边界比例  有bug
+ (CGSize)wz_fitSizeComparisonWithScreenBound:(CGSize)targetSize;


@end
