//
//  QQPlatform.m
//  Unity-iPhone
//
//  Created by Snail on 2/2/15.
//
//

#import "QQPlatform.h"

#import "CYPlatform.h"
#import "CYConstants.h"
#import "UnitedPlatform.h"
#import "QQRuntime.h"
#import "MBProgressHUD.h"

#import "SpecialDefinition.h"

const int _IsQQInstalled(){

    if([TencentOAuth iphoneQQInstalled]){
        return 1;
    }
    return 0;
}
const int _GotoLoginQQ()
{

    [[QQPlatform Instance] QQLogin];
    return 1;
}

const int GotoLoginOutQQ()
{
    [[QQPlatform Instance] QQLOginOut];
    return 1;
}

@implementation QQPlatform




@synthesize Tencent=_TencentOAuth;
static QQPlatform* _QQPlatformInstance=nil;


+(QQPlatform*) Instance
{
    if(_QQPlatformInstance==nil)
    {
        _QQPlatformInstance =[[QQPlatform alloc] init];
    }
    return _QQPlatformInstance;
}

#pragma mark -
-(id) init
{

    self=[super init];
    if(self)
    {
        _TencentOAuth =[[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:self];
    }
   
    return self;
}
-(void)dealloc
{
    [_TencentOAuth dealloc];
    [super dealloc];
}

-(BOOL)QQLogin
{

    if([_TencentOAuth isSessionValid])
    {
        [self ThirdLoginToken:[QQRuntime Instance].Token OpenID:[QQRuntime Instance].OpenID];
    }
    else
    {
        NSArray *permissions=[NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo", nil];
    
        [_TencentOAuth authorize:permissions inSafari:NO];
    }
    return YES;
}

-(BOOL)QQLOginOut
{
    [_TencentOAuth logout:self];
    return YES;
}

- (void)tencentOAuth:(TencentOAuth *)tencentOAuth doCloseViewController:(UIViewController *)viewController
{
  
}

-(BOOL)IsQQInstalled
{
    BOOL d = [TencentOAuth iphoneQQInstalled];
    if (d == true) {
        NSLog(@"%s","iphoneQQ Installed");
    }
    else
    {
        NSLog(@"%s","iphoneQQ not Installed");
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]])
    {
        NSLog(@"%s","iphoneQQ Installed");
        d = true;
    }
    else
    {
        NSLog(@"%s","iphoneQQ not Installed");
        d = false;
    }
    return d;
}


#pragma mark -TencentLoginDelegate

-(void)ThirdLoginToken:(NSString*) token OpenID: (NSString*) open
{
    NSLog(@"token:%@ OpenID:%@", token, open);
    NSDictionary *mDict=[NSDictionary dictionaryWithObjectsAndKeys:
                        token,CY_PARAM_TOKEN,
                         open,CY_PARAM_OPENID,
                         nil];
    
    [[CYPlatform sharePlatform] thirdSdkLogin:CY_SDK_QQ params:mDict];
}
/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin
{
    if(_TencentOAuth.openId!=nil&&_TencentOAuth.accessToken!=nil)
    {
        [_TencentOAuth getUserInfo];
        
        [QQRuntime Instance].Token=_TencentOAuth.accessToken;
        [QQRuntime Instance].OpenID=_TencentOAuth.openId;
        [self ThirdLoginToken:_TencentOAuth.accessToken OpenID:_TencentOAuth.openId];
        
    }
    
    
}
/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    // Configure for text only and offset down
    if(!cancelled)
    {
        UIViewController *baseController = nil;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window)
        {
            baseController = window.rootViewController;
        }
        UIView *visibleView = baseController ? baseController.view : nil;
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:visibleView animated:YES];
        
        hud.labelText = @"登录失败！";
        hud.mode = MBProgressHUDModeText;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:3];
    }
    else
    {
        NSLog(@"登录取消！");
    }
    
    
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork
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
    hud.labelText = @"登录超时。";
    hud.mode = MBProgressHUDModeText;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
    
}

#pragma mark -TencentWebViewDelegate

- (BOOL) tencentWebViewShouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    toInterfaceOrientation=UIInterfaceOrientationMaskPortrait;
    return YES;
}

- (NSUInteger) tencentWebViewSupportedInterfaceOrientationsWithWebkit
{

    return 0;
}
- (BOOL) tencentWebViewShouldAutorotateWithWebkit
{
    return NO;
}


@end
