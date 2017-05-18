//
//  WZVariousBaseObject.m
//  WZVariousTable
//
//  Created by admin on 17/3/3.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVariousBaseObject.h"
#import "WZVariousBaseCell.h"

@implementation WZVariousBaseObject
@synthesize cellType = _cellType;

+ (NSDictionary *)modelCustomPropertyMapper {
    return [NSDictionary dictionary];
}

- (void)setCellType:(NSString *)cellType {
    if ([cellType isKindOfClass:[NSString class]]) {
        _cellType = cellType;
    } else {
        _cellType = NSStringFromClass([WZVariousBaseCell class]);
    }
}

- (NSString *)cellType {
    if (!_cellType) {
        _cellType = NSStringFromClass([WZVariousBaseCell class]);
    }
    return _cellType;
}

@end
