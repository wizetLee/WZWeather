//
//  WZVideoPickerController.h
//  WZWeather
//
//  Created by admin on 1/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WZVideoPickerType) {
    WZVideoPickerType_none,
    WZVideoPickerType_browse,
    WZVideoPickerType_pick,
    WZVideoPickerType_delete,
    WZVideoPickerType_composition,
};

@class WZVideoPickerController;
@protocol WZVideoPickerControllerProtocol <NSObject>

///左击
- (void)videoPickerControllerDidClickedLeftItem;
///右击
- (void)videoPickerControllerDidClickedRightItem;

@end


/** 挑选资源模式  删除资源模式
 
 
     挑选：只允许选择相同尺寸的视频进行合并? 
 */
@interface WZVideoPickerController : UIViewController



@property (nonatomic, weak) id<WZVideoPickerControllerProtocol> delegate;

//MARK:统一选中的size  用于视频合并
@property (nonatomic, assign) CGSize targetSize;
//MARK:选择的视频的顺序
@property (nonatomic, strong) NSMutableArray *selectiveSequentialList;
//MARK:模式选取
@property (nonatomic, assign) WZVideoPickerType type;

+ (void)showPickerWithPresentedController:(UIViewController <WZVideoPickerControllerProtocol>*)presentedController;


@end
