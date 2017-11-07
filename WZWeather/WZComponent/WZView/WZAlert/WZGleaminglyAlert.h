//
//  WZBaseAlert.h
//  WZAlert
//
//  Created by Wizet on 21/9/17.
//  Copyright © 2017年 Wizet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZGleaminglyAlert : UIView

- (void)clickBackgroundToDismiss:(BOOL)boolean;
- (void)show;
- (void)alertDismissWithAnimated:(BOOL)animated;
- (void)createViews NS_REQUIRES_SUPER;


@end
