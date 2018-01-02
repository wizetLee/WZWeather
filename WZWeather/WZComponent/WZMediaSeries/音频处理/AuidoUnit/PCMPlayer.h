//
//  PCMPlayer.h
//  WZWeather
//
//  Created by 李炜钊 on 2017/12/24.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PCMPlayer;
@protocol PCMPlayerProtocol <NSObject>

- (void)playFinished;

@end

@interface PCMPlayer : NSObject

@property (nonatomic ,  weak) id<PCMPlayerProtocol> delegate;

- (void)play;

@end
