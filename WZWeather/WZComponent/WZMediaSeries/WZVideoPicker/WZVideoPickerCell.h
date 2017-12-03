//
//  WZVideoPickerCell.h
//  WZWeather
//
//  Created by admin on 1/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZVideoPickerCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;//资源的封面
@property (nonatomic, strong) UILabel *headlineLabel;//资源的时间
@property (nonatomic, strong) UILabel *sizeLabel;//资源尺寸
@property (nonatomic, strong) UILabel *sequenceLabel;//选取的顺序

@property (nonatomic, strong) UIButton *selectButton;//选取的标识
@property (nonatomic, strong) void (^selectedBlock)();//选取的标识 的回调

@end
