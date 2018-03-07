//
//  WZVariousSectionsTable.h
//  WZWeather
//
//  Created by wizet on 17/4/5.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "WZVariousTable.h"

/**
 基于WZVariousTable的扩展（Header Footer部分， 多个section）
 */
@interface WZVariousSectionsTable : WZVariousTable

@property (nonatomic,   weak) id<UITableViewDelegate> variousSectionsDelegate;//可自定义header footer
@property (nonatomic, strong) NSMutableArray <NSMutableArray *>*datas;//重载超类属性


@end
