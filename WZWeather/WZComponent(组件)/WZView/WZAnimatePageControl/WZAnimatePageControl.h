//
//  WZPageControl.h
//  WZWeather
//
//  Created by wizet on 9/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZAnimatePageControl;
@protocol WZAnimatePageControlProtocol <NSObject>

- (void)pageControl:(WZAnimatePageControl *)pageControl didSelectInIndex:(NSInteger)index;

@end

@interface WZAnimatePageControl : UIView

@property (nonatomic,   weak) id <WZAnimatePageControlProtocol> delegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame
              itemContentList:(NSArray <NSDictionary <NSString *, NSString *>*> *) itemContentList
                     itemSize:(CGSize)tmpItemSize;

//当前所在的角标
- (NSUInteger)currentIndex;

//带动画接口
- (void)selectedInIndex:(NSInteger)index withAnimation:(BOOL)boolean;

@end
