//
//  BSactivityDetailAttendViewBaseCell.h
//  WZWeather
//
//  Created by admin on 8/3/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSactivityDetailAttendViewCellProtocol.h"


@interface BSactivityDetailAttendViewBaseCell : UITableViewCell <BSactivityDetailAttendViewCellProtocol>

@property (nonatomic, strong) UILabel *titleLabel;

- (void)updateWithModel:(id)model;

@end
