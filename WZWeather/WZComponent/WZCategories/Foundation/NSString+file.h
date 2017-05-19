//
//  NSString+file.h
//  WZWeather
//
//  Created by wizet on 17/5/16.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WZSearchPathDirectory) {
    WZSearchPathDirectoryDocument = 0,
    WZSearchPathDirectoryLibrary = 1,
    WZSearchPathDirectoryCaches = 2,
    WZSearchPathDirectoryTemporary = 3,
};


/**
 *  检查文件
 *  @param path 文件路径
 */
BOOL wz_fileExistsAtPath(NSString * path);

/**
 *  创建文件夹
 *  @param path 文件路径
 */
BOOL wz_createFolderAtPath(NSString * path);

/**
 *  检查文件
 *  @param direction 文件路径
 *  @param fileName 文件名字
 *  @param cover 文件存时是否要覆盖
 *  @return 文件存在或创建成功返回true 创建失败返回false
 */
BOOL wz_createFile(WZSearchPathDirectory direction, NSString * fileName, BOOL cover);

/**
 *  检查文件
 *  @param direction 文件路径
 *  @param folderName 文件名字
 */
BOOL wz_createFolder(WZSearchPathDirectory direction, NSString * folderName);

/**
 *  合成文件路径
 *  @param direction 文件路径
 *  @param fileName  文件名字
 *  @return 文件路径
 */
NSString * wz_filePath(WZSearchPathDirectory direction, NSString * fileName);

@interface NSString (file)



@end
