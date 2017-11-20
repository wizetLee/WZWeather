//
//  WZSearchBar.h
//  WZSearchBar
//
//  Created by admin on 16/10/19.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZSearchBar : UISearchBar

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, assign) BOOL useClearBtn;
@property (nonatomic, strong, readonly) UIButton *clearButton;
@property (nonatomic, strong) void (^clickedClearButton)();
/*
 *
 *  系统searchBar中的UISearchBarTextField的高度默认固定为28
 *  左右边距固定为8，上下边距是父控件view的高度减去28除以2
 */

//使用前需要设置useClearBtn  并且给他自定义一个Image 否则显示grayColor
- (void)clearButtonHidden:(BOOL)hidden;
@end

