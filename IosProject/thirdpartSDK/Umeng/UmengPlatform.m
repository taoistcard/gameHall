//
//  UmengPlatform.m
//  niuniu
//
//  Created by sayuokdgd on 15/4/14.
//
//

#import <Foundation/Foundation.h>
#import "UmengPlatform.h"
#import "MobClick.h"
#import "UMessage.h"

#define LuaEventID   @"1100"

@implementation UmengPlatform

static UmengPlatform* g_UmengPlatform=nil;


+(UmengPlatform*) Instance
{
    if(g_UmengPlatform==nil)
    {
        g_UmengPlatform =[[UmengPlatform alloc] init];
    }
    return g_UmengPlatform;
}

-(id) init
{
    
    self=[super init];
    if(self)
    {
    }
    
    return self;
}
-(void)dealloc
{
    [super dealloc];
}

#pragma mark -
-(void)OnCustomerEvent:(NSDictionary *)eventDic
{
    NSString *eventID = [eventDic objectForKey:@"eventID"];
    NSLog(@"eventID:%@",eventID);
    [MobClick event:eventID attributes:eventDic];
}


-(void)addAlias:(NSString *)alias type:(NSString *)type
{
    
    [UMessage addAlias:alias type:type response:^(id responseObject, NSError *error) {
        if(responseObject)
        {
            NSLog(@"绑定成功！");
        }
        else
        {
            NSLog(@"绑定失败:%@",error.localizedDescription);
        }
    }];
}

-(void)removeAlias:(NSString *)alias type:(NSString *)type
{
    [UMessage removeAlias:alias type:type response:^(id responseObject, NSError *error) {
        if(responseObject)
        {
            NSLog(@"删除成功！");
        }
        else
        {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
}
-(void)onEvent:(NSString *)eventId
{NSLog(@"onEvent---umeng");
    [MobClick event:eventId];
}
-(void)onEventBegin:(NSString *)eventId
{NSLog(@"onEventBegin---umeng");
    [MobClick beginEvent:eventId];
}
-(void)onEventEnd:(NSString *)eventId
{NSLog(@"onEventEnd---umeng");
    [MobClick endEvent:eventId];
}
@end