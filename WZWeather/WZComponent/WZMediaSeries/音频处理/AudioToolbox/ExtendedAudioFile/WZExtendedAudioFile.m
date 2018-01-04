//
//  WZExtendedAudioFile.m
//  WZWeather
//
//  Created by admin on 3/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZExtendedAudioFile.h"

@interface WZExtendedAudioFile ()
{
    ExtAudioFileRef audioFileRef;
}
@end

@implementation WZExtendedAudioFile

- (void)viewDidLoad {
    [super viewDidLoad];
    
/////权限为只读
//1、配置URL
     NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Secretofmyheart" ofType:@"mp3"]];
//2、openfile
    CheckError(ExtAudioFileOpenURL((__bridge CFURLRef)url, &audioFileRef), "ExtAudioFileOpenURL");
    
//3、查看音频流格式
    AudioStreamBasicDescription ASBD = {0};
    UInt32 ASBDSize = sizeof(ASBD);
    CheckError(ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileDataFormat, &ASBDSize, &ASBD), "kExtAudioFileProperty_FileDataFormat");
    
//4、查看MaxPacketSize
    UInt32 maxPacketSize = 0;
    UInt32 maxPacketSize_Size = sizeof(maxPacketSize);
    CheckError(ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileMaxPacketSize, &maxPacketSize_Size, &maxPacketSize), "kExtAudioFileProperty_FileMaxPacketSize");
    
    AudioStreamBasicDescription outDesc = ASBD;
    outDesc.mSampleRate = 44100;
    outDesc.mFormatID = kAudioFormatLinearPCM;
    outDesc.mFormatFlags = kLinearPCMFormatFlagIsFloat;
    outDesc.mBitsPerChannel = 16; // 16bit sample depth
    outDesc.mChannelsPerFrame = 2;
    outDesc.mBytesPerFrame = outDesc.mChannelsPerFrame * outDesc.mBitsPerChannel/8;
    outDesc.mFramesPerPacket = 1;
    outDesc.mBytesPerPacket = outDesc.mFramesPerPacket * outDesc.mBytesPerFrame;
    
#warning 格式有点问题？？？
    CheckError(ExtAudioFileSetProperty(audioFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(outDesc), &outDesc), "ExtAudioFileSetProperty");;
    
//5、readfile
    [self readWith:maxPacketSize ASBD:ASBD];
    
//6、seek
    SInt64 outFrameOffset = 0;
    CheckError(ExtAudioFileTell(audioFileRef, &outFrameOffset), "ExtAudioFileTell");//读出当前正在读写帧的偏移量
    SInt64 target = 11;
    CheckError(ExtAudioFileSeek(audioFileRef, target), "ExtAudioFileSeek");//seek 到具体的帧
    NSLog(@"current frame:%lld", outFrameOffset);
    [self readWith:maxPacketSize ASBD:ASBD];
    CheckError(ExtAudioFileTell(audioFileRef, &outFrameOffset), "ExtAudioFileTell");
    NSLog(@"current frame:%lld", outFrameOffset);
    
//last、closefile
    CheckError(ExtAudioFileDispose(audioFileRef), "ExtAudioFileDispose");
}

- (void)readWith:(UInt32)maxPacketSize  ASBD:(AudioStreamBasicDescription)ASBD {
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mNumberChannels = ASBD.mChannelsPerFrame;
    bufferList.mBuffers[0].mDataByteSize = maxPacketSize;
    bufferList.mBuffers[0].mData = malloc(maxPacketSize);//注意 此处数据可能与mChannelsPerFrame有关
    
    UInt32 ioNumberFrames = 1;
    CheckError(ExtAudioFileRead(audioFileRef, &ioNumberFrames, &bufferList), "ExtAudioFileRead");
    free(bufferList.mBuffers[0].mData);
}

@end
