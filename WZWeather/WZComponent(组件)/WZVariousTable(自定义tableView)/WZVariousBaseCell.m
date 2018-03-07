//
//  WZVariousBaseCell.m
//  WZVariousTable
//
//  Created by wizet on 17/3/3.
//  Copyright © 2017年 WZ. All rights reserved.
//

#import "WZVariousBaseCell.h"
#import "WZVariousBaseObject.h"

@implementation WZVariousBaseCell

- (void)isLastElement:(BOOL)boolean {}

+ (CGFloat)heightForData:(WZVariousBaseObject *)obj {return 0.0;}

- (void)singleClicked {NSLog(@"被单击了:%@",[self class]);}

- (void)longPressedUseable:(BOOL)boolean {self.gesture.enabled = boolean;}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {}

- (void)content {}

//code
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self content];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self content];
}


#pragma mark - Accessor 
- (void)setLocatedController:(UIViewController *)locatedController {
    if ([locatedController isKindOfClass:[UIViewController class]]) {
        _locatedController = locatedController;
    }
}

- (UILongPressGestureRecognizer *)gesture {
    if (_gesture) {
        _gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(longPress:)];
        _gesture.minimumPressDuration = 0.5f;
        [self addGestureRecognizer:_gesture];
    }
    return _gesture;
}

@end
