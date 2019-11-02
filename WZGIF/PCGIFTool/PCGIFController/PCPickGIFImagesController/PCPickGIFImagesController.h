//
//  PCPickGIFImagesController.h
//  WZGIF
//
//  Created by wizet on 2017/7/30.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCGIFTool.h"

@class WZCollectionItem;
@interface PCPickGIFImagesController : UIViewController

@property (nonatomic, strong) NSMutableArray <WZCollectionItem *>*dataMArr;//可外部提供collection需要展示的图片

@end
