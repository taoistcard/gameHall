//
//  MethodForLuaOC.m
//  niuniu
//
//  Created by sayuokdgd on 15-4-9.
//
//

#import <Foundation/Foundation.h>
#import "MethodForLuaOC.h"
#import "AppController.h"
#import "SVModalWebViewController.h"
#import "OpenUDIDManager.h"
#import "NSString+MD5Addition.h"
#import "UnitedPlatform.h"
#import "QQPlatform.h"
#import "UmengPlatform.h"
#import "VideoInterFace.h"
#import "WebViewEnterManager.h"
#import "WXApi.h"


@interface UIAlertView (UIAlertViewDragon)
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@implementation UIAlertView(UIAlertViewDragon)

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/jue-ce-san-guo/id897391758?ls=1&mt=8"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
    exit(0);
}

@end


@implementation MethodForLua

#pragma mark - device

+ (NSString *)getDeviceID
{
    return [[OpenUDIDManager achiveOpenUDIDValue] md5];
}

#pragma mark - Ios
// 获取版本号
+ (NSString *)appVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}

// 获取微信客户端是否安装
+ (NSString *) isWXAppInstalled
{
    if ([WXApi isWXAppInstalled]) {
        return @"YES";
    }
    return @"NO";
}

+ (void)updateWithStore
{
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                  message:@"版本过低，请进入商店升级！"
                                                 delegate:nil
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil];
    
    [alert setDelegate:alert];
    [alert show];
    
}

// 打开竖屏web
+ (void)openPortraitWebView:(NSDictionary *)dic
{
    NSString *url = [dic objectForKey:@"url"];
    NSURL *NSUrl = [NSURL URLWithString:url];
    
    AppController * myDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
    myDelegate.isSupportedPortrait = YES;
    
    [[WebViewEnterManager shareWebViewEnterManager] showWebview:NSUrl];
    
    //    myDelegate.isSupportedPortrait = NO;
}

// 打开web
+ (void)openWebView:(NSDictionary *)dic
{
    AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
    RootViewController *controller = [appController rootController];
    
    NSString *url = [dic objectForKey:@"url"];
    SVModalWebViewController *webview = [[SVModalWebViewController alloc] initWithAddress:url];
    [controller presentViewController:webview animated:YES completion:nil];
    [webview release];
    
}

// 打开web
+ (void)openPureURL:(NSDictionary *)dic
{
    NSString *url = [dic objectForKey:@"url"];
    NSURL *AppUrl=[[NSURL alloc]initWithString:url];
    [[UIApplication sharedApplication] openURL:AppUrl];
    [AppUrl release];
}

+ (NSString *)openAppPkg:(NSDictionary *)dic
{
    NSString *pkg = [dic objectForKey:@"pkg"];
    NSURL *AppUrl=[[NSURL alloc]initWithString:[ NSString stringWithFormat:@"%@%@",pkg,@"://"]];
    bool isLeave=[[UIApplication sharedApplication] canOpenURL:AppUrl];
    if(isLeave)
    {
        [[UIApplication sharedApplication] openURL:AppUrl];
        [AppUrl release];
        return @"Yes";
    }
    else
    {
        [AppUrl release];
        return @"NO";
    }
}

+ (NSString *)checkAppPkg:(NSDictionary *)dic
{
    NSString *pkg = [dic objectForKey:@"pkg"];
    NSURL *AppUrl=[[NSURL alloc]initWithString:[ NSString stringWithFormat:@"%@%@",pkg,@"://"]];
    bool isLeave=[[UIApplication sharedApplication] canOpenURL:AppUrl];
    if(isLeave)
    {
        [AppUrl release];
        return @"Yes";
    }
    else
    {
        [AppUrl release];
        return @"NO";
    }
}

#pragma mark - UnitedPlatform
// 注册监听
+ (void)registerLuaListener:(NSDictionary *)dic
{
    [[UnitedPlatform shareUnitedPlatform] registerLuaListener:dic];
}

// 游客登录
+ (BOOL)guestLogin
{
    return [[UnitedPlatform shareUnitedPlatform] guestLogin];
}

// 请求应用推荐列表
+ (void)PlatformRequestRecommandAppList
{
    [[UnitedPlatform shareUnitedPlatform] PlatformRequestRecommandAppList];
}

// 手机注册，获取验证码
+ (void)PlatformPhoneRegCheckCode:(NSDictionary *)dic
{
    NSString *phone = [dic objectForKey:@"phone"];
    [[UnitedPlatform shareUnitedPlatform] PlatformPhoneRegCheckCode:phone];
}

// 手机注册
+ (void)PlatformLoginPhone:(NSDictionary *)dic
{
    NSString *phone = [dic objectForKey:@"phone"];
    NSString *authCode = [dic objectForKey:@"authCode"];
    NSString *password = [dic objectForKey:@"password"];
    [[UnitedPlatform shareUnitedPlatform] PlatformLoginPhone:phone authCode:authCode password:password];
}

// 手机绑定，获取验证码
+ (void)PlatformPhoneBindCheckCode:(NSDictionary *)dic
{
    NSString *phone = [dic objectForKey:@"phone"];
    [[UnitedPlatform shareUnitedPlatform] PlatformPhoneBindCheckCode:phone];
}

// 手机绑定
+ (void)PlatformBindPhone:(NSDictionary *)dic
{
    NSString *phone = [dic objectForKey:@"phone"];
    NSString *authCode = [dic objectForKey:@"authCode"];
    [[UnitedPlatform shareUnitedPlatform] PlatformBindPhone:phone authCode:authCode password:nil];
}

// 账号登录
+ (void)PlatformLoginAcount:(NSDictionary *)dic
{
    NSString *account = [dic objectForKey:@"account"];
    NSString *password = [dic objectForKey:@"password"];
    [[UnitedPlatform shareUnitedPlatform] PlatformLoginAcount:account password:password];
}

// 自动登录
+ (void)PlatformLoginAuto:(NSDictionary *)dic
{
    BOOL isSurportGuest = [dic objectForKey:@"isSurportGuest"];
    [[UnitedPlatform shareUnitedPlatform] PlatformLoginAuto:isSurportGuest];
}

// 短信找回密码验证码
+ (void)PlatformFindPasswordSmsAuth:(NSDictionary *)dic
{
    NSString *phone = [dic objectForKey:@"phone"];
    [[UnitedPlatform shareUnitedPlatform] PlatformFindPasswordSmsAuth:phone];
}
// 短信找回密码
+ (void)PlatformFindPasswordSms:(NSDictionary *)dic
{
    NSString *phone = [dic objectForKey:@"phone"];
    NSString *authCode = [dic objectForKey:@"authCode"];
    NSString *password = [dic objectForKey:@"password"];
    [[UnitedPlatform shareUnitedPlatform] PlatformFindPasswordSms:phone authCode:authCode password:password];
}

// 苹果内购
+ (void)PlatformAppPurchases:(NSDictionary *)dic
{
    NSString *packageID = [dic objectForKey:@"packageID"];
    NSString *productId = [dic objectForKey:@"productId"];
    [[UnitedPlatform shareUnitedPlatform] PlatformAppPurchases:packageID ProductID:productId];
}

// 微信支付
+ (void)WeiXinAppPurchases:(NSDictionary *)dic
{
    NSString *packageID = [dic objectForKey:@"packageID"];
    NSString *productId = [dic objectForKey:@"productId"];
    [[UnitedPlatform shareUnitedPlatform] WeiXinAppPurchases:packageID ProductID:productId];
}

// 支付宝支付
+ (void)AliPayAppPurchases:(NSDictionary *)dic
{
    NSString *packageID = [dic objectForKey:@"packageID"];
    NSString *productId = [dic objectForKey:@"productId"];
    [[UnitedPlatform shareUnitedPlatform] AliPayAppPurchases:packageID ProductID:productId];
}

// 补单列表
+ (void)PlatformAchiveRestorePurchaseList
{
    [[UnitedPlatform shareUnitedPlatform] PlatformAchiveRestorePurchaseList];
}

// 补单
+ (void)PlatformAppRestorePurchases:(NSDictionary *)dic
{
    NSString *orderID = [dic objectForKey:@"orderID"];
    NSString *receipt = [dic objectForKey:@"receipt"];
    [[UnitedPlatform shareUnitedPlatform] PlatformAppRestorePurchases:orderID receipt:receipt];
}

// 网页购买
+ (void)PlatformWebMobilePay:(NSDictionary *)dic
{
    NSString *packageID = [dic objectForKey:@"packageID"];
    [[UnitedPlatform shareUnitedPlatform] PlatformWebMobilePay:packageID];
}

// 用户反馈
+ (void)PlatformFeedback
{
    [[UnitedPlatform shareUnitedPlatform] PlatformFeedback];
}
// 上传头像
+ (void)PlatformUploadAvatarImage
{
    [[UnitedPlatform shareUnitedPlatform] PlatformUploadAvatarImage];
}
// 获取头像地址
+ (void)PlatformGetAvatarImageWithUser:(NSDictionary *)dic
{
    NSString * userID = [dic objectForKey:@"userID"];
    [[UnitedPlatform shareUnitedPlatform] PlatformGetAvatarImageWithUser:[userID integerValue]];
}
// 下载头像
+ (void)PlatformDownloadAvatarImageWithUser:(NSDictionary *)dic
{
    NSString * userID = [dic objectForKey:@"userID"];
    [[UnitedPlatform shareUnitedPlatform] PlatformDownloadAvatarImageWithUser:[userID integerValue]];
}
//打开相册
+ (void)PlatformOpenPhoto
{
    NSLog(@"PlatformOpenPhoto%s","dasd");
    [[UnitedPlatform shareUnitedPlatform] PlatformOpenPhoto];
}
//打开相机
+ (void)PlatformOpenCamera
{
    [[UnitedPlatform shareUnitedPlatform] PlatformOpenCamera];
}
// 切换服务器
+ (void)PlatformSwtichServer:(NSDictionary *)dic
{
    NSString *serverID = [dic objectForKey:@"serverID"];
    [[UnitedPlatform shareUnitedPlatform] PlatformSwtichServer:[serverID integerValue]];
}

// 进入免费筹码
+ (void)freeChip:(NSDictionary *)dic
{
    NSString *url = [dic objectForKey:@"url"];
    [[UnitedPlatform shareUnitedPlatform] freeChip:url];
}

#pragma mark - QQ
// tencentOAuth
+ (void)tencentOAuth
{
    [[QQPlatform Instance] QQLogin];
}

+ (BOOL)IsQQInstalled
{
    return [[QQPlatform Instance] IsQQInstalled];
}

#pragma mark - Umeng
//customer event
+ (void)OnCustomerEvent:(NSDictionary *)dic
{
    [[UmengPlatform Instance] OnCustomerEvent:dic];
}

//add alias
+ (void)addUmengAlias:(NSDictionary *)dic
{
    NSString *alias = [dic objectForKey:@"alias"];
    NSString *type = [dic objectForKey:@"type"];
    [[UmengPlatform Instance] addAlias:alias type:type];
}
//remove alias
+ (void)removeUmengAlias:(NSDictionary *)dic
{
    NSString *alias = [dic objectForKey:@"alias"];
    NSString *type = [dic objectForKey:@"type"];
    [[UmengPlatform Instance] removeAlias:alias type:type];
}

//show share
+ (void)showShare:(NSDictionary *)dic
{
    AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
    [appController showShare:dic];
}

#pragma IJK
//create vedioView int x ,int y,int width ,int height
+ (void)IJKCreateVedioView:(NSDictionary *)dic
{
    NSString *topX = [dic objectForKey:@"topX"];
    NSString *topY = [dic objectForKey:@"topY"];
    NSString *width = [dic objectForKey:@"width"];
    NSString *height = [dic objectForKey:@"height"];
    [[VideoInterFace Instance] OnGenernalVedioViewTopx:[topX integerValue] Topy:[topY integerValue] Width:[width integerValue] Height:[height integerValue]];
}
//播放美女主播 index
+ (void)OnPlayWithUrl:(NSDictionary *)dic
{
    NSString *urlStr = [dic objectForKey:@"url"];
    [[VideoInterFace Instance] OnPlayWithUrl:urlStr];
}
//视频seek
+ (void)IJKSeekToZero
{
    [[VideoInterFace Instance] OnSeekToZero];
}
//停止视频播放
+ (void)IJKStop
{
    [[VideoInterFace Instance] OnStop];
}
//设置视频是否可见
+ (void)IJKSetViewVisible:(NSDictionary *)dic
{
    NSString *isVisiable = [dic objectForKey:@"isVisiable"];
    [[VideoInterFace Instance] OnSetVisible:[isVisiable integerValue]];
}
//视频监听接口设置
+ (void)registerLuaVideoListener:(NSDictionary *)dic
{
    [[VideoInterFace Instance] registerLuaVideoListener:dic];
}

//解压缩zip文件
+(void)unZipFile:(NSDictionary *)dic
{
    [[UnitedPlatform shareUnitedPlatform] unZipFile:[dic objectForKey:@"filePath"] unziptoPath:[dic objectForKey:@"unziptoPath"]];
}
//友盟统计相关
+ (void)onUmengEvent:(NSDictionary *)dic
{
    [[UmengPlatform Instance] onEvent:[dic objectForKey:@"EventId"]];
}
+ (void)umengEventBegin:(NSDictionary *)dic
{
    [[UmengPlatform Instance] onEventBegin:[dic objectForKey:@"EventId"]];
}
+ (void)umengEventEnd:(NSDictionary *)dic
{
    [[UmengPlatform Instance] onEventEnd:[dic objectForKey:@"EventId"]];
}
//字符串是否含有emoj表情
+ (NSString *)stringContainsEmoji:(NSDictionary *)dic
{
    BOOL flag = [[UnitedPlatform shareUnitedPlatform] stringContainsEmoji:[dic objectForKey:@"checkString"]];
    if(flag){return @"true";}
    return @"false";
}
@end