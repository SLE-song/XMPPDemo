//
//  SLEOtherLoginViewController.m
//  XMPP
//
//  Created by mzyw on 16/10/20.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "SLEOtherLoginViewController.h"
#import "SLELoginViewController.h"
#import "SLELoginTools.h"
#import "SLEProgressHUD.h"
#import "SLEChatTabBarController.h"


@interface SLEOtherLoginViewController ()

// user
@property (nonatomic, copy) NSString *sle_userName;
// password
@property (nonatomic, copy) NSString *sle_passWord;

@end

@implementation SLEOtherLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userName.text = [SLELoginTools shareTools].userName;
    self.passWord.text = [SLELoginTools shareTools].passWord;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:nil];
    [self textChange];
}


- (void)textChange{


    self.sle_userName = self.userName.text;
    self.sle_passWord = self.passWord.text;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.sle_userName forKeyPath:kUserName];
    [defaults setValue:self.sle_passWord forKey:kPassWord];
//    [defaults setValue:@"1" forKey:kLoginStatus];
    [defaults synchronize];
    [SLELoginTools shareTools].userName = self.sle_userName;
    [SLELoginTools shareTools].passWord = self.sle_passWord;

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    // 退出键盘
    [self.view endEditing:YES];
}


- (IBAction)cancle:(id)sender {
    // 退出键盘
    [self.view endEditing:YES];
    [[UIApplication sharedApplication].keyWindow setRootViewController:[SLELoginViewController setupLoginVC]];
}

- (IBAction)login:(id)sender {
    
    // 退出键盘
    [self.view endEditing:YES];
    
    if (self.sle_userName != self.userName.text) {
        
        self.userName.text = self.sle_userName;
    }
    if (self.sle_passWord != self.passWord.text) {
        
        self.passWord.text = self.sle_passWord;
    }
    
    [[SLELoginTools shareTools] loginWithUserName:self.userName.text passWord:self.passWord.text loginResult:^(SLEResultType resultType) {

        dispatch_async(dispatch_get_main_queue(), ^{
            
            switch (resultType) {
                case SLEResultTypeSuccess:
                    

                    [SLEProgressHUD showSuccessWithString:@"登录成功!" dismiss:2];
                    [[UIApplication sharedApplication].keyWindow setRootViewController:[SLEChatTabBarController setupChatVC]];
                    break;
                case SLEResultTypeFailure:

                    [[SLELoginTools shareTools] logout];
                    [SLEProgressHUD showErrorWithString:@"用户名或者密码错误" dismiss:2];
                    break;
                    
                case SLEResultTypeNetError:
                    NSLog(@"333登录超时");
                    
                    [[SLELoginTools shareTools] logout];
                    [SLEProgressHUD showErrorWithString:@"请检查网络连接!" dismiss:2];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:kLoginStatus];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [[UIApplication sharedApplication].keyWindow setRootViewController:[SLELoginViewController setupLoginVC]];
                    });
                    break;
                    
                default:
                    break;
            }
        });
        
        
    }];

}




- (void)dealloc
{

    NSLog(@"======");
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}






@end
