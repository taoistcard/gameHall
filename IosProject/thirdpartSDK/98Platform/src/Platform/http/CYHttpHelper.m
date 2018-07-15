//
//  CYHttpHelper.m
//  98Platform
//
//  Created by 张克敏 on 2013-4-27.
//  Copyright (c) 2013年 CY. All rights reserved.
//

#import "CYHttpHelper.h"
#import "CYHttpDefine.h"
#import "CYRuntimeData.h"
#import "CYConstants.h"

#import "GTMBase64.h"
#import "NSString+MD5Addition.h"

#import "ASIFormDataRequest.h"

#define CY_HTTP_PARAM_OS @"IOS"


@interface CYHttpHelper(Private)
+ (NSData *)getSignedPostBody:(NSDictionary *)param;
+ (void)appendClientParamForSign:(NSDictionary *)param;
+ (void)appendClientParam:(ASIFormDataRequest *)request;
+ (ASIFormDataRequest *)getHttpClient:(NSString *)url contextID:(NSInteger)contextID handler:(id)handler;
@end


@implementation CYHttpHelper

+ (NSData *)getSignedPostBody:(NSDictionary *)param
{
    // key sorted
    NSArray *keys = [[param allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *str1 = (NSString *)obj1;
        NSString *str2 = (NSString *)obj2;
        return [str1 compare:str2];
    }];
    
    NSMutableString *signBuffer = [NSMutableString string];
    NSMutableString *requestBuffer = [NSMutableString string];
    ASIFormDataRequest *formDataRequest = [ASIFormDataRequest requestWithURL:nil];
    
    // 1、组合键值对
    int length = [keys count];
    for (int i = 0; i < length ; i++) {
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [param objectForKey:key];
        NSString *encodedValue = [formDataRequest encodeURL:value];
        
        [signBuffer appendString:key];
        [signBuffer appendString:@"="];
        [signBuffer appendString:value];
        [signBuffer appendString:@"&"];
        
        [requestBuffer appendString:key];
        [requestBuffer appendString:@"="];
        [requestBuffer appendString:encodedValue];
        [requestBuffer appendString:@"&"];
    }
    //2、将appkey附件到待签名字符串后面
    [signBuffer appendString:@"appkey="];
    [signBuffer appendString:[CYRuntimeData shareRuntimeData].appKey];
    //3.生成待签名字符串的md5值
    NSString *sign = [signBuffer md5];
    //4、将签名字符串附加
    [requestBuffer appendString:@"sign="];
    [requestBuffer appendString:sign];
    //5、Base64 encode上一步得到的参数字符串，得到POST正文内容
    NSString *base64 = [GTMBase64 stringByEncodingData:[requestBuffer dataUsingEncoding:NSUTF8StringEncoding]];
    return [base64 dataUsingEncoding:NSUTF8StringEncoding];
}

+ (void)appendClientParamForSign:(NSDictionary *)param
{
    NSMutableDictionary *dict = (NSMutableDictionary *)param;
    CYRuntimeData *runtime = [CYRuntimeData shareRuntimeData];
    [dict setObject:runtime.appID forKey:@"appid"];
    [dict setObject:runtime.serverID forKey:@"serverid"];
    [dict setObject:runtime.appVersion forKey:@"ver"];
    [dict setObject:runtime.uuid forKey:@"uuid"];
    [dict setObject:runtime.appChannel forKey:@"source"];
    [dict setObject:runtime.model forKey:@"model"];
    [dict setObject:runtime.mac forKey:@"mac"];
    [dict setObject:[runtime getRequestTime] forKey:@"ts"];
    [dict setObject:CY_HTTP_PARAM_OS forKey:@"os"];
}

+ (void)appendClientParam:(ASIFormDataRequest *)request
{
    CYRuntimeData *runtime = [CYRuntimeData shareRuntimeData];
    [request addPostValue:runtime.appID forKey:@"appid"];
    [request addPostValue:runtime.serverID forKey:@"serverid"];
    [request addPostValue:runtime.appVersion forKey:@"ver"];
    [request addPostValue:runtime.uuid forKey:@"uuid"];
    [request addPostValue:runtime.appChannel forKey:@"source"];
    [request addPostValue:runtime.model forKey:@"model"];
    [request addPostValue:runtime.mac forKey:@"mac"];
    [request addPostValue:CY_HTTP_PARAM_OS forKey:@"os"];
}

+ (ASIFormDataRequest *)getHttpClient:(NSString *)url contextID:(NSInteger)contextID handler:(id)handler
{
    NSURL *nsurl = [NSURL URLWithString:url];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:nsurl];
    request.tag = contextID;
    request.delegate = handler;
    request.timeOutSeconds = 30;
    request.responseEncoding = NSUTF8StringEncoding;
    return request;
}

+ (ASIFormDataRequest *)getLoginClient:(NSString *)url contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [self getHttpClient:url contextID:contextID handler:handler];
    request.custormType = CY_REQUEST_LOGIN;
    return request;
}

+ (ASIFormDataRequest *)getDataClient:(NSString *)url contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [self getHttpClient:url contextID:contextID handler:handler];
    request.custormType = CY_REQUEST_DATA;
    return request;
}

+ (ASIFormDataRequest *)getCmdClient:(NSString *)url contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [self getHttpClient:url contextID:contextID handler:handler];
    request.custormType = CY_REQUEST_CMD;
    return request;
}

#pragma mark - request
#pragma mark sync
/**
 * 同步服务器时间戳
 */
+ (void)syncServerTime:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getHttpClient:CY_HTTP_SERVICE_SYNC_TIME contextID:contextID handler:handler];
    [request startAsynchronous];
}

/**
 * 同步服务器列表
 */
+ (void)syncServerList:(NSInteger)contextID handler:(id)handler sandbox:(BOOL)sandbox
{
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_SERVICE_SYNC_SERVERLIST contextID:contextID handler:handler];
    
    // 请求参数
    [request addPostValue:(sandbox ? @"1" : @"0") forKey:@"sandbox"];
    [CYHttpHelper appendClientParam:request];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 同步消息公告
 */
+ (void)syncMessage:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_SERVICE_SYNC_MESSAGE contextID:contextID handler:handler];
    
    // 请求参数
    [request addPostValue:@"0" forKey:@"msgtype"];
    [CYHttpHelper appendClientParam:request];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 同步在线配置
 */
+ (void)syncOnlineConfig:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_SERVICE_SYNC_ONLINECONFIG contextID:contextID handler:handler];
    NSString *osSubType = [CYRuntimeData shareRuntimeData].isHDVer ? @"pad" : @"phone";
    [request addPostValue:@"os_sub" forKey:osSubType];
    
    // 请求参数
    [CYHttpHelper appendClientParam:request];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 同步应用互推配置
 */
+ (void)syncAppRecommend:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_SERVICE_SYNC_APPRECOMMEND contextID:contextID handler:handler];
    
    // 请求参数
    [CYHttpHelper appendClientParam:request];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 检测程序升级
 */
+ (void)syncAppVersion:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_SERVICE_SYNC_APPVERSION contextID:contextID handler:handler];
    
    // 请求参数
    [CYHttpHelper appendClientParam:request];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 检测资源升级
 */
+ (void)syncAppResVersion:(NSInteger)contextID handler:(id)handler param:(NSDictionary *)param
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:nil];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_SERVICE_SYNC_APPRESVERSION contextID:contextID handler:handler];
    
    // 请求参数
    [request addPostValue:dataString forKey:@"data"];
    [CYHttpHelper appendClientParam:request];
    
    //开始执行
    [request startAsynchronous];
    
    [dataString release];
}

#pragma mark service
/**
 * 账号列表
 */
+ (void)requestAccountList:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_SERVICE_ACCOUNT_LIST contextID:contextID handler:handler];
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 登录请求
 */
+ (void)requestLogin:(NSString *)account password:(NSString *)password contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getLoginClient:CY_HTTP_SERVICE_ACCOUNT_LOGIN contextID:contextID handler:handler];
    request.password = password;
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  account, @"username",
                                  password, @"password",
                                  nil];
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 游客登录
 */
+ (void)requestGuestLogin:(NSString *)password contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getLoginClient:CY_HTTP_SERVICE_ACCOUNT_GUESTLOGIN contextID:contextID handler:handler];
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (password)
    {
        [param setObject:password forKey:@"password"];
    }
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 登录注册合并请求
 */
+ (void)requestLoginMerge:(NSString *)account passwod:(NSString *)password contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getLoginClient:CY_HTTP_SERVICE_ACCOUNT_LOGINMERGE contextID:contextID handler:handler];
    request.password = password;
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  account, @"username",
                                  password, @"password",
                                  nil];
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 手机注册，获取验证码:step1
 */
+ (void)requestPhoneRegSms:(NSString *)phone contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getCmdClient:CY_HTTP_SERVICE_ACCOUNT_PHONEREGSMS contextID:contextID handler:handler];
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:phone, @"phone", nil];
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 手机注册:step2
 */
+ (void)requestPhoneReg:(NSString *)phone code:(NSString *)code password:(NSString *)password contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getLoginClient:CY_HTTP_SERVICE_ACCOUNT_PHONEREG contextID:contextID handler:handler];
    request.password = password;
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  code, @"code",
                                  phone, @"username",
                                  password, @"password",
                                  nil];
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 找回密码，获取短信验证码:step1
 */
+ (void)requestFindpwdSms:(NSString *)phone contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getCmdClient:CY_HTTP_SERVICE_ACCOUNT_FINDPWDSMS contextID:contextID handler:handler];
    
    // 请求参数
    CYRuntimeData *runtime = [CYRuntimeData shareRuntimeData];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  phone, @"phone",
                                  runtime.appID, @"appid",
                                  [runtime getRequestTime], @"ts",
                                  nil];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 找回密码，修改密码:step2
 */
+ (void)requestFindpwd:(NSString *)phone code:(NSString *)code password:(NSString *)password contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getCmdClient:CY_HTTP_SERVICE_ACCOUNT_FINDPWD contextID:contextID handler:handler];
    
    // 请求参数
    CYRuntimeData *runtime = [CYRuntimeData shareRuntimeData];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  code, @"code",
                                  phone, @"phone",
                                  password, @"password",
                                  runtime.appID, @"appid",
                                  [runtime getRequestTime], @"ts",
                                  nil];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 邮箱找回密码
 */
+ (void)requestFindpwdEmail:(NSString *)email contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getCmdClient:CY_HTTP_SERVICE_ACCOUNT_FINDPWDEMAIL contextID:contextID handler:handler];
    
    // 请求参数
    CYRuntimeData *runtime = [CYRuntimeData shareRuntimeData];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  email, @"email",
                                  runtime.appID, @"appid",
                                  [runtime getRequestTime], @"ts",
                                  nil];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 绑定手机号，获取验证码:step1
 */
+ (void)requestBindphoneSms:(NSString *)phone sessionId:(NSString *)sessionId contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getCmdClient:CY_HTTP_SERVICE_ACCOUNT_BINDPHONESMS contextID:contextID handler:handler];
    
    // 请求参数
    CYRuntimeData *runtime = [CYRuntimeData shareRuntimeData];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  phone, @"phone",
                                  sessionId, @"sessionid",
                                  runtime.appID, @"appid",
                                  [runtime getRequestTime], @"ts",
                                  nil];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 绑定手机号:step2
 */
+ (void)requestBindPhone:(NSString *)code password:(NSString *)password sessionId:(NSString *)sessionId contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getCmdClient:CY_HTTP_SERVICE_ACCOUNT_BINDPHONE contextID:contextID handler:handler];
    request.password = password;
    
    if (password == nil)
    {
        password = @"";
    }
    // 请求参数
    CYRuntimeData *runtime = [CYRuntimeData shareRuntimeData];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  code, @"code",
                                  password, @"password",
                                  sessionId, @"sessionid",
                                  runtime.appID, @"appid",
                                  [runtime getRequestTime], @"ts",
                                  nil];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 发送修改密码
 */
+ (void)requestChangepwd:(NSString *)oldpwd newpwd:(NSString *)newpwd sessionId:(NSString *)sessionId contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getCmdClient:CY_HTTP_SERVICE_ACCOUNT_CHANGEPWDE contextID:contextID handler:handler];
    request.password = newpwd;
    
    // 请求参数
    CYRuntimeData *runtime = [CYRuntimeData shareRuntimeData];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  oldpwd, @"oldpwd",
                                  newpwd, @"newpwd",
                                  sessionId, @"sessionid",
                                  runtime.appID, @"appid",
                                  [runtime getRequestTime], @"ts",
                                  nil];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 老麻将系统登录请求
 */
+ (void)requestDuoleLogin:(NSString *)account password:(NSString *)password verify:(BOOL)verify contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getLoginClient:CY_HTTP_SERVICE_DUOLEACCOUNT_LOGIN contextID:contextID handler:handler];
    request.password = password;
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  account, @"username",
                                  password, @"password",
                                  verify ? @"1" : @"0", @"verify",
                                  nil];
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 提交激活码
 */
+ (void)requestSubmitActivationCode:(NSString *)code sessionId:(NSString *)sessionId contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getLoginClient:CY_HTTP_SERVICE_ACTIVATIONCODE_SUBMIT contextID:contextID handler:handler];
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  code, @"code",
                                  sessionId, @"sessionid",
                                  nil];
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

#pragma mark pay
/**
 * 苹果内购，获取套餐订单号
 */
+ (void)requestApplePayPackageOrderID:(NSString *)packageID productID:(NSString *)productID sessionID:(NSString *)sessionID contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getHttpClient:CY_HTTP_MOBILEPAY_APPLE_SUBMITP contextID:contextID handler:handler];
    
    // 请求参数
    if (packageID)
    {
        [request addPostValue:packageID forKey:@"packageid"];
    }
    [request addPostValue:productID forKey:@"productid"];
    [request addPostValue:sessionID forKey:@"sessionid"];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 苹果内购，获取订单号
 */
+ (void)requestApplePayOrderID:(NSString *)productID sessionID:(NSString *)sessionID contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getHttpClient:CY_HTTP_MOBILEPAY_APPLE_SUBMIT contextID:contextID handler:handler];
    
    // 请求参数
    [request addPostValue:productID forKey:@"productid"];
    [request addPostValue:sessionID forKey:@"sessionid"];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 苹果内购，验证订单
 */
+ (void)requestApplePayFinish:(NSString *)orderID receipt:(NSString *)receipt contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getHttpClient:CY_HTTP_MOBILEPAY_APPLE_FINISH contextID:contextID handler:handler];
    
    // 请求参数
    [request addPostValue:orderID forKey:@"orderid"];
    [request addPostValue:receipt forKey:@"receipt"];
    
    //开始执行
    [request startAsynchronous];
}

#pragma mark third sdk
/**
 * 快用，登录
 */
+ (void)requestKYLogin:(NSString *)token contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getLoginClient:CY_HTTP_SERVICE_KYACCOUNT_LOGIN contextID:contextID handler:handler];
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  token, @"token",
                                  nil];
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 快用，获取订单
 */
+ (void)requestKYPayOrderID:(NSInteger)fee packageID:(NSInteger)packageID sessionID:(NSString *)sessionID  contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_MOBILEPAY_KY_SUBMIT contextID:contextID handler:handler];
    
    // 请求参数
    [request addPostValue:[NSString stringWithFormat:@"%d", fee] forKey:@"fee"];
    [request addPostValue:sessionID forKey:@"sessionid"];
    if (packageID > 0)
    {
        [request addPostValue:[NSString stringWithFormat:@"%d", packageID] forKey:@"packageid"];
    }
    
    //开始执行
    [request startAsynchronous];
}

/**
 * QQ登录
 */
+ (void)requestQQLogin:(NSString *)token openID:(NSString *)openID contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getLoginClient:CY_HTTP_SERVICE_QQ_LOGIN contextID:contextID handler:handler];
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  openID, @"openid",
                                  token, @"token",
                                  nil];
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}
/**
 * 爱思登录
 */
+ (void)requestAiSiLogin:(NSString *)token contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getLoginClient:CY_HTTP_SERVICE_AISI_LOGIN contextID:contextID handler:handler];
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  token, @"I4_token",
                                  nil];
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 爱思，获取订单
 */
+ (void)requestAiSiPayOrderID:(NSInteger)packageID sessionID:(NSString *)sessionID  contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_MOBILEPAY_AISI_SUBMIT contextID:contextID handler:handler];
    
    // 请求参数
    [request addPostValue:sessionID forKey:@"sessionid"];
    if (packageID > 0)
    {
        [request addPostValue:[NSString stringWithFormat:@"%d", packageID] forKey:@"packageid"];
    }
    
    //开始执行
    [request startAsynchronous];
}

+ (void)requestiToolsLogin:(NSString *)session contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getLoginClient:CY_HTTP_SERVICE_ITOOLS_LOGIN contextID:contextID handler:handler];
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  session, @"itools_session",
                                  nil];
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * iTools，获取订单
 */
+ (void)requestIToolsPayOrderID:(NSInteger)packageID sessionID:(NSString *)sessionID  contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_MOBILEPAY_ITOOLS_SUBMIT contextID:contextID handler:handler];
    
    // 请求参数
    [request addPostValue:sessionID forKey:@"sessionid"];
    if (packageID > 0)
    {
        [request addPostValue:[NSString stringWithFormat:@"%d", packageID] forKey:@"packageid"];
    }
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 刷脸登录
 */
+ (void)requestFaceVisaLogin:(NSString *)token contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getLoginClient:CY_HTTP_SERVICE_FACEVISA_LOGIN contextID:contextID handler:handler];
    
    // 请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  token, @"facevisa_token",
                                  nil];
    [CYHttpHelper appendClientParamForSign:param];
    
    // 签名
    NSData *data = [CYHttpHelper getSignedPostBody:param];
    [request appendPostData:data];
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 刷脸获取订单
 */
+ (void)requestFaceVisaPayOrderID:(NSInteger)packageID sessionID:(NSString *)sessionID  contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_MOBILEPAY_FACEVISA_SUBMIT contextID:contextID handler:handler];
    
    // 请求参数
    [request addPostValue:sessionID forKey:@"sessionid"];
    if (packageID > 0)
    {
        [request addPostValue:[NSString stringWithFormat:@"%ld", (long)packageID] forKey:@"packageid"];
    }
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 微信，获取订单
 */
+ (void)requestWeiXinPayOrderID:(NSInteger)packageID sessionID:(NSString *)sessionID  contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_MOBILEPAY_WEIXIN_SUBMIT contextID:contextID handler:handler];
    
    // 请求参数
    [request addPostValue:sessionID forKey:@"sessionid"];
    if (packageID > 0)
    {
        [request addPostValue:[NSString stringWithFormat:@"%d", packageID] forKey:@"packageid"];
    }
    
    //开始执行
    [request startAsynchronous];
}

/**
 * 支付宝，获取订单
 */
+ (void)requestAliPayOrderID:(NSInteger)packageID sessionID:(NSString *)sessionID  contextID:(NSInteger)contextID handler:(id)handler
{
    ASIFormDataRequest *request = [CYHttpHelper getDataClient:CY_HTTP_MOBILEPAY_ALIPAY_SUBMIT contextID:contextID handler:handler];
    
    // 请求参数
    [request addPostValue:sessionID forKey:@"sessionid"];
    if (packageID > 0)
    {
        [request addPostValue:[NSString stringWithFormat:@"%d", packageID] forKey:@"packageid"];
    }
    
    //开始执行
    [request startAsynchronous];
}

@end
