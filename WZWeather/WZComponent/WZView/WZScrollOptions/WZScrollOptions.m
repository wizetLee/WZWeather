//
//  WZScrollOptions.m
//  WZWeather
//
//  Created by wizet on 2017/7/1.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZScrollOptions.h"

@interface WZScrollOptions()

@property (nonatomic, strong) NSMutableArray <UIButton *>*buttonArray;
@property (nonatomic, strong) UIView *traceLineView;
@property (nonatomic, strong) UIButton *buttonP;
@property (nonatomic, assign) CGFloat gap;
@property (nonatomic, assign) CGFloat traceH;

@end

@implementation WZScrollOptions

@synthesize selectedTextColor = _selectedTextColor;
@synthesize normalTextColor = _normalTextColor;
@synthesize traceLineColor = _traceLineColor;
@synthesize textFont = _textFont;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    self.showsHorizontalScrollIndicator = false;
    _currentIndex = 0;
    _animationTime = 0.3;
    _gap = 10.0;
    _traceLineView = [[UIView alloc]init];
    _traceH = 2.0;
    _traceLineView.frame = CGRectMake(0
                                      , self.frame.size.height - _traceH
                                      , 0
                                      , _traceH);
    _traceLineView.backgroundColor = self.traceLineColor;
}

- (void)selectedIndex:(NSInteger)index {
    
    if (_titleArray.count && index > _titleArray.count - 1) {
        index = _titleArray.count - 1;
    }
    _currentIndex = index;
    UIButton *button = [self viewWithTag:index];
    if ([button isKindOfClass:[UIButton class]]) {
        [self clickedBtn:button];
    }
}

#pragma mark - 点击事件
- (void)clickedBtn:(UIButton *)sender{
    _currentIndex = sender.tag;
    [self modifyStatus:sender];

    if (self.contentSize.width > self.width) {
        CGFloat offsetX = 0.0;
        
        if (sender.centerX > self.width / 2.0
            && sender.centerX < self.contentSize.width - self.width / 2.0) {
            offsetX = sender.centerX - self.width / 2.0;//居中
        } else if (sender.centerX <= self.width / 2.0){
            offsetX = 0.0;
        } else {
            offsetX = self.contentSize.width - self.width;
        }
        
        [UIView animateWithDuration:_animationTime animations:^{
             self.contentOffset = CGPointMake(offsetX, 0);
            _traceLineView.width = [sender.titleLabel sizeThatFits:CGSizeMake(0, 0)].width;
            _traceLineView.centerX = sender.centerX;
        }];
    }
    
    // 代理
    if ([self.scrollOptionsDelegate respondsToSelector:@selector(scrollOptions:clickedAtIndex:)]) {
        [self.scrollOptionsDelegate scrollOptions:self clickedAtIndex:(sender.tag)];
    }
}

//修改选中状态
- (void)modifyStatus:(UIButton *)button {
    if (button) {
        [_buttonP setTitleColor:self.normalTextColor forState:UIControlStateNormal];
        _buttonP.layer.affineTransform = CGAffineTransformIdentity;
        _buttonP = button;
        [_buttonP setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
        _buttonP.layer.affineTransform = CGAffineTransformScale(_buttonP.layer.affineTransform, 0.9, 0.9);
    }
}

#pragma mark - Accessor
- (void)setTitleArray:(NSArray *)titleArray{
    
    if (![titleArray isKindOfClass:[NSArray class]]) {
        return;
    }
    
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    [self.buttonArray removeAllObjects];
    
    _titleArray = titleArray;
    
    if (_titleArray.count) {
        __block CGFloat btnX = 0.0;
        CGFloat gap = _gap;
        
        [_titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIButton *button = [[UIButton alloc] init];
            [self.buttonArray addObject:button];
            [self addSubview:button];
            button.tag = idx;
            [button.titleLabel setFont:self.textFont];
            [button setTitleColor:self.normalTextColor forState:UIControlStateNormal];
            [button setTitle:obj forState:UIControlStateNormal];
            [button addTarget:self
                       action:@selector(clickedBtn:)
             forControlEvents:UIControlEventTouchUpInside];
            [button sizeToFit];
            button.frame = CGRectMake(btnX
                                      , button.frame.origin.y
                                      , CGRectGetWidth(button.frame)
                                      , CGRectGetHeight(self.frame)) ;
            //位置调整
            btnX = btnX + button.frame.size.width + gap;
            
            //内容size 大于 self.width
            if (idx == 0) {
                [self modifyStatus:button];
                [self addSubview:_traceLineView];
                _traceLineView.width = [button.titleLabel sizeThatFits:CGSizeMake(0, 0)].width;
                _traceLineView.centerX = button.centerX;
            }
        }];
        
        self.contentSize = CGSizeMake(CGRectGetMaxX(self.buttonArray.lastObject.frame)
                                      , CGRectGetHeight(self.frame));
        
         //内容size 小于 self.width
        if (self.contentSize.width < self.frame.size.width) {
            //均分宽度
            CGFloat buttonW = self.frame.size.width / _titleArray.count;
            for (int i = 0; i < self.buttonArray.count; i++) {
                UIButton *button = self.buttonArray[i];
                button.frame = CGRectMake(i * buttonW
                                          , button.frame.origin.y
                                          , buttonW
                                          , CGRectGetHeight(button.frame));
                
                if (i == 0) {
                    _traceLineView.width = [button.titleLabel sizeThatFits:CGSizeMake(0, 0)].width;
                    _traceLineView.centerX = button.centerX;
                }
            }
        }
    }
}

- (UIColor *)normalTextColor {
    if (!_normalTextColor) {
        _normalTextColor = [UIColor colorWithRed:51.0 / 255.0 green:51.0 / 255.0 blue:51.0 / 255.0 alpha:1.0];
    }
    return _normalTextColor;
}

- (void)setNormalTextColor:(UIColor *)normalTextColor {
    if (![normalTextColor isKindOfClass:[UIColor class]]) {return;}
    _normalTextColor = normalTextColor;
    for (UIButton *button in self.buttonArray) {
        if (button == _buttonP) {continue;}
        [button setTitleColor:normalTextColor forState:UIControlStateNormal];
    }
}

- (UIColor *)selectedTextColor {
    if (!_selectedTextColor) {
        _selectedTextColor = [UIColor colorWithRed:255.0 / 255.0 green:215.0 / 255.0 blue:0.0 alpha:1.0];
    }
    return _selectedTextColor;
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    if (![selectedTextColor isKindOfClass:[UIColor class]]) {return;}
    _selectedTextColor = selectedTextColor;
    [_buttonP setTitleColor:selectedTextColor forState:UIControlStateNormal];
}

- (UIFont *)textFont {
    if (!_textFont) {
        _textFont = [UIFont systemFontOfSize:14];
    }
    return _textFont;
}

- (void)setTextFont:(UIFont *)textFont {
    if (![textFont isKindOfClass:[UIFont class]]) {return;}
    _textFont = textFont;
    
    if (_titleArray.count) {
        [self setTitleArray:self.titleArray];
        [self selectedIndex:_currentIndex];
    }
}

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

- (UIColor *)traceLineColor {
    if (!_traceLineColor) {
        _traceLineColor = self.selectedTextColor;
    }
    return _traceLineColor;
}

- (void)setTraceLineColor:(UIColor *)traceLineColor {
    if (![traceLineColor isKindOfClass:[UIColor class]]) {return;}
    _traceLineColor = traceLineColor;
    _traceLineView.backgroundColor = traceLineColor;
}


@end
