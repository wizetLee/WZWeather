//
//  WZRoundRenderLayer.h
//  WZBaseRoundSelector
//
//  Created by wizet on 17/3/28.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@protocol WZRoundRenderLayerDelegate <NSObject>

/**
 *
 *  @param currentPoint : bezier path current point
 */
- (void)renderPathCurrentPoint:(CGPoint)currentPoint;

@end


/**
 *   始终在－PI / 2.0 处绘制   只负责绘制
 */
@interface WZRoundRenderLayer : CALayer

@property (nonatomic, assign) double renderAngle;//范围 0 ~ M_PI * 2.0

@property (nonatomic, weak) id<WZRoundRenderLayerDelegate> renderLayerDelegate;

- (instancetype)initWithCircleRadius:(CGFloat)circleRadius layerLineWidth:(CGFloat)layerLineWidth;


@end
