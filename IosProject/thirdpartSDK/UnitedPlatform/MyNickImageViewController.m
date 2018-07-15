//
//  MyNickImageViewController.m
//  CC3Card
//
//  Created by develop on 14-2-24.
//
//

#import "MyNickImageViewController.h"
@interface MyNickImageViewController ()

@end

@implementation MyNickImageViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;//UIInterfaceOrientationMaskPortrait;//
}

- (BOOL)shouldAutorotate
{
    //支持转屏
    return YES;
}
#endif

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation ==UIInterfaceOrientationLandscapeLeft  || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
@end
