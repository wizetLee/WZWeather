//
//  Demo_WrapViewController.m
//  WZWeather
//
//  Created by 李炜钊 on 2018/2/25.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "Demo_WrapViewController.h"
#import "WrapView.h"
@interface Demo_WrapViewController ()
{
    WrapView *_tmpView;
}
@end

@implementation Demo_WrapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WrapView *tmpView = [[WrapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:tmpView];
    [self.view sendSubviewToBack:tmpView];
    tmpView.backgroundColor = [UIColor orangeColor];
    _tmpView = tmpView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tmpView.center = self.view.center;
}

- (IBAction)mixture:(id)sender {
    UIImage *image = [_tmpView mixture];
    [self showImage:image];
}
- (IBAction)material:(id)sender {
    UIImage *image = [_tmpView material];
    [self showImage:image];
}

- (void)showImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *tmpImageView = [[UIImageView alloc] initWithImage:image];
        CGFloat hw = [UIScreen mainScreen].bounds.size.width * 2.0 / 3;
        tmpImageView.frame = CGRectMake(0.0, 0.0,  hw, hw);
        tmpImageView.contentMode = UIViewContentModeScaleAspectFit;
        tmpImageView.center = self.view.center;
        [self.view addSubview:tmpImageView];
        
        [UIView animateWithDuration:3.0 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            tmpImageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [tmpImageView removeFromSuperview];
            self.view.userInteractionEnabled = true;
        }];
    });
}


@end
