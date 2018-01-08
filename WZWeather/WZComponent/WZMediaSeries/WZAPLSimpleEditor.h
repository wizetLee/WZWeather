/*
     File: APLSimpleEditor.h
 Abstract: Simple editor setups an AVMutableComposition using supplied clips and time ranges. It also setups AVVideoComposition to add a crossfade transition.
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */
#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>
#import <AVFoundation/AVFoundation.h>



//MARK: - 自定义动画枚举
typedef NS_ENUM(NSUInteger, APLSimpleEditorTransitionType) {
    APLSimpleEditorTransitionType_None              = 0,
    APLSimpleEditorTransitionType_Fades,//或者叫 Dissolve
    APLSimpleEditorTransitionType_Push,
    APLSimpleEditorTransitionType_Wipe,
};

@class WZAPLSimpleEditor;
@protocol WZAPLSimpleEditorProtocol<NSObject>

@optional;
//合成进度
- (void)wzAPLSimpleEditor:(WZAPLSimpleEditor *)editor currentProgress:(CGFloat)progress;
//合成完成
- (void)wzAPLSimpleEditor:(WZAPLSimpleEditor *)editor exportCompleted:(NSError *)error;
//抛出状态当前选中的视频中的状态 （是否可过渡，选中的过渡类型）
- (void)wzAPLSimpleEditor:(WZAPLSimpleEditor *)editor didUpdateTypeList:(NSArray <NSNumber *>*)transitionTypeList enabeList:(NSArray <NSNumber *>*)transitionsEnabledList;

@end
/*********
 此类用于自定义视频的合成以及以及过度效果
 *************/

@interface WZAPLSimpleEditor : NSObject

// Set these properties before building the composition objects.

///即将剪切的资源片段
@property (nonatomic, readonly, retain) NSArray <AVAsset *>*clips; // array of AVURLAssets

//资源时间(asset.duration)
@property (nonatomic, readonly, retain) NSArray <NSValue *>*clipTimeRanges; // array of CMTimeRanges stored in NSValues.

@property (nonatomic, readonly, retain) AVMutableComposition *composition;
@property (nonatomic, readonly, retain) AVMutableVideoComposition *videoComposition;
@property (nonatomic, readonly, retain) AVMutableAudioMix *audioMix;

///外部设置过渡时间(单一)
@property (nonatomic) CMTime transitionDuration;

///节点过渡的类型
@property (nonatomic, strong) NSMutableArray <NSNumber *>*transitionTypeMArr;//APLSimpleEditorTransitionType
///判断节点是否可过渡
@property (nonatomic, strong) NSMutableArray <NSNumber *>*transitionsEnabledMArr;//0 1 0 1
///导出尺寸的视频的尺寸（选中视频的尺寸）
@property (nonatomic, assign, readonly) CGSize targetSize;
///代理
@property (nonatomic, weak) id<WZAPLSimpleEditorProtocol> delegate;


/// Builds the composition and videoComposition(播放 或者 重播)
- (void)buildCompositionObjectsForPlayback;

///得到PlayerItem
- (AVPlayerItem *)playerItem;

@end

//MARK: - 自定义延展
@interface WZAPLSimpleEditor (assist)

//MARK: 资源导出
/**
 导出(导出的文件路径是固定的)，文件名字根据type配置
 @param fileName 文件名
 @param handler 回调
 */
- (void)exportToSandboxDocumentWithFileName:(NSString *)fileName completionHandler:(void (^)(AVAssetExportSessionStatus statue , NSURL *fileURL))handler ;

//MARK:保存到本地
/**
 保存到本地
 @param URL 保存的资源路径
 @param handler 回调
 */
+ (void)saveVideoToLocalWithURL:(NSURL *)URL completionHandler:(void (^)(BOOL success))handler;

//MARK:整个资源更新掉 资源赋值

/**
  整个资源更新掉 资源赋值
 @param assets 资源数组
 */
- (void)updateEditorWithVideoAssets:(NSArray <AVAsset *>*)assets;

//MARK: 根据size匹配水印layer
- (CALayer *)animationToolLayerWithTargetSize:(CGSize)targetSize;

@end

