//
//  Demo_VideoReversalController.m
//  WZWeather
//
//  Created by admin on 27/2/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "Demo_VideoReversalController.h"
#import "AVUtilities.h"
#import "WZVideoSurfAlert.h"

@interface Demo_VideoReversalController ()
{
    AVUtilities *utilities;
}
@end

@implementation Demo_VideoReversalController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"input" ofType:@"mov"]];
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:@"WZConvertPhotosIntoVideoTool.mov"];
    asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    
//    WZVideoSurfAlert *alert = [[WZVideoSurfAlert alloc] init];
//    alert.asset = asset;
//    //是没有音轨的
//    [alert alertShow];
    
    NSString *outputFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true
                                                                   ).firstObject;
    outputFilePath = [outputFilePath stringByAppendingPathComponent:@"wizeteeeeeeee.mov"];
    utilities = [AVUtilities assetByReversingAsset:asset outputURL:[NSURL fileURLWithPath:outputFilePath]];
}

@end
