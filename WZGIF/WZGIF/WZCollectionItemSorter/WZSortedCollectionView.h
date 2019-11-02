//
//  WZSortedCollectionView.h
//  WZGIF
//
//  Created by admin on 17/7/18.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZSortedCollectionView;
@protocol WZSortedCollectionViewProtocol <NSObject>

//item 移动事件回调
- (void)customCollectionView:(WZSortedCollectionView *)customCollectionView moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end


@interface WZSortedCollectionView : UICollectionView


@property (nonatomic, weak) id <WZSortedCollectionViewProtocol> sortedDelegate;
@property (nonatomic, strong) NSIndexPath *originalIndexPath;                                   //最初选择的IndexPath


@end
