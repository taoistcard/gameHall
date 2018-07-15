//
//  QQRuntime.h
//  Unity-iPhone
//
//  Created by Snail on 2/10/15.
//
//

#import <Foundation/Foundation.h>

@interface QQRuntime : NSObject
{
    NSString* _Token;
    NSString* _OpenID;
}
@property(nonatomic,retain) NSString* Token;
@property(nonatomic,retain) NSString* OpenID;
-(void) InitDic;
-(void) SaveDic;
+(QQRuntime*) Instance;
@end
