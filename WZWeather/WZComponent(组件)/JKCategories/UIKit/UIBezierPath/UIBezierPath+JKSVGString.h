//
//  UIBezierPath+JKSVGString.h
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 14/12/30.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (JKSVGString)
/**
 *  @brief  UIBezierPath转成SVG
 *
 *  @return SVG
 * （可缩放矢量图形）可缩放矢量图形是基于可扩展标记语言（标准通用标记语言的子集），用于描述二维矢量图形的一种图形格式。它由万维网联盟制定，是一个开放标准。
 */
- (NSString*)jk_SVGString;
@end
