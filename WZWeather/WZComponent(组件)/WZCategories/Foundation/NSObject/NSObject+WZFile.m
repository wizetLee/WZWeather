//
//  NSObject+WZFile.m
//  WZWeather
//
//  Created by wizet on 17/6/7.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "NSObject+WZFile.h"

@implementation NSObject (WZFile)

/*
 Documents：苹果建议将程序中建立的或在程序中浏览到的文件数据保存在该目录下，iTunes备份和恢复的时候会包括此目录
 Library：存储程序的默认设置或其它状态信息；
 Library/Caches：存放缓存文件，iTunes不会备份此目录，此目录下文件不会在应用退出删除
 tmp：提供一个即时创建临时文件的地方。
 */

+ (BOOL)wz_fileExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)wz_createFolderAtPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([self wz_fileExistsAtPath:path]) {
        return true;
    } else {
        return [manager createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:nil];
        //createIntermediates:如果创建的路径的自路径不存在时，是否连同自路径一起创建 }
    }
}

+ (BOOL)wz_createFileAtPath:(NSString *)path cover:(BOOL)cover {
    if ([self wz_fileExistsAtPath:path] && !cover) {
        return true;
    }
    return [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}

+ (BOOL)wz_createFile:(WZSearchPathDirectory )direction fileName:(NSString *)fileName cover:(BOOL)cover {
    return  [self wz_createFileAtPath:[self wz_filePath:direction fileName:fileName] cover:cover];
}


+ (BOOL)wz_createFolder:(WZSearchPathDirectory)direction folderName:(NSString *)folderName {
    return [self wz_createFolderAtPath:[self wz_filePath:direction fileName:folderName]];
}

+ (NSString *)wz_filePath:(WZSearchPathDirectory)direction fileName:(NSString *)fileName {
    if (![fileName isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString *path = NSTemporaryDirectory();
    
    NSSearchPathDirectory systemDircetion = 0;
    
    switch (direction) {
        case WZSearchPathDirectoryDocument:
        {
            systemDircetion = NSDocumentDirectory;
        }   break;
        case WZSearchPathDirectoryLibrary:
        {
            systemDircetion = NSLibraryDirectory;
        }   break;
        case WZSearchPathDirectoryCaches:
        {
            systemDircetion = NSCachesDirectory;
        }   break;
        default:{   }   break;
    }
    if (systemDircetion) {
        path = NSSearchPathForDirectoriesInDomains(systemDircetion, NSUserDomainMask, true).firstObject;
    }
    
    //拼接文件路径
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    
    return filePath;
}

///配置不被系统回收，也不保存到iClound的文件属性
+ (BOOL)wz_addBackupAttributeToItemAtURL:(NSURL *)URL {
//    [NSURL fileURLWithPath:@""]
    if ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]) {
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    } else {
        return false;
    }
}

@end
