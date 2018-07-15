//
//  CYHttpHelper.h
//  CYFramework
//
//  Created by 张克敏 on 2013-04-27.
//  Copyright (c) 2013年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CY_CONTEXTID_SYNCTIME             1
#define CY_CONTEXTID_LOGIN                2
#define CY_CONTEXTID_LOGIN_GUEST          3
#define CY_CONTEXTID_LOGIN_3SDK           4
#define CY_CONTEXTID_LOGIN_WEBVIEW        5
#define CY_CONTEXTID_LOGIN_MERGER         6
#define CY_CONTEXTID_PHONE_REG_SMS        7
#define CY_CONTEXTID_PHONE_REG            8
#define CY_CONTEXTID_CHANGE_PWD           9
#define CY_CONTEXTID_BIND_PHONE_SMS       10
#define CY_CONTEXTID_BIND_PHONE           11
#define CY_CONTEXTID_FIND_PWD_SMS         12
#define CY_CONTEXTID_FIND_PWD             13
#define CY_CONTEXTID_FIND_PWD_EMAIL       14
#define CY_CONTEXTID_DATA_SERVERLIST      15
#define CY_CONTEXTID_DATA_ACCOUNTLIST     16
#define CY_CONTEXTID_DATA_GETORDERID      17
#define CY_CONTEXTID_DATA_MESSAGE         18
#define CY_CONTEXTID_DATA_ONLINECONFIG    19
#define CY_CONTEXTID_DATA_APPRECOMMEND    20
#define CY_CONTEXTID_DATA_APPVERSION      21
#define CY_CONTEXTID_DATA_APPRESVERSION   22
#define CY_CONTEXTID_LOGIN_DUOLE          23
#define CY_CONTEXTID_ACTIVATION_SUBMIT    24

// Custom ContextID
#define CY_CONTEXTID_APPLE_FINISH         10000
#define CY_CONTEXTID_APPLE_RESTORE        10001

@interface CYHttpHelper : NSObject

#pragma mark - sync
/**
 * 同步服务器时间戳
 */
+ (void)syncServerTime:(NSInteger)contextID handler:(id)handler;
/**
 * 同步服务器列表
 */
+ (void)syncServerList:(NSInteger)contextID handler:(id)handler sandbox:(BOOL)sandbox;
/**
 * 同步消息公告
 */
+ (void)syncMessage:(NSInteger)contextID handler:(id)handler;
/**
 * 同步在线配置
 */
+ (void)syncOnlineConfig:(NSInteger)contextID handler:(id)handler;
/**
 * 同步应用互推配置
 */
+ (void)syncAppRecommend:(NSInteger)contextID handler:(id)handler;
/**
 * 检测程序升级
 */
+ (void)syncAppVersion:(NSInteger)contextID handler:(id)handler;
/**
 * 检测资源升级
 */
+ (void)syncAppResVersion:(NSInteger)contextID handler:(id)handler param:(NSDictionary *)param;

#pragma mark - service
/**
 * 账号列表
 */
+ (void)requestAccountList:(NSInteger)contextID handler:(id)handler;
/**
 * 登录请求
 */
+ (void)requestLogin:(NSString *)account password:(NSString *)password contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 游客登录
 */
+ (void)requestGuestLogin:(NSString *)password contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 登录注册合并请求
 */
+ (void)requestLoginMerge:(NSString *)account passwod:(NSString *)password contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 手机注册，获取验证码:step1
 */
+ (void)requestPhoneRegSms:(NSString *)phone contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 手机注册:step2
 */
+ (void)requestPhoneReg:(NSString *)phone code:(NSString *)code password:(NSString *)password contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 找回密码，获取短信验证码:step1
 */
+ (void)requestFindpwdSms:(NSString *)phone contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 找回密码，修改密码:step2
 */
+ (void)requestFindpwd:(NSString *)phone code:(NSString *)code password:(NSString *)password contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 邮箱找回密码
 */
+ (void)requestFindpwdEmail:(NSString *)email contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 绑定手机号，获取验证码:step1
 */
+ (void)requestBindphoneSms:(NSString *)phone sessionId:(NSString *)sessionId contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 绑定手机号:step2
 */
+ (void)requestBindPhone:(NSString *)code password:(NSString *)password sessionId:(NSString *)sessionId contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 发送修改密码
 */
+ (void)requestChangepwd:(NSString *)oldpwd newpwd:(NSString *)newpwd sessionId:(NSString *)sessionId contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 老麻将系统登录请求
 */
+ (void)requestDuoleLogin:(NSString *)account password:(NSString *)password verify:(BOOL)verify contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 提交激活码
 */
+ (void)requestSubmitActivationCode:(NSString *)code sessionId:(NSString *)sessionId contextID:(NSInteger)contextID handler:(id)handler;

#pragma mark - pay
/**
 * 苹果内购，获取套餐订单号
 */
+ (void)requestApplePayPackageOrderID:(NSString *)packageID productID:(NSString *)productID sessionID:(NSString *)sessionID contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 苹果内购，获取订单号
 */
+ (void)requestApplePayOrderID:(NSString *)productID sessionID:(NSString *)sessionID contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 苹果内购，验证订单
 */
+ (void)requestApplePayFinish:(NSString *)orderID receipt:(NSString *)receipt contextID:(NSInteger)contextID handler:(id)handler;

#pragma mark - third sdk
/**
 * 快用，登录
 */
+ (void)requestKYLogin:(NSString *)token contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 快用，获取订单
 */
+ (void)requestKYPayOrderID:(NSInteger)fee packageID:(NSInteger)packageID sessionID:(NSString *)sessionID  contextID:(NSInteger)contextID handler:(id)handler;
/**
 * QQ登录
 */
+ (void)requestQQLogin:(NSString *)token openID:(NSString *)openID contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 爱思登录
 */
+ (void)requestAiSiLogin:(NSString *)token contextID:(NSInteger)contextID handler:(id)handler;
/**
 * 爱思请求订单号
 */
+ (void)requestAiSiPayOrderID:(NSInteger)packageID sessionID:(NSString *)sessionID  contextID:(NSInteger)contextID handler:(id)handler;
/**
 * iTools登录
 */
+ (void)requestiToolsLogin:(NSString *)session contextID:(NSInteger)contextID handler:(id)handler;

/**
 * iTools请求订单号
 */
+ (void)requestIToolsPayOrderID:(NSInteger)packageID sessionID:(NSString *)sessionID  contextID:(NSInteger)contextID handler:(id)handler;

/**
 * FaceVisa登录
 */
+ (void)requestFaceVisaLogin:(NSString *)token contextID:(NSInteger)contextID handler:(id)handler;
/**
 * FaceVisa请求订单号
 */
+ (void)requestFaceVisaPayOrderID:(NSInteger)packageID sessionID:(NSString *)sessionID  contextID:(NSInteger)contextID handler:(id)handler;

/**
 * 微信，获取订单
 */
+ (void)requestWeiXinPayOrderID:(NSInteger)packageID sessionID:(NSString *)sessionID  contextID:(NSInteger)contextID handler:(id)handler;

/**
 * 支付宝，获取订单
 */
+ (void)requestAliPayOrderID:(NSInteger)packageID sessionID:(NSString *)sessionID  contextID:(NSInteger)contextID handler:(id)handler;

@end
