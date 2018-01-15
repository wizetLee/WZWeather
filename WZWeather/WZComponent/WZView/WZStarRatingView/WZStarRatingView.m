//
//  WZStarRatingView.m
//  WZStarRating
//
//  Created by wizet on 16/10/31.
//  Copyright © 2016年 wizet. All rights reserved.
//

#import "WZStarRatingView.h"

@interface WZStarRatingView()

@property (nonatomic, assign) CGSize starSize;
@property (nonatomic, assign) CGFloat spacing;

@property (nonatomic, assign) NSUInteger starCount;
@property (nonatomic, assign) CGFloat totalRange;
@property (nonatomic, assign) CGFloat currentRange;

@property (nonatomic, assign) double totalValue;

@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, strong) UIView *camouflageView;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) NSMutableArray<NSValue *> *frameMArr;

@property (nonatomic, strong) NSMutableArray *starArr;
@property (nonatomic, strong) NSMutableArray *darkStarArr;

@end

@implementation WZStarRatingView
@synthesize currentValue = _currentValue;

/**
 *  星型评分
 *
 *  starSize        星星大小（位置自动计算居中）
 *  spacing         星星间的间距
 *  starCount       星的数量
 *  totalRange      评分计算总范围
 *  currentRange    当前评分的范围（选中范围）
 *  currentValue    当前评分值
 *  totalValue      评分总值
 *  minValue        设置最小分值  默认为0
 *  maskView        遮罩view
 *  camouflageView  顶层的view(名字取好点.)
 *  pan,tap         self的手势
 *  frameMarr       所有星的frame
 *  约束点：仅能横排放置星星  星星默认居中  frame须事先计算好
 */


#pragma mark - Public
- (instancetype)initWithFrame:(CGRect)frame
                    starCount:(NSUInteger)starCount
                     starSize:(CGSize)starSize
                      spacing:(CGFloat)spacing
                   totalValue:(NSUInteger)totalValue
                         type:(WZStarRatingViewType)type{
    
    self = [super initWithFrame:frame];
    if (self) {
        _starSize= starSize;
        _starCount = starCount;
        _totalValue = totalValue;
        _spacing = spacing;
        _type = type;
        _totalValue = totalValue;
        [self setupSubviews];
    }
    return self;
}

- (void)vitalizeStarImage:(UIImage *)image {
    if ([image isKindOfClass:[UIImage class]]) {
        if (self.starArr.count > 0) {
            for (id obj in self.starArr) {
                if ([obj isKindOfClass:[UIImageView class]]) {
                    UIImageView *tmpImageView = (UIImageView *)obj;
                    tmpImageView.image = image;
                }
            }
        }
    }
}

- (void)vitalizeDarkStarImage:(UIImage *)image {
    if ([image isKindOfClass:[UIImage class]]) {
        if (self.darkStarArr.count > 0) {
            for (id obj in self.darkStarArr) {
                if ([obj isKindOfClass:[UIImageView class]]) {
                    UIImageView *tmpImageView = (UIImageView *)obj;
                    tmpImageView.image = image;
                }
            }
        }
    }
}

#pragma mark - Private
- (void)setupSubviews {
    _camouflageView = [[UIView alloc] initWithFrame:self.bounds];
    _maskLayer = [CALayer layer];
    _maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
    _maskLayer.frame = CGRectMake(0
                                  , 0
                                  , 0/*变量*/
                                  , self.bounds.size.height);
    _camouflageView.layer.mask = _maskLayer;
    
    _totalRange = _starSize.width * _starCount;
    
    CGFloat starOriginX = (self.bounds.size.width - (_starSize.width * _starCount + (_starCount - 1) * _spacing)) / 2.0;
    CGFloat starY = self.bounds.size.height / 2.0 - _starSize.height / 2.0;
    
    for (int i = 0; i < _starCount; i++) {
        CGRect starFrame = CGRectMake(starOriginX + (_starSize.width + _spacing) * i
                                      , starY
                                      , _starSize.width
                                      , _starSize.height);
        [self.frameMArr addObject:[NSValue valueWithCGRect:starFrame]];
        
        UIImageView *camouflageViewSubview = [[UIImageView alloc] initWithFrame:starFrame];
        UIImageView *selfSubview = [[UIImageView alloc] initWithFrame:starFrame];
        
        camouflageViewSubview.image = [UIImage imageNamed:@"bigStar"];
        selfSubview.image = [UIImage imageNamed:@"bigDarkStar"];
        
        [_camouflageView addSubview:camouflageViewSubview];
        [self addSubview:selfSubview];
        [self.darkStarArr addObject:selfSubview];
        [self.starArr addObject:camouflageViewSubview];
    }
    
    [self addSubview:_camouflageView];//放在最前位置
}

- (void)innerStarWithFrame:(CGRect)frame index:(int)i{
    switch (_type) {
        case WZStarRatingViewTypeWholeStar:
        {
            _maskLayer.frame = CGRectMake(0
                                          , 0
                                          , frame.origin.x + CGRectGetWidth(frame)
                                          , self.bounds.size.height);
            
            _currentRange = (NSUInteger)(frame.size.width * (i + 1));
        }
            break;
        case WZStarRatingViewTypeHalfStar:
        {
            if ((CGRectGetWidth(_maskLayer.frame) - frame.origin.x) > CGRectGetWidth(frame) / 2.0) {
                _maskLayer.frame = CGRectMake(0
                                              , 0
                                              , frame.origin.x + CGRectGetWidth(frame)
                                              , self.bounds.size.height);
                _currentRange = (NSUInteger)(frame.size.width * (i + 1));
            } else {
                _maskLayer.frame = CGRectMake(0
                                              , 0
                                              , frame.origin.x + CGRectGetWidth(frame) / 2.0
                                              , self.bounds.size.height);
                _currentRange = (NSUInteger)(frame.size.width * (i + 0.5));
            }
        }
            break;
        default:
        {
            _currentRange = (NSUInteger)(CGRectGetWidth(frame) * i + (CGRectGetWidth(_maskLayer.frame) - frame.origin.x));
        }
            break;
    }
}

- (void)gesture:(UIGestureRecognizer *)gesture {
    
    [CATransaction begin];// 去除隐式动画
    [CATransaction setDisableActions:YES];
    
    CGPoint point = [gesture locationInView:self];
    _maskLayer.frame = CGRectMake(0
                                 , 0
                                 , point.x
                                 , self.bounds.size.height);
 
    //利用位置计算值
    for (int i = 0; i < self.frameMArr.count; i++) {
        NSValue *frameValue = self.frameMArr[i];
        CGRect frame = frameValue.CGRectValue;
       
        if (CGRectGetMinX(frame) < point.x && point.x < CGRectGetMaxX(frame)) {
            // star inner
            [self innerStarWithFrame:frame index:i];
        } else if (CGRectGetMaxX(frame) < point.x && point.x < CGRectGetMaxX(frame) + _spacing && frameValue != self.frameMArr.lastObject) {
            // star - spacing - star
             _currentRange = frame.size.width * (i + 1) ;
        } else if (point.x < self.frameMArr.firstObject.CGRectValue.origin.x) {
            // star left
            _currentRange = 0;
        } else if (point.x > CGRectGetMaxX(self.frameMArr.lastObject.CGRectValue)) {
            // star right
            _currentRange = _totalRange;
        }
        
        _percentageValue = _currentRange / _totalRange * 1.0;
        
        if (_minValue != 0.0 && _minValue >= self.currentValue) {
            self.percentageValue = _minValue / (_totalValue * 1.0);
        }
        
        if (self.starRatingCurrentValueBlock) {
            self.starRatingCurrentValueBlock(_percentageValue * _totalValue);
        }
    }
    
    [CATransaction commit];
}

- (UITapGestureRecognizer *)tap {
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
    }
    return _tap;
}

- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
    }
    return _pan;
}


#pragma mark setter & getter

- (NSMutableArray *)starArr {
    if (!_starArr) {
        _starArr = [NSMutableArray array];
    }
    return _starArr;
}

- (NSMutableArray *)darkStarArr {
    if (!_darkStarArr) {
        _darkStarArr = [NSMutableArray array];
    }
    return _darkStarArr;
}

//利用值计算位置 这里写得不够好
- (void)setPercentageValue:(double)percentageValue {
    if (percentageValue > 1.0) {
        _percentageValue = 1.0;
    } else {
        _percentageValue = percentageValue;
    }
    
    if (self.frameMArr.count > 0) {
        NSUInteger index = ((round(_percentageValue * 10000) / 10000) * 10) / (self.frameMArr.firstObject.CGRectValue.size.width / _totalRange * 10);
        CGFloat maskViewWidth = 0.0;
        switch (_type) {
            case WZStarRatingViewTypeWholeStar:
            {
                if (((NSUInteger)((round(_percentageValue * 10000) / 10000) * _totalRange * 10) % (NSUInteger)((self.frameMArr.firstObject.CGRectValue.size.width / _totalRange) * _totalRange * 10)) == 0) {/*point  取模使得精确度有所下降*/
                } else {
                    index += 1;
                }
                maskViewWidth = self.frameMArr.firstObject.CGRectValue.origin.x + (index) * _spacing + (index) * self.frameMArr.firstObject.CGRectValue.size.width;
            }
                break;
            case WZStarRatingViewTypeHalfStar:
            {
                NSUInteger halfCount = (round(_percentageValue * 10000) / 10000 * 10) * _totalRange / (self.frameMArr.firstObject.CGRectValue.size.width / 2.0 * 10);
                
                if (_percentageValue == 0) {
                    maskViewWidth = 0;
                }  else {
                    if (((NSUInteger)((round(_percentageValue * 10000) / 10000 ) * _totalRange * 10 )%                                                             (NSUInteger)((self.frameMArr.firstObject.CGRectValue.size.width / 2 / _totalRange) * _totalRange * 10)) == 0) {
                        
                    } else {
                        halfCount += 1;
                    }
                    maskViewWidth = self.frameMArr.firstObject.CGRectValue.origin.x + (halfCount / 2) * _spacing + (halfCount ) * (self.frameMArr.firstObject.CGRectValue.size.width / 2.0);
                }
            }
                break;
            default:
            {
               maskViewWidth = self.frameMArr.firstObject.CGRectValue.origin.x + (index) * _spacing + (_percentageValue * _totalRange);
            }
                break;
        }
        
        _maskLayer.frame = CGRectMake(0
                                     , 0
                                     , maskViewWidth/*变量*/
                                     , self.bounds.size.height);
    }
}

//直接设置当前值
- (void)setCurrentValue:(double)currentValue {
    _currentValue = currentValue;
    self.percentageValue = _currentValue / self.totalValue;
}

- (double)currentValue {
    return _percentageValue * _totalValue;
}

- (void)setTouchable:(BOOL)touchable {
    _touchable = touchable;
    if (_touchable) {
        [self addGestureRecognizer:self.pan];
        [self addGestureRecognizer:self.tap];
    } else {
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

- (NSMutableArray *)frameMArr {
    if (!_frameMArr) {
        _frameMArr = [NSMutableArray array];
    }
    return _frameMArr;
}

@end
