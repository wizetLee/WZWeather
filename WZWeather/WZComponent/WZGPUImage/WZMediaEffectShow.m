//
//  WZMediaEffectShow.m
//  WZWeather
//
//  Created by Wizet on 6/11/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZMediaEffectShow.h"

#define headlineKey @"headlineKey"
#define filterKey @"filterKey"

//#define WZMeidaEffectType(name) WZMeidaEffectType_##name
//
//typedef NS_ENUM(NSUInteger, WZMeidaEffectType) {
//    WZMeidaEffectType(none),
//    WZMeidaEffectType(brightness),//亮度
//    WZMeidaEffectType(saturability),//饱和度
//    WZMeidaEffectType(sharpen),//锐度
//    WZMeidaEffectType(whiteBalance),//白平衡
//    WZMeidaEffectType(hue),//色调
//    WZMeidaEffectType(contrast),//对比度
//    WZMeidaEffectType(construction),//结构
//};

@interface WZMediaEffectShowCell()

@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic,   weak) GPUImageFilter *curFilter;
@property (nonatomic,   weak) NSMutableArray <NSDictionary *>*dataSource;
@property (nonatomic, strong) UILabel *headlineLabel;
@property (nonatomic, strong) CALayer *surfaceLayer;
@property (nonatomic, strong) GPUImageFilter *scaleFilter;

@end

@implementation WZMediaEffectShowCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)setFilter:(GPUImageFilter *)filter {
    _curFilter = filter;
    [filter addTarget:_scaleFilter];
}

- (void)prepareForReuse {
    for (NSDictionary *dic in _dataSource) {
        GPUImageFilter *filter = dic[filterKey];
        if ([filter.targets containsObject:_scaleFilter]) {
            [filter removeTarget:_scaleFilter];
        }
    }
    //所有滤镜都要移除这个分支  因为不知道哪个滤镜持有这个分支
}


- (void)createViews {
    CGFloat scale = [UIScreen mainScreen].scale;
    scale = 0.1;
    _scaleFilter = [[GPUImageFilter alloc] init];
    [_scaleFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(self.frame.size.width * scale, self.frame.size.height * scale)];
    _imageView = [[GPUImageView alloc] initWithFrame:self.bounds];
    
    [self.contentView addSubview:_imageView];
    
    _headlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 44.0, self.frame.size.width, self.frame.size.height - 44.0)];
    [self.contentView addSubview:_headlineLabel];
    _headlineLabel.backgroundColor = [UIColor greenColor];
    _headlineLabel.adjustsFontSizeToFitWidth = true;
    _headlineLabel.textAlignment = NSTextAlignmentCenter;
    
    _surfaceLayer = [CALayer layer];
    _surfaceLayer.borderColor = [[UIColor yellowColor] colorWithAlphaComponent:0.6].CGColor;
    _surfaceLayer.borderWidth = 5.0;
    _surfaceLayer.frame = self.bounds;
    [self.contentView.layer addSublayer:_surfaceLayer];
    _surfaceLayer.hidden = false;
    
    
    [_scaleFilter addTarget:_imageView];
}

@end

@interface WZMediaEffectShow()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray <NSDictionary *>*dataSource;
@property (nonatomic, strong) UICollectionView *collection;
@property (nonatomic,   weak) NSIndexPath *selectedIndexPath;
@property (nonatomic,   weak) WZMediaEffectShowCell *cellP;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@property (nonatomic, strong) UIView *bgView;


@end

@implementation WZMediaEffectShow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)createViews {
    [self createFilers];
    
    _bgView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_bgView];
    _bgView.backgroundColor = [UIColor clearColor];
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_bgView addGestureRecognizer:_pan];
    

    [self addSubview:self.collection];
    self.alpha = 0.0;
}

- (void)createFilers {
    NSDictionary *tmpDic = nil;
    _dataSource = [NSMutableArray array];
    GPUImageFilter *filterNone = [[GPUImageFilter alloc] init];
    tmpDic = @{headlineKey:@"无",
               filterKey:filterNone,};
    [_dataSource addObject:tmpDic];
    //亮度luminance
    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    brightnessFilter.brightness = 0.1;
    tmpDic = @{headlineKey:@"亮度",
               filterKey:brightnessFilter,};
    [_dataSource addObject:tmpDic];
    //曝光
    GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc] init];
    exposureFilter.exposure = 1;
    tmpDic = @{headlineKey:@"曝光",
               filterKey:exposureFilter,};
    [_dataSource addObject:tmpDic];
    //对比度
    GPUImageContrastFilter *constrastFilter = [[GPUImageContrastFilter alloc] init];
    constrastFilter.contrast = 4.0;
    tmpDic = @{headlineKey:@"对比度",
               filterKey:constrastFilter,};
    [_dataSource addObject:tmpDic];
    
    //饱和度
    GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
    saturationFilter.saturation = 2;
    tmpDic = @{headlineKey:@"饱和度",
               filterKey:saturationFilter,};
    [_dataSource addObject:tmpDic];
    //伽马线
    GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc] init];
    gammaFilter.gamma = 3.0;
    tmpDic = @{headlineKey:@"伽马线",
               filterKey:gammaFilter,};
    [_dataSource addObject:tmpDic];
    //反色
    GPUImageColorInvertFilter *colorInvertFilter = [[GPUImageColorInvertFilter alloc] init];
    tmpDic = @{headlineKey:@"反色",
               filterKey:colorInvertFilter,};
    [_dataSource addObject:tmpDic];
    //褐色（怀旧）
    GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
    sepiaFilter.intensity = 1;
    tmpDic = @{headlineKey:@"怀旧",
               filterKey:sepiaFilter,};
    [_dataSource addObject:tmpDic];
    //色阶
    GPUImageLevelsFilter *levelsFilter = [[GPUImageLevelsFilter alloc] init];
    tmpDic = @{headlineKey:@"色阶",
               filterKey:levelsFilter,};
    [_dataSource addObject:tmpDic];
    //灰度
    GPUImageGrayscaleFilter *grayscaleFilter = [[GPUImageGrayscaleFilter alloc] init];
    tmpDic = @{headlineKey:@"灰度",
               filterKey:grayscaleFilter,};
    [_dataSource addObject:tmpDic];
    //色彩直方图显示在图片上
//    GPUImageHistogramFilter *histogramFilter = [[GPUImageHistogramFilter alloc] initWithHistogramType:kGPUImageHistogramGreen];
//    histogramFilter.downsamplingFactor = 2;
//    [_dataSource addObject:histogramFilter];
    //色彩直方图
    GPUImageHistogramGenerator *histomgramGenerator = [[GPUImageHistogramGenerator alloc] init];
    tmpDic = @{headlineKey:@"色彩直方图",
               filterKey:histomgramGenerator,};
    [_dataSource addObject:tmpDic];
    //RGB
    GPUImageRGBFilter *rgbFilter = [[GPUImageRGBFilter alloc] init];
    rgbFilter.red = 0.5;
    tmpDic = @{headlineKey:@"RGB",
               filterKey:rgbFilter,};
    [_dataSource addObject:tmpDic];
    //色调曲线
    GPUImageToneCurveFilter *toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
    [self key:@"色调曲线" value:toneCurveFilter];
    //单色
    GPUImageMonochromeFilter *monochromeFilter = [[GPUImageMonochromeFilter alloc] init];
    monochromeFilter.intensity = 1;
    [self key:@"单色" value:monochromeFilter];
    //不透明度
    GPUImageOpacityFilter *opacityFilter = [[GPUImageOpacityFilter alloc] init];
    opacityFilter.opacity = 0.5;
    [self key:@"不透明度" value:opacityFilter];
    //提亮阴影
    GPUImageHighlightShadowFilter *highlightShadowFilter = [[GPUImageHighlightShadowFilter alloc] init];
    highlightShadowFilter.shadows = 0.5;
    highlightShadowFilter.highlights = 0.5;
//    [self key:@"提亮阴影" value:highlightShadowFilter];
    //色彩替换（替换亮度和暗部色彩）
    GPUImageFalseColorFilter *falseColorFilter = [[GPUImageFalseColorFilter alloc] init];
//    falseColorFilter.
//    [self key:@"色彩替换" value:falseColorFilter];
    //色度 2_input
//    GPUImageHueBlendFilter *hueBlendFilter = [[GPUImageHueBlendFilter alloc] init];
//    [self key:@"色度" value:hueBlendFilter];
    //色度键 无效（查原因）
//    GPUImageChromaKeyFilter *chromaKeyFilter = [[GPUImageChromaKeyFilter alloc] init];
//    [self key:@"色度键" value:chromaKeyFilter];
    //白平衡
    GPUImageWhiteBalanceFilter *whiteBalanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
    [self key:@"白平衡" value:whiteBalanceFilter];
    //像素平均色值
    GPUImageAverageColor *averageColor = [[GPUImageAverageColor alloc] init];
    [self key:@"像素平均色值" value:averageColor];
    //纯色
    GPUImageSolidColorGenerator *solidColorGenerator = [[GPUImageSolidColorGenerator alloc] init];
    [self key:@"纯色" value:solidColorGenerator];
    //亮度平均
    GPUImageLuminosity *luminosity = [[GPUImageLuminosity alloc] init];
    [self key:@"亮度平均" value:luminosity];
    //像素色值亮度平均，图像黑白（类似漫画的效果） group
//    GPUImageAverageLuminanceThresholdFilter *averageLuminanceThresholdFilter = [[GPUImageAverageLuminanceThresholdFilter alloc] init];
//    [self key:@"类漫画" value:averageLuminanceThresholdFilter];
    //色彩调整
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    lookupFilter.intensity = 0.4;
    [self key:@"色彩调整" value:lookupFilter];
//    GPUImageAmatorkaFilter *amatorkFilter = [[GPUImageAmatorkaFilter alloc] init];
//    [self key:@"色彩调整1" value:amatorkFilter];
    //  group
//    GPUImageMissEtikateFilter *missEtikateFilter = [[GPUImageMissEtikateFilter alloc] init];
//    [self key:@"色彩调整2" value:missEtikateFilter];
//    GPUImageSoftEleganceFilter *softEleganceFilter = [[GPUImageSoftEleganceFilter alloc] init];
//    [self key:@"色彩调整3" value:softEleganceFilter];
    //十字
    GPUImageCrosshairGenerator *crosshairGenerator = [[GPUImageCrosshairGenerator alloc] init];
    [self key:@"十字" value:crosshairGenerator];
    //线条
    GPUImageLineGenerator *lineGenerator = [[GPUImageLineGenerator alloc] init];
    [self key:@"线条" value:lineGenerator];
    //形状变化
    GPUImageTransformFilter *transformFilter = [[GPUImageTransformFilter alloc] init];
    [self key:@"形状变化" value:transformFilter];
    //锐度
    GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    [self key:@"锐度" value:sharpenFilter];
//    //反遮罩锐度 group
//    GPUImageUnsharpMaskFilter *unsharpMaskFilter = [[GPUImageUnsharpMaskFilter alloc] init];
//    [self key:@"反遮罩锐度" value:unsharpMaskFilter];
    //色调
  
    //结构
    
}

- (void)key:(NSString *)key value:(GPUImageFilter *)filter {

   NSDictionary *tmpDic = @{headlineKey:key,
               filterKey:filter,};
    [_dataSource addObject:tmpDic];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    //计算变化的比例
    CGPoint oppositePoint = [pan translationInView:self];
    if (oppositePoint.x >= 0) {
        CGFloat scale = oppositePoint.x / _collection.frame.size.width;
        self.alpha = 1 - scale;
        _collection.minX = self.frame.size.width - _collection.frame.size.width + oppositePoint.x;
    }
    if (pan.state == UIGestureRecognizerStateBegan) {

    
    }
   if (pan.state == UIGestureRecognizerStateEnded) {
       [self caculateStatus];
       //清空链
#warning 需要清空链
    }
}

- (void)caculateStatus {
    [UIView animateWithDuration:0.25 animations:^{
        if (self.alpha > 0.5) {
            [self showPercent:1];
        } else {
            if ([_delegate respondsToSelector:@selector(mediaEffectShowDidShrinked)]) {
                [_delegate mediaEffectShowDidShrinked];
            }
            [self showPercent:0];

        }
    }];
}

- (void)showPercent:(CGFloat)percent {
    self.alpha = percent;
    CGFloat x = self.frame.size.width - percent * _collection.frame.size.width;
    if (x >= self.frame.size.width) {
        x = self.frame.size.width;
    }
    _collection.minX = x;
}

- (void)dismissPercent:(CGFloat)percent {
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource?_dataSource.count:0;
}

- (__kindof WZMediaEffectShowCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WZMediaEffectShowCell *cell = (WZMediaEffectShowCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WZMediaEffectShowCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    
    NSDictionary *dic = _dataSource[indexPath.row];
    NSString *headline = dic[headlineKey];
    GPUImageFilter *filter = dic[filterKey];
    cell.headlineLabel.text = headline;
    
	cell.surfaceLayer.hidden = !(_selectedIndexPath == indexPath);
    cell.dataSource = _dataSource;
    ///透过一个低倍的滤镜
    __weak typeof(self) weakSelf = self;
    runSynchronouslyOnVideoProcessingQueue(^{
        [weakSelf.inputSource addTarget:filter];
        [cell setFilter:filter];
    });
   
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WZMediaEffectShowCell *cell = (WZMediaEffectShowCell *)[collectionView cellForItemAtIndexPath:_selectedIndexPath];
    _cellP.surfaceLayer.hidden = true;///PS：双重引用保障... 因为cell未被重用时候调用上面方法时cell为nil
    cell.surfaceLayer.hidden = true;
    
    GPUImageFilter *tmpFilter = nil;
    if (_selectedIndexPath == indexPath) {
        cell.surfaceLayer.hidden = true;
        tmpFilter =_dataSource[0][@"filterKey"];
        _selectedIndexPath = nil;
    } else {
        _selectedIndexPath = indexPath;
        cell = (WZMediaEffectShowCell *)[collectionView cellForItemAtIndexPath:indexPath];
        //    cell.selected = true;
        cell.surfaceLayer.hidden = false;
        _cellP = cell;
        tmpFilter =_dataSource[indexPath.row][@"filterKey"];
    }
    if (tmpFilter && [_delegate respondsToSelector:@selector(mediaEffectShow:didSelectedFilter:)] ) {
        [_delegate mediaEffectShow:self didSelectedFilter:tmpFilter];
    }
    //更改实体数据选中项
}

- (void)didSelectedFilter:(GPUImageFilter *)filter {
    if ([filter isKindOfClass:[GPUImageFilter class]]) {
        
    } else if ([filter isKindOfClass:[GPUImageSaturationFilter class]]) {
        
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    } else {
        return view;
    }
}

#pragma mark - Accessor
-(UICollectionView *)collection {
    if (!_collection) {
        CGFloat w = 80.0;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(w - 10.0, w - 10.0);
        _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0.0, w, self.frame.size.height) collectionViewLayout:layout];
        [_collection registerClass:[WZMediaEffectShowCell class] forCellWithReuseIdentifier:@"WZMediaEffectShowCell"];
        _collection.delegate = self;
        _collection.dataSource = self;
        
    }
    return _collection;
}


@end
