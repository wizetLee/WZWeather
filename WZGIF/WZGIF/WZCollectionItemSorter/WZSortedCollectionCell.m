//
//  WZSortedCollectionCell.m
//  WZGIF
//
//  Created by admin on 17/7/18.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZSortedCollectionCell.h"

@implementation WZSortedCollectionCell

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    _coverImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImgView.layer.masksToBounds = true;
    [self.contentView addSubview:_coverImgView];
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat deleteBtnTRSpacing = 3.0;
    CGFloat deleteBtnHW = 20.0;
    _deleteBtn.frame = CGRectMake(self.bounds.size.width - deleteBtnHW - deleteBtnTRSpacing
                                  , deleteBtnTRSpacing
                                  , deleteBtnHW, deleteBtnHW);
    [self.contentView addSubview:_deleteBtn];
    _deleteBtn.layer.cornerRadius = deleteBtnHW / 2.0;
    _deleteBtn.layer.masksToBounds = true;
    
    [_deleteBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_deleteBtn setTitle:@"X" forState:UIControlStateNormal];
//    [_deleteBtn setImage:[UIImage imageNamed:@"message_customMade_btn_closeUploadImage_normal"] forState:UIControlStateNormal];
//    [_deleteBtn setImage:[UIImage imageNamed:@"message_customMade_btn_closeUploadImage_highlighted"] forState:UIControlStateHighlighted];
    
    _coverBtn = [[UIButton alloc] initWithFrame:self.bounds];
//    [_coverBtn setBackgroundImage:[UIImage imageNamed:@"newcontent_btn_loaclPictures_normal"] forState:UIControlStateNormal];
    
//    [_coverBtn setBackgroundImage:[UIImage imageNamed:@"newcontent_btn_loaclPictures_highlighted"] forState:UIControlStateHighlighted];
    [self.contentView addSubview:_coverBtn];
    [_coverBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    _coverBtn.backgroundColor = [UIColor yellowColor];
    _deleteBtn.backgroundColor = [UIColor redColor];
}

- (void)clickedBtn:(UIButton *)sender {
    if (sender == _deleteBtn) {
        if (self.deleteBlock) {
            self.deleteBlock();
        }
    } else if (sender == _coverBtn) {
        if (self.coverBlock) {
            self.coverBlock();
        }
    }
}

@end
