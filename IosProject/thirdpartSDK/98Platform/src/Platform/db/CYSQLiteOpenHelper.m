//
//  CYSQLiteOpenHelper.m
//  98Platform
//
//  Created by 张克敏 on 14-4-29.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import "CYSQLiteOpenHelper.h"

@interface CYSQLiteOpenHelper ()
{
    BOOL     _isOpened;
    sqlite3* _database;
}
@end


@implementation CYSQLiteOpenHelper
@synthesize delegate = _delegate;

- (id)initWithFile:(NSString *)path
{
    self = [self init];
    if (self)
    {
        _path = [[NSString alloc] initWithString:path];
    }
    return self;
}

- (void)dealloc
{
    [_path release];
    [super dealloc];
}

- (BOOL)openDatabase
{
    if (_isOpened)
    {
        return YES;
    }
    int code = sqlite3_open([_path UTF8String], &_database);
    if (code == SQLITE_OK)
    {
        if (_delegate)
        {
            [_delegate onCreateTable:_database];
        }
        _isOpened = YES;
    }
    NSLog(@"open db code=%d", code);
    return _isOpened;
}

- (void)closeDatabase
{
    if (!_isOpened)
    {
        return;
    }
    _isOpened = NO;
    sqlite3_close(_database);
}

- (BOOL)execWithSQL:(NSString *)sql
{
    char *errorMsg = nil;
    int code = sqlite3_exec(_database, [sql UTF8String], nil, nil, &errorMsg);
    if (code == SQLITE_OK)
    {
        return YES;
    }
    NSLog(@"exec data failed. code=%d", code);
    return NO;
}

- (NSArray *)selectDataWithSQL:(NSString *)sql
{
    sqlite3_stmt *stmt;
    int code = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, nil);
    if (code == SQLITE_OK)
    {
        int count = sqlite3_column_count(stmt);
        if (count == 0)
        {
            return nil;
        }
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            // 列数
            int cols = sqlite3_data_count(stmt);
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:cols];
            for (int i = 0; i < cols; i++)
            {
                NSString *key = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
                id value = nil;
                
                int colType = sqlite3_column_type(stmt, i);
                switch (colType)
                {
                    case SQLITE_INTEGER:
                        value = [NSNumber numberWithInt:sqlite3_column_int(stmt, i)];
                        break;
                    case SQLITE_FLOAT:
                        value = [NSNumber numberWithDouble:sqlite3_column_double(stmt, i)];
                        break;
                    case SQLITE_NULL:
                        break;
                    case SQLITE_TEXT:
                    default:
                        value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i)];
                        break;
                }
                if (key && value)
                {
                    [dict setObject:value forKey:key];
                }
            }
            if ([dict count] == 0)
            {
                continue;
            }
            [result addObject:dict];
        }
        return result;
    }
    sqlite3_finalize(stmt);
    NSLog(@"select data failed. code=%d", code);
    return nil;
}

@end
