//
//  WZMediaFetcher.m
//  WZPhotoPicker
//
//  Created by admin on 17/6/7.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "WZMediaFetcher.h"


@implementation WZMediaAsset
#pragma mark - WZMediaAsset
-(void)setAsset:(PHAsset *)asset {
    _asset = [asset isKindOfClass:[PHAsset class]]?asset:nil;
}

- (void)fetchThumbnailImageSynchronous:(BOOL)synchronous handler:(void (^)(UIImage *image))handler {
    [WZMediaFetcher fetchThumbnailWithAsset:_asset  synchronous:synchronous handler:^(UIImage *thumbnail) {
        _imageThumbnail = thumbnail;
        if (handler) {handler(thumbnail);};
    }];
}

- (void)fetchOrigionImageSynchronous:(BOOL)synchronous handler:(void (^)(UIImage *image))handler {
    [WZMediaFetcher fetchOrigionWith:_asset synchronous:synchronous handler:^(UIImage *origion) {
        if (handler) {handler(origion);};
    }];
}

@end

#pragma mark - WZMediaAssetCollection
@implementation WZMediaAssetCollection

- (void)customCoverWithMediaAsset:(WZMediaAsset *)mediaAsset withCoverHandler:(void(^)(UIImage *image))handler {
    if ([mediaAsset isKindOfClass:[WZMediaAsset class]]) {
        _coverAssset = mediaAsset;
        if (handler) {
            [WZMediaFetcher fetchThumbnailWithAsset:mediaAsset.asset synchronous:false handler:^(UIImage *thumbnail) {
                handler(thumbnail);
            }];
        }
    }
}

- (void)coverHandler:(void(^)(UIImage *image))handler {
    [self customCoverWithMediaAsset:self.coverAssset withCoverHandler:handler];
}

#pragma mark - Accessor
- (NSArray <WZMediaAsset *>*)mediaAssetArray {
    if (!_mediaAssetArray) {
        _mediaAssetArray = [NSArray array];
    }
    return _mediaAssetArray;
}

- (WZMediaAsset *)coverAssset {
    if (!_coverAssset) {
        if (self.mediaAssetArray.count > 0) {
            _coverAssset = self.mediaAssetArray[0];
        }
    }
    return _coverAssset;
}

@end

#pragma mark - WZMediaPicker
@implementation WZMediaFetcher

#pragma mark - Fetch Picture
+ (NSMutableArray <WZMediaAssetCollection *> *)fetchAssetCollection {
    //智能相册
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    //按照 PHAssetCollection 的startDate 升序排序
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:true]];
    
    /*
     PHAssetCollectionTypeAlbum PHAssetCollectionSubtypeAlbumRegular  :qq 微博  我的相簿（自定义的相簿）
     PHAssetCollectionTypeSmartAlbum PHAssetCollectionSubtypeSmartAlbumUserLibrary 胶卷中的图（包含video）
     PHAssetCollectionTypeSmartAlbum PHAssetCollectionSubtypeAlbumRegular 智能相簿（包含image video audio类型 ）
     */
    
    PHFetchResult *result_smartAlbums = [PHAssetCollection
                                         fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                         subtype:PHAssetCollectionSubtypeAlbumRegular
                                         options:fetchOptions];
    
    NSMutableArray <WZMediaAssetCollection *>* mmediaAssetArrayCollection = [[self class] universalMediaAssetCollectionWith:result_smartAlbums];
    return mmediaAssetArrayCollection;
}

+ ( NSMutableArray <WZMediaAssetCollection *>*)universalMediaAssetCollectionWith:(PHFetchResult *)result_smartAlbums {
    NSMutableArray <WZMediaAssetCollection *>* mmediaAssetArrayCollection = [NSMutableArray array];
    
    for (PHAssetCollection *assetCollection in result_smartAlbums) {
        PHFetchResult<PHAsset *> *fetchResoult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:[[self class] configImageOptions]];
        
        //过滤无图片的fetchResoult 配置数据源
        if (fetchResoult.count) {
            
            WZMediaAssetCollection *mediaAssetCollection = [[WZMediaAssetCollection alloc] init];
            mediaAssetCollection.assetCollection = assetCollection;
            mediaAssetCollection.title = assetCollection.localizedTitle;
            [mmediaAssetArrayCollection addObject:mediaAssetCollection];
            
            NSMutableArray <WZMediaAsset *>*mmediaAssetArray = [NSMutableArray array];
            for (PHAsset *asset in fetchResoult) {
                WZMediaAsset *object = [[WZMediaAsset alloc] init];
                object.asset = asset;
                [mmediaAssetArray addObject:object];
            }
            
            mediaAssetCollection.mediaAssetArray = [NSArray arrayWithArray:mmediaAssetArray];
        }
    }
    return mmediaAssetArrayCollection;
}


//+ (NSArray <WZMediaAssetCollection *> *)customMediaAssetCollectionOnlyImageAsset {
//    
//}
//+ (NSArray <WZMediaAssetCollection *> *)customMediaAssetCollectionOnlyVideoAsset {
//    
//}
////获取个人创建的相册的集合<也有视频/图片类型>
//+ (NSArray <WZMediaAssetCollection *> *)customMediaAssetCollectionOnlyImageHybirdVideoAsset {
//    NSMutableArray <WZMediaAssetCollection *>* mmediaAssetArrayCollection = [NSMutableArray array];
//    PHFetchResult *customCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
//    for (PHAssetCollection *assetCollection in customCollections) {
//        PHFetchResult<PHAsset *> *fetchResoult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:[[self class] configImageOptions]];
//        
//        //过滤无图片的fetchResoult 配置数据源
//        if (fetchResoult.count) {
//            WZMediaAssetCollection *mediaAssetCollection = [[WZMediaAssetCollection alloc] init];
//            mediaAssetCollection.assetCollection = assetCollection;
//            mediaAssetCollection.title = assetCollection.localizedTitle;
//            [mmediaAssetArrayCollection addObject:mediaAssetCollection];
//            NSMutableArray <WZMediaAsset *>*mmediaAssetArray = [NSMutableArray array];
//            for (PHAsset *asset in fetchResoult) {
//                WZMediaAsset *object = [[WZMediaAsset alloc] init];
//                object.asset = asset;
//                [mmediaAssetArray addObject:object];
//            }
//            mediaAssetCollection.mediaAssetArray = [NSArray arrayWithArray:mmediaAssetArray];
//        }
//    }
//    return mmediaAssetArrayCollection;
//}
//

/*
 //  用户自定义的资源
 PHFetchResult *customCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
 for (PHAssetCollection *collection in customCollections) {
 PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
 [nameArr addObject:collection.localizedTitle];
 [assetArr addObject:assets];
 }
 */



+ (int32_t)fetchThumbnailWithAsset:(PHAsset *)mediaAsset synchronous:(BOOL)synchronous handler:(void(^)(UIImage *thumbnail))handler {
    CGSize targetSize = WZMEDIAASSET_THUMBNAILSIZE;
    PHImageRequestID imageRequestID = [self fetchImageWithAsset:mediaAsset targetSize:targetSize synchronous:synchronous handler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (handler) {
            handler(result);
        }
    }];
    
    ///数据信息 仅限于本地图片
//    PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
//   PHContentEditingInputRequestID ID =  [mediaAsset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
//        //        contentEditingInput.mediaType
//        //        contentEditingInput.mediaSubtypes
//        //        contentEditingInput.location
//        //        contentEditingInput.creationDate
//        if (contentEditingInput.creationDate) {
//            //创建日期
//            NSDateFormatter *dataFormer = [[NSDateFormatter alloc] init];
//            [dataFormer setDateStyle:NSDateFormatterNoStyle];
//            [dataFormer stringFromDate:contentEditingInput.creationDate];
//        }
//
//        if (contentEditingInput.location) {
//            //经纬度
//
//        }
//
//        CIImage *fullImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
//        NSDictionary *nsdic = fullImage.properties;
//        NSDictionary *originExif = nsdic[@"{Exif}"];
//
//        // 镜头信息
//        NSString *lensModel = [NSString stringWithFormat:@"设备型号:%@",originExif[(NSString *)kCGImagePropertyExifLensModel]];
//        // 光圈系数
//        NSString *fNumber = [NSString stringWithFormat:@"光圈系数:f/%@",originExif[(NSString *)kCGImagePropertyExifFNumber]];
//        // 曝光时间
//        NSString *exposureTime = [NSString stringWithFormat:@"曝光时间:f/%@",originExif[(NSString *)kCGImagePropertyExifExposureTime]];
//        // 镜头焦距
//        NSString *focalLength = [NSString stringWithFormat:@"镜头焦距:%@mm",originExif[(NSString *)kCGImagePropertyExifFocalLength]];
//        // 日期和时间
//        NSString *dataTime = [NSString stringWithFormat:@"数字化时间:%@",originExif[(NSString *)kCGImagePropertyExifDateTimeDigitized]];
//        // ISO
//        NSString *isoSpeedRatings = [NSString stringWithFormat:@"ISO:%@",[originExif[(NSString *)kCGImagePropertyExifISOSpeedRatings] firstObject]];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"%@", lensModel);
//            NSLog(@"%@", fNumber);
//            NSLog(@"%@", exposureTime);
//            NSLog(@"%@", focalLength);
//            NSLog(@"%@", dataTime);
//            NSLog(@"%@", isoSpeedRatings);
//        });
//    }];
//    [mediaAsset cancelContentEditingInputRequest:ID];//weak 引用这个asset
    
    return imageRequestID;
}

+ (int32_t)fetchOrigionWith:(PHAsset *)mediaAsset synchronous:(BOOL)synchronous handler:(void(^)(UIImage *origion))handler {
    CGSize targetSize = CGSizeMake(mediaAsset.pixelWidth, mediaAsset.pixelHeight);
    PHImageRequestID imageRequestID = [self fetchImageWithAsset:mediaAsset targetSize:targetSize synchronous:synchronous handler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (handler) {
            handler(result);
        }
    }];
    
    return imageRequestID;
}

+ (int32_t)fetchImageWithAsset:(PHAsset *)mediaAsset costumSize:(CGSize)customSize synchronous:(BOOL)synchronous handler:(void(^)(UIImage *image))handler {
    PHImageRequestID imageRequestID = [self fetchImageWithAsset:mediaAsset targetSize:customSize synchronous:synchronous handler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (handler) {
            handler(result);
        }
    }];
    return imageRequestID;
}

+ (int32_t)fetchImageWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize synchronous:(BOOL)synchronous handler:(void (^)(UIImage * _Nullable result, NSDictionary * _Nullable info))handler {
    //图片请求选项配置 同步异步配置
    PHImageRequestOptions *imageRequestOption = [self configImageRequestOption];
    if (synchronous) {
        //增加同步配置
        imageRequestOption = [self configSynchronousImageRequestOptionWith:imageRequestOption];
    }
    
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:imageRequestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (handler) {
            handler(result, info);
        }
    }];
    return imageRequestID;
}

+ (int32_t)fetchImageWithAsset:(PHAsset *)asset synchronous:(BOOL)synchronous handler:(void (^)(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info))handler {
    //图片请求选项配置
    //图片请求选项配置 同步异步配置
    PHImageRequestOptions *imageRequestOption = [self configImageRequestOption];
    if (synchronous) {
        //同步配置
        imageRequestOption = [self configSynchronousImageRequestOptionWith:imageRequestOption];
    }
    
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequestOption resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (handler) {
            handler(imageData, dataUTI, orientation, info);
        }
    }];
    return imageRequestID;
}

#pragma mark - 配置
//过滤出image类型的资源
+ (PHFetchOptions *)configImageOptions {
    PHFetchOptions *fetchResoultOption = [[PHFetchOptions alloc] init];
    fetchResoultOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];//按照日期降序排序
    fetchResoultOption.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];//过滤剩下照片类型
    return fetchResoultOption;
}

+ (PHFetchOptions *)configVideoOptions {
    PHFetchOptions *fetchResoultOption = [[PHFetchOptions alloc] init];
    fetchResoultOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];//按照日期降序排序
    fetchResoultOption.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo];//过滤剩下视频类型
    return fetchResoultOption;
}

+ (PHImageRequestOptions *)configImageRequestOption {
    //图片请求选项配置
    PHImageRequestOptions *imageRequestOption = [[PHImageRequestOptions alloc] init];
    //图片版本:最新
    imageRequestOption.version = PHImageRequestOptionsVersionCurrent;
    //非同步
    imageRequestOption.synchronous = false;
    //图片请求模式:高质量格式
    imageRequestOption.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    //图片请求模式:精确的
    imageRequestOption.resizeMode = PHImageRequestOptionsResizeModeExact;
    //用于对原始尺寸的图像进行裁剪，基于比例坐标。resizeMode 为 Exact 时有效。
    //  imageRequestOption.normalizedCropRect = CGRectMake(0, 0, 100, 100);
    return imageRequestOption;
}

//同步配置
+ (PHImageRequestOptions *)configSynchronousImageRequestOptionWith:(PHImageRequestOptions *)imageRequestOption {
    imageRequestOption.synchronous = true;
    return imageRequestOption;
}


//+ (void)fetchOrigionWith:(PHAsset *)mediaAsset handler:(void(^)(UIImage *origion, NSString *origionPath))handler {
//    CGSize targetSize = CGSizeMake(mediaAsset.pixelWidth, mediaAsset.pixelHeight);
////    if (targetSize.height <= 300 || targetSize.width <= 300) {
////        NSLog(@"< 300");
////    }
//    [self fetchImageWithAsset:mediaAsset targetSize:targetSize handler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        //写进file中
//        NSString *path = nil;
//        if ([info[@"PHImageFileURLKey"] isKindOfClass:[NSURL class]]) {
//            NSURL * fileUrl = info[@"PHImageFileURLKey"];
//
//            //存放在tmp中 可随时更换目录
//            path = [NSString stringWithFormat:@"%@/%@", [[self class] wz_filePath:WZSearchPathDirectoryTemporary fileName:@"WZFileStorage"], fileUrl.lastPathComponent];
//
//            //保存所在文件
//            if ([[self class] wz_fileExistsAtPath:path]) {
//                //文件已经存在
//                NSLog(@"文件已经存在");
//            } else {
//                if ([[self class] wz_createFolder:WZSearchPathDirectoryTemporary folderName:@"WZFileStorage"]) {
//                    @autoreleasepool {
//                        NSData *resultData = UIImagePNGRepresentation(result);
//                        if (![resultData writeToFile:path atomically:true]) {
//                            path = nil;
//                        } else {
//                            NSLog(@"创建成功");
//                        }
//                    }
//                } else {
//                    //创建失败 path 不存在
//                    path = nil;
//                }
//            }
//        }
//
//        UIImage *targetImage = nil;
//        if (!path) {
//            targetImage = result;
//        }
//
//        //二保存其一 因为:原图的缓存太大了,不能每次都加上原图
//        if (handler) {
//            handler(targetImage, path);
//        }
//    }];
//}


//    [[PHImageManager defaultManager] requestImageDataForAsset:mediaAsset.asset options:imageRequestOption resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//        UIImage *origion  = [UIImage imageWithData:imageData];
//
//        CGSize targetSize = [self size:origion.size adjustLargestUnit:150];
//        UIImage *thumbnail = [self image:origion byScalingToSize:targetSize];
////
//        mediaAsset.mediaType = WZMediaTypePhoto;
//        mediaAsset.thumbnail = thumbnail;
//        mediaAsset.origion = origion;
//        if (handler) {
//            handler(origion, origion);
//        }
//    }];


//+ (CGSize)size:(CGSize)size adjustLargestUnit:(CGFloat)largestUnit {
//    if (largestUnit == 0.0) {
//        return CGSizeZero;
//    } else if (size.height > 0) {
//        CGFloat scale = size.width / size.height;
//        CGFloat newWidth = 0.0;
//        CGFloat newHeight = 0.0;
//
//        if (scale > 1.0) {
//            //宽大于高
//            newWidth = largestUnit;
//            newHeight = largestUnit / scale;
//        } else {
//            //高大于宽
//            newWidth = largestUnit * scale;
//            newHeight = largestUnit;
//        }
//        return CGSizeMake(newWidth, newHeight);
//    }
//
//    return CGSizeZero;
//}

//+ (UIImage *)image:(UIImage*)image byScalingToSize:(CGSize)targetSize {
//    UIImage *sourceImage = image;
//    UIImage *newImage = nil;
//
//    UIGraphicsBeginImageContext(targetSize);
//
//    CGRect thumbnailRect = CGRectZero;
//    thumbnailRect.origin = CGPointZero;
//    thumbnailRect.size.width  = targetSize.width;
//    thumbnailRect.size.height = targetSize.height;
//
//    [sourceImage drawInRect:thumbnailRect];
//
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    return newImage ;
//}

#pragma mark - Fetch Video
+ (int32_t)fetchVideoWith:(PHAsset *)asset synchronous:(BOOL)synchronous handler:(void (^)(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info))handler {
    PHVideoRequestOptions *videoRequsetOptions = [[PHVideoRequestOptions alloc] init];
    videoRequsetOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    videoRequsetOptions.networkAccessAllowed = false;
    PHImageRequestID imageRequestID = 0;
    
    if (!synchronous) {
        //异步
        imageRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:videoRequsetOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if (handler) {
                handler(asset, audioMix, info);
            }
        }];
    } else {
        //同步 使用信号量
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        //请求asset
        imageRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:videoRequsetOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if (handler) {
                handler(asset, audioMix, info);
            }
            dispatch_semaphore_signal(semaphore);
        }];
        //等待信号
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    //请求item
//    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:videoRequsetOptions resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
//
//    }];
    
    //导出 ExportSession
//    [[PHImageManager defaultManager] requestExportSessionForVideo:asset options:videoRequsetOptions exportPreset:AVAssetExportPresetHighestQuality resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
//
//    }];
    
    
    return imageRequestID;
}

//MARK:获取拥有所有视频的集合
+ (NSArray <PHAsset *> *)allVideosAssets; {
    PHFetchOptions *option = [[self class] configVideoOptions];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    NSMutableArray *videos = [NSMutableArray array];
    for (NSUInteger i = 0; i < smartAlbums.count; i++) {
        PHAssetCollection *smartAlbum = [smartAlbums objectAtIndex:i];
        PHFetchResult<PHAsset *> *assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:smartAlbum options:option];
        for (PHAsset *tmpPHAsset in assetsFetchResults) {
            [videos addObject:tmpPHAsset];
        }
    }
    return videos;
}


#pragma mark - 删除某一些资源
+ (void)deleteAssetsWithLIDS:(NSArray <NSString *>*)localIdentifierArr complectionHandler:(void (^)(BOOL success, NSError *error))handler {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHFetchResult *assets = [PHAsset fetchAssetsWithLocalIdentifiers:localIdentifierArr options:nil];
        if (assets) { [PHAssetChangeRequest deleteAssets:assets]; }
    } completionHandler:^(BOOL success, NSError *error) {
        if (handler) { handler(success, error); }
    }];
}

#pragma mark - 保存某一些资源
+ (void)saveVideoWithURL:(NSURL *)URL completionHandler:(void (^)(BOOL success, NSError *error))handler {
    if ([[NSFileManager defaultManager] fileExistsAtPath:URL.path]) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:URL];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (handler) { handler(success, error); }
        }];
    } else {
       if (handler) { handler(false, [NSError errorWithDomain:@"资源出错" code:-1 userInfo:nil]); }
    }
}

+ (void)saveImageWithURL:(NSURL *)URL completionHandler:(void (^)(BOOL success, NSError *error))handler {
    if ([[NSFileManager defaultManager] fileExistsAtPath:URL.path]) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:URL];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (handler) { handler(success, error); }
        }];
    } else {
        if (handler) { handler(false, [NSError errorWithDomain:@"资源出错" code:-1 userInfo:nil]); }
    }
}

+ (void)saveImage:(UIImage *)image completionHandler:(void (^)(BOOL success, NSError *error))handler {
    if ([image isKindOfClass:[UIImage class]]) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (handler) { handler(success, error); }
        }];
    } else {
        if (handler) { handler(false, [NSError errorWithDomain:@"图片出错" code:-1 userInfo:nil]); }
    }
}

+ (void)saveImage:(NSData *)imageData
         metadata:(NSDictionary *)metadata
         identify:(NSString *)identify
           target:(id)target
          seleter:(SEL)aSelector {
    
    NSLog(@"imagedata ---- %f",(float)imageData.length / (1024*1024));
    NSData *newImageData = [self setExifInfoWithIndentify:identify imageData:imageData exifDic:metadata];
    
    NSLog(@"newImageData ---- %f",(float)newImageData.length / (1024*1024));
    UIImage *image = [UIImage imageWithData:newImageData];// [UIImage imageWithCIImage:ciImage scale:1 orientation:UIImageOrientationUp];
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSLog(@"datattt ---- %f",(float)data.length / (1024*1024));
    NSString *savePath = [NSTemporaryDirectory() stringByAppendingString:@"tempSaveImage.jpg"];
    [newImageData writeToFile:savePath atomically:YES];
    
    __block PHAssetChangeRequest *changeRequest = nil;
    __block PHObjectPlaceholder *placeholder = nil;
    
    PHAssetCollection *collection = nil;//[self collection];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];//[PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL fileURLWithPath:savePath]];
        placeholder = changeRequest.placeholderForCreatedAsset;
        
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        // PHObjectPlaceholder *placeholder = changeRequest.placeholderForCreatedAsset;
        NSString *localIdentifier = placeholder.localIdentifier;
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            PHFetchResult *aResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
            PHAsset *asset = [aResult firstObject];
            PHAssetCollectionChangeRequest *collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            [collectionRequest addAssets:@[asset]];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            NSLog(@"save finish !!!!!!!!!!!!!!!!!!!");
            if(target != nil && [target respondsToSelector:aSelector]){
                [target performSelectorOnMainThread:aSelector withObject:nil waitUntilDone:NO];
            }
            
        }];
        
    }];
    
}

+ (NSMutableData *)setExifInfoWithIndentify:(NSString *)identifier imageData:(NSData *)imageData exifDic:(NSDictionary *)exif {
    
    PHFetchResult *aResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil];
    PHAsset *asset = [aResult firstObject];
    
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.networkAccessAllowed = NO;
    
    [imageRequestOptions setSynchronous:YES];
    
    __block CGImageSourceRef imgSource = nil;
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:imageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        imgSource = CGImageSourceCreateWithData((__bridge_retained CFDataRef)imageData, NULL);
        
    }];
    
    NSMutableDictionary *metadataAsMutable = [self metadataDic:identifier exifDic:exif];
    
    //NSLog(@"Info: %@",metadataAsMutable);
    
    CGImageSourceRef editImgSource = CGImageSourceCreateWithData((__bridge_retained CFDataRef)imageData, NULL);
    
    CFStringRef UTI = CGImageSourceGetType(imgSource);
    
    NSMutableData *newImageData = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)newImageData, UTI, 1, NULL);
    
    if(!destination)
        NSLog(@"***创建 失败***");
    
    CGImageDestinationAddImageFromSource(destination, editImgSource, 0, (__bridge CFDictionaryRef) metadataAsMutable);
    
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if(!success)
        NSLog(@"***保存 失败***");
    return newImageData;
}


+ (NSMutableDictionary *)metadataDic:(NSString *)identifier exifDic:(NSDictionary *)exif {
    
    PHFetchResult *aResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil];
    PHAsset *asset = [aResult firstObject];
    
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.networkAccessAllowed = NO;
    
    [imageRequestOptions setSynchronous:YES];
    
    __block CGImageSourceRef imgSource = nil;
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:imageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        imgSource = CGImageSourceCreateWithData((__bridge_retained CFDataRef)imageData, NULL);
        
    }];
    
    NSDictionary *metadata = nil;
    if(imgSource == nil){
        metadata = exif;
        
    }else{
        
        metadata = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imgSource, 0, NULL);
    }
    
    
    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
    
    NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    if (EXIFDictionary==nil) {
        EXIFDictionary = [[NSMutableDictionary alloc] init];
    }
    [EXIFDictionary setObject:@"InterPhoto"
                       forKey:(NSString *)kCGImagePropertyExifUserComment];
    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    
    NSMutableDictionary *TIFFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyTIFFDictionary] mutableCopy];
    if (TIFFDictionary==nil) {
        TIFFDictionary = [[NSMutableDictionary alloc] init];
    }
    [TIFFDictionary setObject:@"InterPhoto"
                       forKey:(NSString *)kCGImagePropertyTIFFMake];
    [TIFFDictionary setObject:@(1) forKey:(NSString *)kCGImagePropertyTIFFOrientation];
    [metadataAsMutable setObject:TIFFDictionary forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    [metadataAsMutable setObject:@(1) forKey:(NSString *)kCGImagePropertyIPTCImageOrientation];
    [metadataAsMutable setObject:@(1) forKey:(NSString *)kCGImagePropertyOrientation];
    return metadataAsMutable;
}

#pragma mark 获取图片exif
+ (NSDictionary *)imageExifWithLocalIdentifier:(NSString *)localIdentifier {
    
    
    if (localIdentifier == nil) {
        return nil;
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
    
    if(result == nil){
        return @{};
    }
    else if(result.count == 0){
        
        return@{};
    }
    
    __block BOOL isExecuted = NO;
    PHAsset *asset = result.firstObject;
    PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    [asset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
        
        CIImage *fullImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
        
        NSDictionary *nsdic = fullImage.properties;
        
        if([nsdic isKindOfClass:[NSDictionary class]]){
            
            [properties addEntriesFromDictionary:nsdic];
        }
        
        /*
         NSDictionary *originExif = nsdic[@"{Exif}"];
         
         NSDictionary *originMakerApple = nsdic[@"{MakerApple}"];
         
         NSDictionary *originGPS = nsdic[@"{GPS}"];
         
         properties[@"{GPS}"] = [NSDictionary dictionaryWithDictionary:originGPS];
         
         properties[@"{MakerApple}"] = [NSDictionary   dictionaryWithDictionary:originMakerApple];
         
         properties[@"{Exif}"] = [NSDictionary dictionaryWithDictionary:originExif];
         */
        isExecuted = YES;
        
    }];
    
    while (isExecuted == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return properties;
}

@end
