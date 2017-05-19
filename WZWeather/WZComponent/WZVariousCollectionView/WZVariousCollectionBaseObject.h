//
//  WZVariousCollectionBaseObject.h
//  WZWeather
//
//  Created by wizet on 17/3/8.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WZVariousCollectionBaseCell;
/**
 *  数据object
 */

@interface WZVariousCollectionBaseObject : NSObject

@property (nonatomic, copy) NSString * cellType;
@property (nonatomic, assign) BOOL isLastElement;

+ (NSDictionary *)modelCustomPropertyMapper;//yymodel

@end
