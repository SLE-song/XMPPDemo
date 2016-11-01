//
//  SLEAddFriendsViewController.m
//  XMPP
//
//  Created by mzyw on 16/10/27.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "SLEAddFriendsViewController.h"
#import "SLELoginTools.h"
#import "SLEProgressHUD.h"


@interface SLEAddFriendsViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addTextField;

@end

@implementation SLEAddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.addTextField.delegate = self;
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    
    // 发送添加好友请求
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",self.addTextField.text,@"kmart.local"];
    XMPPJID *friendsJid = [XMPPJID jidWithString:jidStr];
    
    if ([jidStr isEqualToString:[SLELoginTools shareTools].userName]) {
        
        
        [SLEProgressHUD showErrorWithString:@"不能添加自己为好友！" dismiss:2];
        return YES;
    }
    
    BOOL exit = [[SLELoginTools shareTools].xmppRosterStorage userExistsWithJID:friendsJid xmppStream:[SLELoginTools shareTools].xmppStream];
    if (exit) {
        
        [SLEProgressHUD showErrorWithString:@"当前好友已经存在！" dismiss:2];
        return YES;
    }
    
    [[SLELoginTools shareTools].xmppRoster subscribePresenceToUser:friendsJid];
    
    return YES;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
