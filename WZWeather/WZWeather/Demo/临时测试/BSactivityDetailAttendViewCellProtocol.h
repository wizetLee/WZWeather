//
//  BSactivityDetailAttendViewCellProtocol.h
//  WZWeather
//
//  Created by admin on 8/3/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BSactivityDetailAttendViewCellProtocol <NSObject>

- (float)calculateCellHeightWithModel:(id)model;
- (void)updateWithModel:(id)model;

@end
