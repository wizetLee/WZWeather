//
//  UIApplication+JKKeyboardFrame.h
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 15/5/23.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  键盘的frame情况   缺点  不可以直接在获取一个回调
 */
@interface UIApplication (JKKeyboardFrame)

- (CGRect)jk_keyboardFrame;

@end
