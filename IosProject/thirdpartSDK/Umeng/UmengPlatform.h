//
//  UmengPlatform.h
//  niuniu
//
//  Created by sayuokdgd on 15/4/14.
//
//

#ifndef niuniu_UmengPlatform_h
#define niuniu_UmengPlatform_h

#import <Foundation/Foundation.h>
@interface UmengPlatform : NSObject
{
}

+(UmengPlatform*) Instance;
//customer event
-(void)OnCustomerEvent:(NSDictionary *)eventDic;
//add Alias
-(void)addAlias:(NSString *)alias type:(NSString *)type;
//remove Alias
-(void)removeAlias:(NSString *)alias type:(NSString *)type;
-(void)onEvent:(NSString *)eventId;
-(void)onEventBegin:(NSString *)eventId;
-(void)onEventEnd:(NSString *)eventId;
@end

#endif
