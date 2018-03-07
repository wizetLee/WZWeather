//
//  UIApplication+JKNetworkActivityIndicator.m
//  NetworkActivityIndicator
//
//  Created by Matt Zanchelli on 1/10/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "UIApplication+JKNetworkActivityIndicator.h"

#import <libkern/OSAtomic.h>

@implementation UIApplication (JKNetworkActivityIndicator)

/**
 *  volatile:每次获取都会重现获取变量的值  而不会从寄存器中取那个备份(强制编译器每次使用变量的时候都从内存里面 加载)    int32_t:为了保证平台的通用性
 */
static volatile int32_t numberOfActiveNetworkConnectionsxxx;

#pragma mark Public API

//OSAtomicAdd32  线程同步
- (void)jk_beganNetworkActivity
{
	self.networkActivityIndicatorVisible = OSAtomicAdd32(1, &numberOfActiveNetworkConnectionsxxx) > 0;
//    [NSNotificationQueue defaultQueue]
}

/*
 2、内存屏障和Volatile变量（MemoryBarriers and Volatile Variables）
 1）内存屏障：
 为了达到最佳性能,编译器通常会对汇编基本的指令进行重新排序来尽可能保持处理器的指令流水线。如果看似独立的变量实际上 是相互影响,那么编译器优化有可能把这些变量更新位错误的顺序,导致潜在不不正确结果。
 内存屏障(memorybarrier)是一个使用来确保内存操作按照正确的顺序工作的非阻塞的同步工具。内存屏障的作用就像一个栅栏,迫使处理器来完成位于障碍前面的任何加载和存储操作,才允许它执行位于屏障之后的加载和存储操作。内存屏障同样使用来确保一个线程(但对另外一个线程可见)的内存操作总是按照预定的顺序完成。
 为了使用一个内存屏障,你只要在你代码里面需要的地方简单的调用OSMemoryBarrier函数。
 2）Volatile变量
 编译器优化代码通过加载这些变量的值进入寄存器。对于本地变量,这通常不会有什么问题。但是如果一个变量对另外一个线程可见,那么这种优化可能会阻止其他线程发现变量的任何变化。在变量之前加上关键字volatile可以强制编译器每次使用变量的时候都从内存里面 加载。如果一个变量的值随时可能给编译器无法检测的外部源更改,那么你可以把该变量声明为volatile变量。
 因为内存屏障和volatile变量降低了编译器可执行的优化,因此你应该谨慎使用它们,只在有需要的地方时候,以确保正确性。
 */

- (void)jk_endedNetworkActivity
{
	self.networkActivityIndicatorVisible = OSAtomicAdd32(-1, &numberOfActiveNetworkConnectionsxxx) > 0;
}

@end
