//
//  WZSystemDetails.h
//  WZWeather
//
//  Created by wizet on 29/9/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
///根据userDefault中的一个字段 以及 当前版本去判断
typedef NS_ENUM(NSUInteger, WZAppInstallType) {
    ///正常状态
    WZAppInstallTypeNormal,
    ///首次安装
    WZAppInstallTypeFirst,
    ///升级或降级
    WZAppInstallTypeUpgradeOrDowngrade,
};

/** 应用程序发布版本号 第一个整数代表重大修改的版本，如实现新的功能或重大变化的修订。 第二个整数表示的修订，实现较突出的特点。 第三个整数代表维护版本。该键的值不同于CFBundleVersion标识。 */
NSString * appVersion();
/** 应用程序内部标示 用以记录开发版本的，每次更新的时候都需要比上一次高 优势体现在测试时出现bug，可定位出现问题的build */
NSString * appBuild();
///应用的BundleID
NSString * appBundleID();
///APP的状态 用作APP启动的时候的特殊用途
WZAppInstallType appInstallType();








@interface WZSystemDetails : NSObject
/// 系统版本等于
+ (BOOL)systemVersionEqualTo:(NSString *)version;

/// 系统版本大于
+ (BOOL)systemVersionGreaterThan:(NSString *)version;

/// 系统版本大于或等于
+ (BOOL)systemVersionGreaterThanOrEqualTo:(NSString *)version;

/// 系统版本小于
+ (BOOL)systemVersionLessThan:(NSString *)version;

/// 系统版本等于
+ (BOOL)systemVersionLessThanOrEqualTo:(NSString *)version;

/// 设备（最基本的）
+ (NSString *)platform;

/// 设备 （具体的）
+ (NSString *)platformString;


/// 大于或等于iphone platform 的版本
+ (BOOL)largerOrEqualToIPhonePlatformWithIndex0:(NSInteger)index0 index1:(NSInteger)index1;

/// 大于或等于iPad platform 的版本
+ (BOOL)largerOrEqualToIPadPlatformWithIndex0:(NSInteger)index0 index1:(NSInteger)index1;

/// 大于或等于iphone
+ (BOOL)largerOrEqualToIPhone7;

//+ (BOOL)largerOrEqualToIPad;

/// 是否ipad
+ (BOOL)isiPad;

/// 是否iphone
+ (BOOL)isiPhone;

/// 是否ipod
+ (BOOL)isiPod;

/// 是否appleTV
+ (BOOL)isAppleTV;

/// 是否appleWatch
+ (BOOL)isAppleWatch;

/// 是否模拟器
+ (BOOL)isSimulator;

/// ios版本
+ (NSString *)systemVersion;

/// 系统名称
+ (NSString *)systemName;

/// 获取系统信息
+ (NSUInteger)getSysInfo:(uint)typeSpecifier;

/// cup频率
+ (NSUInteger)cpuFrequency;

/// 总线频率
+ (NSUInteger)busFrequency;

/// ram的大小
+ (NSUInteger)ramSize;

/// cpu核数
+ (NSUInteger)cpuNumber;

/// 内存总的大小(单位：B）
+ (NSUInteger)totalMemory;

/// 用户的内存大小(单位：B）
+ (NSUInteger)userMemory;

/// 获取当前设备可用内存(单位：B）
+ (NSUInteger)availableMemory;

/// 获取当前任务所占用的内存（单位：B）
+ (NSUInteger)taskMemory;

/// 磁盘的总空间
+ (NSNumber *)totalDiskSpace;

/// 磁盘的可用空间
+ (NSNumber *)freeDiskSpace;

/// 生成一个唯一码
+ (NSString *)generateUUID;

/// 是否retina屏
+ (BOOL)isRetina;

/// 是否retinaHD屏
+ (BOOL)isRetinaHD;

/// 固定屏幕size
+ (CGSize)fixedScreenSize;


@end


