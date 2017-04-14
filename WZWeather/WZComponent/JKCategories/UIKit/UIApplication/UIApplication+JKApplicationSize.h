//
//  UIApplication+JKApplicationSize.h
//  testSize
//
//  Created by Ignazio Calo on 23/01/15.
//  Copyright (c) 2015 IgnazioC. All rights reserved.
//  https://github.com/ignazioc/iOSApplicationSize
//   A small category on UIApplication used to calculate the size of the running iOS applicaiton.


#import <UIKit/UIKit.h>

@interface UIApplication (JKApplicationSize)
/**
 *  计算应用大小 无算上tmp
 *
 *  @return 应用大小str
 */
- (NSString *)jk_applicationSize;

@end
