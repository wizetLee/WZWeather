//
//  PCAdjustiveGIFSpeedView.m
//  WZGIF
//
//  Created by admin on 21/7/17.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "PCAdjustiveGIFSpeedView.h"

@interface PCAdjustiveGIFSpeedView()

@property (nonatomic, strong) UIButton *styleButton;//切换GIF的播放方向
@property (nonatomic, strong) UIView *speedControlView;//速度控制
@property (nonatomic, strong) UIView *speedSilderContainer;//速度杆位置容器
@property (nonatomic, strong) CALayer *speedSilderBgLayer;//速度杆背景
@property (nonatomic, strong) CALayer *speedSilderLayer;//速度杆
@property (nonatomic, strong) UIView *speedControl;//速度杆控制器

@end

@implementation PCAdjustiveGIFSpeedView

#pragma mark - Initialize
- (instancetype)init {
    if (self = [super init]) {
        [self createViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

#pragma mark - Create Views
- (void)createViews {
    self.backgroundColor = [UIColor greenColor];
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
//    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat styleBtnW = 50.0;
    _styleButton = [[UIButton alloc] init];
    _styleButton.frame = CGRectMake(screenW - 15.0 - styleBtnW, ([self viewHeight] - styleBtnW) / 2.0  , styleBtnW, styleBtnW);
    [self addSubview:_styleButton];
    [_styleButton setTitle:@"顺序" forState:UIControlStateNormal];
    [_styleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_styleButton setBackgroundColor:[UIColor yellowColor]];
    [_styleButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _speedControlView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenW - styleBtnW - 15.0 * 2.0, [self viewHeight])];
    [_speedControlView setBackgroundColor:[UIColor redColor]];
    [self addSubview:_speedControlView];
    
    CGFloat containerWH = 44.0;
    _speedSilderContainer = [[UIView alloc] initWithFrame:CGRectMake(containerWH / 2.0, 0.0, _speedControlView.bounds.size.width - containerWH, 10.0)];
    [_speedControlView addSubview:_speedSilderContainer];
    [_speedSilderContainer setCenter:_speedControlView.center];
    
    _speedSilderBgLayer = [CALayer layer];
    _speedSilderLayer = [CALayer layer];
    _speedSilderBgLayer.frame = _speedSilderContainer.bounds;
    _speedSilderLayer.frame = CGRectMake(0.0, 0.0, 0.0, _speedSilderContainer.bounds.size.height);
    _speedSilderBgLayer.backgroundColor = [UIColor grayColor].CGColor;
    _speedSilderLayer.backgroundColor = [UIColor magentaColor].CGColor;
    [_speedSilderContainer.layer addSublayer:_speedSilderBgLayer];
    [_speedSilderContainer.layer addSublayer:_speedSilderLayer];
    
    CGFloat controlHW = containerWH;
    _speedControl = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([self viewHeight] - controlHW) / 2.0, controlHW, controlHW)];
    _speedControl.layer.cornerRadius = controlHW / 2.0;
    [_speedControlView addSubview:_speedControl];
    [_speedControl.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_speedControl addGestureRecognizer:pan];
    [self currentSpeedRate:0.5];
}

- (void)clickedBtn:(UIButton *)sender {
    switch (_tarckDirection) {
        case PCGIFTrackDirectionForward://顺序
        {
            _tarckDirection = PCGIFTrackDirectionBackward;
            [_styleButton setTitle:@"倒序" forState:UIControlStateNormal];
        }
            break;
            
        case PCGIFTrackDirectionBackward://倒序
        {
            _tarckDirection = PCGIFTrackDirectionRound;
            [_styleButton setTitle:@"往返" forState:UIControlStateNormal];
            
        }
            break;
            
        case PCGIFTrackDirectionRound://往返
        {
            _tarckDirection = PCGIFTrackDirectionForward;
            [_styleButton setTitle:@"顺序" forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    if ([_delegate respondsToSelector:@selector(currentTrackDirection:)]) {
        [_delegate currentTrackDirection:_tarckDirection];
    }
}

- (void)currentSpeedRate:(CGFloat)speedRate {
    if (speedRate > 1.0) {
        speedRate = 1.0;
    }
    
    if (speedRate < 0) {
        speedRate = 0.0;
    }
    
    [CATransaction begin];//事务
    [CATransaction setDisableActions:true];
    _speedSilderLayer.frame = CGRectMake(0.0, 0.0, speedRate * _speedSilderContainer.bounds.size.width, _speedSilderLayer.bounds.size.height);
    [CATransaction commit];
    _speedControl.center = CGPointMake(_speedSilderContainer.frame.origin.x + speedRate * _speedSilderContainer.bounds.size.width, _speedControl.center.y);
}

//平移手势
- (void)pan:(UIPanGestureRecognizer *)gesture {
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if ([_delegate respondsToSelector:@selector(beginSetSpeedRate)]) {
                [_delegate beginSetSpeedRate];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if ([_delegate respondsToSelector:@selector(commitSetSpeedRate)]) {
                [_delegate commitSetSpeedRate];
            }
        }
            break;
        default:
            break;
    }
    
    CGPoint currentPoint = [gesture locationInView:_speedControlView];
    CGFloat minX = _speedSilderContainer.frame.origin.x;
    CGFloat maxX = CGRectGetMaxX(_speedSilderContainer.frame);
    CGFloat rate = 0.0;
    if (minX > currentPoint.x) {
        
    } else if (maxX < currentPoint.x) {
        rate = 1.0;
    } else {
        rate = (currentPoint.x - minX) / (maxX - minX);
    }
    
    [self currentSpeedRate:rate];
    if ([_delegate respondsToSelector:@selector(currentSpeedRate:)]) {
        [_delegate currentSpeedRate:rate];
     
    }
}

- (CGFloat)viewHeight {
    return 70.0;
}

@end
