#import "CYAppPurchaseObject.h"
#import "CYTextUtil.h"

@interface CYAppPurchaseObject()
{
}
@end

@implementation CYAppPurchaseObject
@synthesize userID = _userID;
@synthesize orderID = _orderID;
@synthesize receipt = _receipt;
@synthesize orderDate = _orderDate;

+ (CYAppPurchaseObject *)creatWithUserID:(NSInteger)userID orderID:(NSString *)orderID receipt:(NSString *)receipt orderDate:(NSString *)orderDate
{
    if (userID < 1 || [CYTextUtil isEmpty:orderID] || [CYTextUtil isEmpty:receipt])
    {
        return nil;
    }
    return [[[CYAppPurchaseObject alloc] initWithUserID:userID orderID:orderID receipt:receipt orderDate:orderDate] autorelease];
}

- (id)initWithUserID:(NSInteger)userID orderID:(NSString *)orderID receipt:(NSString *)receipt orderDate:(NSString *)orderDate
{
    self = [self init];
    if (self)
    {
        _userID   = userID;
        _orderID = [[NSString alloc] initWithString:orderID];
        _receipt = [[NSString alloc] initWithString:receipt];
        if (orderDate)
        {
            _orderDate   = [[NSString alloc] initWithString:orderDate];
        }
    }
    return self;
}

- (void)dealloc
{
    [_orderID release];
    [_receipt release];
    [_orderDate release];
    [super dealloc];
}

@end
