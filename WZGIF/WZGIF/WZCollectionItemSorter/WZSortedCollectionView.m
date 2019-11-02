//
//  WZSortedCollectionView.m
//  WZGIF
//
//  Created by admin on 17/7/18.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZSortedCollectionView.h"

//点到点距离结构体
typedef struct PointToPointDistance {
    CGFloat xDistance;
    CGFloat yDistance;
} PointToPointDistance;

typedef NS_ENUM(NSUInteger, WZSortedDirectionStatus) {
    WZSortedDirectionStatusIdle      = 0,//空闲
    WZSortedDirectionStatusTop       = 1,//上
    WZSortedDirectionStatusLeft      = 2,//左
    WZSortedDirectionStatusBottom    = 3,//下
    WZSortedDirectionStatusRight     = 4,//右
};

@interface WZSortedCollectionView()

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;     //手势
@property (nonatomic, strong) UIView *snapshotView;                        //快照
@property (nonatomic, strong) NSIndexPath *moveIndexPath;                  //移动到的IndexPath
@property (nonatomic, assign) PointToPointDistance PTPD;                   //点到点距离
@property (nonatomic, strong) CADisplayLink *displayLink;                  //计时器
@property (nonatomic, assign) CGFloat scrollDistance;                      //偏移方向
@property (nonatomic, assign) WZSortedDirectionStatus directionStatus;     //偏移状态
@property (nonatomic, assign) CGFloat deviant;                             //偏移值

@end


@implementation WZSortedCollectionView

#pragma mark - Initialization
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    //默认值配置
    if (_scrollDistance  < 0.01) {_scrollDistance = 20.0;}
    if (_deviant < 0.01) {_deviant = 5.0;}
    
    //长按手势添加
    [self addGestureRecognizer:self.longPress];
}

- (void)autoFit {
    for (UICollectionViewCell *cell in [self visibleCells]) {
        if (_originalIndexPath == [self indexPathForCell:cell]) {
            //排除自己
        } else {
            //计算需要移动到的那个的IndexPath
            CGFloat spacingX = fabs(_snapshotView.center.x - cell.center.x);
            CGFloat spacingY = fabs(_snapshotView.center.y - cell.center.y);
            if (spacingX <= _snapshotView.bounds.size.width / 2.0f
                && spacingY <= _snapshotView.bounds.size.height / 2.0f) {
                _moveIndexPath = [self indexPathForCell:cell];
                //数据源的替换
                if (_moveIndexPath/*不能移动第一个item*/) {
                    [self moveItemAtIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
                    if (_sortedDelegate && [_sortedDelegate respondsToSelector:@selector(customCollectionView:moveFromIndexPath:toIndexPath:)]) {
                        [_sortedDelegate customCollectionView:self moveFromIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
                    }
                    [self cellForItemAtIndexPath:_originalIndexPath].hidden = false;
                    _originalIndexPath = _moveIndexPath;
                    [self cellForItemAtIndexPath:_originalIndexPath].hidden = true;
                }
                break;
            }
        }
    }
}

#pragma mark - LongPress
- (void)lonePress:(UILongPressGestureRecognizer *)longPress
{
    //是否要区分self.dir
    
//    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;//区分滑动方向
    
//    UICollectionViewFlowLayout
//    layout.scrollDirection
    if ([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
        
        switch (layout.scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal: {
            //水平方向
                [self dealHorizontalWithLongPress:longPress];
            } break;
                
            case UICollectionViewScrollDirectionVertical: {
            //垂直方向
                [self dealVerticalWithLongPress:longPress];
            } break;
                
            default: {} break;
        }
    }
   
}

- (void)dealHorizontalWithLongPress:(UILongPressGestureRecognizer *)longPress {
    CGPoint currentPoint = [longPress locationInView:longPress.view];
    self.directionStatus = WZSortedDirectionStatusIdle;
    switch (_longPress.state) {
            //开始拖拽
        case UIGestureRecognizerStateBegan: {
            {
                //获取选中cell
                NSIndexPath *selectedIndexPath = [self indexPathForItemAtPoint:[_longPress locationInView:self]];
                if (selectedIndexPath) {
                    _originalIndexPath = selectedIndexPath;
                    
                    //记录IndexPath  快照View  所选中的cell中的点位置
                    UICollectionViewCell *cell = (UICollectionViewCell *)[self cellForItemAtIndexPath:selectedIndexPath];
                    cell.hidden = true;
                    
                    _snapshotView = [cell snapshotViewAfterScreenUpdates:false];
                    [self addSubview:_snapshotView];
                    _snapshotView.frame = cell.frame;
                    
                    PointToPointDistance tmpPTPD = {_snapshotView.center.x - currentPoint.x
                        , _snapshotView.center.y - currentPoint.y};
                    _PTPD = tmpPTPD;
                }
            }
        }   break;
            //开始移动
        case UIGestureRecognizerStateChanged: {
            if (_snapshotView && _originalIndexPath) {
                //利用移动点 计算snapshotView的位置
                _snapshotView.center = CGPointMake(currentPoint.x + _PTPD.xDistance, currentPoint.y + _PTPD.yDistance);
                //找出当前点所对应的IndexPath
                [self autoFit];
            }
        }   break;
            //结束移动 数据换算
        case UIGestureRecognizerStateEnded: {
            //位置的恢复
            self.directionStatus = WZSortedDirectionStatusIdle;
            if (_originalIndexPath) {
                [UIView animateWithDuration:0.25 animations:^{
                    _snapshotView.center = [self cellForItemAtIndexPath:_originalIndexPath].center;
                } completion:^(BOOL finished) {
                    [self cellForItemAtIndexPath:_originalIndexPath].hidden = false;
                    [_snapshotView removeFromSuperview];
                    _snapshotView = nil;
                    _originalIndexPath = nil;
                    _moveIndexPath = nil;
                    for (UICollectionViewCell *cell in [self visibleCells]) {
                        cell.hidden = false;
                    }
                    [self reloadData];
                }];
            }
        }   break;
        default:{
        }   break;
    }
    
    //判断当前点的位置 自行滑动 滑动方向:上下左右
    if (_snapshotView) {
        CGPoint centerPoint = CGPointMake(_snapshotView.center.x - self.contentOffset.x
                                          , _snapshotView.center.y - self.contentOffset.y);
        if ([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
            UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
            
            //由scrollDistance 算出的 四个死角不作为滑动点
            if ((centerPoint.x <= _scrollDistance
                 && (centerPoint.y <= _scrollDistance))                                     /*左上角*/
                || ((centerPoint.x >= (self.bounds.size.width - _scrollDistance))
                    && (centerPoint.y <= _scrollDistance))                                  /*右上角*/
                || ((centerPoint.x <= _scrollDistance)
                    && (centerPoint.y >= (self.bounds.size.height - _scrollDistance)))      /*左下角*/
                || ((centerPoint.x >= (self.bounds.size.width - _scrollDistance))
                    && (centerPoint.y >= (self.bounds.size.height - _scrollDistance)))      /*右下角*/
                ) {
                self.directionStatus = WZSortedDirectionStatusIdle;
            } else if (flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
                //垂直方向
                if (centerPoint.y <= _scrollDistance) {
                    //向上滑动
                    self.directionStatus = WZSortedDirectionStatusTop;
                    //使用定时器滑动
                } else if (centerPoint.y >= self.bounds.size.height - _scrollDistance) {
                    //向下滑动
                    self.directionStatus = WZSortedDirectionStatusBottom;
                } else {
                    
                }
            } else {
                //水平方向
#pragma mark - 当前滑动方向为水平方面
                if (centerPoint.x <= _scrollDistance) {
                    //向左滑动
                    self.directionStatus = WZSortedDirectionStatusLeft;
                    //使用定时器滑动
                } else if (centerPoint.x >= self.bounds.size.width - _scrollDistance) {
                    //向右滑动
                    self.directionStatus = WZSortedDirectionStatusRight;
                } else {
                    
                }
            }
        }
    }
}


- (void)dealVerticalWithLongPress:(UILongPressGestureRecognizer *)longPress {
    CGPoint currentPoint = [longPress locationInView:longPress.view];
    self.directionStatus = WZSortedDirectionStatusIdle;
    switch (_longPress.state) {
            //开始拖拽
        case UIGestureRecognizerStateBegan: {
            {
                //获取选中cell
                NSIndexPath *selectedIndexPath = [self indexPathForItemAtPoint:[_longPress locationInView:self]];
                if (selectedIndexPath) {
                    _originalIndexPath = selectedIndexPath;
                    
                    //记录IndexPath  快照View  所选中的cell中的点位置
                    UICollectionViewCell *cell = (UICollectionViewCell *)[self cellForItemAtIndexPath:selectedIndexPath];
                    cell.hidden = true;
                    
                    _snapshotView = [cell snapshotViewAfterScreenUpdates:false];
                    [self addSubview:_snapshotView];
                    _snapshotView.frame = cell.frame;
                    
                    PointToPointDistance tmpPTPD = {_snapshotView.center.x - currentPoint.x
                        , _snapshotView.center.y - currentPoint.y};
                    _PTPD = tmpPTPD;
                }
            }
        }   break;
            //开始移动
        case UIGestureRecognizerStateChanged: {
            if (_snapshotView && _originalIndexPath) {
                //利用移动点 计算snapshotView的位置
                _snapshotView.center = CGPointMake(currentPoint.x + _PTPD.xDistance, currentPoint.y + _PTPD.yDistance);
                //找出当前点所对应的IndexPath
                [self autoFit];
            }
        }   break;
            //结束移动 数据换算
        case UIGestureRecognizerStateEnded: {
            //位置的恢复
            self.directionStatus = WZSortedDirectionStatusIdle;
            if (_originalIndexPath) {
                [UIView animateWithDuration:0.25 animations:^{
                    _snapshotView.center = [self cellForItemAtIndexPath:_originalIndexPath].center;
                } completion:^(BOOL finished) {
                    [self cellForItemAtIndexPath:_originalIndexPath].hidden = false;
                    [_snapshotView removeFromSuperview];
                    _snapshotView = nil;
                    _originalIndexPath = nil;
                    _moveIndexPath = nil;
                    for (UICollectionViewCell *cell in [self visibleCells]) {
                        cell.hidden = false;
                    }
                    [self reloadData];
                }];
            }
        }   break;
        default:{
        }   break;
    }
    
    //判断当前点的位置 自行滑动 滑动方向:上下左右
    if (_snapshotView) {
        CGPoint centerPoint = CGPointMake(_snapshotView.center.x - self.contentOffset.x
                                          , _snapshotView.center.y - self.contentOffset.y);
        if ([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
            UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
            
            //由scrollDistance 算出的 四个死角不作为滑动点
            if ((centerPoint.x <= _scrollDistance
                 && (centerPoint.y <= _scrollDistance))                                     /*左上角*/
                || ((centerPoint.x >= (self.bounds.size.width - _scrollDistance))
                    && (centerPoint.y <= _scrollDistance))                                  /*右上角*/
                || ((centerPoint.x <= _scrollDistance)
                    && (centerPoint.y >= (self.bounds.size.height - _scrollDistance)))      /*左下角*/
                || ((centerPoint.x >= (self.bounds.size.width - _scrollDistance))
                    && (centerPoint.y >= (self.bounds.size.height - _scrollDistance)))      /*右下角*/
                ) {
                self.directionStatus = WZSortedDirectionStatusIdle;
            } else if (flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
                //垂直方向
                if (centerPoint.y <= _scrollDistance) {
                    //向上滑动
                    self.directionStatus = WZSortedDirectionStatusTop;
                    //使用定时器滑动
                } else if (centerPoint.y >= self.bounds.size.height - _scrollDistance) {
                    //向下滑动
                    self.directionStatus = WZSortedDirectionStatusBottom;
                } else {
                    
                }
            } else {
                //水平方向
                if (centerPoint.x <= _scrollDistance) {
                    //向左滑动
                    self.directionStatus = WZSortedDirectionStatusLeft;
                    //使用定时器滑动
                } else if (centerPoint.x >= self.bounds.size.width - _scrollDistance) {
                    //向右滑动
                    self.directionStatus = WZSortedDirectionStatusRight;
                } else {
                    
                }
            }
        }
    }
}

#pragma mark - DisplayLinkAction
- (void)displayLinkAction:(CADisplayLink *)displayLink {
    //根据方向滑动
    if (_snapshotView) {
        switch (_directionStatus) {
            case 0: break;
            case 1:{
                //上
                if ((int)self.contentOffset.y <= 0) {
                    self.contentOffset = CGPointMake(self.contentOffset.x, 0);
                } else {
                    self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y - _deviant);
                    _snapshotView.center = CGPointMake(_snapshotView.center.x, _snapshotView.center.y - _deviant);
                }
            } break;
            case 2:{
                //左
                if ((int)self.contentOffset.x <= 0) {
                    self.contentOffset = CGPointMake(0, self.contentOffset.y);
                } else {
                    self.contentOffset = CGPointMake(self.contentOffset.x - _deviant, self.contentOffset.y);
                    _snapshotView.center = CGPointMake(_snapshotView.center.x - _deviant, _snapshotView.center.y);
                }
            } break;
            case 3:{
                //下
                if ((int)self.contentOffset.y + (int)self.bounds.size.height >= (int)self.contentSize.height) {
                    if (self.contentSize.height < self.bounds.size.height) {
                    } else {
                        self.contentOffset = CGPointMake(self.contentOffset.x
                                                         , self.contentSize.height - self.bounds.size.height);
                    }
                } else {
                    self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y + _deviant);
                    _snapshotView.center = CGPointMake(_snapshotView.center.x, _snapshotView.center.y + _deviant);
                }
            } break;
            case 4:{
                //右
                if ((int)self.contentOffset.x + (int)self.bounds.size.width >= (int)self.contentSize.width) {
                    if (self.contentSize.width < self.bounds.size.width) {
                    } else {
                        self.contentOffset = CGPointMake(self.contentSize.width, self.contentOffset.y - self.bounds.size.width);
                    }
                } else {
                    self.contentOffset = CGPointMake(self.contentOffset.x + _deviant, self.contentOffset.y);
                    _snapshotView.center = CGPointMake(_snapshotView.center.x + _deviant, _snapshotView.center.y);
                }
            } break;
                
            default: break;
        }
        [self autoFit];
    }
}


#pragma mark - Accessor
//长按手势
- (UILongPressGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePress:)];
        [self addGestureRecognizer:_longPress];
        _longPress.minimumPressDuration = 0.3;
    }
    return _longPress;
}

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (void)setDirectionStatus:(WZSortedDirectionStatus)directionStatus {
    _directionStatus = directionStatus;
    if (_directionStatus != WZSortedDirectionStatusIdle) {
        self.displayLink.paused = false;
        return;
    }
    self.displayLink.paused = true;
}

@end
