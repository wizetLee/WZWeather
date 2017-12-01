//
//  WZVideoPickerController.m
//  WZWeather
//
//  Created by admin on 1/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVideoPickerController.h"
#import "WZVideoPickerCell.h"
#import <Photos/Photos.h>
#import "WZMediaFetcher.h"

@interface WZVideoPickerController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collection;
@property (nonatomic, strong) NSArray <PHAsset *>* mediaAssetArray;

@end

@implementation WZVideoPickerController

//MARK: 图片选择  present形式就使用这种初始化模式
+ (void)showPickerWithPresentedController:(UIViewController <WZVideoPickerControllerProtocol>*)presentedController {
    WZVideoPickerController *VC = [[WZVideoPickerController alloc] init];
    VC.delegate = (id<WZVideoPickerControllerProtocol>)self;
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:VC];
    [presentedController presentViewController:navigationVC animated:true completion:^{}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass([self class]);
    self.automaticallyAdjustsScrollViewInsets = false;
    
    _mediaAssetArray = [NSMutableArray array];
    _mediaAssetArray = [WZMediaFetcher allVideosAssets];
    
    [self createViews];
}

- (void)createViews {
    CGFloat top = 0.0;
    CGFloat bottom = 0.0;
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
    
    top = MACRO_FLOAT_STSTUSBAR_AND_NAVIGATIONBAR_HEIGHT;
    bottom = MACRO_FLOAT_SAFEAREA_BOTTOM;
    CGFloat height = screenH - bottom - top;
    
    [self.view addSubview:self.collection];//系统自己匹配的安全区域显示的内容
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonAction)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"选择完成" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonAction)];
    
    if (self.navigationController) {
        self.navigationItem.leftBarButtonItem = left;
        self.navigationItem.rightBarButtonItem = right;
    }
}

- (void)leftButtonAction {
    if ([_delegate respondsToSelector:@selector(videoPickerControllerDidClickedLeftItem)]) {
        [_delegate videoPickerControllerDidClickedLeftItem];
    } else {
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

- (void)rightButtonAction {
    if ([_delegate respondsToSelector:@selector(videoPickerControllerDidClickedRightItem)]) {
        [_delegate videoPickerControllerDidClickedRightItem];
    }
}


#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section; {
    return _mediaAssetArray.count;
}


- (__kindof WZVideoPickerCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    WZVideoPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WZVideoPickerCell" forIndexPath:indexPath];
    
    if (_mediaAssetArray.count > indexPath.row) {
        PHAsset *tmpPHAsset = _mediaAssetArray[indexPath.row];
        cell.headlineLabel.text = [NSString stringWithFormat:@"%.2fsec", tmpPHAsset.duration];
        [WZMediaFetcher fetchThumbnailWithAsset:tmpPHAsset synchronous:false handler:^(UIImage *thumbnail) {
            cell.imageView.image = thumbnail;
            
        }];
        
//        PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
//        option.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
//        [[PHImageManager defaultManager] requestAVAssetForVideo:tmpPHAsset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//
//        }];
    }
    return cell;
}


#pragma mark - Accessor
- (UICollectionView *)collection {
    if (!_collection) {
        
        CGRect rect = self.navigationController?CGRectMake(0.0, 64.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0):self.view.bounds;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat gap = 10.0;
        layout.minimumLineSpacing = gap;
        layout.minimumInteritemSpacing = gap;
        layout.sectionInset = UIEdgeInsetsMake(gap, gap, gap, gap);
        CGFloat itemWH = ([UIScreen mainScreen].bounds.size.width - gap * 5) / 4;
        layout.itemSize = CGSizeMake(itemWH, itemWH);
        
        _collection = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collection.backgroundColor = [UIColor whiteColor];
        _collection.dataSource = self;
        _collection.delegate = self;
        [_collection registerClass:[WZVideoPickerCell class] forCellWithReuseIdentifier:NSStringFromClass([WZVideoPickerCell class])];
        
    }
    return _collection;
}

@end
