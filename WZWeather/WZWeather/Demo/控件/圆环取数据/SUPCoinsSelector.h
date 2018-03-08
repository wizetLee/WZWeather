//
//  SUPCoinsSelector.h
//  WZBaseRoundSelector
//
//  Created by admin on 17/3/28.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZRoundSelectorLogicView.h"

@protocol SUPCoinsSelectorDelegate <NSObject>

- (void)getCoins:(double)coins;

@end

@interface SUPCoinsSelector : WZRoundSelectorLogicView

@property (nonatomic, assign) double coins;
@property (nonatomic, assign) id<SUPCoinsSelectorDelegate> coinsDelegate;
@property (nonatomic, strong) UIImageView *tendencyView;

@end
