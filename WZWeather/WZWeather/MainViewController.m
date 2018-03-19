//
//  MainViewController.m
//  WZWeather
//
//  Created by wizet on 17/2/27.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "MainViewController.h"
#import "UIButton+WZMinistrant.h"
#import "WZSystemDetails.h"
#import "WZCameraAssist.h"
#import "WZVCModel.h"
#import "WZHttpRequest+WZWeather.h"
@interface MainViewController ()

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSArray <WZVCModel *>* sources;

@end

@implementation MainViewController

int wzxxxx = 9;//已初始化的全局变量是强符号
int wzxxxx;
int wzxxxx;// 并不出错 , 因为未初始化的全局变量是弱符号
/**
 导出符号， 在本模块定义， 能够被其他模块引用的符号。 非static全局函数， 非static全局变量。
 导入符号， 在其他模块定义，被本模块引用的符号。  extern 修饰的全局非static变量声明（extern int a）， 其他模块的函数引用
 （外部符号（导入符号）： 本模块未定义却被本模块引用的符号）
 静态符号， 在本模块定义， 只能被本模块引用的符号。 static函数， static全局变量。
 局部符号， 在函数内部定义的非static变量。不出现在符号表，由栈管理。链接器不care这类符号
 
 链接器的规则、P468
 1、不允许有多个同名的强符号
 2、如果有一个强符号和多个弱符号同名，那么选择强符号
 3、如果有多个弱符号同名，则从这些弱符号中选取任意一个
 */



#pragma mark - VC Lifecycle
- (void)dealloc { }

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"导航栏";

//    [WZHttpRequest requestBaiSiBuDeJieWithType:WZBaiSiBuDeJieType_video title:@"视频" page:1 SerializationResult:^(id  _Nullable result, BOOL isDictionaty, BOOL isArray, BOOL mismatching, NSError * _Nullable error) {
//        
//    }];
    
    //数据
    _sources = [WZVCModel source];
    //view
    [self.view addSubview:self.table];
    
    //权限
    [WZCameraAssist checkAuthorizationWithHandler:^(BOOL videoAuthorization, BOOL audioAuthorization, BOOL libraryAuthorization) {
        if (!videoAuthorization
            || !videoAuthorization
            || !videoAuthorization) {
            [WZCameraAssist showAlertByVC:self];
        }
    }];
    
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = false;
}

//不用masonry 就使用下面的代码
//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//
//    ///或者改成宏
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

#pragma mark - UITableViewDelegate & UITableViewDataSource

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
    if (_sources.count > indexPath.row) { cell.textLabel.text = _sources[indexPath.row].headline; }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     if (_sources.count > indexPath.row) {

         WZVCModel *model = _sources[indexPath.row];
         
         if (model.type == WZVCModelTransitionType_Push_FromNib) {
             
             UIViewController *VC = [[model.VCClass alloc] initWithNibName:NSStringFromClass(model.VCClass) bundle:nil];
             [self.navigationController pushViewController:VC animated:true];
             
         } else if (model.VCClass == WZAVPlayerViewController.class
                    || model.VCClass == WZMediaController.class) {
             
            id vc = [model.VCClass new];
            self.navigationController.navigationBarHidden = false;
            [self.navigationController pushViewController:vc animated:true];
             
         } else if (model.VCClass == WZPhotoCatalogueController.class) {
             
            [WZPhotoCatalogueController showPickerWithPresentedController:(UIViewController <WZMediaAssetProtocol> *)self];
             
         } else if (model.VCClass == WZVideoPickerController.class) {
             
            [WZVideoPickerController showPickerWithPresentedController:(UIViewController <WZVideoPickerControllerProtocol> *)self];
             
         }
     }
}

#pragma mark - Private

////iOS11以下 是不会调用以下方法的   横竖屏改变 VC present pop 等操作都会执行这个消息
//- (void)viewSafeAreaInsetsDidChange {
//    [super viewSafeAreaInsetsDidChange];
//     NSLog(@"%@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
//}

#pragma mark - WZVideoPickerControllerProtocol


#pragma mark - Accessor
- (UITableView *)table {
    if(!_table) {
        UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [self.view addSubview:table];
        [table mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo((self.view));
            make.right.mas_equalTo(self.view);
            if (@available(iOS 11.0, *)) {
                make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
                make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            } else {
                make.top.mas_equalTo(self.mas_topLayoutGuide);
                make.bottom.mas_equalTo(self.mas_bottomLayoutGuide);
            }
        }];
        
        table.delegate = (id<UITableViewDelegate>)self;
        table.dataSource = (id<UITableViewDataSource>)self;
        table.backgroundColor = UIColor.lightGrayColor;
        table.estimatedRowHeight = UITableViewAutomaticDimension;
        table.estimatedSectionFooterHeight = 0.0;
        table.estimatedSectionHeaderHeight = 0.0;
        
        [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        
        __weak typeof(self) weakSelf = self;
        table.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf.table.mj_header endRefreshing];
        }];
        _table = table;
        
//        CGFloat top = 0.0;
//        CGFloat bottom = 0.0;
//        CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
//        CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
//
//        top = MACRO_FLOAT_STSTUSBAR_AND_NAVIGATIONBAR_HEIGHT;
//        bottom = MACRO_FLOAT_SAFEAREA_BOTTOM;
//        CGFloat height = screenH - bottom - top;
       
//        self.table.frame = CGRectMake(0.0, top, screenW, height);
    }
    return _table;
}

@end
