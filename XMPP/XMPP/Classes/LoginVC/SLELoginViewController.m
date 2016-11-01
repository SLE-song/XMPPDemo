//
//  SLELoginViewController.m
//  XMPP
//
//  Created by mzyw on 16/10/20.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "SLELoginViewController.h"
#import "SLEChatTabBarController.h"
#import "SLEProgressHUD.h"
#import "SLEOtherLoginViewController.h"
#import "SLELoginTools.h"
#import "SLERegisterViewController.h"


@interface SLELoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *uesernameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

// 登录工具
@property (nonatomic, strong) SLELoginTools *tools;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end


/**
 
 * 实现登录
 * 1.初始化XMPPStream
 * 2.连接服务器【传JID】
 * 3.连接成功，发送密码
 * 4.发送成功，发送"在线"消息
 
 */
@implementation SLELoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tools = [SLELoginTools shareTools];
    self.tabBarController.tabBar.hidden = YES;
    self.uesernameTextField.background = [UIImage imageNamed:@"operationbox_text"];
    self.uesernameTextField.text = _tools.userName;
    self.loginBtn.enabled = self.passwordTextField.text.length;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)textChange{
    
     self.loginBtn.enabled = self.passwordTextField.text.length;
    
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    [self.view endEditing:YES];
    [_tools logout];
}



#pragma mark----注销
- (void)logout
{
    
    [_tools logout];
}




#pragma mark----按钮点击

- (IBAction)register:(id)sender {
    // 退出键盘
    [self.view endEditing:YES];
    [self presentViewController:[[SLERegisterViewController alloc] init] animated:YES completion:nil];
}


- (IBAction)login:(id)sender {
    
    // 退出键盘
    [self.view endEditing:YES];
    
    // 保存相关数据
    NSString *userName = self.uesernameTextField.text;
    NSString *passWord = self.passwordTextField.text;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:userName forKeyPath:kUserName];
    [defaults setValue:passWord forKey:kPassWord];
    [defaults synchronize];
    [SLELoginTools shareTools].userName = userName;
    [SLELoginTools shareTools].passWord = passWord;
    
    // 执行登录
    [_tools loginWithUserName:userName passWord:passWord loginResult:^(SLEResultType resultType) {
        NSLog(@"来到回调");
        dispatch_async(dispatch_get_main_queue(), ^{
        
            switch (resultType) {
                case SLEResultTypeSuccess:
                    
                    NSLog(@"222登录成功");
                    [SLEProgressHUD showSuccessWithString:@"登录成功!" dismiss:2];
                    [[UIApplication sharedApplication].keyWindow setRootViewController:[SLEChatTabBarController setupChatVC]];
                    break;
                case SLEResultTypeFailure:
                    NSLog(@"333登录失败");
                    
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

// 其他登录方式
- (IBAction)otherLogin:(id)sender {
    
    SLEOtherLoginViewController *otherVc = [[SLEOtherLoginViewController alloc] init];
    
    [self presentViewController:otherVc animated:YES completion:nil];
}

// 初始化
+ (SLELoginViewController *)setupLoginVC
{
    
    return [[SLELoginViewController alloc] init];
}


- (void)dealloc
{
    
    NSLog(@"======");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



@end
