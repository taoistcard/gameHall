//
//  MethodForLuaOC.h
//  niuniu
//
//  Created by sayuokdgd on 15-4-9.
//
//

#ifndef niuniu_MethodForLuaOC_h
#define niuniu_MethodForLuaOC_h

@interface MethodForLua : NSObject

#pragma mark - device
/**
 * 获取当前设备号
 */
+ (NSString *)getDeviceID;
// 获取版本号
+ (NSString *)appVersion;
+ (void)updateWithStore;

#pragma mark - tencent
+ (void)tencentOAuth;
+ (BOOL)IsQQInstalled;
// 获取微信客户端是否安装
+ (NSString *) isWXAppInstalled;


#pragma mark - webView
// 打开竖屏web
+ (void)openPortraitWebView:(NSDictionary *)dic;
+ (void)openWebView:(NSDictionary *)dic;


#pragma mark - App
// 请求应用推荐列表
+ (void)PlatformRequestRecommandAppList;
+ (NSString *)openAppPkg:(NSDictionary *)dic;
// 单独用来判断机器上是否安装了指定的的应用
+ (NSString *)checkAppPkg:(NSDictionary *)dic;


#pragma mark - UnitedPlatform
// 注册监听
+ (void)registerLuaListener:(NSDictionary *)dic;
// 游客登录
+ (BOOL)guestLogin;
// 手机注册，获取验证码
+ (void)PlatformPhoneRegCheckCode:(NSDictionary *)dic;
// 手机注册
+ (void)PlatformLoginPhone:(NSDictionary *)dic;
// 手机绑定，获取验证码
+ (void)PlatformPhoneBindCheckCode:(NSDictionary *)dic;
// 手机绑定
+ (void)PlatformBindPhone:(NSDictionary *)dic;
// 账号登录
+ (void)PlatformLoginAcount:(NSDictionary *)dic;
// 自动登录
+ (void)PlatformLoginAuto:(NSDictionary *)dic;
// 短信找回密码验证码
+ (void)PlatformFindPasswordSmsAuth:(NSDictionary *)dic;
// 短信找回密码
+ (void)PlatformFindPasswordSms:(NSDictionary *)dic;
// 苹果内购
+ (void)PlatformAppPurchases:(NSDictionary *)dic;
// 微信支付
+ (void)WeiXinAppPurchases:(NSDictionary *)dic;
// 支付宝支付
+ (void)AliPayAppPurchases:(NSDictionary *)dic;
// 补单列表
+ (void)PlatformAchiveRestorePurchaseList;
// 补单
+ (void)PlatformAppRestorePurchases:(NSDictionary *)dic;
// 网页购买
+ (void)PlatformWebMobilePay:(NSDictionary *)dic;
// 用户反馈
+ (void)PlatformFeedback;
// 上传头像
+ (void)PlatformUploadAvatarImage;
// 获取头像地址
+ (void)PlatformGetAvatarImageWithUser:(NSDictionary *)dic;
// 下载头像
+ (void)PlatformDownloadAvatarImageWithUser:(NSDictionary *)dic;
// 切换服务器
+ (void)PlatformSwtichServer:(NSDictionary *)dic;
// 进入免费筹码
+ (void)freeChip:(NSDictionary *)dic;


#pragma mark - Umeng
+ (void)OnCustomerEvent:(NSDictionary *)dic;
+ (void)addUmengAlias:(NSDictionary *)dic;
+ (void)removeUmengAlias:(NSDictionary *)dic;
+ (void)showShare:(NSDictionary *)dic;
+ (void)onUmengEvent:(NSDictionary *)dic;
+ (void)umengEventBegin:(NSDictionary *)dic;
+ (void)umengEventEnd:(NSDictionary *)dic;


#pragma mark - tools
//解压缩zip文件
+ (void)unZipFile:(NSDictionary *)dic;
//打开相册
+ (void)PlatformOpenPhoto;
//打开相机
+ (void)PlatformOpenCamera;
//字符串是否含有emoj表情
+ (NSString *)stringContainsEmoji:(NSDictionary *)dic;
@end

#endif
