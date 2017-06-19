//
//  WZPageViewAssistController.m
//  WZWeather
//
//  Created by admin on 17/6/16.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZPageViewAssistController.h"

@interface WZPageViewAssistController ()

@end

@implementation WZPageViewAssistController

- (instancetype)init {
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark Accessor
- (NSMutableDictionary *)param {
    if (!_param) {
        _param = [NSMutableDictionary dictionary];
    }
    return _param;
}
@end
