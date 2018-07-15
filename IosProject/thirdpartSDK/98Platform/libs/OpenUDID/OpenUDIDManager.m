//
//  OpenUDIDManager.m
//  98Platform
//
//  Created by apple on 13-11-12.
//
//

#import "OpenUDIDManager.h"
#import "OpenUDID.h"
#import "NSString+MD5Addition.h"
#import "CYTextUtil.h"


#define CY_PERMANENT_FILE              @"platform_permanent_openudid_file.plist"
#define CY_PERMANENT_OPENUDID          @"permanent_openudid"
#define CY_PERMANENT_OPENUDID_VERIFY   @"permanent_verify"

#define CY_PERMANENT_SUFFIX            @"98pk"


@implementation OpenUDIDManager

+ (NSString *)achiveOpenUDIDValue
{
    NSString *udidPub = [OpenUDIDManager getUDIDFromPublic];
    NSString *udidApp = [OpenUDIDManager getUDIDFromApp];
    if (![CYTextUtil isEmpty:udidPub])
    {
        if (![CYTextUtil equals:udidPub string2:udidApp])
        {
            // 应用程序目录存一份
            [OpenUDIDManager saveUDID2App:udidPub];
        }
        return udidPub;
    }
    if (![CYTextUtil isEmpty:udidApp])
    {
        if (![CYTextUtil equals:udidPub string2:udidApp])
        {
            // 公共区存一份
            [OpenUDIDManager saveUDID2Public:udidApp];
        }
        return udidApp;
    }
    
    // 自动生成UUID
    NSString *udid = [OpenUDID value];
    
    // 保存到公共区和应用程序目录
    [OpenUDIDManager saveUDID2App:udid];
    [OpenUDIDManager saveUDID2Public:udid];
    
    // 返回
    return udid;
}

+ (NSString *)getUDIDFromPublic
{
    // 公共区数据
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:CY_PERMANENT_FILE];
    NSDictionary *permanentData = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (permanentData && [permanentData count] > 0)
    {
        return [OpenUDIDManager getUDIDFromPermanentData:permanentData];
    }
    return nil;
}

+ (NSString *)getUDIDFromApp
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id permanentData = [userDefaults objectForKey:CY_PERMANENT_FILE];
    if ([permanentData isKindOfClass:[NSDictionary class]])
    {
        return [OpenUDIDManager getUDIDFromPermanentData:permanentData];
    }
    return nil;
}

+ (NSString *)getUDIDFromPermanentData:(NSDictionary *)dict
{
    if (!dict || [dict count] < 2)
    {
        return nil;
    }
    id verify = [dict objectForKey:CY_PERMANENT_OPENUDID_VERIFY];
    id openid = [dict objectForKey:CY_PERMANENT_OPENUDID];
    if (![verify isKindOfClass:[NSString class]] || ![openid isKindOfClass:[NSString class]])
    {
        return nil;
    }
    NSString *md5  = (NSString *)verify;
    NSString *udid = (NSString *)openid;
    NSString *udidVerify = [[NSString stringWithFormat:@"%@%@", udid, CY_PERMANENT_SUFFIX]md5];
    if (![udidVerify isEqualToString:md5])
    {
        return nil;
    }
    return udid;
}

+ (void)saveUDID2Public:(NSString *)udid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:CY_PERMANENT_FILE];
    NSString *udidVerify = [[NSString stringWithFormat:@"%@%@", udid, CY_PERMANENT_SUFFIX] md5];
    NSDictionary *permanentData = [NSDictionary dictionaryWithObjectsAndKeys:
                                   udidVerify, CY_PERMANENT_OPENUDID_VERIFY,
                                   udid, CY_PERMANENT_OPENUDID,
                                   nil];
    [permanentData writeToFile:filePath atomically:NO];
}

+ (void)saveUDID2App:(NSString *)udid
{
    NSString *udidVerify = [[NSString stringWithFormat:@"%@%@", udid, CY_PERMANENT_SUFFIX] md5];
    NSDictionary *permanentData = [NSDictionary dictionaryWithObjectsAndKeys:
                                   udidVerify, CY_PERMANENT_OPENUDID_VERIFY,
                                   udid, CY_PERMANENT_OPENUDID,
                                   nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:permanentData forKey:CY_PERMANENT_FILE];
    [userDefaults synchronize];
}

@end
