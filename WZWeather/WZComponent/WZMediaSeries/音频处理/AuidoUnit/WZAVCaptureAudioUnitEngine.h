//
//  WZAVCaptureAudioUnitEngine.h
//  WZWeather
//
//  Created by admin on 2/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import <Foundation/Foundation.h>

//苹果的文件
// CoreAudio Public Utility
#include "CAStreamBasicDescription.h"
#include "CAComponentDescription.h"
#include "CAAudioBufferList.h"
#include "AUOutputBL.h"

@protocol WZAVCaptureAudioUnitEngineProtocol<NSObject>

- (void)captureAudioUnitEngineStartRecording;
- (void)captureAudioUnitEngineStopRecording;
- (void)captureAudioUnitEnginePauseRecording;
- (void)captureAudioUnitEngineResumeRecording;

@end

@interface WZAVCaptureAudioUnitEngine : NSObject

@property (nonatomic, strong, readonly) NSURL *outputURL;
@property (nonatomic,   weak) id<WZAVCaptureAudioUnitEngineProtocol> delegate;

- (void)startCaptureSession;
- (void)stopCaptureSession;

- (void)startRecording;
- (void)pauseRecording;
- (void)resumeRecording;
- (void)stopRecording;

@end
