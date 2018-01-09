//
//  WZPageControlThrobItem.m
//  WZWeather
//
//  Created by wizet on 9/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZAnimatePageControlThrobItem.h"

@interface WZAnimatePageControlThrobItem()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *headlineLable;//位于视图之外

@end

@implementation WZAnimatePageControlThrobItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.yellowColor;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (!_imageView) {
        _imageView = UIImageView.alloc.init;
        [self addSubview:_imageView];
        
        _headlineLable = UILabel.alloc.init;
        _headlineLable.font = [UIFont boldSystemFontOfSize:15.0];
        _headlineLable.textColor = [UIColor colorWithRed:200 / 255.0 green:206 / 255.0 blue:200 / 255.0 alpha:1.0];
        _headlineLable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_headlineLable];
//        200 206 200 -> 0.0 0.0 0.0
    }
    _imageView.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
    
    CGFloat labelW = _imageView.frame.size.width * 2;
    _headlineLable.frame = CGRectMake(0.0, _imageView.frame.size.height + 10.0, labelW, 18.0);
    _headlineLable.center = CGPointMake(self.frame.size.width / 2.0, _headlineLable.center.y);
}

//0~1
- (void)setScale:(CGFloat)scale {
    if (scale < 0) {
        scale = 0;
    } else if (scale > 1) {
        scale = 1;
    }
    
    //比例
    _imageView.transform = CGAffineTransformMakeScale(scale, scale);
    //颜色
    _headlineLable.textColor = [UIColor colorWithRed:200 / 255.0 * scale green:206 / 255.0 * scale blue:200 / 255.0 * scale alpha:1.0];
    //字体
    _headlineLable.font = [UIFont boldSystemFontOfSize:15.0 + (1 - scale) * 5];
    //position
    _headlineLable.transform = CGAffineTransformMakeTranslation(0.0, (1 - scale) * 20.0);
}

@end
