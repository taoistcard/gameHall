//
//  CYOnlineConfig.m
//  98Platform
//
//  Created by 张克敏 on 14-5-6.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import "CYOnlineConfig.h"
#import "CYTextUtil.h"

#define CY_ONLINECONFIG_ON  @"on"
#define CY_ONLINECONFIG_OFF @"off"


@implementation CYOnlineConfig
@synthesize data = _data;

+ (CYOnlineConfig *)decodeWithJson:(NSDictionary *)json
{
    if (json && [json count] > 0)
    {
        return [[[CYOnlineConfig alloc] initWithJson:json] autorelease];
    }
    return nil;
}

- (CYOnlineConfig *)initWithJson:(NSDictionary *)json
{
    self = [self init];
    if (self)
    {
        _data = [[NSDictionary alloc] initWithDictionary:json];
    }
    return self;
}

- (BOOL)has:(NSString *)key
{
    if (_data && [_data count] > 0)
    {
        NSArray *keys = [_data allKeys];
        return [keys containsObject:key];
    }
    return NO;
}

- (BOOL)isON:(NSString *)key
{
    NSString *value = [self stringWithKey:key];
    if (value == nil)
    {
        return NO;
    }
    value = [[value lowercaseString] lowercaseString];
    return [CYTextUtil equals:value string2:CY_ONLINECONFIG_ON];
}

- (BOOL)isOFF:(NSString *)key
{
    NSString *value = [self stringWithKey:key];
    if (value == nil)
    {
        return NO;
    }
    value = [[value lowercaseString] lowercaseString];
    return [CYTextUtil equals:value string2:CY_ONLINECONFIG_OFF];
}

- (NSString *)stringWithKey:(NSString *)key
{
    if (_data && [_data count] > 0)
    {
        id value = [_data objectForKey:key];
        if ([value isKindOfClass:[NSString class]])
        {
            return (NSString *)value;
        }
    }
    return nil;
}

@end
