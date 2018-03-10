//
//  WZVideoPickerCell.m
//  WZWeather
//
//  Created by admin on 1/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVideoPickerCell.h"

@interface WZVideoPickerCell()



@end

@implementation WZVideoPickerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        CGFloat h = 22.0;
        _headlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, self.bounds.size.height - h, self.bounds.size.width, h)];
        _headlineLabel.text = @"";
        _headlineLabel.textColor = UIColor.whiteColor;
        _headlineLabel.font = [UIFont systemFontOfSize:12];
        _headlineLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_headlineLabel];
        _headlineLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
       
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, self.bounds.size.height - h * 2.0, self.bounds.size.width, h)];
        _sizeLabel.text = @"";
        _sizeLabel.font = [UIFont systemFontOfSize:12];
        _sizeLabel.textColor = UIColor.whiteColor;
        _sizeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_sizeLabel];
        _sizeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];

        [self.contentView addSubview:self.selectButton];
        
        
        _sequenceLabel = [[UILabel alloc] init];
        _sequenceLabel.frame = CGRectMake(0.0, 0.0, h * 2, h);
        _sequenceLabel.layer.cornerRadius = h / 2.0;
        _sequenceLabel.layer.masksToBounds = true;
        _sequenceLabel.text = @"";
        _sequenceLabel.textColor = UIColor.blackColor;
        _sequenceLabel.font = [UIFont systemFontOfSize:12];
        _sequenceLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_sequenceLabel];
        _sequenceLabel.backgroundColor = [UIColor.orangeColor colorWithAlphaComponent:0.75];
        self.clipsToBounds = true;
        
        
        _maskLayer = [CALayer layer];
        _maskLayer.frame = self.bounds;
        _maskLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
        _maskLayer.hidden = true;
        [self.contentView.layer addSublayer:_maskLayer];
        
    }
    return self;
}

- (void)prepareForReuse {
    _maskLayer.hidden = true;
    _sequenceLabel.text = nil;
    _headlineLabel.text = nil;
    _sizeLabel.text = nil;
    _imageView.image = nil;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        CGFloat selectedBtnHW = 33;
        _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - selectedBtnHW , 0, selectedBtnHW, selectedBtnHW)];
        [self.contentView addSubview:_selectButton];
        NSAssert([UIImage imageNamed:@"message_oeuvre_btn_normal"], @"资源丢失");
        NSAssert([UIImage imageNamed:@"message_oeuvre_btn_selected"], @"资源丢失");
        [_selectButton setImage:[UIImage imageNamed:@"message_oeuvre_btn_normal"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"message_oeuvre_btn_selected"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
        _selectButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    }
    return _selectButton;
}


- (void)clickedBtn:(UIButton *)sender {
    if (_selectedBlock) {
        _selectedBlock();
    }
}

@end
