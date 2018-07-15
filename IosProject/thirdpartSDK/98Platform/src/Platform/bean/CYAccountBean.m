//
//  CYAccountBean.m
//  98Platform
//
//  Created by 张克敏 on 14-5-4.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import "CYAccountBean.h"
#import "CYTextUtil.h"

@interface CYAccountBean()
{
    // 密码(密文)
    NSString* _password;
}
@end


@implementation CYAccountBean
@synthesize userID = _userID;
@synthesize userName = _userName;
@synthesize nickName = _nickName;
@synthesize avatar = _avatar;
@synthesize password = _password;
@synthesize atime = _atime;

+ (CYAccountBean *)creatWithUserID:(NSInteger)userID userName:(NSString *)userName nickName:(NSString *)nickName password:(NSString *)password avatar:(NSString *)avatar
{
    if (userID < 1 || [CYTextUtil isEmpty:userName])
    {
        return nil;
    }
    return [[[CYAccountBean alloc] initWithUserID:userID userName:userName nickName:nickName password:password avatar:avatar] autorelease];
}

+ (CYAccountBean *)creatWithUserInfo:(CYUserInfo *)userInfo
{
    if (!userInfo)
    {
        return nil;
    }
    return [CYAccountBean creatWithUserID:userInfo.userID userName:userInfo.userName nickName:userInfo.nickName password:userInfo.encryptPassword avatar:userInfo.avatar];
}

- (id)initWithUserID:(NSInteger)userID userName:(NSString *)userName nickName:(NSString *)nickName password:(NSString *)password avatar:(NSString *)avatar
{
    self = [self init];
    if (self)
    {
        _userID   = userID;
        _userName = [[NSString alloc] initWithString:userName];
        if (nickName)
        {
            _nickName = [[NSString alloc] initWithString:nickName];
        }
        if (password)
        {
            _password = [[NSString alloc] initWithString:password];
        }
        if (avatar)
        {
            _avatar   = [[NSString alloc] initWithString:avatar];
        }
    }
    return self;
}

- (void)dealloc
{
    [_userName release];
    [_nickName release];
    [_password release];
    [_avatar release];
    [super dealloc];
}

- (BOOL)hasPassword
{
    if (_password && [_password length] > 0)
    {
        return YES;
    }
    return NO;
}

@end
