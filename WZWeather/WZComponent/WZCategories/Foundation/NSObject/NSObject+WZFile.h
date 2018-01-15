//
//  NSObject+WZFile.h
//  WZWeather
//
//  Created by wizet on 17/6/7.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WZSearchPathDirectory) {
    WZSearchPathDirectoryDocument           = 0,
    WZSearchPathDirectoryLibrary            = 1,
    WZSearchPathDirectoryCaches             = 2,
    WZSearchPathDirectoryTemporary          = 3,
};

@interface NSObject (WZFile)
/**
 *  检查文件
 *  @param path 文件路径
 */
+ (BOOL)wz_fileExistsAtPath:(NSString *)path;

/**
 *  创建文件夹
 *  @param path 文件路径
 */
+ (BOOL)wz_createFolderAtPath:(NSString *)path;

/**
 *  检查文件
 *  @param direction 文件路径
 *  @param fileName 文件名字
 *  @param cover 文件存时是否要覆盖
 *  @return 文件存在或创建成功返回true 创建失败返回false
 */
+ (BOOL)wz_createFileAtPath:(NSString *)path cover:(BOOL)cover;

///默认覆盖文件
+ (BOOL)wz_createFolder:(WZSearchPathDirectory)direction folderName:(NSString *)folderName ;

/**
 *  检查文件
 *  @param direction 文件路径
 *  @param folderName 文件名字
 */
+ (BOOL)wz_createFile:(WZSearchPathDirectory )direction fileName:(NSString *)fileName cover:(BOOL)cover;

/**
 *  合成文件路径
 *  @param direction 文件路径
 *  @param fileName  文件名字
 *  @return 文件路径
 */
+ (NSString *)wz_filePath:(WZSearchPathDirectory)direction fileName:(NSString *)fileName;

///配置不被系统回收，也不保存到iClound的文件属性
+ (BOOL)wz_addBackupAttributeToItemAtURL:(NSURL *)URL;

/*iOS 数据存储指导方针：https://developer.apple.com/icloud/documentation/data-storage/index.html
 
 iCloud包括了备份，会通过Wi-Fi每天自动备份用户iOS设备。app的home目录下的所有东西都会被备份，除了应用Bundle本身、缓存目录和temp目录。已购买的音乐、应用、书籍、Camera Roll、设备设置、主屏幕、App组织、消息、铃声也都会被备份。由于备份通过无线进行，并且为每个用户存储在iCloud中，应用需最小化自己存储的数据数量。大文件会延长备份时间，并且消耗用户的可用iCloud空间。
 
 为了确保备份尽可能快速高效，应用存储数据需要遵循以下指导方针：
 1. 只有那些用户生成的文档或其它数据，或者应用不能重新创建的数据，才应该存储在<Application_Home>/Documents目录下，并且会被自动备份到iCloud。
 
 2. 可以重新下载或生成的数据，应该存储在<Application_Home>/Library/Caches目录。例如数据库缓存文件、可下载文件（杂志、报纸、地图应用使用的数据）等都属于这一类。
 
 3. 临时使用的数据应该存放在<Application_Home>/tmp目录。尽管这些文件不会被iCloud备份，应用在使用完之后需要记得删除这些文件，这样才不会继续占用用户设备的空间。
 
 什么时候用到"不要备份"属性呢？
 4. 使用"不要备份"属性来指定那些需要保留在设备中的文件（即使是低存储空间情况下，也就是必须要保留的文件要使用到这个属性）。那些能够重新生成，但在低存储空间时仍需保留，对应用正常运行有影响，或者用户希望文件在离线时可用的文件，需要使用这个属性。无论哪个目录下的文件（包括Documents目录），都可以使用这个属性。这些文件不会被删除，也不会包含在用户的iCloud或iTunes备份中。由于这些文件一直占用着用户设备的存储空间，应用有责任定期监控和删除这些文件。
*/


@end
