//
//  WZMediaEffectShow.m
//  WZWeather
//
//  Created by admin on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaEffectShow.h"

@interface WZMediaEffectShowCell()

@property (nonatomic, strong) GPUImageView *imageView;

@end

@implementation WZMediaEffectShowCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)setFilter:(GPUImageFilter *)filter {
    [filter removeAllTargets];
    [filter addTarget:_imageView];
}

- (void)createViews {
    _imageView = [[GPUImageView alloc] initWithFrame:self.bounds];
}

@end

@interface WZMediaEffectShow()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UICollectionView *collection;

@end

@implementation WZMediaEffectShow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource?_dataSource.count:0;
}

- (__kindof WZMediaEffectShowCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WZMediaEffectShowCell *cell = (WZMediaEffectShowCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"collectionView" forIndexPath:indexPath];
    id d = _dataSource[indexPath.row];
    [cell setFilter:d];
    
    return cell;
}

#pragma mark - Accessor
-(UICollectionView *)collection {
    if (!_collection) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(60.0, 60.0);
        _collection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [_collection registerClass:[WZMediaEffectShowCell class] forCellWithReuseIdentifier:@"WZMediaEffectShowCell"];
        _collection.delegate = self;
        _collection.dataSource = self;
    }
    return _collection;
}


@end
