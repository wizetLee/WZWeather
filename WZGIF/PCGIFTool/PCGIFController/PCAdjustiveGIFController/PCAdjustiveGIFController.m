//
//  PCAdjustiveGIFController.m
//  WZGIF
//
//  Created by admin on 21/7/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "PCAdjustiveGIFController.h"
#import "PCAdjustiveGIFSpeedView.h"

/**
 * 调节GIF播放顺序的方案:计时器控制间隔以及切换图片
 */
@interface PCAdjustiveGIFController ()<PCAdjustiveGIFSpeedViewProtocol>

@property (nonatomic, strong) UIImageView *imageView;//展示GIF的容器
@property (nonatomic, strong) UIImage *currentImage;//GIF容器当前展示的图片
@property (nonatomic, strong) PCAdjustiveGIFSpeedView *speedView;//GIF速度 防线 控制杆
@property (nonatomic, strong) CADisplayLink *displayLink;//计时器
@property (nonatomic, assign) NSUInteger index;//遍历图片的角标
@property (nonatomic, assign) BOOL forward;//往返调整

@property (nonatomic, assign) CGFloat frameInteral;//帧间隔
@property (nonatomic, assign) CGFloat standardframeInteral;//标准帧间隔
@property (nonatomic, assign) CGFloat memoryInteral;//记忆帧间隔-viewWillDisapper的时候使用

@end

@implementation PCAdjustiveGIFController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //界面出现 构造计时器
    [self createTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //获取上次保留的帧间隔
    _memoryInteral = self.frameInteral;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //界面消失 销毁计时器
    [self deinitTimer];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

#pragma mark - Private
- (void)createViews {
    UIBarButtonItem *compositionGIFItem = [[UIBarButtonItem alloc] initWithTitle:@"合成GIF" style:UIBarButtonItemStylePlain target:self action:@selector(compositionGIF)];
    self.navigationItem.rightBarButtonItems = @[compositionGIFItem];
    
    _speedView = [[PCAdjustiveGIFSpeedView alloc] init];
    [self.view addSubview:_speedView];
    _speedView.delegate = self;
    _speedView.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - [_speedView viewHeight], [UIScreen mainScreen].bounds.size.width, [_speedView viewHeight]);
   
    _imageView = [[UIImageView alloc] init];
    [self.view addSubview:_imageView];
    _imageView.frame = CGRectMake(0.0, 64.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0 -  [_speedView viewHeight]);
    
}

- (void)createTimer {
    if (_dataArr.count) {
        _index = 0;
        //设置定时器的处罚间隔
        if (_memoryInteral) {
            self.frameInteral = _memoryInteral;
        } else {
            //如果没有间隔默认值
            if (_dataArr[0].interval == 0) {
                _standardframeInteral = 0.5;
            } else {
                _standardframeInteral = _dataArr[0].interval;
            }
            self.frameInteral = _standardframeInteral;
        }
        
        [self.speedView currentSpeedRate:self.frameInteral / _standardframeInteral];
        self.displayLink.paused = false;
    }
}

- (void)deinitTimer {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

//通过UI操纵的枚举（PCGIFTrackDirection）合成GIF
- (NSArray *)imagesAccordingTrackDirection:(PCGIFTrackDirection)trackDirection {
    NSMutableArray *tmpMArr = [NSMutableArray array];
    switch (trackDirection) {
        case PCGIFTrackDirectionForward:
        {
            tmpMArr = [NSMutableArray arrayWithArray:_dataArr];
            for (PCGIFItem *item in tmpMArr) {
                item.interval = self.frameInteral;
            }
        }
            break;
        case PCGIFTrackDirectionBackward:
        {
            [_dataArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PCGIFItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.interval = self.frameInteral;
                [tmpMArr addObject:obj];
            }];
        }
            break;
        case PCGIFTrackDirectionRound:
        {
            tmpMArr = [NSMutableArray arrayWithArray:_dataArr];
            [_dataArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PCGIFItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx != (_dataArr.count - 1)) {
                    PCGIFItem *item = [[PCGIFItem alloc] init];
                    item.targetImage = obj.targetImage;
                    //item.interval = obj.interval;
                    item.interval = self.frameInteral;
                    [tmpMArr addObject:item];
                }
            }];
        }
            break;
            
        default:
            break;
    }
    return tmpMArr;
}

#pragma mark - 合成GIF操作:
- (void)compositionGIF {
    if (_dataArr.count) {
     
        //根据设置方向对数据的顺序进行处理
        NSMutableArray *tmpMArr = [NSMutableArray arrayWithArray:[self imagesAccordingTrackDirection:[self trackDirection]]];
        
        //GIF 路径的匹配
        NSURL *url = nil;
        if (self.gifFilePath) {
            url = [NSURL fileURLWithPath:self.gifFilePath];
        } else {
            NSLog(@"合成失败：创建GIF的保存路径失败");
            return;
        }
    
        NSLog(@"开始合成GIF");
        //GIF的合成 同步
        [PCGIFTool createGIFWithURL:url items:tmpMArr loopCount:0];
        NSLog(@"GIF合成完毕");
        
        //GIF的拆解  同步
//        [PCGIFTool destructGIFWithURL:url handler:^(NSURL *url, NSMutableArray *frames, NSMutableArray *delayTimes, CGFloat totalTime, CGFloat gifWidth, CGFloat gifHeight, NSUInteger loopCount) {
//            NSLog(@"GIF拆解测试：%@, %@, %lf, %lf, %lf, %ld", frames, delayTimes, totalTime, gifWidth, gifHeight, loopCount);
//        }];
        
        //从保存GIF的路径中获取data
        NSData *gifData = [NSData dataWithContentsOfFile:self.gifFilePath];
        if (gifData) {
            /**
             播放合成的gif
            
             （1）FL 第三方的播放模式
                    FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:gifData];
                    _imageView.animatedImage  = image;
             
             （2）SD 普通的image播放//使用了SD的分类
                    _imageView.image = [UIImage sd_animatedGIFWithData:gifData];
             
             （3）系统的image gif播放或者利用计时器切换图片
             */
            
            NSLog(@"合成GIF文件的大小%ld", gifData.length);
        } else {
            NSLog(@"文件不存在");
        }
    }
}


#pragma mark - 计时器事件  切换图片逻辑处理
- (void)dispalyLinkAction:(CADisplayLink *)displayLink {
    @synchronized (self) {
        if (_dataArr.count) {
            @autoreleasepool {
                _currentImage = _dataArr[_index].targetImage;
                _imageView.image = _currentImage;
            }
            
            if ([self trackDirection] == PCGIFTrackDirectionForward) {
                if (_index < _dataArr.count - 1) {
                    _index++;
                } else {
                    _index = 0.0;
                }
            } else if ([self trackDirection] == PCGIFTrackDirectionBackward) {
                if (_index > 0) {
                    _index--;
                } else {
                    _index = _dataArr.count - 1;
                }
            } else if ([self trackDirection] == PCGIFTrackDirectionRound) {
                if (_forward) {
                    if (_index < _dataArr.count - 1) {
                        _index++;
                    } else {
                        _forward = false;
                        _index--;
                    }
                } else {
                    if (_index > 0) {
                        _index--;
                    } else {
                        _forward = true;
                        _index++;
                    }
                }
            }
        }
        
    }
}

#pragma mark - PCAdjustiveGIFSpeedViewProtocol
//开始调整速率
- (void)beginSetSpeedRate {
    if (_dataArr.count) {
        _displayLink.paused = true;
    }
}
//完成调整速率
- (void)commitSetSpeedRate {
    if (_dataArr.count) {
        _displayLink.paused = false;
    }
}
//速率控制回调
- (void)currentSpeedRate:(CGFloat)speedRate {
#warning FrameInteral can not be zero 不可能为零 需要根据需求调整
    self.frameInteral = _standardframeInteral * speedRate;
}

//改变方向的回调
- (void)currentTrackDirection:(PCGIFTrackDirection)trackDirection {
    if (_dataArr.count) {
        if (trackDirection == PCGIFTrackDirectionForward) {
    
        } else if (trackDirection == PCGIFTrackDirectionForward) {
         
        } else if (trackDirection == PCGIFTrackDirectionRound) {
            _forward = true;
        }
    }
}


#pragma mark - Accessor
- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(dispalyLinkAction:)];
        _displayLink.paused = true;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (void)setFrameInteral:(CGFloat)frameInteral {
    _frameInteral = frameInteral;
    self.displayLink.frameInterval = 60.0 * _frameInteral;
}

- (PCGIFTrackDirection)trackDirection {
    return _speedView.tarckDirection;
}

- (NSString *)gifFilePath {
    if (!_gifFilePath) {
        NSString *gifFileName = @"wizetGIFFile";
        NSString *gifFilePath = [PCGIFTool gifSavePathWithName:gifFileName];//保存路径和文件名,外部取的文件名
        if (!gifFilePath) {
            NSLog(@"文件path创建失败");
        } else {
            _gifFilePath = gifFilePath;
        }
    }
     return _gifFilePath;
}

@end
