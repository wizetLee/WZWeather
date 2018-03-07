//
//  WZDownloadTarget.m
//  WZWeather
//
//  Created by wizet on 17/5/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZDownloadTarget.h"
#import "WZDownloadProgressCell.h"
#import "WZDownloadRequest.h"

@implementation WZDownloadTarget
@synthesize cellType = _cellType;

- (instancetype)init {
    if (self = [super init]) {
        [self addObserver:self forKeyPath:@"totalBytesWritten" options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"totalBytesWritten"]) {
        if ([self.delegate conformsToProtocol:@protocol(WZDownloadtargetDelegate)]
            && [self.delegate respondsToSelector:@selector(progressCallBack:)]) {
            [self.delegate progressCallBack:change];
        }
    }
}

- (void)dealloc {
    @try {
        if (self) {
            [self removeObserver:self forKeyPath:@"totalBytesWritten"];
        }
    } @catch (NSException *exception) {
        NSLog(@"exception:%@",exception);
    }
}

- (void)setCellType:(NSString *)cellType {
    if ([cellType isKindOfClass:[NSString class]]) {
        _cellType = cellType;
    } else {
        _cellType = NSStringFromClass([WZDownloadProgressCell class]);
    }
}

- (NSString *)cellType {
    if (!_cellType) {
        _cellType = NSStringFromClass([WZDownloadProgressCell class]);
    }
    return _cellType;
}


@end
