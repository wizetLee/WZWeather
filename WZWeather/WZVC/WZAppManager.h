//
//  WZAppManager.h
//  WZWeather
//
//  Created by Wizet on 17/10/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

///在app delegate 中处理事物 （初始化路径，必要的文件下载，数据库的创建， 版本数据库，路径，资料的更新）
///检测版本是否有更新过
///检测数据库是否要更新(根据后台)
@interface WZAppManager : NSObject

@end
