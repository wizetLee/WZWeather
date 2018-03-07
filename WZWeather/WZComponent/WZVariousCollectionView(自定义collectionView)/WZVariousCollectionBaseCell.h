//
//  WZVariousCollectionBaseCell.h
//  WZWeather
//
//  Created by wizet on 17/3/7.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZVariousCollectionBaseObject.h"

@protocol  WZVariousCollectionDelegate<NSObject>

- (void)variousView:(UIView *)view param:(NSMutableDictionary *)param;

@end

@class WZVariousCollectionBaseObject;

typedef NS_ENUM(NSUInteger, WZVariousCollectionMethod) {
    WZVariousCollectionMethod_0  = 0,
    WZVariousCollectionMethod_1  = 1,
    WZVariousCollectionMethod_2  = 2,
};

@interface WZVariousCollectionBaseCell : UICollectionViewCell

@property (nonatomic,   weak) UIViewController *locatedController;
@property (nonatomic,   weak) id<WZVariousCollectionDelegate> variousViewDelegate;
@property (nonatomic, strong) WZVariousCollectionBaseObject *data;

- (void)isLastElement:(BOOL)boolean;
- (void)singleClicked;
- (void)longPressed;

+ (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath model:(WZVariousCollectionBaseObject *)model;


@end
