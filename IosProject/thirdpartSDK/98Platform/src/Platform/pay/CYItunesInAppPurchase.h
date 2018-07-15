//
//  CYItunesInAppPurchase.h
//  98Platform
//
//  Created by 张克敏 on 2013-04-27.
//  Copyright (c) 2013年 CY.98PK All rights reserved.
//
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "ASIHTTPRequestDelegate.h"

@interface CYItunesInAppPurchase : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate, ASIHTTPRequestDelegate>

+ (CYItunesInAppPurchase *)shareItunesInAppPurchase;

// 根据产品ID发起购买
- (void)purchaseWithProductID:(NSString *)productID view:(UIView *)view;
// 根据产品ID发起购买套餐
- (void)purchaseWithPackageID:(NSString *)packageID productID:(NSString *)productID view:(UIView *)view;
// 补单
- (void)restorePurchaseWithOrderID:(NSString *)orderID receipt:(NSString *)receipt view:(UIView *)view;
// 下载支付点
- (void)downloadProductsWithArray:(NSArray *)products;
//返回补单列表
- (NSArray*)achiveRestorePurchaseList;

@end