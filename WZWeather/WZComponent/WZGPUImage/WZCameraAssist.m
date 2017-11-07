//
//  WZCameraAssist.m
//  WZWeather
//
//  Created by admin on 7/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZCameraAssist.h"

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

@end
