//
//  WZMediaEffectShow.m
//  WZWeather
//
//  Created by Wizet on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaEffectShow.h"

#define WZMeidaEffectType(name) WZMeidaEffectType_##name

typedef NS_ENUM(NSUInteger, WZMeidaEffectType) {
    WZMeidaEffectType(none),
    WZMeidaEffectType(luminance),//亮度
    WZMeidaEffectType(saturability),//饱和度
    WZMeidaEffectType(sharpen),//锐度
    WZMeidaEffectType(whiteBalance),//白平衡
    WZMeidaEffectType(hue),//色调
    WZMeidaEffectType(contrast),//对比度
    WZMeidaEffectType(construction),//结构
};

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
@property (nonatomic, weak) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@property (nonatomic, strong) UIView *bgView;
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

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)createViews {
    _bgView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_bgView];
    _bgView.backgroundColor = [UIColor clearColor];
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_bgView addGestureRecognizer:_pan];
    //    _dataSource = [];

    [self addSubview:self.collection];
    self.alpha = 0.0;
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    //计算变化的比例
    CGPoint oppositePoint = [pan translationInView:self];
    
    if (oppositePoint.x >= 0) {
        CGFloat scale = oppositePoint.x / _collection.frame.size.width;
        self.alpha = 1 - scale;
        _collection.minX = self.frame.size.width - _collection.frame.size.width + oppositePoint.x;
    }
    NSLog(@"%@", NSStringFromCGPoint(oppositePoint));
   if (pan.state == UIGestureRecognizerStateEnded) {
       [self caculateStatus];
    }
}

- (void)caculateStatus {
    [UIView animateWithDuration:0.25 animations:^{
        if (self.alpha > 0.5) {
            [self showPercent:1];
        } else {
            if ([_delegate respondsToSelector:@selector(mediaEffectShowDidShrinked)]) {
                [_delegate mediaEffectShowDidShrinked];
            }
            [self showPercent:0];
        }
    }];
}

- (void)showPercent:(CGFloat)percent {
    self.alpha = percent;
    CGFloat x = self.frame.size.width - percent * _collection.frame.size.width;
    if (x >= self.frame.size.width) {
        x = self.frame.size.width;
    }
    _collection.minX = x;
}

- (void)dismissPercent:(CGFloat)percent {
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource?_dataSource.count:10;
}

- (__kindof WZMediaEffectShowCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WZMediaEffectShowCell *cell = (WZMediaEffectShowCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WZMediaEffectShowCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
//    id d = _dataSource[indexPath.row];
//    [cell setFilter:d];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedIndexPath) {
        WZMediaEffectShowCell *cell = (WZMediaEffectShowCell *)[collectionView cellForItemAtIndexPath:_selectedIndexPath];
        cell.selected = false;
        cell = (WZMediaEffectShowCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.selected = true;
        //更改实体数据选中项
    }
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    } else {
        return view;
    }
}

#pragma mark - Accessor
-(UICollectionView *)collection {
    if (!_collection) {
        CGFloat w = 80.0;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(w - 10.0, w - 10.0);
        _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0.0, w, self.frame.size.height) collectionViewLayout:layout];
        [_collection registerClass:[WZMediaEffectShowCell class] forCellWithReuseIdentifier:@"WZMediaEffectShowCell"];
        _collection.delegate = self;
        _collection.dataSource = self;
        
    }
    return _collection;
}


@end
