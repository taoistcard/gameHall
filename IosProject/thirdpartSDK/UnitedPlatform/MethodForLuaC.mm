#import <Foundation/Foundation.h>
#include "base/ZipUtils.h"

@interface Tools : NSObject {
}
+ (void)uncompressZip:(NSDictionary *) parm;
@end;


//@interface Tools ()
//+ (NSError *)inflateErrorWithCode:(int)code;
//@end;

//NS_CC_BEGIN

@implementation Tools

+ (void)uncompressZip:(NSDictionary *) parm
//(char* filename, char* destPath)
{

    char *zip = (char *) [[parm objectForKey:@"zip"] cStringUsingEncoding:NSASCIIStringEncoding];
    char *dir = (char *) [[parm objectForKey:@"dir"] cStringUsingEncoding:NSASCIIStringEncoding];
    
//    cocos2d::ZipUtils::uncompressDir(zip, dir);

}

@end

//NS_CC_END

//bool ZipUtils::uncompressDir(char* filename, char* destPath)