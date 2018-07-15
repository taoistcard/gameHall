//
//  CYHttpDefine.h
//  98Platform
//
//  Created by 张克敏 on 14-4-28.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#ifndef _8Platform_CYHttpDefine_h
#define _8Platform_CYHttpDefine_h

/**
 * 98pk.net    适用于 牛牛
 * game100.cn  适用于 斗地主
 **/

//#define SERVICE_DOMAIN "192.168.0.44:8001"

//#define SERVICE_DOMAIN "service.game100.cn"
//
//#define ICON_SERVICE_DOMAIN "icon.game100.cn"

// -----------------------URL定义-----------------------
// 自定义头像上传
#define CY_HTTP_UPLOAD_IMAGE                    @"http://" ICON_SERVICE_DOMAIN "/set_avatar.php"
// 自定义头像下载
#define CY_HTTP_DOWNLOAD_IMAGE_PREFIX           @"http://" ICON_SERVICE_DOMAIN "/avatar/"

// ----------------------------------------service--------------------------------------------
// 同步时间
#define CY_HTTP_SERVICE_SYNC_TIME               @"http://" SERVICE_DOMAIN "/service/sync/time"
// 同步服务器列表
#define CY_HTTP_SERVICE_SYNC_SERVERLIST         @"http://" SERVICE_DOMAIN "/service/sync/serverlist"
// 用户名密码登录
#define CY_HTTP_SERVICE_ACCOUNT_LOGIN           @"http://" SERVICE_DOMAIN "/service/account/login"
// 游客登录
#define CY_HTTP_SERVICE_ACCOUNT_GUESTLOGIN      @"http://" SERVICE_DOMAIN "/service/account/guestlogin"
// 登录、注册合并操作
#define CY_HTTP_SERVICE_ACCOUNT_LOGINMERGE      @"http://" SERVICE_DOMAIN "/service/account/loginmerge"
// 手机注册，获取验证码
#define CY_HTTP_SERVICE_ACCOUNT_PHONEREGSMS     @"http://" SERVICE_DOMAIN "/service/account/phoneregsms"
// 手机注册
#define CY_HTTP_SERVICE_ACCOUNT_PHONEREG        @"http://" SERVICE_DOMAIN "/service/account/phonereg"
// 绑定手机号，获取验证码
#define CY_HTTP_SERVICE_ACCOUNT_BINDPHONESMS    @"http://" SERVICE_DOMAIN "/service/account/bindphonesms"
// 绑定手机号
#define CY_HTTP_SERVICE_ACCOUNT_BINDPHONE       @"http://" SERVICE_DOMAIN "/service/account/bindphone"
// 修改密码
#define CY_HTTP_SERVICE_ACCOUNT_CHANGEPWDE      @"http://" SERVICE_DOMAIN "/service/account/changepwd"
// 找回密码，获取验证码
#define CY_HTTP_SERVICE_ACCOUNT_FINDPWDSMS      @"http://" SERVICE_DOMAIN "/service/account/findpwdsms"
// 找回密码，修改密码
#define CY_HTTP_SERVICE_ACCOUNT_FINDPWD         @"http://" SERVICE_DOMAIN "/service/account/findpwdphone"
// 邮箱找回密码
#define CY_HTTP_SERVICE_ACCOUNT_FINDPWDEMAIL    @"http://" SERVICE_DOMAIN "/service/account/findpwdemail"
// 用户反馈
#define CY_HTTP_SERVICE_FEEDBACK                @"http://" SERVICE_DOMAIN "/service/feedback/index"
// 账号列表
#define CY_HTTP_SERVICE_ACCOUNT_LIST            @"http://" SERVICE_DOMAIN "/service/account/accountlist"
// 消息公告
#define CY_HTTP_SERVICE_SYNC_MESSAGE            @"http://" SERVICE_DOMAIN "/service/sync/message"
// 在线配置
#define CY_HTTP_SERVICE_SYNC_ONLINECONFIG       @"http://" SERVICE_DOMAIN "/service/sync/onlineconfig"
// 应用互推
#define CY_HTTP_SERVICE_SYNC_APPRECOMMEND       @"http://" SERVICE_DOMAIN "/service/sync/apprecommend"
// 程序版本升级
#define CY_HTTP_SERVICE_SYNC_APPVERSION         @"http://" SERVICE_DOMAIN "/service/sync/appversion"
// 资源版本升级
#define CY_HTTP_SERVICE_SYNC_APPRESVERSION      @"http://" SERVICE_DOMAIN "/service/sync/resversion"
// 老麻将系统账号登录
#define CY_HTTP_SERVICE_DUOLEACCOUNT_LOGIN      @"http://" SERVICE_DOMAIN "/service/duoleaccount/login"
// 提交激活码
#define CY_HTTP_SERVICE_ACTIVATIONCODE_SUBMIT   @"http://" SERVICE_DOMAIN "/service/activationcode/submit"

// ----------------------------------------pay--------------------------------------------
/** 98GAME网页版支付 **/
// 网页支付:首页
#define CY_HTTP_MOBILEPAY_PAY_INDEX             @"http://" SERVICE_DOMAIN "/mobilepay/pay/index"
// 网页套餐支付
#define CY_HTTP_MOBILEPAY_PAY_PACKAGE           @"http://" SERVICE_DOMAIN "/mobilepay/pay/package"
// 网页支付:历史查询
#define CY_HTTP_MOBILEPAY_PAY_HISTORY           @"http://" SERVICE_DOMAIN "/mobilepay/pay/history"
// 网页支付:银行卡
#define CY_HTTP_MOBILEPAY_PAY_BANK              @"http://" SERVICE_DOMAIN "/mobilepay/pay/bank"

/** 苹果内购 **/
#define CY_HTTP_MOBILEPAY_APPLE_SUBMITP         @"http://" SERVICE_DOMAIN "/mobilepay/apple/submitp"
#define CY_HTTP_MOBILEPAY_APPLE_SUBMIT          @"http://" SERVICE_DOMAIN "/mobilepay/apple/submit"
#define CY_HTTP_MOBILEPAY_APPLE_FINISH          @"http://" SERVICE_DOMAIN "/mobilepay/apple/finish"

/** 运营商 **/
// 移动MM支付
#define CY_HTTP_MOBILEPAY_MOBILE_MM_SUBMIT      @"http://" SERVICE_DOMAIN "/mobilepay/mobilemm/submit"

// 移动游戏基地支付
#define CY_HTTP_MOBILEPAY_MOBILE_GAME_SUBMIT    @"http://" SERVICE_DOMAIN "/mobilepay/mobilegame/submit"

// 联通沃商店支付
#define CY_HTTP_MOBILEPAY_UNICOM_WO_SUBMIT      @"http://" SERVICE_DOMAIN "/mobilepay/unicomwo/submit"
#define CY_HTTP_MOBILEPAY_UNICOM_WO_NOTIFY      @"http://" SERVICE_DOMAIN "/mobilepay/unicomwo/notify"

// 电信爱游戏支付
#define CY_HTTP_MOBILEPAY_TELECOM_EGAME_SUBMIT  @"http://" SERVICE_DOMAIN "/mobilepay/telecomegame/submit"

/** 其他市场 **/
// 安智市场支付
#define CY_HTTP_MOBILEPAY_ANZHI_SUBMIT          @"http://" SERVICE_DOMAIN "/mobilepay/anzhi/submit"

// UC登录、支付
#define CY_HTTP_SERVICE_UCACCOUNT_LOGIN         @"http://" SERVICE_DOMAIN "/service/ucaccount/login"
#define CY_HTTP_MOBILEPAY_UCPAY_SUBMIT          @"http://" SERVICE_DOMAIN "/mobilepay/ucpay/submit"

// 小米登录、支付
#define CY_HTTP_SERVICE_XIAOMIACCOUNT_LOGIN     @"http://" SERVICE_DOMAIN "/service/xiaomiaccount/login"
#define CY_HTTP_MOBILEPAY_XIAOMIPAY_SUBMIT      @"http://" SERVICE_DOMAIN "/mobilepay/xiaomi/submit"

// 华为登录、支付------
#define CY_HTTP_SERVICE_HUAWEIACCOUNT_LOGIN     @"http://" SERVICE_DOMAIN "/service/huaweiaccount/login"
#define CY_HTTP_MOBILEPAY_HUAWEI_SUBMIT         @"http://" SERVICE_DOMAIN "/mobilepay/huawei/submit"

// 360登录、支付------
#define CY_HTTP_SERVICE_360ACCOUNT_LOGIN        @"http://" SERVICE_DOMAIN "/service/360account/login"
#define CY_HTTP_MOBILEPAY_360PAY_SUBMIT         @"http://" SERVICE_DOMAIN "/mobilepay/360pay/submit"

// 百度多酷登录、支付
#define CY_HTTP_SERVICE_DUOKUACCOUNT_LOGIN      @"http://" SERVICE_DOMAIN "/service/duokuaccount/login"
#define CY_HTTP_MOBILEPAY_DUOKU_SUBMIT          @"http://" SERVICE_DOMAIN "/mobilepay/duoku/submit"

// 快用登录、支付
#define CY_HTTP_SERVICE_KYACCOUNT_LOGIN         @"http://" SERVICE_DOMAIN "/service/kuaiyongaccount/login"
#define CY_HTTP_MOBILEPAY_KY_SUBMIT             @"http://" SERVICE_DOMAIN "/mobilepay/kuaiyong/submit"

// QQ登录
#define CY_HTTP_SERVICE_QQ_LOGIN                @"http://" SERVICE_DOMAIN "/service/qq/login"

//爱思
#define CY_HTTP_SERVICE_AISI_LOGIN                @"http://" SERVICE_DOMAIN "/service/i4/login"

#define CY_HTTP_MOBILEPAY_AISI_SUBMIT                @"http://" SERVICE_DOMAIN "/mobilepay/i4/submit"

//iTools
#define CY_HTTP_SERVICE_ITOOLS_LOGIN                @"http://" SERVICE_DOMAIN "/service/itools/login"

#define CY_HTTP_MOBILEPAY_ITOOLS_SUBMIT                @"http://" SERVICE_DOMAIN "/mobilepay/itools/submit"

//facevisa
#define CY_HTTP_SERVICE_FACEVISA_LOGIN                @"http://" SERVICE_DOMAIN "/service/facevisa/login"

#define CY_HTTP_MOBILEPAY_FACEVISA_SUBMIT                @"http://" SERVICE_DOMAIN "/mobilepay/facevisa/submit"

// 微信支付
#define CY_HTTP_MOBILEPAY_WEIXIN_SUBMIT         @"http://" SERVICE_DOMAIN "/mobilepay/weixin/submit"

// 支付宝支付
#define CY_HTTP_MOBILEPAY_ALIPAY_SUBMIT         @"http://" SERVICE_DOMAIN "/mobilepay/alipayapp/submit"

#endif


///**
// * 98pk.net    适用于 牛牛
// * game100.cn  适用于 斗地主
// **/
//#define SERVICE_DOMAIN "game100.cn"
//
//// -----------------------URL定义-----------------------
//// 自定义头像上传
//#define CY_HTTP_UPLOAD_IMAGE                    @"http://icon." SERVICE_DOMAIN "/set_avatar.php"
//// 自定义头像下载
//#define CY_HTTP_DOWNLOAD_IMAGE_PREFIX           @"http://icon." SERVICE_DOMAIN "/avatar/"
//
//// ----------------------------------------service--------------------------------------------
//// 同步时间
//#define CY_HTTP_SERVICE_SYNC_TIME               @"http://service." SERVICE_DOMAIN "/service/sync/time"
//// 同步服务器列表
//#define CY_HTTP_SERVICE_SYNC_SERVERLIST         @"http://service." SERVICE_DOMAIN "/service/sync/serverlist"
//// 用户名密码登录
//#define CY_HTTP_SERVICE_ACCOUNT_LOGIN           @"http://service." SERVICE_DOMAIN "/service/account/login"
//// 游客登录
//#define CY_HTTP_SERVICE_ACCOUNT_GUESTLOGIN      @"http://service." SERVICE_DOMAIN "/service/account/guestlogin"
//// 登录、注册合并操作
//#define CY_HTTP_SERVICE_ACCOUNT_LOGINMERGE      @"http://service." SERVICE_DOMAIN "/service/account/loginmerge"
//// 手机注册，获取验证码
//#define CY_HTTP_SERVICE_ACCOUNT_PHONEREGSMS     @"http://service." SERVICE_DOMAIN "/service/account/phoneregsms"
//// 手机注册
//#define CY_HTTP_SERVICE_ACCOUNT_PHONEREG        @"http://service." SERVICE_DOMAIN "/service/account/phonereg"
//// 绑定手机号，获取验证码
//#define CY_HTTP_SERVICE_ACCOUNT_BINDPHONESMS    @"http://service." SERVICE_DOMAIN "/service/account/bindphonesms"
//// 绑定手机号
//#define CY_HTTP_SERVICE_ACCOUNT_BINDPHONE       @"http://service." SERVICE_DOMAIN "/service/account/bindphone"
//// 修改密码
//#define CY_HTTP_SERVICE_ACCOUNT_CHANGEPWDE      @"http://service." SERVICE_DOMAIN "/service/account/changepwd"
//// 找回密码，获取验证码
//#define CY_HTTP_SERVICE_ACCOUNT_FINDPWDSMS      @"http://service." SERVICE_DOMAIN "/service/account/findpwdsms"
//// 找回密码，修改密码
//#define CY_HTTP_SERVICE_ACCOUNT_FINDPWD         @"http://service." SERVICE_DOMAIN "/service/account/findpwdphone"
//// 邮箱找回密码
//#define CY_HTTP_SERVICE_ACCOUNT_FINDPWDEMAIL    @"http://service." SERVICE_DOMAIN "/service/account/findpwdemail"
//// 用户反馈
//#define CY_HTTP_SERVICE_FEEDBACK                @"http://service." SERVICE_DOMAIN "/service/feedback/index"
//// 账号列表
//#define CY_HTTP_SERVICE_ACCOUNT_LIST            @"http://service." SERVICE_DOMAIN "/service/account/accountlist"
//// 消息公告
//#define CY_HTTP_SERVICE_SYNC_MESSAGE            @"http://service." SERVICE_DOMAIN "/service/sync/message"
//// 在线配置
//#define CY_HTTP_SERVICE_SYNC_ONLINECONFIG       @"http://service." SERVICE_DOMAIN "/service/sync/onlineconfig"
//// 应用互推
//#define CY_HTTP_SERVICE_SYNC_APPRECOMMEND       @"http://service." SERVICE_DOMAIN "/service/sync/apprecommend"
//// 程序版本升级
//#define CY_HTTP_SERVICE_SYNC_APPVERSION         @"http://service." SERVICE_DOMAIN "/service/sync/appversion"
//// 资源版本升级
//#define CY_HTTP_SERVICE_SYNC_APPRESVERSION      @"http://service." SERVICE_DOMAIN "/service/sync/resversion"
//// 老麻将系统账号登录
//#define CY_HTTP_SERVICE_DUOLEACCOUNT_LOGIN      @"http://service." SERVICE_DOMAIN "/service/duoleaccount/login"
//// 提交激活码
//#define CY_HTTP_SERVICE_ACTIVATIONCODE_SUBMIT   @"http://service." SERVICE_DOMAIN "/service/activationcode/submit"
//
//// ----------------------------------------pay--------------------------------------------
///** 98GAME网页版支付 **/
//// 网页支付:首页
//#define CY_HTTP_MOBILEPAY_PAY_INDEX             @"http://service." SERVICE_DOMAIN "/mobilepay/pay/index"
//// 网页套餐支付
//#define CY_HTTP_MOBILEPAY_PAY_PACKAGE           @"http://service." SERVICE_DOMAIN "/mobilepay/pay/package"
//// 网页支付:历史查询
//#define CY_HTTP_MOBILEPAY_PAY_HISTORY           @"http://service." SERVICE_DOMAIN "/mobilepay/pay/history"
//// 网页支付:银行卡
//#define CY_HTTP_MOBILEPAY_PAY_BANK              @"http://service." SERVICE_DOMAIN "/mobilepay/pay/bank"
//
///** 苹果内购 **/
//#define CY_HTTP_MOBILEPAY_APPLE_SUBMITP         @"http://service." SERVICE_DOMAIN "/mobilepay/apple/submitp"
//#define CY_HTTP_MOBILEPAY_APPLE_SUBMIT          @"http://service." SERVICE_DOMAIN "/mobilepay/apple/submit"
//#define CY_HTTP_MOBILEPAY_APPLE_FINISH          @"http://service." SERVICE_DOMAIN "/mobilepay/apple/finish"
//
///** 运营商 **/
//// 移动MM支付
//#define CY_HTTP_MOBILEPAY_MOBILE_MM_SUBMIT      @"http://service." SERVICE_DOMAIN "/mobilepay/mobilemm/submit"
//
//// 移动游戏基地支付
//#define CY_HTTP_MOBILEPAY_MOBILE_GAME_SUBMIT    @"http://service." SERVICE_DOMAIN "/mobilepay/mobilegame/submit"
//
//// 联通沃商店支付
//#define CY_HTTP_MOBILEPAY_UNICOM_WO_SUBMIT      @"http://service." SERVICE_DOMAIN "/mobilepay/unicomwo/submit"
//#define CY_HTTP_MOBILEPAY_UNICOM_WO_NOTIFY      @"http://service." SERVICE_DOMAIN "/mobilepay/unicomwo/notify"
//
//// 电信爱游戏支付
//#define CY_HTTP_MOBILEPAY_TELECOM_EGAME_SUBMIT  @"http://service." SERVICE_DOMAIN "/mobilepay/telecomegame/submit"
//
///** 其他市场 **/
//// 安智市场支付
//#define CY_HTTP_MOBILEPAY_ANZHI_SUBMIT          @"http://service." SERVICE_DOMAIN "/mobilepay/anzhi/submit"
//
//// UC登录、支付
//#define CY_HTTP_SERVICE_UCACCOUNT_LOGIN         @"http://service." SERVICE_DOMAIN "/service/ucaccount/login"
//#define CY_HTTP_MOBILEPAY_UCPAY_SUBMIT          @"http://service." SERVICE_DOMAIN "/mobilepay/ucpay/submit"
//
//// 小米登录、支付
//#define CY_HTTP_SERVICE_XIAOMIACCOUNT_LOGIN     @"http://service." SERVICE_DOMAIN "/service/xiaomiaccount/login"
//#define CY_HTTP_MOBILEPAY_XIAOMIPAY_SUBMIT      @"http://service." SERVICE_DOMAIN "/mobilepay/xiaomi/submit"
//
//// 华为登录、支付------
//#define CY_HTTP_SERVICE_HUAWEIACCOUNT_LOGIN     @"http://service." SERVICE_DOMAIN "/service/huaweiaccount/login"
//#define CY_HTTP_MOBILEPAY_HUAWEI_SUBMIT         @"http://service." SERVICE_DOMAIN "/mobilepay/huawei/submit"
//
//// 360登录、支付------
//#define CY_HTTP_SERVICE_360ACCOUNT_LOGIN        @"http://service." SERVICE_DOMAIN "/service/360account/login"
//#define CY_HTTP_MOBILEPAY_360PAY_SUBMIT         @"http://service." SERVICE_DOMAIN "/mobilepay/360pay/submit"
//
//// 百度多酷登录、支付
//#define CY_HTTP_SERVICE_DUOKUACCOUNT_LOGIN      @"http://service." SERVICE_DOMAIN "/service/duokuaccount/login"
//#define CY_HTTP_MOBILEPAY_DUOKU_SUBMIT          @"http://service." SERVICE_DOMAIN "/mobilepay/duoku/submit"
//
//// 快用登录、支付
//#define CY_HTTP_SERVICE_KYACCOUNT_LOGIN         @"http://service." SERVICE_DOMAIN "/service/kuaiyongaccount/login"
//#define CY_HTTP_MOBILEPAY_KY_SUBMIT             @"http://service." SERVICE_DOMAIN "/mobilepay/kuaiyong/submit"
//
//// QQ登录
//#define CY_HTTP_SERVICE_QQ_LOGIN                @"http://service." SERVICE_DOMAIN "/service/qq/login"
//
////爱思
//#define CY_HTTP_SERVICE_AISI_LOGIN                @"http://service." SERVICE_DOMAIN "/service/i4/login"
//
//#define CY_HTTP_MOBILEPAY_AISI_SUBMIT                @"http://service." SERVICE_DOMAIN "/mobilepay/i4/submit"
//
////iTools
//#define CY_HTTP_SERVICE_ITOOLS_LOGIN                @"http://service." SERVICE_DOMAIN "/service/itools/login"
//
//#define CY_HTTP_MOBILEPAY_ITOOLS_SUBMIT                @"http://service." SERVICE_DOMAIN "/mobilepay/itools/submit"
//
////facevisa
//#define CY_HTTP_SERVICE_FACEVISA_LOGIN                @"http://service." SERVICE_DOMAIN "/service/facevisa/login"
//
//#define CY_HTTP_MOBILEPAY_FACEVISA_SUBMIT                @"http://service." SERVICE_DOMAIN "/mobilepay/facevisa/submit"
//
//// 微信支付
//#define CY_HTTP_MOBILEPAY_WEIXIN_SUBMIT         @"http://service." SERVICE_DOMAIN "/mobilepay/weixin/submit"
//
//// 支付宝支付
//#define CY_HTTP_MOBILEPAY_ALIPAY_SUBMIT         @"http://service." SERVICE_DOMAIN "/mobilepay/alipayapp/submit"
//
//#endif