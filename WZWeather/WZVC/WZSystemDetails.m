//
//  WZSystemDetails.m
//  WZWeather
//
//  Created by wizet on 29/9/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZSystemDetails.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <mach/mach.h>

// MARK: - 系统接口



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

@implementation WZSystemDetails
// 系统版本等于
+ (BOOL)systemVersionEqualTo:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedSame;
}

// 系统版本大于
+ (BOOL)systemVersionGreaterThan:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedDescending;
}

// 系统版本大于或等于
+ (BOOL)systemVersionGreaterThanOrEqualTo:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending;
}

// 系统版本小于
+ (BOOL)systemVersionLessThan:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending;
}

// 系统版本等于或小于
+ (BOOL)systemVersionLessThanOrEqualTo:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedDescending;
}

+ (NSString *)platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    return platform;
}

+ (NSString *)platformString {
    NSString *platform = [self platform];
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
    if ([platform isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
    if ([platform isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
    if ([platform isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
    if ([platform isEqualToString:@"iPhone10,3"])   return @"iPhone_X";
    if ([platform isEqualToString:@"iPhone10,6"])   return @"iPhone_X";
    
    // iPod
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    
    // iPad
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (GSM)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air (CDMA)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (Cellular)";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (Cellular)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7-inch (WiFi)";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7-inch (Cellular)";
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9-inch (WiFi)";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9-inch (Cellular)";
    
    // Apple Watch
    if ([platform isEqualToString:@"Watch1,1"])     return @"Apple Watch 38mm";
    if ([platform isEqualToString:@"Watch1,2"])     return @"Apple Watch 42mm";
    
    // Apple TV
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3G";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3G";
    
    // 虚拟机
    if ([platform isEqualToString:@"i386"])         return [UIDevice currentDevice].model;
    if ([platform isEqualToString:@"x86_64"])       return [UIDevice currentDevice].model;
    
    return platform;
}

// 大于或等于iphone platform 的版本
+ (BOOL)largerOrEqualToIPhonePlatformWithIndex0:(NSInteger)index0 index1:(NSInteger)index1 {
    NSString *platform = [self platform];
    if ([platform containsString:@"iPhone"]) {
        NSString *str = [platform stringByReplacingOccurrencesOfString:@"iPhone" withString:@""];
        NSArray *strs = [str componentsSeparatedByString:@","];
        if (strs && strs.count == 2) {
            NSString *indexStr0 = strs[0];
            NSString *indexStr1 = strs[1];
            NSInteger tmpIndex0 = [indexStr0 integerValue];
            NSInteger tmpIndex1 = [indexStr1 integerValue];
            
            if (tmpIndex0 >= index0) {
                if (tmpIndex1 >= index1) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

+ (BOOL)largerOrEqualToIPadPlatformWithIndex0:(NSInteger)index0 index1:(NSInteger)index1 {
    NSString *platform = [self platform];
    if ([platform containsString:@"iPad"]) {
        NSString *str = [platform stringByReplacingOccurrencesOfString:@"iPad" withString:@""];
        NSArray *strs = [str componentsSeparatedByString:@","];
        if (strs && strs.count == 2) {
            NSString *indexStr0 = strs[0];
            NSString *indexStr1 = strs[1];
            NSInteger tmpIndex0 = [indexStr0 integerValue];
            NSInteger tmpIndex1 = [indexStr1 integerValue];
            
            if (tmpIndex0 >= index0) {
                if (tmpIndex1 >= index1) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

// 大于或等于iphone7
+ (BOOL)largerOrEqualToIPhone7 {
    return [self largerOrEqualToIPhonePlatformWithIndex0:9 index1:1];
}

+ (BOOL)isiPad {
    @try {
        if ([[[self platform] substringToIndex:4] isEqualToString:@"iPad"]) {
            return YES;
        } else {
            return NO;
        }
    } @catch (NSException *exception) {
        
    }
    
    return NO;
}

+ (BOOL)isiPhone {
    @try {
        if ([[[self platform] substringToIndex:6] isEqualToString:@"iPhone"]) {
            return YES;
        } else {
            return NO;
        }
    } @catch (NSException *exception) {
        
    }
    
    return NO;
}

+ (BOOL)isiPod {
    @try {
        if ([[[self platform] substringToIndex:4] isEqualToString:@"iPod"]) {
            return YES;
        } else {
            return NO;
        }
    } @catch (NSException *exception) {
        
    }
    
    return NO;
}

+ (BOOL)isAppleTV {
    @try {
        if ([[[self platform] substringToIndex:7] isEqualToString:@"AppleTV"]) {
            return YES;
        } else {
            return NO;
        }
    } @catch (NSException *exception) {
        
    }
    
    return NO;
}

+ (BOOL)isAppleWatch {
    @try {
        if ([[[self platform] substringToIndex:5] isEqualToString:@"Watch"]) {
            return YES;
        } else {
            return NO;
        }
    } @catch (NSException *exception) {
        
    }
    
    return NO;
}

+ (BOOL)isSimulator {
    @try {
        if ([[self platform] isEqualToString:@"i386"] || [[self platform] isEqualToString:@"x86_64"]) {
            return YES;
        } else {
            return NO;
        }
    } @catch (NSException *exception) {
        
    }
    
    return NO;
}

// ios版本
+ (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

// 系统名称
+ (NSString *)systemName {
    return [[UIDevice currentDevice] systemName];
}

+ (NSUInteger)getSysInfo:(uint)typeSpecifier {
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

+ (NSUInteger)cpuFrequency {
    return [self getSysInfo:HW_CPU_FREQ];
}

+ (NSUInteger)busFrequency {
    return [self getSysInfo:HW_TB_FREQ];
}

+ (NSUInteger)ramSize {
    return [self getSysInfo:HW_MEMSIZE];
}

+ (NSUInteger)cpuNumber {
    return [self getSysInfo:HW_NCPU];
}

+ (NSUInteger)totalMemory {
    return [self getSysInfo:HW_PHYSMEM];
}

+ (NSUInteger)userMemory {
    return [self getSysInfo:HW_USERMEM];
}

+ (NSUInteger)availableMemory {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return vm_page_size * vmStats.free_count;
}

+ (NSUInteger)taskMemory {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size;
}

+ (NSNumber *)totalDiskSpace {
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [attributes objectForKey:NSFileSystemSize];
}

+ (NSNumber *)freeDiskSpace {
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [attributes objectForKey:NSFileSystemFreeSize];
}

+ (NSString *)generateUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge_transfer NSString *)string;
}

+ (BOOL)isRetina {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0 || [UIScreen mainScreen].scale == 3.0)) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isRetinaHD {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 3.0)) {
        return YES;
    } else {
        return NO;
    }
}

+ (CGSize)fixedScreenSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    return screenSize;
}
@end
