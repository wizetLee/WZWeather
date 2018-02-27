//
//  MainViewController.m
//  WZWeather
//
//  Created by wizet on 17/2/27.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "MainViewController.h"
#import "WZLoopView.h"
#import "WZScrollOptions.h"
#import "UIButton+WZMinistrant.h"
#import "WZSystemDetails.h"
#import "WZCameraAssist.h"

#import "WZVCModel.h"


@interface MainViewController () <WZVideoPickerControllerProtocol, WZMediaAssetProtocol>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray <WZVCModel *>* sources;

@end

@implementation MainViewController

///方法交换
//+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector bySwizzledSelector:(SEL)swizzledSelector{
//    Class class = [self class];
//    //原有方法
//    Method originalMethod = class_getInstanceMethod(class, originalSelector);
//    //替换原有方法的新方法
//    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//    //先尝试給源SEL添加IMP，这里是为了避免源SEL没有实现IMP的情况
//    BOOL didAddMethod = class_addMethod(class,originalSelector,
//                                        method_getImplementation(swizzledMethod),
//                                        method_getTypeEncoding(swizzledMethod));
//    if (didAddMethod) {//添加成功：说明源SEL没有实现IMP，将源SEL的IMP替换到交换SEL的IMP
//        class_replaceMethod(class,swizzledSelector,
//                            method_getImplementation(originalMethod),
//                            method_getTypeEncoding(originalMethod));
//    } else {//添加失败：说明源SEL已经有IMP，直接将两个SEL的IMP交换即可
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
//}
//
//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self methodSwizzlingWithOriginalSelector:@selector(viewWillAppear:) bySwizzledSelector:@selector(sure_viewWillDisappear:)];
//    });
//}
//
//- (void)sure_viewWillDisappear:(BOOL)animated {
//    [self sure_viewWillDisappear:animated];
//}

#pragma mark - ViewController Lifecycle

- (instancetype)init {
    if (self = [super init]) {}
    return self;    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"导航栏";
    WZLoopView *loop = [[WZLoopView alloc] initWithFrame:CGRectMake(0.0, MACRO_FLOAT_STSTUSBAR_AND_NAVIGATIONBAR_HEIGHT, MACRO_FLOAT_SCREEN_WIDTH, 100) images:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", ] loop:true delay:2];
    [self.view addSubview:loop];

//    NSLog(@"%lf", button.cornerRadius);
    
//    appBuild();
//    appVersion();
//    appBundleID();
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.view addSubview:imageView];
//    [WZHttpRequest loadBiYingImageInfo:^(NSString *BiYingCopyright, NSString *BiYingDate, NSString *BiYingDescription, NSString *BiYingTitle, NSString *BiYingSubtitle, NSString *BiYingImg_1366, NSString *BiYingImg_1920, UIImage *image) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//           imageView.image = image;
//        });
//    }];//异步加载必应墙纸
    
    
    
    _sources = [WZVCModel source];
   
    
    
    if(!_table) {
        UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [self.view addSubview:table];
        [table mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo((self.view));
            make.right.mas_equalTo(self.view);
            if (@available(iOS 11.0, *)) {
                make.top.mas_equalTo(loop.mas_bottom);
                make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            } else {
                make.top.mas_equalTo(loop.mas_bottom);
                make.bottom.mas_equalTo(self.mas_bottomLayoutGuide);
            }
        }];
        table.delegate = (id<UITableViewDelegate>)self;
        table.dataSource = (id<UITableViewDataSource>)self;
        table.backgroundColor = UIColor.yellowColor;
        table.estimatedRowHeight = UITableViewAutomaticDimension;
        table.estimatedSectionFooterHeight = 0.0;
        table.estimatedSectionHeaderHeight = 0.0;
        
        [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        __weak typeof(self) weakSelf = self;
        table.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
            [weakSelf.table.mj_header endRefreshing];
        }];
        
            CGFloat top = 0.0;
            CGFloat bottom = 0.0;
            CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
            CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
        
            top = MACRO_FLOAT_STSTUSBAR_AND_NAVIGATIONBAR_HEIGHT;
            bottom = MACRO_FLOAT_SAFEAREA_BOTTOM;
            CGFloat height = screenH - bottom - top;
           _table = table;
           self.table.frame = CGRectMake(0.0, top, screenW, height);
    }
}



//不用masonry 就使用下面的代码
//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//
//    ///
//    CGFloat top = 0.0;
//    CGFloat bottom = 0.0;
//    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
//    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
//    if (@available(iOS 11.0, *)) {
//        top = self.view.safeAreaInsets.top;
//        bottom = self.view.safeAreaInsets.bottom;
//    } else {
//        top = MACRO_FLOAT_STSTUSBAR_AND_NAVIGATIONBAR_HEIGHT;
//    }
//    CGFloat height = screenH - bottom - top;
//
//    self.table.frame = CGRectMake(0.0, top, screenW, height);
//}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
      return 50.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section; {
      return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section; {
      return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    if (_sources.count > indexPath.row) {
       cell.textLabel.text = _sources[indexPath.row].headline;
    } else {
        cell.textLabel.text = @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     if (_sources.count > indexPath.row) {

         WZVCModel *model = _sources[indexPath.row];
         if (model.type == WZVCModelTransitionType_Push_FromNib) {
             UIViewController *VC = [[model.VCClass alloc] initWithNibName:NSStringFromClass(model.VCClass) bundle:nil];
             [self.navigationController pushViewController:VC animated:true];
         }
         
         if (model.VCClass == WZMediaController.class) {
             [self pushToMediaVC];
         } else if (model.VCClass == WZAVPlayerViewController.class) {
             WZAVPlayerViewController *vc = [WZAVPlayerViewController new];
             self.navigationController.navigationBarHidden = false;
             [self.navigationController pushViewController:vc animated:true];
         } else if (model.VCClass == WZPhotoCatalogueController.class) {
              [WZPhotoCatalogueController showPickerWithPresentedController:self];
         } else if (model.VCClass == WZVideoPickerController.class) {
             [WZVideoPickerController showPickerWithPresentedController:self];
         } else if (model.VCClass == WZTestViewController.class) {
             WZTestViewController *vc = [[WZTestViewController alloc] init];
             [self.navigationController pushViewController:vc animated:true];
         }
         
     }
}


- (void)pushToMediaVC {
    [WZCameraAssist checkAuthorizationWithHandler:^(BOOL videoAuthorization, BOOL audioAuthorization, BOOL libraryAuthorization) {
        if (videoAuthorization
            && audioAuthorization
            && libraryAuthorization) {
            ///下载页面
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController addToSystemSideslipBlacklist:NSStringFromClass([WZDownloadController class])];
                //    WZDownloadController *vc = [[WZDownloadController alloc] init];
                WZMediaController *vc = [WZMediaController new];
                [self.navigationController pushViewController:vc animated:true];
                
            });
        } else {
            [self showAlter];
        }
    }];
}

//iOS11以下 是不会调用以下方法的   横竖屏改变 VC present pop 等操作都会执行这个消息
//- (void)viewSafeAreaInsetsDidChange {
//    [super viewSafeAreaInsetsDidChange];
//     NSLog(@"%@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
//}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = false;
}



- (void)showAlter {
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"视频、音频、相册权限受阻" message:@"是否要到设置处进行权限设置" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [WZCameraAssist openAppSettings];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alter dismissViewControllerAnimated:true completion:nil];
    }];
    [alter addAction:actionSure];
    [alter addAction:actionCancel];
    [self presentViewController:alter animated:true completion:nil];
}

#pragma mark - WZVideoPickerControllerProtocol

///右击
- (void)videoPickerControllerDidClickedRightItem; {
    
}

#pragma mark - WZPageViewControllerProtocol
//控制器角标传出
- (void)pageViewController:(UIPageViewController *)pageViewController showVC:(WZPageViewAssistController *)VC inIndex:(NSInteger)index {
    NSLog(@"vc-%@=======index-%ld", VC, index);
}

@end
