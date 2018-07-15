//
//  CYOnlineConfig.h
//  98Platform
//
//  Created by 张克敏 on 14-5-6.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CY_ONLINECONFIG_FILE @"onlineconfig.dt"

@interface CYOnlineConfig : NSObject
{
    NSDictionary *_data;
}
@property(nonatomic,retain) NSDictionary *data;

+ (CYOnlineConfig *)decodeWithJson:(NSDictionary *)json;
- (CYOnlineConfig *)initWithJson:(NSDictionary *)json;

- (BOOL)has:(NSString *)key;
- (BOOL)isON:(NSString *)key;
- (BOOL)isOFF:(NSString *)key;
- (NSString *)stringWithKey:(NSString *)key;

@end
