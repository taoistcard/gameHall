//
//  CYRuntimeData.h
//  98Platform
//
//  Created by 张克敏 on 14-4-28.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYDataHandler.h"

@interface CYRuntimeData : NSObject
{
    /** 时间戳 **/
    long      _synchronizedTime; //服务器同步的时间戳(单位秒)
    long      _localMachineTime; //本地机器时间(单位秒)
    
    /** 设备信息 **/
    NSString  *_model;           //设备型号
    NSString  *_uuid;            //设备唯一号
    NSString  *_mac;             //MAC地址
    
    /** 平台信息 **/
    NSString  *_appID;           //每一个应用注册到服务端都会生成应用ID
    NSString  *_appKey;          //应用密钥，用于参数签名
    NSString  *_serverID;        //游戏区id，默认0
    NSString  *_appChannel;      //应用发布渠道
    NSString  *_appVersion;      //应用程序版本号
    
    BOOL      _isHDVer;          //是否HD版本
}

@property(nonatomic,retain,readonly) NSString *model;
@property(nonatomic,retain,readonly) NSString *uuid;
@property(nonatomic,retain,readonly) NSString *mac;

@property(nonatomic,retain,readonly) NSString *appID;
@property(nonatomic,retain,readonly) NSString *appKey;
@property(nonatomic,retain,readonly) NSString *serverID;
@property(nonatomic,retain,readonly) NSString *appChannel;
@property(nonatomic,retain,readonly) NSString *appVersion;

@property(nonatomic,assign,readonly) BOOL     isHDVer;

- (void)initData;
- (void)initData:(NSString *)appID appKey:(NSString *)appKey serverID:(NSString *)serverID channel:(NSString *)channel;

/**
 * 设置为HD版本
 */
- (void)setHDVersion:(BOOL)isHD;

/**
 * 切换服务器，这样可能会导致重登录，请慎用
 */
- (void)switchServer:(NSInteger)serverId;

/**
 * 接收到服务器同步的时间戳
 */
- (void)receiveServerTime:(CYDataHandler *)dataHandler;

/**
 * 获取请求发送的真实时间戳（服务器时间+间隔）
 */
- (NSString *)getRequestTime;

+ (CYRuntimeData *)shareRuntimeData;
+ (NSString *)encrypt:(NSString *)str;
+ (NSString *)decrypt:(NSString *)str;
@end
