//
//  WZSortedCollectionCell.h
//  WZGIF
//
//  Created by admin on 17/7/18.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZSortedCollectionCell : UICollectionViewCell

@property (nonatomic, strong) void (^coverBlock)();         //点击封面block
@property (nonatomic, strong) void (^deleteBlock)();        //删除block
@property (nonatomic, strong) UIImageView *coverImgView;    //封面图
@property (nonatomic, strong) UIButton *deleteBtn;          //删除按钮
@property (nonatomic, strong) UIButton *coverBtn;

@end
