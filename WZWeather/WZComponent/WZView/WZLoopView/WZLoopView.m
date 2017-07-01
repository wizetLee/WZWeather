//
//  WZLoopView.m
//  WZWeather
//
//  Created by admin on 17/6/23.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZLoopView.h"

#define FLOAT_PAGE_HEIGHT 20

@implementation WZLoopViewItem



@end


@interface WZLoopView()<UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *currentImages;//当前显示的图片 位置-1  以及位置+1   共承载3张图片
@property (nonatomic, assign) int currentPage;              //当前页数
@property (nonatomic, strong) UIPageControl *pageControl;   //页数标记
@property (nonatomic, strong) UIScrollView *scrollView;     //负责轮播功能

@end

@implementation WZLoopView

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images loop:(BOOL)loop delay:(NSTimeInterval)timeInterval {
    if (self = [super initWithFrame:frame]) {
        _loop = loop;
        _timeInterval = timeInterval;
        _images = images;
        _currentPage = 0;
        
        [self createViews];
        
        if (_timeInterval <= 0) {
            _timeInterval = 2.0;
        }
        
        if (_loop) {
            [self performSelector:@selector(nextPage) withObject:nil afterDelay:_timeInterval];
        }
    }
    return self;
}

#pragma mark
- (void)createViews {
    [self addScrollView];
    [self addPageControl];
}

- (void)addScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    //创建重用轮播imageView
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * width, 0, width, height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = [UIImage imageNamed:self.currentImages[i]];
        [scrollView addSubview:imageView];
    }
    
    scrollView.contentSize = CGSizeMake(3.0 * width, height);   //大小为3个窗口
    scrollView.contentOffset = CGPointMake(width, 0);           //滑动至中间位置
    scrollView.scrollsToTop = false;
    scrollView.pagingEnabled = true;
    scrollView.showsHorizontalScrollIndicator = false;
    scrollView.showsVerticalScrollIndicator = false;
    scrollView.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [scrollView addGestureRecognizer:tap];
    
    [self addSubview:scrollView];
    _scrollView = scrollView;
}

- (void)addPageControl {
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, height-FLOAT_PAGE_HEIGHT, width, FLOAT_PAGE_HEIGHT)];
    bgView.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.2];
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, width, FLOAT_PAGE_HEIGHT)];
    pageControl.numberOfPages = self.images.count;
    pageControl.currentPage = 0;
    pageControl.userInteractionEnabled = false;
    _pageControl = pageControl;
    [bgView addSubview:self.pageControl];
    [self addSubview:bgView];
}


- (void)nextPage {
    if (_loop) {
        if ([NSRunLoop currentRunLoop] == [NSRunLoop mainRunLoop]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextPage) object:nil];
            [self.scrollView setContentOffset:CGPointMake(self.frame.size.width * 2, 0) animated:true];
        }
    }
}

- (NSMutableArray *)currentImages {
    if (!_currentImages) {
        _currentImages = [[NSMutableArray alloc] init];
    }
    [_currentImages removeAllObjects];
    
    //获取当前位置以及相邻视图显示的图片
    NSInteger count = self.images.count;
    int i = (int)(_currentPage + count - 1)%count;
    [_currentImages addObject:self.images[i]];
    [_currentImages addObject:self.images[_currentPage]];
    i = (int)(_currentPage + 1)%count;
    [_currentImages addObject:self.images[i]];
    
    return _currentImages;
}

- (void)refreshImages {
    if (self.scrollView) {
        NSArray *subViews = self.scrollView.subviews;
        for (int i = 0; i < subViews.count; i++) {
            UIImageView *imageView = (UIImageView *)subViews[i];
            imageView.clipsToBounds = true;
            if ([imageView isKindOfClass:[UIImageView class]]) {
                imageView.image = [UIImage imageNamed:self.currentImages[i]];
            }
        }
        //返回self.frame.size.width 的位置
        [self.scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
    }
}

//单击事件回调数据、角标
- (void)tap:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(loopViewDidSelectedImage:index:)]) {
        [self.delegate loopViewDidSelectedImage:self index:_currentPage];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat OffsetX = scrollView.contentOffset.x;
    CGFloat width = self.frame.size.width;
  
    if (_loop && (OffsetX - self.frame.size.width) < 0.0001) {
        [self performSelector:@selector(nextPage) withObject:nil afterDelay:_timeInterval];
    }
    
    if (OffsetX >= 2 * width) {
        _currentPage = (++_currentPage) % self.images.count;
        [self updateStatus];
    }
    
    if (OffsetX <= 0) {
        _currentPage = (int)(_currentPage + self.images.count - 1)%self.images.count;
        [self updateStatus];
    }
}

//手势滑动的时候取消切换下一页事件
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextPage) object:nil];
}

- (void)updateStatus {
    self.pageControl.currentPage = _currentPage;
    [self refreshImages];
    if (_loop) {
        [self performSelector:@selector(nextPage) withObject:nil afterDelay:_timeInterval];
    }
}

#pragma mark Accessor
- (void)setLoop:(BOOL)loop {
    _loop = loop;
    if (_loop) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextPage) object:nil];
        [self performSelector:@selector(nextPage) withObject:nil afterDelay:_timeInterval];
    }
}

@end
