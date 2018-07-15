//
//  WebViewEnterManager.m
//  Unity-iPhone
//
//  Created by apple on 14-1-13.
//
//
#import "WebViewEnterManager.h"
#import "SVBaseModalWebViewController.h"
#import "OpenUDIDManager.h"
#import "AppController.h"
#define NO_ERROR                                 0					/**< 没有错误 */
#define ERROR_UNKNOWN                           -1					/**< 未知错误 */

@interface WebViewEnterRootController:SVBaseModalWebViewController

@end
@implementation WebViewEnterRootController
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
     return UIInterfaceOrientationMaskPortrait == interfaceOrientation;
}

// For ios6, use supportedInterfaceOrientations & shouldAutorotate instead
- (NSUInteger) supportedInterfaceOrientations{
#ifdef __IPHONE_6_0
    return UIInterfaceOrientationMaskPortrait;
//    return UIInterfaceOrientationMaskAll;
#endif
}

- (BOOL) shouldAutorotate {
    return YES;
}
@end

@interface WebViewEnterManager ()
{
    UIWindow *keyWindow;
    UIViewController *_webViewController;
}

@end
WebViewEnterManager *g_WebViewEnterManager;
@implementation WebViewEnterManager

+ (WebViewEnterManager *)shareWebViewEnterManager
{
    if (g_WebViewEnterManager == nil)
    {
        g_WebViewEnterManager = [[WebViewEnterManager alloc] init];
    }
    return g_WebViewEnterManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissSVModalWebViewController)
                                                     name:@"CLOSE_SVModalWebViewController"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goPaymentNotification) name:@"GO_PAYMENT" object:nil];
      

    }
    return self;
}

- (void)goPaymentNotification
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [self viewWillAppear:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self viewDidAppear:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self viewWillDisappear:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self viewDidDisappear:NO];
}

- (void)dismissSVModalWebViewController
{
//    AppController * myDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
//    myDelegate.isSupportedPortrait = NO;
    
    if(_webViewController)
    {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window.windowLevel == UIWindowLevelNormal+1) {
            window.hidden = YES;
            window.windowLevel = UIWindowLevelNormal-1;
            [window autorelease];
            [keyWindow makeKeyAndVisible];
            keyWindow.windowLevel=UIWindowLevelNormal;
            _webViewController = nil;
        }
    }
}

- (void)showWebview:(NSURL *)url
{
    [self presentView:url];
}

- (NSInteger)presentView:(NSURL *)url
{
     UIViewController *viewController = [[[WebViewEnterRootController alloc] initWithURL:url]autorelease];
    //SVBaseModalWebViewController *webViewController = [[[SVBaseModalWebViewController alloc] initWithURL:url]autorelease];
    if (viewController)
    {
        //UIViewController *rootViewController = UnityGetGLViewController();
        //[rootViewController presentViewController:webViewController animated:YES completion:nil];
        keyWindow = [UIApplication sharedApplication].keyWindow;
        UIWindow *window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
        window.windowLevel = UIWindowLevelNormal + 1;
        _webViewController = viewController;
        [window setRootViewController:viewController];
        [window makeKeyAndVisible];
    }
    else
    {
        return ERROR_UNKNOWN;
    }
    return NO_ERROR;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CLOSE_SVModalWebViewController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GO_PAYMENT" object:nil];
    [super dealloc];
}

@end
