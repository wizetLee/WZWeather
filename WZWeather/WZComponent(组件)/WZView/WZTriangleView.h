//
//  WZTriangleView.h
//  WZSettingPicker
//
//  Created by wizet on 16/12/26.
//  Copyright © 2016年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZTriangleView : UIView

/**
 *  三角形默认是等腰三角形而且撑满整个view
 *  可以通过一个vertical point offsetX来更改垂点
 */

@property (nonatomic, strong) UIColor *bgColor;             //三角色
@property (nonatomic, strong) CAShapeLayer *triangleLayer;  //三角layer
@property (nonatomic, assign) CGFloat verticalPointOffsetX; //垂点偏移设置

@end
