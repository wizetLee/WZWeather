//
//  WZScrollOptions.h
//  WZWeather
//
//  Created by wizet on 2017/7/1.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZScrollOptions;

@protocol WZProtocolScrollOptions <NSObject>

- (void)scrollOptions:(WZScrollOptions *)scrollOptions clickedAtIndex:(NSInteger)index;

@end

///标题 选取 控件
@interface WZScrollOptions : UIScrollView

@property (nonatomic, weak) id <WZProtocolScrollOptions> scrollOptionsDelegate;//代理
@property (nonatomic, strong) NSArray *titleArray;//title
@property (nonatomic, assign, readonly) NSInteger currentIndex;//当前选择的角标
@property (nonatomic, assign) CGFloat animationTime;//移动动画的事件
@property (nonatomic, strong) UIColor *selectedTextColor;//选中颜色
@property (nonatomic, strong) UIColor *normalTextColor;//normal颜色
@property (nonatomic, strong) UIFont *textFont;//title的字体
@property (nonatomic, strong) UIColor *traceLineColor;//底部线条的颜色

//选择的角标
- (void)selectedIndex:(NSInteger)index;

@end
