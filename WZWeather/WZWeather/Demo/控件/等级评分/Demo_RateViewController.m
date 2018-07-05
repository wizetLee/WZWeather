//
//  Demo_RateViewController.m
//  WZWeather
//
//  Created by 李炜钊 on 2018/3/4.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "Demo_RateViewController.h"
#import "WZStarRatingView.h"

@interface Demo_RateViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat percentage;
@property (nonatomic, assign) CGFloat offset;

@end

@implementation Demo_RateViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    CGFloat height = 44.0;
    CGFloat y = 100;
    WZStarRatingView *rate0 = [[WZStarRatingView alloc] initWithFrame:CGRectMake(0.0, y, width, height) starCount:5 starSize:CGSizeMake(44.0, 44.0) spacing:10.0 totalValue:5 type:WZStarRatingViewTypeNormal];
    UILabel *label0 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(rate0.frame), width, height)];
    
    y += (height * 2.0);
    WZStarRatingView *rate1 = [[WZStarRatingView alloc] initWithFrame:CGRectMake(0.0, y, width, height) starCount:5 starSize:CGSizeMake(44.0, 44.0) spacing:10.0 totalValue:5 type:WZStarRatingViewTypeNormal];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(rate1.frame), width, height)];

    y += (height * 2.0);
    WZStarRatingView *rate2 = [[WZStarRatingView alloc] initWithFrame:CGRectMake(0.0, y, width, height) starCount:5 starSize:CGSizeMake(44.0, 44.0) spacing:10.0 totalValue:5 type:WZStarRatingViewTypeNormal];
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(rate2.frame), width, height)];

    
    _percentage = 0.0;
    _offset = 0.01;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:true block:^(NSTimer * _Nonnull timer) {
        _percentage = _offset + _percentage;
        rate0.percentageValue = _percentage + _offset;
        rate1.percentageValue = _percentage + _offset;
        rate2.percentageValue = _percentage + _offset;
        if (_percentage >= 1) {
            _offset = -0.01;
        } else if (_percentage <= 0) {
            _offset = 0.01;
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    [self.view addSubview:rate0];
    [self.view addSubview:rate1];
    [self.view addSubview:rate2];
    [self.view addSubview:label0];
    [self.view addSubview:label1];
    [self.view addSubview:label2];
    rate0.minValue = 1;
    rate1.minValue = 1;
    rate2.minValue = 1;
    
    
    rate1.type = WZStarRatingViewTypeHalfStar;
    rate2.type = WZStarRatingViewTypeWholeStar;
    rate0.touchable = rate1.touchable = rate2.touchable = true;

    __weak UILabel *weakLabel0 = label0;
    __weak UILabel *weakLabel1 = label1;
    __weak UILabel *weakLabel2 = label2;
    rate0.starRatingCurrentValueBlock = ^( double currentValue) {
        weakLabel0.text = [NSString stringWithFormat:@"评分为 ： %f", currentValue];
    };

    rate1.starRatingCurrentValueBlock = ^(double currentValue) {
        weakLabel1.text = [NSString stringWithFormat:@"评分为 ： %f", currentValue];
    };

    rate2.starRatingCurrentValueBlock = ^(double currentValue) {
        weakLabel2.text = [NSString stringWithFormat:@"评分为 ： %f", currentValue];
    };

}



@end
