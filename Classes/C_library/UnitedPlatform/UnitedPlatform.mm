//
//  UnitedFlatform.m
//  niuniu
//
//  Created by sayuokdgd on 15/4/11.
//
//

#import <Foundation/Foundation.h>
#include "platform/ios/CCLuaObjcBridge.h"
#import "UnitedPlatform.h"
#import "CYPlatform.h"
#import "CYConstants.h"
#import "CYAccountBean.h"
//#import "MBProgressHUD.h"
//#import "UmengPlatform.h"
#import "CYRuntimeData.h"
#define UmengAliasType   @"UserID"

#import "CYWebview.h"

//#import "ImagePickerViewController.h"
//#import "ImagePicker.h"
#import "CYAppPurchaseObject.h"

@implementation UnitedPlatform

UnitedPlatform *g_UnitedPlatform = nil;
+ (UnitedPlatform *)shareUnitedPlatform
{
    if (g_UnitedPlatform == nil)
    {
        g_UnitedPlatform = [[UnitedPlatform alloc] init];
    }
    return g_UnitedPlatform;
    
}

- (void)dealloc
{
    [super dealloc];
    [luaFuncDic release];
}

- (void)initUnitedPlatform
{
    NSArray *products = [[NSArray alloc] initWithObjects:@"huanle_landpoker_12w", @"huanle_landpoker_50w",@"huanle_landpoker_100w",@"huanle_landpoker_200w",@"huanle_landpoker_500w",nil];
    //    [[CYPlatform sharePlatform] initPlatformWithItuesPruchaseProducts:products];
    [[CYPlatform sharePlatform] initPlatformWithItuesPruchaseProducts:products appID:@"1005" appKey:@"34a9c6a95776107d065672c4eec6213d" serverID:@"3" channel:@"a_01"];
    
    [[CYPlatform sharePlatform] setLoginProcessDelegate:self];
    [[CYPlatform sharePlatform] setDataConfigureDelegate:self];
    [[CYPlatform sharePlatform] setCommandDelegate:self];
    [[CYPlatform sharePlatform] setCustomAvatarDelegate:self];
    
}

/**
 * 注册监听
 **/
- (void)registerLuaListener:(NSDictionary *)dic
{
    luaFuncDic = [[NSDictionary alloc] initWithDictionary:dic];
}

- (BOOL)guestLogin
{
    [CYPlatform sharePlatform].guestLogin = YES;
    return [[CYPlatform sharePlatform] guestLogin];
}

- (void)PlatformPhoneRegCheckCode:(NSString *)phone
{
    NSDictionary *param = [NSDictionary dictionaryWithObject:phone forKey:CY_PARAM_PHONE];
    [[CYPlatform sharePlatform]submitCommand:CY_CMD_PHONE_REG_SMS param:param];
}

- (void)PlatformLoginPhone:(NSString *)phone authCode:(NSString *)authCode password:(NSString *)password
{
    [[CYPlatform sharePlatform]phoneReg:phone authCode:authCode password:password];
}

// 手机绑定，获取验证码
- (void)PlatformPhoneBindCheckCode:(NSString *)phone
{
    NSDictionary *param = [NSDictionary dictionaryWithObject:phone forKey:CY_PARAM_PHONE];
    [[CYPlatform sharePlatform]submitCommand:CY_CMD_BIND_PHONE_SMS param:param];
}
// 手机绑定
- (void)PlatformBindPhone:(NSString *)phone authCode:(NSString *)authCode password:(NSString *)password
{

    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:authCode,CY_PARAM_CODE,password, CY_PARAM_PASSWORD,nil];
    [[CYPlatform sharePlatform]submitCommand:CY_CMD_BIND_PHONE param:param];
}

- (void)PlatformLoginAcount:(NSString *)account password:(NSString *)password
{
    [[CYPlatform sharePlatform]loginWithAccount:account password:password];
}

- (void)PlatformLoginAuto:(BOOL)isSurportGuest
{
    [[CYPlatform sharePlatform]autoLogin:isSurportGuest];
}

- (void)PlatformFindPasswordSmsAuth:(NSString *)phone
{
    NSDictionary *param = [NSDictionary dictionaryWithObject:phone forKey:CY_PARAM_PHONE];
    [[CYPlatform sharePlatform]submitCommand:CY_CMD_FIND_PWD_SMS param:param];
}

- (void)PlatformFindPasswordSms:(NSString *)phone authCode:(NSString *)code password:(NSString *)newpassword
{
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:phone,CY_PARAM_PHONE, code,CY_PARAM_CODE,newpassword, CY_PARAM_PASSWORD,nil];
    [[CYPlatform sharePlatform]submitCommand:CY_CMD_FIND_PWD param:param];
}

- (void)PlatformRequestOnLineSetting
{
    [[CYPlatform sharePlatform]syncDataConfig:CY_DATA_ONLINE_CONFIG];
}

- (void)PlatformAppPurchases:(NSString *)packageID ProductID:(NSString *)productId
{
    if (packageID == NULL)
    {
        [[CYPlatform sharePlatform] startItunesPurchaseWithProductID:productId controller:[self getCurVisiableViewController]];
    }
    else
    {
        [[CYPlatform sharePlatform] startItunesPurchaseWithPackageID:packageID productID:productId controller:[self getCurVisiableViewController]];
    }
}

// 补单列表
- (void)PlatformAchiveRestorePurchaseList
{
    NSArray *appRestorePurchaseList =  [[CYPlatform sharePlatform] achiveRestorePurchaseList];
    // functionId 是 Lua function 的引用 ID，参考 LuaJavaBridge 文章中的描述
    int callbackId = [[luaFuncDic objectForKey:@"OnAppRestorePurchaseList"] intValue];
    
    // 1. 将引用 ID 对应的 Lua function 放入 Lua stack
    cocos2d::LuaBridge::pushLuaFunctionById(callbackId);
    
    // 2. 将需要传递给 Lua function 的参数放入 Lua stack
    cocos2d::LuaValueArray appRestorePurchaseArr;
    
    for (int i = 0; i < [appRestorePurchaseList count]; i++)
    {
        CYAppPurchaseObject *object = [appRestorePurchaseList objectAtIndex:i];
        cocos2d::LuaValueDict restorePurchaseItem;
        restorePurchaseItem["userID"] = cocos2d::LuaValue::intValue([object userID]);
        restorePurchaseItem["orderID"] = cocos2d::LuaValue::stringValue([[object orderID] UTF8String]);
        restorePurchaseItem["receipt"] = cocos2d::LuaValue::stringValue([[object receipt] UTF8String]);
        restorePurchaseItem["orderDate"] = cocos2d::LuaValue::stringValue([[object orderDate] UTF8String]);
        appRestorePurchaseArr.push_back(cocos2d::LuaValue::dictValue(restorePurchaseItem));
    }
    cocos2d::LuaBridge::getStack()->pushLuaValueArray(appRestorePurchaseArr);
    
    // 3. 执行 Lua function
    cocos2d::LuaBridge::getStack()->executeFunction(1);
}

// 补单
- (void)PlatformAppRestorePurchases:(NSString *)orderID receipt:(NSString *)receipt
{
    [[CYPlatform sharePlatform] startRestorePurchaseWithOrderID:orderID receipt:receipt controller:[self getCurVisiableViewController]];
}

- (void)PlatformWebMobilePay:(NSString *)packageID
{
    [[CYPlatform sharePlatform] webMobilePayWithPackageID:packageID controller:[self getCurVisiableViewController] delegate:self];
}

// 用户反馈
- (void)PlatformFeedback
{
    [[CYPlatform sharePlatform] feedback:[self getCurVisiableViewController]];
}
//上传头像
- (void)PlatformUploadAvatarImage
{
    ImagePicker::getInstance()->callImagePickerWithPhotoAndCamera();
}
// 获取头像地址
- (void)PlatformGetAvatarImageWithUser:(NSInteger)userID
{
   [[CYPlatform sharePlatform] getAvatarImagePathWithUserID:userID];
}
// 下载头像
- (void)PlatformDownloadAvatarImageWithUser:(NSInteger)userID
{
    [[CYPlatform sharePlatform] downloadAvatarImagePathWithUserID:userID];
}
//打开相册
- (void)PlatformOpenPhoto
{
    ImagePicker::getInstance()->openPhoto();

}
//打开相机
- (void)PlatformOpenCamera
{
    ImagePicker::getInstance()->openCamera();
}
// 切换服务器
- (void)PlatformSwtichServer:(NSInteger)serverID
{
    [[CYPlatform sharePlatform] switchServer:serverID];
}

/**
 * 进入免费筹码
 */
- (void)freeChip:(NSString *)url
{
    NSString *sessionID = [[CYPlatform sharePlatform] sessionID];
    
    url = [NSString stringWithFormat:@"%@?sessionid=%@", url, sessionID];
    CYWebview *webview = [[CYWebview alloc] initWithAddress:url];
    [[self getCurVisiableViewController] presentViewController:webview animated:YES completion:nil];
    [webview release];
}
#pragma mark - CYLoginProcessDelegate
/**
 * 登录回调
 */
- (void)onCYPlatformLoginResult:(NSInteger)code loginType:(NSInteger)loginType error:(NSString *)error
{
    switch (code) {
        case CY_SUCCESS:
        {
            NSString *sessionID = [CYPlatform sharePlatform].sessionID;
            NSLog(@"sessionID:%@",sessionID);
            
                CYUserInfo* userInfo = [CYPlatform sharePlatform].userInfo;
                NSString* url = userInfo.avatar;
                NSLog(@"url:%@",url);
                NSInteger userid = userInfo.userID;
                NSString* nickname = userInfo.nickName;
                
                // functionId 是 Lua function 的引用 ID，参考 LuaJavaBridge 文章中的描述
                int callbackId = [[luaFuncDic objectForKey:@"onUnitedPlatFormLoginSuccess"] intValue];
                
                // 1. 将引用 ID 对应的 Lua function 放入 Lua stack
                cocos2d::LuaBridge::pushLuaFunctionById(callbackId);
                
                // 2. 将需要传递给 Lua function 的参数放入 Lua stack
                cocos2d::LuaValueDict item;
                item["userID"] = cocos2d::LuaValue::intValue(userid);
                item["nickName"] = cocos2d::LuaValue::stringValue([nickname UTF8String]);
                cocos2d::LuaBridge::getStack()->pushLuaValueDict(item);
                
                // 3. 执行 Lua function
                cocos2d::LuaBridge::getStack()->executeFunction(1);
            
            break;
        }
        case CY_FAILURE:
        case CY_ERROR:
        case CY_TIMEOUT:
        {
            if(error!=nil)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
            break;
        }
            
    }
}

#pragma mark - CYDataConfigureDelegate
/**
 * 数据配置回调
 */
- (void)onCYDataConfigureResult:(NSInteger)code dataType:(NSInteger)dataType data:(NSString *)data;
{
    switch (code) {
        case CY_SUCCESS:
        {
            switch (dataType)
            {
                case CY_DATA_ONLINE_CONFIG:
                {
                    CYOnlineConfig* OnlineConfig =  [CYPlatform sharePlatform].onlineConfig;
                    if([OnlineConfig has:@"review"])
                    {
                        NSString *string = [OnlineConfig stringWithKey:@"review"];
                        
                        NSString *cmdString = [NSString stringWithFormat:@"OnlineConfig_review = \"%@\";",string];
                        cocos2d::LuaEngine *pEngine = cocos2d::LuaEngine::defaultEngine();
                        pEngine->executeString([cmdString UTF8String]);
                        
                    }
                    if([OnlineConfig has:@"charge"])
                    {
                        NSString *string = [OnlineConfig stringWithKey:@"charge"];
                        
                        NSString *cmdString = [NSString stringWithFormat:@"OnlineConfig_charge = \"%@\";",string];
                        cocos2d::LuaEngine *pEngine = cocos2d::LuaEngine::defaultEngine();
                        pEngine->executeString([cmdString UTF8String]);
                        
                    }
                    
                    break;
                }
                case CY_DATA_VERSION_UPDATE:
                {
//                    SBJsonParser *jsonParser = [[[SBJsonParser alloc] init]autorelease];
//                    NSDictionary *array = [jsonParser objectWithString:data];
//                    [ForceUpdateAlertView showForceUpdateAlertView:array];
                    break;
                }
            }
            break;
        }
        case CY_FAILURE:
        {
            break;
        }
        default:
            break;
    }
}
#pragma mark - CYCustomAvatarDelegate
/**
 * 自定义回调
 */
- (void)onCYCustomAvatarResult:(NSInteger)code cmd:(NSInteger)cmd error:(NSString *)error;
{
    
}
- (void)onCYAvatarUploadResult:(NSInteger)code md5:(NSString *)md5 tokenID:(NSString*)tokenID;
{
    //通知ui更新
    // functionId 是 Lua function 的引用 ID，参考 LuaJavaBridge 文章中的描述
    int callbackId = [[luaFuncDic objectForKey:@"onUnitedPlatFormAppAvatarUploadResult"] intValue];
    
    // 1. 将引用 ID 对应的 Lua function 放入 Lua stack
    cocos2d::LuaBridge::pushLuaFunctionById(callbackId);
    
    // 2. 将需要传递给 Lua function 的参数放入 Lua stack
    cocos2d::LuaValueDict item;
    item["resultCode"] = cocos2d::LuaValue::intValue(code);
    const char  *  md5file = [md5 UTF8String];
    item["md5"] = cocos2d::LuaValue::stringValue(md5file);
    const char  *  tokenIDchar = [tokenID UTF8String];
    item["userID"] = cocos2d::LuaValue::stringValue(tokenIDchar);
    cocos2d::LuaBridge::getStack()->pushLuaValueDict(item);
    
    // 3. 执行 Lua function
    cocos2d::LuaBridge::getStack()->executeFunction(1);
}
- (void)onCYAvatarDownloadResult:(NSInteger)code data:(NSString *)data tokenID:(NSString* )tokenID ;
{
    
    //通知ui更新
    // functionId 是 Lua function 的引用 ID，参考 LuaJavaBridge 文章中的描述
    int callbackId = [[luaFuncDic objectForKey:@"onUnitedPlatFormAppAvatarDownloadResult"] intValue];
    
    // 1. 将引用 ID 对应的 Lua function 放入 Lua stack
    cocos2d::LuaBridge::pushLuaFunctionById(callbackId);
    
    // 2. 将需要传递给 Lua function 的参数放入 Lua stack
    cocos2d::LuaValueDict item;
    item["resultCode"] = cocos2d::LuaValue::intValue(code);
    const char  *  url = [data UTF8String];
    item["data"] = cocos2d::LuaValue::stringValue(url);
    const char  *  tokenIDc = [tokenID UTF8String];
    item["tokenID"] = cocos2d::LuaValue::stringValue(tokenIDc);
    cocos2d::LuaBridge::getStack()->pushLuaValueDict(item);
    
    // 3. 执行 Lua function
    cocos2d::LuaBridge::getStack()->executeFunction(1);
}
#pragma mark - CYCommandDelegate
/**
 * 指令回调
 */
- (void)onCYCommandResult:(NSInteger)code cmd:(NSInteger)cmd error:(NSString *)error;
{
    switch (code) {
        case CY_SUCCESS:
        {
            switch (cmd) {
                case CY_CMD_FIND_PWD_SMS:
                case CY_CMD_PHONE_REG_SMS:
                case CY_CMD_BIND_PHONE_SMS:
                {
                    UIViewController *baseController = nil;
                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
                    if (window)
                    {
                        baseController = window.rootViewController;
                    }
                    UIView *visibleView = baseController ? baseController.view : nil;
                    
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:visibleView animated:YES];
                    
                    // Configure for text only and offset down
                    hud.labelText = @"手机验证码获取成功，请注意查收短信";
                    hud.mode = MBProgressHUDModeText;
                    hud.margin = 10.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:3];
                    break;
                }
                case CY_CMD_FIND_PWD:
                {
                    UIViewController *baseController = nil;
                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
                    if (window)
                    {
                        baseController = window.rootViewController;
                    }
                    UIView *visibleView = baseController ? baseController.view : nil;
                    
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:visibleView animated:YES];
                    
                    // Configure for text only and offset down
                    hud.labelText = @"账号密码已经通过手机短信密码验证重置，请重新登录！";
                    hud.mode = MBProgressHUDModeText;
                    hud.margin = 10.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:3];
                    break;
                }
                case CY_CMD_ITUNES_PAY:
                {
                    //通知ui更新
                    // functionId 是 Lua function 的引用 ID，参考 LuaJavaBridge 文章中的描述
                    int callbackId = [[luaFuncDic objectForKey:@"onUnitedPlatFormAppPurchaseResult"] intValue];
                    
                    // 1. 将引用 ID 对应的 Lua function 放入 Lua stack
                    cocos2d::LuaBridge::pushLuaFunctionById(callbackId);
                    
                    // 2. 将需要传递给 Lua function 的参数放入 Lua stack
                    cocos2d::LuaValueDict item;
                    item["resultCode"] = cocos2d::LuaValue::intValue(code);
                    cocos2d::LuaBridge::getStack()->pushLuaValueDict(item);
                    
                    // 3. 执行 Lua function
                    cocos2d::LuaBridge::getStack()->executeFunction(1);
                    [self PlatformAchiveRestorePurchaseList];
                    break;
                }
                case CY_CMD_BIND_PHONE:
                {
                    UIViewController *baseController = nil;
                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
                    if (window)
                    {
                        baseController = window.rootViewController;
                    }
                    UIView *visibleView = baseController ? baseController.view : nil;
                    
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:visibleView animated:YES];
                    
                    // Configure for text only and offset down
                    hud.labelText = @"手机号绑定成功！";
                    hud.mode = MBProgressHUDModeText;
                    hud.margin = 10.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:3];
                    
                    //通知ui更新
                    // functionId 是 Lua function 的引用 ID，参考 LuaJavaBridge 文章中的描述
                    int callbackId = [[luaFuncDic objectForKey:@"onUnitedPlatFormBindPhoneResult"] intValue];
                    
                    // 1. 将引用 ID 对应的 Lua function 放入 Lua stack
                    cocos2d::LuaBridge::pushLuaFunctionById(callbackId);
                    
                    // 2. 将需要传递给 Lua function 的参数放入 Lua stack
                    cocos2d::LuaValueDict item;
                    item["resultCode"] = cocos2d::LuaValue::intValue(code);
                    cocos2d::LuaBridge::getStack()->pushLuaValueDict(item);
                    
                    // 3. 执行 Lua function
                    cocos2d::LuaBridge::getStack()->executeFunction(1);
                    break;
                }
                default:
                    break;
            }
            
            
            
            break;
        }
        case CY_FAILURE:
        {
            if(error)
            {
                UIViewController *baseController = nil;
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                if (window)
                {
                    baseController = window.rootViewController;
                }
                UIView *visibleView = baseController ? baseController.view : nil;
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:visibleView animated:YES];
                
                // Configure for text only and offset down
                hud.labelText = error;
                hud.mode = MBProgressHUDModeText;
                hud.margin = 10.f;
                hud.removeFromSuperViewOnHide = YES;
                
                [hud hide:YES afterDelay:3];
            }
            if (cmd == CY_CMD_ITUNES_PAY) {
                [self PlatformAchiveRestorePurchaseList];
            }
            break;
        }
        default:
            break;
    }
    
    //通知lua
    int callbackId = [[luaFuncDic objectForKey:@"onUnitedPlatFormAppCommandResult"] intValue];
    
    cocos2d::LuaBridge::pushLuaFunctionById(callbackId);
    cocos2d::LuaValueDict item;
    item["code"] = cocos2d::LuaValue::intValue(code);
    item["cmd"] = cocos2d::LuaValue::intValue(cmd);
    item["error"] = cocos2d::LuaValue::stringValue([error UTF8String]);
    cocos2d::LuaBridge::getStack()->pushLuaValueDict(item);
    cocos2d::LuaBridge::getStack()->executeFunction(1);

    
}

#pragma mark - CYPayProcessDelegate
/**
 * Web支付结果回调
 */
- (void)onCYPaymentResult:(NSInteger)code error:(NSString *)error;
{
    switch (code) {
        case CY_SUCCESS:
        {
//            [NSTimer scheduledTimerWithTimeInterval:1.2f target:self selector:@selector(AppleAppPurchaseSuccess) userInfo:nil repeats:NO];
            break;
        }
    }
}

- (UIViewController *)getCurVisiableViewController
{
    UIViewController *baseController = nil;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window)
    {
        baseController = window.rootViewController;
    }
    return baseController;
}
@end