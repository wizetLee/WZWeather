//
//  WZMediaEffectShow.h
//  WZWeather
//
//  Created by Wizet on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
@class WZMediaEffectShow;
@interface WZMediaEffectShowCell : UICollectionViewCell

- (void)setFilter:(GPUImageFilter *)filter;

@end

@protocol WZMediaEffectShowProtocol <NSObject>

- (void)mediaEffectShowDidShrinked;

@end

@interface WZMediaEffectShow : UIView

@property (nonatomic, weak) id<WZMediaEffectShowProtocol> delegate;

- (void)showPercent:(CGFloat)percent;
- (void)caculateStatus;

@end
