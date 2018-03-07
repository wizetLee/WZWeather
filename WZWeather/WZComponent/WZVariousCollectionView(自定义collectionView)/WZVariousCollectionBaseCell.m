//
//  WZVariousCollectionBaseCell.m
//  WZWeather
//
//  Created by wizet on 17/3/7.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVariousCollectionBaseCell.h"

@implementation WZVariousCollectionBaseCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(longPress:)];
        gesture.minimumPressDuration = 0.5f;
        [self addGestureRecognizer:gesture];
    }
    return self;
}

- (void)isLastElement:(BOOL)boolean {
}

- (void)singleClicked {
//    NSLog(@"被单击了:%s", __FUNCTION__);
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self longPressed];
    }
}

- (void)longPressed  {
//    NSLog(@"被长按了:%s", __FUNCTION__);
}

+ (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath model:(WZVariousCollectionBaseObject *)model {
    return CGSizeZero;
}

- (void)setLocatedController:(UIViewController *)locatedController {
    if ([locatedController isKindOfClass:[UIViewController class]]) {
        _locatedController = locatedController;
    }
} 

@end
