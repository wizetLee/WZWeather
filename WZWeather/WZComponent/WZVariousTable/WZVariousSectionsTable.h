//
//  WZVariousSectionsTable.h
//  WZWeather
//
//  Created by wizet on 17/4/5.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "WZVariousTable.h"

@interface WZVariousSectionsTable : WZVariousTable

@property (nonatomic, weak) id<UITableViewDelegate> variousSectionsDelegate;//可自定义header footer

@property (nonatomic, strong) NSMutableArray <NSMutableArray *>*sectionsDatas;

@end
