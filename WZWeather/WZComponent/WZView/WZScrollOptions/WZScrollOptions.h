//
//  WZScrollOptions.h
//  WZWeather
//
//  Created by wizet on 2017/7/1.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZScrollOptionsItem : NSObject

@end

@interface WZScrollOptionsCell : UICollectionViewCell

@end

@class WZScrollOptions;
@protocol WZProtocol_scrollOptions <NSObject>

/**
 菜单按钮点击时回调
 
 @param scrollMenuView 带单view
 @param index 所点按钮的index
 */
- (void)scrollOptions:(WZScrollOptions *)scrollOptions clickedAtIndex:(NSInteger)index;

@end

@interface WZScrollOptions : UIView

@property (nonatomic, strong) NSArray <WZScrollOptionsItem *> *itemArray;

@end
