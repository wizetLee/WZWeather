//
//  WZLoopView.h
//  WZWeather
//
//  Created by wizet on 17/6/23.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WZLoopView;

@protocol WZLoopViewProtocol <NSObject>
@optional

- (void)loopViewDidSelectedImage:(WZLoopView *)loopView index:(int)index;

@end

@interface WZLoopViewItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSArray <NSArray *>*imagesArray;

@end

@interface WZLoopView : UIView

@property (nonatomic, weak) id<WZLoopViewProtocol> delegate;
@property (nonatomic, assign) BOOL loop;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, strong) NSArray *images;

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images loop:(BOOL)loop delay:(NSTimeInterval)timeInterval;



@end
