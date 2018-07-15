//
//  FVAlertView.h
//  FacevisaSdk
//
//  Created by 周夏赛 on 15/12/23.
//  Copyright © 2015年 David Luo. All rights reserved.
//

#import "FVCustomIOSAlertView.h"

@interface FVAlertView : FVCustomIOSAlertView

+ (id)alertViewWithTitle:(NSString *)title message:(NSString *)message;
- (id)initWithTitle:(NSString *)title message:(NSString *)message;

@end
