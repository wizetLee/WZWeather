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
    CGFloat animationTargetX;       //间接计算index的变量
    NSInteger animtionCounter;      //动画次数统计
    CGFloat positionSeparation;     //动画偏移分量
    CGFloat animationTimes;         //动画的频率（定值）
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
    if (boolean) {
        [self locationHandleViewWithTargetX:[self calculateCenterXWithIndex:index]];
    } else {
        animationTargetX = [self calculateCenterXWithIndex:index];
        _handleView.center = CGPointMake(animationTargetX, _handleView.center.y);
        [self calculateItemScale];
        [self didSelectDelegate];
        NSLog(@"current%ld", [self currentIndex]);
    }
}

//当前所在的角标
- (NSUInteger)currentIndex {
    
//    return [self calculateIndexWithCenterX:self.handleView.center.x];//逻辑上应当使用self.handleView.center.x，使用animationTargetX替代self.handleView.center.x是因为self.handleView.center.x在做动画的过程会不断得改变
    return [self calculateIndexWithCenterX:animationTargetX];
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
        [self locationHandleViewWithTargetX:x];
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    @synchronized(self) {
        [self locationHandleViewWithTargetX:[self calculateTraceXRestrict:[tap locationInView:self].x]];
    }
}

//根据给出的X坐标算出动画分量
- (void)locationHandleViewWithTargetX:(CGFloat)origionX {
    _displayLink.paused = true;
    {
        animtionCounter = 0;
        __block CGFloat x = origionX;
        [self calculateLeastWithTargetX:x result:^(NSInteger index, CGFloat leastValue) {
            x = _itemList[index].center.x;//取出相近的item的角标后，获取item的中心水平分量
        }];
        animationTargetX = x;//最终动画需要到达的分量
        plusSeparation = (self.handleView.center.x - x) >= 0? 0: 1;
        positionSeparation = fabs(self.handleView.center.x - x) / animationTimes;
    }
    _displayLink.paused = false;
}

//动画计时器事件
- (void)displayLink:(CADisplayLink *)link {
    @synchronized(self) {
        animtionCounter++;
        if (animtionCounter >= animationTimes) {
            [self didSelectDelegate];
            link.paused = true;
        }
        if (plusSeparation) {
            _handleView.center = CGPointMake(_handleView.center.x + positionSeparation, _handleView.center.y);
        } else {
            _handleView.center = CGPointMake(_handleView.center.x - positionSeparation, _handleView.center.y);
        }
        [self calculateItemScale];
    }
}

- (void)didSelectDelegate {
    if ([_delegate respondsToSelector:@selector(pageControl:didSelectInIndex:)]) {
        [_delegate pageControl:self didSelectInIndex: [self calculateIndexWithCenterX:animationTargetX]];
    }
}


//计算靠得最近的点
- (void)calculateLeastWithTargetX:(CGFloat)value result:(void (^)(NSInteger index, CGFloat leastValue))result {
    NSInteger tragetIndex = 0;
    CGFloat leastValue = -1;//得到最相近的值
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
//滑动块X坐标的过滤
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
///centerX ————> index
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

//根据角标得到item的center.x
- (CGFloat)calculateCenterXWithIndex:(NSInteger)index {
    if (index < 0) {
        index = 0;
    } else if (index >= count) {
        index = count - 1;
    }
    //左边间距+item.w * (index - 1) + item之间的边距 * (index - 1) +  item.w  / 2.0
    CGFloat targetX = lrGap + index * itemSize.width + index * innerGap + itemSize.width / 2.0;
    return targetX;
}

@end

