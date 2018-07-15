//
//  WebViewEnterManager.h
//  Unity-iPhone
//
//  Created by apple on 14-1-13.
//
//

#import <Foundation/Foundation.h>

@interface WebViewEnterManager : NSObject
{
}
+ (WebViewEnterManager *)shareWebViewEnterManager;
- (void)showWebview:(NSURL *)url;
@end
