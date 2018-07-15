//
//  CYPlatform.h
//  98Platform
//
//  Created by 张克敏 on 13-4-26.
//  Copyright (c) 2013年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CYPlatformDelegate.h"
#import "CYUserInfo.h"
#import "CYItunesInAppPurchase.h"
#import "CYOnlineConfig.h"

#import "ASIFormDataRequest.h"

#define CY_PLATFORM_VERSION @"2.0.0"


@interface CYPlatform : NSObject <ASIHTTPRequestDelegate>
{
    id<CYLoginProcessDelegate>  _loginProcessDelegate;
    id<CYDataConfigureDelegate> _dataConfigureDelegate;
    id<CYCommandDelegate>       _commandDelegate;
    id<CYCustomAvatarDelegate>  _customAvatarDelegate;
    BOOL                        _guestLogin;
    
    // 登录的用户信息
    CYUserInfo                  *_userInfo;
    NSString                    *_sessionID;
    NSMutableArray              *_accountList;
    CYOnlineConfig              *_onlineConfig;
}

@property(nonatomic,assign) id<CYLoginProcessDelegate>  loginProcessDelegate;
@property(nonatomic,assign) id<CYDataConfigureDelegate> dataConfigureDelegate;
@property(nonatomic,assign) id<CYCommandDelegate>       commandDelegate;
@property(nonatomic,assign) id<CYCustomAvatarDelegate>  customAvatarDelegate;
@property(nonatomic,assign) BOOL                        guestLogin;

@property(nonatomic,retain,readonly) CYUserInfo         *userInfo;
@property(nonatomic,retain,readonly) NSString           *sessionID;
@property(nonatomic,retain,readonly) NSArray            *accountList;
@property(nonatomic,retain,readonly) CYOnlineConfig     *onlineConfig;

#pragma mark - api
/**
 * 获取CYPlatform的实例对象
 */
+ (CYPlatform *)sharePlatform;

/**
 * 初始化平台
 */
- (void)initPlatformWithItuesPruchaseProducts:(NSArray *)products;
- (void)initPlatformWithItuesPruchaseProducts:(NSArray *)products appID:(NSString *)appID appKey:(NSString *)appKey serverID:(NSString *)serverID channel:(NSString *)channel;

/**
 * 平台唤醒
 */
- (void)onResume;

/**
 * 设置为HD版本
 */
- (void)setHDVersion:(BOOL)isHD;

/**
 * 获取应用版本号
 */
- (NSString *)getAppVersion;

/**
 * 获取渠道号
 */
- (NSString *)getAppChannel;

/**
 * 切换服务器，这样可能会导致重登录，请慎用
 */
- (void)switchServer:(NSInteger)serverId;

#pragma mark - sync
/**
 * 同步服务器列表
 */
- (void)syncServerList:(BOOL)sandbox;
/**
 * 请求数据配置
 */
- (void)syncDataConfig:(NSInteger)dataType;
/**
 * 请求数据配置
 */
- (void)syncDataConfig:(NSInteger)dataType param:(NSDictionary *)param;
/**
 * 检查应用版本升级
 */
- (void)checkVersionUpdate;

#pragma mark - login & register
/**
 * 当前账号重登录
 */
- (BOOL)loginWithUserInfo;
/**
 * 登录注册合并请求
 *
 * @param account 用户名
 * @param password 密码(明文)
 */
- (BOOL)loginWithAccount:(NSString *)account password:(NSString *)password;
/**
 * 根据账号索引登录
 */
- (BOOL)loginWithUserID:(NSInteger)userID;
/**
 * 根据账号索引登录，没有密码的情况
 */
- (BOOL)loginWithUserID:(NSInteger)userID password:(NSString *)password;
/**
 * 游客登录
 */
- (BOOL)guestLogin;
/**
 * 自动登录模式，根据上次登录成功的账号自动登录，可支持游客登录
 *
 * @param guestLogin true-支持游客登录，false-不支持游客登录
 */
- (BOOL)autoLogin:(BOOL)guestLogin;
/**
 * 第三方渠道SDK登录
 */
- (void)thirdSdkLogin:(NSInteger)sdkType params:(NSDictionary *)params;

/**
 * 内部WebView登录用，接入时请无视
 */
- (void)loginWebview:(id<CYLoginProcessDelegate>)delegate;

/**
 * 老麻将系统账号登录
 *
 * @param account 用户名
 * @param password 密码(明文)
 * @param verify 是否直接验证
 */
- (void)duoleLogin:(NSString *)account password:(NSString *)password verify:(BOOL)verify;

/**
 * 手机注册
 */
- (void)phoneReg:(NSString *)phone authCode:(NSString *) authCode password:(NSString *)password;

#pragma mark - service
/**
 * 指令类请求
 */
- (void)submitCommand:(NSInteger)cmdType param:(NSDictionary *)param;
/**
 * 进入用户反馈
 */
- (void)feedback:(UIViewController *)controller;

#pragma mark - pay
/**
 * 进入网页支付:首页
 */
- (void)webMobilePay:(UIViewController *)controller delegate:(id<CYPayProcessDelegate>)delegate;
/**
 * 进入套餐网页支付
 */
- (void)webMobilePayWithPackageID:(NSString *)packageID controller:(UIViewController *)controller delegate:(id<CYPayProcessDelegate>)delegate;

/**
 * 进入网页支付:银行卡
 */
- (void)webMobilePayBank:(UIViewController *)controller amount:(NSInteger)amount delegate:(id<CYPayProcessDelegate>)delegate;
/**
 * 进入网页支付:历史查询
 */
- (void)webMobilePayHistory:(UIViewController *)controller;
/**
 * 发起苹果内购
 */
- (void)startItunesPurchaseWithProductID:(NSString *)productID controller:(UIViewController *)controller;
/**
 * 发起苹果内购--套餐
 */
- (void)startItunesPurchaseWithPackageID:(NSString *)packageID productID:(NSString *)productID controller:(UIViewController *)controller;
/**
 * 补单列表
 */
- (NSArray*)achiveRestorePurchaseList;
/**
 * 补单
 */
- (void)startRestorePurchaseWithOrderID:(NSString *)orderID receipt:(NSString *)receipt controller:(UIViewController *)controller;
/**
 * 获取订单号，用于第三方SDK支付
 */
- (void)getPayOrderID:(NSInteger)sdkType params:(NSDictionary *)params;

#pragma mark - avatar
/**
 * 上传自定义头像
 */
- (void)uploadAvatarImage:(UIImage *)image;
- (NSString *)getAvatarImagePathWithUserID:(NSInteger)userID;
/**
 * 获取自定义头像地址
 */
- (UIImage *)getAvatarImageWithUserID:(NSInteger)userID;
//根据TOKENID下载自定义头像
- (void)downloadAvatarImagePathWithUserID:(NSInteger)userID;
@end

