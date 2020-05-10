//
//  MysticShop.h
//  Mystic
//
//  Created by travis weerts on 3/27/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import <StoreKit/StoreKit.h>
#import "Mystic.h"

typedef void (^MysticShopBlock)(BOOL success, NSArray *products);
typedef void (^MysticShopBlockDownload)(float progressDone, SKDownload *download);


@class MysticShopTransaction, MysticShopProduct;

@interface MysticShop : NSObject
{
    
}
@property (nonatomic, retain) NSSet *productIDs;
@property (nonatomic, retain) NSSet *userPurchaseIDs;
@property (copy, nonatomic) MysticBlockSender finishedBlock, startBlock;
@property (copy, nonatomic) MysticBlock restoreFinishedBlock;
@property (copy, nonatomic) MysticBlockSender canceledBlock;
@property (copy, nonatomic) MysticShopBlockDownload downloadProgressBlock;
@property (copy, nonatomic) MysticBlockSender failedBlock;
@property (copy, nonatomic) MysticBlockSender purchasedBlock;

@property (nonatomic, retain) NSArray *products;

+ (MysticShop *) sharedShop;
+ (NSString *)shopOptionsFilePath;
+ (NSArray *) productsOfType:(MysticProductType)type;
+ (NSArray *) products;
+ (MysticShopProduct *) productInfoForIdentifier:(NSString *)identifier;
+ (NSDictionary *) data;
+ (BOOL) downloadedProduct:(NSString *) identifier;
+ (SKProduct *) purchasedProduct:(NSString *) identifier;
+ (void) purchase:(NSString *) identifier start:(MysticBlockSender)start download:(MysticShopBlockDownload)downloadBlock success:(MysticBlockSender)success failed:(MysticBlockSender)failed;
+ (void) buy:(SKProduct *)product start:(MysticBlockSender)start download:(MysticShopBlockDownload)downloadBlock success:(MysticBlockSender)success failed:(MysticBlockSender)failed;
+ (BOOL) hasPurchased:(NSString *) identifier;

-(void) request:(NSSet *)productIDs handler:(MysticShopBlock)handler;
-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
-(void) provideContentForProduct:(SKPaymentTransaction *)payment productID:(NSString *)productID;
-(void) completeTransaction:(SKPaymentTransaction *)transaction;
-(void) restoreTransaction:(SKPaymentTransaction *)transaction;
-(void) failedTransaction:(SKPaymentTransaction *)transaction;
-(void) restoreCompletedTransactions;
-(void) restoreCompletedTransactions:(MysticBlock)restoreFinished;
-(BOOL) purchased:(NSString *)productID;
-(void) buy:(SKProduct *)product;
-(void) download:(MysticShopTransaction *)transaction;
-(void) downloadProduct:(SKProduct *)product;

@end




@interface MysticShopTransaction : NSObject
{
    
}
@property (nonatomic, retain) NSString *productID, *contentIdentifier;
@property (nonatomic, retain) SKPaymentTransaction *transaction;
@property (nonatomic, retain) SKPayment *payment;
@property (nonatomic, retain) SKProduct *product;
@property (nonatomic, assign) float progress;

@end


@interface MysticShopProduct : NSObject
{
    
}
@property (nonatomic, retain) NSString *productID, *contentIdentifier, *imageName, *title, *details;
@property (nonatomic, assign) float price;
@property (nonatomic, assign) BOOL featured, charity;
@property (nonatomic, assign) MysticProductType type;
@property (nonatomic, readonly) NSString *priceString;

+ (MysticShopProduct *) productWithInfo:(NSDictionary *)info;
@end


