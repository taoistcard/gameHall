#import <Foundation/Foundation.h>

@interface CYAppPurchaseObject : NSObject
{
    // 用户ID
    NSInteger   _userID;
    // 订单ID
    NSString*   _orderID;
    // app校验信息
    NSString*   _receipt;
    // 订单日期
    NSString*   _orderDate;
}

+ (CYAppPurchaseObject *)creatWithUserID:(NSInteger)userID orderID:(NSString *)orderID receipt:(NSString *)receipt orderDate:(NSString *)orderDate;

@property(nonatomic,assign,readonly) NSInteger userID;
@property(nonatomic,retain,readonly) NSString* orderID;
@property(nonatomic,retain,readonly) NSString* receipt;
@property(nonatomic,retain,readonly) NSString* orderDate;

@end
