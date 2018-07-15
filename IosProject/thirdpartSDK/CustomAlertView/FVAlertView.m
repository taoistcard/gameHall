//
//  FVAlertView.m
//  FacevisaSdk
//
//  Created by 周夏赛 on 15/12/23.
//  Copyright © 2015年 David Luo. All rights reserved.
//

#import "FVAlertView.h"

@implementation FVAlertView

+ (id)alertViewWithTitle:(NSString *)title message:(NSString *)message {
    return [[FVAlertView alloc] initWithTitle:title message:message];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    self = [super init];
    if (self) {
        self.useMotionEffects = YES;
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.containerView = containerView;
        
        if ([title isEqualToString:@""]) {
            title = nil;
        }
        UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 10, 300, 50)];
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [containerView addSubview:titleLabel];
        
        if ([message isEqualToString:@""]) {
            message = nil;
        }
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        messageLabel.text = message;
        messageLabel.font = [UIFont systemFontOfSize:15];
        messageLabel.numberOfLines = 0;
        NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:15]};
        CGSize size = CGSizeMake(280, MAXFLOAT);
        CGSize labelsize = [message boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
        messageLabel.frame = CGRectMake(10, 60, labelsize.width, labelsize.height);
        [containerView addSubview:messageLabel];
        
        containerView.frame = CGRectMake(0, 0, 300, 60 + labelsize.height + 10);
    }
    return self;
}

@end
