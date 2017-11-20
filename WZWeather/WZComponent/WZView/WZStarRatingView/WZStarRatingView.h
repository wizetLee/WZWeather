//
//  WZStarRatingView.h
//  WZStarRating
//
//  Created by admin on 16/10/31.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WZStarRatingViewType) {
    WZStarRatingViewTypeNormal              = 0,//
    WZStarRatingViewTypeWholeStar           = 1,//评分状态下星星选择模式 整个
    WZStarRatingViewTypeHalfStar            = 2,//                   半个
};

@interface WZStarRatingView : UIView
                                                                                    //评分状态时及时获取分值
@property (nonatomic, strong) void (^starRatingCurrentValueBlock)(double currentValue);

@property (nonatomic, assign) BOOL touchable;                                       //评分状态开启与否
@property (nonatomic, assign) double percentageValue;                               //评分的百分比（可自定义设置）
@property (nonatomic, assign) double currentValue;                                  //当前分值
@property (nonatomic, assign) double minValue;                                      //设置最小分值
@property (nonatomic, assign, readonly) double totalValue;                          //总分值
@property (nonatomic, assign) WZStarRatingViewType type;


- (instancetype)initWithFrame:(CGRect)frame starCount:(NSUInteger)starCount starSize:(CGSize)starSize spacing:(CGFloat)spacing totalValue:(NSUInteger)totalValue type:(WZStarRatingViewType)type;

- (void)vitalizeStarImage:(UIImage *)image;                                         //更改星星图案
- (void)vitalizeDarkStarImage:(UIImage *)image;

@end
