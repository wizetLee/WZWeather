//
//  WZDownloadProgressCell.m
//  WZWeather
//
//  Created by admin on 17/5/18.
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
        //抛出一个进度接口
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, WZSCREEN_WIDTH, WZDownloadProgressCellHeight/ 2.0)];
        _titleLable.text = @"title";
        [self.contentView addSubview:_titleLable];
        
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, WZDownloadProgressCellHeight / 2.0, WZSCREEN_WIDTH, WZDownloadProgressCellHeight / 2.0)];
        [self.contentView addSubview:_progressLabel];
        _progressLabel.text = @"0.000000";
        
        CGFloat edge = 10;
        _actionBtn = [[UIButton alloc] initWithFrame:CGRectMake(WZSCREEN_WIDTH - WZDownloadProgressCellHeight, edge, WZDownloadProgressCellHeight - edge, WZDownloadProgressCellHeight - edge)];
        [self.contentView addSubview:_actionBtn];
        _actionBtn.backgroundColor = [UIColor greenColor];
        [_actionBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.contentView.backgroundColor = [UIColor yellowColor];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, WZDownloadProgressCellHeight - 10, WZSCREEN_WIDTH, 10)];
        line.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:line];
        
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
    }
}

- (void)clickedBtn:(UIButton *)sender {
    if ([self.variousViewDelegate respondsToSelector:@selector(variousView:param:)]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"data"] = _data;
        [self.variousViewDelegate variousView:self param:dic];
    }
}

- (void)setData:(WZVariousBaseObject *)data {
    if ([data isKindOfClass:[WZDownloadTarget class]]) {
        _data = data;
        ((WZDownloadTarget *)_data).delegate = (id<WZDownloadtargetDelegate>)self;
    }
}

#pragma mark WZDownloadtargetDelegate
- (void)progressCallBack:(NSDictionary *)callBack {
    if ([self.data isKindOfClass:[WZDownloadTarget class]]) {
        WZDownloadTarget *data = (WZDownloadTarget *)self.data;
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
