//
//  WZAnimatePageControl.m
//  WZWeather
//
//  Created by wizet on 9/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZAnimatePageControl.h"
#import "WZAnimatePageControlThrobItem.h"

@interface WZAnimatePageControl()
{
    NSInteger count;
    CGFloat innerGap;
    CGFloat lrGap;
    CGSize itemSize;
    CGSize handleViewSize;
    CGFloat itemOrigionY;
    
    BOOL plusSeparation;
    CGFloat animationTargetX;
    NSInteger animtionCounter;
    CGFloat positionSeparation;
    CGFloat animationTimes;
    CGFloat nonAnimationTimes;
}

@property (nonatomic, strong) NSMutableArray <WZAnimatePageControlThrobItem *>*itemList;
@property (nonatomic, strong) UIView *handleView;
@property (nonatomic, strong) UIPanGestureRecognizer *handlePan;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSArray <NSDictionary <NSString *, NSString *>*> * itemContentList;

@end

@implementation WZAnimatePageControl

#pragma mark - Public
- (instancetype)initWithFrame:(CGRect)frame itemContentList:(NSArray <NSDictionary <NSString *, NSString *>*> *) itemContentList itemSize:(CGSize)tmpItemSize
{
    NSAssert(itemContentList, @"无数据");
    _itemContentList = itemContentList;
    count = itemContentList.count;
    handleViewSize = itemSize = tmpItemSize;
    self = [super initWithFrame:frame];
    if (self) {}
    return self;
}

- (void)selectedInIndex:(NSInteger)index withAnimation:(BOOL)boolean {
    animationTimes = boolean?15.0:nonAnimationTimes;//设定：boolean 为false 时动画时间为1/60，人眼几乎观察不到动画
    [self locationHandleViewWithCenterX:[self calculateOrigionXWithIndex:index]];
}

#pragma mark - Private
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self creatViews];
}

- (void)dealloc {
    [_displayLink invalidate];
}

- (void)creatViews {
    animationTimes = 15; // 0.25 * 60
    nonAnimationTimes = 1;
    itemOrigionY = 5.0;
    [_displayLink invalidate];
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLink:)];
    _displayLink.paused = true;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    _itemList = NSMutableArray.array;
    
    lrGap                   = 10.0;
    innerGap                = ((self.frame.size.width - count * itemSize.width) - lrGap * 2) / (count - 1);
    if (innerGap <0) {
        innerGap = 0;
        NSAssert(0, @"需要注意的地方");
    }
    
    for (NSInteger i = 0; i < count; i++) {
        WZAnimatePageControlThrobItem *item = WZAnimatePageControlThrobItem.alloc.init;
        [self addSubview:item];
        item.frame = CGRectMake(lrGap + i * itemSize.width + i * innerGap, itemOrigionY, itemSize.width, itemSize.height);
        [_itemList addObject:item];
        
        NSDictionary <NSString *, NSString *>* dic = _itemContentList[i];
        
        //item
        item.imageView.image = [UIImage imageNamed:dic[@"image"]];
        item.headlineLable.text = dic[@"headline"];
        item.imageView.backgroundColor = UIColor.redColor;
    }
    
    _handleView = UIView.alloc.init;
    [self addSubview:_handleView];
    _handleView.frame = CGRectMake(0.0, itemOrigionY, handleViewSize.width, handleViewSize.height);
    _handleView.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
    
    
    _handlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_handleView addGestureRecognizer:_handlePan];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:_tap];
    
    //默认滑动到第0个点
    [self selectedInIndex:0 withAnimation:false];
}

#pragma mark - Gesture Logic Calculated
- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self];
    CGFloat x = pan.view.center.x + translation.x;
    x = [self calculateTraceXRestrict:x];
    pan.view.center = CGPointMake(x, pan.view.center.y);
    [pan setTranslation:CGPointZero inView:self];
    
    [self calculateItemScale];
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self locationHandleViewWithCenterX:x];
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    @synchronized(self) {
        [self locationHandleViewWithCenterX:[self calculateTraceXRestrict:[tap locationInView:self].x]];
    }
}

- (void)locationHandleViewWithCenterX:(CGFloat)origionX {
    _displayLink.paused = true;
    {
        animtionCounter = 0;
        __block CGFloat x = origionX;
        [self calculateLeastWithTargetX:x result:^(NSInteger index, CGFloat leastValue) {
            x = _itemList[index].center.x;
        }];
        animationTargetX = x;
        plusSeparation = (self.handleView.center.x - x) >= 0? 0: 1;
        positionSeparation = fabs(self.handleView.center.x - x) / animationTimes;
    }
    _displayLink.paused = false;
}

- (void)displayLink:(CADisplayLink *)link {
    @synchronized(self) {
        animtionCounter++;
        if (animtionCounter >= animationTimes) {
            if ([_delegate respondsToSelector:@selector(pageControl:didSelectInIndex:)]) {
                [_delegate pageControl:self didSelectInIndex: [self calculateIndexWithCenterX:animationTargetX]];
            }
            link.paused = true;
            animationTimes = 15.0;//此举为处理带动画接口（恢复动画时间）
        }
        if (plusSeparation) {
            _handleView.center = CGPointMake(_handleView.center.x + positionSeparation, _handleView.center.y);
        } else {
            _handleView.center = CGPointMake(_handleView.center.x - positionSeparation, _handleView.center.y);
        }
        [self calculateItemScale];
    }
}

//计算靠最近的点
- (void)calculateLeastWithTargetX:(CGFloat)value result:(void (^)(NSInteger index, CGFloat leastValue))result {
    NSInteger tragetIndex = 0;
    CGFloat leastValue = -1;
    for (NSInteger i = 0; i < _itemList.count; i++) {
        WZAnimatePageControlThrobItem *item = _itemList[i];
        CGFloat distance = fabs(item.center.x - value);
        if (leastValue < 0 ||
            leastValue > distance) {//距离相等的情况：取上一个点
            leastValue = distance;
            tragetIndex = i;
        }
    }
    if (result) {
        result(tragetIndex , leastValue);
    }
}

//动画部分
- (void)calculateItemScale {
    CGFloat denominator = innerGap + itemSize.width;
    CGFloat curX =  _handleView.center.x;
    
    for (NSInteger i = 0; i < _itemList.count; i++) {
        WZAnimatePageControlThrobItem *item = _itemList[i];
        CGFloat numerator = fabs(curX - item.center.x);
        [item setScale:numerator / denominator];
    }
}

- (CGFloat)calculateTraceXRestrict:(CGFloat)curX {
    if (curX < _itemList.firstObject.center.x) {
        curX = _itemList.firstObject.center.x;
    }
    
    if (curX > _itemList.lastObject.center.x) {
        curX = _itemList.lastObject.center.x;
    }
    return curX;
}

///index ————> centerX
///ocenterX ————> index

- (NSUInteger)calculateIndexWithCenterX:(CGFloat)centerX {
    NSUInteger index = 0;
    CGFloat length = 0;
    for (NSUInteger i = 0; i < count; i++) {
        length = lrGap + itemSize.width / 2.0 + (i) * itemSize.width + (i) * innerGap ;
        if (centerX - length  < 3.0) {//容错配置
            index = i;
            break;
        }
    }
    
    return index;
}

- (CGFloat)calculateOrigionXWithIndex:(NSInteger)index {
    if (index < 0) {
        index = 0;
    } else if (index >= count) {
        index = count - 1;
    }
    CGFloat targetCenterX = lrGap + index * itemSize.width + index * innerGap;
    return targetCenterX;
}

@end

