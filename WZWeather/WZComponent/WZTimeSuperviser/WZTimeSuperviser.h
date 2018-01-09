//
//  WZTimeSuperviser.h
//  WZWeather
//
//  Created by wizet on 17/5/3.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WZTimeSuperviser;

@protocol  WZTimeSuperviserDelegate <NSObject>

/**
 * 跳出APP时（锁屏时），计时器时间的计算  --跳出获取时间戳，进入app获取时间戳，得到时间差，直接跳到时间差
 * 跳出屏幕时再回来，应当是停止操作抑或是继续走定时器（此类的处理方式为暂停）
 * 考虑，在外部处理这件事还是在内部处理比较合适?（内部尚未处理）
 */
@optional;
//时间回调
- (void)timeSuperviser:(WZTimeSuperviser *)timeSuperviser currentTime:(NSTimeInterval)currentTime;
//暂停
- (void)timeSuperviserPause;
//恢复
- (void)timeSuperviserResume;

//完成或中途停止
- (void)timeSuperviser:(WZTimeSuperviser *)timeSuperviser didStopWithCancel:(BOOL)cancel;

@end

//存在问题：设置间隔为浮点型时可能不精确
@interface WZTimeSuperviser : NSObject
{
    NSTimeInterval _interval;
    BOOL _pause;
    __weak id<WZTimeSuperviserDelegate> _delegate;
}
/**
 *  定时器间隔 默认是1s
 */
@property (nonatomic, assign) NSTimeInterval interval;

/**
 *  可查看是否处于暂停状态
 */
@property (nonatomic, assign, readonly) BOOL pause;

/**
 *  持续时间（回调抛出时间）
 */
@property (nonatomic, assign, readonly) NSTimeInterval duration;

/**
 *  事件终止时间
 *  ps：由于interal的设定 使得 duration最终值与terminalTime有所差异  但总有duration >= terminalTime时，终止代理回调）
 *  因此需要主观地设置interval可最终使得duration == terminalTime
 *  terminalTime 默认为0时  计时器需要手动停止 
 */
@property (nonatomic, assign) NSTimeInterval terminalTime;

/**
 *  回调代理
 */
@property (nonatomic, weak) id<WZTimeSuperviserDelegate> delegate;


/**
 * 启动定时器（各项属性配置完之后再调用）(也是恢复定时器操作 Q:是否应该分出一个接口)
 */
- (void)timeSuperviserFire;

/**
 * 暂停定时器
 */
- (void)timeSuperviserPause;

/**
 * 停止定时器
 */
- (void)timeSuperviserStop;


#pragma  mark - for subClass
- (void)fireEvent;

//不期望在外部调用 在子类中调用
- (void)timerEvent;

@end
