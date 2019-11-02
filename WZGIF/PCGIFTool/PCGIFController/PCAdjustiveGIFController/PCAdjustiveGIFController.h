//
//  PCAdjustiveGIFController.h
//  WZGIF
//
//  Created by admin on 21/7/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCGIFTool.h"

@interface PCAdjustiveGIFController : UIViewController

@property (nonatomic, strong) NSString *gifFilePath;//可外部处理GIF的保存路径
@property (nonatomic, copy) NSArray <PCGIFItem *>*dataArr;//外部传值、得到制作GIF的图片源

@end
