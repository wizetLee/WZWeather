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
        _gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(longPress:)];
        _gesture.minimumPressDuration = 0.5f;
        [self addGestureRecognizer:_gesture];
     
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)longPressed {
     NSLog(@"被长按了:%@",[self class]);
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self longPressed];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark setter & getter 
- (void)setLocatedController:(UIViewController *)locatedController {
    if ([locatedController isKindOfClass:[UIViewController class]]) {
        _locatedController = locatedController;
    }
}

@end
