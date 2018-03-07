//
//  WZPageControlThrobItem.h
//  WZWeather
//
//  Created by wizet on 9/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZAnimatePageControlThrobItem : UIView

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *headlineLable;//位于视图之外

- (void)setScale:(CGFloat)scale;

@end
