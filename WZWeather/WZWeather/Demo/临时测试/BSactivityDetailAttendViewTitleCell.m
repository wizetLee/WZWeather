//
//  BSactivityDetailAttendViewTitleCell.m
//  WZWeather
//
//  Created by admin on 8/3/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "BSactivityDetailAttendViewTitleCell.h"
#import "BSactivityDetailAttendViewTableModel.h"

@implementation BSactivityDetailAttendViewTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:24.0 * 0.75];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.numberOfLines = 1;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)updateWithModel:(BSactivityDetailAttendViewTableModel *)model {
    UILabel *tempLabel = self.titleLabel;

    tempLabel.text = model.title;
    tempLabel.frame =  CGRectMake(0.0, 0.0, BSATTENDVIEWTABLE_WIDTH, [self calculateCellHeightWithModel:nil]);
}

- (float)calculateCellHeightWithModel:(BSactivityDetailAttendViewTableModel *)model {
    return 22.0;
}



@end
