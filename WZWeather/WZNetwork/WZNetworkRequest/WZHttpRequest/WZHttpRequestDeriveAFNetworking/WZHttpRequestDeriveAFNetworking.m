//
//  WZHttpRequestDeriveAFNetworking.m
//  WZWeather
//
//  Created by admin on 17/5/12.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZHttpRequestDeriveAFNetworking.h"

@implementation WZHttpRequestDeriveAFNetworking

+ (void)aaa {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.session
//    manager.
    
    if ([manager.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]]) {
        ((AFJSONResponseSerializer *)manager.responseSerializer).readingOptions = NSJSONReadingAllowFragments;
    }
    [manager.requestSerializer setValue:@"" forHTTPHeaderField:@""];//配置请求头信息

    
    
//    manager dataTaskWithRequest:<#(nonnull NSURLRequest *)#> completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        
//    }
    
    
    
}

@end
