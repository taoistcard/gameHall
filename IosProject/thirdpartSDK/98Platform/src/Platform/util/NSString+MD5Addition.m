//
//  NSString+MD5Addition.m
//  98Platform
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright 2011 Aurora Apps. All rights reserved.
//

#import "NSString+MD5Addition.h"
#import <CommonCrypto/CommonCrypto.h>
#import "CYTextUtil.h"

@implementation NSString(MD5Addition)

- (NSString *)md5
{
    if ([CYTextUtil isEmpty:self])
    {
        return nil;
    }
    
    const char *values = [self UTF8String];
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    CC_MD5(values, strlen(values), md);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", md[i]];
    }
    
    return output;
}

@end
