//
//  WZScrollOptions.m
//  WZWeather
//
//  Created by wizet on 2017/7/1.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZScrollOptions.h"

#define WZSCROLLOPTIONS_COLLECTIONCELLID @"WZScrollOptions_colletionCellID"
@interface WZScrollOptions()

@property (nonatomic, strong) UICollectionView *colllection;

@end

@implementation WZScrollOptions

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _colllection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    [self addSubview:_colllection];
    _colllection.dataSource = (id<UICollectionViewDataSource>)self;
    _colllection.delegate = (id<UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>)self;
    
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WZSCROLLOPTIONS_COLLECTIONCELLID forIndexPath:indexPath];

    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
#pragma mark - UICollectionViewDelegateFlowLayout


@end
