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
    _table.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.25];;
    
    _table.registerCellDic = [NSMutableDictionary dictionaryWithDictionary:@{@"WZMediaConfigCell" : [WZMediaConfigCell class]}];
    [self addSubview:_table];
    _table.contentInset = UIEdgeInsetsMake(50, 0.0, 0.0, 0.0);
    WZMediaConfigObject *canvas = [[WZMediaConfigObject alloc] init];
    canvas.cellType = @"WZMediaConfigCell";
    canvas.type = 1;
    canvas.selectedType = WZMediaConfigType_canvas_9_multiply_16;
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
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    if ([_delegate respondsToSelector:@selector(mediaConfigView:tap:)]) {
        [_delegate mediaConfigView:self tap:tap];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    } else {
        return view;
    }
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
