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


- (void)createViews {
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
    
}

@end

@interface WZMediaEffectShow()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray <NSDictionary *>*dataSource;
@property (nonatomic, strong) UICollectionView *collection;
@property (nonatomic,   weak) NSIndexPath *selectedIndexPath;
@property (nonatomic,   weak) WZMediaEffectShowCell *cellP;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UISlider *slider;

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
    _slider = [[UISlider alloc] init];
    _slider.hidden = true;
    _slider.frame = CGRectMake(10.0, 44.0, [UIScreen mainScreen].bounds.size.height - 44.0 - 44.0 - 44.0, 88.0);
    
    _slider.backgroundColor = [UIColor greenColor];
    _slider.layer.anchorPoint = CGPointMake(0, 0);
    _slider.transform = CGAffineTransformRotate(_slider.transform, M_PI_2);
    [self addSubview:_slider];
    [_slider addTarget:self action:@selector(slider:) forControlEvents:UIControlEventValueChanged];
    self.alpha = 0.0;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_collection addGestureRecognizer:longPress];
}

- (void)createFilers {
    NSDictionary *tmpDic = nil;
    _dataSource = [NSMutableArray array];
    GPUImageOutput<GPUImageInput> *filter;
    
    GPUImageFilter *filterNone = [[GPUImageFilter alloc] init];
    tmpDic = @{headlineKey:@"无",
               filterKey:filterNone,};
    [_dataSource addObject:tmpDic];
    
    filter = [[GPUImageTrillColorOffsetFilter alloc] init];
    [self key:@"抖音" value:filter];
    
    //饱和度
     filter = [[GPUImageSaturationFilter alloc] init];
     [self key:@"饱和度" value:filter];

    //反色
    filter = [[GPUImageColorInvertFilter alloc] init];
    [self key:@"反色" value:filter];

//    //色彩直方图
//    GPUImageHistogramGenerator *histomgramGenerator = [[GPUImageHistogramGenerator alloc] init];
//    tmpDic = @{headlineKey:@"色彩直方图",
//               filterKey:histomgramGenerator,};
//    [_dataSource addObject:tmpDic];


    //色度键 无效（查原因）
//    GPUImageChromaKeyFilter *chromaKeyFilter = [[GPUImageChromaKeyFilter alloc] init];
//    [self key:@"色度键" value:chromaKeyFilter];

    //纯色
//    GPUImageSolidColorGenerator *solidColorGenerator = [[GPUImageSolidColorGenerator alloc] init];
//    [self key:@"纯色" value:solidColorGenerator];


//    //十字
//    GPUImageCrosshairGenerator *crosshairGenerator = [[GPUImageCrosshairGenerator alloc] init];
//    [self key:@"十字" value:crosshairGenerator];
    
    //形状变化
//    GPUImageTransformFilter *transformFilter = [[GPUImageTransformFilter alloc] init];
//    [self key:@"形状变化" value:transformFilter];
  
        UIImage *inputImage = [UIImage imageNamed:@"mask"];
        GPUImagePicture *sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
        [sourcePicture processImage];
  
    //结构

    GPUImagePixellateFilter *pixellateFilter = [[GPUImagePixellateFilter alloc] init];
    [self key:@"像素化" value:pixellateFilter];

    //围绕一个圆圈进行的像素化
//    GPUImagePolarPixellateFilter *polarPiexellateFilter = [[GPUImagePolarPixellateFilter alloc] init];
//    [self key:@"PolarPixellateFilter" value:polarPiexellateFilter];
    
//    //按照一定规模半径的圆圈进行像素化
//    GPUImagePixellatePositionFilter *pixellatePositionFilter = [[GPUImagePixellatePositionFilter alloc] init];
//    [self key:@"PixellatePositionFilter" value:pixellatePositionFilter];
    
    GPUImagePolkaDotFilter *polkaDotFilter = [[GPUImagePolkaDotFilter alloc] init];
    [self key:@"圆点网板" value:polkaDotFilter];
    
    GPUImageHalftoneFilter *imageHalftoneFilter = [[GPUImageHalftoneFilter alloc] init];
    [self key:@"黑白网板" value:imageHalftoneFilter];
    
    
    filter = [[GPUImageCrosshatchFilter alloc] init];
    [self key:@"交叉线" value:filter];
    
    
    
    filter = [[GPUImageGrayscaleFilter alloc] init];
    [self key:@"灰度" value:filter];
    
    filter = [[GPUImageMonochromeFilter alloc] init];
    [(GPUImageMonochromeFilter *)filter setColor:(GPUVector4){0.0f, 0.0f, 1.0f, 1.f}];
    [self key:@"单色" value:filter];
    
    filter = [[GPUImageFalseColorFilter alloc] init];
    [self key:@"色彩替换" value:filter];
    
//    filter = [[GPUImageSoftEleganceFilter alloc] init];
//    [self key:@"SoftEleganceFilter" value:filter];
    
//    filter = [[GPUImageMissEtikateFilter alloc] init];
//    [self key:@"MissEtikateFilter" value:filter];
    
//    filter = [[GPUImageAmatorkaFilter alloc] init];
//    [self key:@"AmatorkaFilter" value:filter];
   
    
    filter = [[GPUImageContrastFilter alloc] init];
    [self key:@"对比度" value:filter];
    
    filter = [[GPUImageBrightnessFilter alloc] init];
    [self key:@"亮度" value:filter];
    
    filter = [[GPUImageLevelsFilter alloc] init];
    [self key:@"色阶" value:filter];
    
    filter = [[GPUImageRGBFilter alloc] init];
    [self key:@"RGB" value:filter];
    
    filter = [[GPUImageHueFilter alloc] init];
    [self key:@"色调" value:filter];
    
    filter = [[GPUImageWhiteBalanceFilter alloc] init];
    [self key:@"白平衡" value:filter];
    
    filter = [[GPUImageExposureFilter alloc] init];
    [self key:@"曝光" value:filter];
    
    filter = [[GPUImageSharpenFilter alloc] init];
    [self key:@"锐度" value:filter];
    
    filter = [[GPUImageUnsharpMaskFilter alloc] init];
    [self key:@"反遮罩锐度" value:filter];
    
    filter = [[GPUImageGammaFilter alloc] init];
    [self key:@"伽马线" value:filter];
    
//    filter = [[GPUImageToneCurveFilter alloc] init];
//    [(GPUImageToneCurveFilter *)filter setBlueControlPoints:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)], [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)], nil]];
//    [self key:@"色调曲线" value:filter];
    
    filter = [[GPUImageHighlightShadowFilter alloc] init];
    [self key:@"提亮阴影" value:filter];
    
    filter = [[GPUImageHazeFilter alloc] init];
    [self key:@"Haze / UV" value:filter];
    
//    filter = [[GPUImageAverageColor alloc] init];
//    [self key:@"像素平均色值" value:filter];

//    filter = [[GPUImageLuminosity alloc] init];
//    [self key:@"亮度平均" value:filter];
    
    filter = [[GPUImageHistogramFilter alloc] initWithHistogramType:kGPUImageHistogramRGB];
    [self key:@"色彩直方图" value:filter];
    
//    filter = [[GPUImageHueBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"色度" value:filter];
    
    filter = [[GPUImageOpacityFilter alloc] init];
    [sourcePicture addTarget:filter];
    [self key:@"不透明度" value:filter];
    
    filter = [[GPUImageiOSBlurFilter alloc] init];
    [self key:@"iOS 7 Blur" value:filter];
    
    filter = [[GPUImageSepiaFilter alloc] init];
    [self key:@"怀旧" value:filter];
    
    filter = [[GPUImageHistogramEqualizationFilter alloc] initWithHistogramType:kGPUImageHistogramLuminance];
    [self key:@"HistogramEqualizationFilter" value:filter];
    
    filter = [[GPUImageLuminanceThresholdFilter alloc] init];
    [self key:@"LuminanceThresholdFilter" value:filter];
    
    filter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    [self key:@"AdaptiveThresholdFilter" value:filter];
    
    filter = [[GPUImageAverageLuminanceThresholdFilter alloc] init];
    [self key:@"AverageLuminanceThresholdFilter" value:filter];
    
    filter = [[GPUImageMaskFilter alloc] init];
    [(GPUImageFilter*)filter setBackgroundColorRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    [self key:@"MaskFilter" value:filter];
    
     filter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
    [self key:@"Sobel边缘检测" value:filter];
    
    filter = [[GPUImageXYDerivativeFilter alloc] init];
    [self key:@"XY边缘检测" value:filter];
    
    filter = [[GPUImageHarrisCornerDetectionFilter alloc] init];
    [(GPUImageHarrisCornerDetectionFilter *)filter setThreshold:0.20];
    [self key:@"Harris Corner边缘检测" value:filter];
    
    filter = [[GPUImageNobleCornerDetectionFilter alloc] init];
    [(GPUImageNobleCornerDetectionFilter *)filter setThreshold:0.20];
    [self key:@"Noble Corner边缘检测" value:filter];
    
    filter = [[GPUImageShiTomasiFeatureDetectionFilter alloc] init];
    [(GPUImageShiTomasiFeatureDetectionFilter *)filter setThreshold:0.20];
    [self key:@"ShiTomasi Feature边缘检测" value:filter];
//
//    filter = [[GPUImageHoughTransformLineDetector alloc] init];
//    [(GPUImageHoughTransformLineDetector *)filter setLineDetectionThreshold:0.60];
//    [self key:@"HoughTransformLineDetector" value:filter];
//
    filter = [[GPUImagePrewittEdgeDetectionFilter alloc] init];
    [self key:@"Prewitt边缘检测" value:filter];
    
    filter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
    [self key:@"CannyEdge边缘检测" value:filter];
    
    filter = [[GPUImageThresholdEdgeDetectionFilter alloc] init];
    [self key:@"Threshold边缘检测" value:filter];
    
    filter = [[GPUImageLocalBinaryPatternFilter alloc] init];
    [self key:@"LocalBinaryPatternFilter" value:filter];
    
    filter = [[GPUImageBuffer alloc] init];
    [self key:@"Buffer" value:filter];
    
    filter = [[GPUImageLowPassFilter alloc] init];
    [self key:@"重影（低程度）" value:filter];
    
    filter = [[GPUImageHighPassFilter alloc] init];
    [self key:@"重影（高程度）" value:filter];
    
//    [videoCamera rotateCamera];//动作（手势？）测试
//     filter = [[GPUImageMotionDetector alloc] init];
//    [self key:@"MotionDetector" value:filter];
    
    filter = [[GPUImageSketchFilter alloc] init];
    [self key:@"Sketch边缘检测" value:filter];
    
    filter = [[GPUImageThresholdSketchFilter alloc] init];
    [self key:@"ThresholdSketch边缘检测" value:filter];
    
//    filter = [[GPUImageToonFilter alloc] init];
//    [self key:@"Toon" value:filter];
//
//    filter = [[GPUImageSmoothToonFilter alloc] init];
//    [self key:@"SmoothToonFilter" value:filter];
    
//    filter = [[GPUImageTiltShiftFilter alloc] init];
//    [(GPUImageTiltShiftFilter *)filter setTopFocusLevel:0.4];
//    [(GPUImageTiltShiftFilter *)filter setBottomFocusLevel:0.6];
//    [(GPUImageTiltShiftFilter *)filter setFocusFallOffRate:0.2];
//    [self key:@"TiltShift " value:filter];
//
//    filter = [[GPUImageCGAColorspaceFilter alloc] init];
//    [self key:@"CGAColorspaceFilter" value:filter];
//
//    filter = [[GPUImage3x3ConvolutionFilter alloc] init];
//    [(GPUImage3x3ConvolutionFilter *)filter setConvolutionKernel:(GPUMatrix3x3){
//        {-1.0f,  0.0f, 1.0f},
//        {-2.0f, 0.0f, 2.0f},
//        {-1.0f,  0.0f, 1.0f}
//    }];
//    [self key:@"3x3ConvolutionFilter" value:filter];
//
//    filter = [[GPUImageEmbossFilter alloc] init];
//    [self key:@"EmbossFilter" value:filter];
//
//    filter = [[GPUImageLaplacianFilter alloc] init];
//    [self key:@"LaplacianFilter" value:filter];
//
//    filter = [[GPUImagePosterizeFilter alloc] init];
//    [self key:@"PosterizeFilter" value:filter];
//
//    filter = [[GPUImageSwirlFilter alloc] init];
//    [self key:@"SwirlFilter" value:filter];
//
//    filter = [[GPUImageBulgeDistortionFilter alloc] init];
//    [self key:@"BulgeDistortionFilter" value:filter];
//
//    filter = [[GPUImageSphereRefractionFilter alloc] init];
//    [(GPUImageSphereRefractionFilter *)filter setRadius:0.15];
//    [self key:@"SphereRefractionFilter" value:filter];
//
//    filter = [[GPUImageGlassSphereFilter alloc] init];
//    [(GPUImageGlassSphereFilter *)filter setRadius:0.15];
//    [self key:@"GlassSphereFilter" value:filter];
//
//    filter = [[GPUImagePinchDistortionFilter alloc] init];
//    [self key:@"PinchDistortionFilter" value:filter];
//
//    filter = [[GPUImageStretchDistortionFilter alloc] init];
//    [self key:@"StretchDistortionFilter" value:filter];
//
//    filter = [[GPUImageRGBDilationFilter alloc] initWithRadius:4];
//    [self key:@"RGBDilationFilter" value:filter];
//
//    filter = [[GPUImageRGBErosionFilter alloc] initWithRadius:4];
//    [self key:@"RGBErosionFilter" value:filter];
//
//    filter = [[GPUImageRGBOpeningFilter alloc] initWithRadius:4];
//    [self key:@"RGBOpeningFilter" value:filter];
//
//    filter = [[GPUImageRGBClosingFilter alloc] initWithRadius:4];
//    [self key:@"RGBClosingFilter" value:filter];
//
//    filter = [[GPUImagePerlinNoiseFilter alloc] init];
//    [self key:@"PerlinNoiseFilter" value:filter];
//
////    GPUImageVoronoiConsumerFilter
////    [self key:@"泰森多边形法" value:filter];
//
//    filter = [[GPUImageMosaicFilter alloc] init];
//    [(GPUImageMosaicFilter *)filter setTileSet:@"squares.png"];
//    [(GPUImageMosaicFilter *)filter setColorOn:NO];
//    [self key:@"MosaicFilter" value:filter];
//

//
//    filter = [[GPUImageChromaKeyBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [(GPUImageChromaKeyBlendFilter *)filter setColorToReplaceRed:0.0 green:1.0 blue:0.0];
//    [self key:@"ChromaKeyBlendFilter" value:filter];

////    filter = [[GPUImageChromaKeyFilter alloc] init];
////    [sourcePicture addTarget:filter];
////    [(GPUImageChromaKeyFilter *)filter setColorToReplaceRed:0.0 green:1.0 blue:0.0];
////    [self key:@"ChromaKeyFilter" value:filter];
//
//
//
//    filter = [[GPUImageAddBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"AddBlendFilter" value:filter];
//
//    filter = [[GPUImageDivideBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"DivideBlendFilter" value:filter];
//
//    filter = [[GPUImageMultiplyBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"MultiplyBlendFilter" value:filter];
//
//    filter = [[GPUImageOverlayBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"OverlayBlendFilter" value:filter];
//
//    filter = [[GPUImageLightenBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"RGBDilationFilter" value:filter];
//
//    filter = [[GPUImageDarkenBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"RGBDilationFilter" value:filter];
//
//    filter = [[GPUImageDissolveBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"DissolveBlendFilter" value:filter];
//
//    filter = [[GPUImageScreenBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"ScreenBlendFilter" value:filter];
//
//    filter = [[GPUImageColorBurnBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"ColorBurnBlendFilter" value:filter];
//
//    filter = [[GPUImageColorDodgeBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"RGBDilationFilter" value:filter];
//
//    filter = [[GPUImageLinearBurnBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"LinearBurnBlendFilter" value:filter];
//
//    filter = [[GPUImageExclusionBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"ExclusionBlendFilter" value:filter];
//
//    filter = [[GPUImageDifferenceBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"DifferenceBlendFilter" value:filter];
//
//    filter = [[GPUImageSubtractBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"SubtractBlendFilter" value:filter];
//
//    filter = [[GPUImageHardLightBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"HardLightBlendFilter" value:filter];
//
//    filter = [[GPUImageSoftLightBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"SoftLightBlendFilter" value:filter];
//
//    filter = [[GPUImageColorBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"ColorBlendFilter" value:filter];
//

//
//    filter = [[GPUImageSaturationBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"RGBDilationFilter" value:filter];
//
//    filter = [[GPUImageLuminosityBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"LuminosityBlendFilter" value:filter];
//
//    filter = [[GPUImageNormalBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"NormalBlendFilter" value:filter];
//
//    filter = [[GPUImagePoissonBlendFilter alloc] init];
//    [sourcePicture addTarget:filter];
//    [self key:@"PoissonBlendFilter" value:filter];
//

//
//    filter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"CustomFilter"];
//    [self key:@"Filter" value:filter];
//
//    filter = [[GPUImageRGBDilationFilter alloc] init];
//    [self key:@"RGBDilationFilter" value:filter];
//
//    filter = [[GPUImageKuwaharaRadius3Filter alloc] init];
//    [self key:@"KuwaharaRadius3Filter" value:filter];
//
//    filter = [[GPUImageVignetteFilter alloc] init];
//    [self key:@"Vignette" value:filter];
//
//    filter = [[GPUImageGaussianBlurFilter alloc] init];
//    [self key:@"Gaussian Blur" value:filter];
//
//    filter = [[GPUImageBoxBlurFilter alloc] init];
//    [self key:@"Box Blur" value:filter];
//
//    filter = [[GPUImageMedianFilter alloc] init];
//    [self key:@"Median" value:filter];
//
//    filter = [[GPUImageMotionBlurFilter alloc] init];
//    [self key:@"Motion Blur" value:filter];
//
//    filter = [[GPUImageZoomBlurFilter alloc] init];
//    [self key:@"Zoom Blur" value:filter];
//

//

//
//    filter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
//    [(GPUImageGaussianSelectiveBlurFilter*)filter setExcludeCircleRadius:40.0/320.0];
//    [self key:@"Selective Blur" value:filter];
//
//    filter = [[GPUImageGaussianBlurPositionFilter alloc] init];
//    [(GPUImageGaussianBlurPositionFilter*)filter setBlurRadius:40.0/320.0];
//    [self key:@"Selective Blur" value:filter];
//
    // 双边滤波
//    filter = [[GPUImageBilateralFilter alloc] init];
//    [self key:@"Bilateral Blur" value:filter];
//
//    filter = [[GPUImageFilterGroup alloc] init];
//
//    GPUImageSepiaFilter *sepiaFilter2 = [[GPUImageSepiaFilter alloc] init];
//    [(GPUImageFilterGroup *)filter addFilter:sepiaFilter2];
//
//    GPUImagePixellateFilter *pixellateFilter2 = [[GPUImagePixellateFilter alloc] init];
//    [(GPUImageFilterGroup *)filter addFilter:pixellateFilter];
//
//    [sepiaFilter2 addTarget:pixellateFilter];
//    [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:sepiaFilter2]];
//    [(GPUImageFilterGroup *)filter setTerminalFilter:pixellateFilter2];
//    [self key:@"Filter Group" value:filter];
    
//    filter = [[GPUImageSaturationFilter alloc] init];
//    [self key:@"Face Detection" value:filter];
//    //写代理
//    //    [camera setDelegate:self];
    
    //GPUImageFilterPipeline
    

}

- (void)key:(NSString *)key value:(GPUImageOutput <GPUImageInput>*)filter {

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
//    GPUImageFilter *filter = dic[filterKey];
    cell.headlineLabel.text = headline;
    
    cell.surfaceLayer.hidden = !(_selectedIndexPath == indexPath);

    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0) {
    return true;//配置不可移动名单
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath NS_AVAILABLE_IOS(9_0) {
    id objc = self.dataSource[sourceIndexPath.item];
    [self.dataSource removeObject:objc];
    [self.dataSource insertObject:objc atIndex:destinationIndexPath.item];
}
///存在的问题： 移动的时候会有cell快速跳跃 这可能是个大问题影响体验
- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    CGPoint point = [longPress locationInView:_collection];
    NSIndexPath *indexPath = [_collection indexPathForItemAtPoint:point];
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
            if (!indexPath) {
                break;
            }
            [_collection beginInteractiveMovementForItemAtIndexPath:indexPath];
            break;
        case UIGestureRecognizerStateChanged:
            [_collection updateInteractiveMovementTargetPosition:point];
            break;
        case UIGestureRecognizerStateEnded:
            [_collection endInteractiveMovement];
            break;
        default:
            [_collection cancelInteractiveMovement];
            break;
    }
}


#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WZMediaEffectShowCell *cell = (WZMediaEffectShowCell *)[collectionView cellForItemAtIndexPath:_selectedIndexPath];
    _cellP.surfaceLayer.hidden = true;///PS：双重引用保障... 因为cell未被重用时候调用上面方法时cell为nil
    cell.surfaceLayer.hidden = true;
    
    GPUImageFilter *filter = nil;
    if (_selectedIndexPath == indexPath) {
        cell.surfaceLayer.hidden = true;
        filter =_dataSource[0][@"filterKey"];
        _selectedIndexPath = nil;
    } else {
        _selectedIndexPath = indexPath;
        cell = (WZMediaEffectShowCell *)[collectionView cellForItemAtIndexPath:indexPath];
        //    cell.selected = true;
        cell.surfaceLayer.hidden = false;
        _cellP = cell;
        filter =_dataSource[indexPath.row][@"filterKey"];
    }
    if (filter && [_delegate respondsToSelector:@selector(mediaEffectShow:didSelectedFilter:)] ) {
        [_delegate mediaEffectShow:self didSelectedFilter:filter];
    }
    //更改实体数据选中项
     _slider.hidden = true;
    if ([filter isKindOfClass:[GPUImageSaturationFilter class]]) {
        //饱和度
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:2.0];
        [_slider setValue:((GPUImageSaturationFilter *)filter).saturation];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageContrastFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:4.0];
        [_slider setValue:((GPUImageContrastFilter *)filter).contrast];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageBrightnessFilter class]]) {
        [_slider setMinimumValue:-1.0];
        [_slider setMaximumValue:1.0];
        [_slider setValue:((GPUImageBrightnessFilter *)filter).brightness];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageLevelsFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
        [_slider setValue:0.0];
        float value = [_slider value];
        [(GPUImageLevelsFilter *)filter setRedMin:value gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
        [(GPUImageLevelsFilter *)filter setGreenMin:value gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
        [(GPUImageLevelsFilter *)filter setBlueMin:value gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageRGBFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:2.0];
        [_slider setValue:((GPUImageRGBFilter *)filter).green];
         _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageColorInvertFilter class]]) {
        _slider.hidden = true;
    } else if ([filter isKindOfClass:[GPUImageSepiaFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
        [_slider setValue:((GPUImageSepiaFilter *)filter).intensity];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageGrayscaleFilter class]]) {
        _slider.hidden = true;
    } else if ([filter isKindOfClass:[GPUImageMonochromeFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
        [_slider setValue:((GPUImageMonochromeFilter *)filter).intensity];
        _slider.hidden = false;
        [(GPUImageMonochromeFilter *)filter setColor:(GPUVector4){0.0f, 0.0f, 1.0f, 1.f}];
    } else if ([filter isKindOfClass:[GPUImageOpacityFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
         [_slider setValue:((GPUImageOpacityFilter *)filter).opacity];
        _slider.hidden = false;

    } else if ([filter isKindOfClass:[GPUImagePixellateFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
        [_slider setValue:((GPUImagePixellateFilter *)filter).fractionalWidthOfAPixel];
         _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImagePolarPixellateFilter class]]) {
        [_slider setMinimumValue:-0.1];
        [_slider setMaximumValue:0.1];
        [_slider setValue:((GPUImagePolarPixellateFilter *)filter).pixelSize.width];
      
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImagePolkaDotFilter class]]) {
        [_slider setValue:((GPUImagePolkaDotFilter *)filter).dotScaling];
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:0.3];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageHalftoneFilter class]]) {
        [_slider setValue:((GPUImageHalftoneFilter *)filter).fractionalWidthOfAPixel];
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:0.05];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageCrosshatchFilter class]]) {
        [_slider setValue:((GPUImageCrosshatchFilter *)filter).crossHatchSpacing];
        [_slider setMinimumValue:0.01];
        [_slider setMaximumValue:0.06];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageSobelEdgeDetectionFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
         [_slider setValue:((GPUImageSobelEdgeDetectionFilter *)filter).edgeStrength];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImagePrewittEdgeDetectionFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
         [_slider setValue:((GPUImagePrewittEdgeDetectionFilter *)filter).edgeStrength];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageCannyEdgeDetectionFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
         [_slider setValue:((GPUImageCannyEdgeDetectionFilter *)filter).blurRadiusInPixels];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageThresholdEdgeDetectionFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
        [_slider setValue:((GPUImageThresholdEdgeDetectionFilter *)filter).threshold];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageXYDerivativeFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
        [_slider setValue:((GPUImageXYDerivativeFilter *)filter).edgeStrength];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageHarrisCornerDetectionFilter class]]) {
        
        [_slider setMinimumValue:0.01];
        [_slider setMaximumValue:0.70];
        [_slider setValue:((GPUImageHarrisCornerDetectionFilter *)filter).threshold];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageNobleCornerDetectionFilter class]]) {
        [_slider setMinimumValue:0.01];
        [_slider setMaximumValue:0.70];
        [_slider setValue:((GPUImageNobleCornerDetectionFilter *)filter).threshold];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageShiTomasiFeatureDetectionFilter class]]) {
        [_slider setMinimumValue:0.01];
        [_slider setMaximumValue:0.70];
          [_slider setValue:((GPUImageShiTomasiFeatureDetectionFilter *)filter).threshold];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageLowPassFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
        [_slider setValue:((GPUImageLowPassFilter *)filter).filterStrength];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageHighPassFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
        [_slider setValue:((GPUImageHighPassFilter *)filter).filterStrength];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageSketchFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
        [_slider setValue:((GPUImageSketchFilter *)filter).edgeStrength];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageThresholdSketchFilter class]]) {
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:1.0];
        [_slider setValue:((GPUImageThresholdSketchFilter *)filter).threshold];
        _slider.hidden = false;
    } else if ([filter isKindOfClass:[GPUImageTiltShiftFilter class]]) {
        [(GPUImageTiltShiftFilter *)filter setTopFocusLevel:0.4];
        [(GPUImageTiltShiftFilter *)filter setBottomFocusLevel:0.6];
        [(GPUImageTiltShiftFilter *)filter setFocusFallOffRate:0.2];
        _slider.hidden = false;
        [_slider setMinimumValue:0.2];
        [_slider setMaximumValue:0.8];
        [_slider setValue:((GPUImageTiltShiftFilter *)filter).bottomFocusLevel - 0.1];
    } else if ([filter isKindOfClass:[GPUImageSharpenFilter class]]) {
        _slider.hidden = false;
        [_slider setMinimumValue:-4.0];
        [_slider setMaximumValue:4.0];
        [_slider setValue:((GPUImageSharpenFilter *)filter).sharpness];
    } else if ([filter isKindOfClass:[GPUImageExposureFilter class]]) {
        [_slider setMinimumValue:-10.0];
        [_slider setMaximumValue:10.0];
        _slider.hidden = false;
        [_slider setValue:((GPUImageExposureFilter *)filter).exposure];
    } else if ([filter isKindOfClass:[GPUImageUnsharpMaskFilter class]]) {
        [_slider setMinimumValue:0];
        [_slider setMaximumValue:4.0];
        _slider.hidden = false;
        [_slider setValue:((GPUImageUnsharpMaskFilter *)filter).intensity];
    } else if ([filter isKindOfClass:[GPUImageGammaFilter class]]) {
        [_slider setMinimumValue:0];
        [_slider setMaximumValue:3];
        _slider.hidden = false;
        [_slider setValue:((GPUImageGammaFilter *)filter).gamma];
    } else if ([filter isKindOfClass:[GPUImageHighlightShadowFilter class]]) {
        [_slider setMinimumValue:0];
        [_slider setMaximumValue:1];
        _slider.hidden = false;
        [_slider setValue:((GPUImageHighlightShadowFilter *)filter).highlights];
    } else if ([filter isKindOfClass:[GPUImageHazeFilter class]]) {
        [_slider setMinimumValue:-0.3];
        [_slider setMaximumValue:0.3];
        _slider.hidden = false;
        [_slider setValue:((GPUImageHazeFilter *)filter).distance];
    } else if ([filter isKindOfClass:[GPUImageHistogramFilter class]]) {
        [_slider setMinimumValue:4.0];
        [_slider setMaximumValue:32.0];
        _slider.hidden = false;
        [_slider setValue:((GPUImageHistogramFilter *)filter).downsamplingFactor];
    } else if ([filter isKindOfClass:[GPUImageWhiteBalanceFilter class]]) {
        _slider.hidden = false;
        [_slider setMinimumValue:2500.0];
        [_slider setMaximumValue:7500.0];
        [_slider setValue:((GPUImageWhiteBalanceFilter *)filter).temperature];
    } else if ([filter isKindOfClass:[GPUImageHalftoneFilter class]]) {
        _slider.hidden = false;
        [_slider setValue:0.01];
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:0.05];
    } else if ([filter isKindOfClass:[GPUImageTrillColorOffsetFilter class]]) {
        _slider.hidden = false;
        [_slider setValue:0.1];
        [_slider setMinimumValue:0.0];
        [_slider setMaximumValue:0.1];
    }
}

- (void)slider:(UISlider *)slider {
    NSDictionary *dic = self.dataSource[_selectedIndexPath.row];
    GPUImageFilter *filter = dic[filterKey];
    if ([filter isKindOfClass:[GPUImageSaturationFilter class]]) {
        ((GPUImageSaturationFilter *)filter).saturation = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageTiltShiftFilter class]]) {
        CGFloat midpoint = [(UISlider *)_slider value];
        [(GPUImageTiltShiftFilter *)filter setTopFocusLevel:midpoint - 0.1];
        [(GPUImageTiltShiftFilter *)filter setBottomFocusLevel:midpoint + 0.1];
        
    } else if ([filter isKindOfClass:[GPUImageContrastFilter class]]) {
        ((GPUImageContrastFilter *)filter).contrast = slider.value;
    } else if ([filter isKindOfClass:[GPUImageBrightnessFilter class]]) {
        ((GPUImageBrightnessFilter *)filter).brightness = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageLevelsFilter class]]) {
        float value = [slider value];
        [(GPUImageLevelsFilter *)filter setRedMin:value gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
        [(GPUImageLevelsFilter *)filter setGreenMin:value gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
        [(GPUImageLevelsFilter *)filter setBlueMin:value gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
        
    } else if ([filter isKindOfClass:[GPUImageRGBFilter class]]) {
        ((GPUImageRGBFilter *)filter).green = slider.value;
    } else if ([filter isKindOfClass:[GPUImageColorInvertFilter class]]) {
        _slider.hidden = true;
    } else if ([filter isKindOfClass:[GPUImageSepiaFilter class]]) {
        ((GPUImageSepiaFilter *)filter).intensity = _slider.value;
    } else if ([filter isKindOfClass:[GPUImageGrayscaleFilter class]]) {
        _slider.hidden = true;
    } else if ([filter isKindOfClass:[GPUImageMonochromeFilter class]]) {
        ((GPUImageMonochromeFilter *)filter).intensity = slider.value;
    } else if ([filter isKindOfClass:[GPUImageOpacityFilter class]]) {
        ((GPUImageOpacityFilter *)filter).opacity = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImagePixellateFilter class]]) {
        ((GPUImagePixellateFilter *)filter).fractionalWidthOfAPixel = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImagePolarPixellateFilter class]]) {
        [(GPUImagePolarPixellateFilter *)filter setPixelSize:CGSizeMake([(UISlider *)_slider value], [(UISlider *)_slider value])];
      
    } else if ([filter isKindOfClass:[GPUImagePolkaDotFilter class]]) {
        ((GPUImagePolkaDotFilter *)filter).dotScaling = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageHalftoneFilter class]]) {
        ((GPUImageHalftoneFilter *)filter).fractionalWidthOfAPixel = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageCrosshatchFilter class]]) {
        ((GPUImageCrosshatchFilter *)filter).crossHatchSpacing = _slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageSobelEdgeDetectionFilter class]]) {
        ((GPUImageSobelEdgeDetectionFilter *)filter).edgeStrength = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImagePrewittEdgeDetectionFilter class]]) {
        ((GPUImagePrewittEdgeDetectionFilter *)filter).edgeStrength = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageCannyEdgeDetectionFilter class]]) {
        ((GPUImageCannyEdgeDetectionFilter *)filter).blurRadiusInPixels = _slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageThresholdEdgeDetectionFilter class]]) {
        ((GPUImageThresholdEdgeDetectionFilter *)filter).threshold = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageXYDerivativeFilter class]]) {
        ((GPUImageXYDerivativeFilter *)filter).edgeStrength = _slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageHarrisCornerDetectionFilter class]]) {
        ((GPUImageHarrisCornerDetectionFilter *)filter).threshold = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageNobleCornerDetectionFilter class]]) {
        ((GPUImageNobleCornerDetectionFilter *)filter).threshold = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageShiTomasiFeatureDetectionFilter class]]) {
        ((GPUImageShiTomasiFeatureDetectionFilter *)filter).threshold = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageLowPassFilter class]]) {
        ((GPUImageLowPassFilter *)filter).filterStrength = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageHighPassFilter class]]) {
        ((GPUImageHighPassFilter *)filter).filterStrength = slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageSketchFilter class]]) {
        ((GPUImageSketchFilter *)filter).edgeStrength = _slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageThresholdSketchFilter class]]) {
    ((GPUImageThresholdSketchFilter *)filter).threshold = _slider.value;

    } else if ([filter isKindOfClass:[GPUImageSharpenFilter class]]) {
        ((GPUImageSharpenFilter *)filter).sharpness = _slider.value;
       
    } else if ([filter isKindOfClass:[GPUImageExposureFilter class]]) {
       ((GPUImageExposureFilter *)filter).exposure = _slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageUnsharpMaskFilter class]]) {
       ((GPUImageUnsharpMaskFilter *)filter).intensity = _slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageGammaFilter class]]) {
        ((GPUImageGammaFilter *)filter).gamma = _slider.value;
    
    } else if ([filter isKindOfClass:[GPUImageHighlightShadowFilter class]]) {
        ((GPUImageHighlightShadowFilter *)filter).highlights = _slider.value;
      
    } else if ([filter isKindOfClass:[GPUImageHazeFilter class]]) {
        ((GPUImageHazeFilter *)filter).distance = _slider.value;
     
    } else if ([filter isKindOfClass:[GPUImageHistogramFilter class]]) {
        ((GPUImageHistogramFilter *)filter).downsamplingFactor = _slider.value;
    
    } else if ([filter isKindOfClass:[GPUImageWhiteBalanceFilter class]]) {
        ((GPUImageWhiteBalanceFilter *)filter).temperature = _slider.value;
        
    } else if ([filter isKindOfClass:[GPUImageTrillColorOffsetFilter class]]) {
        ((GPUImageTrillColorOffsetFilter *)filter).enlargeWeight = _slider.value;
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
