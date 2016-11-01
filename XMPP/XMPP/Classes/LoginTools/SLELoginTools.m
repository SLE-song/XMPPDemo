//
//  SLELoginTools.m
//  XMPP
//
//  Created by mzyw on 16/10/21.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

/** 
 *
 *登录流程： a.获取用户名 和 密码，连接到主机
 *         b.连接主机成功之后，开始发送密码
 *         c.发送密码，验证授权
 *         d.验证授权成功，登录成功，发送在线消息给主机
 *         e.发送在线消息成功，登录完成
 *
 *注册流程： a.获取用户名 和 密码，连接到主机
 *         b.连接主机成功之后，开始发送注册密码
 *         c.发送注册密码
 *         d.注册成功，发送在线消息给主机
 *         e.发送在线消息成功
 */






#import "SLELoginTools.h"
#import "SLEProgressHUD.h"
#import "SLEChatTabBarController.h"
#import "SLELoginViewController.h"
//#import "XMPPReconnect.h"


//#import "XMPPRosterMemoryStorage.h"
//#import "XMPPRosterCoreDataStorage.h"


@interface SLELoginTools ()<XMPPStreamDelegate>

{
    
    // 回调结果
    SLEResultBlock _resultBlock;
    // 电子名片数据存储
    XMPPvCardCoreDataStorage *_xmppvCDStorage;
    
    // 头像模块
    XMPPvCardAvatarModule *_xmppAvatarModule;
 
    // 重连
    XMPPReconnect *_xmppReconnect;
    
    // 聊天模块
    XMPPMessageArchiving *_xmppMessageArchiving;

}

@end

@implementation SLELoginTools

static SLELoginTools *tools;

+ (instancetype)shareTools
{
    if (tools == nil) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            tools = [[SLELoginTools alloc] init];
        });
    }

    return tools;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        
        _userName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserName];
        _passWord = [[NSUserDefaults standardUserDefaults] objectForKey:kPassWord];
        _loginStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginStatus];
    }

    return self;
}

static NSString *domain = @"kmart.local";

- (NSString *)currentJid
{


    return [NSString stringWithFormat:@"%@@%@",self.userName,domain];
}



#pragma mark----注册
- (void)registerUserWithRegistResult:(SLEResultBlock)resultBlock
{
    [SLELoginTools shareTools].registerOperation = YES;
    _resultBlock = resultBlock;
    [_xmppStream disconnect];
    [self connectToHostWithUserName:[SLELoginTools shareTools].registerUserName passWord:[SLELoginTools shareTools].registerPassWord];

}

#pragma mark----注销
- (void)logout
{
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
    [_xmppStream disconnect];
}

#pragma mark----登录
- (void)loginWithUserName:(NSString *)userName passWord:(NSString *)passWord loginResult:(SLEResultBlock)resultBlock
{

    [SLELoginTools shareTools].registerOperation = NO;
    _resultBlock = resultBlock;
    [self connectToHostWithUserName:userName passWord:passWord];
}





#pragma mark----初始化 私有方法
- (void)setupXMPPStream
{
    
    _xmppStream = [[XMPPStream alloc] init];
    
    // 添加电子名片模块
    _xmppvCDStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _xmppvCAModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_xmppvCDStorage];
    
    // 激活
    [_xmppvCAModule activate:_xmppStream];
    
    
    // 头像模块
    _xmppAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCAModule];
    [_xmppAvatarModule activate:_xmppStream];
    
    
    // 自动重连模块
    _xmppReconnect = [[XMPPReconnect alloc] init];
    [_xmppReconnect activate:_xmppStream];
    
    
    // 花名册模块
    _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage];
    [_xmppRoster activate:_xmppStream];
    
    
    // 消息模块
    _xmppMessageArVCoreDStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_xmppMessageArVCoreDStorage];
    [_xmppMessageArchiving activate:_xmppStream];
    
    // 设置后台属性  必须真机测试
    _xmppStream.enableBackgroundingOnSocket = YES;
    
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

// 连接主机
- (void)connectToHostWithUserName:(NSString *)userName passWord:(NSString *)passWord
{

    self.myPassWord = passWord;
    if ([SLELoginTools shareTools].isRegisterOperation) {
        
        [SLEProgressHUD showStatusWithString:@"正在注册..."];
    }else{
    
        [SLEProgressHUD showStatusWithString:@"正在登陆..."];
    }
    if (_xmppStream == nil) {
        
        [self setupXMPPStream];
    }
    
    // resource 设备类型
    NSString *temp = nil;
    NSString *jid = nil;
    for (int i; i < userName.length; i++) {
        
        temp = [userName substringWithRange:NSMakeRange(i, 1)];
        if ([temp isEqualToString:@"@"]) {
           
            break;
        }
        
        jid = [userName substringToIndex:i+1];
    }
    XMPPJID *mJID = [XMPPJID jidWithUser:jid domain:@"kmart.local" resource:@"iphone"];
    _xmppStream.myJID = mJID;
    
    // 设置服务器域名 -- 不仅仅可以是域名，还可以是 IP
    _xmppStream.hostName = @"kmart.local";
    
    // 设置端口 ，可以不设置，默认是 5222
    _xmppStream.hostPort = 5222;
    
    NSError *error = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    
    
}

// 发送密码
- (void)sendPassWordToHostWithPassWord:(NSString *)passWord
{
    
    NSError *error = nil;
    NSLog(@"密码：%@",passWord);
    [_xmppStream authenticateWithPassword:passWord error:&error];
    if (error) {

        SLELog(@"发送密码错误 %@",error);
    }
    
}

// 发送在线消息
- (void)sendOnlineMesseageToHost
{
    NSLog(@"发送在线消息");
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
    
}

- (void)saveData{

    /** 存储数据 */
    XMPPvCardTemp *slevCardTemp =  self.xmppvCAModule.myvCardTemp;
    self.photo = slevCardTemp.photo;
    self.nickName = slevCardTemp.nickname;
    self.orgName = slevCardTemp.orgName;
    
//    if (slevCardTemp.orgUnits) {
//        
//        self.orgUnits = slevCardTemp.orgUnits;
//    }
    self.title = slevCardTemp.title;
    //    NSLog(@"%@--%@--%@--%@--%@",slevCardTemp.photo,slevCardTemp.nickname,slevCardTemp.orgName,slevCardTemp.orgUnits,slevCardTemp.title);
    self.xmppvCardTemp = slevCardTemp;
    
    /** 因为 xmpp 内部不对 telecomsAddresses 解析，所以使用 note 字段代替 */
    self.teleNumber = slevCardTemp.note;
    /** 因为 xmpp 内部不对 emailAddresses 解析，所以使用 mailer 字段代替 */
    self.mailer = slevCardTemp.mailer;
    if (self.xmppvCardTemp.emailAddresses.count > 0) {
        
        self.mailer = self.xmppvCardTemp.emailAddresses[0];
    }


}



#pragma mark----xmppstream 代理
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"发送密码");
    if ([SLELoginTools shareTools].isRegisterOperation) {// 注册
        
        NSError *error = nil;
        [_xmppStream registerWithPassword:[SLELoginTools shareTools].registerPassWord error:&error];
        if (error) {
            
            NSLog(@"%@",error);
        }
    }else{// 登录
    
    
        [self sendPassWordToHostWithPassWord:self.myPassWord];
    }
}


#pragma mark----连接失败
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{


    SLELog(@"与主机连接失败 %@",error);
    
    if (!error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            

            [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:kLoginStatus];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[UIApplication sharedApplication].keyWindow setRootViewController:[SLELoginViewController setupLoginVC]];
        });
    }
    
    if (_resultBlock && error) {
        
        _resultBlock(SLEResultTypeNetError);
    }
}



#pragma mark---- 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{

    NSLog(@"注册成功");
    if (_resultBlock) {
        
        _resultBlock(SLEResultTypeSuccess);
    }

}


#pragma mark---- 注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{

    NSLog(@"%@",error);
    if (_resultBlock) {
        
        _resultBlock(SLEResultTypeFailure);
    }

}

#pragma mark----授权成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    
    NSLog(@"授权成功");
    [self sendOnlineMesseageToHost];
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:kLoginStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (_resultBlock) {
        
        _resultBlock(SLEResultTypeSuccess);
    }
    
}

#pragma mark----授权失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{

    NSLog(@"授权失败 %@",error);
    if (_resultBlock) {
        
        _resultBlock(SLEResultTypeFailure);
    }




}


#pragma mark----接收到数据就会来到方法
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{

    if (message.body == nil) {
        
        return;
    }
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        
        NSLog(@"在后台");
        UILocalNotification *localNoti = [[UILocalNotification alloc] init];
        localNoti.alertBody = [NSString stringWithFormat:@"%@\n%@",message.fromStr,message.body];
        localNoti.fireDate = [NSDate date];
        localNoti.soundName = @"default";
        [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
    }
    
}


#pragma mark----清楚数据
- (void)teardownXMPP
{

    [_xmppStream removeDelegate:self];
    [_xmppStream disconnect];
    
    [_xmppvCAModule deactivate];
    [_xmppAvatarModule deactivate];
    [_xmppReconnect deactivate];
    [_xmppRoster deactivate];
    [_xmppMessageArchiving deactivate];
    
    _xmppStream = nil;
    _xmppvCAModule = nil;
    _xmppReconnect = nil;
    _xmppvCDStorage = nil;
    _xmppAvatarModule = nil;
    _xmppRoster = nil;
    _xmppRosterStorage = nil;
    _xmppMessageArchiving = nil;
    _xmppMessageArVCoreDStorage = nil;

}

- (void)dealloc{

    [self teardownXMPP];
}

@end
