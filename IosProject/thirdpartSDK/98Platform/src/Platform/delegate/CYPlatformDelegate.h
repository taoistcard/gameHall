//
//  CYPlatformDelegate.h
//  98Platform
//
//  Created by 张克敏 on 14-4-25.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 登录回调
 */
@protocol CYLoginProcessDelegate <NSObject>
@required
- (void)onCYPlatformLoginResult:(NSInteger)code loginType:(NSInteger)loginType error:(NSString *)error;
@end

/**
 * 数据配置回调
 */
@protocol CYDataConfigureDelegate <NSObject>
@required
- (void)onCYDataConfigureResult:(NSInteger)code dataType:(NSInteger)dataType data:(NSString *)data;
@end

/**
 * 指令回调
 */
@protocol CYCommandDelegate <NSObject>
@required
- (void)onCYCommandResult:(NSInteger)code cmd:(NSInteger)cmd error:(NSString *)error;
@end

/**
 * 自定义头像回调
 */
@protocol CYCustomAvatarDelegate <NSObject>
@required
- (void)onCYAvatarUploadResult:(NSInteger)code md5:(NSString*)md5 tokenID:(NSString*)tokenID;
- (void)onCYAvatarDownloadResult:(NSInteger)code data:(NSString *)data tokenID:(NSString*)tokenID;
@end

/**
 * Web支付结果回调
 */
@protocol CYPayProcessDelegate <NSObject>
@required
- (void)onCYPaymentResult:(NSInteger)code error:(NSString *)error;
@end