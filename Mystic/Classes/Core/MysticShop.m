//
//  MysticShop.m
//  Mystic
//
//  Created by travis weerts on 3/27/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticShop.h"
#import "MBProgressHUD/MBProgressHUD.h"

#define DEBUGSHOP 0


NSString *const ProductPurchasedNotification = @"ProductPurchasedNotification";




@interface MysticShop () <SKPaymentTransactionObserver, SKProductsRequestDelegate, MysticProgressHUDDelegate>
{
    SKProductsRequest *_productsRequest;
    MysticShopBlock _completionHandler;
    MBProgressHUD *_progress;
    NSMutableArray *_purchasedIDs;
    
}
@end



@implementation MysticShop


@synthesize productIDs, userPurchaseIDs, products;
@synthesize finishedBlock, canceledBlock, purchasedBlock, failedBlock, restoreFinishedBlock, startBlock;

static MysticShop *MysticShopInstance;


+ (MysticShop *) sharedShop;
{
    if(!MysticShopInstance) MysticShopInstance = [[MysticShop alloc] init];
    return MysticShopInstance;
}

+ (void) resetPurchases
{
    
}

+ (NSArray *) productsOfType:(MysticProductType)type;
{
    NSMutableArray *returnProducts = [NSMutableArray array];
    NSArray *products = [MysticShop products];
    
    switch(type)
    {
        case MysticProductTypeCharity:
        {
            for (MysticShopProduct *product in products) {
                if(product.charity) [returnProducts addObject:product];
            }
            break;
        }
        case MysticProductTypeFeatured:
        {
            for (MysticShopProduct *product in products) {
                if(product.featured) [returnProducts addObject:product];
            }
            break;
        }
        case MysticProductTypeOther:
        {
            for (MysticShopProduct *product in products) {
                if(!product.featured && !product.charity) [returnProducts addObject:product];
            }
            break;
        }
        default:
        {
            returnProducts = (NSMutableArray *)products;
        }
    }
    return returnProducts;
}

+ (MysticShopProduct *) productInfoForIdentifier:(NSString *)identifier;
{
    NSArray *products = [MysticShop products];
    for (MysticShopProduct *prod in products) {
        if([prod.productID isEqualToString:identifier]) return prod;
    }
    return nil;
}

#pragma mark - Utility Methods



+ (NSString *)shopOptionsFilePath;
{
    return [[NSBundle mainBundle] pathForResource:@"Shop" ofType:@"plist"];
}

+ (NSDictionary *) data;
{
    return [NSDictionary dictionaryWithContentsOfFile:[MysticShop shopOptionsFilePath]];
    
}

+ (NSArray *) products;
{
    NSMutableArray *products = [NSMutableArray array];
    for (NSDictionary *productData in [[MysticShop data] allValues]) {
        MysticShopProduct *sp = [MysticShopProduct productWithInfo:productData];
//        BOOL hasProduct = NO;
//        for (SKProduct *pd in theProds) {
//            if([pd.productIdentifier isEqualToString:sp.productID])
//            {
//                hasProduct = YES;
//                break;
//            }
//        }
//        if(hasProduct) [products addObject:sp];
        [products addObject:sp];
    }
    
    return products;
}

+ (NSSet *) productIDs
{
    NSMutableSet *ids = [NSMutableSet set];
    for (MysticShopProduct *product in [MysticShop products]) {
        [ids addObject:product.productID];
    }
    [ids addObject:MysticShopProductIdentifierHandwritingCam];
    return ids;
}

+ (BOOL) hasPurchased:(NSString *) identifier;
{
    return [[MysticShop sharedShop] purchased:identifier];
}

+ (BOOL) downloadedProduct:(NSString *) identifier;
{
    if(![[MysticShop sharedShop] purchased:identifier]) return NO;
    NSString *productID = [NSString stringWithFormat:@"%@-downloaded", identifier];
    if([[NSUserDefaults standardUserDefaults] objectForKey:productID] && [[NSUserDefaults standardUserDefaults] boolForKey:productID]) return YES;
    
    return NO;
}

+ (SKProduct *) purchasedProduct:(NSString *) identifier;
{
    if([[MysticShop sharedShop] purchased:identifier])
    {
        return [[MysticShop sharedShop] productWithIdentifier:identifier];
    }
    return nil;
}

+ (void) purchase:(NSString *) identifier start:(MysticBlockSender)start download:(MysticShopBlockDownload)downloadBlock success:(MysticBlockSender)success failed:(MysticBlockSender)failed;
{
    NSAssert(identifier != nil, @"Product identifier is nil");
    
    SKProduct *myProduct = nil;
    for (SKProduct *prod in [MysticShop sharedShop].products) {
        if([prod.productIdentifier isEqualToString:identifier])
        {
            myProduct = prod;
            break;
        }
    }
    if(!myProduct)
    {
        failed(myProduct);
        return;
    }
    if([MysticShop hasPurchased:identifier])
    {
        success(myProduct);
    }
    else
    {
        [MysticShop sharedShop].startBlock = start;
        [MysticShop sharedShop].finishedBlock = success;
        [MysticShop sharedShop].failedBlock = failed;
        [MysticShop sharedShop].downloadProgressBlock = downloadBlock;
        
        [[MysticShop sharedShop] buy:[[MysticShop sharedShop] productWithIdentifier:identifier]];
    }
    return;
}

+ (void) buy:(SKProduct *)product start:(MysticBlockSender)start download:(MysticShopBlockDownload)downloadBlock success:(MysticBlockSender)success failed:(MysticBlockSender)failed;
{
    
        [MysticShop sharedShop].startBlock = start;
        [MysticShop sharedShop].finishedBlock = success;
        [MysticShop sharedShop].failedBlock = failed;
        [MysticShop sharedShop].downloadProgressBlock = downloadBlock;
        
        [[MysticShop sharedShop] buy:product];

}

- (SKProduct *) productWithIdentifier:(NSString *)identifier
{
    for (SKProduct *product in self.products) {
        if([product.productIdentifier isEqualToString:identifier]) { return product; }
    }
    return nil;
}






#pragma mark SKProductsRequestDelegate


-(id) init
{
    self = [super init];
    if(self)
    {
        if(![Mystic storeEnabled]) return self;
        _purchasedIDs = [[NSMutableArray array] retain];
        
        if ([SKPaymentQueue canMakePayments] && (self = [super init]))
        {
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        }
        self.downloadProgressBlock = ^(float progressDone, SKDownload *download){
            
        };
        
        
        [self request:[MysticShop productIDs] handler:^(BOOL success, NSArray *returnproducts) {
            [MysticShop sharedShop].products = returnproducts;
            for (SKProduct *p in returnproducts) {
    #ifdef DEBUGSHOP

                //DLog(@"Product Loaded: %@", p.productIdentifier);
    #endif
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:MysticEventProductsLoadedNotification object:products];
        }];
    }
    return self;
}


- (NSSet *) userPurchaseIDs
{
    return [NSSet setWithArray:_purchasedIDs];
}
-(void) request:(NSSet *)productIDs handler:(MysticShopBlock)handler
{
    if(_completionHandler) {Block_release(_completionHandler); _completionHandler=nil;}
    _completionHandler = [handler copy];
    
    if(_productsRequest)
    {
        [_productsRequest release], _productsRequest = nil;
    }
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[MysticShop productIDs]];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
{
    [_productsRequest release];
    _productsRequest = nil;
    _completionHandler(YES, response.products);
    Block_release(_completionHandler);
    _completionHandler = nil;
}

-(void) request:(SKRequest *)request didFailWithError:(NSError *)error;
{
#ifdef DEBUGSHOP
    DLog(@"Failed to load list of products.");
#endif
    [_productsRequest release];
    
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    Block_release(_completionHandler);
    _completionHandler = nil;
}

#pragma end

#pragma mark Transaction

-(void) provideContentForProduct:(SKPaymentTransaction *)payment productID:(NSString *)productID;
{
    [_purchasedIDs addObject:productID];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productID];
    
    if([payment respondsToSelector:@selector(downloads)] && payment.downloads) [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@-downloaded", productID]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    MysticShopTransaction *transaction = [[MysticShopTransaction alloc] init];
    
    [transaction setTransaction:payment];
    [transaction setProductID:productID];
    if(self.finishedBlock) self.finishedBlock(transaction);
    [[NSNotificationCenter defaultCenter] postNotificationName:MysticEventProductPurchasedNotification object:transaction userInfo:nil];
    [transaction release];
    
}

-(void) completeTransaction:(SKPaymentTransaction *)transaction;
{
#ifdef DEBUGSHOP
    DLog(@"completeTransaction");
#endif
    
    [self provideContentForProduct:transaction productID:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void) restoreTransaction:(SKPaymentTransaction *)transaction;
{
#ifdef DEBUGSHOP
    DLog(@"restoreTransaction");
#endif
    
    [self provideContentForProduct:transaction productID:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void) failedTransaction:(SKPaymentTransaction *)transaction;
{
#ifdef DEBUGSHOP
    DLog(@"failedTransaction");
#endif
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        DLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    
    if(self.failedBlock) self.failedBlock(transaction);
    self.failedBlock = nil;
}

-(void) restoreCompletedTransactions:(MysticBlock)restoreFinished;
{
    self.restoreFinishedBlock = restoreFinished;
    [self restoreCompletedTransactions];
    
}
-(void) restoreCompletedTransactions
{
#ifdef DEBUGSHOP
    DLog(@"restoreCompletedTransactions");
#endif
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MysticEventProductsRestoringNotification object:nil];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma end

#pragma mark Buy & Download

-(BOOL) purchased:(NSString *)productID
{
#ifdef WRITEMECAM_FREE
    
    if([productID isEqualToString:MysticShopProductIdentifierHandwritingCam])
    {
//        DLog(@"defaulting write me cam to purchased & free");
        return YES;
    }
    
#endif
    NSAssert(productID != nil, @"Product ID is nil");
    if([[NSUserDefaults standardUserDefaults] objectForKey:productID] && [[NSUserDefaults standardUserDefaults] boolForKey:productID]) return YES;
    return [_purchasedIDs containsObject:productID];
}

-(void) buy:(SKProduct *)product
{
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    
    MysticShopTransaction *transaction = [[MysticShopTransaction alloc] init];
    transaction.product = product;
    transaction.payment = payment;
    transaction.productID = product.productIdentifier;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MysticEventProductPurchasingNotification object:transaction];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [transaction autorelease];
}
-(void) downloadProduct:(SKProduct *)product;
{
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    
    MysticShopTransaction *transaction = [[MysticShopTransaction alloc] init];
    transaction.product = product;
    transaction.payment = payment;
    transaction.productID = product.productIdentifier;
    
    [self download:transaction];
    [transaction autorelease];
}
-(void) download:(MysticShopTransaction *)transaction
{
    NSAssert(transaction.transaction.transactionState == SKPaymentTransactionStatePurchased ||
             transaction.transaction.transactionState == SKPaymentTransactionStateRestored, @"The payment transaction must be completed");
    
    if ([transaction.transaction respondsToSelector:@selector(downloads)] && [transaction.transaction.downloads count])
    {
//        DLog(@"starting download for purchase");
        [[NSNotificationCenter defaultCenter] postNotificationName:MysticEventProductDownloadingNotification object:transaction];
        [[SKPaymentQueue defaultQueue] startDownloads:transaction.transaction.downloads];
    }
}

#pragma end

#pragma mark SKPaymentTransactionObserver

-(void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
#ifdef DEBUGSHOP

    DLog(@"RestoreCompletedTransactions");
#endif
    if(self.restoreFinishedBlock) self.restoreFinishedBlock();
    self.restoreFinishedBlock = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:MysticEventProductsRestoredNotification object:nil];
}



-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            
            
            case SKPaymentTransactionStatePurchased:
            {
#ifdef DEBUGSHOP
                DLog(@"SKPaymentTransactionStatePurchased");
                
#endif
                if([transaction respondsToSelector:@selector(downloads)])
                {
#ifdef DEBUGSHOP

                DLog(@"DOWNLOADS: %@", transaction.downloads);
#endif
                    if(![transaction.downloads count])
                    {
                        [self completeTransaction:transaction];
                    }
                    else
                    {
                        if(self.startBlock) self.startBlock(transaction);
                        
                        [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
                    }
                }
                else
                {
                    [self completeTransaction:transaction];
                }
                
                break;
            }
                
            case SKPaymentTransactionStateFailed:
            {
#ifdef DEBUGSHOP

                DLog(@"SKPaymentTransactionStateFailed");
                DLog(@"ERROR: %@", transaction.error);
#endif
                [self failedTransaction:transaction];
                break;
            }
                
            case SKPaymentTransactionStateRestored:
            {
#ifdef DEBUGSHOP
                
                DLog(@"Restored");
#endif
                [self restoreTransaction:transaction]; break;
            }
                
            case SKPaymentTransactionStatePurchasing:
            {
#ifdef DEBUGSHOP
                DLog(@"SKPaymentTransactionStatePurchasing");
#endif
                
                break;
            }
            case SKPaymentTransactionStateDeferred:
            {
                break;
            }
        }
    }
}

-(void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
#ifdef DEBUGSHOP
    DLog(@"restoreCompletedTransactionsFailedWithError");
#endif
}

-(void) paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
#ifdef DEBUGSHOP
    DLog(@"removedTransactions");
#endif
}

-(void) paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    for (SKDownload *download in downloads)
    {
        switch (download.downloadState)
        {
            case SKDownloadStateActive:
            {
#ifdef DEBUGSHOP
                DLog(@"%f", download.progress);
                DLog(@"%f remaining", download.timeRemaining);
#endif
                
                if (download.progress == 0.0 && !_progress)
                {
#define WAIT_TOO_LONG_SECONDS 60
#define TOO_LARGE_DOWNLOAD_BYTES 4194304
                    
                    const BOOL instantDownload = (download.timeRemaining != SKDownloadTimeRemainingUnknown && download.timeRemaining < WAIT_TOO_LONG_SECONDS) ||
                    (download.contentLength < TOO_LARGE_DOWNLOAD_BYTES);
                    
                    if (instantDownload)
                    {
                        if(!self.downloadProgressBlock)
                        {
                            UIView *window= [[UIApplication sharedApplication] keyWindow];
                            
                            _progress = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
                            [window addSubview:_progress];
                            
                            [_progress show:YES];
                            [_progress setDelegate:self];
                            [_progress setDimBackground:YES];
                            [_progress setLabelText:@"Downloading"];
                            [_progress setMode:MysticProgressHUDModeAnnularDeterminate];
                        }
                    }
                    else
                    {
//                        DLog(@"Implement me!");
                    }
                }
                if(!self.downloadProgressBlock)
                {
                    if(_progress) [_progress setProgress:download.progress];
                }
                else
                {
                    self.downloadProgressBlock(download.progress, download);
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:MysticEventProductDownloadingNotification object:download userInfo:nil];
                
                break;
            }
                
            case SKDownloadStateCancelled: { if(self.downloadProgressBlock) self.downloadProgressBlock(download.progress, download); break; }
            case SKDownloadStateFailed:
            {

#ifdef DEBUGSHOP
                DLog(@"download failed");
#endif
                if(self.downloadProgressBlock) self.downloadProgressBlock(download.progress, download);
                break;
            }
                
            case SKDownloadStateFinished:
            {
                NSString *source = [download.contentURL relativePath];
                NSDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[source stringByAppendingPathComponent:@"ContentInfo.plist"]];
                //DLog(@"Download is finished: %@", source);

                NSFileManager *fileManager = [NSFileManager defaultManager];
                
               
                //DLog(@"DOWNLOAD COMPLETE: %@", dict);
                //NSString *productShortName = [[download.contentIdentifier componentsSeparatedByString:@"."] lastObject];
                NSString *productFolderName = @"MysticProducts";
                NSString *productDirPath = [MysticConfigManager configDirSubPath:productFolderName];
                if ([dict objectForKey:@"MysticFiles"])
                {
                    for (NSString *file in [dict objectForKey:@"MysticFiles"])
                    {
                        NSString *content = [[source stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:file];
                        //DLog(@"CONTENT: %@", content);
                        
                        
                        NSString *destFile = [productDirPath stringByAppendingFormat:@"/%@", file] ;
                        NSError *error=nil;
                        
                        if ([fileManager fileExistsAtPath:destFile] == YES) {
                            [fileManager removeItemAtPath:destFile error:&error];
                        }
                        
                        [fileManager copyItemAtPath:content toPath:destFile error:&error];
                        if(error)
                        {
#ifdef DEBUGSHOP

                            DLog(@"ERROR on copy file to: %@ - %@", destFile, error);
#endif
                        }
                        else
                        {
                            //DLog(@"copied file to: %@", destFile);
                        }

                    }
                }
                if ([dict objectForKey:@"MysticConfig"])
                {
                    NSDictionary *downloadConfig = [dict objectForKey:@"MysticConfig"];
                    if(downloadConfig)
                    {
                        [[Mystic core] addConfig:downloadConfig name:download.contentIdentifier finished:^(id sender) {
                            
                        }];
                    }
                    
                }
                
                if (download.transaction.transactionState == SKPaymentTransactionStatePurchased)
                {
                    [MysticAlert notice:@"Thank you" message:@"Your purchase is complete, and the effects are ready to use." action:^(id object, id o2) {
                        
                    } options:nil];
                    
                }
                if(self.downloadProgressBlock) self.downloadProgressBlock(download.progress, download);
 
                

                
                [self provideContentForProduct:download.transaction productID:download.contentIdentifier];
                
                [[SKPaymentQueue defaultQueue] finishTransaction:download.transaction];
                break;
            }
                
            case SKDownloadStatePaused:
            {
#ifdef DEBUGSHOP
                DLog(@"SKDownloadStatePaused");
#endif
                break;
            }
                
            case SKDownloadStateWaiting:
            {
#ifdef DEBUGSHOP
                DLog(@"SKDownloadStateWaiting");
#endif
                break;
            }
        }
    }
}

#pragma end






#pragma mark MysticProgressHUDDelegate

-(void) hudWasHidden:(MBProgressHUD *)hud
{
    if(!_progress) return;
    
    NSAssert(_progress, @"ddd");
    
    [_progress removeFromSuperview];
    
    [_progress release], _progress=nil;
    
    //SAFE_RELEASE_VIEW(_progress);
}

#pragma end

@end


@implementation MysticShopTransaction

@synthesize productID, transaction, payment, product, contentIdentifier, progress;

- (id) init
{
    self = [super init];
    self.progress = 0;
    return self;
}

- (NSString *) contentIdentifier
{
    return self.productID;
}

@end


@implementation MysticShopProduct

@synthesize productID, contentIdentifier, price, title, details, imageName, type, priceString, featured, charity;

+ (MysticShopProduct *) productWithInfo:(NSDictionary *)info;
{
    MysticShopProduct *product = [[MysticShopProduct alloc] init];
    if([info objectForKey:@"price"]) product.price = [[info objectForKey:@"price"] floatValue];
    if([info objectForKey:@"title"]) product.title = [info objectForKey:@"title"];
    if([info objectForKey:@"identifier"]) product.productID = [info objectForKey:@"identifier"] ;
    if([info objectForKey:@"details"]) product.details = [info objectForKey:@"details"] ;
    if([info objectForKey:@"image"]) product.imageName = [info objectForKey:@"image"];
    product.type = MysticProductTypeUnknown;
    if([[info objectForKey:@"charity"] boolValue])
    {
        product.charity = YES;
        product.type = MysticProductTypeCharity;
    }
    
    if([[info objectForKey:@"featured"] boolValue])
    {
        product.featured = YES;
    }
    
    return [product autorelease];
}
- (void) dealloc;
{
    [productID release];
    [contentIdentifier release];
    [priceString release];
    [imageName release];
    [details release];
    [super dealloc];
}
- (id) init
{
    self = [super init];
    self.price = 0;
    self.charity = NO;
    self.featured = NO;
    self.imageName = @"product_placeholder.jpg";
    self.type = MysticProductTypeUnknown;
    self.title = @"Untitled";
    self.details = @"No description available.";
    self.productID = nil;
    return self;
}

- (NSString *) contentIdentifier
{
    return self.productID;
}

- (NSString *) priceString
{
    if(self.price <= 0)
    {
        return @"FREE";
    }
    
    
    return [NSString stringWithFormat:@"$%2.2f", self.price];
}

@end

