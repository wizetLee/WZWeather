//
//  UIApplication+JKApplicationSize.m
//  testSize
//
//  Created by Ignazio Calo on 23/01/15.
//  Copyright (c) 2015 IgnazioC. All rights reserved.
//

#import "UIApplication+JKApplicationSize.h"

@implementation UIApplication (JKApplicationSize)

- (NSString *)jk_applicationSize {
    unsigned long long docSize   =  [self jk_sizeOfFolder:[self jk_documentPath]];
    unsigned long long libSize   =  [self jk_sizeOfFolder:[self jk_libraryPath]];
    unsigned long long cacheSize =  [self jk_sizeOfFolder:[self jk_cachePath]];
    //没有算上tmp Size
    unsigned long long total = docSize + libSize + cacheSize;
    
    /**
     *   字节转换为字符串 
     */
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:total countStyle:NSByteCountFormatterCountStyleFile];
    return folderSizeStr;
}

/**
 *  获取文件路径
 *
 *  @return 文件路径
 */
- (NSString *)jk_documentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths firstObject];
    return basePath;
}

- (NSString *)jk_libraryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths firstObject];
    return basePath;
}

- (NSString *)jk_cachePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths firstObject];
    return basePath;
}



/**
 *   计算路径文件的大小
 *
 *  @param folderPath 文件路径
 *
 *  @return 文件的大小
 */
-(unsigned long long)jk_sizeOfFolder:(NSString *)folderPath
{
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    /**
     *  数组转枚举
     */
    NSEnumerator *contentsEnumurator = [contents objectEnumerator];
    
    NSString *file;
    unsigned long long folderSize = 0;
    
    while (file = [contentsEnumurator nextObject]) {
        /**
         *  读取文件的属性
         */
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:file] error:nil];
        NSLog (@"fileAttributes:%@",fileAttributes );
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }
    return folderSize;
}
@end
