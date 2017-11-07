//
//  WZBaseAlert.m
//  WZAlert
//
//  Created by Wizet on 16/10/14.
//  Copyright © 2016年 Wizet. All rights reserved.
//

#import "WZBaseAlert.h"
@interface WZBaseAlert()

@end

@implementation WZBaseAlert

- (instancetype)initWithDispalyType:(WZAlertDipalyDismissType)displayType {
    self = [super init];
    if (self) {
        _displayType = displayType;
        [self configureNotification];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _displayType = 0;
        [self configureNotification];
    }
    return self;
}

- (void)configureNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDispaly{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    _forefrontWindow = [self getFrontWindow];
    if (_forefrontWindow) {
        [_forefrontWindow addSubview:self];
        [self addSubview:self.bgView];
        [self addSubview:self.bgAnimatedView];
        [self alertContent];                //子类继承后在这里写入显示出来的alert的内容以及配置bgView颜色
//        [self configureDelegate];           //代理
        [self viewStatusBeforeAnimate];     //配置动画开始前的状态
        [self animateAction];               //配置动画动作
    }
}

- (UIWindow *)getFrontWindow {
    UIWindow *frontWindow = nil;
    NSEnumerator *frontToBackWindows = [[UIApplication sharedApplication].windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL isWindowOnMainScreen = (window.screen == [UIScreen mainScreen]);       //当前屏幕
        BOOL isWindowVisible = (!window.hidden && window.alpha > 0.001);            //透明度
        BOOL isWindowNormalLevel = (window.windowLevel == UIWindowLevelNormal);     //window level
        if (isWindowOnMainScreen && isWindowVisible && isWindowNormalLevel) {
            frontWindow = window;
        }
    }
    if (!frontWindow) {
        frontWindow = [UIApplication sharedApplication].windows.lastObject;
    }
    return frontWindow;
}

// custom in subclass
- (CGFloat)bgViewAlpha {
    return 0.4;
}

- (CGFloat)finishAnimationTime {
    return 0.5;
}

- (CGFloat)beginAnimationTime {
    return 0.75;
}

- (UIColor *)alertBackgroundViewColor {
    return [UIColor blackColor];
}

- (void)alertContent {}

- (void)viewStatusBeforeAnimate {//动画前的位置
    switch (_displayType) {
        case WZAlertDipalyDismissTypeFromTopToBottom:
        {
            self.bgAnimatedView.frame = CGRectMake(0, -[UIScreen mainScreen].bounds.size.height, self.bgAnimatedView.bounds.size.width, self.bgAnimatedView.bounds.size.height);
            self.bgView.alpha = 0.0;
        }
            break;
            
        case WZAlertDipalyDismissTypeFromBottomToTop:
        {
            self.bgAnimatedView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.bgAnimatedView.bounds.size.width, self.bgAnimatedView.bounds.size.height);
            self.bgView.alpha = 0.0;
        }
            break;
        
        case WZAlertDipalyDismissTypeGleamingly:
        {
            self.bgAnimatedView.frame = CGRectMake(0, 0, self.bgAnimatedView.bounds.size.width, self.bgAnimatedView.bounds.size.height);
            self.bgAnimatedView.alpha = 0.0;
            self.bgView.alpha = 0.0;
        }
            break;
            
        default:{
            self.bgAnimatedView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.bgAnimatedView.bounds.size.width, self.bgAnimatedView.bounds.size.height);
        }
            break;
    }
}

- (void)animateAction { //动画到达的位置
    [UIView animateWithDuration:[self beginAnimationTime] delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        switch (_displayType) {
            case WZAlertDipalyDismissTypeFromTopToBottom || WZAlertDipalyDismissTypeFromBottomToTop:
            {
                self.bgAnimatedView.frame = CGRectMake(0, 0, self.bgAnimatedView.bounds.size.width, self.bgAnimatedView.bounds.size.height);
            }
                break;
            case WZAlertDipalyDismissTypeGleamingly:
            {
                self.bgAnimatedView.alpha = 1.0;
               
            }
                break;
                
            default:{
                self.bgAnimatedView.frame = CGRectMake(0, 0.0, self.bgAnimatedView.bounds.size.width, self.bgAnimatedView.bounds.size.height);
            }
                break;
        }
        self.bgView.alpha = [self bgViewAlpha];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)alertShow {
   [self viewDispaly];
}

- (void)alertDismissWithAnimated:(BOOL)animated {//结束动画的位置
    if (animated) {
        [UIView animateWithDuration:[self finishAnimationTime] animations:^{
            //移除前的动画（做成枚举呈现不同的动画）
            
            switch (_displayType) {
                case WZAlertDipalyDismissTypeFromTopToBottom:
                {
                    self.bgAnimatedView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.bgAnimatedView.bounds.size.width, self.bgAnimatedView.bounds.size.height);
                    self.bgView.alpha = 0.0;
                }
                    break;
                    
                case WZAlertDipalyDismissTypeGleamingly:
                {
                    self.bgAnimatedView.alpha = 0.0;
                    self.bgView.alpha = 0.0;
                }
                    break;
                    
                default:{
                    self.bgAnimatedView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.bgAnimatedView.bounds.size.width, self.bgAnimatedView.bounds.size.height);
                    self.bgView.alpha = 0.0;
                }                    
                    break;
            }
            
        } completion:^(BOOL finished) {
            [self removeSelf];
        }];
    } else {
        [self removeSelf];
    }
}

- (void)removeSelf {
    [[self class] removeAllSubviews:self.bgView];
    [[self class] removeAllSubviews:self.bgAnimatedView];
    [[self class] removeAllSubviews:self];
    [self removeFromSuperview];
}

+ (void)removeAllSubviews:(UIView *)view {
    while (view.subviews.count) {
        UIView* child = view.subviews.lastObject;
        [child removeFromSuperview];
    }
}


- (void)clikedbgAnimatedView:(UITapGestureRecognizer *)tap {
    if (_clickedBackgroundToDismiss) {
        [self alertDismissWithAnimated:true];
    }
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    if ([view isKindOfClass:[UIView class]]) {
        if (view != self.bgAnimatedView && view != self.bgView) {
            if (![self.bgAnimatedView.subviews containsObject:view]) {
                [self.bgAnimatedView addSubview:view];
                //                NSLog(@"self.bgAnimatedView 不存在该view");
            } else {
                //                NSLog(@"self.bgAnimatedView 存在该view");
            }
        } else {
            if (![self.subviews containsObject:view]) {
                [self addSubview:view];
                //                NSLog(@"self 不存在该view");
            } else {
                //                NSLog(@"self 存在该view");
            }
        }
    }
}

#pragma mark setter & getter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColor = [self alertBackgroundViewColor];
    }
    return _bgView;
}

- (UIView *)bgAnimatedView {
    if (!_bgAnimatedView) {
        _bgAnimatedView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bgAnimatedView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.tapView];
    }
    return _bgAnimatedView;
}

- (UIView *)tapView {
    if (!_tapView) {
        _tapView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _tapView.backgroundColor = [UIColor clearColor];
    }
    return _tapView;
}

- (void)setClickedBackgroundToDismiss:(BOOL)clickedBackgroundToDismiss {
    _clickedBackgroundToDismiss = clickedBackgroundToDismiss;
    if (self.tapView) {
        if (clickedBackgroundToDismiss) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clikedbgAnimatedView:)];
            [_tapView addGestureRecognizer:tap];
        }
    }
}


#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    CGFloat KBHeight = [self getKeyboardHeightFromNotification:aNotification];
    if (self.keyboardHeightBlock) {
        self.keyboardHeightBlock(KBHeight);
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    if (self.keyboardHeightBlock) {
        self.keyboardHeightBlock(0.0);//回收键盘
    }
    
}

- (CGFloat)getKeyboardHeightFromNotification:(NSNotification *)notification {
    CGFloat KBHeight = 0.0;
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    if (aValue) {
        CGRect keyboardRect = [aValue CGRectValue];
        KBHeight = keyboardRect.size.height;
    }
    return KBHeight;
}

@end
