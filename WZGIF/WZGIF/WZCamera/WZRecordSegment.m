//
//  WZRecordSegment.m
//  WZGIF
//
//  Created by admin on 25/7/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZRecordSegment.h"
@interface WZRecordSegment() {
    AVAsset *_asset;
    __weak UIImage *_thumbnail;
    __weak UIImage *_lastImage;
}
@end

@implementation WZRecordSegment

- (instancetype)initWithURL:(NSURL *)url info:(NSDictionary *)info {
    self = [self init];
    
    if (self) {
        _url = url;
        _info = info;
    }
    
    return self;
}


- (BOOL)fileUrlExists {
    return [[NSFileManager defaultManager] fileExistsAtPath:self.url.path];
}


#pragma mark - Accessor
- (void)setUrl:(NSURL *)url {
    _url = url;
    _asset = nil;
}

- (AVAsset *)asset {
    if (_asset == nil) {
        _asset = [AVAsset assetWithURL:_url];
    }
    
    return _asset;
}

- (CMTime)duration {
    return [self asset].duration;
}

- (UIImage *)thumbnail {
    UIImage *image = _thumbnail;
    if (image == nil) {
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        
        NSError *error = nil;
        CGImageRef thumbnailImage = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:nil error:&error];
        
        if (error == nil) {
            image = [UIImage imageWithCGImage:thumbnailImage];
            _thumbnail = image;
        } else {
            NSLog(@"Unable to generate thumbnail for %@: %@", self.url, error.localizedDescription);
        }
    }
    
    return image;
}

- (float)frameRate {
    NSArray *tracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    
    if (tracks.count == 0) {
        return 0;
    }
    
    AVAssetTrack *videoTrack = [tracks firstObject];
    
    return videoTrack.nominalFrameRate;
}


@end
