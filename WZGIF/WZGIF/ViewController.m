//
//  ViewController.m
//  WZGIF
//
//  Created by admin on 17/7/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#import <Photos/Photos.h>
#import "WZDisplayLinkSuperviser.h"
#import "UIImage+Utility.h"
#import <MediaPlayer/MediaPlayer.h>

#import "WZCamera.h"
#import "WZCamera+Utility.h"
#import "WZCollectionItemSorter.h"
#import "PCGIFTool.h"
#import "PCPickGIFImagesController.h"
#import <GLKit/GLKit.h>

@interface ViewController ()<WZCameraProtocol>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIBarButtonItem *shotSwitchItem;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, strong) NSArray *imagesArr;
@property (nonatomic, strong) WZCamera *camera;

@end

@implementation ViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
    
    _camera = [[WZCamera alloc] init];
    _camera.delegate = self;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h =  [UIScreen mainScreen].bounds.size.height;
//    _camera.previewLayer.frame = CGRectMake(0.0, 64.0, h - w - 64.0, h - w - 64.0);
    _camera.previewLayer.frame = CGRectMake(0.0, 64.0, w, h - 64.0);
    [self.view.layer addSublayer:_camera.previewLayer];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:false];
}

#pragma mark - Create Views
- (void)createViews {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [self.view addSubview:_imageView];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setTitle:@"拍照" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [btn1 sizeToFit];
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordButton = btn2;
    [btn2 setTitle:@"录像" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(record) forControlEvents:UIControlEventTouchUpInside];
    [btn2 sizeToFit];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"开启镜头" style:UIBarButtonItemStylePlain target:self action:@selector(openTheCamera)];
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithTitle:@"合成视频" style:UIBarButtonItemStylePlain target:self action:@selector(composition)];
    
    self.navigationItem.leftBarButtonItems = @[item4, item3, item1, item2];
    _shotSwitchItem = item3;
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn3 setTitle:@"Push" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    [btn3 sizeToFit];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn3];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    

    CGFloat btnW = [UIScreen mainScreen].bounds.size.width / 4.0;
    UIButton *flashButton = [[UIButton alloc] init];
    [flashButton setTitle:@"闪光灯开" forState:UIControlStateNormal];
    flashButton.frame = CGRectMake(0.0, 0.0, btnW, 44.0);
    [flashButton addTarget:self action:@selector(flash:) forControlEvents:UIControlEventTouchUpInside];
    flashButton.layer.borderWidth = 1.0;
    
    UIButton *torchButton = [[UIButton alloc] init];
    [torchButton setTitle:@"手电筒开" forState:UIControlStateNormal];
    torchButton.frame = CGRectMake(btnW, 0.0, btnW, 44.0);
    [torchButton addTarget:self action:@selector(torch:) forControlEvents:UIControlEventTouchUpInside];
    torchButton.layer.borderWidth = 1.0;
    
    UIButton *lens = [[UIButton alloc] init];
    lens.layer.borderWidth = 1.0;
    [lens setTitle:@"前镜头" forState:UIControlStateNormal];
    lens.frame = CGRectMake(btnW * 2.0, 0.0, btnW, 44.0);
    [lens addTarget:self action:@selector(lens:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *clear = [[UIButton alloc] init];
    clear.layer.borderWidth = 1.0;
    [clear setTitle:@"清除录像" forState:UIControlStateNormal];
    clear.frame = CGRectMake(btnW * 3.0, 0.0, btnW, 44.0);
    [clear addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationController.toolbarHidden = false;
    self.navigationController.toolbar.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 44.0, [UIScreen mainScreen].bounds.size.width, 44.0);
    [self.navigationController.toolbar setBarTintColor:[UIColor orangeColor]];
    
    [self.navigationController.toolbar addSubview:flashButton];
    [self.navigationController.toolbar addSubview:torchButton];
    [self.navigationController.toolbar addSubview:lens];
    [self.navigationController.toolbar addSubview:clear];
}

//隐藏状态栏
//- (BOOL)prefersStatusBarHidden{
//    return false;
//}

#pragma mark - Navigation Items event
- (void)push {
    if (_camera.session.isRunning) {
        [self openTheCamera];
        [_recordButton setTitle:@"录像" forState:UIControlStateNormal];
    }
    
    PCPickGIFImagesController *VC =[PCPickGIFImagesController new];
    NSMutableArray *tmpMArr = [NSMutableArray array];
    if (_imagesArr) {
//        CGFloat interval = 8.0 / _imagesArr.count;//拍摄的时间/录到的图片数目;
        for (int i = 0; i < _imagesArr.count; i++) {
            WZCollectionItem *item = [[WZCollectionItem alloc] init];
            item.clearImage = _imagesArr[i];
            [tmpMArr addObject:item];
        }
    }
    VC.dataMArr = tmpMArr;
    [self.navigationController setToolbarHidden:true];
    [self.navigationController pushViewController:VC animated:true];
}

//打开镜头
- (void)openTheCamera {
    if (!_camera.session.isRunning) {
         [_camera startRunning];
        _shotSwitchItem.title = @"关闭镜头";
    } else {
        [_camera stopRunning];
        _shotSwitchItem.title = @"开启镜头";
    }
}

//拍照
- (void)takePhoto {
    if (!_camera.session.isRunning) {
        [WZToast toastWithContent:@"请打开摄像头!"];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [_camera takePhoto:^(UIImage *image, NSError *error) {
        [weakSelf savePhotoAlert:^{
            // 图片保存错误提示：Error Domain=NSCocoaErrorDomain Code=2047 "Photos Access not allowed (authorization status 0)" UserInfo={NSLocalizedDescription=Photos Access not allowed (authorization status 0)}
            //需要检查相册权限 如果没权限 提醒设置
            [ViewController savePhotoWithImage:image handler:^(BOOL success, NSError *error) {
                if (success) {
                     [WZToast toastWithContent:@"图片保存成功"];
                } else if (error) {
                    NSLog(@"图片保存错误提示：%@", error.description);
                     [WZToast toastWithContent:[NSString stringWithFormat:@"图片保存错误提示：%@", error.description]];
                }
            }];
        }];
    }];
}

//开始录像
- (void)record {
    if (!_camera.session.isRunning) {
        [WZToast toastWithContent:@"请打开摄像头!"];
        return;
    }
    if (_camera.recordStatus == WZCameraRecordStatusRecording) {
        [_recordButton setTitle:@"恢复" forState:UIControlStateNormal];
        [_camera pauseRecord];
    } else if (_camera.recordStatus == WZCameraRecordStatusPause) {
        [_recordButton setTitle:@"暂停" forState:UIControlStateNormal];
        [_camera resumeRecord];
    } else {
        [_recordButton setTitle:@"暂停" forState:UIControlStateNormal];
        [_camera startRecord];
    }
    
//    if ([_camera canRecordingMovieFile]) {
//        if (!_camera.session.isRunning) {
//            [WZToast toastWithContent:@"请打开摄像头!"];
//            return;
//        }
//        
//        if (_camera.movieFileOutput.isRecording) {
//            
//            [_camera stopRecording];
//            [_recordButton setTitle:@"录像" forState:UIControlStateNormal];
//        } else {
//            [_recordButton setTitle:@"停止" forState:UIControlStateNormal];
//            //Error Domain=AVFoundationErrorDomain Code=-11818 "已停止录制" UserInfo={AVErrorRecordingSuccessfullyFinishedKey=true, NSUnderlyingError=0x1742419b0 {Error Domain=NSOSStatusErrorDomain Code=-16414 "(null)"}, NSLocalizedRecoverySuggestion=停止其他所有使用录制设备的操作，再试一次。, NSLocalizedDescription=已停止录制}
//            //当正在录像的时候 进行拍照操作就会终止录像操作 解决方式：1、隐藏拍照入口 2、在相机内部进行拍照录像等操作互斥 推荐1咯~
//            
//            __weak typeof(self) weakSelf = self;
//            [_camera recordWithDidStartRecordingBlock:^(NSURL *fileURL, NSError *error) {
//                
//            } didFinishRecordingBlock:^(NSURL *fileURL, NSError *error) {
//                [weakSelf.recordButton setTitle:@"录像" forState:UIControlStateNormal];
//                if (error) {
//                    [WZToast toastWithContent:[NSString stringWithFormat:@"录制视频出错：%@", error.description]];
//                }
//            }];
//        }
//    } else {
//        [WZToast toastWithContent:@"不可录像状态"];
//    }
}

//闪光灯
- (void)flash:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"闪光灯开"]) {
        [sender setTitle:@"闪光灯关" forState:UIControlStateNormal];
        [self.camera flashOpen];
    } else if ([sender.titleLabel.text isEqualToString:@"闪光灯关"]) {
        [sender setTitle:@"闪光灯开" forState:UIControlStateNormal];
        [self.camera flashClose];
    }
}

//手电筒
- (void)torch:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"手电筒开"]) {
        [sender setTitle:@"手电筒关" forState:UIControlStateNormal];
        [self.camera torchOpen];
    } else if ([sender.titleLabel.text isEqualToString:@"手电筒关"]) {
        [sender setTitle:@"手电筒开" forState:UIControlStateNormal];
        [self.camera torchClose];
    }
}

//切换镜头lens:
- (void)lens:(UIButton *)sender {
    if (_camera.session.isRunning) {
        if ([sender.titleLabel.text isEqualToString:@"后镜头"]) {
            [sender setTitle:@"前镜头" forState:UIControlStateNormal];
            [self.camera lensBack];
        } else if ([sender.titleLabel.text isEqualToString:@"前镜头"]) {
            [sender setTitle:@"后镜头" forState:UIControlStateNormal];
            [self.camera lensFront];
        }
        [self.camera startRunning];
    } else {
        [WZToast toastWithContent:@"请打开摄像头"];
    }
}

//清除录像记录
- (void)clear:(UIButton *)sender {
    [_recordButton setTitle:@"录像" forState:UIControlStateNormal];
    [self.camera stopRecord];
    [WZToast toastWithContent:@"清除成功，可再次录制" position:WZToastPositionTypeBottom];
}


//合成视频 再分解为图片组
- (void)composition {
//    AVMutableComposition *composition = [WZCamera compositionWithSegments:_camera.videoRecordSegmentMArr];
//    NSLog(@"合成路径!!!:%@", composition);
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:composition];
    
    NSLog(@"等待中....................................");
    [_recordButton setTitle:@"录像" forState:UIControlStateNormal];
    [self.camera stopRecord];
}

#pragma mark - 定时器代理 WZTimeSuperviserDelegate
- (void)timeSuperviser:(WZTimeSuperviser *)timeSuperviser currentTime:(NSTimeInterval)currentTime {
    //    NSLog(@"__current:%lf", currentTime);
    int faucet = currentTime * 10;
    if (faucet % 2 == 0) {
    }
}

- (void)timeSuperviserStop {
}

#pragma mark - WZMovieWriterProtocol
- (void)movieWriter:(WZMovieWriter *)movieWriter finishWritingWithError:(NSError *)error MovieOutputURL:(NSURL *)movieOutputURL {
    if (!movieOutputURL) {
        return;
    }
   
//    _outputURL = movieOutputURL;
//    _imagesArr = [PCGIFTool divideVideoIntoImagesWithURL:_outputURL framesPerSecond:6];//10sec 6张图
    NSLog(@"视频转为图片：%ld", _imagesArr.count);
    if ([movieOutputURL isKindOfClass:[NSURL class]]) {
        NSLog(@"file data length:%ld", [NSData dataWithContentsOfURL:movieOutputURL].length);
    }
    
//    if ([movieOutputURL isKindOfClass:[NSURL class]]
//        && [[NSFileManager defaultManager] fileExistsAtPath:movieOutputURL.path]) {
//        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:movieOutputURL];
//        [[player moviePlayer] prepareToPlay];
//        [self.navigationController pushViewController:player animated:true];
//        [[player moviePlayer] play];
//    }
    
//    [_recordButton setTitle:@"录像" forState:UIControlStateNormal];
//    [WZToast toastWithContent:@"视频拆解完毕，请push到下一页设置" duration:3];
    
    
    // 保存视频
    [self saveMedia:movieOutputURL];
}

- (void)movieWriter:(WZMovieWriter *)movieWriter interruptedWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_recordButton setTitle:@"录像" forState:UIControlStateNormal];
        [_camera stopRecord];
    });
}

#pragma mark - WZOrientationProtocol
- (void)orientationMonitor:(WZOrientationMonitor *)monitor change:(UIDeviceOrientation)change {
    NSLog(@"——————%ld", change);
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//
//    [self configurationSession:^{
//        [self device:_device configuration:^{
//            
//            if ([_device hasFlash] && [_device isFlashModeSupported:AVCaptureFlashModeOn]
//                ) {
//                [_device setFlashMode:AVCaptureFlashModeOn];
//                [_device setTorchMode:AVCaptureTorchModeOn];
//            }
//        }];
//    }];
//    
//    [self configurationSession:^{
//        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]  ) {
//            [_session setSessionPreset:AVCaptureSessionPresetHigh];
//        }
//    }];
//}

#pragma mark - 保存照片
//写入图片到相册
+ (void)savePhotoWithImage:(UIImage *)image handler:(void (^)(BOOL success, NSError * error))handler {
    if ([image isKindOfClass:[UIImage class]]) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        } completionHandler:handler];
    } else {
        if (handler) {
            handler(false, [NSError errorWithDomain:@"保存非图片类型" code:-1 userInfo:nil]);
        }
    }
}

- (void)saveMedia:(NSURL *)url {
    //保存的到相册！！！
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
             NSLog(@"保存成功");
            [WZToast toastWithContent:@"保存成功" duration:3];
        } else if(error) {
            NSLog(@"error.description: %@", error.description);
        }
    }];
}

//保存照片弹窗
- (void)savePhotoAlert:(void (^)())sureHandler {
    if (sureHandler) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存到相册" message:@"需要保存到相册吗?" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"需要" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            sureHandler();
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:sure];
        [alert addAction:cancel];
        [self presentViewController:alert animated:true completion:nil];
    }
}

#pragma mark - WZCameraProtocol
//- (void)bufferImage:(UIImage *)image {
//    _imageView.image = image;
//}

- (void)recordRestrict {
    [WZToast toastWithContent:@"录制完毕，请合成视频" duration:3];
    [_recordButton setTitle:@"录制" forState:UIControlStateNormal];
}

- (void)aaa {
    GLKView *view = [[GLKView alloc] init];
    
}

- (void)camera:(WZCamera *)camera captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    //打印通道数目
//    if (outputFileURL) {
//        
//    }
    
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@(true)};//获取更加精确的时长和计时信息
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:outputFileURL options:options];

//    NSString *key1 = @"tracks";
//    NSArray *keys = @[key1];//异步加载tracks这个属性
//    NSLog(@"asset.creationDate :%@", asset.creationDate);
//    NSLog(@"asset.lyrics :%@", asset.lyrics);
//    NSLog(@"asset.commonMetadata :%@", asset.commonMetadata);//曲名、歌手、插图信息等常见元素
//    NSLog(@"asset.metadata :%@", asset.metadata);//8.0
//    NSLog(@"asset.availableMetadataFormats :%@", asset.availableMetadataFormats);
//  
//    //查询给定的属性的状态
//    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
//        NSError *error = nil;
//        AVKeyValueStatus status = [asset statusOfValueForKey:key1 error:&error];
//        switch (status) {
//            case AVKeyValueStatusLoading:
//            {
//                
//            }
//                break;
//            case AVKeyValueStatusLoaded:
//            {
//                
//            }
//                break;
//            case AVKeyValueStatusCancelled:
//            {
//                NSLog(@"AVKeyValueStatusCancelled : %@", error.debugDescription);
//            }
//                break;
//            case AVKeyValueStatusFailed:
//            case AVKeyValueStatusUnknown:
//            default://AVKeyValueStatusUnknown
//                break;
//        }
//    }];
//    
//    NSString *key2 = @"availableMetadataFormats";
//    keys = @[key2];
//    //返回一个资源中包含的所有元数据格式
//    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
//        NSMutableArray *tmpMArr = [NSMutableArray array];
//        for (NSString *formet in asset.availableMetadataFormats) {
//            [tmpMArr addObjectsFromArray:[asset metadataForFormat:formet]];
//        }
//        NSLog(@"(NSArray<AVMetadataItem *> *) %@", tmpMArr);
//     }];
//    
//    //得到一个元数据项的数组，希望找到具体的元数据的值
////    NSArray *metadata = nil;//从某处获取到元数据数组
////    NSString *keySpace = AVMetadataKeySpaceiTunes;
////    NSString *artistKey = AVMetadataiTunesMetadataKeyArtist;
////    NSString *albumKey = AVMetadataiTunesMetadataKeyAlbum;
////    NSArray <AVMetadataItem *>*artistMetadata = [AVMetadataItem metadataItemsFromArray:metadata withKey:artistKey keySpace:keySpace];
////    NSArray <AVMetadataItem *>*albumMetadata = [AVMetadataItem metadataItemsFromArray:metadata withKey:albumKey keySpace:keySpace];
//    
////    AVMetadataItem：一个封装键值对的封装器
//    AVMetadataItem *item;
    
    
    
    NSLog(@"track %@", asset.tracks);
}
@end
