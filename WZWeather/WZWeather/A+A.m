//
//  A+A.m
//  WZWeather
//
//  Created by wizet on 2017/7/2.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "A+A.h"



@implementation A (A)

- (void)setString:(NSString *)string {

    objc_setAssociatedObject(self, @selector(setString:), string, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)string {
    return objc_getAssociatedObject(self, @selector(setString:));
}


@end
