//
//  QQPlatform.h
//  Unity-iPhone
//
//  Created by Snail on 2/2/15.
//
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
@interface QQPlatform : NSObject<TencentSessionDelegate>
{
    TencentOAuth* _TencentOAuth;
}

@property(nonatomic,retain) TencentOAuth *Tencent;

-(BOOL)QQLogin;
-(BOOL)QQLOginOut;
+(QQPlatform*) Instance;
-(BOOL)IsQQInstalled;

@end
