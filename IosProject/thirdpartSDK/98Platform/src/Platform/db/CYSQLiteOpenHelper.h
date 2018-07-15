//
//  CYSQLiteOpenHelper.h
//  98Platform
//
//  Created by 张克敏 on 14-4-29.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@protocol CYSQLiteOpenHelperDelegate;

@interface CYSQLiteOpenHelper : NSObject
{
    id<CYSQLiteOpenHelperDelegate> _delegate;
    NSString*                      _path;
}

@property(nonatomic,assign) id<CYSQLiteOpenHelperDelegate> delegate;

- (id)initWithFile:(NSString *)path;

- (BOOL)openDatabase;
- (void)closeDatabase;

- (BOOL)execWithSQL:(NSString *)sql;
- (NSArray *)selectDataWithSQL:(NSString *)sql;
@end


@protocol CYSQLiteOpenHelperDelegate <NSObject>
- (void)onCreateTable:(sqlite3 *)database;
@end