//
//  CYConstants.h
//  98Platform
//
//  Created by 张克敏 on 13-4-26.
//  Copyright (c) 2013年 CY. All rights reserved.
//

#ifndef _8Platform_CYConstants_h
#define _8Platform_CYConstants_h

/*
 * 该头文件定义的返回码
 */

/* REQUEST_TYPE(请无视我吧) */
#define CY_REQUEST_LOGIN        1
#define CY_REQUEST_DATA         2
#define CY_REQUEST_CMD          3

/* RETURN_CODE */
#define CY_SUCCESS              1 //成功
#define CY_FAILURE              2 //失败
#define CY_TIMEOUT              3 //超时
#define CY_ERROR                4 //异常

/* 登录类型 */
#define CY_LOGIN_PLATFORM       1 //平台登录
#define CY_LOGIN_THIRD          2 //第三方SDK登录

/* COMMAND_CODE */
#define CY_CMD_BIND_PHONE_SMS   1 //绑定手机号
#define CY_CMD_BIND_PHONE       2
#define CY_CMD_FIND_PWD_SMS     3 //找回密码
#define CY_CMD_FIND_PWD         4
#define CY_CMD_FIND_PWD_EMAIL   5
#define CY_CMD_PHONE_REG_SMS    6 //手机注册，短信验证码
#define CY_CMD_CHANGE_PWD       7 //修改密码
#define CY_CMD_ACTIVATION_CODE  8 //提交激活码
#define CY_CMD_ITUNES_PAY       9 //苹果内购

/* DATA_TYPE */
#define CY_DATA_ACCOUNT_LIST    1 //账号列表--内部用
#define CY_DATA_VERSION_UPDATE  2 //程序升级--内部用
#define CY_DATA_SERVERLIST      3 //服务器列表
#define CY_DATA_ONLINE_CONFIG   4 //在线参数
#define CY_DATA_APP_LIST        5 //应用推荐
#define CY_DATA_MESSAGE         6 //消息公告
#define CY_DATA_PAY_ORDERID     7 //支付订单号
#define CY_DATA_RES_VERSION     8 //资源版本升级

/* THIRD_SDK */
#define CY_SDK_NULL             0  //未知
//#define CY_SDK_MOBILE_MM        1  //移动MM
//#define CY_SDK_MOBILE_GAME      2  //移动游戏基地
//#define CY_SDK_UNICOM_WO        3  //联通沃商店
//#define CY_SDK_TELECOM_EGAME    4  //电信爱游戏
//#define CY_SDK_XIAOMI           5  //小米
//#define CY_SDK_UC               6  //UC
//#define CY_SDK_HUAWEI           7  //华为
//#define CY_SDK_OPPO             8  //OPPO
//#define CY_SDK_360              9  //360
//#define CY_SDK_DUOKU           10  //百度多酷
//#define CY_SDK_91              11  //91IOS--未接入
//#define CY_SDK_ANZHI           12  //安智
#define CY_SDK_KY              13  //快用-IOS
//#define CY_SDK_KK              14  //KK唱响
//#define CY_SDK_LENOVO          15  // 联想
//#define CY_SDK_GIONEE          16  // 金立
//#define CY_SDK_BAIDU           17  // 百度移动游戏
//#define CY_SDK_COOLPAD         18  // 酷派
//#define CY_SDK_GFAN            19  // 机锋网
//#define CY_SDK_WANDOUJIA       20  // 豌豆荚
//#define CY_SDK_APPCHINA        21  // 应用汇
#define CY_SDK_WEIXIN          22  // 微信支付
#define CY_SDK_ALIPAY          23  // 支付宝支付

#define CY_SDK_QQ              100 //QQ
#define CY_SDK_AiSi            101 //AiSi
#define CY_SDK_ITOOLS          102 //iTools
#define CY_SDK_FACEVISA        103 //FaceVisa

/* 请求参数(接口入参中有NSDictionary类型的，其Key在此定义) */
#define CY_PARAM_SID           @"sid"
#define CY_PARAM_UID           @"uid"
#define CY_PARAM_SESSION       @"session"
#define CY_PARAM_TOKEN         @"token"
#define CY_PARAM_TOKEN_SECRET  @"tokenSecret"
#define CY_PARAM_PHONE         @"phone"
#define CY_PARAM_CODE          @"code"
#define CY_PARAM_PASSWORD      @"password"
#define CY_PARAM_EMAIL         @"email"
#define CY_PARAM_PRODUCTID     @"productid"
#define CY_PARAM_CONSUMECODE   @"consumecode"
#define CY_PARAM_FEE           @"fee"
#define CY_PARAM_TYPE          @"type"
#define CY_PARAM_PACKAGEID     @"packageid"
#define CY_PARAM_OPENID        @"openid"

#endif