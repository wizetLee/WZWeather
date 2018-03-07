//
//  WZMediaTmpRecordList.m
//  WZWeather
//
//  Created by wizet on 21/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaTmpRecordList.h"
@interface WZMediaTmpRecordListCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *headlineLabel;

@end

@implementation WZMediaTmpRecordListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    _imageView = [[UIImageView alloc] init];
    _imageView.frame = self.contentView.bounds;
    [self.contentView addSubview:_imageView];
    
    _headlineLabel = [[UILabel alloc] init];
    _headlineLabel.frame = self.contentView.bounds;
    [self.contentView addSubview:_headlineLabel];
}

@end


@interface WZMediaTmpRecordList() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collection;

@end

@implementation WZMediaTmpRecordList

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.frame.size.width, self.frame.size.width);
    
    _collection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    [self addSubview:_collection];
    [_collection registerClass:[WZMediaTmpRecordListCell class] forCellWithReuseIdentifier:NSStringFromClass([WZMediaTmpRecordListCell class])];
    _collection.delegate = self;
    _collection.dataSource = self;
}


- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
}

#pragma mark - Delegate And DataSource
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (WZMediaTmpRecordListCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WZMediaTmpRecordListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WZMediaTmpRecordListCell class]) forIndexPath:indexPath];
    
    
    return cell;
}

@end
