//
//  WZOptionBar.m
//  WZWeather
//
//  Created by admin on 17/6/23.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZOptionBar.h"

@interface WZOptionBar()

@property (nonatomic, strong) UIScrollView *content;

@end

@implementation WZOptionBar


- (instancetype)init {
    if (self = [super init]) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    [self addSubview:self.content];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.content.frame = self.bounds;
}

#pragma mark Accessor
- (UIScrollView *)content {
    if (!_content) {
        _content = [[UIScrollView alloc] initWithFrame:self.bounds];
    }
    return _content;
}

- (NSMutableArray <NSString *>*)titleArray {
    if (!_titleArray) {
        _titleArray = [NSMutableArray array];
    }
    return _titleArray;
}

@end
