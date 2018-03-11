//
//  BSactivityDetailAttendViewContentCell.m
//  
//
//  Created by admin on 8/3/18.
//

#import "BSactivityDetailAttendViewContentCell.h"
#import "BSactivityDetailAttendViewTableModel.h"

@implementation BSactivityDetailAttendViewContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:20.0 * 0.75];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)updateWithModel:(BSactivityDetailAttendViewTableModel *)model {
    UILabel *tempLabel = self.titleLabel;
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.text = model.title;
  
    CGSize size = [tempLabel sizeThatFits:CGSizeMake(BSATTENDVIEWTABLE_WIDTH, MAXFLOAT)];
    //设置frame
    tempLabel.frame = CGRectMake(0.0, 0.0, size.height, size.height);

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // 行间距设置为30
    [paragraphStyle setLineSpacing:7];
    
    NSMutableAttributedString  *setString = [[NSMutableAttributedString alloc] initWithString:model.title];
    [setString  addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [setString length])];
    [tempLabel  setAttributedText:setString];
    
    CGFloat height = [self getHeightLineWithString:setString.string withWidth:BSATTENDVIEWTABLE_WIDTH withFont:tempLabel.font];
    
    tempLabel.frame =  CGRectMake(0.0, 0.0, BSATTENDVIEWTABLE_WIDTH, height);
}

- (float)calculateCellHeightWithModel:(BSactivityDetailAttendViewTableModel *)model {
    [self updateWithModel:model];
    return self.titleLabel.frame.size.height;
}

- (CGFloat)getHeightLineWithString:(NSString *)string withWidth:(CGFloat)width withFont:(UIFont *)font {
    
    CGSize size = CGSizeMake(width, 2000);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:7];

    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};

    CGFloat height = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size.height;
    
    return height;
}

@end
