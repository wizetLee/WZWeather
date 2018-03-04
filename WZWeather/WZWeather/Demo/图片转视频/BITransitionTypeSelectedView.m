//
//  BITransitionTypeSelectedView.m
//  WZWeather
//
//  Created by admin on 2/3/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "BITransitionTypeSelectedView.h"

@interface BITransitionTypeSelectedView() {
    UIButton *_btnPointer;
}
@property (nonatomic, strong) NSArray *nodeTypeArr;

@end

@implementation BITransitionTypeSelectedView


- (void)defaultConfig {
    self.frame = [UIScreen mainScreen].bounds;
    NSMutableArray *tmpArr = [NSMutableArray array];

    for (int i = 0; i < _nodeCount; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"效果为 : 无" forState:UIControlStateNormal];
        button.tag = 100 + i;
        [self addSubview:button];
        
        [tmpArr addObject:@(0)]; //节点数目
    }
    
    _nodeTypeArr  = [tmpArr copy];
}

- (void)configAlert {
    UIAlertController *alert = [[UIAlertController alloc] init];
    NSArray <NSDictionary *>*source = [self.class alertSource];
    NSUInteger count = source.count;
    for (NSUInteger i = 0; i < count; i++) {
        NSDictionary *dic = source[i];
        NSString *value = dic[[NSString stringWithFormat:@"%lu", (unsigned long)i]];
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"效果 :  %@", value] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self actionWithType:i];
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *action1000 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action1000];
    
    [self.navigationController presentViewController:alert animated:true completion:^{}];
}

- (void)actionWithType:(NSUInteger)type {
    UIButton *sender = _btnPointer;
    NSUInteger index = sender.tag - 100;
    if (1 > index) {
    
        NSString *title = [self.class alertSource][type][[NSString stringWithFormat:@"%lu", (unsigned long)type]];
        [sender setTitle:[NSString stringWithFormat:@"效果为 : %@", title] forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"_____" forState:UIControlStateNormal];
    }
}

+ (NSArray <NSDictionary *>*)alertSource {
    NSMutableArray *source = NSMutableArray.array;
    NSDictionary *dic = @{@"0" : @"无"};
    [source addObject:dic];
    
    dic = @{@"1" : @"溶解"};
    [source addObject:dic];
    
    dic = @{@"2" : @"黑"};
    [source addObject:dic];
    
    dic = @{@"3" : @"白"};
    [source addObject:dic];
    
    dic = @{@"4" : @"模糊"};
    [source addObject:dic];
    
    dic = @{@"5" : @"抹_左向右"};
    [source addObject:dic];
    
    dic = @{@"6" : @"抹_右向左"};
    [source addObject:dic];
    
    dic = @{@"7" : @"抹_顶向底"};
    [source addObject:dic];
    
    dic = @{@"8" : @"抹_底向顶"};
    [source addObject:dic];
    
    dic = @{@"9" : @"挤压_左向右"};
    [source addObject:dic];
    
    dic = @{@"10" : @"挤压_右向左"};
    [source addObject:dic];
    
    dic = @{@"11" : @"挤压_顶向底"};
    [source addObject:dic];
    
    dic = @{@"12" : @"挤压_底向顶"};
    [source addObject:dic];
    
    dic = @{@"13" : @"翻转"};
    [source addObject:dic];
    
    dic = @{@"14" : @"百叶窗_水平"};
    [source addObject:dic];
    
    dic = @{@"15" : @"百叶窗_垂直"};
    [source addObject:dic];
    
    dic = @{@"16" : @"逐次百叶窗_左向右"};
    [source addObject:dic];
    
    dic = @{@"17" : @"逐次百叶窗_右向左"};
    [source addObject:dic];
    
    dic = @{@"18" : @"逐次百叶窗_顶向底"};
    [source addObject:dic];
    
    dic = @{@"19" : @"逐次百叶窗_底向顶"};
    [source addObject:dic];
    
    dic = @{@"20" : @"顺时针"};
    [source addObject:dic];
    
    dic = @{@"21" : @"逆时针"};
    [source addObject:dic];
    
    dic = @{@"22" : @"星形"};
    [source addObject:dic];
    
    dic = @{@"23" : @"辉光"};
    [source addObject:dic];
    
    return source;
}


@end
