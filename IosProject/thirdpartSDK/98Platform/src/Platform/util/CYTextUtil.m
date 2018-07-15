//
//  CYTextUtil.m
//  98Platform
//
//  Created by 张克敏 on 14-5-5.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import "CYTextUtil.h"

@implementation CYTextUtil

+ (BOOL)isHex:(NSString *)string
{
    if ([CYTextUtil isEmpty:string])
    {
        return NO;
    }
    NSString *regex = @"^[0-9a-zA-Z]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:string];
}

+ (BOOL)isEmpty:(NSString *)string
{
    if (string == nil || [string length] == 0)
    {
        return YES;
    }
    return NO;
}

+ (BOOL)isDigitsOnly:(NSString *)string
{
    if ([CYTextUtil isEmpty:string])
    {
        return NO;
    }
    NSScanner *scan = [NSScanner scannerWithString:string];
    NSInteger result = 0;
    return [scan scanInt:&result] && [scan isAtEnd];
}

+ (BOOL)equals:(NSString *)string1 string2:(NSString *)string2
{
    if (string1 == nil && string2 == nil)
    {
        return YES;
    }
    if (string1 && string2 && [string1 length]  == [string2 length])
    {
        return YES;
    }
    return [string1 isEqualToString:string2];
}

+ (NSDictionary *)parseHttpQuery:(NSString *)query
{
    if ([CYTextUtil isEmpty:query])
    {
        return nil;
    }
    NSArray *array = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[array count]];
    for (NSString *string in array)
    {
        NSArray *kv = [string componentsSeparatedByString:@"="];
        if ([kv count] != 2)
        {
            continue;
        }
        NSString *key = [kv objectAtIndex:0];
        NSString *val = [kv objectAtIndex:1];
        [dic setObject:val forKey:key];
    }
    return dic;
}

@end
