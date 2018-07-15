//
//  CYDataHandler.m
//  98Platform
//
//  统一平台返回的数据结构为Json格式，具体有两种形式
//  ①成功:
//  {
//      isSuccess:true,
//      ts:1399345596
//      data: {
//          ts:1399345596
//      }
//  }
//  ②错误:
//  {
//      isSuccess:false,
//      ts:1399345596
//      error: {
//          sign:"SERVICE_NOT_AVAILABLE",
//          message:"服务不可用"
//      }
//  }
//
//  Created by 张克敏 on 14-5-5.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import "CYDataHandler.h"
#import "CYTextUtil.h"

@interface CYDataHandler()
{
    BOOL          _success;
    NSString*     _errorSign;
    NSString*     _errorMessage;
    
    // 返回的data结构部分数据
    NSDictionary* _dataJson;
    NSArray*      _dataJsonArray;
    // 上下文
    NSInteger     _contextID;
    NSInteger     _requestType;
}
- (id)initWithJson:(NSDictionary *)json;
- (void)setRequestType:(NSInteger)type;
- (void)setContextID:(NSInteger)ctid;
@end


@implementation CYDataHandler
@synthesize contextID = _contextID;
@synthesize requestType = _requestType;

- (id)initWithJson:(NSDictionary *)json
{
    self = [self init];
    if (self)
    {
        // isSuccess
        NSNumber *num = [json objectForKey:@"isSuccess"];
        if (num && [num boolValue])
        {
            _success = YES;
            id data = [json objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]])
            {
                _dataJson = [[NSDictionary alloc] initWithDictionary:data];
            }
            else if ([data isKindOfClass:[NSArray class]])
            {
                _dataJsonArray = [[NSArray alloc] initWithArray:data];
            }
        }
        // error
        else
        {
            NSDictionary *error = [json objectForKey:@"error"];
            if (error && [error count] > 0)
            {
                NSString *sign = [error objectForKey:@"sign"];
                NSString *message = [error objectForKey:@"message"];
                if (![CYTextUtil isEmpty:sign])
                {
                    _errorSign = [[NSString alloc] initWithString:sign];
                }
                if (![CYTextUtil isEmpty:message])
                {
                    _errorMessage = [[NSString alloc] initWithString:message];
                }
            }
        }
    }
    return self;
}

- (void)setRequestType:(NSInteger)type
{
    _requestType = type;
}

- (void)setContextID:(NSInteger)ctid
{
    _contextID = ctid;
}

- (void)dealloc
{
    [_errorSign release];
    [_errorMessage release];
    
    [_dataJson release];
    [_dataJsonArray release];
    [super dealloc];
}

+ (CYDataHandler *)handlerWithData:(NSData *)data
{
    if (!data || [data length] == 0)
    {
        return nil;
    }
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil || ![json isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    CYDataHandler *handler = [[[CYDataHandler alloc] initWithJson:json] autorelease];
    return handler;
}

+ (CYDataHandler *)handlerWithRequest:(ASIFormDataRequest *)request
{
    CYDataHandler *data = [CYDataHandler handlerWithData:[request responseData]];
    if (data)
    {
        id type = [request postValueForKey:@"cy_request_type"];
        if ([type isKindOfClass:[NSNumber class]])
        {
            [data setRequestType:[(NSNumber *)type integerValue]];
        }
        else
        {
            [data setRequestType:0];
        }
        [data setContextID:request.tag];
    }
    return data;
}

- (BOOL)isSuccess
{
    return _success;
}

- (NSString *)errorSign
{
    return _errorSign;
}

- (NSString *)errorMsg:(NSString *)fallback
{
    if (_errorMessage == nil)
    {
        return fallback;
    }
    return _errorMessage;
}

- (NSArray *)dataArray
{
    return _dataJsonArray;
}

- (NSDictionary *)dataObject
{
    return _dataJson;
}

- (NSString *)dataString
{
    id obj = nil;
    if (_dataJson && [_dataJson count] > 0)
    {
        obj = _dataJson;
    }
    else if (_dataJsonArray && [_dataJsonArray count] > 0)
    {
        obj = _dataJsonArray;
    }
    if ([NSJSONSerialization isValidJSONObject:obj])
    {
        NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:kNilOptions error:nil];
        NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        return string;
    }
    return nil;
}

- (NSArray *)arrayForKey:(NSString *)key
{
    if (_dataJson == nil || [CYTextUtil isEmpty:key])
    {
        return nil;
    }
    id obj = [_dataJson objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]])
    {
        return (NSArray *)obj;
    }
    return nil;
}

- (NSString *)stringForKey:(NSString *)key
{
    if (_dataJson == nil || [CYTextUtil isEmpty:key])
    {
        return nil;
    }
    id obj = [_dataJson objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
    {
        return (NSString *)obj;
    }
    return nil;
}

- (NSNumber *)numberForKey:(NSString *)key
{
    if (_dataJson == nil || [CYTextUtil isEmpty:key])
    {
        return nil;
    }
    id obj = [_dataJson objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]])
    {
        return (NSNumber *)obj;
    }
    return nil;
}

- (NSDictionary *)objectForKey:(NSString *)key
{
    if (_dataJson == nil || [CYTextUtil isEmpty:key])
    {
        return nil;
    }
    id obj = [_dataJson objectForKey:key];
    if ([obj isKindOfClass:[NSDictionary class]])
    {
        return (NSDictionary *)obj;
    }
    return nil;
}

@end
