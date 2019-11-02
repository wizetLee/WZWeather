//
//  PCGIFTool.h
//  WZGIF
//
//  Created by admin on 21/7/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define PCGIFITEM_DEFAULT_INTERVAL 0.1

/**
 被用于制作GIF的帧Item
 */
@interface PCGIFItem : NSObject

@property (nonatomic, strong) UIImage *targetImage;//用于制作gif的对应的图片
@property (nonatomic, assign) NSTimeInterval interval;//gif帧之间的间隔 默认间隔是 PCGIFITEM_DEFAULT_INTERVAL 

@end

/**
 制作GIF的工具
 */
@interface PCGIFTool : NSObject

//自定义的size定制GIF （对图片的操作）
//自定义帧间隔的gif
//提供访问gif保存的路径的接口
//gif合成  拆解 更改

/**
 制作GIF接口

 @param URL 保存GIF的URL
 @param GIFItems 自定义结构 可控制若干张图的帧之间的间隔 //期望：图片尺寸均匀
 @param loopCount GIF循环的次数，一般为0
 */
+ (void)createGIFWithURL:(NSURL*)URL items:(NSArray <PCGIFItem *>*)GIFItems loopCount:(NSUInteger)loopCount;

/**
  制作GIF接口

 @param URL 保存GIF的URL
 @param images 源图片：//期望：图片尺寸均匀
 @param loopCount GIF循环的次数，一般为0
 @param linearInternal 帧之间的间隔（线性）
 */
+ (void)createGIFWithURL:(NSURL*)URL images:(NSArray <UIImage *>*)images loopCount:(NSUInteger)loopCount linearInterval:(NSTimeInterval)linearInterval;

/**
 保存路径

 @param name 文件名 (不用带.gif)
 @return 文件名所在的路径
 */
+ (NSString *)gifSavePathWithName:(NSString *)name;

/**
 视频转化为图片数组 同步操作 稍微会有点误差
 @param URL 资源视频路径
 @param framesPerSecond FPS 帧每秒
 @return 拆解出的图片
*/
+ (NSArray <UIImage *>*)divideVideoIntoImagesWithURL:(NSURL *)URL framesPerSecond:(unsigned short int)framesPerSecond;

/**
 GIF拆解 同步操作
 
 @param URL GIF文件路径
 @param handler 拆解完成的回调
 */
+ (void)destructGIFWithURL:(NSURL *)URL handler:(void (^)(NSURL *url, NSMutableArray <UIImage *>*frames, NSMutableArray <NSNumber *>*delayTimes, CGFloat totalTime, CGFloat gifWidth, CGFloat gifHeight, NSUInteger loopCount))handler;

#pragma mark - 图片尺寸裁剪
//CGSizeEqualToSize(<#CGSize size1#>, <#CGSize size2#>)
+ (UIImage *)image:(UIImage*)image ZoomToSize:(CGSize)size;
@end
