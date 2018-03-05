//
//  WZTestViewController.m
//  WZWeather
//
//  Created by admin on 31/1/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "WZTestViewController.h"

@interface WZTestViewController ()



@end

@implementation WZTestViewController


- (void)dealloc {
    NSLog(@"%s", __func__);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    
}

- (void)viewDidAppear:(BOOL)animated {

}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];


}

//冒泡  升序
void bubble(int a[], int size) {
    int i, j, tmp;
    for (i = 0; i < size; i++) {
        for (j = 1; j < size - i; j++) {
            if (a[j] < a[i]) {
                
            }
            tmp = a[i];
            
        }
    }
}


@end
