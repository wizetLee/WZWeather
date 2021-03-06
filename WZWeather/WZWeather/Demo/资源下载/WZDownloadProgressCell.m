//
//  WZDownloadProgressCell.m
//  WZWeather
//
//  Created by wizet on 17/5/18.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZDownloadProgressCell.h"
#import "WZDownloadTarget.h"
#import "WZDownloadRequest.h"
#define WZDownloadProgressCellHeight  100
@interface WZDownloadProgressCell()<WZDownloadtargetDelegate>

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIButton *actionBtn;

@end

@implementation WZDownloadProgressCell
@synthesize data = _data;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubviews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self.data isKindOfClass:[WZDownloadTarget class]]) {
        WZDownloadTarget *data = (WZDownloadTarget *)self.data;
        _titleLable.text = data.url.path;
        _progressLabel.text = [NSString stringWithFormat:@"%lf",bytesTransitionMB(data.totalBytesWritten)];
        [_progressLabel sizeToFit];
    }
}

#pragma mark - CreateSubviews
- (void)addSubviews {
    _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, MACRO_FLOAT_SCREEN_WIDTH, WZDownloadProgressCellHeight/ 2.0)];
    _titleLable.text = @"title";
    [self.contentView addSubview:_titleLable];
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, WZDownloadProgressCellHeight / 2.0, MACRO_FLOAT_SCREEN_WIDTH, WZDownloadProgressCellHeight / 2.0)];
    [self.contentView addSubview:_progressLabel];
    _progressLabel.text = @"0.000000";
    
    CGFloat edge = 10;
    _actionBtn = [[UIButton alloc] initWithFrame:CGRectMake(MACRO_FLOAT_SCREEN_WIDTH - edge - WZDownloadProgressCellHeight
                                                            , WZDownloadProgressCellHeight / 2.0
                                                            , WZDownloadProgressCellHeight - edge
                                                            , WZDownloadProgressCellHeight / 2.0 - edge)];
    [self.contentView addSubview:_actionBtn];
    [_actionBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_actionBtn setTitle:@"暂停" forState:UIControlStateNormal];
    _actionBtn.backgroundColor = [UIColor greenColor];
    self.contentView.backgroundColor = [UIColor yellowColor];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, WZDownloadProgressCellHeight - 10, MACRO_FLOAT_SCREEN_WIDTH, 10)];
    line.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:line];
}

#pragma mark - Button Action
- (void)clickedBtn:(UIButton *)sender {
    if ([self.variousViewDelegate respondsToSelector:@selector(variousView:param:)]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"data"] = _data;
        [self.variousViewDelegate variousView:self param:dic];
    }
    [self checkButtonStatus];
}

- (void)checkButtonStatus {
    if (((WZDownloadTarget *)_data).pause) {
        [_actionBtn setTitle:@"下载" forState:UIControlStateNormal];
        _actionBtn.backgroundColor = [UIColor redColor];
    } else {
        [_actionBtn setTitle:@"暂停" forState:UIControlStateNormal];
        _actionBtn.backgroundColor = [UIColor greenColor];
    }
}

- (void)setData:(WZVariousBaseObject *)data {
    if ([data isKindOfClass:[WZDownloadTarget class]]) {
        _data = data;
        ((WZDownloadTarget *)_data).delegate = (id<WZDownloadtargetDelegate>)self;
    }
}

#pragma mark - WZDownloadtargetDelegate
- (void)progressCallBack:(NSDictionary *)callBack {
    if ([self.data isKindOfClass:[WZDownloadTarget class]]) {
        WZDownloadTarget *data = (WZDownloadTarget *)self.data;
        [self checkButtonStatus];
        _progressLabel.text = [NSString stringWithFormat:@"%lf",bytesTransitionMB(data.totalBytesWritten)];
    }
}

- (void)singleClicked {
    NSLog(@"%@",self.data);
}

+ (CGFloat)heightForData:(WZVariousBaseObject *)obj {
    return WZDownloadProgressCellHeight;
}


@end
