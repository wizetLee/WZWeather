//
//  WZDownloadTarget.h
//  WZWeather
//
//  Created by admin on 17/5/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZDownloadTarget : NSObject

@property (nonatomic, assign) BOOL pause;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSData *resumeData;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
//@property (nonatomic, assign) NSUInteger ;//当前进度
//@property (nonatomic, assign) NSUInteger ;//任务总进度
//@property (nonatomic, assign) NSUInteger ;//任务速度

@end
