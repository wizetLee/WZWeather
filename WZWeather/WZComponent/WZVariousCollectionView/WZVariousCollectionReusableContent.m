//
//  WZVariousCollectionReusableContent.m
//  WZWeather
//
//  Created by wizet on 17/4/13.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVariousCollectionReusableContent.h"

@implementation WZVariousCollectionReusableContent

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (CGSize)sizeForData:(id)data {
    CGSize size = CGSizeZero;
    if (data) {
        size = CGSizeMake(200, 200);
    }
    if ([data isEqualToString:@"111"]) {
        size = CGSizeMake(10, 10);
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
    return size;
}



- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}


@end
