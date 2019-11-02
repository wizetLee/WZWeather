//
//  WZCollectionItemSorter.m
//  WZGIF
//
//  Created by admin on 17/7/18.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZCollectionItemSorter.h"
#import "WZSortedCollectionView.h"
#import "WZSortedCollectionCell.h"

@implementation WZCollectionItem


@end

#define WZSORTEDCOLLECTION_CELLID @"WZSortedCollectionCellID"

@interface WZCollectionItemSorter ()<WZSortedCollectionViewProtocol,
                                    UICollectionViewDelegate,
                                    UICollectionViewDataSource>

@property (nonatomic, strong) WZSortedCollectionView *collectionView;

@end

@implementation WZCollectionItemSorter

@synthesize dataMArr = _dataMArr;

#pragma mark - Initialization
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    [self addSubview:self.collectionView];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.collectionView.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
}

#pragma mark - WZSortedCollectionViewProtocol
//item 移动事件回调
- (void)customCollectionView:(WZSortedCollectionView *)customCollectionView moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    //数据替换
    if (self.dataMArr.count > fromIndexPath.row
        && self.dataMArr.count > toIndexPath.row) {
        @try {
            NSMutableArray *tmpArr = [NSMutableArray array];
            id obj = self.dataMArr[fromIndexPath.row];
            tmpArr = self.dataMArr;
            [tmpArr removeObject:obj];
            [tmpArr insertObject:obj atIndex:toIndexPath.row];
            self.dataMArr = tmpArr;
            
            //移动代理
            if (_delegate && [_delegate respondsToSelector:@selector(sorter:moveFromIndexPath:toIndexPath:)]) {
                [_delegate sorter:self moveFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
            }
            
        } @catch (NSException *exception) {
            NSLog(@"异常%@", exception.debugDescription);
        } @finally {
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //点击代理
    if (_delegate && [_delegate respondsToSelector:@selector(sorter:didSelectedItemAtIndexPath:)]) {
        [_delegate sorter:self didSelectedItemAtIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataMArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WZSortedCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WZSORTEDCOLLECTION_CELLID forIndexPath:indexPath];
    __weak NSIndexPath *weakIndexPath = indexPath;
    __weak typeof(self) weakSelf = self;
    
    cell.deleteBtn.hidden = false;
    cell.coverBtn.hidden = true;
    if (self.dataMArr.count > indexPath.row) {
        WZCollectionItem *item = self.dataMArr[indexPath.row];
        if (item.thumbnailImage) {
            cell.coverImgView.image = item.thumbnailImage;//用的小图
        } else if (item.clearImage) {
            cell.coverImgView.image = item.clearImage;//最好用的小图

        }
        
        //            NSData *tmpData = [NSData dataWithContentsOfFile:item.thumbnailFileUrl];
        //            UIImage *image =  [UIImage imageWithData:tmpData];
        
        //        删除的block
        cell.deleteBlock = ^(){
            [weakSelf.dataMArr removeObjectAtIndex:weakIndexPath.row];
            [weakSelf.collectionView reloadData];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(sorter:didDeletedItemInIndexPath:)]) {
                [weakSelf.delegate sorter:weakSelf didDeletedItemInIndexPath:weakIndexPath];
            }
        };
    }
    
    return cell;
}

#pragma mark - Accessor
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        //layout配置
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat sectionInsetValue = 0.0;
        layout.minimumLineSpacing = 4.0;
        layout.minimumInteritemSpacing = 4.0;
//        CGFloat itemSizeHW = ([UIScreen mainScreen].bounds.size.width
//                              - sectionInsetValue * 2
//                              - layout.minimumLineSpacing * 2) / 3.0;
        CGFloat itemSizeHW = 100;
        layout.itemSize = CGSizeMake(itemSizeHW, itemSizeHW);
        layout.sectionInset = UIEdgeInsetsMake(sectionInsetValue, sectionInsetValue, sectionInsetValue, sectionInsetValue);
        _collectionView = [[WZSortedCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [_collectionView registerClass:[WZSortedCollectionCell class] forCellWithReuseIdentifier:WZSORTEDCOLLECTION_CELLID];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.sortedDelegate = self;
    }
    return _collectionView;
}

- (NSMutableArray *)dataMArr {
    if (!_dataMArr) {
        _dataMArr = [NSMutableArray array];
    }
    return _dataMArr;
}

- (void)setDataMArr:(NSMutableArray<WZCollectionItem *> *)dataMArr {
    if ([dataMArr isKindOfClass:[NSArray class]]) {
        _dataMArr  = [NSMutableArray arrayWithArray:dataMArr];
        [self.collectionView reloadData];
    }
}

@end
