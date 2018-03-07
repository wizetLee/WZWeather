//
//  WZAssetBrowseNavigationView.h
//  WZPhotoPicker
//
//  Created by wizet on 2017/6/9.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WZAssetBrowseNaviagtionProtocol <NSObject>

- (void)assetBrowseNaviagtionBackAction;//返回代理事件
- (void)assetBrowseNaviagtionSelectedAction;//选中代理事件

@end

@interface WZAssetBrowseNavigationView : UIView

@property (nonatomic, weak) id<WZAssetBrowseNaviagtionProtocol> delegate;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) UILabel *titleLabel;

+ (instancetype)customAssetBrowseNavigationWithDelegate:(id<WZAssetBrowseNaviagtionProtocol>)delegate;

@end
