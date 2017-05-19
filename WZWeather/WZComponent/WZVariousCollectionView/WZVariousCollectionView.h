//
//  WZVariousCollectionView.h
//  WZWeather
//
//  Created by wizet on 17/3/7.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZVariousCollectionBaseCell.h"
#import "WZVariousCollectionSectionsBaseProvider.h"


@interface WZVariousCollectionView : UICollectionView

//注册header footer cell
@property (nonatomic, strong) NSMutableArray <WZVariousCollectionSectionsBaseProvider *>*sectionsProviders;
@property (nonatomic, strong) NSMutableDictionary <NSString *, Class>*registerCellDic;
@property (nonatomic, weak) id<WZVariousCollectionDelegate> variousCollectionDelegate;
@property (nonatomic, weak) UIViewController *locatedController;
//数据源
/**
 *  section data Source
 */
@property (nonatomic, strong) NSMutableArray <NSMutableArray <WZVariousCollectionBaseObject *>*>*sectionsDatas;
+ (instancetype)createWithFrame:(CGRect)frame;

@end
