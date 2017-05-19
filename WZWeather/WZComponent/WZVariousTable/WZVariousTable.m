//
//  WZVariousTable.m
//  WZVariousTable
//
//  Created by wizet on 17/3/3.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVariousTable.h"

#define WZTABLE_DEFAULTCELLID NSStringFromClass([WZVariousBaseCell class])

@interface WZVariousTable()<UITableViewDelegate, UITableViewDataSource>


@end

@implementation WZVariousTable
@synthesize registerCellDic = _registerCellDic;
@synthesize datas = _datas;


//初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self prepareForTable];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self prepareForTable];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self prepareForTable];
    }
    return self;
}

- (void)prepareForTable {
    self.datas = [NSMutableArray array];//初始化
    self.separatorStyle = UITableViewCellSeparatorStyleNone;//无分割线
    
    //代理
    self.delegate = self;
    self.dataSource = self;
    [self registerClass:[WZVariousBaseCell class] forCellReuseIdentifier:WZTABLE_DEFAULTCELLID];//内部注册
}

#pragma mark UITableViewDelegate

//cell高度配置
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //匹配cell 计算
    WZVariousBaseObject * variousObj = [self getVariousObjectByIndexPath:indexPath];
    
    if (variousObj.cellHeight && !variousObj.cellHeightVariable) {
        return variousObj.cellHeight;
    }
    
    if ([self.registerCellDic[variousObj.cellType] isSubclassOfClass:[WZVariousBaseCell class]]) {
        return [self.registerCellDic[variousObj.cellType] heightForData:variousObj];
    }
    
    return [WZVariousBaseCell heightForData:variousObj];
}

//类型(隐藏式)纠正  考虑到 外部突然插入数据到self.datas 因此没在set方法中过滤
- (WZVariousBaseObject *)getVariousObjectByIndexPath:(NSIndexPath *)indexPath {
    @try {
        if ([self.datas[indexPath.row] isKindOfClass:[WZVariousBaseObject class]]) {
            BOOL last = (self.datas[indexPath.row] == self.datas.lastObject);
            ((WZVariousBaseObject *)self.datas[indexPath.row]).isLastElement = last;
            return self.datas[indexPath.row];
        } else {
            return [[WZVariousBaseObject alloc] init];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    
    return [[WZVariousBaseObject alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        [tableView deselectRowAtIndexPath:indexPath animated:false];//不留下选中痕迹
        
        WZVariousBaseCell *cell =  [tableView cellForRowAtIndexPath:indexPath];
        
        if ([cell isKindOfClass:[WZVariousBaseCell class]]) {
            [cell singleClicked];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
}

#pragma mark UITableViewDataSource
//数据个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WZVariousBaseObject * variousObj = [self getVariousObjectByIndexPath:indexPath];
    Class class = [WZVariousBaseCell class];
    
    if ([self.registerCellDic[variousObj.cellType] isSubclassOfClass:[WZVariousBaseCell class]]) {
        class = self.registerCellDic[variousObj.cellType];
    }
    
    NSString *cellID = NSStringFromClass(class);//配置类型
    
    if (!cellID) {
        cellID = WZTABLE_DEFAULTCELLID;
    }
    
    WZVariousBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[class alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:cellID];
    }
    
    //代理等
    cell.variousViewDelegate = (id<WZVariousViewDelegate>)self;
    cell.locatedController = self.locatedController;
    cell.data = variousObj;
    
    [cell isLastElement:variousObj.isLastElement];
    
    return cell;
}

#pragma mark variousViewDelegate
- (void)variousView:(UIView *)view param:(NSDictionary *)param{
    if ([self.variousViewDelegate respondsToSelector:@selector(variousView:param:)]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:param];
        [self.variousViewDelegate variousView:self param:dic];
    }
}

#pragma mark setter & getter
- (NSMutableDictionary *)registerCellDic {
    if (!_registerCellDic) {
        _registerCellDic = [NSMutableDictionary dictionary];
    }
    return _registerCellDic;
}

- (void)setRegisterCellDic:(NSMutableDictionary *)registerCellDic {
    for (int i = 0; i < registerCellDic.allKeys.count; i++) {
        NSString *key = registerCellDic.allKeys[i];
        //判断是否为cell类型
        if (![registerCellDic[key] isSubclassOfClass:[WZVariousBaseCell class]]) {
            registerCellDic[key] = [WZVariousBaseCell class];//修正类型
        }
        
        //以cell类名 作为 ID
        [self registerClass:registerCellDic[key] forCellReuseIdentifier:NSStringFromClass([registerCellDic[key] class])];
    }
    
    _registerCellDic = [NSMutableDictionary dictionaryWithDictionary:registerCellDic];
}

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

//数据过滤
- (void)setDatas:(NSMutableArray *)datas {
    if ([datas isKindOfClass:[NSMutableArray class]]) {
        //        NSMutableArray *tmpMArr = [NSMutableArray array];
        //        for (id obj in datas) {
        //            if ([obj isKindOfClass:[WZVariousBaseObject class]]) {
        //                [tmpMArr addObject:obj];
        //            }
        //        }
        _datas = [NSMutableArray arrayWithArray:datas];
    }
}

@end
