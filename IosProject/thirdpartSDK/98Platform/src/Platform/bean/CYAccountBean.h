//
//  CYAccountBean.h
//  98Platform
//
//  Created by 张克敏 on 14-5-4.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYUserInfo.h"

@interface CYAccountBean : NSObject
{
    // 用户ID
    NSInteger   _userID;
    // 用户名
    NSString*   _userName;
    // 昵称
    NSString*   _nickName;
    // 头像
    NSString*   _avatar;
    // 更新实际
    NSString*   _atime;
}

+ (CYAccountBean *)creatWithUserID:(NSInteger)userID userName:(NSString *)userName nickName:(NSString *)nickName password:(NSString *)password avatar:(NSString *)avatar;
+ (CYAccountBean *)creatWithUserInfo:(CYUserInfo *)userInfo;

@property(nonatomic,assign,readonly) NSInteger userID;
@property(nonatomic,retain,readonly) NSString* userName;
@property(nonatomic,retain,readonly) NSString* nickName;
@property(nonatomic,retain,readonly) NSString* avatar;
@property(nonatomic,retain,readonly) NSString* password;
@property(nonatomic,retain)          NSString* atime;

- (BOOL)hasPassword;

@end
