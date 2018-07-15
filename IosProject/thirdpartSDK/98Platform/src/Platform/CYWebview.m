//
//  CYWebview.m
//  98Platform
//
//  Created by 张克敏 on 14-6-11.
//
//

#import "CYWebview.h"
#import "CYTextUtil.h"
#import "CYPlatform.h"
#import "CYConstants.h"
#import "CYPlatformDelegate.h"

@interface CYWebview () <CYLoginProcessDelegate>
@property (nonatomic, strong) NSString  *returnUrl;
@property (nonatomic, strong) NSString  *payResult;
@property (nonatomic, strong) NSString  *payMessage;
@end


@implementation CYWebview
@synthesize delegate = _delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if( (self = [super initWithCoder:aDecoder]) ) {
        
        m_orientation = UIInterfaceOrientationMaskLandscape;
    }
    
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    [super dealloc];
}

- (void)doneButtonClicked:(id)sender
{
    if (_delegate)
    {
        NSInteger code = 0;
        if ([@"success" isEqualToString:self.payResult])
        {
            code = CY_SUCCESS;
        }
        else if ([@"failure" isEqualToString:self.payResult])
        {
            code = CY_FAILURE;
        }
        else
        {
            code = CY_ERROR;
        }
        [_delegate onCYPaymentResult:code error:self.payMessage];
    }
    
    if (([self isBeingPresented] || [self isMovingToParentViewController]))
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }

}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *path = [[request URL] absoluteString];
    return [self handlerJsProtocol:path];
}

#pragma mark - JS Protocol
- (BOOL)handlerJsProtocol:(NSString *)string
{
    if (![string hasPrefix:@"sccmd://"])
    {
        return YES;
    }
    string = [string substringFromIndex:[@"sccmd://" length]];
    /**
     * 根据协议命令做特殊处理
     * 协议命令格式：①protocol+command+returnUrl ②protocol+command+param
     * ①举例：sccmd://ACCOUNT_SESSION_INVALID/?url=httpa://192.168.0.115/mobilepay/pay/index
     * ②举例：sccmd://PAY_RESULT/?type=success&msg=支付成功
     */
    // command
    NSRange range = [string rangeOfString:@"/?"];
    NSString *cmd = [string substringToIndex:range.location];
    if ([@"ACCOUNT_SESSION_INVALID" isEqualToString:cmd])
    {
        // SessionID无效，重新登录
        range = [string rangeOfString:@"url="];
        self.returnUrl = [string substringFromIndex:(range.location + range.length)];
        [[CYPlatform sharePlatform] loginWebview:self];
    }
    else if ([@"PAY_RESULT" isEqualToString:cmd])
    {
        if ([@"success" isEqualToString:self.payResult])
        {
            return NO;
        }
        // 支付结果
        NSString *query = [string substringFromIndex:(range.location + range.length)];
        NSDictionary *dic = [CYTextUtil parseHttpQuery:query];
        self.payResult = [dic objectForKey:@"type"];
        self.payMessage = [dic objectForKey:@"msg"];
    }
    return NO;
}

- (void)onCYPlatformLoginResult:(NSInteger)code loginType:(NSInteger)loginType error:(NSString *)error
{
    switch (code)
    {
        case CY_SUCCESS:
        {
            if ([CYTextUtil isEmpty:self.returnUrl])
            {
                return;
            }
            NSString *sessionID = [CYPlatform sharePlatform].sessionID;
            NSMutableString *url = [NSMutableString stringWithString:self.returnUrl];
            if ([url characterAtIndex:[url length] - 1] != '?')
            {
                [url appendString:@"?"];
            }
            [url appendFormat:@"sessionid=%@", sessionID];
            [self reloadWithAddress:url];
        }
            break;
        case CY_FAILURE:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"亲，您的网络不给力哦，检查一下吧！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
            break;
        default:
            break;
    }
}

- (void) setOrientation:(NSUInteger)orientation
{
    m_orientation = orientation;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
- (NSUInteger)supportedInterfaceOrientations
{
    return m_orientation;
}

- (BOOL)shouldAutorotate
{
    //支持转屏
    return YES;
}
#endif

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (UIInterfaceOrientationMaskLandscape == m_orientation) {
        return UIInterfaceOrientationIsLandscape( interfaceOrientation );
    }else{
        return UIInterfaceOrientationIsPortrait( interfaceOrientation );
    }
    
}

@end
