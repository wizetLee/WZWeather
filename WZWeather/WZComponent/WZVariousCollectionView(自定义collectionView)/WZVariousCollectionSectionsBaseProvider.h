//
//  WZVariousCollectionSectionsBaseProvider.h
//  WZWeather
//
//  Created by wizet on 17/4/13.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZVariousCollectionReusableContent.h"

@protocol WZVariousCollectionSectionsBaseProviderDelegate <NSObject>

- (void)updateProviderWithData:(id)data;

@end

@interface WZVariousCollectionSectionsBaseProvider : NSObject
@property (nonatomic, weak) id<WZVariousCollectionSectionsBaseProviderDelegate> providerDelegate;

@property (nonatomic, strong) id headerData;//更新header的模型
@property (nonatomic, strong) id footerData;//同上
@property (nonatomic, assign) UIEdgeInsets sectionInsect;
@property (nonatomic, assign) CGFloat minimumLineSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, strong) WZVariousCollectionReusableContent *headerContent;//在外部设置sizeForData无效
@property (nonatomic, strong) WZVariousCollectionReusableContent *footerContent;

@end
