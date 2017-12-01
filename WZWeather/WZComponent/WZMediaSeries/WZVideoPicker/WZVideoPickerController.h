//
//  WZVideoPickerController.h
//  WZWeather
//
//  Created by admin on 1/12/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZVideoPickerController;
@protocol WZVideoPickerControllerProtocol <NSObject>

///左击
- (void)videoPickerControllerDidClickedLeftItem;
///右击
- (void)videoPickerControllerDidClickedRightItem;

@end

@interface WZVideoPickerController : UIViewController

@property (nonatomic, weak) id<WZVideoPickerControllerProtocol> delegate;

+ (void)showPickerWithPresentedController:(UIViewController <WZVideoPickerControllerProtocol>*)presentedController;


@end
