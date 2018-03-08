//
//  SUPCoinsSelector.m
//  WZBaseRoundSelector
//
//  Created by admin on 17/3/28.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "SUPCoinsSelector.h"

@implementation SUPCoinsSelector

- (instancetype)initWithFrame:(CGRect)frame curValue:(double)curValue maxValue:(double)maxValue {
    if (self = [super initWithFrame:frame curValue:curValue maxValue:maxValue]) {
        self.tendencyView.frame = CGRectMake(self.frame.size.width / 2.0 - 24.0, -(48.0 - 15.0)/2.0, 48.0, 48.0);
    }
    return self;
}

- (void)metric:(double)metric {
    //给出当前移动的度
    /*
     
     最低0.01元，最高1000元，价格设置的圆圈分成3个阶段。
     第一段（0~1/4处）：0~1，滑动最低0.01元；
     第二段（1/4~2/4处）：1~10，滑动最低0.1元；
     第三段（2/4~3/4处）：10~100，滑动最低1元。
     第四段（3/4~1处）：100~1000，滑动最低100元。
     
     
     if (metric <= 0.25) {
     _coins = (metric / 0.25 * 1.0);
     } else if (metric <= 0.50) {
     _coins = (int)((((metric - 0.25) / 0.25) * (10 - 1) + 1) * 10) / 10.0 ;
     } else if (metric <= 0.75) {
     _coins = (int)(((metric - 0.50) / 0.25) * (100 - 10) + 10);
     } else {
     _coins = ((int)(((metric - 0.75) / 0.25) * (1000 - 100) + 100)) / 100 * 100 ;
     }
     
     if ([self.coinsDelegate respondsToSelector:@selector(getCoins:)]) {
     [self.coinsDelegate getCoins:_coins];
     }
     */
    
    
    /*
     价格调节范围0.01~1000，价格设置的圆圈分成4个阶段：
     第一段（0~1/4处）：范围0~1，其中0.00~0.1只能是0.01的倍数， 0.1~1，只能是0.1的倍数
     第二段（1/4~2/4处）：1~10，只能是1的倍数
     第三段（2/4~3/4处）：10~100，只能是1的倍数
     第四段（3/4~1处）：100~1000，只能是10的倍数
     */
    if (metric <= 0.25) {
        if (metric <= 0.025) {
            _coins = (metric / 0.25 * 1.0);
        } else {
            _coins = (int)((metric / 0.25 * 1.0) * 10) / 10.0 ;
        }
    } else if (metric <= 0.50) {
        _coins = (int)(((metric - 0.25) / 0.25) * (10 - 1) + 1);
    } else if (metric <= 0.75) {
        _coins = (int)(((metric - 0.50) / 0.25) * (100 - 10) + 10);
    } else {
        _coins = ((int)(((metric - 0.75) / 0.25) * (1000 - 100) + 100)) / 10 * 10 ;
    }
    
    if ([self.coinsDelegate respondsToSelector:@selector(getCoins:)]) {
        [self.coinsDelegate getCoins:_coins];
    }
    
}

/**
 *  输入价格更改圈中值
 *
 *  @param coins 价格
 */
- (void)setCoins:(double)coins {
    //分解
    _coins = (double)coins;
    if (coins < 0.0) {coins = 0.0;}
    if (coins > 1000.0) {coins = 1000.0;}
  
    double angle = 0.0;
    
    if (coins <= 1.0) {
        angle = coins / 1.0 * M_PI_2;
        _status = 1;
    } else if (coins <= 10.0) {
        angle = (coins - 1.0) / (10.0 - 1.0) * M_PI_2 + M_PI_2;
        _status = 2;
    } else if (coins <= 100.0) {
        angle = (coins - 10.0) / (100.0 - 10.0) * M_PI_2 + M_PI_2 * 2.0;
        _status = 3;
    } else {//
        angle = (coins - 100.0) / (1000.0 - 100.0) * M_PI_2 + M_PI_2 * 3.0;
        _status = 4;
    }
    
    //获得渲染角度
    [self renderAngle:angle];
}

- (void)renderPathCurrentPoint:(CGPoint)currentPoint {
    _tendencyView.center = currentPoint;
}

#pragma mark setter & getter 
- (UIImageView *)tendencyView {
    if (!_tendencyView) {
        _tendencyView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 48.0, 48.0)];
        _tendencyView.image = [UIImage imageNamed:@"newcontent_icon_coins"];
        [self addSubview:_tendencyView];
    }
    return _tendencyView;
}


@end
