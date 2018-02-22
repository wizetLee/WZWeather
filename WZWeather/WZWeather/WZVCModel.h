//
//  WZVCModel.h
//  WZWeather
//
//  Created by admin on 22/2/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZVCModel : NSObject



@property (nonatomic, strong) NSString *headline;

@property (nonatomic, strong) Class VCClass;

@property (nonatomic, assign) BOOL fromNib;
@property (nonatomic, assign) BOOL pushDirectly;        //直接push  
@property (nonatomic, assign) BOOL presentDirectly;     //直接present

@end
