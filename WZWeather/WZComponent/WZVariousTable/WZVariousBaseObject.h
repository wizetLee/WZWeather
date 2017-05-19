//
//  WZVariousBaseObject.h
//  WZVariousTable
//
//  Created by wizet on 17/3/3.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class WZVariousBaseCell; //默认cellType

/**
 *  数据object
 */

@interface WZVariousBaseObject : NSObject

@property (nonatomic, assign) BOOL isLastElement;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) BOOL cellHeightVariable;  //考虑需求需要更改cell高度的情况
@property (nonatomic, copy) NSString *cellType;

+ (NSDictionary *)modelCustomPropertyMapper;//yymodel

@end
