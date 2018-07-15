//
//  CYPlatform.m
//  98Platform
//
//  Created by 张克敏 on 13-4-26.
//  Copyright (c) 2013年 CY. All rights reserved.
//

#import "CYPlatform.h"
#import "CYConstants.h"
#import "CYHttpHelper.h"
#import "CYHttpDefine.h"
#import "CYRuntimeData.h"
#import "CYAccountBusiness.h"
#import "CYTextUtil.h"
#import "CYDataHandler.h"
#import "CYImageManager.h"
#import "CYWebview.h"

#import "NSString+MD5Addition.h"
#import "OpenUDIDManager.h"

#import <UIKit/UIPasteboard.h>

#define CY_CLIENT_BESPOKE_UC      @"uc"
#define CY_CLIENT_BESPOKE_KY      @"ky"
#define CY_CLIENT_BESPOKE_XIAOMI  @"xiaomi"


@interface CYPlatform ()
{
    BOOL                        _logedin;
    BOOL                        _saveAccount;
    
    CYImageManager*             _imageManager;
    id<CYLoginProcessDelegate>  _loginTempDelegate;
}
@end


CYPlatform *g_CYPlatform = nil;

@implementation CYPlatform
@synthesize loginProcessDelegate = _loginProcessDelegate;
@synthesize dataConfigureDelegate = _dataConfigureDelegate;
@synthesize commandDelegate = _commandDelegate;
@synthesize customAvatarDelegate = _customAvatarDelegate;
@synthesize guestLogin = _guestLogin;
@synthesize userInfo = _userInfo;
@synthesize sessionID = _sessionID;
@synthesize accountList = _accountList;
@synthesize onlineConfig = _onlineConfig;

- (id)init
{
    self = [super init];
    if (self)
    {
        _imageManager = [[CYImageManager alloc] init];
    }
    return self;
}

- (void)dealloc
{
    _loginProcessDelegate = nil;
    _dataConfigureDelegate = nil;
    _commandDelegate = nil;
    _customAvatarDelegate = nil;
    
    [_userInfo release];
    [_sessionID release];
    [_accountList release];
    [_onlineConfig release];
    [_imageManager release];
    
    [super dealloc];
}

#pragma mark - private
- (void)saveGuestPassword
{
    if (!_userInfo.isGuestAccount || [CYTextUtil isEmpty:_userInfo.encryptPassword])
    {
        return;
    }
    NSData *data = [_userInfo.encryptPassword dataUsingEncoding:NSUTF8StringEncoding];
    UIPasteboard *board = [UIPasteboard pasteboardWithName:@"cn._98game.platform.pb.normal" create:YES];
    [board setData:data forPasteboardType:@"data"];
    [board setPersistent:YES];
}

- (NSString *)getSavedGuestPassword
{
    UIPasteboard *board = [UIPasteboard pasteboardWithName:@"cn._98game.platform.pb.normal" create:NO];
    if (board)
    {
        NSData *data = [board dataForPasteboardType:@"data"];
        if (data && [data length] > 0)
        {
            NSString *password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return [CYRuntimeData decrypt:password];
        }
    }
    return nil;
}

/**
 * 登录成功后解析用户信息
 */
- (void)setLoginUserInfoData:(CYDataHandler *)dataHandler save:(BOOL)save password:(NSString *)password
{
    NSString *sessionID = [dataHandler stringForKey:@"sessionID"];
    CYUserInfo *userInfo = [CYUserInfo decode:[dataHandler objectForKey:@"user"]];
    if ([CYTextUtil isEmpty:sessionID] || userInfo == nil)
    {
        return;
    }
    
    _sessionID = [[NSString alloc] initWithString:sessionID];
    _userInfo = [userInfo retain];
    _logedin = YES;
    
    // 游客账号的密码保存至剪切板里
    [self saveGuestPassword];
    
    if (!save)
    {
        return;
    }
    
    // 普通登录，注册时的密码
    if (![CYTextUtil isEmpty:password])
    {
        _userInfo.encryptPassword = [CYRuntimeData encrypt:password];
    }
    [self updateAccountList];
}

- (void)updateAccountList
{
    CYAccountBean *account = [self findAccountByUserID:_userInfo.userID];
    if (account)
    {
        [_accountList removeObject:account];
    }
    CYAccountBean *newAccount = [CYAccountBean creatWithUserInfo:_userInfo];
    [_accountList insertObject:newAccount atIndex:0];
    if ([_accountList count] > CY_ACCOUNT_LIMIT)
    {
        [_accountList removeLastObject];
    }
    
    // 更新到数据库
    CYAccountBusiness *db = [[CYAccountBusiness alloc] init];
    [db mergeAccount:newAccount];
    [db release];
}

/**
 * 同步账号列表
 */
- (void)setAccountListData:(NSArray *)data
{
    if (!data || [data count] == 0)
    {
        return;
    }
    [_accountList removeAllObjects];
    
    for (NSDictionary *obj in data)
    {
        if (!obj || [obj count] == 0)
        {
            continue;
        }
        id idUserID = [obj objectForKey:@"UserID"];
        id idUserName = [obj objectForKey:@"UserName"];
        if ([idUserID isKindOfClass:[NSNumber class]] && [idUserName isKindOfClass:[NSString class]])
        {
            id idNickName = [obj objectForKey:@"NickName"];
            id idAvatar = [obj objectForKey:@"Avatar"];
            NSInteger userID = [(NSNumber *)idUserID integerValue];
            NSString *userName = (NSString *)idUserName;
            NSString *nickName = ([idNickName isKindOfClass:[NSString class]]) ? (NSString *)idNickName : nil;
            NSString *avatar = ([idAvatar isKindOfClass:[NSString class]]) ? (NSString *)idAvatar : nil;
            CYAccountBean *account = [CYAccountBean creatWithUserID:userID userName:userName nickName:nickName password:nil avatar:avatar];
            [_accountList addObject:account];
        }
        else
        {
            continue;
        }
    }
    
    CYAccountBusiness *db = [[CYAccountBusiness alloc] init];
    [db syncAccountList:_accountList];
    [db release];
}

- (void)updateLoginedUserPassword:(NSString *)password
{
    if ([CYTextUtil isEmpty:password])
    {
        return;
    }
    password = [CYRuntimeData encrypt:password];
    [_userInfo setEncryptPassword:password];
    [self saveGuestPassword];
    
    CYAccountBusiness *business = [[CYAccountBusiness alloc] init];
    [business updatePassword:password userName:_userInfo.userName];
    [business release];
}

- (void)updateOnlineConfig:(CYDataHandler *)dataHandler
{
    NSDictionary *data = [dataHandler dataObject];
    if (!data || [data count] == 0)
    {
        return;
    }
    
    if (!_onlineConfig)
    {
        _onlineConfig = [[CYOnlineConfig alloc] initWithJson:data];
    }
    else
    {
        _onlineConfig.data = data;
    }
    
    // 存盘
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:CY_ONLINECONFIG_FILE];
    [userDefaults synchronize];
}

- (CYAccountBean *)findAccountByUserID:(NSInteger)userID
{
    for (CYAccountBean *bean in _accountList)
    {
        if (bean.userID == userID)
        {
            return bean;
        }
    }
    return nil;
}

- (BOOL)checkLoginStatus
{
    if (_logedin)
    {
        return YES;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [alert release];
    return NO;
}

#pragma mark - api
/**
 * 获取CYPlatform的实例对象
 */
+ (CYPlatform *)sharePlatform
{
    if (g_CYPlatform == nil)
    {
        g_CYPlatform = [[CYPlatform alloc] init];
    }
    return g_CYPlatform;
}

/**
 * 初始化平台
 */
- (void)initPlatformWithItuesPruchaseProducts:(NSArray *)products
{
    _logedin = NO;
    _saveAccount = YES;
    
    // 初始化运行时数据
    [[CYRuntimeData shareRuntimeData] initData];
    
    // 载入存盘的账号列表
    CYAccountBusiness *business = [[CYAccountBusiness alloc] init];
    NSArray *array = [business getAccountList];
    if (array && [array count] > 0)
    {
        _accountList = [[NSMutableArray alloc] initWithArray:array];
    }
    else
    {
        _accountList = [[NSMutableArray alloc] initWithCapacity:CY_ACCOUNT_LIMIT];
    }
    [business release];
    
    // 载入存盘的在线配置
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    id data = [userDefault objectForKey:CY_ONLINECONFIG_FILE];
    if ([data isKindOfClass:[NSDictionary class]])
    {
        _onlineConfig = [[CYOnlineConfig alloc] initWithJson:data];
    }
    
    // 下载平台内购项
    [[CYItunesInAppPurchase shareItunesInAppPurchase] downloadProductsWithArray:products];
    
    // 同步服务器时间
    [CYHttpHelper syncServerTime:CY_CONTEXTID_SYNCTIME handler:self];
}

- (void)initPlatformWithItuesPruchaseProducts:(NSArray *)products appID:(NSString *)appID appKey:(NSString *)appKey serverID:(NSString *)serverID channel:(NSString *)channel
{
    _logedin = NO;
    _saveAccount = YES;
    
    // 初始化运行时数据
    [[CYRuntimeData shareRuntimeData] initData:appID appKey:appKey serverID:serverID channel:channel];
    
    // 载入存盘的账号列表
    CYAccountBusiness *business = [[CYAccountBusiness alloc] init];
    NSArray *array = [business getAccountList];
    if (array && [array count] > 0)
    {
        _accountList = [[NSMutableArray alloc] initWithArray:array];
    }
    else
    {
        _accountList = [[NSMutableArray alloc] initWithCapacity:CY_ACCOUNT_LIMIT];
    }
    [business release];
    
    // 载入存盘的在线配置
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    id data = [userDefault objectForKey:CY_ONLINECONFIG_FILE];
    if ([data isKindOfClass:[NSDictionary class]])
    {
        _onlineConfig = [[CYOnlineConfig alloc] initWithJson:data];
    }
    
    // 下载平台内购项
    [[CYItunesInAppPurchase shareItunesInAppPurchase] downloadProductsWithArray:products];
    
    // 同步服务器时间
    [CYHttpHelper syncServerTime:CY_CONTEXTID_SYNCTIME handler:self];
}
    
/**
 * 平台唤醒
 */
- (void)onResume
{
    // 检查充值漏单
//    [[CYItunesInAppPurchase shareItunesInAppPurchase] checkRestorePurchase];
}

/**
 * 设置为HD版本
 */
- (void)setHDVersion:(BOOL)isHD
{
    [[CYRuntimeData shareRuntimeData] setHDVersion:isHD];
}

/**
 * 获取应用版本号
 */
- (NSString *)getAppVersion
{
    return [CYRuntimeData shareRuntimeData].appVersion;
}

/**
 * 获取渠道号
 */
- (NSString *)getAppChannel
{
    return [CYRuntimeData shareRuntimeData].appChannel;
}

/**
 * 切换服务器，这样可能会导致重登录，请慎用
 */
- (void)switchServer:(NSInteger)serverId
{
    [[CYRuntimeData shareRuntimeData] switchServer:serverId];
}

#pragma mark - sync
/**
 * 同步服务器列表
 */
- (void)syncServerList:(BOOL)sandbox
{
    [CYHttpHelper syncServerList:CY_CONTEXTID_DATA_SERVERLIST handler:self sandbox:sandbox];
}

/**
 * 请求数据配置
 */
- (void)syncDataConfig:(NSInteger)dataType
{
    [self syncDataConfig:dataType param:nil];
}

/**
 * 请求数据配置
 */
- (void)syncDataConfig:(NSInteger)dataType param:(NSDictionary *)param
{
    switch (dataType)
    {
        case CY_DATA_ACCOUNT_LIST:// 账号列表
            if ([_accountList count] == 0)
            {
                [CYHttpHelper requestAccountList:CY_CONTEXTID_DATA_ACCOUNTLIST handler:self];
            }
        case CY_DATA_VERSION_UPDATE:// 程序升级
            [CYHttpHelper syncAppVersion:CY_CONTEXTID_DATA_APPVERSION handler:self];
            break;
        case CY_DATA_SERVERLIST:// 服务器列表
            //@see syncServerList:(BOOL)sandbox
            break;
        case CY_DATA_ONLINE_CONFIG:// 在线参数
            [CYHttpHelper syncOnlineConfig:CY_CONTEXTID_DATA_ONLINECONFIG handler:self];
            break;
        case CY_DATA_APP_LIST:// 应用推荐
            [CYHttpHelper syncAppRecommend:CY_CONTEXTID_DATA_APPRECOMMEND handler:self];
            break;
        case CY_DATA_MESSAGE:// 消息公告
            [CYHttpHelper syncMessage:CY_CONTEXTID_DATA_MESSAGE handler:self];
            break;
        case CY_DATA_PAY_ORDERID:// 支付订单号
            //@see getPayOrderID:(NSInteger)sdkType params:(NSDictionary *)params
            break;
        case CY_DATA_RES_VERSION:// 资源版本升级
            if (!param || [param count] == 0)
            {
                return;
            }
            [CYHttpHelper syncAppResVersion:CY_CONTEXTID_DATA_APPRESVERSION handler:self param:param];
            break;
    }
}

/**
 * 检查应用版本升级
 */
- (void)checkVersionUpdate
{
    [self syncDataConfig:CY_CONTEXTID_DATA_APPVERSION];
}

#pragma mark - login & register
/**
 * 当前账号重登录
 */
- (BOOL)loginWithUserInfo
{
    if (_logedin && _userInfo && ![CYTextUtil isEmpty:_userInfo.encryptPassword])
    {
        NSString *account = _userInfo.userName;
        NSString *password = [_userInfo getPassword];
        if ([CYTextUtil isEmpty:account] || [CYTextUtil isEmpty:password])
        {
            return NO;
        }
        [CYHttpHelper requestLoginMerge:account passwod:password contextID:CY_CONTEXTID_LOGIN_MERGER handler:self];
        return YES;
    }
    return NO;
}

/**
 * 登录注册合并请求
 *
 * @param account 用户名
 * @param password 密码(明文)
 */
- (BOOL)loginWithAccount:(NSString *)account password:(NSString *)password
{
    if ([CYTextUtil isEmpty:account] || [CYTextUtil isEmpty:password])
    {
        return NO;
    }
    [CYHttpHelper requestLoginMerge:account passwod:password contextID:CY_CONTEXTID_LOGIN_MERGER handler:self];
    return YES;
}

/**
 * 根据账号索引登录
 */
- (BOOL)loginWithUserID:(NSInteger)userID
{
    CYAccountBean *find = [self findAccountByUserID:userID];
    if (!find || [CYTextUtil isEmpty:find.userName] || [CYTextUtil isEmpty:find.password])
    {
        return NO;
    }
    NSString *password = [CYRuntimeData decrypt:find.password];
    [CYHttpHelper requestLogin:find.userName password:password contextID:CY_CONTEXTID_LOGIN handler:self];
    return YES;
}

/**
 * 根据账号索引登录，没有密码的情况
 */
- (BOOL)loginWithUserID:(NSInteger)userID password:(NSString *)password
{
    if ([CYTextUtil isEmpty:password])
    {
        return NO;
    }
    CYAccountBean *find = [self findAccountByUserID:userID];
    if (!find || [CYTextUtil isEmpty:find.userName])
    {
        return NO;
    }
    [CYHttpHelper requestLogin:find.userName password:password contextID:CY_CONTEXTID_LOGIN handler:self];
    return NO;
}

/**
 * 游客登录
 */
- (BOOL)guestLogin
{
    if (_guestLogin)
    {
        NSString *password = [self getSavedGuestPassword];
        [CYHttpHelper requestGuestLogin:password contextID:CY_CONTEXTID_LOGIN_GUEST handler:self];
        return YES;
    }
    return NO;
}

/**
 * 自动登录模式，根据上次登录成功的账号自动登录，可支持游客登录
 *
 * @param guestLogin true-支持游客登录，false-不支持游客登录
 */
- (BOOL)autoLogin:(BOOL)guestLogin
{
    _guestLogin = guestLogin;
    
    if ([_accountList count] > 0)
    {
        // 自动登录
        CYAccountBean *bean = [_accountList firstObject];
        if (!bean || [CYTextUtil isEmpty:bean.userName] || [CYTextUtil isEmpty:bean.password])
        {
            return NO;
        }
        NSString *password = [CYRuntimeData decrypt:bean.password];
        [CYHttpHelper requestLogin:bean.userName password:password contextID:CY_CONTEXTID_LOGIN handler:self];
        return YES;
    }
    else
    {
        // 游客登录
        return [self guestLogin];
    }
    return NO;
}

/**
 * 第三方渠道SDK登录
 */
- (void)thirdSdkLogin:(NSInteger)sdkType params:(NSDictionary *)params
{
    if (!params || [params count] == 0)
    {
        return;
    }
    _saveAccount = NO;
    NSInteger contextID = CY_CONTEXTID_LOGIN_3SDK;
    switch (sdkType)
    {
        case CY_SDK_KY:// 快用
        {
            NSString *token = [params objectForKey:CY_PARAM_TOKEN];
            [CYHttpHelper requestKYLogin:token contextID:contextID handler:self];
            break;
        }
        case CY_SDK_QQ:// QQ
        {
            NSString *token = [params objectForKey:CY_PARAM_TOKEN];
            NSString *openID = [params objectForKey:CY_PARAM_OPENID];
            [CYHttpHelper requestQQLogin:token openID:openID contextID:contextID handler:self];
            break;
        }
        case CY_SDK_AiSi:// aisi
        {
            NSString *token = [params objectForKey:CY_PARAM_TOKEN];
            [CYHttpHelper requestAiSiLogin:token contextID:contextID handler:self];
            break;
        }
        case CY_SDK_ITOOLS:// itools
        {
            NSString *token = [params objectForKey:CY_PARAM_SESSION];
            [CYHttpHelper requestAiSiLogin:token contextID:contextID handler:self];
            break;
        }
        case CY_SDK_FACEVISA:
        {
            NSString *token = [params objectForKey:CY_PARAM_TOKEN];
            [CYHttpHelper requestFaceVisaLogin:token contextID:contextID handler:self];
            break;
        }
        default:
            break;
    }
}

/**
 * 内部WebView登录用，接入时请无视
 */
- (void)loginWebview:(id<CYLoginProcessDelegate>)delegate
{
    _loginTempDelegate = delegate;
    NSString *account = _userInfo.userName;
    NSString *password = [_userInfo getPassword];
    [CYHttpHelper requestLogin:account password:password contextID:CY_CONTEXTID_LOGIN_WEBVIEW handler:self];
}

/**
 * 老麻将系统账号登录
 *
 * @param account 用户名
 * @param password 密码(明文)
 * @param verify 是否直接验证
 */
- (void)duoleLogin:(NSString *)account password:(NSString *)password verify:(BOOL)verify
{
    if ([CYTextUtil isEmpty:account] || [CYTextUtil isEmpty:password])
    {
        return;
    }
    [CYHttpHelper requestDuoleLogin:account password:password verify:verify contextID:CY_CONTEXTID_LOGIN_DUOLE handler:self];
}

/**
 * 手机注册
 */
- (void)phoneReg:(NSString *)phone authCode:(NSString *) authCode password:(NSString *)password
{
    if ([CYTextUtil isEmpty:phone] || [CYTextUtil isEmpty:authCode] || [CYTextUtil isEmpty:password])
    {
        return;
    }
    [CYHttpHelper requestPhoneReg:phone code:authCode password:password contextID:CY_CONTEXTID_PHONE_REG handler:self];
}

#pragma mark - service
/**
 * 指令类请求
 */
- (void)submitCommand:(NSInteger)cmdType param:(NSDictionary *)param
{
    if (!param || [param count] == 0)
    {
        return;
    }
    switch (cmdType) {
        case CY_CMD_BIND_PHONE_SMS:// 绑定手机号:
            if ([self checkLoginStatus])
            {
                NSString *phone = [param objectForKey:CY_PARAM_PHONE];
                [CYHttpHelper requestBindphoneSms:phone sessionId:_sessionID contextID:CY_CONTEXTID_BIND_PHONE_SMS handler:self];
            }
            break;
        case CY_CMD_BIND_PHONE://
            if ([self checkLoginStatus])
            {
                NSString *code = [param objectForKey:CY_PARAM_CODE];
                NSString *password = [param objectForKey:CY_PARAM_PASSWORD];
                [CYHttpHelper requestBindPhone:code password:password sessionId:_sessionID contextID:CY_CONTEXTID_BIND_PHONE handler:self];
            }
            break;
        case CY_CMD_FIND_PWD_SMS:// 找回密码
            {
                NSString *phone = [param objectForKey:CY_PARAM_PHONE];
                [CYHttpHelper requestFindpwdSms:phone contextID:CY_CONTEXTID_FIND_PWD_SMS handler:self];
            }
            break;
        case CY_CMD_FIND_PWD:
            {
                NSString *code = [param objectForKey:CY_PARAM_CODE];
                NSString *phone = [param objectForKey:CY_PARAM_PHONE];
                NSString *password = [param objectForKey:CY_PARAM_PASSWORD];
                [CYHttpHelper requestFindpwd:phone code:code password:password contextID:CY_CONTEXTID_FIND_PWD handler:self];
            }
            break;
        case CY_CMD_FIND_PWD_EMAIL:
            {
                NSString *email = [param objectForKey:CY_PARAM_EMAIL];
                [CYHttpHelper requestFindpwdEmail:email contextID:CY_CONTEXTID_FIND_PWD_EMAIL handler:self];
            }
            break;
        case CY_CMD_PHONE_REG_SMS:// 手机注册，获取验证码
            {
                NSString *phone = [param objectForKey:CY_PARAM_PHONE];
                [CYHttpHelper requestPhoneRegSms:phone contextID:CY_CONTEXTID_PHONE_REG_SMS handler:self];
            }
            break;
        case CY_CMD_CHANGE_PWD:// 修改密码
            {
                NSString *oldPassword = [[_userInfo getPassword] md5];
                NSString *newPassword = [param objectForKey:CY_PARAM_PASSWORD];
                [CYHttpHelper requestChangepwd:oldPassword newpwd:newPassword sessionId:_sessionID contextID:CY_CONTEXTID_CHANGE_PWD handler:self];
            }
            break;
        case CY_CMD_ACTIVATION_CODE:// 提交激活码
            if ([self checkLoginStatus])
            {
                NSString *code = [param objectForKey:CY_PARAM_CODE];
                [CYHttpHelper requestSubmitActivationCode:code sessionId:_sessionID contextID:CY_CONTEXTID_ACTIVATION_SUBMIT handler:self];
            }
            break;
        default:
            break;
    }
}

/**
 * 进入用户反馈
 */
- (void)feedback:(UIViewController *)controller
{
    if (!_logedin || [CYTextUtil isEmpty:_sessionID] || !controller)
    {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@?sessionid=%@", CY_HTTP_SERVICE_FEEDBACK, _sessionID];
//    CYWebview *webview = [[CYWebview alloc] initWithAddress:url];
    CYWebview *webview = [CYWebview alloc];
    [webview setOrientation:UIInterfaceOrientationMaskLandscape];
    [webview initWithAddress:url];
    [controller presentViewController:webview animated:YES completion:nil];
    [webview release];
}

#pragma mark - pay
/**
 * 进入网页支付:首页
 */
- (void)webMobilePay:(UIViewController *)controller delegate:(id<CYPayProcessDelegate>)delegate
{
    if (!_logedin || [CYTextUtil isEmpty:_sessionID] || !controller)
    {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@?sessionid=%@", CY_HTTP_MOBILEPAY_PAY_INDEX, _sessionID];
    CYWebview *webview = [[CYWebview alloc] initWithAddress:url];
    webview.delegate = delegate;
    [controller presentViewController:webview animated:YES completion:nil];
    [webview release];
}

/**
 * 进入套餐网页支付
 */
- (void)webMobilePayWithPackageID:(NSString *)packageID controller:(UIViewController *)controller delegate:(id<CYPayProcessDelegate>)delegate
{
    if (!_logedin || [CYTextUtil isEmpty:packageID] || [CYTextUtil isEmpty:_sessionID] || !controller)
    {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@?sessionid=%@&packageid=%@", CY_HTTP_MOBILEPAY_PAY_PACKAGE, _sessionID, packageID];
    CYWebview *webview = [[CYWebview alloc] initWithAddress:url];
    webview.delegate = delegate;
    [controller presentViewController:webview animated:YES completion:nil];
    [webview release];
}

/**
 * 进入网页支付:银行卡
 */
- (void)webMobilePayBank:(UIViewController *)controller amount:(NSInteger)amount delegate:(id<CYPayProcessDelegate>)delegate
{
    if (!_logedin || [CYTextUtil isEmpty:_sessionID] || !controller)
    {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@?sessionid=%@&rdoAmount=%d", CY_HTTP_MOBILEPAY_PAY_BANK, _sessionID, amount];
    CYWebview *webview = [[CYWebview alloc] initWithAddress:url];
    webview.delegate = delegate;
    [controller presentViewController:webview animated:YES completion:nil];
    [webview release];
}

/**
 * 进入网页支付:历史查询
 */
- (void)webMobilePayHistory:(UIViewController *)controller
{
    if (!_logedin || [CYTextUtil isEmpty:_sessionID] || !controller)
    {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@?sessionid=%@", CY_HTTP_MOBILEPAY_PAY_HISTORY, _sessionID];
    CYWebview *webview = [[CYWebview alloc] initWithAddress:url];
    [controller presentViewController:webview animated:YES completion:nil];
    [webview release];
}

/**
 * 发起平台内购
 */
- (void)startItunesPurchaseWithProductID:(NSString *)productID controller:(UIViewController *)controller
{
    if (!_logedin || [CYTextUtil isEmpty:_sessionID] || [CYTextUtil isEmpty:productID] || !controller)
    {
        return;
    }
    [[CYItunesInAppPurchase shareItunesInAppPurchase] purchaseWithProductID:productID view:controller.view];
}

/**
 * 发起苹果内购--套餐
 */
- (void)startItunesPurchaseWithPackageID:(NSString *)packageID productID:(NSString *)productID controller:(UIViewController *)controller
{
    if (!_logedin || [CYTextUtil isEmpty:_sessionID] || [CYTextUtil isEmpty:productID] || !controller)
    {
        return;
    }
    [[CYItunesInAppPurchase shareItunesInAppPurchase] purchaseWithPackageID:packageID productID:productID view:controller.view];
}

/**
 * 补单列表
 */
- (NSArray*)achiveRestorePurchaseList
{
    return [[CYItunesInAppPurchase shareItunesInAppPurchase] achiveRestorePurchaseList];
}

/**
 * 补单
 */
- (void)startRestorePurchaseWithOrderID:(NSString *)orderID receipt:(NSString *)receipt controller:(UIViewController *)controller
{
    if (!_logedin || [CYTextUtil isEmpty:_sessionID] || [CYTextUtil isEmpty:orderID] || !controller)
    {
        return;
    }
    [[CYItunesInAppPurchase shareItunesInAppPurchase] restorePurchaseWithOrderID:orderID receipt:receipt view:controller.view];
}

/**
 * 获取订单号，用于第三方SDK支付
 */
- (void)getPayOrderID:(NSInteger)sdkType params:(NSDictionary *)params
{
    if (!_logedin || !params || [params count] == 0)
    {
        return;
    }
    NSInteger contextID = CY_CONTEXTID_DATA_GETORDERID;
    switch (sdkType)
    {
        case CY_SDK_KY:// 快用
            {
                NSNumber *fee = [params objectForKey:CY_PARAM_FEE];
                NSInteger packageID = 0;
                id obj = [params objectForKey:CY_PARAM_PACKAGEID];
                if ([obj isKindOfClass:[NSNumber class]])
                {
                    packageID = ((NSNumber *) obj).integerValue;
                }
                
                [CYHttpHelper requestKYPayOrderID:fee.integerValue packageID:packageID sessionID:_sessionID contextID:contextID handler:self];
            }
            break;
        case CY_SDK_AiSi:// 爱思
            {
                NSInteger packageID = 0;
                id obj = [params objectForKey:CY_PARAM_PACKAGEID];
                if ([obj isKindOfClass:[NSNumber class]])
                {
                    packageID = ((NSNumber *) obj).integerValue;
                }
            
                [CYHttpHelper requestAiSiPayOrderID:packageID sessionID:_sessionID contextID:contextID handler:self];
            }
            break;
        case CY_SDK_FACEVISA:
            {
                NSInteger packageID = 0;
                id obj = [params objectForKey:CY_PARAM_PACKAGEID];
                if ([obj isKindOfClass:[NSString class]])
                {
                    packageID = ((NSString *) obj).integerValue;
                }

                [CYHttpHelper requestFaceVisaPayOrderID:packageID sessionID:_sessionID contextID:contextID handler:self];
            }
            break;
        case CY_SDK_WEIXIN:
            {
                NSInteger packageID = 0;
                id obj = [params objectForKey:CY_PARAM_PACKAGEID];
                if ([obj isKindOfClass:[NSString class]])
                {
                    packageID = ((NSString *) obj).integerValue;
                }
                [CYHttpHelper requestWeiXinPayOrderID:packageID sessionID:_sessionID contextID:contextID handler:self];
            }
            break;
        case CY_SDK_ALIPAY:
            {
                NSInteger packageID = 0;
                id obj = [params objectForKey:CY_PARAM_PACKAGEID];
                if ([obj isKindOfClass:[NSString class]])
                {
                    packageID = ((NSString *) obj).integerValue;
                }
                [CYHttpHelper requestAliPayOrderID:packageID sessionID:_sessionID contextID:contextID handler:self];
            }
            break;
        default:
            break;
    }
}

#pragma mark - avatar
/**
 * 上传自定义头像
 */
- (void)uploadAvatarImage:(UIImage *)image
{
    if (_logedin)
    {
        return [_imageManager uploadImage:image];
    }
}

/**
 * 获取自定义头像
 */
- (UIImage *)getAvatarImageWithUserID:(NSInteger)userID
{
    return [_imageManager imageWithUserID:userID];
}
/**
 * 获取自定义头像URL
 */
- (NSString *)getAvatarImagePathWithUserID:(NSInteger)userID
{
    return [_imageManager imagePathWithUserID:userID];
}
/**
 * 下载自定义头像
 */
- (void)downloadAvatarImagePathWithUserID:(NSInteger)userID
{
    NSString *key = [NSString stringWithFormat:@"%d", userID];
    [_imageManager downloadAvatarImageByTokenIdAndMd5:key md5:nil];
}
#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIFormDataRequest *)request
{
    CYDataHandler *dataHandler = [CYDataHandler handlerWithRequest:request];
    if (dataHandler == nil)
    {
        return;
    }
    int contextID = dataHandler.contextID;
    switch (contextID) {
        case CY_CONTEXTID_SYNCTIME:// 同步时间
            [[CYRuntimeData shareRuntimeData] receiveServerTime:dataHandler];
            [self syncDataConfig:CY_DATA_ACCOUNT_LIST];
            break;
        case CY_CONTEXTID_LOGIN:// 登录
        case CY_CONTEXTID_LOGIN_GUEST:// 游客登录
        case CY_CONTEXTID_LOGIN_3SDK:// 第三方SDK登录
        case CY_CONTEXTID_LOGIN_MERGER:// 登录注册合并请求
        case CY_CONTEXTID_PHONE_REG:// 手机号注册
        case CY_CONTEXTID_LOGIN_DUOLE:// 老麻将账号登录
            if ([dataHandler isSuccess])
            {
                [self setLoginUserInfoData:dataHandler save:_saveAccount password:request.password];
                if (_loginProcessDelegate)
                {
                    NSInteger loginType = (contextID == CY_CONTEXTID_LOGIN_3SDK) ? CY_LOGIN_THIRD : CY_LOGIN_PLATFORM;
                    [_loginProcessDelegate onCYPlatformLoginResult:CY_SUCCESS loginType:loginType error:nil];
                }
            }
            else if (_loginProcessDelegate)
            {
                NSString *error = [dataHandler errorMsg:@"登录失败"];
                NSInteger loginType = (contextID == CY_CONTEXTID_LOGIN_3SDK) ? CY_LOGIN_THIRD : CY_LOGIN_PLATFORM;
                [_loginProcessDelegate onCYPlatformLoginResult:CY_FAILURE loginType:loginType error:error];
            }
            break;
        case CY_CONTEXTID_LOGIN_WEBVIEW:// 重登录
            if ([dataHandler isSuccess])
            {
                [self setLoginUserInfoData:dataHandler save:NO password:request.password];
                if (_loginTempDelegate)
                {
                    [_loginTempDelegate onCYPlatformLoginResult:CY_SUCCESS loginType:CY_LOGIN_PLATFORM error:nil];
                }
            }
            else if (_loginTempDelegate)
            {
                NSString *error = [dataHandler errorMsg:@"登录失败"];
                [_loginTempDelegate onCYPlatformLoginResult:CY_FAILURE loginType:CY_LOGIN_PLATFORM error:error];
            }
            _loginTempDelegate = nil;
            break;
        case CY_CONTEXTID_CHANGE_PWD:// 修改密码
            if ([dataHandler isSuccess])
            {
                // 成功则保存密码
                [self updateLoginedUserPassword:request.password];
                if (_commandDelegate)
                {
                    [_commandDelegate onCYCommandResult:CY_SUCCESS cmd:CY_CMD_CHANGE_PWD error:nil];
                }
            }
            else if (_commandDelegate)
            {
                NSString *error = [dataHandler errorMsg:@"密码修改失败"];
                [_commandDelegate onCYCommandResult:CY_FAILURE cmd:CY_CMD_CHANGE_PWD error:error];
            }
            break;
        case CY_CONTEXTID_PHONE_REG_SMS:// 手机号注册，获取短信验证码
        case CY_CONTEXTID_BIND_PHONE_SMS:// 绑定手机号，获取短信验证码
        case CY_CONTEXTID_BIND_PHONE:// 绑定手机号
        case CY_CONTEXTID_FIND_PWD_SMS:// 找回密码，获取短信验证码
        case CY_CONTEXTID_FIND_PWD:// 找回密码
        case CY_CONTEXTID_FIND_PWD_EMAIL:// 邮箱找回密码
        case CY_CONTEXTID_ACTIVATION_SUBMIT:// 提交激活码
            if (!_commandDelegate)
            {
                break;
            }
            NSInteger cmd = 0;
            switch (contextID)
            {
                case CY_CONTEXTID_PHONE_REG_SMS:// 手机号注册，获取短信验证码
                    cmd = CY_CMD_PHONE_REG_SMS;
                    break;
                case CY_CONTEXTID_BIND_PHONE_SMS:// 绑定手机号，获取短信验证码
                    cmd = CY_CMD_BIND_PHONE_SMS;
                    break;
                case CY_CONTEXTID_BIND_PHONE:// 绑定手机号
                    if ([dataHandler isSuccess])
                    {
                        // 成功则保存密码
                        [self updateLoginedUserPassword:request.password];
                    }
                    cmd = CY_CMD_BIND_PHONE;
                    break;
                case CY_CONTEXTID_FIND_PWD_SMS:// 找回密码，获取短信验证码
                    cmd = CY_CMD_FIND_PWD_SMS;
                    break;
                case CY_CONTEXTID_FIND_PWD:// 找回密码
                    cmd = CY_CMD_FIND_PWD;
                    break;
                case CY_CONTEXTID_FIND_PWD_EMAIL:// 邮箱找回密码
                    cmd = CY_CMD_FIND_PWD_EMAIL;
                    break;
                case CY_CONTEXTID_ACTIVATION_SUBMIT:// 提交激活码
                    cmd = CY_CMD_ACTIVATION_CODE;
                    break;
                default:
                    return;
            }
            if ([dataHandler isSuccess])
            {
                [_commandDelegate onCYCommandResult:CY_SUCCESS cmd:cmd error:nil];
            }
            else
            {
                NSString *error = [dataHandler errorMsg:@"请求失败"];
                [_commandDelegate onCYCommandResult:CY_FAILURE cmd:cmd error:error];
            }
            break;
        case CY_CONTEXTID_DATA_SERVERLIST:// 服务器列表
            if (!_dataConfigureDelegate)
            {
                break;
            }
            if ([dataHandler isSuccess])
            {
                [_dataConfigureDelegate onCYDataConfigureResult:CY_SUCCESS dataType:CY_DATA_SERVERLIST data:[dataHandler dataString]];
            }
            else
            {
                NSString *error = [dataHandler errorMsg:@"获取服务器列表失败"];
                [_dataConfigureDelegate onCYDataConfigureResult:CY_FAILURE dataType:CY_DATA_SERVERLIST data:error];
            }
            break;
        case CY_CONTEXTID_DATA_ACCOUNTLIST:// 账号列表
            if ([dataHandler isSuccess])
            {
                NSArray *array = [dataHandler dataArray];
                [self setAccountListData:array];
                if (_dataConfigureDelegate)
                {
                    [_dataConfigureDelegate onCYDataConfigureResult:CY_SUCCESS dataType:CY_DATA_ACCOUNT_LIST data:nil];
                }
            }
            else
            {
                if (_dataConfigureDelegate)
                {
                    [_dataConfigureDelegate onCYDataConfigureResult:CY_SUCCESS dataType:CY_DATA_ACCOUNT_LIST data:[dataHandler errorSign]];
                }
            }
            break;
        case CY_CONTEXTID_DATA_GETORDERID:// 获取支付订单号
            if (!_dataConfigureDelegate)
            {
                return;
            }
            if ([dataHandler isSuccess])
            {
                //old
                //NSString *orderID = [dataHandler stringForKey:@"OrderID"];
                //[_dataConfigureDelegate onCYDataConfigureResult:CY_SUCCESS dataType:CY_DATA_PAY_ORDERID data:orderID];

                NSDictionary *jsonData = [dataHandler dataObject];
                [_dataConfigureDelegate onCYDataConfigureResult:CY_SUCCESS dataType:CY_DATA_PAY_ORDERID data:jsonData];

            }
            else
            {
                NSString *error = [dataHandler errorMsg:@"获取订单失败"];
                [_dataConfigureDelegate onCYDataConfigureResult:CY_FAILURE dataType:CY_DATA_PAY_ORDERID data:error];
            }
            break;
        case CY_CONTEXTID_DATA_MESSAGE:// 消息公告
            if (!_dataConfigureDelegate)
            {
                return;
            }
            if ([dataHandler isSuccess])
            {
                [_dataConfigureDelegate onCYDataConfigureResult:CY_SUCCESS dataType:CY_DATA_MESSAGE data:[dataHandler dataString]];
            }
            else
            {
                NSString *error = [dataHandler errorMsg:@"获取公告失败"];
                [_dataConfigureDelegate onCYDataConfigureResult:CY_FAILURE dataType:CY_DATA_MESSAGE data:error];
            }
            break;
        case CY_CONTEXTID_DATA_ONLINECONFIG:// 在线配置
            if ([dataHandler isSuccess])
            {
                [self updateOnlineConfig:dataHandler];
                if (_dataConfigureDelegate)
                {
                    [_dataConfigureDelegate onCYDataConfigureResult:CY_SUCCESS dataType:CY_DATA_ONLINE_CONFIG data:nil];
                }
            }
            break;
        case CY_CONTEXTID_DATA_APPRECOMMEND:// 应用互推
            if (!_dataConfigureDelegate)
            {
                return;
            }
            if ([dataHandler isSuccess])
            {
                [_dataConfigureDelegate onCYDataConfigureResult:CY_SUCCESS dataType:CY_DATA_APP_LIST data:[dataHandler dataString]];
            }
            else
            {
                NSString *error = [dataHandler errorMsg:@"获取应用列表失败"];
                [_dataConfigureDelegate onCYDataConfigureResult:CY_FAILURE dataType:CY_DATA_APP_LIST data:error];
            }
            break;
        case CY_CONTEXTID_DATA_APPVERSION:// 版本升级
            if (!_dataConfigureDelegate)
            {
                return;
            }
            if ([dataHandler isSuccess])
            {
                [_dataConfigureDelegate onCYDataConfigureResult:CY_SUCCESS dataType:CY_DATA_VERSION_UPDATE data:[dataHandler dataString]];
            }
            else
            {
                NSString *error = [dataHandler errorMsg:@"获取升级配置失败"];
                [_dataConfigureDelegate onCYDataConfigureResult:CY_FAILURE dataType:CY_DATA_VERSION_UPDATE data:error];
            }
            break;
    }
}

- (void)requestFailed:(ASIFormDataRequest *)request
{
    if (request.tag != CY_CONTEXTID_SYNCTIME)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"亲，您的网络不给力哦，检查一下吧！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        if (request.tag == CY_CONTEXTID_LOGIN_WEBVIEW)
        {
            _loginTempDelegate = nil;
            return;
        }
        // 超时反馈
        switch (request.custormType)
        {
            case CY_REQUEST_LOGIN:
                if (_loginProcessDelegate)
                {
                    [_loginProcessDelegate onCYPlatformLoginResult:CY_TIMEOUT loginType:0 error:nil];
                }
                break;
            case CY_REQUEST_DATA:
                if (_dataConfigureDelegate)
                {
                    [_dataConfigureDelegate onCYDataConfigureResult:CY_TIMEOUT dataType:0 data:nil];
                }
                break;
            case CY_REQUEST_CMD:
                if (_commandDelegate)
                {
                    [_commandDelegate onCYCommandResult:CY_TIMEOUT cmd:0 error:nil];
                }
                break;
        }
    }
}

@end
