//
//  WZVariousSectionsTable.m
//  WZWeather
//
//  Created by wizet on 17/4/5.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "WZVariousSectionsTable.h"


@implementation WZVariousSectionsTable
@synthesize sectionsDatas = _sectionsDatas;

//类型(隐藏式)纠正
- (WZVariousBaseObject *)getVariousObjectByIndexPath:(NSIndexPath *)indexPath {
    @try {
       
        if ([self.sectionsDatas[indexPath.section] isKindOfClass:[NSArray class]]) {
            NSArray * arr = self.sectionsDatas[indexPath.section];
           
            if ([arr[indexPath.row] isKindOfClass:[WZVariousBaseObject class]]) {
                BOOL last = (self.sectionsDatas[indexPath.section][indexPath.row] == self.sectionsDatas[indexPath.section].lastObject);
                ((WZVariousBaseObject *)self.sectionsDatas[indexPath.section][indexPath.row]).isLastElement = last;
                 return self.sectionsDatas[indexPath.section][indexPath.row];
            } else {
                return [[WZVariousBaseObject alloc] init];
            }
        } else {
            return [[WZVariousBaseObject alloc] init];
        }
    } @catch (NSException *exception) {
        return [[WZVariousBaseObject alloc] init];
    } @finally {
        
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([self.variousSectionsDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [self.variousSectionsDelegate tableView:tableView viewForHeaderInSection:section];
    }
    return [UIView new];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.variousSectionsDelegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [self.variousSectionsDelegate tableView:tableView viewForFooterInSection:section];
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.variousSectionsDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.variousSectionsDelegate tableView:tableView heightForHeaderInSection:section];
    }
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.variousSectionsDelegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.variousSectionsDelegate tableView:tableView heightForFooterInSection:section];
    }
    return 0.001;
}


#pragma mark UITableViewDataSource
//数据个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sectionsDatas.count > 0) {
         return self.sectionsDatas[section].count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionsDatas.count;
}

#pragma mark setter & getter
- (NSMutableArray *)sectionsDatas {
    if (!_sectionsDatas) {
        _sectionsDatas = [NSMutableArray array];
    }
    return _sectionsDatas;
}

//数据过滤
- (void)setSectionsDatas:(NSMutableArray *)sectionsDatas {
    if ([sectionsDatas isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *tmpMArr = [NSMutableArray array];
        for (id obj in sectionsDatas) {
            if ([obj isKindOfClass:[NSMutableArray class]]) {
                [tmpMArr addObject:obj];
            }
        }
        _sectionsDatas = [NSMutableArray arrayWithArray:tmpMArr];
        [self reloadData];
    }
}

@end
