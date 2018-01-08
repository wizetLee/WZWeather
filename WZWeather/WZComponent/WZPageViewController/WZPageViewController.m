//
//  WZPageViewController.m
//  WZWeather
//
//  Created by wizet on 17/6/16.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZPageViewController.h"
#import "WZPageViewAssistController.h"

@interface WZPageViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, assign) NSInteger numberOfIndexs;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation WZPageViewController

@synthesize reusableVCArray = _reusableVCArray;

#pragma Initialize
- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary<NSString *,id> *)options {
    NSMutableDictionary *configOptions = [NSMutableDictionary dictionaryWithDictionary:options?:@{}];
    //页面间隔设置
    configOptions[UIPageViewControllerOptionInterPageSpacingKey] = @(10);
    if (self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:navigationOrientation options:configOptions]) {
        //自定义模态跳转模式
        //        self.modalPresentationStyle = UIModalPresentationCustom;
        //模态过渡模式
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        /*
         UIModalTransitionStyleCoverVertical：画面从下向上徐徐弹出，关闭时向下隐 藏（默认方式）。
         UIModalTransitionStyleFlipHorizontal：从前一个画面的后方，以水平旋转的方式显示后一画面。
         UIModalTransitionStyleCrossDissolve：前一画面逐渐消失的同时，后一画面逐渐显示。
         */
        //自定义跳转代理
        //        self.transitioningDelegate = self;
   
    }
    return self;
}

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.dataSource = self;
    self.delegate = self;
    
    [self showVCWithIndex:0 animated:false];
    [self createViews];
}

- (void)createViews {
  
}

#pragma mark - Show VC with index
- (void)showVCWithIndex:(NSInteger)index animated:(BOOL)animated {
    if (index <= 0) {index = 0;}
    if (index > _numberOfIndexs) {index = _numberOfIndexs;}
    _currentIndex = index;
    WZPageViewAssistController *VC = [self matchViewControllerWithIndex:index];
    _currentVC = VC;
    __weak typeof(self) weakSelf = self;
    [self setViewControllers:@[VC] direction:UIPageViewControllerNavigationDirectionForward animated:animated completion:^(BOOL finished) {
        //执行代理
        if ([weakSelf.pageViewControllerDelegate respondsToSelector:@selector(pageViewController:showVC:inIndex:)] ) {
            [weakSelf.pageViewControllerDelegate pageViewController:weakSelf showVC:VC inIndex:index];
        }
    }];
}

#pragma mark - Match VC with Index
//匹配控制器
- (WZPageViewAssistController *)matchViewControllerWithIndex:(NSInteger)index {
  
    if (index < 0
        || index > _numberOfIndexs) {
        return nil;
    }
   
    WZPageViewAssistController *VC = self.reusableVCArray[index % self.reusableVCArray.count];
    VC.index = index;
    
    return VC;
}


#pragma mark - UIPageViewControllerDelegate
//将要切换控制器
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers NS_AVAILABLE_IOS(6_0) {
//    WZPageViewAssistController *VC = pageViewController.viewControllers.firstObject;
}

//切换控制器完成
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    WZPageViewAssistController *VC = pageViewController.viewControllers.firstObject;
   
    if (VC && VC != _currentVC) {
        _currentIndex = VC.index;
        if ([_pageViewControllerDelegate respondsToSelector:@selector(pageViewController:showVC:inIndex:)] ) {
            [_pageViewControllerDelegate pageViewController:self showVC:VC inIndex:_currentIndex];
        }
        _currentVC = VC;
    }
}

//- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation __TVOS_PROHIBITED;
//
//- (UIInterfaceOrientationMask)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED;
//- (UIInterfaceOrientation)pageViewControllerPreferredInterfaceOrientationForPresentation:(UIPageViewController *)pageViewController NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED;

#pragma mark - UIPageViewControllerDataSource
//上一个控制器
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(WZPageViewAssistController *)viewController {
    return [self matchViewControllerWithIndex:viewController.index - 1];
}

//下一个控制器
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(WZPageViewAssistController *)viewController {
    return [self matchViewControllerWithIndex:viewController.index + 1];
}

//设置了以下代理会触发底部pageControl
////数目
//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController NS_AVAILABLE_IOS(6_0) {
//    return self.reusableVCArray.count;
//}
//
////起始角标
//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController NS_AVAILABLE_IOS(6_0) {
//    return 0;
//}


#pragma mark - Accessor
//默认为一个VC
- (NSArray <WZPageViewAssistController *>*)reusableVCArray {
    if (!_reusableVCArray) {
        WZPageViewAssistController *VC = [[WZPageViewAssistController alloc] init];
        VC.index = 0;
        _currentIndex = 0;
        _numberOfIndexs = 0;
        _reusableVCArray = @[VC];
    }
    return _reusableVCArray;
}
 
- (void)setReusableVCArray:(NSArray<WZPageViewAssistController *> *)reusableVCArray {
  
    //过滤操作 且 必须含有数据
    if ([reusableVCArray isKindOfClass:[NSArray class]]
        && reusableVCArray.count) {
        NSMutableArray *tmpMArray = [NSMutableArray array];
        
        for (id VC in reusableVCArray) {
            if([VC isKindOfClass:[WZPageViewAssistController class]]) {
                [tmpMArray addObject:VC];
            }
        }
        
        //配置序号
        for (int i = 0; i < tmpMArray.count; i++) {
            ((WZPageViewAssistController *)tmpMArray[i]).index = i;
        }
        if (tmpMArray.count) {
            _numberOfIndexs = tmpMArray.count - 1;
        }
        
        _reusableVCArray = [NSArray arrayWithArray:tmpMArray];
    }
}


@end
