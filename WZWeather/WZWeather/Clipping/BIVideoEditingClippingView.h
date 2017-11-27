//
//  BIViewEditingClippingView.h
//  PocoCamera
//
//  Created by admin on 22/9/17.
//  Copyright © 2017年 PocoCamera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZRatioCutOutView.h"


@protocol BIVideoEditingClippingViewProtocol <NSObject>

@end

@interface BIVideoEditingClippingView : UIView

@property (nonatomic, weak) id<WZRatioCutOutViewProtocol> delegate;
@property (nonatomic, strong) AVAsset *asset;

@end
@interface BIRatioCutOutCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *coverImgView;

@end


