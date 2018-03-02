//
//  BITransitionTypeSelectedView.h
//  WZWeather
//
//  Created by admin on 2/3/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BITransitionTypeSelectedView : UIView

@property (nonatomic, assign) NSUInteger nodeCount;

@property (nonatomic, strong, readonly) NSArray <NSNumber *>*nodeTypeArr;
@property (nonatomic,   weak) UINavigationController *navigationController;

@end
