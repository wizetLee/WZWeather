//
//  UIImage+Utility.h
//  WZGIF
//
//  Created by wizet on 2017/7/23.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)

#pragma mark - 纠正图片方向
- (UIImage *)normalizedImage;
- (UIImage *)fixOrientation;

@end
