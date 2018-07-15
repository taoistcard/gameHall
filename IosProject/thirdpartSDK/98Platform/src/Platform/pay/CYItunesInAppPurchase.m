//
//  CYItunesInAppPurchase.m
//  98Platform
//
//  Created by 张克敏 on 2013-04-27.
//  Copyright (c) 2013年 CY.98PK All rights reserved.
//

#import "CYItunesInAppPurchase.h"
#import "CYHttpDefine.h"
#import "CYHttpHelper.h"
#import "CYPlatform.h"
#import "CYTextUtil.h"
#import "CYDataHandler.h"
#import "CYProgressView.h"
#import "CYConstants.h"

#import "NSString+MD5Addition.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "CYAppPurchaseObject.h"

#define CYITUNES_INAPP_PURCHASE_PERSISTENT_TEMP @"CYITUNES_INAPP_PURCHASE_PERSISTENT_TEMP"

#define CYITUNES_PERMANENT_FILE  @"CYITUNES_PERMANENT_FILE.plist"

@interface CYItunesInAppPurchase ()
{
    // 支付点
    NSArray*        _productArray;
    // 等待提示
    CYProgressView* _progressView;
    // 待支付的订单号
    NSString*       _orderID;
    // 待验证的订单信息
    NSMutableDictionary     *_permanentData;
    // 待验证订单保存路径
    NSString *_filePath;
    //补单的订单号
    NSString*       _restoreOrderID;
}
@end


CYItunesInAppPurchase *g_CYItunesInAppPurchase = nil;
@implementation CYItunesInAppPurchase

+ (CYItunesInAppPurchase *)shareItunesInAppPurchase
{
    if (!g_CYItunesInAppPurchase)
    {
        g_CYItunesInAppPurchase = [[CYItunesInAppPurchase alloc] init];
    }
    return g_CYItunesInAppPurchase;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        // 载入存盘数据
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _filePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:CYITUNES_PERMANENT_FILE] retain];
        _permanentData = [[NSMutableDictionary alloc] initWithContentsOfFile:_filePath];
        if (_permanentData == nil)
        {
            _permanentData = [[NSMutableDictionary alloc] initWithCapacity:4];
        }
    }
    return self;
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [_productArray release];
    [_orderID release];
    [_progressView release];
    [_permanentData release];
    [_restoreOrderID release];
    [super dealloc];
}

- (void)alertWithMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)creatProgressViewToView:(UIView *)view
{
    if (_progressView)
    {
        return;
    }
    _progressView = [[CYProgressView alloc] initWithFrame:view.bounds];
    [view addSubview:_progressView];
}

- (void)progressWithMessage:(NSString *)msg
{
    if (_progressView)
    {
        [_progressView setText:msg];
        [_progressView show];
    }
}

- (void)closeProgress
{
    if (_progressView)
    {
        [_progressView dismiss];
        [_progressView removeFromSuperview];
        [_progressView release];
        _progressView = nil;
    }
}

- (void)itunesPurchase:(CYDataHandler *)dataHander request:(ASIFormDataRequest *)request
{
    if ([dataHander isSuccess])
    {
        id value = [dataHander stringForKey:@"OrderID"];
        if (![value isKindOfClass:[NSString class]])
        {
            return;
        }
        _orderID = [[NSString alloc] initWithString:value];
        [self progressWithMessage:@"正在连接Itunes，请稍候。。。"];
        
        // 开始连接Itunes
        NSString *productID = [request postValueForKey:@"productid"];
        
        // 支付点是否已经Download下来了
        SKPayment *payment = nil;
        if (_productArray)
        {
            for (SKProduct *product in _productArray)
            {
                if ([productID isEqualToString:product.productIdentifier])
                {
                    payment = [SKPayment paymentWithProduct:product];
                    break;
                }
            }
        }
        if (!payment)
        {
            payment = [SKPayment paymentWithProductIdentifier:productID];
        }
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        // 将订单号临时存盘
        [self savePersistentOrderID];
    }
    else
    {
        // 关闭提示
        [self closeProgress];
        // 错误原因
        [self alertWithMessage:[dataHander errorMsg:@"订单生成失败，请联系客服"]];
    }
}

#pragma mark - persistent
- (void)savePersistentOrderID
{
    if ([CYTextUtil isEmpty:_orderID])
    {
        return;
    }
    NSDictionary *temp = [NSDictionary dictionaryWithObject:_orderID forKey:@"CurrentOrderID"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:temp forKey:CYITUNES_INAPP_PURCHASE_PERSISTENT_TEMP];
    [userDefaults synchronize];
}

- (NSString *)getPersistentOrderID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [userDefaults dictionaryForKey:CYITUNES_INAPP_PURCHASE_PERSISTENT_TEMP];
    if (dict && [dict count] > 0)
    {
        id currentOrderID = [dict objectForKey:@"CurrentOrderID"];
        if ([currentOrderID isKindOfClass:[NSString class]])
        {
            return (NSString *)currentOrderID;
        }
    }
    return nil;
}

- (void)recordReceipt:(NSString *)receipt orderID:(NSString *)orderID
{
    NSDate* curTime = [NSDate date];// 获取本地时间
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];  // 格式化时间NSDate
    NSString* stringFromDate = [formatter stringFromDate:curTime];
    
    
    NSString* orderTimer =[NSString stringWithFormat:@"%d|##|%@|##|%@",[[[CYPlatform sharePlatform] userInfo] userID],receipt,stringFromDate];
    [_permanentData setObject:orderTimer forKey:orderID];
    
    [self savePermanentData];
}

- (void)savePermanentData
{
    if (_permanentData)
    {
        [_permanentData writeToFile:_filePath atomically:NO];
    }
}

// 服务器验证通过，删除本地记录
- (void)removeRecord:(BOOL)restore
{
    //
    [_permanentData removeObjectForKey:_orderID];
    [self savePermanentData];
    
    // 非补单，则删除内存中订单号
    if (!restore)
    {
        [self removeOrderID];
    }
}
    
- (void)removeOrderID
{
    if (_orderID)
    {
        [_orderID release];
        _orderID = nil;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CYITUNES_INAPP_PURCHASE_PERSISTENT_TEMP];
    [userDefaults synchronize];
}

#pragma mark - api
-(NSArray*)achiveRestorePurchaseList
{
    NSMutableArray * returnArray = [NSMutableArray arrayWithCapacity:5];
    if([[CYPlatform sharePlatform] userInfo])
    {
        NSEnumerator *enumerator = [_permanentData keyEnumerator];
        NSString* key;
        while ((key = [enumerator nextObject])) {
            NSString* value = [_permanentData objectForKey:key];
            NSArray *b = [value componentsSeparatedByString:@"|##|"];
            
            NSString* idString = [b  objectAtIndex:0];
            int UserID = [idString intValue];
            if([[[CYPlatform sharePlatform] userInfo] userID]==UserID)
            {
                CYAppPurchaseObject* ob = [CYAppPurchaseObject creatWithUserID:UserID orderID:key receipt:[b  objectAtIndex:1] orderDate:[b  objectAtIndex:2]];
                [returnArray addObject:ob];
            }
        }
    }
    return returnArray;
}

// 补单
- (void)restorePurchaseWithOrderID:(NSString *)orderID receipt:(NSString *)receipt view:(UIView *)view
{
    if([_permanentData objectForKey:orderID])
    {
        // 提示等待
        [self creatProgressViewToView:view];
        [self progressWithMessage:@"正在验证订单，请稍候。。。"];
        _restoreOrderID = [[NSString alloc] initWithString:orderID];
        [CYHttpHelper requestApplePayFinish:orderID receipt:receipt contextID:CY_CONTEXTID_APPLE_RESTORE handler:self];
    }
}

// 去Itunes下载支付点
- (void)downloadProductsWithArray:(NSArray *)products
{
    if (![SKPaymentQueue canMakePayments] || !products || [products count] == 0)
    {
        return;
    }
    NSSet *set = [NSSet setWithArray:products];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
    [request autorelease];
}

- (void)purchaseWithProductID:(NSString *)productID view:(UIView *)view;
{
    if (![SKPaymentQueue canMakePayments])
    {
        return;
    }
    if (![CYTextUtil isEmpty:_orderID] || [CYTextUtil isEmpty:productID] || !view)
    {
        return;
    }
    // 提示等待
    [self creatProgressViewToView:view];
    [self progressWithMessage:@"正在生成订单，请稍候。。。"];
    
    // 获取订单号
    NSString *sessionID = [CYPlatform sharePlatform].sessionID;
    [CYHttpHelper requestApplePayOrderID:productID sessionID:sessionID contextID:CY_CONTEXTID_DATA_GETORDERID handler:self];
}

- (void)purchaseWithPackageID:(NSString *)packageID productID:(NSString *)productID view:(UIView *)view
{
    if (![SKPaymentQueue canMakePayments])
    {
        return;
    }
    if (![CYTextUtil isEmpty:_orderID] || [CYTextUtil isEmpty:productID] || !view)
    {
        return;
    }
    // 提示等待
    [self creatProgressViewToView:view];
    [self progressWithMessage:@"正在生成订单，请稍候。。。"];
    
    // 获取订单号
    NSString *sessionID = [CYPlatform sharePlatform].sessionID;
    [CYHttpHelper requestApplePayPackageOrderID:packageID productID:productID sessionID:sessionID contextID:CY_CONTEXTID_DATA_GETORDERID handler:self];
}

#pragma mark - ASIHTTPRequestDelegate
// 补单请求处理
- (void)processRestore:(CYDataHandler *)dataHandler orderID:(NSString *)orderID
{
    // 关闭提示
    [self closeProgress];
    if ([dataHandler isSuccess] && [CYTextUtil equals:orderID string2:_restoreOrderID])
    {
        [_permanentData removeObjectForKey:_restoreOrderID];
        [self savePermanentData];
        _restoreOrderID = nil;
        NSInteger resultCode = CY_SUCCESS;
        NSString* message = @"亲，恭喜您产品购买成功！欢迎下次光临！";
        [self alertWithMessage:message];
        
        if ([CYPlatform sharePlatform].commandDelegate)
        {
            [[CYPlatform sharePlatform].commandDelegate onCYCommandResult:resultCode cmd:CY_CMD_ITUNES_PAY error:message];
        }
    }
    else if (![dataHandler isSuccess])
    {
        // 关闭提示
        [self closeProgress];
        [self alertWithMessage:[dataHandler errorMsg:@"补单验证订单失败，请联系客服"]];
    }
    if ([@"PAY_BUSINESS_FINDAPPLYORDER_ORDER_NOT_FOUND" isEqualToString:[dataHandler errorSign]] && [CYTextUtil equals:orderID string2:_restoreOrderID])
    {
        [_permanentData removeObjectForKey:_restoreOrderID];
        [self savePermanentData];
        _restoreOrderID = nil;
        // 关闭提示
        [self closeProgress];
    }
}

// 验单请求处理
- (void)processFinish:(CYDataHandler *)dataHandler
{
    // 关闭提示
    [self closeProgress];
    
    NSInteger resultCode = 0;
    NSString *message = nil;
    if ([dataHandler isSuccess])
    {
        // 验单成功，删除存盘记录
        [self removeRecord:NO];
        resultCode = CY_SUCCESS;
        message = @"亲，恭喜您产品购买成功！欢迎下次光临！";
    }
    else
    {
        // 验单失败
        [self removeOrderID];
        resultCode = CY_FAILURE;
        message = [dataHandler errorMsg:@"对不起，产品购买失败，请联系客服！"];
    }
    [self alertWithMessage:message];
    
    if ([CYPlatform sharePlatform].commandDelegate)
    {
        [[CYPlatform sharePlatform].commandDelegate onCYCommandResult:resultCode cmd:CY_CMD_ITUNES_PAY error:message];
    }
}

- (void)requestFinished:(ASIFormDataRequest *)request
{
    CYDataHandler *dataHandler = [CYDataHandler handlerWithData:[request responseData]];
    if (dataHandler == nil)
    {
        return;
    }
    
    switch (request.tag)
    {
        case CY_CONTEXTID_DATA_GETORDERID://获取订单
            [self itunesPurchase:dataHandler request:request];
            break;
        case CY_CONTEXTID_APPLE_RESTORE://漏单验证
            [self processRestore:dataHandler orderID:[request postValueForKey:@"orderid"]];
            break;
        case CY_CONTEXTID_APPLE_FINISH://支付验单
            [self processFinish:dataHandler];
            break;
    }
}

- (void)requestFailed:(ASIFormDataRequest *)request
{
    if (request.tag == CY_CONTEXTID_APPLE_RESTORE)
    {
        return;
    }
    [self removeOrderID];
    [self closeProgress];
    [self alertWithMessage:@"请求失败，请检查网络"];
    
    if (request.tag == CY_CONTEXTID_APPLE_FINISH)
    {
        if ([CYPlatform sharePlatform].commandDelegate)
        {
            [[CYPlatform sharePlatform].commandDelegate onCYCommandResult:CY_TIMEOUT cmd:CY_CMD_ITUNES_PAY error:@"请求超时"];
        }
    }
}

#pragma mark - process SKPaymentTransaction
- (void)finishTransaction:(SKPaymentTransaction *)transaction success:(BOOL)success
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    if (success)
    {
        if ([CYTextUtil isEmpty:_orderID])
        {
            // 修复BUG，应用退出有收到了充值结果，这时内存中没有订单号了
            _orderID = [self getPersistentOrderID];
        }
        if ([CYTextUtil isEmpty:_orderID])
        {
            [self closeProgress];
            return;
        }
        // Itunes购买成功，记录并验证该笔订单
        NSString *receipt = [GTMBase64 stringByEncodingData:transaction.transactionReceipt];
        [self recordReceipt:receipt orderID:_orderID];
        [self progressWithMessage:@"正在验单订单，请稍候。。。"];
        [CYHttpHelper requestApplePayFinish:_orderID receipt:receipt contextID:CY_CONTEXTID_APPLE_FINISH handler:self];
    }
    else
    {
        [self removeOrderID];
        
        // 失败，或者取消购买
        if (transaction.error.code != SKErrorPaymentCancelled)
        {
            NSString *error = transaction.error.localizedDescription;
            if ([CYTextUtil isEmpty:error])
            {
                error = @"购买超时，请尝试重新购买！";
            }
            [self alertWithMessage:error];
        }
        
        [self closeProgress];
    }
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *productArray = response.products;
    if (productArray && [productArray count] > 0)
    {
        _productArray = [[NSArray alloc] initWithArray:productArray];
    }
}

#pragma mark - SKPaymentTransactionObserver protocol
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *t in transactions)
    {
        switch (t.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                [self progressWithMessage:@"Itunes正在处理此订单，请稍候。。。"];
                break;
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                [self finishTransaction:t success:YES];
                break;
            case SKPaymentTransactionStateFailed:
                [self finishTransaction:t success:NO];
                break;
            default:
                break;
        }
    }
}

@end
