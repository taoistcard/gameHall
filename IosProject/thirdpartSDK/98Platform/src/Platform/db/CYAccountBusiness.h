//
//  CYAccountBusiness.h
//  98Platform
//
//  Created by 张克敏 on 14-4-29.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYSQLiteOpenHelper.h"
#import "CYAccountBean.h"

#define CY_ACCOUNT_LIMIT 5

@interface CYAccountBusiness : NSObject <CYSQLiteOpenHelperDelegate>
- (NSArray *)getAccountList;
- (void)updatePassword:(NSString *)password userName:(NSString *)userName;
- (void)updateAvatar:(NSString *)avatar userName:(NSString *)userName;
- (void)mergeAccount:(CYAccountBean *)account;
- (void)syncAccountList:(NSArray *)list;
@end
