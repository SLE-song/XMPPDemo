//
//  SLEProgressHUD.h

//
//  Created by sle on 16/10/10.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLEProgressHUD : UIView

+ (void)showErrorWithString:(NSString *) str dismiss:(CGFloat)duration;
+ (void)showStatusWithString:(NSString *) str dismiss:(CGFloat)duration;
+ (void)showStatusWithString:(NSString *) str;
+ (void)showSuccessWithString:(NSString *) str dismiss:(CGFloat)duration;
+ (void)dismiss;

@end
