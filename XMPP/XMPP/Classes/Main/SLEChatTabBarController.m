//
//  SLEChatTabBarController.m
//  XMPP
//
//  Created by mzyw on 16/10/20.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "SLEChatTabBarController.h"
#import "SLEChatNavigationController.h"
#import "SLEMeTableViewController.h"
#import "SLEDiscoverTableViewController.h"
#import "SLEConnectionTableViewController.h"
#import "SLEWeChatTableViewController.h"
#import "SLEProgressHUD.h"
#import "SLELoginViewController.h"

@interface SLEChatTabBarController ()

@end

@implementation SLEChatTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupChildVC];
}

// 加载所有子控制器
- (void)setupChildVC
{
    [self setupOneChildVcWithViewController:[[SLEWeChatTableViewController alloc] init] title:@"微信" image:@"tabbar_mainframe" selectImage:@"tabbar_mainframeHL"];
    
    [self setupOneChildVcWithViewController:[[SLEConnectionTableViewController alloc] init] title:@"通讯录" image:@"tabbar_contacts" selectImage:@"tabbar_contactsHL"];
    
    [self setupOneChildVcWithViewController:[[SLEDiscoverTableViewController alloc] init] title:@"发现" image:@"tabbar_discover" selectImage:@"tabbar_discoverHL"];
    
    [self setupOneChildVcWithViewController:[[SLEMeTableViewController alloc] init] title:@"我" image:@"tabbar_me" selectImage:@"tabbar_meHL"];
}

// 加载一个子控制器
- (void)setupOneChildVcWithViewController:(UIViewController *)vc title:(NSString *)title image:(NSString *)image selectImage:(NSString *)selectImage
{

    SLEChatNavigationController *chatNav = [[SLEChatNavigationController alloc] initWithRootViewController:vc];
    vc.title = title;
    [vc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:9/255.0 green:187/255.0 blue:7/255.0 alpha:1]} forState:UIControlStateSelected];
    vc.tabBarItem.image = [UIImage imageNamed:image];
    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self addChildViewController:chatNav];
}




// 初始化
+ (SLEChatTabBarController *)setupChatVC
{

    return [[SLEChatTabBarController alloc] init];
}


- (void)handleLoginStatus:(SLEResultType)resultType{

    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (resultType) {
            case SLEResultTypeSuccess:
                
                NSLog(@"222登录成功");
                [SLEProgressHUD showSuccessWithString:@"登录成功!" dismiss:2];
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


}

@end
