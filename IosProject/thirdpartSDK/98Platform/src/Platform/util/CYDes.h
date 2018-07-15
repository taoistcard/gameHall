//
//  CYDes.h
//  98Platform
//
//  Created by 张克敏 on 14-4-25.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYDes : NSObject
{
    NSString *_key;
    NSString *_iv;
}

@property(nonatomic,retain) NSString *key;
@property(nonatomic,retain) NSString *iv;

- (NSString *)encrypt:(NSString *)str;
- (NSString *)decrypt:(NSString *)str;

@end
