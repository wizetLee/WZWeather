//
//  WZVariousCollectionSectionsBaseProvider.m
//  WZWeather
//
//  Created by wizet on 17/4/13.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVariousCollectionSectionsBaseProvider.h"

@implementation WZVariousCollectionSectionsBaseProvider

@synthesize headerContent = _headerContent;
@synthesize footerContent = _footerContent;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minimumLineSpacing = 10;
        self.minimumInteritemSpacing = 10;
        self.sectionInsect = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return self;
}

- (WZVariousCollectionReusableContent *)headerContent {
    if (!_headerContent) {
        _headerContent = [[WZVariousCollectionReusableContent alloc] init];
    }
    return _headerContent;
}

- (WZVariousCollectionReusableContent *)footerContent {
    if (!_footerContent) {
        _footerContent = [[WZVariousCollectionReusableContent alloc] init];
    }
    return _footerContent;
}

- (void)setFooterContent:(WZVariousCollectionReusableContent *)footerContent {
    if ([footerContent isKindOfClass:[WZVariousCollectionReusableContent class]]) {
        _footerContent = footerContent;
    }
}

- (void)setHeaderContent:(WZVariousCollectionReusableContent *)headerContent {
    if ([headerContent isKindOfClass:[WZVariousCollectionReusableContent class]]) {
        _headerContent = headerContent;
    }
}

- (void)setFooterData:(id)footerData {
    _footerData = footerData;
    if ([self.providerDelegate respondsToSelector:@selector(updateProviderWithData:)]) {
        [self.providerDelegate updateProviderWithData:footerData];
    }
}

- (void)setHeaderData:(id)headerData {
    _headerData = headerData;
    if ([self.providerDelegate respondsToSelector:@selector(updateProviderWithData:)]) {
         [self.providerDelegate updateProviderWithData:headerData];
    }
}

@end
