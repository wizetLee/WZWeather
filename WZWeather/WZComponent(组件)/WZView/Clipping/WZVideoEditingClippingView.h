//
//  BIViewEditingClippingView.h
//  PocoCamera
//
//  Created by admin on 22/9/17.
//  Copyright © 2017年 PocoCamera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZRatioCutOutView.h"

#define WZVideoAssetEditableRestrict 10.0  //可剪辑的范围为2sec   外部也要支持这个格式

/*
 参照于  like可剪辑范围不小于2sec  如果asset 小于 2sec则会跳过可剪裁页面
        印象的可剪辑范围是1sec
 */

@protocol WZVideoEditingClippingViewProtocol <NSObject>

@end

//MARK:- WZVideoEditingClippingView
@interface WZVideoEditingClippingView : UIView

@property (nonatomic,   weak) id<WZRatioCutOutViewProtocol> delegate;
@property (nonatomic, strong) AVAsset *asset;


@end

//MARK:- BIRatioCutOutCollectionCell
@interface BIRatioCutOutCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *coverImgView;

@end


