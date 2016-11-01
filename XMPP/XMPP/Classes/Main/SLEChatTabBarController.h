//
//  SLEChatTabBarController.h
//  XMPP
//
//  Created by mzyw on 16/10/20.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLELoginTools.h"


@interface SLEChatTabBarController : UITabBarController

+ (SLEChatTabBarController *)setupChatVC;

- (void)handleLoginStatus:(SLEResultType)resultType;

@end
