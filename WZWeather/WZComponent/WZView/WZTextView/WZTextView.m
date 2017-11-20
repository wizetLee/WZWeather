//
//  WZTextView.m
//  WZTextView
//
//  Created by admin on 16/10/18.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "WZTextView.h"

@implementation WZCustomTextView

- (instancetype)init {
    if (self = [super init]) {
        self.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);//刚好的贴边设置
        self.layer.masksToBounds = false;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
        self.layer.masksToBounds = false;
    }
    return self;
}

@end

@interface WZTextView()<UITextViewDelegate>
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UILabel *tipsLabel;
@end

@implementation WZTextView

- (instancetype)initWithFrame:(CGRect)frame textViewEdgeInsets:(UIEdgeInsets)textViewEdgeInsets
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.textView];
        _textView.frame = CGRectMake(textViewEdgeInsets.left
                                     , textViewEdgeInsets.top - 2
                                     , self.bounds.size.width - textViewEdgeInsets.left - textViewEdgeInsets.right
                                     , self.bounds.size.height - textViewEdgeInsets.top - textViewEdgeInsets.bottom + 4) ;
        _textLength = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHiden:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)vitalizePlaceholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor {
    
    if ([placeholderColor isKindOfClass:[UIColor class]]) {
        self.placeholderColor = placeholderColor;
    }
    
    if ([placeholder isKindOfClass:[NSString class]] && ![placeholder isEqualToString:@""]) {
        self.placeholder = placeholder;
    }
}

- (void)viatlizeTipsLabelText:(NSString *)text {
    if ([text isKindOfClass:[NSString class]]) {
        self.tipsLabel.text = text;
    }
}

//tips label 的 可变性的预测
- (void)vitalizeTipsLabelFont:(UIFont *)font textColor:(UIColor *)textColor {
    CGFloat tipsLabelH = 0.0;
    if (font && [font isKindOfClass:[UIFont class]]) {
        self.tipsLabel.font = font;
        tipsLabelH = font.lineHeight;
    }
    if (textColor && [textColor isKindOfClass:[UIColor class]]) {
        self.tipsLabel.textColor = textColor;
    }
    
    _tipsLabel.frame = CGRectMake(0, self.textView.bounds.size.height - 2 -  tipsLabelH + 2, self.textView.bounds.size.width, tipsLabelH);
    
}

#pragma mark setter & getter
- (WZCustomTextView *)textView {
    if (!_textView) {
        _textView = [[WZCustomTextView alloc] init];
        _textView.frame = CGRectZero;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.delegate = self;
        
    }
    return _textView;
}

- (UIColor *)placeholderColor {
    if (!_placeholderColor) {
        _placeholderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0f];
    }
    return _placeholderColor;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    if (placeholder && [placeholder isKindOfClass:[NSString class]] && ![placeholder isEqualToString:@""]) {
        self.textView.text = placeholder;
        self.textView.textColor = self.placeholderColor;
    } else {
        self.textView.textColor = self.textColor;
    }
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor blackColor];
        _textView.textColor = _textColor;
    }
    return _textColor;
}

- (void)setText:(NSString *)text {
    if(text != nil && [text isKindOfClass:[NSString class]] && text.length > 0) {
        self.textView.text = text;
        self.textView.textColor = self.textColor;
    }  else {
        self.textView.text = self.placeholder;
        self.textView.textColor = self.placeholderColor;
    }
    
    if (self.textViewTextBlock) {
        NSString *tmpStr = @"";
        if ([self.textView.text isEqualToString:self.placeholder]) {
            
        } else {
            tmpStr = self.textView.text;
        }
        self.textViewTextBlock(tmpStr);
    }
}

- (NSString *)text {
    return self.textView.text;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    if (font && [font isKindOfClass:[UIFont class]]) {
        self.textView.font = font;
    }
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.backgroundColor = [UIColor clearColor];
        _tipsLabel.textAlignment = NSTextAlignmentRight;
        CGFloat tipsLabelH = _tipsLabel.font.lineHeight;
        _tipsLabel.frame = CGRectMake(0, self.textView.bounds.size.height -  tipsLabelH + 2, self.textView.bounds.size.width, tipsLabelH);
        [self.textView addSubview:_tipsLabel];
    }
    return _tipsLabel;
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    if([textView.text isEqualToString:self.placeholder]) {
        textView.textColor = self.placeholderColor;
    } else {
        textView.textColor = self.textColor;
    }
    
    if (self.textViewTextBlock) {
        self.textViewTextBlock(textView.text);
    }
    
    if (_textLength != 0 && _textLength >= self.placeholder.length && _textLength <= textView.text.length) {
        textView.text = [textView.text substringToIndex:_textLength];
        if (self.textLengthOverBlock) {
            self.textLengthOverBlock(textView.text.length);
        }
        
        if (self.textViewTextBlock) {
            self.textViewTextBlock(textView.text);
        }
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if([textView.text isEqualToString:self.placeholder]) {
        textView.text = @"";
    }
    
    textView.textColor = self.textColor;
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""] || !textView.text) {
        textView.text = self.placeholder;
        textView.textColor = self.placeholderColor;
    }
}

//- (void)textViewDidEndEditing:(UITextView *)textView {
//    if([textView.text isEqualToString:@""] || textView.text == nil || [textView.text isEqualToString:self.placeholder]) {
//        textView.text = self.placeholder;
//        textView.textColor = self.placeholderColor;
//    }
//}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"] && !self.downKeyboard) {
        [textView resignFirstResponder];
        return false;
    }
    return true;
}

#pragma mark notification

-(void)keyBoardWillShow:(NSNotification *)notification {
    CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    if (self.keyboardHeightBlock) {
        self.keyboardHeightBlock(keyboardHeight);
    }
}

-(void)keyBoardWillHiden:(NSNotification *)notification {
    if (self.keyboardHeightBlock) {
        self.keyboardHeightBlock(0.0);
    }
}

/* 回调样板
 __weak typeof(self) weakSelf = self;
 _textView.keyboardHeightBlock = ^(CGFloat keyboradHeight){
 CGFloat selfViewY = 0;
 if (SCREEN_HEIGHT - (视图位置) < keyboradHeight) {
 selfViewY = - (keyboradHeight - (视图位置));
 } else if (keyboradHeight != 0) {
 selfViewY = 0;
 } else {
 selfViewY = -keyboradHeight;
 }
 [UIView animateWithDuration:0.25 animations:^{
 weakSelf.view.sup_y = selfViewY;
 }];
 };
 
 _textView.textViewTextBlock = ^(NSString *text) {
 if (text) {
 [weakSelf.textView viatlizeTipsLabelText:[NSString stringWithFormat:@"%ld/50",text.length]];
 }
 };
 
 _textView.textLengthOverBlock = ^(NSUInteger textLength) {
 [weakSelf.view sup_makeToast:@"内容长度不允许超过50"];
 };
 */
@end

