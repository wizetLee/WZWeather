//
//  WZMediaController.m
//  WZWeather
//
//  Created by admin on 17/10/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaController.h"
#import "WZGPUImageStillCamera.h"///静态图 动态录像
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSUInteger, WZMediaType) {
    WZMediaTypeStillImage,
    WZMediaTypeVideo,
};


@interface WZMediaController ()
{
    BOOL sysetmNavigationBarHiddenState;
}

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@property (nonatomic, strong) WZGPUImageStillCamera *camera;//静态图 以及录像
@property (nonatomic, assign) WZMediaType mediaType;

@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;

@property (nonatomic, strong) GPUImageView *presentView;


///------------------随便搭的UI
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *pickBtn;

@end

@implementation WZMediaController

#pragma mark - ViewController Lifecycle

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (instancetype)init {
    if (self = [super init]) {}
    return self;
}

- (void)loadView {
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.backgroundColor = [UIColor whiteColor];
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
  
    CGFloat y = 0.0;
    if (@available(iOS 11.0, *)) {
        y = self.view.safeAreaInsets.bottom;
        NSLog(@"%@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    } else {
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController) {
        sysetmNavigationBarHiddenState = self.navigationController.navigationBarHidden;
        self.navigationController.navigationBarHidden = true;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = sysetmNavigationBarHiddenState;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Public Method
- (void)createViews {
    //适配iOS 11
    
    CGFloat topH = 0.0, bottomH = 0.0;
    if (@available(iOS 11.0, *)) {
        if (MACRO_SYSTEM_IS_IPHONE_X) {
            topH = 24.0;
            bottomH = 34.0;
        }
    }
    _presentView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_presentView];
    [self assembleStillImage];
    
    _closeBtn = [[UIButton alloc] init];
    _closeBtn.frame = CGRectMake(0.0, topH, 44.0 * 2, 44.0);
    [_closeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    _closeBtn.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_closeBtn];
    [_closeBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _pickBtn = [[UIButton alloc] init];
    _pickBtn.frame = CGRectMake(0.0, MACRO_FLOAT_SCREEN_HEIGHT - bottomH - 44.0, 44.0 * 2, 44.0);
    _pickBtn.center = CGPointMake(MACRO_FLOAT_SCREEN_WIDTH / 2.0, _pickBtn.center.y);
    [_pickBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_pickBtn setTitle:@"拍照" forState:UIControlStateNormal];
    _pickBtn.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_pickBtn];
    [_pickBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)clickedBtn:(UIButton *)sender {
    if (sender == _closeBtn) {
        [_camera stopCameraCapture];
        [self.navigationController popViewControllerAnimated:true];
    } else if (sender == _pickBtn) {
      
    }
}

#pragma mark -
///切换为相机
- (void)assembleStillImage {
    _mediaType = WZMediaTypeStillImage;
    //首次 高画质 背面配置
    AVCaptureSessionPreset preset = AVCaptureSessionPresetHigh;
    AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
    _camera = [[WZGPUImageStillCamera alloc] initWithSessionPreset:preset cameraPosition:position];
//    [_camera startCameraCapture];
//    [_camera stopCameraCapture];
    
    _camera.outputImageOrientation = UIInterfaceOrientationPortrait;//拍照方向
    ///前后摄像头镜像配置
    _camera.horizontallyMirrorFrontFacingCamera = false;
    _camera.horizontallyMirrorRearFacingCamera = false;
    
    _filter = [[GPUImageSepiaFilter alloc] init];//褐色滤镜;
    
 
    
    
    ///
//    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
//    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:movieURL.path]) {
//        [[NSFileManager defaultManager] removeItemAtURL:movieURL error: nil];
//    }
//    CGSize outputSize = CGSizeMake(480.0, 640.0);
//    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:outputSize];
//    _movieWriter.encodingLiveVideo = true;
//
//    [_camera addTarget:_filter];//成链
//    [_filter addTarget:_movieWriter];
//    [_filter addTarget:_presentView];
//
//    //开始录像
    
    [_camera addTarget:_presentView];//成链
    [_camera startCameraCapture];
    
    ///延迟0.5s
//    double delayToStartRecording = 0.5;
//    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
//    dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
//        NSLog(@"Start recording");
//
//        _camera.audioEncodingTarget = _movieWriter;
//        [_movieWriter startRecording];
//
//        //        NSError *error = nil;
//        //        if (![videoCamera.inputCamera lockForConfiguration:&error])
//        //        {
//        //            NSLog(@"Error locking for configuration: %@", error);
//        //        }
//        //        [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
//        //        [videoCamera.inputCamera unlockForConfiguration];
//
//        double delayInSeconds = 10.0;
//        dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
//
//            [_filter removeTarget:_movieWriter];
//            _camera.audioEncodingTarget = nil;
//            [_movieWriter finishRecording];
//            NSLog(@"Movie completed");
//
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//            if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:movieURL])
//            {
//                [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error)
//                 {
//                     dispatch_async(dispatch_get_main_queue(), ^{
//
//                         if (error) {
//                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
//                                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                             [alert show];
//                         } else {
//                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
//                                                                            delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                             [alert show];
//                         }
//                     });
//                 }];
//            }
//        });
//    });
}
                       
//切换为视频模式
- (void)assembleVideo {
    _mediaType = WZMediaTypeVideo;
    
}



@end
