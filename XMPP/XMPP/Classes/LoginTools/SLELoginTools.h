//
//  SLELoginTools.h
//  XMPP
//
//  Created by mzyw on 16/10/21.
//  Copyright © 2016年 宋帅超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

#import "XMPPvCardTemp.h"
//#import "XMPPRoster.h"

typedef enum  {
    
    SLEResultTypeSuccess,
    SLEResultTypeFailure,
    SLEResultTypeNetError
} SLEResultType;


typedef void (^SLEResultBlock)(SLEResultType resultType);


@interface SLELoginTools : NSObject

// 本地缓存
@property (nonatomic, strong) NSUserDefaults *localDefaults;
// 用户名
@property (nonatomic, copy) NSString *userName;
// 密码
@property (nonatomic, copy) NSString *passWord;

/******************************************************************/
// 注册用户名
@property (nonatomic, copy) NSString *registerUserName;
// 注册密码
@property (nonatomic, copy) NSString *registerPassWord;
// 传进来的密码
@property (nonatomic, copy) NSString *myPassWord;


// jid
@property (nonatomic, copy) NSString *currentJid ;

/******************************************************************/
// 电子名片
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCAModule;
// 朋友列表
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage * xmppRosterStorage;;

// 花名册
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;


// 
@property (nonatomic, strong) XMPPvCardTemp *xmppvCardTemp;


// xmpp 流
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;

// 聊天模块
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *xmppMessageArVCoreDStorage;

/******************************************************************/
// 缓存数据
// 昵称
@property (nonatomic, copy) NSString *nickName;
// 头像
@property (nonatomic, strong) NSData *photo;
// 公司
@property (nonatomic, copy) NSString *orgName;
// 部门
@property (nonatomic, strong) NSArray *orgUnits;
// 职位
@property (nonatomic, copy) NSString *title;
// 电话
@property (nonatomic, copy) NSString *teleNumber;
// 邮箱
@property (nonatomic, copy) NSString *mailer;


/******************************************************************/
// 登录状态  1：表示未注销  0：表示注销
@property (nonatomic, copy) NSString *loginStatus;

// 登录/注册标示  YES:注册 / NO：登录
@property (nonatomic, assign, getter=isRegisterOperation) BOOL registerOperation;



/******************************************************************/
/** 登录 */
- (void)loginWithUserName:(NSString *)userName passWord:(NSString *)passWord loginResult:(SLEResultBlock)resultBlock;

/** 注销 */
- (void)logout;

- (void)registerUserWithRegistResult:(SLEResultBlock)resultBlock;


+ (instancetype)shareTools;
- (void)saveData;
@end
