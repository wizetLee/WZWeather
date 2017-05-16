//
//  NSString+file.m
//  WZWeather
//
//  Created by admin on 17/5/16.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "NSString+file.h"

/*
 Documents：苹果建议将程序中建立的或在程序中浏览到的文件数据保存在该目录下，iTunes备份和恢复的时候会包括此目录
 Library：存储程序的默认设置或其它状态信息；
 Library/Caches：存放缓存文件，iTunes不会备份此目录，此目录下文件不会在应用退出删除
 tmp：提供一个即时创建临时文件的地方。
 */

BOOL wz_fileExistsAtPath(NSString * path) {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

BOOL wz_createFolderAtPath(NSString * path) {
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL boolean = false;
    if (wz_fileExistsAtPath(path)) {
        boolean = true;
    } else {
        NSError *error = nil;
        if ([manager createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:&error]) {
            //createIntermediates:如果创建的路径的自路径不存在时，是否连同自路径一起创建
            boolean = true;
        }
    }
    return boolean;
}

BOOL wz_createFileAtPath(NSString * path, BOOL cover) {
    if (wz_fileExistsAtPath(path) && !cover) {
        return true;
    }
    return [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}

BOOL wz_createFile(WZSearchPathDirectory direction, NSString * fileName, BOOL cover) {
    return wz_createFileAtPath(wz_filePath(direction, fileName), cover);
}

BOOL wz_createFolder(WZSearchPathDirectory direction, NSString * folderName) {
    return wz_createFolderAtPath(wz_filePath(direction, folderName));
}

NSString * wz_filePath(WZSearchPathDirectory direction, NSString * fileName) {
    if (![fileName isKindOfClass:[NSString class]]) {
        return false;
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


@implementation NSString (file)

@end
