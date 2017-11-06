//
//  WZVariousBaseCell.h
//  WZVariousTable
//
//  Created by wizet on 17/3/3.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WZVariousBaseObject;
@class WZVariousBaseCell;
#define VARIOUS_ORIGINDATA @"WZVarious_originData"


@protocol  WZVariousViewDelegate<NSObject>

- (void)variousView:(UIView *)view param:(NSDictionary *)param;

@end

@interface WZVariousBaseCell : UITableViewCell

@property (nonatomic, weak) id<WZVariousViewDelegate> variousViewDelegate;
@property (nonatomic, weak) UIViewController *locatedController;
@property (nonatomic, strong) WZVariousBaseObject *data;
@property (nonatomic, strong) UILongPressGestureRecognizer *gesture;

+ (CGFloat)heightForData:(WZVariousBaseObject *)obj;

- (void)isLastElement:(BOOL)boolean;
- (void)singleClicked;

- (void)longPressedUseable:(BOOL)boolean;
- (void)longPress:(UILongPressGestureRecognizer *)longPress;
@end
