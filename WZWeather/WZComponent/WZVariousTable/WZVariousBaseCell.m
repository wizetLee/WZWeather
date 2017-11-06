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

- (void)isLastElement:(BOOL)boolean {
    
}

+ (CGFloat)heightForData:(WZVariousBaseObject *)obj {
    return 0.0;
}

- (void)singleClicked {
    NSLog(@"被单击了:%@",[self class]);
}

//for code
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)longPressedUseable:(BOOL)boolean {
    if (boolean) {
        if (_gesture) {
            _gesture.enabled = true;
        } else {
            _gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(longPress:)];
            _gesture.minimumPressDuration = 0.5f;
            [self addGestureRecognizer:_gesture];
        }
    } else {
        _gesture.enabled = false;
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Accessor 
- (void)setLocatedController:(UIViewController *)locatedController {
    if ([locatedController isKindOfClass:[UIViewController class]]) {
        _locatedController = locatedController;
    }
}

@end
