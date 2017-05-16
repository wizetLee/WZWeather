//
//  MainViewController.m
//  WZWeather
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "MainViewController.h"
#import <WebKit/WebKit.h>

#import <CommonCrypto/CommonDigest.h>

@protocol abc <NSObject>

@end

@interface MainViewController ()
{
    int iii;
}

@property (nonatomic, strong)  CTCallCenter *center;
@property (nonatomic, strong) NSTimer *timer;


@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.hidden = true;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self textDefine];
//    NSLog(@"%@",[UIDevice currentDevice].identifierForVendor);
//    [[UIColor jk_colorWithHex:0x000000] jk_invertedColor];
//    NSLog(@"%@",[UIDevice jk_macAddress]);
//    _center  = [[CTCallCenter alloc] init];
////    NSLog(@"%@",[_center description]);
//    __weak typeof(self) weakSelf = self;
//    _center.callEventHandler = ^(CTCall *call) {
//        NSSet<CTCall*> *callSets = weakSelf.center.currentCalls;
//        NSLog(@"%@",callSets);
//        NSLog(@"call:%@", [call description]);
//    };
    
//    NSString *str =  [[self class] sup_md5FileNameConvertedByFileName:@"哈"];
//    NSLog(@"%@", str);
    
    wz_createFile(WZSearchPathDirectoryTemporary ,@"wizet.txt", true);
    NSLog(@"%@",NSHomeDirectory());
}

+ (NSString *)sup_md5FileNameConvertedByFileName:(NSString *)name {
    const char *str = [name UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[name pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [name pathExtension]]];
    
    return filename;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    Class c = NSClassFromString(@"sViewController");
    id v = [[c alloc] init];
    [self.navigationController pushViewController:v animated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
