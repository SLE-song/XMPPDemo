//
//  SLERegisterViewController.m
//  XMPP
//
//  Created by mzyw on 16/10/25.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "SLERegisterViewController.h"
#import "SLELoginTools.h"
#import "SLEProgressHUD.h"
#import "SLEChatTabBarController.h"
#import "SLELoginViewController.h"

@interface SLERegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;


@end

@implementation SLERegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)registerBtn:(id)sender {
    
    [SLELoginTools shareTools].registerUserName = self.userNameTextField.text;
    [SLELoginTools shareTools].registerPassWord = self.passWordTextField.text;
    
    
    
    [[SLELoginTools shareTools] registerUserWithRegistResult:^(SLEResultType resultType) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            switch (resultType) {
                case SLEResultTypeSuccess:
                    
                    NSLog(@"222登录成功");
                    [SLEProgressHUD showSuccessWithString:@"注册成功!" dismiss:2];
                    [[NSUserDefaults standardUserDefaults] setValue:[SLELoginTools shareTools].registerUserName forKey:kUserName];
                    [[NSUserDefaults standardUserDefaults] setValue:[SLELoginTools shareTools].registerPassWord forKey:kPassWord];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [SLELoginTools shareTools].userName = self.userNameTextField.text;
                    [SLELoginTools shareTools].passWord = self.passWordTextField.text;
                    [[UIApplication sharedApplication].keyWindow setRootViewController:[SLEChatTabBarController setupChatVC]];
                    
                    
                    break;
                case SLEResultTypeFailure:
                    NSLog(@"333注册失败");
                    
                    [[SLELoginTools shareTools] logout];
                    [SLEProgressHUD showErrorWithString:@"注册失败，请更换用户名重试！" dismiss:2];
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
- (IBAction)cancle:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
