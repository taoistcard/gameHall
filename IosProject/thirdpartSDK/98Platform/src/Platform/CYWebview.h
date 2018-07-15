//
//  CYWebview.h
//  98Platform
//
//  Created by 张克敏 on 14-6-11.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SVModalWebViewController.h"
#import "CYPlatformDelegate.h"

@interface CYWebview : SVModalWebViewController
{
    id<CYPayProcessDelegate> _delegate;
    NSUInteger m_orientation;
}
@property(nonatomic,assign) id<CYPayProcessDelegate> delegate;
- (void) setOrientation:(NSUInteger)orientation;
@end
