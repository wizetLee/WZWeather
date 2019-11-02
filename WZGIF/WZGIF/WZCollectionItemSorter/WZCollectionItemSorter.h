//
//  WZCollectionItemSorter.h
//  WZGIF
//
//  Created by admin on 17/7/18.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZCollectionItem : NSObject

@property (nonatomic, strong) UIImage *thumbnailImage;           //缩略图
@property (nonatomic, strong) UIImage *clearImage;              //清晰图
@property (nonatomic, strong) NSURL *remoteImageURL;            //网络图片url_str
@property (nonatomic, strong) NSString *localImagePath;         //本地图片路径

@end

@class WZCollectionItemSorter;

@protocol WZCollectionItemSorterProtocol <NSObject>

//已删除事件
- (void)sorter:(WZCollectionItemSorter *)sorter didDeletedItemInIndexPath:(NSIndexPath *)indexPath;
//交换完成后的事件（对数据源进行调整）
- (void)sorter:(WZCollectionItemSorter *)sorter moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
//选中item事件
- (void)sorter:(WZCollectionItemSorter *)sorter didSelectedItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface WZCollectionItemSorter : UIView

@property (nonatomic, weak) id<WZCollectionItemSorterProtocol> delegate;
@property (nonatomic, strong) NSMutableArray <WZCollectionItem *>*dataMArr;//数据源



@end
