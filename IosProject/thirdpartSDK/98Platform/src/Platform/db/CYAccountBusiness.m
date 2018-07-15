//
//  CYAccountBusiness.m
//  98Platform
//
//  Created by 张克敏 on 14-4-29.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import "CYAccountBusiness.h"
#import "CYSQLiteOpenHelper.h"
#import "CYTextUtil.h"

#import <UIKit/UIPasteboard.h>

/* 数据库表定义 */
#define CY_DB_FILE         @"cyplatform.db"
#define CY_ACCOUNT_TABLE   @"account"
#define CY_COLUMN_USERID   @"userid"
#define CY_COLUMN_USERNAME @"username"
#define CY_COLUMN_NICKNAME @"nickname"
#define CY_COLUMN_PASSWORD @"password"
#define CY_COLUMN_AVATAR   @"avatar"
#define CY_COLUMN_TIME     @"atime"

/* 剪切板定义 */
#define CY_PB_NAME         @"cn._98game.platform.pb.act"
#define CY_PB_TYPE         @"act_item"

@interface CYAccountBusiness ()
{
    CYSQLiteOpenHelper *_helper;
}
@end

@implementation CYAccountBusiness

#pragma mark - function
+ (NSString *)null2String:(NSString *)str
{
    if ([CYTextUtil isEmpty:str])
    {
        return @"";
    }
    return str;
}

+ (NSString *)currentTimeMillis
{
    long long millis = [[NSDate date] timeIntervalSince1970] * 1000;
    return [NSString stringWithFormat:@"%lld", millis];
}

+ (NSArray *)listFromDatabase:(CYSQLiteOpenHelper *)helper
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC LIMIT %d", CY_ACCOUNT_TABLE, CY_COLUMN_TIME, CY_ACCOUNT_LIMIT];
    NSArray *rs = [helper selectDataWithSQL:sql];
    
    if (!rs || [rs count] == 0)
    {
        return nil;
    }
    
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:[rs count]];
    for (NSDictionary *dict in rs)
    {
        NSNumber *userID = [dict objectForKey:CY_COLUMN_USERID];
        if (!userID || [userID integerValue] < 1)
        {
            continue;
        }
        NSString *userName = [dict objectForKey:CY_COLUMN_USERNAME];
        if ([CYTextUtil isEmpty:userName])
        {
            continue;
        }
        NSString *nickName = [dict objectForKey:CY_COLUMN_NICKNAME];
        NSString *password = [dict objectForKey:CY_COLUMN_PASSWORD];
        NSString *avatar = [dict objectForKey:CY_COLUMN_AVATAR];
        NSString *atime = [dict objectForKey:CY_COLUMN_TIME];
        CYAccountBean *bean = [CYAccountBean creatWithUserID:[userID integerValue] userName:userName nickName:nickName password:password avatar:avatar];
        [bean setAtime:atime];
        [list addObject:bean];
    }
    return list;
}

+ (NSArray *)listFromPasteboard:(UIPasteboard *)pasteboard
{
    NSData *data = [pasteboard dataForPasteboardType:CY_PB_TYPE];
    if (data && [data length] > 0)
    {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:[array count]];
        for (NSDictionary *dict in array)
        {
            NSNumber *userID = [dict objectForKey:@"uid"];
            NSString *userName = [dict objectForKey:@"uname"];
            if (!userID || userID.integerValue < 1 || [CYTextUtil isEmpty:userName])
            {
                continue;
            }
            
            NSString *password = [dict objectForKey:@"upwd"];
            NSString *atime = [dict objectForKey:@"tm"];
            if ([CYTextUtil isEmpty:password])
            {
                password = @"";
            }
            if ([CYTextUtil isEmpty:atime])
            {
                atime = [CYAccountBusiness currentTimeMillis];
            }
            
            CYAccountBean *bean = [CYAccountBean creatWithUserID:userID.integerValue userName:userName nickName:nil password:password avatar:nil];
            [bean setAtime:atime];
            [list addObject:bean];
        }
        return list;
    }
    return nil;
}

+ (void)sync2Pasteboard:(UIPasteboard *)board array:(NSArray *)array
{
    if (!array || [array count] == 0)
    {
        return;
    }
    // 将本地账号同步到剪切板
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:[array count]];
    for (CYAccountBean *bean in array)
    {
        NSString *password = [CYAccountBusiness null2String:bean.password];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInteger:bean.userID], @"uid",
                              bean.userName, @"uname",
                              password,      @"upwd",
                              bean.atime,    @"tm",
                              nil];
        [dataArray addObject:dict];
    }
    [board setData:[NSKeyedArchiver archivedDataWithRootObject:dataArray] forPasteboardType:CY_PB_TYPE];
}

+ (void)sync2Database:(CYSQLiteOpenHelper *)helper array:(NSArray *)array
{
    // 将剪切板账号同步到数据库
    for (CYAccountBean *bean in array)
    {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@) VALUES (%d, '%@', '%@', '%@', '%@', '%@')",
                         CY_ACCOUNT_TABLE,
                         CY_COLUMN_USERID, CY_COLUMN_USERNAME, CY_COLUMN_NICKNAME, CY_COLUMN_PASSWORD, CY_COLUMN_AVATAR, CY_COLUMN_TIME,
                         bean.userID, bean.userName, @"", bean.password, @"", bean.atime];
        [helper execWithSQL:sql];
    }
}

+ (NSArray *)syncWithCompare:(NSArray *)loaclArray pbArray:(NSArray *)pbArray helper:(CYSQLiteOpenHelper *)helper pasteboard:(UIPasteboard *)pasteboard
{
    BOOL dbChanged = NO;
    BOOL pbChanged = NO;
    
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:[loaclArray count]];
    for (CYAccountBean *bean in loaclArray)
    {
        [keys addObject:[NSNumber numberWithInteger:bean.userID]];
    }
    
    for (CYAccountBean *bean1 in pbArray)
    {
        NSNumber *key = [NSNumber numberWithInteger:bean1.userID];
        NSUInteger index = [keys indexOfObject:key];
        if (index == NSNotFound)
        {
            NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = %d", CY_COLUMN_USERID, CY_ACCOUNT_TABLE, CY_COLUMN_USERID, bean1.userID];
            NSArray *rs = [helper selectDataWithSQL:sql];
            if (rs && [rs count] > 0)
            {
                // update
                sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ = %d",
                       CY_ACCOUNT_TABLE,
                       CY_COLUMN_TIME, bean1.atime,
                       CY_COLUMN_USERID, bean1.userID];
                [helper execWithSQL:sql];
            }
            else
            {
                // insert
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@) VALUES (%d, '%@', '%@', '%@', '%@', '%@')",
                                 CY_ACCOUNT_TABLE,
                                 CY_COLUMN_USERID, CY_COLUMN_USERNAME, CY_COLUMN_NICKNAME, CY_COLUMN_PASSWORD, CY_COLUMN_AVATAR, CY_COLUMN_TIME,
                                 bean1.userID, bean1.userName, @"", bean1.password, @"", bean1.atime];
                [helper execWithSQL:sql];
            }
            dbChanged = YES;
        }
        else
        {
            CYAccountBean *bean2 = [loaclArray objectAtIndex:index];
            long long time2 = [bean2.atime longLongValue];
            long long time1 = [bean1.atime longLongValue];
            if (time2 < time1)
            {
                // update
                NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ = %d",
                                 CY_ACCOUNT_TABLE,
                                 CY_COLUMN_TIME, bean1.atime,
                                 CY_COLUMN_USERID, bean1.userID];
                [helper execWithSQL:sql];
                
                dbChanged = YES;
            }
            else if (time2 > time1)
            {
                pbChanged = YES;
            }
        }
    }
    
    if (dbChanged)
    {
        NSArray *array = [CYAccountBusiness listFromDatabase:helper];
        [CYAccountBusiness sync2Pasteboard:pasteboard array:array];
        return array;
    }
    else
    {
        if (pbChanged)
        {
            [CYAccountBusiness sync2Pasteboard:pasteboard array:loaclArray];
        }
        return loaclArray;
    }
}

#pragma mark - LifeCycle
- (id)init
{
    self = [super init];
    if (self)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:CY_DB_FILE];
        _helper = [[CYSQLiteOpenHelper alloc] initWithFile:path];
        _helper.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [_helper release];
    [super dealloc];
}

#pragma mark - API
- (void)onCreateTable:(sqlite3 *)database
{
    char *errorMsg = nil;
    NSString *sql = @"CREATE TABLE IF NOT EXISTS account "
                     "(_id INTEGER PRIMARY KEY AUTOINCREMENT, "
                     "userid INTEGER, "
                     "username TEXT, "
                     "nickname TEXT, "
                     "password TEXT, "
                     "avatar TEXT, "
                     "atime TEXT)";
    sqlite3_exec(database, [sql UTF8String], nil, nil, &errorMsg);
}

- (NSArray *)getAccountList
{
    [_helper openDatabase];
    
    // result array
    NSArray *accountList = nil;
    
    // db data
    NSArray *dbArray = [CYAccountBusiness listFromDatabase:_helper];
    
    // pb data
    UIPasteboard *board = [UIPasteboard pasteboardWithName:CY_PB_NAME create:YES];
    NSArray *pbArray = [CYAccountBusiness listFromPasteboard:board];
    board.persistent = YES;
    
    // merge process
    if (pbArray && [pbArray count] > 0)
    {
        if (dbArray && [dbArray count] > 0)
        {
            accountList = [CYAccountBusiness syncWithCompare:dbArray pbArray:pbArray helper:_helper pasteboard:board];
        }
        else
        {
            accountList = pbArray;
            [CYAccountBusiness sync2Database:_helper array:pbArray];
        }
    }
    else
    {
        accountList = dbArray;
        [CYAccountBusiness sync2Pasteboard:board array:dbArray];
    }
    
    [_helper closeDatabase];
    return accountList;
}

// 更新账号密码
- (void)updatePassword:(NSString *)password userName:(NSString *)userName
{
    if ([CYTextUtil isEmpty:password])
    {
        return;
    }
    
    [_helper openDatabase];
    
    NSString *time = [CYAccountBusiness currentTimeMillis];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@', %@ = '%@' WHERE %@ = '%@'",
                     CY_ACCOUNT_TABLE,
                     CY_COLUMN_TIME, time,
                     CY_COLUMN_PASSWORD, password,
                     CY_COLUMN_USERNAME, userName];
    [_helper execWithSQL:sql];
    
    [_helper closeDatabase];
    
    // 同步到剪切板
    UIPasteboard *board = [UIPasteboard pasteboardWithName:CY_PB_NAME create:NO];
    NSArray *array = [CYAccountBusiness listFromPasteboard:board];
    if (!array || [array count] == 0)
    {
        return;
    }
    CYAccountBean *find = nil;
    NSUInteger index = NSNotFound;
    for (NSUInteger i = 0; i < [array count]; i++)
    {
        CYAccountBean *bean = [array objectAtIndex:i];
        if ([userName isEqualToString:bean.userName])
        {
            find = bean;
            index = i;
        }
    }
    if (find)
    {
        NSMutableArray *pbArray = [NSMutableArray arrayWithArray:array];
        CYAccountBean *bean = [CYAccountBean creatWithUserID:find.userID userName:find.userName nickName:nil password:password avatar:nil];
        [pbArray replaceObjectAtIndex:index withObject:bean];
        [CYAccountBusiness sync2Pasteboard:board array:pbArray];
    }
}

- (void)updateAvatar:(NSString *)avatar userName:(NSString *)userName
{
    if ([CYTextUtil isEmpty:avatar])
    {
        return;
    }
    
    [_helper openDatabase];
    
    avatar = [CYAccountBusiness null2String:avatar];
    NSString *time = [CYAccountBusiness currentTimeMillis];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@', %@ = '%@' WHERE %@ = '%@'",
                     CY_ACCOUNT_TABLE,
                     CY_COLUMN_TIME, time,
                     CY_COLUMN_AVATAR, avatar,
                     CY_COLUMN_USERNAME, userName];
    [_helper execWithSQL:sql];
    
    [_helper closeDatabase];
}

// 账号登录或注册
- (void)mergeAccount:(CYAccountBean *)account
{
    if (!account || [CYTextUtil isEmpty:account.password])
    {
        return;
    }
    
    [_helper openDatabase];
    NSString *time = [CYAccountBusiness currentTimeMillis];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = %d", CY_COLUMN_USERID, CY_ACCOUNT_TABLE, CY_COLUMN_USERID, account.userID];
    NSArray *rs = [_helper selectDataWithSQL:sql];
    if (rs && [rs count] > 0)
    {
        // 更新用户
        sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@' WHERE %@ = %d",
               CY_ACCOUNT_TABLE,
               CY_COLUMN_USERNAME, account.userName,
               CY_COLUMN_NICKNAME, [CYAccountBusiness null2String:account.nickName],
               CY_COLUMN_PASSWORD, account.password,
               CY_COLUMN_AVATAR, [CYAccountBusiness null2String:account.avatar],
               CY_COLUMN_TIME, time,
               CY_COLUMN_USERID, account.userID];
        [_helper execWithSQL:sql];
    }
    else
    {
        // 新增用户
        sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@) VALUES (%d, '%@', '%@', '%@', '%@', '%@')",
               CY_ACCOUNT_TABLE,
               CY_COLUMN_USERID, CY_COLUMN_USERNAME, CY_COLUMN_NICKNAME, CY_COLUMN_PASSWORD, CY_COLUMN_AVATAR, CY_COLUMN_TIME,
               account.userID, account.userName, [CYAccountBusiness null2String:account.nickName], account.password, [CYAccountBusiness null2String:account.avatar], time];
        [_helper execWithSQL:sql];
    }
    
    [_helper closeDatabase];
    
    // 同步到剪切板
    UIPasteboard *board = [UIPasteboard pasteboardWithName:CY_PB_NAME create:NO];
    NSArray *array = [CYAccountBusiness listFromPasteboard:board];
    if (array && [array count] > 0)
    {
        BOOL find = NO;
        for (CYAccountBean *bean in array)
        {
            if (bean.userID == account.userID)
            {
                bean.atime = time;
                find = YES;
            }
        }
        if (!find)
        {
            NSMutableArray *pbArray = [NSMutableArray arrayWithArray:array];
            if ([pbArray count] >= CY_ACCOUNT_LIMIT)
            {
                [pbArray removeLastObject];
            }
            [pbArray addObject:account];
            
            array = pbArray;
        }
    }
    else
    {
        array = [NSArray arrayWithObject:account];
    }
    [CYAccountBusiness sync2Pasteboard:board array:array];
}

// 同步账号列表
- (void)syncAccountList:(NSArray *)list
{
    if (!list || [list count] == 0)
    {
        return;
    }
    
    // 同步到数据库
    [_helper openDatabase];
    
    NSString *time = [CYAccountBusiness currentTimeMillis];
    for (CYAccountBean *bean in list)
    {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@) VALUES (%d, '%@', '%@', '%@', '%@', '%@')",
                         CY_ACCOUNT_TABLE,
                         CY_COLUMN_USERID, CY_COLUMN_USERNAME, CY_COLUMN_NICKNAME, CY_COLUMN_PASSWORD, CY_COLUMN_AVATAR, CY_COLUMN_TIME,
                         bean.userID, bean.userName, [CYAccountBusiness null2String:bean.nickName], @"", [CYAccountBusiness null2String:bean.avatar], time];
        [_helper execWithSQL:sql];
        [bean setAtime:time];
    }
    
    [_helper closeDatabase];
    
    // 同步到剪切板
    UIPasteboard *board = [UIPasteboard pasteboardWithName:CY_PB_NAME create:NO];
    [CYAccountBusiness sync2Pasteboard:board array:list];
}

@end
