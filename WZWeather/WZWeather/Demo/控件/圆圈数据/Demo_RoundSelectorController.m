//
//  Demo_RoundSelectorController.m
//  WZWeather
//
//  Created by 李炜钊 on 2018/3/4.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "Demo_RoundSelectorController.h"
#import "SUPCoinsSelector.h"

@interface Demo_RoundSelectorController ()

{
    UILabel *coinsLabel;

}

@end

@implementation Demo_RoundSelectorController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    SUPCoinsSelector *selector = [[SUPCoinsSelector alloc] initWithFrame:CGRectMake(0.0, 100.0, MACRO_FLOAT_SCREEN_WIDTH, MACRO_FLOAT_SCREEN_WIDTH) curValue:0 maxValue:1000.0];
    [self.view addSubview:selector];
    selector.coinsDelegate = (id <SUPCoinsSelectorDelegate>)self;
    
    coinsLabel = [[UILabel alloc] init];
    coinsLabel.frame = CGRectMake(0.0, CGRectGetMaxY(selector.frame), MACRO_FLOAT_SCREEN_WIDTH, 44.0);
    [self.view addSubview:coinsLabel];
}

#pragma mark - SUPCoinsSelectorDelegate
- (void)getCoins:(double)coins {
    coinsLabel.text = [NSString stringWithFormat:@"coins = %f", coins];
}



@end
