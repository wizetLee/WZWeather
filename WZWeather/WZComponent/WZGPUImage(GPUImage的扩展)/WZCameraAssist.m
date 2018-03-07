//
//  WZCameraAssist.m
//  WZWeather
//
//  Created by wizet on 7/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZCameraAssist.h"
#import <Photos/Photos.h>

@implementation WZCameraAssist

#pragma mark - 去除系统声音（添加文件时勾选add to target）
+ (void)removeSystemSound {
    static SystemSoundID soundID;
    if (soundID == 0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"photoShutter2" ofType:@"caf"];
        NSAssert(path, @"资源文件缺失");
        if (path) {
            NSURL *filePath = [NSURL fileURLWithPath:path];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
        } else {
            NSLog(@"去除系统声音路径为空");
        }
    }
    AudioServicesPlaySystemSound(soundID);
}


#pragma mark - 从图片中直接读取二维码 iOS8.0
+ (NSString *)scQRReaderForImage:(UIImage *)qrimage {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:qrimage.CGImage];
    NSArray *features = [detector featuresInImage:image];
    CIQRCodeFeature *feature = [features firstObject];
    NSString *result = feature.messageString;
    return result;
}

#pragma mark - 权限识别接口
+ (void)checkAuthorizationWithHandler:(void (^)(BOOL videoAuthorization, BOOL audioAuthorization, BOOL libraryAuthorization))handler {
    
    if (TARGET_IPHONE_SIMULATOR) {
        [WZToast toastWithContent:@"请使用iPhone真机测试"];
        return;
    }
    
    if (!handler) {
        return;
    }
    __block BOOL video = false;
    __block BOOL audio = false;
    __block BOOL library = false;
    
    [self videoAuthorization:^(BOOL granted) {
        video = granted;
        [self audioAuthorization:^(BOOL granted1) {
            audio = granted1;
            [self libraryAuthorization:^(BOOL granted2) {
                library = granted2;
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(video, audio, library);
                });
            }];
        }];
    }];
}

#pragma mark - 视频权限请求
+ (void)videoAuthorization:(void (^)(BOOL granted))handler {
    if (!handler) {return;}
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];//相机权限
    if (videoStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {//相机权限
            handler(granted);
        }];
    } else if(videoStatus == AVAuthorizationStatusNotDetermined
              || videoStatus == AVAuthorizationStatusRestricted) {
        //到设置区设置
        handler(false);
    } else {
        handler(true);
    }
}

#pragma mark - 音频权限请求
+ (void)audioAuthorization:(void (^)(BOOL granted))handler {
    if (!handler) {return;}
    AVAuthorizationStatus audiostatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];//麦克风权限
    if (audiostatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {//相机权限
            handler(granted);
        }];
    } else if(audiostatus == AVAuthorizationStatusNotDetermined
              || audiostatus == AVAuthorizationStatusRestricted) {
        handler(false);
    } else {
        handler(true);
    }
}

#pragma mark - 相册权限请求
+ (void)libraryAuthorization:(void (^)(BOOL granted))handler {
    if (!handler) {return;}
    PHAuthorizationStatus libraryStatus = [PHPhotoLibrary authorizationStatus];
    if (libraryStatus == PHAuthorizationStatusNotDetermined) {
        __block BOOL library = false;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                library = true;
            }
            handler(library);
        }];
    } else if (libraryStatus == PHAuthorizationStatusRestricted
               || libraryStatus == PHAuthorizationStatusDenied) {
        handler(false);
    } else {
        handler(true);
    }
}



/**
   wifi  7\8\9  @"prefs:root=WIFI"
         10     @"APP-Prefs:root=WIFI"
 */

/**
 进入app设置页面
 */
+ (void)openAppSettings {
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
              [[UIApplication sharedApplication] openURL:url];
        } else {
            NSLog(@"无法打开设置");
        }
}


#warning  有点问题
+ (void)openAppWithScheme_iOS_10:(NSURL *)url {
        if (@available(iOS 10.0, *)) {
            ///UIApplicationOpenSettingsURLString 无效
            NSDictionary *option = @{UIApplicationOpenURLOptionUniversalLinksOnly : @(true)};
            [[UIApplication sharedApplication] openURL:url options:option completionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"成功");
                } else {
                    NSLog(@"失败");
                }
            }];
        } else {
        }
}

+ (void)showAlertByVC:(UIViewController *)VC {
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"视频、音频、相册权限受阻" message:@"是否要到设置处进行权限设置" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [WZCameraAssist openAppSettings];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alter dismissViewControllerAnimated:true completion:nil];
    }];
    [alter addAction:actionSure];
    [alter addAction:actionCancel];
    [VC presentViewController:alter animated:true completion:nil];

}

@end
