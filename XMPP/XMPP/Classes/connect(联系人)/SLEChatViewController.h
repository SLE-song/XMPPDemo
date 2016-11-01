//
//  SLEChatViewController.h
//  XMPP
//
//  Created by mzyw on 16/10/28.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPJID.h"

@interface SLEChatViewController : UIViewController

// 好友JID
@property (nonatomic, copy) XMPPJID *friendJID;

@end
