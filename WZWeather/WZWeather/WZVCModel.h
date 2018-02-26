//
//  WZVCModel.h
//  WZWeather
//
//  Created by admin on 22/2/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WZVCModelTransitionType) {
    WZVCModelTransitionType_Custom,
    WZVCModelTransitionType_Push,
    WZVCModelTransitionType_Push_FromNib,
    WZVCModelTransitionType_Present,
    WZVCModelTransitionType_Present_FromNib,
};

@interface WZVCModel : NSObject

@property (nonatomic, strong) NSString *headline;

@property (nonatomic, strong) Class VCClass;

@property (nonatomic, assign) WZVCModelTransitionType type;


@end
