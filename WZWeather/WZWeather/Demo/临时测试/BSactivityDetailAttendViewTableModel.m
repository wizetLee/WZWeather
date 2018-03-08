//
//  BSactivityDetailAttendViewTableModel.m
//  WZWeather
//
//  Created by admin on 8/3/18.
//  Copyright © 2018年 WZ. All rights reserved.
//

#import "BSactivityDetailAttendViewTableModel.h"

@implementation BSactivityDetailAttendViewTableModel


+ (NSArray <BSactivityDetailAttendViewTableModel *>*)dataSource {
    NSMutableArray *tmpMarr = NSMutableArray.array;
    BSactivityDetailAttendViewTableModel *model = nil;
//    BSactivityDetailAttendViewBlankCell
//    BSactivityDetailAttendViewTitleCell
//    BSactivityDetailAttendViewContentCell
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.title = @"个人信息保护法律声明";
    model.cellID = @"BSactivityDetailAttendViewTitleCell";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.cellID = @"BSactivityDetailAttendViewBlankCell30";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.title = @"    感谢您对一汽马自达品牌的关注以及对本网站的友好访问。一汽马自达作为本网站的所有人，特此发布本声明如下，提醒您仔细阅读。";
    model.cellID = @"BSactivityDetailAttendViewContentCell";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.cellID = @"BSactivityDetailAttendViewBlankCell50";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.title = @"个人信息的范围";
    model.cellID = @"BSactivityDetailAttendViewTitleCell";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.cellID = @"BSactivityDetailAttendViewBlankCell30";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.title = @"    我们向您收集的个人信息系能够单独或者与其他信息结合识别您的个人身份的信息，包括但不限于您的姓名、性别、年龄、出生日期、身份证号、住址、联系方式、爱好、职业、紧急联系人、相关账号、使用我们的服务的时间和地点等个人信息（“个人信息”）。该等信息均是您自愿提供的。";
    model.cellID = @"BSactivityDetailAttendViewContentCell";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.cellID = @"BSactivityDetailAttendViewBlankCell50";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.title = @"个人数据的使用和披露";
    model.cellID = @"BSactivityDetailAttendViewTitleCell";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.cellID = @"BSactivityDetailAttendViewBlankCell30";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.title = @"    一汽马自达可将您的个人数据用于网站的技术管理、客户服务和管理、产品调查和推广。在法律要求的情况下，我们将不可避免地将您的数据披露给政府机构。我们的雇员、代理和经销商均受保密义务的约束。您有权拒绝提供个人信息。但如果您拒绝提供某些个人信息，您将可能无法使用我们提供的某些产品、服务，或者可能对您使用这些产品或服务造成一定的影响，如出现前述情况或问题则需要您自行承担相应的后果。";
    model.cellID = @"BSactivityDetailAttendViewContentCell";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.cellID = @"BSactivityDetailAttendViewBlankCell50";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.title = @"适用法律";
    model.cellID = @"BSactivityDetailAttendViewTitleCell";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.cellID = @"BSactivityDetailAttendViewBlankCell30";
    [tmpMarr addObject:model];
    
    model = BSactivityDetailAttendViewTableModel.alloc.init;
    model.title = @"    本声明适用中华人民共和国法律。如果您需要查询、修改或更正您的个人信息，或对个人信息保护问题有任何疑问或投诉，您可以拨打400-666-8080联系我们。";
    model.cellID = @"BSactivityDetailAttendViewContentCell";
    [tmpMarr addObject:model];
    
    return tmpMarr;
}


@end
