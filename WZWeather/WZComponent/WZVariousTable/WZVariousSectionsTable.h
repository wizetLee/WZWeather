//
//  WZVariousSectionsTable.h
//  SUPEPRO
//
//  Created by admin on 17/4/5.
//  Copyright © 2017年 jerry. All rights reserved.
//

#import "WZVariousTable.h"

@interface WZVariousSectionsTable : WZVariousTable

@property (nonatomic, weak) id<UITableViewDelegate> variousSectionsDelegate;//可自定义header footer

@property (nonatomic, strong) NSMutableArray <NSMutableArray *>*sectionsDatas;

@end
