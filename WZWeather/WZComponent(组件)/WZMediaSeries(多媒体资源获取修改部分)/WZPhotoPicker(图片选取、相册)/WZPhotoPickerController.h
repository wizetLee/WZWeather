//
//  WZPhotoPickerController.h
//  WZPhotoPicker
//
//  Created by wizet on 2017/5/19.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZMediaFetcher.h"

/**
 图片挑选
 */
@interface WZPhotoPickerController : UIViewController

/**
 回到代理
 */
@property (nonatomic, weak) id<WZMediaAssetProtocol> delegate;

/**
 固定类型的数据源
 */
@property (nonatomic, strong) NSArray <WZMediaAsset *>* mediaAssetArray;

/**
 限制选取图片的数目
 */
@property (nonatomic, assign) NSUInteger restrictNumber;

@end
