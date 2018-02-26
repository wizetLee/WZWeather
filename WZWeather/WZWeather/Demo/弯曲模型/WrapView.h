//
//  WrapView.h
//  WarpDemo
//
//  Created by admin on 31/10/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WrapView : UIView

//切换 模式 按钮 放大 同时也
//tips
//每移动完成一切旋转等效果，重新获取一次模型的旧的模型的

- (UIImage *)material;
- (UIImage *)mixture;

@end
