//
//  BIViewEditingClippingView.m
//  PocoCamera
//
//  Created by admin on 22/9/17.
//  Copyright © 2017年 PocoCamera. All rights reserved.
//

#import "BIVideoEditingClippingView.h"
#define BIRATIOCUTOUTCOLLECTIONCELLID @"BIRatioCutOutCollectionCellID"
#define BIRatioCutOutViewEdgeWidth   22.0
#define BIRatioCutOutViewCellHeight   (1 * 60.0)
#define BIRatioCutOutViewCellWidth   (([UIScreen mainScreen].bounds.size.width - BIRatioCutOutViewEdgeWidth * 2) / 15) ///去掉边缘 剩下的位置 /15 factor 因子为2

@interface BIVideoEditingClippingView()<UIScrollViewDelegate>

@property (nonatomic, strong) WZRatioCutOutView *cutOutView;
@property (nonatomic,   weak) UIButton *btnPointer;
///图片部分
@property (nonatomic, strong) UICollectionView *collection;
@property (nonatomic, strong) NSMutableArray <NSValue *>*timeMArr;
@property (nonatomic, strong) NSMutableDictionary *imageDic;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@property (nonatomic, assign) CGFloat  minimumTime;//1
@property (nonatomic, assign) CGFloat restrictTime;//为0时候为任意

@end

@implementation BIVideoEditingClippingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

#pragma mark - Private Method
- (void)createViews {

    _minimumTime = 1;
    _restrictTime = 0;
    _timeMArr = [[NSMutableArray alloc] init];
    _timeMArr = [[NSMutableArray alloc] init];
    _imageDic = [NSMutableDictionary dictionary];
    CGFloat typeH = 44.0; //isIPad
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(BIRatioCutOutViewCellWidth, BIRatioCutOutViewCellHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - BIRatioCutOutViewCellHeight - typeH, UIScreen.mainScreen.bounds.size.width, BIRatioCutOutViewCellHeight) collectionViewLayout:layout];
    _collection.contentInset = UIEdgeInsetsMake(0.0, BIRatioCutOutViewEdgeWidth, 0.0, BIRatioCutOutViewEdgeWidth);
    _collection.showsHorizontalScrollIndicator = false;
    _collection.delegate = (id<UICollectionViewDelegate>)self;
    _collection.dataSource = (id<UICollectionViewDataSource>)self;
    _collection.bouncesZoom = false;
    _collection.bounces = false;
    [self addSubview:_collection];
    [_collection registerClass:[BIRatioCutOutCollectionCell class] forCellWithReuseIdentifier:BIRATIOCUTOUTCOLLECTIONCELLID];
    
    _cutOutView = [[WZRatioCutOutView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - BIRatioCutOutViewCellHeight - typeH, [UIScreen mainScreen].bounds.size.width, BIRatioCutOutViewCellHeight)];
    [self addSubview:_cutOutView];
    
    NSArray <NSString *>*tmpArr = @[@"任意", @"10", @"15", @"30"];
    CGFloat btnW = [UIScreen mainScreen].bounds.size.width / tmpArr.count;
    for (int i = 0; i < tmpArr.count; i++) {
        UIButton *button = [[UIButton alloc] init];
//        [self addSubview:button];
        button.frame = CGRectMake(i * btnW, self.frame.size.height - typeH, btnW, typeH);
        [button setTitle:tmpArr[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(pressUpInside:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        if (i == 0) {
            [self pressUpInside:button];
        }
    }
}

- (void)pressUpInside:(UIButton *)sender {
  
    switch (sender.tag) {
        case 0: {
            _restrictTime = 0;
            ///值得注意的是 (CMTimeGetSeconds(self.asset.duration)) 始终会大于0
            if (!_asset
                   || (CMTimeGetSeconds(_asset.duration)) < 1) {
             [_cutOutView setMinimumRestrictRatio:1.0];//计算约束的位置
            } else {
               [_cutOutView setMinimumRestrictRatio:1.0 / (NSInteger)(CMTimeGetSeconds(_asset.duration))];//计算约束的位置
            }
            
//            if (_timeMArr.count) {
//                self.collection.contentSize.width / timeMArr.count;
//                 ;//取整数
//            }
        }break;
        case 1: {
            if ((NSInteger)(CMTimeGetSeconds(self.asset.duration)) < 10.0) {
                return;
            }
            _restrictTime = 10;
            [_cutOutView constantRatio:_restrictTime / (NSInteger)(CMTimeGetSeconds(_asset.duration))];//计算约束的位置
            ///更新view的位置
        }break;
        case 2: {
            if ((NSInteger)(CMTimeGetSeconds(self.asset.duration)) < 15.0) {
                return;
            }
            _restrictTime = 15;
            [_cutOutView constantRatio:_restrictTime / (NSInteger)(CMTimeGetSeconds(_asset.duration))];//计算约束的位置
            
        }break;
        case 3: {
            if ((NSInteger)(CMTimeGetSeconds(self.asset.duration)) < 30.0) {
                return;
            }
            _restrictTime = 30;
            [_cutOutView constantRatio:_restrictTime / (NSInteger)(CMTimeGetSeconds(_asset.duration))];//计算约束的位置
        }break;
        default:
            break;
    }
    [_btnPointer setSelected:false];
    _btnPointer = sender;
    [_btnPointer setSelected:true];
}

- (void)setDelegate:(id<WZRatioCutOutViewProtocol>)delegate {
    _delegate = delegate;
    _cutOutView.delegate = delegate;
}

- (void)setAsset:(AVAsset *)asset {
    _asset = asset;
    [self pressUpInside:_btnPointer];
    [self updateView];

}

#pragma mark - Public Method
- (void)updateView {
    //    _asset
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    _imageGenerator.appliesPreferredTrackTransform = true;//指定在从资源中提取图像时是否应用跟踪矩阵(或矩阵)。
    if (UIScreen.mainScreen.scale > 1.0) {
        _imageGenerator.maximumSize = CGSizeMake(BIRatioCutOutViewCellWidth * 2, 1 * 60.0 * 2);
    } else {
        _imageGenerator.maximumSize = CGSizeMake(BIRatioCutOutViewCellWidth, 1 * 60.0);
    }
    /////1秒拿一张图片
    //视频时间 除以间隔
    CGFloat duration = 1;////要根据视频的时间去设置这个间隔啊
    Float64 assetDuration = CMTimeGetSeconds(_asset.duration);
    if (assetDuration > 30) {
        duration = 2;//去图间隔为2
    }
    NSUInteger factor = (assetDuration / duration);
    
    [_timeMArr removeAllObjects];
    [_imageDic removeAllObjects];
    for (int i = 0; i < factor; i++) {
        CMTime actualTime = CMTimeMakeWithSeconds(i*duration, 600);
        [_timeMArr addObject:[NSValue valueWithCMTime:actualTime]];
    }
    
    //获取
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collection reloadData];
        _cutOutView.frame = CGRectMake(0.0, 0.0, _timeMArr.count * BIRatioCutOutViewCellWidth + BIRatioCutOutViewEdgeWidth * 2.0, _cutOutView.frame.size.height);
        [_cutOutView updateView];
    });
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _timeMArr?_timeMArr.count:0;
}

- (__kindof BIRatioCutOutCollectionCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BIRatioCutOutCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BIRATIOCUTOUTCOLLECTIONCELLID forIndexPath:indexPath];
    NSError *error;
    if (_imageDic[[NSString stringWithFormat:@"%@", indexPath]]) {
        cell.coverImgView.image = (UIImage *) _imageDic[[NSString stringWithFormat:@"%@", indexPath]];
    } else {
        
        CGImageRef halfWayImage = [_imageGenerator copyCGImageAtTime:_timeMArr[indexPath.row].CMTimeValue actualTime:NULL error:&error];
        UIImage *videoScreen;
        if (UIScreen.mainScreen.scale > 1.0){
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
        } else {
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:1.0 orientation:UIImageOrientationUp];
        }
        
        if (halfWayImage != NULL) {
            _imageDic[[NSString stringWithFormat:@"%@", indexPath]] = videoScreen;
            cell.coverImgView.image = videoScreen;
            CGImageRelease(halfWayImage);
        }
        
        if (error) {
            NSLog(@"%@", error.description);
        }
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    scrollView.contentOffset.x
    if (_restrictTime == 0) {///自由滑动
        _cutOutView.frame = CGRectMake(-scrollView.contentOffset.x-BIRatioCutOutViewEdgeWidth, _cutOutView.frame.origin.y, _cutOutView.frame.size.width, _cutOutView.frame.size.height);
    }

}

#pragma mark - WZRatioCutOutViewProtocol
///抛出比例
- (void)ratioCutOutView:(WZRatioCutOutView *)view leadingRatio:(CGFloat)leadingRatio trailingRatio:(CGFloat)trailingRatio leadingDrive:(BOOL)leadingDrive {
    
}

- (void)ratioCutOutViewMoveStateEnd {
    
}

@end


@implementation BIRatioCutOutCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    _coverImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.contentView addSubview:_coverImgView];
    _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImgView.clipsToBounds = true;
}

@end
