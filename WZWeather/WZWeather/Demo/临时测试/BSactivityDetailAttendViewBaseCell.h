//
//  BSactivityDetailAttendViewBaseCell.h
//  WZWeather
//
//  Created by admin on 8/3/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSactivityDetailAttendViewCellProtocol.h"

#define BSATTENDVIEWTABLE_WIDTH (UIScreen.mainScreen.bounds.size.width - (640 - 450) / 2.0)

@interface BSactivityDetailAttendViewBaseCell : UITableViewCell <BSactivityDetailAttendViewCellProtocol>

@property (nonatomic, strong) UILabel *titleLabel;



@end
