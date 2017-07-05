//
//  WZLoopView.h
//  WZWeather
//
//  Created by admin on 17/6/23.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WZLoopView;

@protocol WZProtocolLoopView <NSObject>
@optional

- (void)loopViewDidSelectedImage:(WZLoopView *)loopView index:(int)index;

@end

@interface WZLoopViewItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSArray <NSArray *>*imagesArray;

@end

@interface WZLoopView : UIView

@property (nonatomic, weak) id<WZProtocolLoopView> delegate;
@property (nonatomic, assign) BOOL loop;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, strong) NSArray *images;

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images loop:(BOOL)loop delay:(NSTimeInterval)timeInterval;



@end
