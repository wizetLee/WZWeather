//
//  WZMediaConfigCell.m
//  WZWeather
//
//  Created by admin on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaConfigCell.h"
#import "WZMediaConfigObject.h"



@interface WZMediaConfigCell()

@property (nonatomic, strong) UILabel *healineLabel;

@property (nonatomic, strong) UIButton *buttonLeft;
@property (nonatomic, strong) UIButton *buttonMid;
@property (nonatomic, strong) UIButton *buttonRight;
@property (nonatomic,   weak) UIButton *buttonP;

@end

@implementation WZMediaConfigCell

+ (CGFloat)heightForData:(WZVariousBaseObject *)obj {
    
    return 60.0;
}


//for code
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createView];
    }
    return self;
}

- (void)createView {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    CGFloat viewH = [[self class] heightForData:nil];
    CGFloat viewW = WZMediaConfigCellWidth / 2.0;
    CGFloat gap = 5.0;
    _healineLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0 + gap, (viewH - 44.0) / 2.0, viewW, 44.0)];
    _healineLabel.backgroundColor = [UIColor blueColor];
    _healineLabel.text = @"标题";
    [self.contentView addSubview:_healineLabel];
    

    viewW = ((WZMediaConfigCellWidth / 2.0) - 5 * gap) / 3.0;
    _buttonLeft = [[UIButton alloc] initWithFrame:CGRectMake(_healineLabel.maxX + gap, (viewH - 44.0) / 2.0, viewW, 44.0)];
    _buttonMid = [[UIButton alloc] initWithFrame:CGRectMake(_buttonLeft.maxX + gap, (viewH - 44.0) / 2.0, viewW, 44.0)];
    _buttonRight = [[UIButton alloc] initWithFrame:CGRectMake(_buttonMid.maxX + gap, (viewH - 44.0) / 2.0, viewW, 44.0)];
    
    [self.contentView addSubview:_buttonLeft];
    [self.contentView addSubview:_buttonMid];
    [self.contentView addSubview:_buttonRight];
    _buttonLeft.backgroundColor = [UIColor redColor];
    _buttonMid.backgroundColor = [UIColor greenColor];
    _buttonRight.backgroundColor = [UIColor blueColor];
    [_buttonLeft setTitleColor:[UIColor magentaColor] forState:UIControlStateSelected];
    [_buttonMid setTitleColor:[UIColor magentaColor] forState:UIControlStateSelected];
    [_buttonRight setTitleColor:[UIColor magentaColor] forState:UIControlStateSelected];
    [_buttonLeft addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonMid addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
	[_buttonRight addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _buttonRight.selected = false;
    _buttonLeft.selected = false;
    _buttonMid.selected = false;
    if ([self.data isKindOfClass:[WZMediaConfigObject class]]) {
        WZMediaConfigObject *tmpData = (WZMediaConfigObject *)self.data;
        _healineLabel.text =  tmpData.headline;
        if (tmpData.type == 1) {
            if (tmpData.selectedType == WZMediaConfigType_canvas_1_multiply_1) {
                _buttonP = _buttonLeft;
            } else if (tmpData.selectedType == WZMediaConfigType_canvas_3_multiply_4) {
                _buttonP = _buttonMid;
            } else if (tmpData.selectedType == WZMediaConfigType_canvas_9_multiply_16) {
                _buttonP = _buttonRight;
            }
            _buttonLeft.tag = WZMediaConfigType_canvas_1_multiply_1;
            _buttonMid.tag = WZMediaConfigType_canvas_3_multiply_4;
            _buttonRight.tag = WZMediaConfigType_canvas_9_multiply_16;
            [_buttonLeft setTitle:@"1:1" forState:UIControlStateNormal];
            [_buttonMid setTitle:@"3:4" forState:UIControlStateNormal];
            [_buttonRight setTitle:@"9:16" forState:UIControlStateNormal];
        } else if (tmpData.type == 2) {
            
            if (tmpData.selectedType == WZMediaConfigType_flash_auto) {
                _buttonP = _buttonLeft;
            } else if (tmpData.selectedType == WZMediaConfigType_flash_off) {
                _buttonP = _buttonMid;
            } else if (tmpData.selectedType == WZMediaConfigType_flash_on) {
                _buttonP = _buttonRight;
            }
            _buttonLeft.tag = WZMediaConfigType_flash_auto;
            _buttonMid.tag = WZMediaConfigType_flash_off;
            _buttonRight.tag = WZMediaConfigType_flash_on;
            [_buttonLeft setTitle:@"自动" forState:UIControlStateNormal];
            [_buttonMid setTitle:@"关闭" forState:UIControlStateNormal];
            [_buttonRight setTitle:@"开启" forState:UIControlStateNormal];
        } else if (tmpData.type == 3) {
            if (tmpData.selectedType == WZMediaConfigType_countDown_10) {
                _buttonP = _buttonLeft;
            } else if (tmpData.selectedType == WZMediaConfigType_countDown_3) {
                _buttonP = _buttonMid;
            } else if (tmpData.selectedType == WZMediaConfigType_countDown_off) {
                _buttonP = _buttonRight;
            }
            _buttonLeft.tag = WZMediaConfigType_countDown_10;
            _buttonMid.tag = WZMediaConfigType_countDown_3;
            _buttonRight.tag = WZMediaConfigType_countDown_off;
            [_buttonLeft setTitle:@"10s" forState:UIControlStateNormal];
            [_buttonMid setTitle:@"3s" forState:UIControlStateNormal];
            [_buttonRight setTitle:@"关闭" forState:UIControlStateNormal];
        }
    }
    _buttonP.selected = true;
   
}

- (void)clickedBtn:(UIButton *)sender {
    if ([self.data isKindOfClass:[WZMediaConfigObject class]]) {
        WZMediaConfigObject *tmpData = (WZMediaConfigObject *)self.data;
        _buttonP.selected = false;
        tmpData.selectedType = sender.tag;
        _buttonP = sender;
        _buttonP.selected = true;
        if ([self.variousViewDelegate respondsToSelector:@selector(variousView:param:)]) {
            [self.variousViewDelegate variousView:sender param:@{@"WZMediaConfigType":@(tmpData.selectedType)}];
        }
    }
}


@end
