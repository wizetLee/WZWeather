//
//  T3.m
//  WZWeather
//
//  Created by wizet on 17/4/13.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "T3.h"

@implementation T3

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

+ (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath model:(WZVariousCollectionBaseObject *)model {
    return CGSizeMake(50, 50);
}

+ (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section model:(WZVariousCollectionBaseObject *)model {
    return 10.0;
}
+ (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section model:(WZVariousCollectionBaseObject *)model {
    return 10.0;
}

@end
