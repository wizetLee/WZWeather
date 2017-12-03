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

@property (nonatomic, strong) NSArray <PHAsset *> *mediaAssetData;


//@property (nonatomic, assign) BOOL innerMode;//在选择的模式之中

@property (nonatomic, strong) NSMutableDictionary *imageMDic;//图片缓存。目的：fetch图片的步骤是一部的 因此获取过程有闪烁的现象因此需要缓存

@property (nonatomic, strong) UIBarButtonItem *leftItem;
@property (nonatomic, strong) UIBarButtonItem *rightItem;

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

    self.automaticallyAdjustsScrollViewInsets = false;
    
    _imageMDic = [NSMutableDictionary dictionary];
    
    _mediaAssetData = [WZMediaFetcher allVideosAssets];
    [self resetStatue];
   
    [self createViews];
}

- (void)resetStatue {
    _targetSize = CGSizeZero;
    _selectiveSequentialList = [NSMutableArray array];
  
     [_collection reloadData];
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
    
    _leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonAction)];
    _rightItem = [[UIBarButtonItem alloc] initWithTitle:@"模式选取" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonAction)];
//    right.title =
    if (self.navigationController) {
        self.navigationItem.leftBarButtonItem = _leftItem;
        self.navigationItem.rightBarButtonItem = _rightItem;
    }
}




- (void)leftButtonAction {
    //在选中模式之中
    if (0) {
        //恢复状态
        
    } else {
        //推出选择
        if ([_delegate respondsToSelector:@selector(videoPickerControllerDidClickedLeftItem)]) {
            [_delegate videoPickerControllerDidClickedLeftItem];
        } else {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }
}

- (void)rightButtonAction {
    if (1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选取模式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *surf = [UIAlertAction actionWithTitle:@"浏览模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.type = WZVideoPickerType_browse;
        }];
        UIAlertAction *pick = [UIAlertAction actionWithTitle:@"选取模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.type = WZVideoPickerType_pick;
        }];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"删除模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.type = WZVideoPickerType_delete;
        }];

        UIAlertAction *composition = [UIAlertAction actionWithTitle:@"合并模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.type = WZVideoPickerType_composition;
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:surf];
        [alert addAction:pick];
        [alert addAction:delete];
        [alert addAction:composition];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:true completion:^{
            
        }];
    } else {
        if ([_delegate respondsToSelector:@selector(videoPickerControllerDidClickedRightItem)]) {
            [_delegate videoPickerControllerDidClickedRightItem];
        }
    }
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section; {
    return _mediaAssetData ? _mediaAssetData.count : 0;
}

- (__kindof WZVideoPickerCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    WZVideoPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WZVideoPickerCell" forIndexPath:indexPath];
    
    if (_mediaAssetData.count > indexPath.row) {
        PHAsset *tmpPHAsset = _mediaAssetData[indexPath.row];
        
        cell.headlineLabel.text = [NSString stringWithFormat:@"%.2fsec", tmpPHAsset.duration];
        cell.sizeLabel.text = [NSString stringWithFormat:@"%ld*%ld", tmpPHAsset.pixelWidth, tmpPHAsset.pixelHeight];
        
       
        if (_imageMDic[tmpPHAsset.localIdentifier]) {
            cell.imageView.image = _imageMDic[tmpPHAsset.localIdentifier];
        } else {
            [WZMediaFetcher fetchThumbnailWithAsset:tmpPHAsset synchronous:false handler:^(UIImage *thumbnail) {
                cell.imageView.image = thumbnail;
                _imageMDic[tmpPHAsset.localIdentifier] = thumbnail;
            }];
        }
        
        
        cell.selectButton.hidden = true;
        cell.sequenceLabel.hidden = true;
        if (_type == WZVideoPickerType_pick
            || _type == WZVideoPickerType_delete
            || _type == WZVideoPickerType_composition) {
            cell.selectButton.hidden = false;
            cell.sequenceLabel.hidden = false;
            cell.sequenceLabel.text = @"";
            if ([_selectiveSequentialList containsObject:indexPath]) {
                cell.sequenceLabel.text = [NSString stringWithFormat:@"%ld", [_selectiveSequentialList indexOfObject:indexPath]];
                cell.selectButton.selected = true;
            } else {
               cell.selectButton.selected = false;
            }
        }
        
//        PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
//        option.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
//        [[PHImageManager defaultManager] requestAVAssetForVideo:tmpPHAsset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//
//        }];
    }
    return cell;
}


//MARK: - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     if (_mediaAssetData.count > indexPath.row) {
         PHAsset *tmpPHAsset = _mediaAssetData[indexPath.row];
         WZVideoPickerCell *cell = (WZVideoPickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
         
         if (_type == WZVideoPickerType_pick
             || _type == WZVideoPickerType_delete
             || _type == WZVideoPickerType_composition) {
             
             if ([_selectiveSequentialList containsObject:indexPath]) {
                 [_selectiveSequentialList removeObject:indexPath];
                 cell.selectButton.selected = false;
             } else {
                 [_selectiveSequentialList addObject:indexPath];
                  cell.selectButton.selected = true;
             }
             [collectionView reloadData];
         }
     }
}

#pragma mark - Accessor
- (UICollectionView *)collection {
    if (!_collection) {
        
        CGRect rect = self.navigationController?CGRectMake(0.0, 64.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0):self.view.bounds;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat gap = 1;
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

- (void)setType:(WZVideoPickerType)type {
    _type = type;
    switch (type) {
        case WZVideoPickerType_browse:{
            [self.navigationController.navigationBar setTitleTextAttributes:
             @{NSForegroundColorAttributeName:[UIColor blueColor]}];
            self.title = @"浏览模式";
        } break;
        case WZVideoPickerType_pick:{
            [self.navigationController.navigationBar setTitleTextAttributes:
             @{NSForegroundColorAttributeName:[UIColor greenColor]}];
            self.title = @"选取模式";
        } break;
        case WZVideoPickerType_delete:{
            [self.navigationController.navigationBar setTitleTextAttributes:
             @{NSForegroundColorAttributeName:[UIColor redColor]}];
            self.title = @"删除模式";
        } break;
        case WZVideoPickerType_composition:{
            [self.navigationController.navigationBar setTitleTextAttributes:
             @{NSForegroundColorAttributeName:[UIColor orangeColor]}];
            self.title = @"视频合并模式";
        } break;
            
        default:
             self.title = @"";
            break;
    }
    
    [self resetStatue];
}

@end
