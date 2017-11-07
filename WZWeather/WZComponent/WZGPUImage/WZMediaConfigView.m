//
//  WZMediaConfigView.m
//  WZWeather
//
//  Created by Wizet on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaConfigView.h"
#import "WZMediaConfigCell.h"


@interface WZMediaConfigView()<WZVariousViewDelegate>

@property (nonatomic, strong) WZVariousTable *table;
@property (nonatomic, strong) NSMutableArray <WZMediaConfigObject *>*dataSource;

@end

@implementation WZMediaConfigView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    _table = [[WZVariousTable alloc] initWithFrame:CGRectMake(0.0, 0.0, MACRO_FLOAT_SCREEN_WIDTH, MACRO_FLOAT_SCREEN_HEIGHT) style:UITableViewStylePlain];
    _table.variousViewDelegate = (id<WZVariousViewDelegate>)self;
    _table.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.25];;
    
    _table.registerCellDic = [NSMutableDictionary dictionaryWithDictionary:@{@"WZMediaConfigCell" : [WZMediaConfigCell class]}];
    [self addSubview:_table];
    _table.contentInset = UIEdgeInsetsMake(50, 0.0, 0.0, 0.0);
    WZMediaConfigObject *canvas = [[WZMediaConfigObject alloc] init];
    canvas.cellType = @"WZMediaConfigCell";
    canvas.type = 1;
    canvas.selectedType = WZMediaConfigType_canvas_1_multiply_1;
    canvas.headline = @"画幅";

    WZMediaConfigObject *flash = [[WZMediaConfigObject alloc] init];
    flash.cellType = @"WZMediaConfigCell";
    flash.type = 2;
    flash.selectedType = WZMediaConfigType_flash_auto;
    flash.headline = @"闪光灯";

    WZMediaConfigObject *countDown = [[WZMediaConfigObject alloc] init];
    countDown.cellType = @"WZMediaConfigCell";
    countDown.type = 3;
    countDown.selectedType = WZMediaConfigType_countDown_off;
    countDown.headline = @"倒计时";
    
    _dataSource = [NSMutableArray arrayWithArray:@[canvas, flash, countDown]];
    _table.datas = _dataSource;
    [_table reloadData];
}

#pragma mark - WZVariousViewDelegate
- (void)variousView:(UIView *)view param:(NSDictionary *)param {
    if ([param[@"WZMediaConfigType"] isKindOfClass:[NSNumber class]]) {
        NSNumber *type = (NSNumber *)param[@"WZMediaConfigType"];
        if ([_delegate  respondsToSelector:@selector(mediaConfigView:configType:)]) {
            [_delegate mediaConfigView:self configType:type.unsignedIntegerValue];
        }
    }
}

@end
