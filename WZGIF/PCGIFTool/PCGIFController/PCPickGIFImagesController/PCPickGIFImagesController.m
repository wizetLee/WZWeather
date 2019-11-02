//
//  PCPickGIFImagesController.m
//  WZGIF
//
//  Created by wizet on 2017/7/30.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "PCPickGIFImagesController.h"
#import "WZPhotoCatalogueController.h"
#import "PCAdjustiveGIFController.h"
#import "WZCollectionItemSorter.h"
#import "FLAnimatedImage.h"
#import "WZToast.h"

@interface PCPickGIFImagesController ()<WZCollectionItemSorterProtocol, WZProtocolMediaAsset>

@property (nonatomic, strong) WZCollectionItemSorter *sorter;//图片排序器：UI 长按图片可以更改当前图片的位置

@end

@implementation PCPickGIFImagesController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
    
    [_sorter setDataMArr:_dataMArr];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

#pragma mark - Create Views
- (void)createViews {
    //navigation items
    UIBarButtonItem *pickImagesItem = [[UIBarButtonItem alloc] initWithTitle:@"选图" style:UIBarButtonItemStylePlain target:self action:@selector(pickImages)];
    UIBarButtonItem *scanGIFItem = [[UIBarButtonItem alloc] initWithTitle:@"GIF参数调整" style:UIBarButtonItemStylePlain target:self action:@selector(adjustmentGIF)];
    self.navigationItem.rightBarButtonItems = @[pickImagesItem, scanGIFItem];
    
    _sorter = [[WZCollectionItemSorter alloc] init];
    _sorter.frame = CGRectMake(0.0, 64.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0);
    [self.view addSubview:_sorter];
    _sorter.delegate = self;
}

#pragma mark - Navigation Items Event
//选择制作GIF的图
- (void)pickImages {
    [WZPhotoCatalogueController showPickerWithPresentedController:self];
}

//进入调整GIF的页面
- (void)adjustmentGIF {
    if (_dataMArr.count > 1) {
        NSMutableArray <PCGIFItem *>*tmpGIFItemMArr = [NSMutableArray array];
        for (WZCollectionItem *item in _dataMArr) {
            PCGIFItem *GIFItem = [[PCGIFItem alloc] init];
            UIImage *image;
            if (item.clearImage) {
                image = item.clearImage;
            } else if (item.thumbnailImage) {
                image = item.thumbnailImage;
            }
            if (image) {
                GIFItem.targetImage = image;
#warning - Need A FPS 需要一个帧率
                GIFItem.interval =  10.0 / _dataMArr.count;//8.0 / _dataMArr.count;//录制时间除以图片数目
                [tmpGIFItemMArr addObject:GIFItem];
            }
        }
        
        PCAdjustiveGIFController *VC = [[PCAdjustiveGIFController alloc] init];
        VC.dataArr = [NSArray arrayWithArray:tmpGIFItemMArr];
        [self.navigationController pushViewController:VC animated:true];
    } else {
        [WZToast toastWithContent:@"大哥最少选两张图吧!"];
    }
}

#pragma mark - 选图代理 WZProtocolMediaAsset
- (void)fetchAssets:(NSArray <WZMediaAsset *> *)assets {
    _dataMArr = [NSMutableArray array];
    for (WZMediaAsset *MediaAsset in assets) {//设定的图片的大小 {240， 240}
        [WZMediaFetcher fetchImageWithAsset:MediaAsset.asset costumSize:CGSizeMake(240, 240) synchronous:true handler:^(UIImage *image) {
            WZCollectionItem *item = [WZCollectionItem new];
            item.clearImage = image;
            item.thumbnailImage = image;
            [_dataMArr addObject:item];
        }];
    }
    _sorter.dataMArr = _dataMArr;
}

//- (void)fetchImages:(NSArray <UIImage *> *)images {
//    //
//    _dataMArr = [NSMutableArray array];
//    if ([images isKindOfClass:[NSArray class]]
//        && images.count) {
//        for (UIImage *image in images) {
//            WZCollectionItem *item = [[WZCollectionItem alloc] init];
//            item.clearImage = image;
//            [_dataMArr addObject:item];
//        }
//        _sorter.dataMArr = _dataMArr;//同时刷新视图
//    }
//    
//}

#pragma mark - 图片排序代理 WZCollectionItemSorterProtocol
//已删除事件
- (void)sorter:(WZCollectionItemSorter *)sorter didDeletedItemInIndexPath:(NSIndexPath *)indexPath {
    @synchronized (self) {
        if (_dataMArr.count > indexPath.row) {
            [_dataMArr removeObjectAtIndex:indexPath.row];
            sorter.dataMArr = _dataMArr;
        }
    }
}

//交换完成后的事件（对数据源进行调整）
- (void)sorter:(WZCollectionItemSorter *)sorter moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    @synchronized (self) {
        if (_dataMArr.count > fromIndexPath.row
            && _dataMArr.count > toIndexPath.row) {
            [_dataMArr exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        }
    }
}

//选中item事件
- (void)sorter:(WZCollectionItemSorter *)sorter didSelectedItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Accessor
- (NSMutableArray <WZCollectionItem *>*)dataMArr {
    if (!_dataMArr) {
        _dataMArr = [NSMutableArray array];
    }
    return _dataMArr;
}

@end
