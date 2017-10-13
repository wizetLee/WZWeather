//
//  WZSystemDetails.h
//  WZWeather
//
//  Created by admin on 29/9/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZSystemDetails : NSObject

@end

// MARK: - 系统接口

///根据userDefault中的一个字段 以及 当前版本去判断
typedef NS_ENUM(NSUInteger, WZAppInstallType) {
    ///正常状态
    WZAppInstallTypeNormal,
    ///首次安装
    WZAppInstallTypeFirst,
    ///升级或降级
    WZAppInstallTypeUpgradeOrDowngrade,
};



/**
 应用程序发布版本号
 第一个整数代表重大修改的版本，如实现新的功能或重大变化的修订。
 第二个整数表示的修订，实现较突出的特点。
 第三个整数代表维护版本。该键的值不同于CFBundleVersion标识。
 */
NSString * appVersion() {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: @"1.0.0";
}

/**
 应用程序内部标示
 用以记录开发版本的，每次更新的时候都需要比上一次高
 优势体现在测试时出现bug，可定位出现问题的build
 */
NSString * appBuild() {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: @"1.0.0";
}

///应用的BundleID
NSString * appBundleID() {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey] ?: @"bundleID_is_Empty";
}

///APP的状态 用作APP启动的时候的特殊用途
WZAppInstallType appInstallType() {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"WZ_APP_VERSION"]) {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"WZ_APP_VERSION"] isEqualToString:appVersion()]) {
            return WZAppInstallTypeNormal;
        } else {
            ///更新版本号
            [[NSUserDefaults standardUserDefaults] setValue:appVersion() forKey:@"WZ_APP_VERSION"];
            [[NSUserDefaults standardUserDefaults]  synchronize];
            return WZAppInstallTypeUpgradeOrDowngrade;
        }
    } else {
        ///首次安装
        [[NSUserDefaults standardUserDefaults] setValue:appVersion() forKey:@"WZ_APP_VERSION"];
        [[NSUserDefaults standardUserDefaults]  synchronize];
        return WZAppInstallTypeFirst;
    }
}
