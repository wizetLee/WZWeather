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
#import "WZAPLSimpleEditor.h"
#import "WZVideoSurfAlert.h"

@interface WZVideoPickerController ()<UICollectionViewDelegate, UICollectionViewDataSource , PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) UICollectionView *collection;

@property (nonatomic, strong) NSMutableArray <PHAsset *> *mediaAssetData;
@property (nonatomic, strong) WZAPLSimpleEditor *editor;

@property (nonatomic, assign) BOOL innerMode;//在选择的模式之中

@property (nonatomic, strong) NSMutableDictionary *imageMDic;//图片缓存。目的：fetch图片的步骤是一部的 因此获取过程有闪烁的现象因此需要缓存

@property (nonatomic, strong) UIBarButtonItem *leftItem;
@property (nonatomic, strong) UIBarButtonItem *rightItem;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) WZVideoSurfAlert *surfAlert;

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
    _mediaAssetData = [NSMutableArray arrayWithArray:[WZMediaFetcher allVideosAssets]];
    
    [self resetStatue];
    [self createViews];

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)resetStatue {
    dispatch_async(dispatch_get_main_queue(), ^{
        _targetSize = CGSizeZero;
        _selectiveSequentialList = [NSMutableArray array];
        [_collection reloadData];
        if (_type == WZVideoPickerType_composition
            || _type == WZVideoPickerType_pick
            || _type == WZVideoPickerType_delete) {
             self.rightItem.enabled = false;
        }
    });
}

- (void)createViews {
    CGFloat top = 0.0;
    CGFloat bottom = 0.0;
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
    
    top = MACRO_FLOAT_STSTUSBAR_AND_NAVIGATIONBAR_HEIGHT;
    bottom = MACRO_FLOAT_SAFEAREA_BOTTOM;
    CGFloat height = screenH - bottom - top;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.clipsToBounds = true;
    [self.view addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"wallpaper3.jpeg"];
    _backgroundImageView = imageView;
    
//    [self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
//    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
//    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageWithColor:[UIColor clearColor]];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];//透明
//self.navigationController.navigationBar.backIndicatorImage
    
    [self.view addSubview:self.collection];//系统自己匹配的安全区域显示的内容
    _leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonAction)];
    _rightItem = [[UIBarButtonItem alloc] initWithTitle:@"模式选取" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonAction)];
//    right.title =
    if (self.navigationController) {
        self.navigationItem.leftBarButtonItem = _leftItem;
        self.navigationItem.rightBarButtonItem = _rightItem;
    }
    
    self.type = WZVideoPickerType_browse;
}

- (void)leftButtonAction {
    //在选中模式之中
    if (_innerMode) {
        //恢复状态
        self.type = WZVideoPickerType_browse;
        self.rightItem.enabled = true;
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
    if (!_innerMode) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择当前需要使用的模式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
     
        UIAlertAction *pick = [UIAlertAction actionWithTitle:@"选取模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.type = WZVideoPickerType_pick;
        }];
       
        
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"删除模式" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            self.type = WZVideoPickerType_delete;
        }];
        
        UIAlertAction *composition = [UIAlertAction actionWithTitle:@"合并模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.type = WZVideoPickerType_composition;
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:pick];
        [alert addAction:composition];
        [alert addAction:delete];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:true completion:^{
            
        }];
    } else {
        if (_type == WZVideoPickerType_composition) {
            __weak typeof(self) weakSelf = self;
            _editor = [[WZAPLSimpleEditor alloc] init];
            NSMutableArray <AVAsset *>*tmpMArr = [NSMutableArray array];
            for (NSIndexPath *indexPath in _selectiveSequentialList) {
                if (_mediaAssetData.count > indexPath.row) {
                    PHAsset *tmpPHAsset = _mediaAssetData[indexPath.row];
                    [WZMediaFetcher fetchVideoWith:tmpPHAsset synchronous:true handler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        [tmpMArr addObject:asset];
                        NSLog(@"%@", indexPath);
                    }];
                }
            }
//每次add视频上去需要更新状态
            
//            AVMutableComposition *c =  [[self class] compositionWithSegments:tmpMArr];
//            NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
//
//            NSString *pathWithComponent = [path stringByAppendingPathComponent:@"ssss.mp4"];
//
//            NSURL *outputURL = [NSURL fileURLWithPath:pathWithComponent];
//            if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.path]) {
//                NSError *error;
//                [[NSFileManager defaultManager] removeItemAtPath:outputURL.path error:&error];
//                if (error) {
//                    NSLog(@"文件删除失败：%@",error.description);
//                }
//            }
//            [[self class] exportWithComposition:c outputURL:outputURL withProgressHandler:^(CGFloat progress) {
//                NSLog(@"progress : %lf", progress);
//            } result:^(BOOL success) {
//                NSLog(@"%ld", success);
//            }];
            ///带过渡效果的
            [_editor updateEditorWithVideoAssets:tmpMArr];
            if (tmpMArr.count) {
                [_editor exportToSandboxDocumentWithFileName:@"my222y.mp4" completionHandler:^(AVAssetExportSessionStatus statue, NSURL *fileURL) {
                    if (statue == AVAssetExportSessionStatusCompleted) {
                        NSLog(@"导出成功");
                        [WZToast toastWithContent:@"导出成功"];
                        [WZAPLSimpleEditor saveVideoToLocalWithURL:fileURL completionHandler:^(BOOL success) {
                            if (success) {
                                NSLog(@"保存成功");
                            } else {
                                NSLog(@"保存失败");
                            }
                        }];

                    } else {
                        NSLog(@"导出失败");
                        [WZToast toastWithContent:@"导出失败 未知错误"];
                    }
                }];
            }
            
            
        } else if (_type == WZVideoPickerType_delete) {
            NSMutableArray <NSString *>*tmpMArr = [NSMutableArray array];
            for (NSIndexPath *indexPath in _selectiveSequentialList) {
                if (_mediaAssetData.count > indexPath.row) {
                    PHAsset *asset = _mediaAssetData[indexPath.row];
                    [tmpMArr addObject:asset.localIdentifier];
                }
            }
          
            [WZMediaFetcher deleteAssetsWithLIDS:tmpMArr complectionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"删除成功");
                } else {
                    NSLog(@"%@", error.description);
                }
            }];
        } else if (_type == WZVideoPickerType_pick) {
            
        }
    }
    
    //        if ([_delegate respondsToSelector:@selector(videoPickerControllerDidClickedRightItem)]) {
    //            [_delegate videoPickerControllerDidClickedRightItem];
    //        }

}

//MARK:输出合成的视频
+ (void)exportWithComposition:(AVComposition *)composition outputURL:(NSURL *)outputURL withProgressHandler:(void (^)(CGFloat progress))handler result:(void (^)(BOOL success))result {
    //    AVMutableComposition *composition = [WZCamera compositionWithSegments:_camera.videoRecordSegmentMArr];
    //    NSLog(@"合成路径!!!:%@", composition);
    //    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:composition];
    //可以用来播放
    //    AVMutableComposition *composition;
    if (composition) {
        
    }
    NSString *preset = AVAssetExportPresetHighestQuality;
    AVAssetExportSession *exportSession  = [AVAssetExportSession exportSessionWithAsset:composition presetName:preset];
    
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    __block CGFloat progress = 0.0 ;
    
    
    //     exportSession.timeRange =   ;//配置时间范围
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        //输出状态查询
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAssetExportSessionStatus status = exportSession.status;
            
            if (status == AVAssetExportSessionStatusExporting) {
                progress = exportSession.progress;
                if (handler) {handler(progress);}//输出进度
            } else if (status == AVAssetExportSessionStatusCompleted) {
                //outputURL 可以保存到相册
                progress = 1.0;
                if (handler) {handler(progress);}//输出进度
                if (result) {result(true);}//输出结果
            } else if(status == AVAssetExportSessionStatusCancelled
                      || status == AVAssetExportSessionStatusFailed){
                NSLog(@"输出出错");
                if (result) { result(false);}//输出结果
            }
        });
    }];
    //输出
    
}

#pragma mark - SCRecorder 视频合成方案样例代码 稍有更改
+ (AVMutableComposition *)compositionWithSegments:(NSArray <AVAsset *>*)segments {
    //可变音视频组合
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    //可变音频轨道
    AVMutableCompositionTrack *audioTrack = nil;
    //可变视频轨道
    AVMutableCompositionTrack *videoTrack = nil;
    
    
    CMTime currentTime = composition.duration;
    for (AVAsset *tmpAsset in segments) {
        AVAsset *asset = tmpAsset;
        
        NSArray *audioAssetTracks = [asset tracksWithMediaType:AVMediaTypeAudio];//取出音频轨道
        NSArray *videoAssetTracks = [asset tracksWithMediaType:AVMediaTypeVideo];//取出视频轨道
        
        CMTime maxBounds = kCMTimeInvalid;//最大界限
        
        CMTime videoTime = currentTime;
        
        for (AVAssetTrack *videoAssetTrack in videoAssetTracks) {
            if (videoTrack == nil) {
                NSArray *videoTracks = [composition tracksWithMediaType:AVMediaTypeVideo];
                
                if (videoTracks.count) {
                    videoTrack = [videoTracks firstObject];
                } else {
                    videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                    videoTrack.preferredTransform = videoAssetTrack.preferredTransform;
                }
            }
            
      
        }
        
        CMTime audioTime = currentTime;
        for (AVAssetTrack *audioAssetTrack in audioAssetTracks) {
            if (audioTrack == nil) {
                NSArray *audioTracks = [composition tracksWithMediaType:AVMediaTypeAudio];
                if (audioTracks.count) {
                    audioTrack = [audioTracks firstObject];
                } else {
                    audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                }
            }
            
            
     
        }
        
        currentTime = composition.duration;//组合的时间、作用于下一个循环的偏移量
    }
    
    return composition;
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
//        cell.maskLayer.hidden = true;
        
        if (_type == WZVideoPickerType_pick
            || _type == WZVideoPickerType_delete
            || _type == WZVideoPickerType_composition) {
            cell.selectButton.hidden = false;
            
            cell.sequenceLabel.text = @"";
            if ([_selectiveSequentialList containsObject:indexPath]) {
                cell.sequenceLabel.text = [NSString stringWithFormat:@"%ld", [_selectiveSequentialList indexOfObject:indexPath]];
                cell.selectButton.selected = true;
                cell.sequenceLabel.hidden = false;
            } else {
               cell.selectButton.selected = false;
               cell.sequenceLabel.hidden = true;
            }
            
            if (_type == WZVideoPickerType_delete) {
                cell.sequenceLabel.hidden = true;
            } else if (_type == WZVideoPickerType_composition) {
                
                if ((CGSizeEqualToSize(self.targetSize, CGSizeZero))) {
                    cell.maskLayer.hidden = true;
                } else {
                    CGSize size = CGSizeMake(tmpPHAsset.pixelWidth, tmpPHAsset.pixelHeight);
                    if (CGSizeEqualToSize(self.targetSize, size)) {
                        cell.maskLayer.hidden = true;
                    } else {
                        cell.maskLayer.hidden = false;
                    }
                }
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
             
             if (_type == WZVideoPickerType_composition) {
                 
                 if (CGSizeEqualToSize(self.targetSize, CGSizeZero)) {
                     
                 } else {
                     CGSize size = CGSizeMake(tmpPHAsset.pixelWidth, tmpPHAsset.pixelHeight);
                     //1、未选择时，全部可选
                     //2、选中时候，只能选择相同大小的
                     
                     if (CGSizeEqualToSize(self.targetSize, size)) {
                         
                     } else {
                         [WZToast toastWithContent:@"暂时只支持相同尺寸的视频合成"];
                         return;
                     }
                     
                 }
             }
             
             if ([_selectiveSequentialList containsObject:indexPath]) {
                 [_selectiveSequentialList removeObject:indexPath];
            
                 if (_type == WZVideoPickerType_composition && (_selectiveSequentialList.count == 0)) {
                     self.targetSize = CGSizeZero;
                 }
             } else {
                 if (_type == WZVideoPickerType_composition && (_selectiveSequentialList.count == 0)) {
                     self.targetSize = CGSizeMake(tmpPHAsset.pixelWidth, tmpPHAsset.pixelHeight);
                 }
                 [_selectiveSequentialList addObject:indexPath];
          
             }

             //去调闪的情况
             [CATransaction begin];
             [CATransaction setDisableActions:true];
             [UIView animateWithDuration:0.1 animations:^{
                 [_collection performBatchUpdates:^{
                     [_collection reloadSections:[NSIndexSet indexSetWithIndex:0]];
                 } completion:nil];
             }];
             [CATransaction commit];
             
             if (_selectiveSequentialList.count) {
                 _rightItem.enabled = true;
             } else {
                 _rightItem.enabled = false;
             }
         } else if (_type == WZVideoPickerType_browse) {
             _surfAlert = nil;
             _surfAlert = [[WZVideoSurfAlert alloc] init];
             _surfAlert.clickedBackgroundToDismiss = true;
             self.view.userInteractionEnabled = false;
             [WZMediaFetcher fetchVideoWith:tmpPHAsset synchronous:true handler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.view.userInteractionEnabled = true;
                     _surfAlert.asset = asset;
                     [_surfAlert alertShow];
                 });
             }];
             
         }
     }
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance; {
    _mediaAssetData = [NSMutableArray arrayWithArray:[WZMediaFetcher allVideosAssets]];
    //刷新
    [self setType:_type];
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
        _collection.backgroundColor = [UIColor clearColor];
        _collection.dataSource = self;
        _collection.delegate = self;
        [_collection registerClass:[WZVideoPickerCell class] forCellWithReuseIdentifier:NSStringFromClass([WZVideoPickerCell class])];
        
    }
    return _collection;
}

- (void)setType:(WZVideoPickerType)type {
    _type = type;
    self.leftItem.title = @"";
    self.rightItem.title = @"";
    //UI更替
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (type) {
            case WZVideoPickerType_browse:{
                [self.navigationController.navigationBar setTitleTextAttributes:
                 @{NSForegroundColorAttributeName:[UIColor blueColor]}];
                self.leftItem.tintColor = [UIColor blueColor];
                self.rightItem.tintColor = [UIColor blueColor];
                self.title = @"浏览模式";
                _innerMode = false;
                self.leftItem.title = @"返回";
                self.rightItem.title = @"模式选取";
                _backgroundImageView.image = [UIImage imageNamed:@"wallpaper3.jpeg"];
            } break;
            case WZVideoPickerType_pick:{
                [self.navigationController.navigationBar setTitleTextAttributes:
                 @{NSForegroundColorAttributeName:[UIColor greenColor]}];
                self.title = @"选取模式";
                _innerMode = true;
                self.leftItem.tintColor = [UIColor greenColor];
                self.rightItem.tintColor = [UIColor greenColor];
                self.leftItem.title = @"浏览模式";
                self.rightItem.title = @"选取";
                _backgroundImageView.image = [UIImage imageNamed:@"wallpaper4.jpeg"];
                
            } break;
            case WZVideoPickerType_delete:{
                [self.navigationController.navigationBar setTitleTextAttributes:
                 @{NSForegroundColorAttributeName:[UIColor redColor]}];
                self.title = @"删除模式";
                _innerMode = true;
                self.leftItem.tintColor = [UIColor redColor];
                self.rightItem.tintColor = [UIColor redColor];
                self.leftItem.title = @"浏览模式";
                self.rightItem.title = @"删除";
                _backgroundImageView.image = [UIImage imageNamed:@"wallpaper5.jpeg"];
            } break;
            case WZVideoPickerType_composition:{
                [self.navigationController.navigationBar setTitleTextAttributes:
                 @{NSForegroundColorAttributeName:[UIColor orangeColor]}];
                self.title = @"视频合并模式";
                _innerMode = true;
                self.leftItem.tintColor = [UIColor orangeColor];
                self.rightItem.tintColor = [UIColor orangeColor];
                self.leftItem.title = @"浏览模式";
                self.rightItem.title = @"开始合并";
                _backgroundImageView.image = [UIImage imageNamed:@"wallpaper2.jpeg"];
            } break;
                
            default:
                self.title = @"";
                _innerMode = false;
                break;
        }
    });
    
    [self resetStatue];
}

@end
