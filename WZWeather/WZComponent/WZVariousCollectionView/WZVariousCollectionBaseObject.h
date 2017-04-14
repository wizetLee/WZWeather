//
//  WZVariousCollectionBaseObject.h
//  SUPEPRO
//
//  Created by admin on 17/3/8.
//  Copyright © 2017年 jerry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZVariousCollectionBaseCell.h"
/**
 *  数据object
 */

@interface WZVariousCollectionBaseObject : NSObject

@property (nonatomic, copy) NSString * cellType;
@property (nonatomic, assign) BOOL isLastElement;

+ (NSDictionary *)modelCustomPropertyMapper;//yymodel

@end
