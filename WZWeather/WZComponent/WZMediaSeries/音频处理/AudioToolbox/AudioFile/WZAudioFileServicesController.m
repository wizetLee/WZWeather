//
//  WZAudioFileServicesController.m
//  WZWeather
//
//  Created by admin on 3/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZAudioFileServicesController.h"
//#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
@interface WZAudioFileServicesController ()

@end

@implementation WZAudioFileServicesController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self seekInfo];//查看文件信息
    
}

+ (NSURL *)fileURL {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    return [NSURL fileURLWithPath:[docPath stringByAppendingPathComponent:@"wizetAudio.aif"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)seekInfo {
    {////检查可用类型
        OSStatus stts;
        UInt32 infoSize = 0;
        stts = AudioFileGetGlobalInfoSize(kAudioFileGlobalInfo_AllMIMETypes, 0, NULL, &infoSize);
        CheckError(stts, "AudioFileGetGlobalInfoSize");
        
        NSArray *MIMEs;
        stts = AudioFileGetGlobalInfo(kAudioFileGlobalInfo_AllMIMETypes, 0, NULL, &infoSize, &MIMEs);
        CheckError(stts, "AudioFileGetGlobalInfo");
//        NSLog(@"fileType is %@", MIMEs);
        
        UInt32 propertySize;
        OSType readOrWrite = kAudioFileGlobalInfo_ReadableTypes;
        stts = AudioFileGetGlobalInfoSize(readOrWrite, 0, NULL, &propertySize);
        CheckError(stts, "AudioFileGetGlobalInfoSize");
        
        OSType *types = (OSType*)malloc(propertySize);
        stts = AudioFileGetGlobalInfo(readOrWrite, 0, NULL, &propertySize,  types);
        CheckError(stts, "AudioFileGetGlobalInfo");
        
        UInt32 numTypes = propertySize / sizeof(OSType);//支持类型的数目
        for (UInt32 i=0; i<numTypes; ++i){
            CFStringRef name;
            UInt32 outSize = sizeof(name);
            //类型地址
            stts = AudioFileGetGlobalInfo(kAudioFileGlobalInfo_FileTypeName, sizeof(OSType), types+i, &outSize, &name);//检索出可读文件
            CheckError(stts, "AudioFileGetGlobalInfo");
//            NSLog(@"readalbe types: %@", name);
        }
        free(types);
    }
    //
    /**
     获得“Audio File Services”基本属性步骤：
     先使用kAudioFileGlobalInfo_AllMIMETypes查询属性的大小，然后Specifier为NULL查询所有 支持的MIME类型，结果为表示MIME值的CFStrings的数组（CFArray）。
     接着在用kAudioFileGlobalInfo_ReadableTypes查询到属性大小，其实表示文件类型ID的UInt32数组大小。然后逐个遍历各个得到的文件类型 ID用kAudioFileGlobalInfo_FileTypeName查询到这个文件类型ID对应的CFStringRef表示的文件类型名。
     */
    
    
    ///打开文件 查看文件信息（建议使用AVURLAsset查看）
//        NSURL *url = [[self class] fileURL];
    /*个人录制的文件的信息得到
     info: {
     "approximate duration in seconds" = "0.766";
     }
     */
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Secretofmyheart" ofType:@"mp3"]];
    CFURLRef URLRef = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)url.path, kCFURLPOSIXPathStyle, false);
    AudioFileID audioFileHandle;//句柄
    //使用kAudioFileReadWritePermission的权限有问题
    AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0/*提示文件类型*/, &audioFileHandle);
    
    //    AudioFileTypeID typeIdMP3 = kAudioFileMP3Type;
    // kAudioFilePropertyID3Tag   ID3，一般是位于一个mp3文件的开头或末尾的若干字节内，附加了关于该mp3的歌手，标题，专辑名称，年代，风格等信息，该信息就被称为ID3信息，ID3信息分为两个版本，v1和v2版。 其中：v1版的ID3在mp3文件的末尾128字节，以TAG三个字符开头，后面跟上歌曲信息。 v2版一般位于mp3的开头，可以存储歌词，该专辑的图片等大容量的信息。
    //先获取属性大小
    UInt32 id3DataSize = 0;
    CheckError(AudioFileGetPropertyInfo(audioFileHandle, kAudioFilePropertyID3Tag, &id3DataSize, NULL), "AudioFileGetPropertyInfo");
    
    //唱片信息
    NSDictionary *propertyInfo = nil;
    UInt32 piDataSize = sizeof(propertyInfo);
    AudioFileGetProperty(audioFileHandle, kAudioFilePropertyInfoDictionary, &piDataSize, &propertyInfo);//
    
    
    CFDataRef albumPic = nil;
    UInt32 albumPicDataSize = sizeof(albumPic);
    AudioFileGetProperty(audioFileHandle, kAudioFilePropertyAlbumArtwork, &albumPicDataSize, &albumPic);
    /**
     album = "Secret of my heart";
     "approximate duration in seconds" = "267.076";
     artist = "\U00b2\U00d6\U00c4\U00be\U00c2\U00e9\U00d2\U00c2(Mai kuraki)";
     comments = "www.qq.com";
     genre = Other;
     title = "Secret of my heart";
     "track number" = 1;
     year = 2000;
     */
    AudioFileClose(audioFileHandle);
    
    
    //    {//查asset信息
    //        AVURLAsset *assest = [AVURLAsset URLAssetWithURL:url options:nil];
    //        for (NSString *key in [assest availableMetadataFormats]) {
    //            for (AVMetadataItem *item in [assest metadataForFormat:key]) {
    //                NSString *commonKey = item.commonKey;
    //                if ([commonKey isEqualToString:@"artist"]) {//歌手
    //                    (NSString *)item.value;
    //                }else if([commonKey isEqualToString:@"albumName"]){//专辑名称
    //                    (NSString *)item.value;
    //                }else if([commonKey isEqualToString:@"title"]){//歌曲名
    //                    (NSString *)item.value;
    //                }else if ([commonKey isEqualToString:@"artwork"]){
    //                    NSDictionary *artworkDict = (NSDictionary *)item.value;
    //                    NSData *image = [artworkDict objectForKey:@"data"];
    //                }
    //            }
    //        }
    //    }
}

@end
