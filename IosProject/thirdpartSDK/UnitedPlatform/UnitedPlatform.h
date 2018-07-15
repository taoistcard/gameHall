//
//  UnitedPlatform.h
//  niuniu
//
//  Created by sayuokdgd on 15/4/11.
//
//

#ifndef niuniu_UnitedPlatform_h
#define niuniu_UnitedPlatform_h

#import <Foundation/Foundation.h>
#import "CYPlatform.h"
#import "CYPlatformDelegate.h"

@interface UnitedPlatform : NSObject <CYLoginProcessDelegate, CYDataConfigureDelegate, CYCommandDelegate,CYCustomAvatarDelegate, CYPayProcessDelegate>{
    NSDictionary *luaFuncDic;
}

+ (UnitedPlatform *)shareUnitedPlatform;

//初始化统一平台
- (void)initUnitedPlatform:(NSArray *)products platformFileName:(NSString *)platformFileName;
- (void)initUnitedPlatform:(NSArray *)products appID:(NSString *)appID appKey:(NSString *)appKey serverID:(NSString *)serverID channel:(NSString *)channel;
// 注册监听
- (void)registerLuaListener:(NSDictionary *)dic;
// 游客登录
- (BOOL)guestLogin;
// 手机注册，获取验证码
- (void)PlatformPhoneRegCheckCode:(NSString *)phone;
// 手机注册
- (void)PlatformLoginPhone:(NSString *)phone authCode:(NSString *)authCode password:(NSString *)password;
// 手机绑定，获取验证码
- (void)PlatformPhoneBindCheckCode:(NSString *)phone;
// 手机绑定
- (void)PlatformBindPhone:(NSString *)phone authCode:(NSString *)authCode password:(NSString *)password;
// 账号登录
- (void)PlatformLoginAcount:(NSString *)account password:(NSString *)password;
// 自动登录
- (void)PlatformLoginAuto:(BOOL)isSurportGuest;
// 短信找回密码验证码
- (void)PlatformFindPasswordSmsAuth:(NSString *)phone;
// 短信找回密码
- (void)PlatformFindPasswordSms:(NSString *)phone authCode:(NSString *)code password:(NSString *)newpassword;
// 请求在线配置
- (void)PlatformRequestOnLineSetting;
// 请求应用推荐列表
- (void)PlatformRequestRecommandAppList;
// 苹果内购
- (void)PlatformAppPurchases:(NSString *)packageID ProductID:(NSString *)productId;
// 微信支付
- (void)WeiXinAppPurchases:(NSString *)packageID ProductID:(NSString *)productId;
// 支付宝支付
- (void)AliPayAppPurchases:(NSString *)packageID ProductID:(NSString *)productId;
// 补单列表
- (void)PlatformAchiveRestorePurchaseList;
// 补单
- (void)PlatformAppRestorePurchases:(NSString *)orderID receipt:(NSString *)receipt;
// 网页购买
- (void)PlatformWebMobilePay:(NSString *)packageID;
// 用户反馈
- (void)PlatformFeedback;
//上传头像
- (void)PlatformUploadAvatarImage;
// 获取头像地址
- (void)PlatformGetAvatarImageWithUser:(NSInteger)userID;
// 下载头像
- (void)PlatformDownloadAvatarImageWithUser:(NSInteger)userID;
//打开相册
- (void)PlatformOpenPhoto;
//打开相机
- (void)PlatformOpenCamera;
// 切换服务器
- (void)PlatformSwtichServer:(NSInteger)serverID;
// 进入免费筹码
- (void)freeChip:(NSString *)url;
//解压缩文件
-(void)unZipFile:(NSString*)filePath unziptoPath:(NSString*)unziptoPath;
//字符串是否含有emoj表情
-(BOOL)stringContainsEmoji:(NSString*)string;
@end

#endif
