//
//  SLEChatInputView.h
//  XMPP
//
//  Created by mzyw on 16/10/28.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLEChatInputView : UIView

+ (instancetype)sle_loadSLEChatInputView;

@property (weak, nonatomic) IBOutlet UITextView *chatTextView;

@property (weak, nonatomic) IBOutlet UIButton *addOtherButton;

@end
