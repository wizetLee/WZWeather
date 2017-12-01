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
        [self.contentView addSubview:_headlineLabel];
        _headlineLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.25];
       
        self.clipsToBounds = true;
    }
    return self;
}

@end
