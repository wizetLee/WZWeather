//
//  WZVariousTable.h
//  WZVariousTable
//
//  Created by wizet on 17/3/3.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZVariousBaseCell.h"
#import "WZVariousBaseObject.h"

@class WZVariousTable;

/**
 *  section == 1 的情况   多sections情况在其子类
 */
@interface WZVariousTable : UITableView

@property (nonatomic, weak) id<WZVariousViewDelegate> variousViewDelegate;
@property (nonatomic, weak) UIViewController *locatedController;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSMutableDictionary <NSString *, Class>*registerCellDic;//外部注册

@end
