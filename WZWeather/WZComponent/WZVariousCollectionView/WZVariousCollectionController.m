//
//  WZVariousCollectionController.m
//  WZWeather
//
//  Created by admin on 17/4/14.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVariousCollectionController.h"

@interface WZVariousCollectionController ()

@end

@implementation WZVariousCollectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    _collection = [WZVariousCollectionView staticInitWithFrame:[self vitalizetableFrame]];
    [self.view addSubview:_collection];
    _collection.registerCellDic = [self vitalizeRegisterCellDic];
    _collection.locatedController = self;
    _collection.variousCollectionDelegate = (id<WZVariousCollectionDelegate>)self;
    
}

#pragma mark WZVariousCollectionDelegate
- (void)variousView:(UIView *)view param:(NSMutableDictionary *)param {
}

#pragma mark prepare for sub class

- (CGRect)vitalizetableFrame {
    if (self.navigationController) {
        return CGRectMake(0.0, 64.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    } else {
        return CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
}

- (NSMutableDictionary *)vitalizeRegisterCellDic {
    return [NSMutableDictionary dictionary];
}



@end
