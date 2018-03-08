//
//  BSactivityDetailAttendView.m
//  WZWeather
//
//  Created by admin on 8/3/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "BSactivityDetailAttendViewAlert.h"
#import "BSactivityDetailAttendViewTableModel.h"


@interface BSactivityDetailAttendViewAlert()<UIScrollViewDelegate , UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSArray <BSactivityDetailAttendViewTableModel *>*dataSource;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *trendView;

@end

@implementation BSactivityDetailAttendViewAlert


- (void)alertContent {
    [super alertContent];
    
    _dataSource = [BSactivityDetailAttendViewTableModel dataSource];
    [self calculateCellHeight];
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGFloat w = 450 / 2.0;
    CGFloat x = (screenSize.width - w) / 2.0;
    CGFloat y = 118.0 / 2.0;
    CGFloat h = (screenSize.height - y * 2.0) ;
    _table = [[UITableView alloc] initWithFrame:CGRectMake(x, y, w, h) style:UITableViewStylePlain];
    _table.delegate = self;
    [_table registerClass:BSactivityDetailAttendViewBlankCell.class forCellReuseIdentifier:@"BSactivityDetailAttendViewBlankCell"];
    [_table registerClass:BSactivityDetailAttendViewBlankCell.class forCellReuseIdentifier:@"BSactivityDetailAttendViewBlankCell30"];
    [_table registerClass:BSactivityDetailAttendViewBlankCell.class forCellReuseIdentifier:@"BSactivityDetailAttendViewBlankCell50"];
    [_table registerClass:BSactivityDetailAttendViewTitleCell.class forCellReuseIdentifier:@"BSactivityDetailAttendViewTitleCell"];
    [_table registerClass:BSactivityDetailAttendViewContentCell.class forCellReuseIdentifier:@"BSactivityDetailAttendViewContentCell"];
    _table.dataSource = self;
    _table.backgroundColor = [UIColor clearColor];
    _table.showsVerticalScrollIndicator = false;
    _table.showsHorizontalScrollIndicator = false;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_table];
    
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - 20.0 - 20.0, 20.0, 20.0, 20.0)];
    _closeButton.backgroundColor = [UIColor orangeColor];
    [_closeButton setTitle:@"关" forState:UIControlStateNormal];
    [self addSubview:_closeButton];
    [_closeButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_closeButton.frame) + _closeButton.bounds.size.width / 2.0 , CGRectGetMinY(_table.frame), 2.0, CGRectGetHeight(_table.frame))];
    line.backgroundColor = [UIColor whiteColor];
    [self addSubview:line];
    
    _trendView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(line.frame) - 2.0, CGRectGetMinY(_table.frame), 2.0 * 3, 22.0)];
    _trendView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_trendView];
    
}

#pragma mark - UITableViewDataSource & UITableViewDelegate & UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
   
    if (y < 0) {
        y = 0;
    }
//    if (y > CGRectGetHeight(_table.frame)) {
//        y = CGRectGetHeight(_table.frame);
//    }
    
    y = ((y) / (_table.contentSize.height - CGRectGetHeight(_table.frame))) * (CGRectGetHeight(_table.frame) - _trendView.bounds.size.height) + _trendView.bounds.size.height / 2.0 + CGRectGetMinY(_table.frame);
  
    if (y > (CGRectGetHeight(_table.frame) - _trendView.bounds.size.height / 2.0  + CGRectGetMinY(_table.frame))) {
        y = CGRectGetHeight(_table.frame) - _trendView.bounds.size.height / 2.0  + CGRectGetMinY(_table.frame);
    }
    
    _trendView.center = CGPointMake(_trendView.center.x, y);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section; {
    return _dataSource.count;
}

- (BSactivityDetailAttendViewBaseCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
    BSactivityDetailAttendViewTableModel *model = _dataSource[indexPath.row];
    BSactivityDetailAttendViewBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:model.cellID forIndexPath:indexPath];
    [cell updateWithModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BSactivityDetailAttendViewTableModel *model = _dataSource[indexPath.row];
    if (model.cellHeight) {
        return model.cellHeight;
    }
    return 0;
}

#pragma mark - Private
- (void)clickedBtn:(UIButton *)sender {
    [self alertDismissWithAnimated:true];
}

//计算高度
- (void)calculateCellHeight {
    BSactivityDetailAttendViewBlankCell *blackCell = [[BSactivityDetailAttendViewBlankCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BSactivityDetailAttendViewBlankCell"];
    
     BSactivityDetailAttendViewBlankCell30 *blackCell30 = [[BSactivityDetailAttendViewBlankCell30 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BSactivityDetailAttendViewBlankCell30"];
    
     BSactivityDetailAttendViewBlankCell50 *blackCell50 = [[BSactivityDetailAttendViewBlankCell50 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BSactivityDetailAttendViewBlankCell50"];
    
    BSactivityDetailAttendViewTitleCell *titleCell = [[BSactivityDetailAttendViewTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BSactivityDetailAttendViewTitleCell"];
    BSactivityDetailAttendViewContentCell *ContentCell = [[BSactivityDetailAttendViewContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BSactivityDetailAttendViewContentCell"];
    
    for (BSactivityDetailAttendViewTableModel *tmp in _dataSource) {
        if ([tmp.cellID isEqualToString:@"BSactivityDetailAttendViewTitleCell"]) {
            tmp.cellHeight = [titleCell calculateCellHeightWithModel:tmp];
        } else if ([tmp.cellID isEqualToString:@"BSactivityDetailAttendViewContentCell"]) {
            tmp.cellHeight = [ContentCell calculateCellHeightWithModel:tmp];
        } else if ([tmp.cellID isEqualToString:@"BSactivityDetailAttendViewBlankCell30"]) {
            tmp.cellHeight = [blackCell30 calculateCellHeightWithModel:tmp];
        } else if ([tmp.cellID isEqualToString:@"BSactivityDetailAttendViewBlankCell50"]) {
            tmp.cellHeight = [blackCell50 calculateCellHeightWithModel:tmp];
        } else {
            tmp.cellHeight = [blackCell calculateCellHeightWithModel:tmp];
        }
    }
}

#pragma mark - Overwrite
- (CGFloat)bgViewAlpha {
    return 1;
}

- (UIColor *)alertBackgroundViewColor {
    return [UIColor colorWithRed:31 / 255.0 green:36/ 255.0 blue:41 / 255.0 alpha:1.0];
}

@end
