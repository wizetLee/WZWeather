//
//  WZAuthorization.m
//  WZWeather
//
//  Created by admin on 17/5/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZAuthorization.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation WZAuthorization
- (void)aaaa {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    switch ([ALAssetsLibrary authorizationStatus]) {
        case ALAuthorizationStatusAuthorized:
        {
            //已授权
        }
            break;
            
        default:
        {
            [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                //已授权
            } failureBlock:^(NSError *error) {
                //无权限
            }];
        }
            break;
    }
    
    //由于是向下兼容的 可以直接用上面的做权限申请
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            //已授权
        } else {
            //无权限
        }
    }];
    
}

+ (void)requestPhotoLibraryAuthorization:(void(^)(BOOL success))handler {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    switch ([ALAssetsLibrary authorizationStatus]) {
        case ALAuthorizationStatusAuthorized: {
           handler?:handler(true); //已授权
        } break;
            
        default: {
            [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                handler?:handler(true);//已授权
            } failureBlock:^(NSError *error) {
                handler?:handler(false);//无权限
            }];
        } break;
    }
}


@end
