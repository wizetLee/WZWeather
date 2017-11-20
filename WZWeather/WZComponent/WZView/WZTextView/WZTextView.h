//
//  WZTextView.h
//  WZTextView
//
//  Created by admin on 16/10/18.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZCustomTextView : UITextView

@end

@interface WZTextView : UIView

@property (nonatomic, strong) void (^keyboardHeightBlock)(CGFloat keyboardHeight);
@property (nonatomic, strong) void (^textLengthOverBlock)(NSUInteger textLength);       //字数达到上限才会被调用
@property (nonatomic, strong) void (^textViewTextBlock)(NSString *text);                //有字符串变化就会被调用

@property (nonatomic, strong) WZCustomTextView *textView;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;                                             // placeholder 和 text字体一样大
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) NSUInteger textLength;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, assign) BOOL downKeyboard;

- (instancetype)initWithFrame:(CGRect)frame textViewEdgeInsets:(UIEdgeInsets)textViewEdgeInsets;
- (void)vitalizePlaceholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor;
- (void)vitalizeTipsLabelFont:(UIFont *)font textColor:(UIColor *)textColor;
- (void)viatlizeTipsLabelText:(NSString *)text;

@end

