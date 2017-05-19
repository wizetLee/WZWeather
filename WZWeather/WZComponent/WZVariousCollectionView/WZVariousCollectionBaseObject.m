//
//  WZVariousCollectionBaseObject.m
//  WZWeather
//
//  Created by wizet on 17/3/8.
//  Copyright © 2017年 wizet. All rights reserved.
//


#import "WZVariousCollectionBaseObject.h"
#import "WZVariousCollectionBaseCell.h"

@implementation WZVariousCollectionBaseObject
@synthesize cellType = _cellType;

+ (NSDictionary *)modelCustomPropertyMapper {
    return [NSDictionary dictionary];
}

- (void)setCellType:(NSString *)cellType {
    if ([cellType isKindOfClass:[NSString class]]) {
        _cellType = cellType;
    } else {
        _cellType = NSStringFromClass([WZVariousCollectionBaseCell class]);
    }
}

- (NSString *)cellType {
    if (!_cellType) {
        _cellType = NSStringFromClass([WZVariousCollectionBaseCell class]);
    }
    return _cellType;
}

@end
