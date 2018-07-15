//
//  CYTextUtil.h
//  98Platform
//
//  Created by 张克敏 on 14-5-5.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYTextUtil : NSObject
+ (BOOL)isHex:(NSString *)string;
+ (BOOL)isEmpty:(NSString *)string;
+ (BOOL)isDigitsOnly:(NSString *)string;
+ (BOOL)equals:(NSString *)string1 string2:(NSString *)string2;
+ (NSDictionary *)parseHttpQuery:(NSString *)query;
@end
