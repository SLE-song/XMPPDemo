//
//  AppDelegate.m
//  XMPP
//
//  Created by mzyw on 16/10/20.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import "AppDelegate.h"

#import "SLEOtherLoginViewController.h"
#import "SLELoginTools.h"
#import "SLELoginViewController.h"
#import "SLEChatTabBarController.h"
#import "SLEProgressHUD.h"


@interface AppDelegate ()




@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds]; 
    [self.window makeKeyAndVisible];
   
    if ([[SLELoginTools shareTools].loginStatus isEqualToString:@"1"]) {
    
        self.window.rootViewController = [SLEChatTabBarController setupChatVC];
        
        [[SLELoginTools shareTools] loginWithUserName:[SLELoginTools shareTools].userName passWord:[SLELoginTools shareTools].passWord loginResult:^(SLEResultType resultType) {
           
            [[SLEChatTabBarController setupChatVC] handleLoginStatus:resultType];
        }];
        
        
    }else if ([SLELoginTools shareTools].userName != nil && [SLELoginTools shareTools].passWord != nil) {
        
        SLEOtherLoginViewController *otherVc = [[SLEOtherLoginViewController alloc] init];
        self.window.rootViewController = otherVc;
        otherVc.userName.text = [SLELoginTools shareTools].userName;
        otherVc.passWord.text = [SLELoginTools shareTools].passWord;
        
    }else{
    
        self.window.rootViewController = [SLELoginViewController setupLoginVC];
    }
    
    
    // 注册应用后台通知
    
    if ([[UIDevice currentDevice].systemVersion floatValue] > 8.0) {
        
        UIUserNotificationSettings *userSet = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication]registerUserNotificationSettings:userSet];
    }
    
    
    
    
    return YES;
}







@end
