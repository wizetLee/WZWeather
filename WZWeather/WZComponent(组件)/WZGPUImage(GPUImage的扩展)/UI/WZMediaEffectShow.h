//
//  WZMediaEffectShow.h
//  WZWeather
//
//  Created by Wizet on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
#import "GPUImageTrillColorOffsetFilter.h"
#import "GPUImageBeautifyFilter.h"

@class WZMediaEffectShow;
@interface WZMediaEffectShowCell : UICollectionViewCell

@end

@protocol WZMediaEffectShowProtocol <NSObject>

- (void)mediaEffectShowDidShrinked;
- (void)mediaEffectShow:(WZMediaEffectShow *)view didSelectedFilter:(GPUImageFilter *)filter;

@end


/**
 滤镜选择界面
 */
@interface WZMediaEffectShow : UIView

@property (nonatomic,  weak) id<WZMediaEffectShowProtocol> delegate;
@property (nonatomic,  weak) GPUImageOutput *inputSource;

- (void)showPercent:(CGFloat)percent;
- (void)caculateStatus;

@end
