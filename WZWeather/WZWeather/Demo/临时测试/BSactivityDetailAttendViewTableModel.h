//
//  BSactivityDetailAttendViewTableModel.h
//  WZWeather
//
//  Created by admin on 8/3/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSactivityDetailAttendViewBlankCell.h"
#import "BSactivityDetailAttendViewTitleCell.h"
#import "BSactivityDetailAttendViewContentCell.h"
#import "BSactivityDetailAttendViewBlankCell50.h"
#import "BSactivityDetailAttendViewBlankCell30.h"

#define BSATTENDVIEWTABLE_WIDTH (UIScreen.mainScreen.bounds.size.width - (640 - 450) / 2.0)

@interface BSactivityDetailAttendViewTableModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *cellID;
@property (nonatomic, assign) float cellHeight;

+ (NSArray <BSactivityDetailAttendViewTableModel *>*)dataSource;

@end
