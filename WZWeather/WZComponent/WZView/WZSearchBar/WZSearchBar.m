//
//  WZSearchBar.m
//  WZSearchBar
//
//  Created by admin on 16/10/19.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "WZSearchBar.h"
#define MonitorTextKey @"text"


@interface WZSearchBar()<UISearchBarDelegate>

@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation WZSearchBar

#pragma mark
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configViews];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configViews {
    self.barTintColor = [UIColor lightGrayColor];
    //禁用clear button
    [self.textField setClearButtonMode:UITextFieldViewModeNever];
    self.useClearBtn = true;
    self.clearButton.hidden = true;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
}

#pragma mark 监听
- (void)textChanged:(NSNotification *)notification {
    //    NSLog(@"%@", notification);
    if (notification.object == self.textField) {
        if ([self.text isEqualToString:@""]
            || self.textField == nil) {
            self.clearButton.hidden = true;
        } else {
            self.clearButton.hidden = false;
        }
    }
}

#pragma mark setter & getter

- (void)setUseClearBtn:(BOOL)useClearBtn {
    _useClearBtn = useClearBtn;
    [self addSubview:self.clearButton];
    self.clearButton.hidden = !useClearBtn;
}

- (UITextField *)textField {
    if (!_textField) {
        for (UIView *view in self.subviews) {
            for (UIView *subview in view.subviews) {
                if ([subview isKindOfClass:[UITextField class]]) {
                    _textField = (UITextField *)subview;
                }
            }
        }
        
        if (!_textField) {
            _textField = [self valueForKey:@"searchField"];
        }
        
        if (!_textField) {
            _textField = [self valueForKey:@"_searchField"];
        }
        
        if (_textField) {
            UIView *barImageView = [[[self.subviews firstObject] subviews] firstObject];
            barImageView.layer.borderColor = [UIColorFromRGB(0xfafafa) CGColor];
            //去除上下两条黑色线段
            barImageView.layer.borderWidth = 1;
        }
        
    }
    return _textField;
}

#pragma mark 自定义 clear button
- (UIButton *)clearButton {
    if (!_clearButton) {
        CGFloat btnHW = 19.0;
        CGFloat btnRight = 5.5;
        _clearButton = [[UIButton alloc] initWithFrame:CGRectMake(ceil(self.frame.size.width - btnHW - btnRight) + 1
                                                                  , ceil((self.frame.size.height - btnHW) / 2.0) - 0.5
                                                                  , btnHW
                                                                  , btnHW)];
        
        [_clearButton setImage:[UIImage imageNamed:@"home_icon_searchBar_delete"] forState:UIControlStateNormal];
        [self addSubview:_clearButton];
        [_clearButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

- (void)clickedBtn:(UIButton *)sender {
    self.clearButton.hidden = true;
    if (sender == self.clearButton) {
        self.text = nil;
        if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
            [self.delegate searchBar:self textDidChange:self.text];
        }
        if (_clickedClearButton) {
            _clickedClearButton();
        }
    }
}

- (void)setShowsBookmarkButton:(BOOL)showsBookmarkButton {
    [super setShowsBookmarkButton:showsBookmarkButton];
    [self clearButtonHidden:true];
}

- (void)clearButtonHidden:(BOOL)hidden {
    if (_clearButton) {
        _clearButton.hidden = hidden;
    }
}

//获取textField.frame  的大小再从新设定clearBtn de frame  目前展示hidden
- (void)setShowsCancelButton:(BOOL)showsCancelButton {
    [super setShowsCancelButton:showsCancelButton];
    [self clearButtonHidden:true];
}

- (void)setShowsSearchResultsButton:(BOOL)showsSearchResultsButton {
    [super setShowsSearchResultsButton:showsSearchResultsButton];
    [self clearButtonHidden:true];
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        for(UIView *view in  [[[self subviews] firstObject] subviews]) {
            if([view isKindOfClass:[UIButton class]]) {
                _cancelButton =(UIButton *)view;
            }
        }
    }
    return _cancelButton;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if ([backgroundColor isKindOfClass:[UIColor class]]) {
        self.barTintColor = backgroundColor;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textField.frame = CGRectMake(0, 0, self.width, self.height);
}


@end

