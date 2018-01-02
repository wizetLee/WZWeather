//
//  WZBaseAlert.h
//  WZAlert
//
//  Created by Wizet on 16/10/14.
//  Copyright © 2016年 Wizet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WZAlertDipalyDismissType) {
    WZAlertDipalyDismissTypeGleamingly = 0,
    WZAlertDipalyDismissTypeFromBottomToTop = 1,
    WZAlertDipalyDismissTypeFromTopToBottom = 2,
};

@interface WZBaseAlert : UIView

/**
 *
 *
 */
//显示  移除动画处理
@property (nonatomic, strong) void (^keyboardHeightBlock) (CGFloat keyboardHeight);
//键盘block(出现或者回收键盘的时候调用block处理view的位置关系)

@property (nonatomic,   weak) UIWindow *forefrontWindow;              //最前方window
@property (nonatomic, strong) UIView *bgAnimatedView;               //动画层 载物层
@property (nonatomic, strong) UIView *tapView;                      //点击回收层
@property (nonatomic, strong) UIView *bgView;                       //背景颜色层


@property (nonatomic, assign) WZAlertDipalyDismissType displayType; //显示移除alert方式
@property (nonatomic, assign) BOOL clickedBackgroundToDismiss;      //true:点击背景回收alert

- (void)alertShow;                                                  //show alert
- (void)alertDismissWithAnimated:(BOOL)animated;                    //remove alert

- (instancetype)initWithDispalyType:(WZAlertDipalyDismissType)displayType;

// 定制alert 内容
- (void)alertContent NS_REQUIRES_SUPER;                             //initialize subviews

@end
