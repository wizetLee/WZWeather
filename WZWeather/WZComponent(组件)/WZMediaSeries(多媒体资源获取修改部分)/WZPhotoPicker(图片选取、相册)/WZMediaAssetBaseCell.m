//
//  WZMediaAssetBaseCell.m
//  WZPhotoPicker
//
//  Created by wizet on 2017/5/21.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "WZMediaAssetBaseCell.h"
#import "WZMediaFetcher.h"
#import "UIImageView+setImageInDefaultMode.h"
@implementation WZMediaAssetBaseCell

- (void)prepareForReuse {
    self.imageView.image = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.contentView.layer.borderWidth = 1.0;
//        self.contentView.layer.borderColor = [UIColor blackColor].CGColor;
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor lightGrayColor];
        _imageView.layer.masksToBounds = true;
        [self.contentView addSubview:_imageView];
        
    }
    return self;
}

- (void)clickedBtn:(UIButton *)sender {
    if (_asset) {
        if (_selectedBlock) {
            _selectedBlock(_asset.selected);
        }
    }
}

- (void)setAsset:(WZMediaAsset *)asset {
    if ([asset isKindOfClass:[WZMediaAsset class]]) {
        _asset = asset;
        self.headlineLabel.text = [NSString stringWithFormat:@"%ld * %ld", _asset.asset.pixelWidth, _asset.asset.pixelHeight];
        self.selectButton.selected = _asset.selected;
        if (_asset.imageThumbnail) {
            self.imageView.image = _asset.imageThumbnail;
        } else {
            __weak typeof(self) weakSelf = self;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setImageInDefaultModeWithImage) object:nil];
            [self performSelector:@selector(setImageInDefaultModeWithImage) withObject:nil afterDelay:0.0 inModes:@[NSDefaultRunLoopMode]];
//            [[PHImageManager defaultManager] cancelImageRequest:_imageRequestID];
//            [_asset fetchThumbnailImageSynchronously:false handler:^(UIImage *image) {
//                  weakSelf.imageView.image = image;
//            }];
        }
    }
}

- (void)setImageInDefaultModeWithImage{
    __weak typeof(self) weakSelf = self;
    //获取大图
    [_asset fetchOrigionalImageSynchronously:false handler:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = image;
        });
    }];
}

#pragma mark - Accessor

- (UILabel *)headlineLabel {
    if (!_headlineLabel) {
        CGFloat h = 22.0;
        _headlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, self.bounds.size.height - h, self.bounds.size.width, h)];
        _headlineLabel.text = @"";
        _headlineLabel.textColor = UIColor.whiteColor;
        _headlineLabel.font = [UIFont systemFontOfSize:12];
        _headlineLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_headlineLabel];
        _headlineLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    }
    return _headlineLabel;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        CGFloat selectedBtnHW = 33;
        _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - selectedBtnHW , 0, selectedBtnHW, selectedBtnHW)];
        [self.contentView addSubview:_selectButton];
        NSAssert([UIImage imageNamed:@"message_oeuvre_btn_normal"], @"资源丢失");
        NSAssert([UIImage imageNamed:@"message_oeuvre_btn_selected"], @"资源丢失");
        [_selectButton setImage:[UIImage imageNamed:@"message_oeuvre_btn_normal"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"message_oeuvre_btn_selected"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
        _selectButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    }
    return _selectButton;
}


@end
