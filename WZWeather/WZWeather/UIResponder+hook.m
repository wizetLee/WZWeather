//
//  UIResponder+hook.m
//  WZWeather
//
//  Created by liweizhao on 2018/9/1.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "UIResponder+hook.h"

@implementation UIResponder (hook)


+ (void)load {
    [super load];
    /** 获取原始setBackgroundColor方法 */
    Method originalM = class_getInstanceMethod([self class], @selector(targetForAction:withSender:));
    
    /** 获取自定义的pb_setBackgroundColor方法 */
    Method exchangeM = class_getInstanceMethod([self class], @selector(target2ForAction:withSender:));
    
    /** 交换方法 */
    method_exchangeImplementations(originalM, exchangeM);
   
}

- (id)target2ForAction:(SEL)action withSender:(id)sender {
    NSLog(@"%@---%@---%@", NSStringFromSelector(action), sender, [self targetForAction:action withSender:sender]);
   return [self target2ForAction:action withSender:sender];
}

@end
