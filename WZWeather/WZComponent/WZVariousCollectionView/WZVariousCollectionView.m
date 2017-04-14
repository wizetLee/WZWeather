//
//  WZVariousCollectionView.m
//  text1
//
//  Created by admin on 17/3/7.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVariousCollectionView.h"
#define WZCOLLECTION_DEFAULTCELLID NSStringFromClass([WZVariousCollectionBaseCell class])
#define WZCOLLECTION_DEFAULTREUSABLEVIEWID NSStringFromClass([UICollectionReusableView class])

@interface WZVariousCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@end

@implementation WZVariousCollectionView
@synthesize registerCellDic = _registerCellDic;
@synthesize sectionsDatas = _sectionsDatas;
@synthesize sectionsProviders = _sectionsProviders;

+ (instancetype)staticInitWithFrame:(CGRect)frame {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    WZVariousCollectionView *collection = [[WZVariousCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    return collection;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.dataSource = self;
        self.delegate = self;
        self.alwaysBounceVertical = true;
        
        //注册cell header footer
        [self registerClass:[WZVariousCollectionBaseCell class] forCellWithReuseIdentifier:WZCOLLECTION_DEFAULTCELLID];
        [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:WZCOLLECTION_DEFAULTREUSABLEVIEWID];
        [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:WZCOLLECTION_DEFAULTREUSABLEVIEWID];
    }
    return self;
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionsDatas.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sectionsDatas[section].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  
    WZVariousCollectionBaseObject * variousObj = [self getVariousObjectByIndexPath:indexPath];
    
    Class class = [WZVariousCollectionBaseCell class];
    if ([self.registerCellDic[variousObj.cellType] isSubclassOfClass:[WZVariousCollectionBaseCell class]]) {
        class = self.registerCellDic[variousObj.cellType];
    }
    
    NSString *cellID = NSStringFromClass(class);//配置类型
    
    if (!cellID) {
        cellID = WZCOLLECTION_DEFAULTCELLID;
    }
    
    WZVariousCollectionBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
     //类型匹配
    if (!cell) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:WZCOLLECTION_DEFAULTCELLID forIndexPath:indexPath];
    }
    //代理等
    cell.variousViewDelegate = (id<WZVariousCollectionDelegate>)self;
    cell.locatedController = self.locatedController;
    cell.data = variousObj;
    
    [cell isLastElement:variousObj.isLastElement];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:WZCOLLECTION_DEFAULTREUSABLEVIEWID forIndexPath:indexPath];
    
    WZVariousCollectionSectionsBaseProvider *provider = [self getProviderForSection:indexPath.section];
    provider.providerDelegate = (id<WZVariousCollectionSectionsBaseProviderDelegate>)self;
    [self matchingFrameForReusableView:reusableView withContent:provider withKind:kind];
    
    return reusableView;
}

- (WZVariousCollectionBaseObject *)getVariousObjectByIndexPath:(NSIndexPath *)indexPath {
    @try {
        if ([self.sectionsDatas[indexPath.section][indexPath.row] isKindOfClass:[WZVariousCollectionBaseObject class]]) {
            BOOL last = (self.sectionsDatas[indexPath.section][indexPath.row] == self.sectionsDatas[indexPath.section].lastObject);
            ((WZVariousCollectionBaseObject *)self.sectionsDatas[indexPath.section][indexPath.row]).isLastElement = last;
            return self.sectionsDatas[indexPath.section][indexPath.row];
        } else {
            return [[WZVariousCollectionBaseObject alloc] init];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        return [[WZVariousCollectionBaseObject alloc] init];
    }
}

- (void)matchingFrameForReusableView:(UICollectionReusableView *)reusableView withContent:(WZVariousCollectionSectionsBaseProvider *)provider withKind:(NSString *)kind{
    for (UIView *subView in reusableView.subviews) {
        [subView removeFromSuperview];
    }
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        [provider.footerContent sizeForData:provider.footerData];
        [reusableView addSubview:provider.footerContent];
        reusableView.frame =  CGRectMake(reusableView.frame.origin.x, reusableView.frame.origin.y, provider.footerContent.bounds.size.width, provider.footerContent.bounds.size.height);
    } else {
        [provider.headerContent sizeForData:provider.headerData];
        [reusableView addSubview:provider.headerContent];
        reusableView.frame = CGRectMake(reusableView.frame.origin.x, reusableView.frame.origin.y, provider.headerContent.bounds.size.width, provider.headerContent.bounds.size.height);
    }
}

#pragma mark WZVariousCollectionDelegate
- (void)variousView:(UIView *)view param:(NSMutableDictionary *)param {
    if ([self.variousCollectionDelegate respondsToSelector:@selector(variousView:param:)]) {
        [self.variousCollectionDelegate variousView:view param:param];
    }
}

#pragma mark WZVariousCollectionSectionsBaseProviderDelegate
- (void)updateProviderWithData:(id)data {
    [self reloadData];
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WZVariousCollectionBaseCell *cell = (WZVariousCollectionBaseCell *)[collectionView cellForItemAtIndexPath:indexPath];
 
    if ([cell isKindOfClass:[WZVariousCollectionBaseCell class]]) {
        [cell singleClicked];
    }
}

#pragma mark UICollectionViewDelegateFlowLayout

//每个Item的情况
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //需要实例方法
    WZVariousCollectionBaseObject * variousObj = [self getVariousObjectByIndexPath:indexPath];
    
    Class class = [WZVariousCollectionBaseCell class];
    if ([self.registerCellDic[variousObj.cellType] isSubclassOfClass:[WZVariousCollectionBaseCell class]]) {
        class = self.registerCellDic[variousObj.cellType];
    }
    
    return [class collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath model:self.sectionsDatas[indexPath.section][indexPath.row]];
}

//默认情况是配置sectionsProviders获得参数  或者子类自己定制一套
//每个section之间的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [self getProviderForSection:section].sectionInsect;
}

//cell水平方向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [self getProviderForSection:section].minimumInteritemSpacing;
}
//cell垂直方向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [self getProviderForSection:section].minimumLineSpacing;
}

//for header size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    WZVariousCollectionSectionsBaseProvider *provider = [self getProviderForSection:section];
    return [provider.headerContent sizeForData:provider.headerData];

}
//for footer size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    WZVariousCollectionSectionsBaseProvider *provider = [self getProviderForSection:section];
    return  [provider.footerContent sizeForData:provider.footerData];
}

- (WZVariousCollectionSectionsBaseProvider *)getProviderForSection:(NSInteger)section {
    if (self.sectionsProviders && self.sectionsProviders.count <= section + 1 && [self.sectionsProviders[section] isKindOfClass:[WZVariousCollectionSectionsBaseProvider class]]) {
        return self.sectionsProviders[section];
    }
    return [[WZVariousCollectionSectionsBaseProvider alloc] init];
}

#pragma mark setter & getter 

- (NSMutableArray *)sectionsDatas {
    if (!_sectionsDatas) {
        _sectionsDatas = [NSMutableArray array];
    }
    return _sectionsDatas;
}

- (void)setSectionsDatas:(NSMutableArray<NSMutableArray<WZVariousCollectionBaseObject *> *> *)sectionsDatas {
    if ([sectionsDatas isKindOfClass:[NSArray class]]) {
        NSMutableArray *tmpMArr = [NSMutableArray array];
        for (NSMutableArray *mArr in sectionsDatas) {
            if ([mArr isKindOfClass:[NSArray class]]) {
                NSMutableArray *tmpMArr2 = [NSMutableArray arrayWithArray:mArr];
                for (WZVariousCollectionBaseObject *obj in tmpMArr2) {
                    if (![obj isKindOfClass:[WZVariousCollectionBaseObject class]]) {
                        [tmpMArr2 removeObject:obj];
                    }
                }
                [tmpMArr addObject:tmpMArr2];
            }
        }
        _sectionsDatas = [NSMutableArray arrayWithArray:tmpMArr];
        [self reloadData];
    }
}

- (NSMutableDictionary *)registerCellDic {
    if (!_registerCellDic) {
        _registerCellDic = [NSMutableDictionary dictionary];
    }
    return _registerCellDic;
}

- (void)setRegisterCellDic:(NSMutableDictionary *)registerCellDic {
    if ([registerCellDic isKindOfClass:[NSMutableDictionary class]]) {
        for (int i = 0; i < registerCellDic.allKeys.count; i++) {
            NSString *key = registerCellDic.allKeys[i];
            //判断是否为cell类型
            if (![registerCellDic[key] isSubclassOfClass:[WZVariousCollectionBaseCell class]]) {
                registerCellDic[key] = [WZVariousCollectionBaseCell class];//修正类型
            }
              //以cell类名 作为 ID
            [self registerClass:registerCellDic[key] forCellWithReuseIdentifier:NSStringFromClass([registerCellDic[key] class])];
        }
        _registerCellDic = [NSMutableDictionary dictionaryWithDictionary:registerCellDic];
    }
}

- (NSMutableArray *)sectionsProviders {
    if (!_sectionsProviders) {
        _sectionsProviders = [NSMutableArray array];
    }
    return _sectionsProviders;
}

- (void)setSectionsProviders:(NSMutableArray<WZVariousCollectionSectionsBaseProvider *> *)sectionsProviders {
    if ([sectionsProviders isKindOfClass:[NSArray class]]) {
        NSMutableArray *tmpMArr = [NSMutableArray array];
        for (WZVariousCollectionSectionsBaseProvider *provider in sectionsProviders) {
            if ([provider isKindOfClass:[WZVariousCollectionSectionsBaseProvider class]]) {
                [tmpMArr addObject:provider];
            }
        }
        _sectionsProviders = tmpMArr;
        [self reloadData];
    }
}

@end
