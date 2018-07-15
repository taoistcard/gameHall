//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController
//
//  edit by wanxiaowei 15.11.05.
//  把蒋斌那套代码拿过来支持竖屏显示webview
//  两套代码的区别在于setRootViewController
//  是把本身viewController设成root，还是用系统的root

@interface SVBaseWebViewController : UIViewController

- (instancetype)initWithAddress:(NSString*)urlString;
- (instancetype)initWithURL:(NSURL*)URL;
- (instancetype)initWithURLRequest:(NSURLRequest *)request;

@end
