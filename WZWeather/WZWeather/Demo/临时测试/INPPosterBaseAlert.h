//
//  INPPosterBaseAlert.h
//  INPPosterView
//
//  Created by admin on 17/7/14.
//  Copyright © 2017年 INP. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, INPAlertDipalyDismissType) {
    INPAlertDipalyDismissTypeGleamingly = 0,
    INPAlertDipalyDismissTypeFromBottomToTop = 1,
    INPAlertDipalyDismissTypeFromTopToBottom = 2,
};

@interface INPPosterBaseAlert : UIView

/**
 *
 *
 */
//显示  移除动画处理
@property (nonatomic, strong) void (^keyboardHeightBlock) (CGFloat keyboardHeight);
//键盘block(出现或者回收键盘的时候调用block处理view的位置关系)

@property (nonatomic, weak)   UIView *forefrontWindow;              //最前方window
@property (nonatomic, strong) UIView *bgAnimatedView;               //动画层 载物层
@property (nonatomic, strong) UIView *tapView;                      //点击回收层
@property (nonatomic, strong) UIView *bgView;                       //背景颜色层


@property (nonatomic, assign) INPAlertDipalyDismissType displayType; //显示移除alert方式
@property (nonatomic, assign) BOOL clickedBackgroundToDismiss;      //true:点击背景回收alert

- (void)alertShow;                                                  //show alert
- (void)alertDismissWithAnimated:(BOOL)animated;                    //remove alert

- (instancetype)initWithDispalyType:(INPAlertDipalyDismissType)displayType;

// 定制alert 内容
- (void)alertContent;                             //initialize subviews

@end
