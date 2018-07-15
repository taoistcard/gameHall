//
//  CYUserInfo.h
//  98Platform
//
//  Created by 张克敏 on 13-4-28.
//  Copyright (c) 2013年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYDataHandler.h"

@interface CYUserInfo : NSObject
{
    BOOL            _isGuestAccount;    //是否游客账号
    /* 用户基本数据 */
    NSInteger       _userID;            //用户ID
    NSString*       _userName;          //用户名
	NSString*       _nickName;          //昵称
    NSString*       _avatar;            //头像(是个URL)
    BOOL            _isBindMobile;      //是否绑定手机号
    NSString*       _bindPhoneNumber;   //绑定的手机号码
    NSString*       _lastLoginServer;   //最后登录过的服务器ID
    NSDictionary*   _extData;           //扩展数据
    NSString*       _channel;           //所属渠道
    /* 登录的上下文 */
    NSInteger       _appID;             //应用ID
    NSInteger       _serverID;          //服务器ID
    NSString*       _encryptPassword;   //账号密码(密文)
}

+ (CYUserInfo *)decode:(NSDictionary *)json;

@property(nonatomic,assign,readonly) NSInteger      userID;
@property(nonatomic,retain,readonly) NSString*      userName;
@property(nonatomic,retain,readonly) NSString*      nickName;
@property(nonatomic,retain,readonly) NSString*      avatar;
@property(nonatomic,assign,readonly) BOOL           isBindMobile;
@property(nonatomic,retain,readonly) NSString*      bindPhoneNumber;
@property(nonatomic,retain,readonly) NSString*      lastLoginServer;
@property(nonatomic,retain,readonly) NSDictionary*  extData;
@property(nonatomic,assign,readonly) NSString*      channel;

@property(nonatomic,assign,readonly) NSInteger      appID;
@property(nonatomic,assign,readonly) NSInteger      serverID;
@property(nonatomic,retain)          NSString*      encryptPassword;

@property(nonatomic,assign,readonly) BOOL           isGuestAccount;

- (NSString *)getPassword;
@end
