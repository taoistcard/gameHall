//
//  QQRuntime.m
//  Unity-iPhone
//
//  Created by Snail on 2/10/15.
//
//

#import "QQRuntime.h"

@implementation QQRuntime


@synthesize Token=_Token;
@synthesize OpenID=_OpenID;

static QQRuntime* _QQRuntimeInstance=nil;

+(QQRuntime*) Instance
{
    if(_QQRuntimeInstance==nil)
    {
        _QQRuntimeInstance =[[QQRuntime alloc] init];
    }
    return _QQRuntimeInstance;
}

-(id) init
{
    self=[super init];
    if(self)
    {
        [self InitDic];
    }
    return self;
}
-(void)dealloc
{
    [self SaveDic];
    [super dealloc];
}


-(void) InitDic
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"QQPlatform" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (!dict || [dict count] == 0)
    {
        return;
    }
    self.Token=[dict objectForKey:@"Token"];
    self.OpenID=[dict objectForKey:@"OpenID"];
}
-(void)SaveDic
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"QQPlatform" ofType:@"plist"];
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:self.Token,@"Token",self.OpenID,@"OpenID",nil];
    [dict writeToFile:path atomically:YES];

}
@end
