//
//  WZPhotoCatalogueController.h
//  WZPhotoPicker
//
//  Created by wizet on 2017/5/21.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZMediaAssetBaseCell.h"
#import "WZMediaFetcher.h"

@class WZMediaAssetCollection;


/**
 *  图片目录 cell
 */
@interface WZPhotoCatalogueCell : WZMediaAssetBaseCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) WZMediaAssetCollection *mediaAssetCollection;
@property (nonatomic, strong) void (^clickedBlock)();

@end

/**
     图片目录选择控制器
 */
@interface WZPhotoCatalogueController : UIViewController


/**
 模态出 图片目录

 @param presentedController 弹出目录所在的控制器，如果需要选择的图片回调，需要实现代理
 */
+ (void)showPickerWithPresentedController:(UIViewController <WZMediaAssetProtocol>*)presentedController;

@end
