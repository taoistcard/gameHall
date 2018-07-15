//
//  CYUserInfo.m
//  98Platform
//
//  Created by 张克敏 on 13-4-28.
//  Copyright (c) 2013年 CY. All rights reserved.
//

#import "CYUserInfo.h"
#import "CYTextUtil.h"
#import "CYRuntimeData.h"

#define ACCOUNT_STATUS_DEVICE_NATIVE 0x01 //游客类型


@implementation CYUserInfo
@synthesize userID = _userID;
@synthesize userName = _userName;
@synthesize nickName = _nickName;
@synthesize avatar = _avatar;
@synthesize isBindMobile = _isBindMobile;
@synthesize bindPhoneNumber = _bindPhoneNumber;
@synthesize lastLoginServer = _lastLoginServer;
@synthesize extData = _extData;
@synthesize channel = _channel;

@synthesize appID = _appID;
@synthesize serverID =_serverID;
@synthesize encryptPassword = _encryptPassword;

@synthesize isGuestAccount = _isGuestAccount;


- (void)dealloc
{
    [_userName release];
    [_nickName release];
    [_avatar release];
    [_bindPhoneNumber release];
    [_lastLoginServer release];
    [_channel release];
    [_extData release];
    [_encryptPassword release];
    [super dealloc];
}

- (id)initWithUserID:(NSInteger)userID
{
    self = [self init];
    if (self)
    {
        _userID = userID;
    }
    return self;
}

- (void)parseJson:(NSDictionary *)json
{
    // 基本数据
    id value = [json objectForKey:@"UserName"];
    if ([value isKindOfClass:[NSString class]])
    {
        _userName = [[NSString alloc] initWithString:value];
    }
    value = [json objectForKey:@"NickName"];
    if ([value isKindOfClass:[NSString class]])
    {
        _nickName = [[NSString alloc] initWithString:value];
    }
    value = [json objectForKey:@"Avatar"];
    if ([value isKindOfClass:[NSString class]])
    {
        _avatar = [[NSString alloc] initWithString:value];
    }
    value = [json objectForKey:@"IsBindMobile"];
    if ([value isKindOfClass:[NSNumber class]])
    {
        _isBindMobile = [(NSNumber *)value boolValue];
    }
    value = [json objectForKey:@"Tel"];
    if ([value isKindOfClass:[NSString class]])
    {
        _bindPhoneNumber = [[NSString alloc] initWithString:value];
    }
    value = [json objectForKey:@"LastLoginServer"];
    if ([value isKindOfClass:[NSString class]])
    {
        _lastLoginServer = [[NSString alloc] initWithString:value];
    }
    value = [json objectForKey:@"Channel"];
    if ([value isKindOfClass:[NSString class]])
    {
        _channel = [[NSString alloc] initWithString:value];
    }
    
    // 扩展数据:现在主要用于保存第三方SDK登录的用户信息
    value = [json objectForKey:@"ext"];
    if ([value isKindOfClass:[NSDictionary class]])
    {
        _extData = [[NSDictionary alloc] initWithDictionary:value];
    }
    
    // 请求上下文
    value = [json objectForKey:@"AppID"];
    if ([value isKindOfClass:[NSNumber class]])
    {
        _appID = [(NSNumber *)value integerValue];
    }
    value = [json objectForKey:@"ServerID"];
    if ([value isKindOfClass:[NSNumber class]])
    {
        _serverID = [(NSNumber *)value integerValue];
    }
    
    // 游客或第三方登录时，有密码下发
    value = [json objectForKey:@"Password"];
    if ([value isKindOfClass:[NSString class]])
    {
        _encryptPassword = [[NSString alloc] initWithString:value];
    }
    
    // 账号状态:游客或注册账号
    value = [json objectForKey:@"Status"];
    if ([value isKindOfClass:[NSString class]])
    {
        NSInteger status = [(NSString *)value integerValue];
        _isGuestAccount = (status & ACCOUNT_STATUS_DEVICE_NATIVE) == ACCOUNT_STATUS_DEVICE_NATIVE;
    }
}

+ (CYUserInfo *)decode:(NSDictionary *)json
{
    if (!json || [json count] == 0)
    {
        return nil;
    }
    
    id value = [json objectForKey:@"UserID"];
    if (![value isKindOfClass:[NSString class]])
    {
        return nil;
    }
    NSInteger userID = [(NSString *)value integerValue];
    if (userID < 1)
    {
        return nil;
    }
    
    CYUserInfo *userInfo = [[[CYUserInfo alloc] initWithUserID:userID] autorelease];
    [userInfo parseJson:json];
    return userInfo;
}

- (NSString *)getPassword
{
    if ([CYTextUtil isEmpty:_encryptPassword])
    {
        return nil;
    }
    return [CYRuntimeData decrypt:_encryptPassword];
}
@end
