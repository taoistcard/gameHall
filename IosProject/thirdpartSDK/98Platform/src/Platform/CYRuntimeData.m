//
//  CYRuntimeData.m
//  98Platform
//
//  Created by 张克敏 on 14-4-28.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import "CYRuntimeData.h"
#import "NSString+MD5Addition.h"
#import "UIDevice+Hardware.h"
#import "OpenUDIDManager.h"
#import "CYDes.h"
#import "CYTextUtil.h"


#define CY_PLATFORM_APP_INFO @"g(98)app"
#define CY_PLATFORM_DES_KEY  @"98gm@607"
#define CY_PLATFORM_DES_IV   @"^607GM98"


CYRuntimeData *g_RuntimeData = nil;

@implementation CYRuntimeData
@synthesize model = _model;
@synthesize uuid = _uuid;
@synthesize mac = _mac;

@synthesize appID = _appID;
@synthesize appKey = _appKey;
@synthesize serverID = _serverID;
@synthesize appChannel = _appChannel;
@synthesize appVersion = _appVersion;

@synthesize isHDVer = _isHDVer;

+ (CYRuntimeData *)shareRuntimeData
{
    if (!g_RuntimeData)
    {
        g_RuntimeData = [[CYRuntimeData alloc] init];
    }
    return g_RuntimeData;
}

+ (NSString *)encrypt:(NSString *)str
{
    CYDes *des = [[CYDes alloc] init];
    des.key = CY_PLATFORM_DES_KEY;
    des.iv = CY_PLATFORM_DES_IV;
    NSString *result = [des encrypt:str];
    [des release];
    return result;
}

+ (NSString *)decrypt:(NSString *)str
{
    CYDes *des = [[CYDes alloc] init];
    des.key = CY_PLATFORM_DES_KEY;
    des.iv = CY_PLATFORM_DES_IV;
    NSString *result = [des decrypt:str];
    [des release];
    return result;
}

- (void)dealloc
{
    [_model release];
    [_uuid release];
    [_mac release];
    
    [_appID release];
    [_appKey release];
    [_serverID release];
    [_appChannel release];
    [_appVersion release];
    
    [super dealloc];
}

- (void)initData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cyplatform" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (!dict || [dict count] == 0)
    {
        return;
    }
    // 设备信息
    _model = [[NSString alloc] initWithString:[[UIDevice currentDevice] machine]];
    _mac   = [[NSString alloc] initWithString:[[UIDevice currentDevice] macaddress]];
    _uuid  = [[NSString alloc] initWithString:[[OpenUDIDManager achiveOpenUDIDValue] md5]];
    
    // 客户端版本号
    NSString *versionKey = (NSString *)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[0-9]+.[0-9]+.[0-9]+.[0-9]+$"];
    NSCAssert([predicate evaluateWithObject:versionKey], @"build version must be like 1.0.0.0");
    
    NSRange range = [versionKey rangeOfString:@"." options:NSBackwardsSearch];
    _appVersion = [[NSString alloc] initWithString:[versionKey substringToIndex:range.location]];
    
    // 渠道号
    NSString *channel = [dict objectForKey:@"channel"];
    if (![CYTextUtil isEmpty:channel])
    {
        _appChannel = [[NSString alloc] initWithString:channel];
    }
    
    // 平台信息
    NSString *appInfo = (NSString *)[dict objectForKey:@"_98_app_info"];
    if ([CYTextUtil isEmpty:appInfo])
    {
        NSCAssert(NO, @"_98_app_info was NULL in cyplatform.plist");
        return;
    }
    CYDes *des = [[CYDes alloc] init];
    des.key = CY_PLATFORM_APP_INFO;
    des.iv = CY_PLATFORM_DES_IV;
    appInfo = [des decrypt:appInfo];
    [des release];
    
    NSArray *array = [appInfo componentsSeparatedByString:@","];
    if (!array || [array count] < 3)
    {
        return;
    }
    NSString *appID = [array firstObject];
    NSString *serverID = [array objectAtIndex:1];
    NSString *appKey = [array objectAtIndex:2];
    if (![CYTextUtil isDigitsOnly:appID] || ![CYTextUtil isDigitsOnly:serverID] || [CYTextUtil isEmpty:appKey])
    {
        return;
    }
    _appID      = [[NSString alloc] initWithString:appID];
    _appKey     = [[NSString alloc] initWithString:appKey];
    _serverID   = [[NSString alloc] initWithString:serverID];
}

- (void)initData:(NSString *)appID appKey:(NSString *)appKey serverID:(NSString *)serverID channel:(NSString *)channel
{
    // 设备信息
    _model = [[NSString alloc] initWithString:[[UIDevice currentDevice] machine]];
    _mac   = [[NSString alloc] initWithString:[[UIDevice currentDevice] macaddress]];
    _uuid  = [[NSString alloc] initWithString:[[OpenUDIDManager achiveOpenUDIDValue] md5]];
    
    // 客户端版本号
    NSString *versionKey = (NSString *)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[0-9]+.[0-9]+.[0-9]+.[0-9]+$"];
    NSCAssert([predicate evaluateWithObject:versionKey], @"build version must be like 1.0.0.0");
    
    NSRange range = [versionKey rangeOfString:@"." options:NSBackwardsSearch];
    _appVersion = [[NSString alloc] initWithString:[versionKey substringToIndex:range.location]];
    
    // 渠道号
    if (![CYTextUtil isEmpty:channel])
    {
        _appChannel = [[NSString alloc] initWithString:channel];
    }
    
    // 平台信息

    if (![CYTextUtil isDigitsOnly:appID] || ![CYTextUtil isDigitsOnly:serverID] || [CYTextUtil isEmpty:appKey])
    {
        return;
    }
    _appID      = [[NSString alloc] initWithString:appID];
    _appKey     = [[NSString alloc] initWithString:appKey];
    _serverID   = [[NSString alloc] initWithString:serverID];
}

/**
 * 设置为HD版本
 */
- (void)setHDVersion:(BOOL)isHD
{
    _isHDVer = isHD;
}

/**
 * 切换服务器，这样可能会导致重登录，请慎用
 */
- (void)switchServer:(NSInteger)serverId
{
    if (_serverID)
    {
        [_serverID release];
    }
    _serverID = [[NSString alloc] initWithFormat:@"%d", serverId];
}

/**
 * 接收到服务器同步的时间戳
 */
- (void)receiveServerTime:(CYDataHandler *)dataHandler
{
    if (dataHandler == nil || ![dataHandler isSuccess])
    {
        return;
    }
    NSNumber *ts = [dataHandler numberForKey:@"ts"];
    if (ts == nil)
    {
        return;
    }
    _synchronizedTime = [ts longValue];
    _localMachineTime = [[NSDate date] timeIntervalSince1970];
}

/**
 * 获取请求发送的真实时间戳（服务器时间+间隔）
 */
- (NSString *)getRequestTime
{
    if (_synchronizedTime == 0)
    {
        long seconds = [[NSDate date] timeIntervalSince1970];
        return [NSString stringWithFormat:@"%ld", seconds];
    }
    // 计算时间
    long diff = ([[NSDate date] timeIntervalSince1970] - _localMachineTime);
    long requestTime =  (_synchronizedTime + diff);
    return [NSString stringWithFormat:@"%ld", requestTime];
}

@end
