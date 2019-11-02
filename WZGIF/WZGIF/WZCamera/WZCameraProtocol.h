//
//  WZCameraProtocol.h
//  WZGIF
//
//  Created by admin on 25/7/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WZCamera;
@protocol WZMovieWriterProtocol;
@protocol WZTimeSuperviserDelegate;

@protocol WZCameraProtocol <//AVCaptureFileOutputRecordingDelegate,
//                            AVCaptureMetadataOutputObjectsDelegate ,
//                            AVCaptureVideoDataOutputSampleBufferDelegate ,
//                            AVCaptureAudioDataOutputSampleBufferDelegate,
                            WZOrientationProtocol,
                            WZMovieWriterProtocol
                            >
@optional

#pragma mark - 获取通道的样本
- (void)bufferImage:(UIImage *)image;
- (void)recordRestrict;
@end
