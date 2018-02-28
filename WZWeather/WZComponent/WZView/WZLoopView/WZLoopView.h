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

/**
    轮播图
 */
@interface WZLoopView : UIView

@property (nonatomic,   weak) id<WZLoopViewProtocol> delegate;
@property (nonatomic, assign) BOOL loop;                            //自动轮播与否
@property (nonatomic, assign) NSTimeInterval timeInterval;          //自动轮播间隔
@property (nonatomic, strong) NSArray *images;                      //写死的图片数组，应该修改为异步接收图片的模型

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images loop:(BOOL)loop delay:(NSTimeInterval)timeInterval;



@end
