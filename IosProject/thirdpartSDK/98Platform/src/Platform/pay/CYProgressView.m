//
//  CYProgressView.m
//  98Platform
//
//  Created by 张克敏 on 14-5-7.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import "CYProgressView.h"

@interface CYProgressView()
{
    UIActivityIndicatorView *_activity;
    UILabel                 *_label;
}
@end


@implementation CYProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.hidden = YES;
        [self creatItems];
    }
    return self;
}

- (void)dealloc
{
    [_activity release];
    [_label release];
    [super dealloc];
}

- (void)creatItems
{
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activity.center = self.center;
    _activity.frame = CGRectOffset(_activity.frame, 0, _activity.frame.size.width / 2);
    [self addSubview:_activity];
    
    _label = [[UILabel alloc] init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // iPad
        _label.font = [UIFont systemFontOfSize:24];
        _label.frame = CGRectMake(0, 0, 200, 40);
    }
    else
    {
        // iPhone
        _label.font = [UIFont systemFontOfSize:14];
        _label.frame = CGRectMake(0, 0, 400, 30);
    }
    _label.center = self.center;
    CGFloat y = CGRectGetMaxY(_activity.frame);
    _label.frame = CGRectMake(_label.frame.origin.x, y, _label.frame.size.width, _label.frame.size.height);
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = UITextAlignmentCenter;
    _label.textColor = [UIColor whiteColor];
    _label.adjustsFontSizeToFitWidth = YES;
    _label.minimumFontSize = 10;
    _label.center = CGPointMake(self.center.x, _label.center.y);
    [self addSubview:_label];
}

- (void)setText:(NSString *)text
{
    _label.text = text;
}

- (void)dismiss
{
    if ([self isHidden])
    {
        return;
    }
    [self setHidden:YES];
    [_activity stopAnimating];
}

- (void)show
{
    if (![self isHidden])
    {
        return;
    }
    [self setHidden:NO];
    [_activity startAnimating];
}

@end
