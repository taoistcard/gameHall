//
//  CYDataHandler.h
//  98Platform
//
//  Created by 张克敏 on 14-5-5.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@interface CYDataHandler : NSObject

@property(nonatomic,assign,readonly) NSInteger contextID;
@property(nonatomic,assign,readonly) NSInteger requestType;

+ (CYDataHandler *)handlerWithData:(NSData *)data;
+ (CYDataHandler *)handlerWithRequest:(ASIFormDataRequest *)request;

- (BOOL)isSuccess;
- (NSString *)errorSign;
- (NSString *)errorMsg:(NSString *)fallback;

- (NSArray *)dataArray;// JsonArray
- (NSDictionary *)dataObject;// JsonObject
- (NSString *)dataString;// JsonObject or JsonArray to convert string

- (NSArray *)arrayForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSNumber *)numberForKey:(NSString *)key;
- (NSDictionary *)objectForKey:(NSString *)key;
@end
