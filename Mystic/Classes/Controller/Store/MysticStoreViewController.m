//
//  MysticStoreViewController.m
//  Mystic
//
//  Created by Travis A. Weerts on 6/8/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticStoreViewController.h"
#import "MysticAlert.h"
#import "UIImage+AHKAdditions.h"
#import "UIWindow+AHKAdditions.h"
#import "MysticCategoryButton.h"
#import "MysticAttrString.h"
#import "MysticAttrStringStyle.h"
#import "SSZipArchive.h"
#import "MysticCache.h"
#import "MysticUser.h"
#import "RMStoreKeychainPersistence.h"
#import "NSDictionary+Merge.h"
#import "MysticStore.h"


static float scrollViewMargin = 50;
@interface MysticStoreViewController ()
@property (nonatomic, assign) BOOL productsRequestFinished, wasClosed, selectedItemIsDownload;
@property (nonatomic, assign) NSInteger selectedItemIndex;
@property (nonatomic, assign) UIView *focusedItemView;
@property (nonatomic, assign) MysticButton *lastSender;
@property (weak, nonatomic, readwrite) UIWindow *previousKeyWindow;
@property (weak, nonatomic) MysticImageView *blurredBackgroundView;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSDictionary *data, *selectedItem;
@property (nonatomic, retain) NSMutableArray *items, *products, *invalidProducts;
@property (nonatomic, retain) NSString *selectedProductId;
@property (nonatomic, assign) UIVisualEffectView *blurEffectView;
@end

@implementation MysticStoreViewController

- (instancetype) init;
{
    self = [super init];
    if(!self) return nil;
    self.currentType = @"featured";
    self.wasClosed = NO;
    self.items = [NSMutableArray array];
    self.products = [NSMutableArray array];
    self.invalidProducts = [NSMutableArray array];
    self.storeType = MysticStoreTypeDefault;
    self.selectedItemIndex = NSNotFound;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *previousKeyWindowSnapshot = nil;
    
    
    self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    previousKeyWindowSnapshot = [self.previousKeyWindow ahk_snapshot];
    [self setUpBlurredBackgroundWithSnapshot:previousKeyWindowSnapshot];
    
    
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effectView.frame = self.view.bounds;
    self.blurEffectView = effectView;
    [self.view addSubview:effectView];
    
    // Do any additional setup after loading the view.
    CGRect scrollFrame = self.view.bounds;
    scrollFrame.origin.x = scrollViewMargin/2;
    scrollFrame.size.width = scrollViewMargin/2 + (self.view.bounds.size.width - (scrollViewMargin*2));
    self.scrollView = [[MysticStoreScrollView alloc] initWithFrame:scrollFrame];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    self.view.backgroundColor = UIColor.blackColor;
    
    self.menu = [[MysticStoreMenuView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    self.menu.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    [self.view addSubview:self.menu];
    
    self.hideBtn = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeToolHide) size:(CGSize){17, 10} color:[UIColor colorWithRed:0.44 green:0.42 blue:0.38 alpha:0.95]] target:self sel:@selector(hideButtonTouched:)];
    self.hideBtn.center = (CGPoint){self.view.center.x, CGRectGetMaxY(self.view.bounds)-CGRectGetHeight(self.hideBtn.frame)/2 - 19};
    self.hideBtn.hidden = YES;
    [self.view addSubview:self.hideBtn];
    
    MysticAttrString *restoreStr = [MysticAttrStringStyle string:@"RESTORE" style:MysticStringStyleStoreRestore];
    MysticAttrString *restoreStrH = [MysticAttrStringStyle string:@"RESTORE" style:MysticStringStyleStoreRestore state:UIControlStateHighlighted];
    
    self.restoreButton = [MysticButton buttonWithAttrStr:restoreStr.attrString target:self action:@selector(restoreButtonTouched:)];
    [self.restoreButton setAttributedTitle:restoreStrH.attrString forState:UIControlStateHighlighted];
    self.restoreButton.center = (CGPoint){CGRectGetWidth(self.restoreButton.frame)/2 + 20, self.hideBtn.center.y};
    self.restoreButton.hidden = YES;
    [self.view addSubview:self.restoreButton];
    
    BOOL isDefaultType = self.storeType == MysticStoreTypeDefault;
    
    CGRect lastCategoryFrame = (CGRect){0,0,0,0};
    
    if(isDefaultType)
    {
        MysticCategoryButton *categoryBtn = [MysticCategoryButton buttonWithTitle:@"FEATURED" target:self sel:@selector(categoryButtonTouched:)];
        lastCategoryFrame.size.width = categoryBtn.frame.size.width + 50;
        lastCategoryFrame.size.height = self.menu.frame.size.height;
        categoryBtn.frame = lastCategoryFrame;
        categoryBtn.tag = 1;
        lastCategoryFrame.origin.x += categoryBtn.frame.size.width + self.menu.margin;
        categoryBtn.selected = YES;
        [self.menu addSubview:categoryBtn];
        
        categoryBtn = [MysticCategoryButton buttonWithTitle:@"ART" target:self sel:@selector(categoryButtonTouched:)];
        
        lastCategoryFrame.size.width = categoryBtn.frame.size.width + 50;
        categoryBtn.frame = lastCategoryFrame;
        categoryBtn.tag = 2;
        lastCategoryFrame.origin.x += categoryBtn.frame.size.width;
        [self.menu addSubview:categoryBtn];
        
        categoryBtn = [MysticCategoryButton buttonWithTitle:@"OTHER" target:self sel:@selector(categoryButtonTouched:)];
        lastCategoryFrame.size.width = categoryBtn.frame.size.width + 50;
        categoryBtn.frame = lastCategoryFrame;
        categoryBtn.tag = 3;
        lastCategoryFrame.origin.x += categoryBtn.frame.size.width;
        [self.menu addSubview:categoryBtn];
    }
    else
    {
        MysticCategoryButton *categoryBtn = [MysticCategoryButton buttonWithTitle:@"FEATURED" target:self sel:@selector(categoryButtonTouched:)];
        lastCategoryFrame.size.width = categoryBtn.frame.size.width + 50;
        lastCategoryFrame.size.height = self.menu.frame.size.height;
        categoryBtn.frame = lastCategoryFrame;
        categoryBtn.tag = 1;
        lastCategoryFrame.origin.x += categoryBtn.frame.size.width + self.menu.margin;
        categoryBtn.selected = YES;
        [self.menu addSubview:categoryBtn];
        
        categoryBtn = [MysticCategoryButton buttonWithTitle:@"FREE" target:self sel:@selector(categoryButtonTouched:)];
        lastCategoryFrame.size.width = categoryBtn.frame.size.width + 50;
        categoryBtn.frame = lastCategoryFrame;
        categoryBtn.tag = 4;
        lastCategoryFrame.origin.x += categoryBtn.frame.size.width;
        [self.menu addSubview:categoryBtn];
        
        
        categoryBtn = [MysticCategoryButton buttonWithTitle:@"OTHER" target:self sel:@selector(categoryButtonTouched:)];
        lastCategoryFrame.size.width = categoryBtn.frame.size.width + 50;
        categoryBtn.frame = lastCategoryFrame;
        categoryBtn.tag = 2;
        lastCategoryFrame.origin.x += categoryBtn.frame.size.width;
        [self.menu addSubview:categoryBtn];
    }
    self.menu.hidden = YES;
    [self.menu centerViews:nil];
    
    self.menu.contentSize = (CGSize){lastCategoryFrame.origin.x, self.menu.frame.size.height};
    
    self.restoreButton.hidden = YES;

    self.activity = [[activityIndicator alloc] initWithFrame:(CGRect){0,0,65,65}];
    self.activity.center = self.view.center;
    self.activity.strokeColor = [UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00];
    self.activity.alpha = 0;
    [self.view addSubview:self.activity];
    
    self.data = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"store" ofType:@"plist"]];
    
}
- (void) viewDidAppear:(BOOL)animated;
{
    
    [self showActivity:^(BOOL finished1) {
        if(self.shouldDownloadFocusedProduct && self.focusOnProductID)
        {
            self.hideBtn.alpha = 0;
            self.hideBtn.hidden = NO;
            [self.hideBtn fadeIn:0.3 completion:^(BOOL finished) {
                [self purchaseProduct:self.focusOnProductID];
            }];
        }
        else
        {
            [self.activity fadeOut:0.2 completion:^(BOOL finished) {
                self.hideBtn.hidden = NO;
                self.restoreButton.hidden = NO;
                self.menu.hidden = NO;
                [self loadItems:self.currentType];
                
            }];
        }
        

    }];
    
    
}
- (void) restoreButtonTouched:(MysticButton *)sender;
{
    sender.enabled = NO;
    sender.hidden = YES;
    self.scrollView.hidden = YES;
    self.menu.hidden =YES;
    [self showActivity:^(BOOL finished) {
        
        [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
            DLog(@"Transactions restored:  %@", transactions);
             nil;
            for (SKPaymentTransaction *trans in transactions) {
                SKPayment *payment = trans.payment;
                [MysticUser remember:payment.productIdentifier];
            }
            [self hideActivity:^(BOOL finished) {
                [MysticAlert notice:@"Purchases Restored" message:@"All of your purchases have been restored."];
                self.scrollView.hidden = NO;
                sender.hidden = NO;
                self.menu.hidden =NO;
                
            }];
        } failure:^(NSError *error) {
            
            [MysticAlert notice:@"Store Error" message:@"Looks like something went wrong, please try again."];
            sender.enabled = YES;
            self.scrollView.hidden = NO;
            sender.hidden = NO;
            self.menu.hidden =NO;
            
            
        }];
    }];
    
}
- (void) hideButtonTouched:(MysticButton *)sender;
{
    sender.enabled = NO;
    self.lastSender.enabled = YES;
    self.lastSender.alpha = 1;
    self.lastSender = nil;
    if(self.scrollView.alpha == 0 || self.scrollView.hidden)
    {
        [@[self.activity] fadeOut:0.3 delay:0 completion:^(BOOL finished) {
            [@[self.scrollView, self.hideBtn, self.menu, self.restoreButton] fadeIn:0.3 delay:0 completion:nil];
            self.hideBtn.enabled = YES;
        }];
    }
    else
    {
        [self hide];
    }
}

- (void) hide;
{
    if(self.onHide) self.onHide(self,NO);
    [[RMStore defaultStore] removeStoreObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) showActivity:(void (^ _Nullable)(BOOL finished))completion;
{
    [self.activity startLoading];
    [self.activity fadeIn:0.3 completion:completion];
}
- (void) hideActivity:(MysticBlockAnimationFinished)completion;
{
    [self hideActivity:YES completion:completion];
}
- (void) hideActivity:(BOOL)success completion:(MysticBlockAnimationFinished)completion;
{
    [self.activity completeLoading:YES completion:!completion ? nil : ^{
        MysticWait(0.2, ^{ [self.activity fadeOut:0.3 completion:completion]; });
    }];
}
- (NSMutableArray *) itemsForType:(NSString *)typeVal;
{
    NSString *type = typeVal ? typeVal : @"featured";
    BOOL loadFree = [type isEqualToString:@"free"];
    if(loadFree) type = @"other";
    NSString *groupType = nil;
    BOOL isDefaultStore = self.storeType == MysticStoreTypeDefault;
    if(!isDefaultStore)
    {
        switch (self.storeType) {
            case MysticStoreTypeText: groupType=@"text"; break;
            case MysticStoreTypeTextures: groupType=@"texture"; break;
            case MysticStoreTypeFonts: groupType=@"font"; break;
            case MysticStoreTypeFeatures: groupType=@"feature"; break;
            case MysticStoreTypeFrames: groupType=@"frame"; break;
            case MysticStoreTypeLights: groupType=@"light"; break;
            case MysticStoreTypeColors: groupType=@"color"; break;
            case MysticStoreTypeShapes: groupType=@"shape"; break;
            case MysticStoreTypeFilters: groupType=@"filter"; break;
            default: break;
        }
    }
    NSDictionary *allItems = [self.data objectForKey:@"items"];
    NSDictionary *allOrders = [self.data objectForKey:@"order"];
    
    NSArray *orders = [allOrders objectForKey:type];
    if(self.focusOnProductID)
    {
        BOOL foundItem = NO;
        for (NSString *itemKey in orders) {
            if([itemKey isEqualToString:self.focusOnProductID]) { foundItem = YES; break; }
        }
        if(!foundItem)
        {
            NSDictionary *item = [allItems objectForKey:self.focusOnProductID];
            type = item[@"type"];
            orders = [allOrders objectForKey:type];
        }
    }
    MysticButton *category = nil;
    if([type isEqualToString:@"featured"]) category = [self.menu viewWithTag:1];
    if([type isEqualToString:@"art"]) category = [self.menu viewWithTag:2];
    if([type isEqualToString:@"other"]) category = [self.menu viewWithTag:3];
    if([type isEqualToString:@"free"]) category = [self.menu viewWithTag:4];
    category.selected = YES;
    for (MysticButton *categorySibling in category.siblings) {
        categorySibling.selected = NO;
    }
    if(loadFree)
    {
        NSArray *featuredOrders = [allOrders objectForKey:@"featured"];
        NSArray *artOrders = [allOrders objectForKey:@"art"];
        NSArray *otherOrders = [allOrders objectForKey:@"other"];
        
        NSMutableArray *newOrders = [NSMutableArray arrayWithArray:featuredOrders];
        [newOrders addObjectsFromArray:artOrders];
        [newOrders addObjectsFromArray:otherOrders];
        orders = newOrders;
    }
    NSMutableArray *newOrders = [NSMutableArray array];
    for (NSString *itemKey in orders) {
        if([newOrders containsObject:itemKey]) continue;
        [newOrders addObject:itemKey];
    }
    orders = newOrders;
    if(!orders || orders.count == 0 || !allItems || allItems.count == 0) { DLogError(@"No items found"); return nil; }
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *itemKey in orders) {
        BOOL foundInvalid = NO;
        for (NSString *invalid in self.invalidProducts) { if([itemKey isEqualToString:invalid]) { foundInvalid = YES; break; } }
        if(self.storeType != MysticStoreTypeDefault)
        {
            if(groupType && [[allItems objectForKey:itemKey] objectForKey:@"group"] && ![[[allItems objectForKey:itemKey] objectForKey:@"group"] isEqualToString:groupType]) foundInvalid = YES;
            if(loadFree && !foundInvalid && [[[allItems objectForKey:itemKey] objectForKey:@"price"] floatValue] > 0) foundInvalid = YES;
        }
        if(!foundInvalid && self.hideNonFocusedProducts && self.focusOnProductID && ![itemKey isEqualToString:self.focusOnProductID])
        {
           
            foundInvalid = YES;
        }

        if(foundInvalid) continue;

        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithDictionary:[allItems objectForKey:itemKey]];
        if(!item) continue;
        [item setObject:itemKey forKey:@"key"];
        [items addObject:item];
    }
    return items;
}
- (NSArray *) loadItems:(NSString *)type;
{
    self.currentType = type ? type : @"featured";
    BOOL loadFree = [self.currentType isEqualToString:@"free"];
    NSArray *items = nil;
    UIView *itemView = nil;
    UIView *selectedItemView = nil;
    int selectedItemPage = 0;
    MysticButton *itemButton = nil;
    MysticImageView *itemImageView = nil;
    MysticAttrString *collectionSubTitle = [MysticAttrStringStyle string:@"COLLECTION" style:MysticStringStyleStoreItemSubtitle state:UIControlStateNormal];

    CGFloat itemButtonHeight = 33;
    CGFloat itemMargin = scrollViewMargin;
    CGFloat itemViewHeight = self.view.bounds.size.width - (itemMargin*2) + 20 + itemButtonHeight*2;
    CGRect itemFrame = (CGRect){(itemMargin/2),self.scrollView.center.y - itemViewHeight/2,self.view.bounds.size.width - (itemMargin*2), itemViewHeight};
    int itemIndex = 0;
    for (UIView *itemOldView in self.scrollView.subviews) {
        if(![itemOldView isKindOfClass:[UIView class]]) continue;
        [itemOldView removeFromSuperview];
    }
    if(self.hideNonFocusedProducts && self.focusOnProductID)
    {
        NSDictionary *item = [MysticStore product:self.focusOnProductID];
        if(!item) return nil;
        self.items = [NSMutableArray arrayWithObject:item];
        self.menu.hidden = YES;
    }
    else
    {
        self.items = [self itemsForType:self.currentType];
    }
    
    for (NSDictionary *item in self.items) {
        
        BOOL download = [item[@"download"] boolValue];
        UIImage *itemImage = nil;
        NSString *itemImageName = item[@"image"];
        itemImageName = itemImageName ? itemImageName : [[item[@"key"] componentsSeparatedByString:@"."] lastObject];
        itemImage = [UIImage imageNamed:itemImageName];
        if(!itemImage) itemImage = [UIImage imageNamed:@"store_item_default"];
        NSString *productID = item[@"key"];
        SKProduct *product = [[RMStore defaultStore] productForIdentifier:productID];
        float priceVal = item[@"price"] ? [item[@"price"] floatValue] : 0;
        float price = priceVal;
        NSString *priceStr = [RMStore localizedPriceOfProduct:product];
        priceStr = priceStr ? [priceStr substringFromIndex:1] : nil;
        price = priceStr ? [priceStr floatValue] : price;
        BOOL purchased = [MysticStore hasPurchased:productID];
        
        
        
        itemView = [[UIView alloc] initWithFrame:itemFrame];
        itemFrame.origin.x += CGRectGetWidth(itemFrame) + (itemMargin/2);
        
        itemImageView = [[MysticImageView alloc] initWithFrame:(CGRect){0,0,CGRectGetWidth(itemFrame), CGRectGetWidth(itemFrame)}];
        itemImageView.image = itemImage;
        itemImageView.tag = 11111;
        itemImageView.backgroundColor = UIColor.blackColor;
        itemImageView.layer.shadowColor = UIColor.blackColor.CGColor;
        itemImageView.layer.shadowRadius = 5;
        itemImageView.layer.shadowOpacity = 0.35;
        itemImageView.layer.shadowOffset = CGSizeZero;
        itemImageView.contentMode = UIViewContentModeScaleAspectFill;
        [itemView addSubview:itemImageView];
        itemImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemImageViewTapped:)];
        [itemImageView addGestureRecognizer:tap];
        MysticAttrString *itmBtnStrN = [MysticAttrStringStyle string:price > 0 ? [NSString stringWithFormat:@"$%2.2f", price] : @"GET" style:MysticStringStyleStoreItemButton];
        MysticAttrString *itmBtnStrH = [MysticAttrStringStyle string:itmBtnStrN.attrString.string style:MysticStringStyleStoreItemButton state:UIControlStateHighlighted];
        MysticAttrString *itmBtnStrD = [MysticAttrStringStyle string:@"REQUESTING" style:MysticStringStyleStoreItemButton state:UIControlStateDisabled];
        MysticAttrString *itmBtnStrS = [MysticAttrStringStyle string:download ? @"DOWNLOADED" : @"PURCHASED" style:MysticStringStyleStoreItemButton state:UIControlStateSelected];

        
        itemButton = [MysticButton buttonWithAttrStr:itmBtnStrN.attrString target:self action:@selector(itemButtonTouched:)];
        [itemButton setAttributedTitle:itmBtnStrH.attrString forState:UIControlStateHighlighted];
        [itemButton setAttributedTitle:itmBtnStrD.attrString forState:UIControlStateDisabled];
        [itemButton setAttributedTitle:itmBtnStrS.attrString forState:UIControlStateSelected];
        
        [itemButton setWidth:itmBtnStrN.attrString.size.width+scrollViewMargin/2+(itemButton.padding*2) forState:UIControlStateNormal];
        [itemButton setWidth:itmBtnStrH.attrString.size.width+scrollViewMargin/2+(itemButton.padding*2) forState:UIControlStateHighlighted];
        [itemButton setWidth:itmBtnStrD.attrString.size.width+scrollViewMargin/2+(itemButton.padding*2) forState:UIControlStateDisabled];
        [itemButton setWidth:itmBtnStrS.attrString.size.width+scrollViewMargin/2+(itemButton.padding*2) forState:UIControlStateSelected];

        [itemButton setBorderColor:[UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1] forState:UIControlStateHighlighted];
        [itemButton setBorderColor:[UIColor colorWithRed:0.44 green:0.42 blue:0.38 alpha:1] forState:UIControlStateNormal];
        [itemButton setBorderColor:[UIColor colorWithRed:0.44 green:0.42 blue:0.38 alpha:1] forState:UIControlStateDisabled];
        [itemButton setBorderColor:[UIColor colorWithRed:0.44 green:0.42 blue:0.38 alpha:1] forState:UIControlStateSelected];

        
        itemButton.frame = (CGRect){0,itemImageView.frame.size.height + 40, itemButton.frame.size.width, itemButtonHeight};
        itemButton.enabled = YES;
        itemButton.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.25];
        itemButton.layer.cornerRadius = itemButton.frame.size.height/2;
        itemButton.layer.borderWidth = 1;
        itemButton.layer.borderColor =[UIColor colorWithRed:0.44 green:0.42 blue:0.38 alpha:1].CGColor;
        itemButton.center = (CGPoint){itemImageView.center.x, itemButton.frame.origin.y + itemButtonHeight/2};
        itemButton.selected = purchased;
        [itemView addSubview:itemButton];
        itemView.tag = itemIndex + 1111;
        
        
        MysticAttrString *itemTitle = [MysticAttrStringStyle string:[item[@"title"] uppercaseString] style:MysticStringStyleStoreItemTitle state:UIControlStateNormal];
        MysticAttrString *itemSubTitle = item[@"subtitle"] && [item[@"subtitle"] length] > 0 ? [MysticAttrStringStyle string:item[@"subtitle"] style:MysticStringStyleStoreItemSubtitle state:UIControlStateNormal] : collectionSubTitle;
        CGRect itemSubTitleFrame = itemImageView.bounds;
        itemSubTitleFrame.size.height = itemSubTitle.size.height;
        itemSubTitleFrame.origin.y = itemImageView.bounds.size.height - itemSubTitleFrame.size.height - 30;
        
        CGRect itemTitleFrame = itemImageView.bounds;
        itemTitleFrame.size.height = itemTitle.size.height;
        itemTitleFrame.origin.y = itemSubTitleFrame.origin.y - itemTitleFrame.size.height - 4;
        
        UILabel *itemSubTitleLabel = [[UILabel alloc] initWithFrame:itemSubTitleFrame];
        itemSubTitleLabel.attributedText = itemSubTitle.attrString;
        itemSubTitleLabel.tag = 4567;
        [itemImageView addSubview:itemSubTitleLabel];
        
        UILabel *itemTitleLabel = [[UILabel alloc] initWithFrame:itemTitleFrame];
        itemTitleLabel.attributedText = itemTitle.attrString;
        itemTitleLabel.tag = 4566;

        [itemImageView addSubview:itemTitleLabel];
        
        [itemView sizeToFit];
        [self.scrollView addSubview:itemView];
        if(!selectedItemView && self.focusOnProductID && [productID isEqualToString:self.focusOnProductID])
        {
            selectedItemView = itemView;
            selectedItemPage = itemIndex;
        }
        itemIndex++;
        
    }
    itemFrame.origin.x -= (CGRectGetWidth(itemFrame) - (itemMargin/2));
    self.scrollView.contentSize = (CGSize){self.items.count * (CGRectGetWidth(itemFrame) + (itemMargin/2)), self.scrollView.frame.size.height};
//    if(bgImage) [self.blurredBackgroundView setImage:bgImage duration:0.5];
    if(selectedItemView && selectedItemPage != 0)
    {
        [self.scrollView scrollToPage:selectedItemPage animated:NO];
    }
    else
    {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        [self scrollViewDidChangePage:self.scrollView];
    }
    return self.items;
}
- (void) itemImageViewTapped:(UITapGestureRecognizer *)recognizer;
{
    int itemIndex = recognizer.view.superview.tag - 1111;
    UIView *itemView = [self.scrollView viewWithTag:1111+itemIndex];
    UIImageView *imageView = [itemView viewWithTag:11111];
    imageView.transform = CGAffineTransformMakeScale(1.03, 1.03);
    [MysticUIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        imageView.transform = CGAffineTransformMakeScale(1.08, 1.08);
    } completion:nil];
}
- (void) itemButtonTouched:(MysticButton *)sender;
{
    if(sender.selected)
    {
        [MysticAlert notice:@"You already have this" message:@"You already have this add-on."];
        return;
    }
    [[RMStore defaultStore] addStoreObserver:self];

    int itemIndex = sender.superview.tag - 1111;
    sender.enabled = NO;
    sender.alpha = 0;
    self.lastSender = sender;
    NSDictionary *item = [self.items objectAtIndex:itemIndex];
    self.selectedItem = item;
    self.selectedItemIndex = itemIndex;
    
    BOOL download = [item[@"download"] boolValue];
    self.selectedItemIsDownload = download;
    sender.frame = (CGRect){0,sender.frame.origin.y, sender.frame.size.width , 34};
    sender.center = (CGPoint){sender.superview.frame.size.width/2, sender.frame.origin.y + 34/2};
    
    NSString *productID = item[@"key"];
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:productID];
    float priceVal = item[@"price"] ? [item[@"price"] floatValue] : 0;
    float price = priceVal;
    NSString *priceStr = [[RMStore localizedPriceOfProduct:product] substringFromIndex:1] ;
    price = [priceStr floatValue];
    self.selectedProductId = productID;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    activityIndicator *itemActivity = [[activityIndicator alloc] initWithFrame:(CGRect){0,0,sender.frame.size.height, sender.frame.size.height}];
    itemActivity.tag = 777888;
    itemActivity.alpha = 0;
    [itemActivity startLoading];
    itemActivity.center = sender.center;
    itemActivity.strokeColor = [UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00];
    [sender.superview addSubview:itemActivity];
    self.lastActivity = itemActivity;
    [itemActivity fadeIn:0.3 completion:^(BOOL finished) {
        [self purchaseProduct:self.selectedProductId];
    }];
    
    
    
}



- (void) categoryButtonTouched:(MysticButton *)sender;
{
    self.lastSender = nil;
    self.focusedItemView=nil;
    self.selectedItem=nil;
    self.selectedItemIndex=0;
    self.selectedProductId = nil;
    self.selectedItemIsDownload=NO;
    sender.selected = YES;
    for (MysticButton *sibling in sender.siblings) {
        sibling.selected = NO;
    }
    NSString *type = self.currentType;
    switch (sender.tag) {
        case 1: type = @"featured"; break;
        case 2: type = @"art"; break;
        case 3: type = @"other"; break;
        case 4: type = @"free"; break;
        default: break;
    }
    if(!type) type = @"featured";
    [self.scrollView fadeOut:0.3 completion:^(BOOL finished) {
        [self loadItems:type];
        [self.scrollView fadeIn:0.3];
    }];
    
}

- (void) noThanksTouched:(MysticButton *)sender;
{
    self.wasClosed = YES;
    sender.enabled = NO;
    [[RMStore defaultStore] removeStoreObserver:self];

    [@[self.patronView, self.activity, self.noThanksBtn] fadeOut:0.3 delay:0 completion:^(BOOL finished) {
        self.activity.center = self.view.center;
        self.activity.strokeColor = [UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00];
        self.lastSender.enabled = YES;
        self.lastSender.selected = YES;
        self.lastSender.alpha = 1;
        if(!self.lastSender)
        {
            return [self hide];
        }
        [@[self.scrollView, self.hideBtn, self.restoreButton, self.menu] fadeIn:0.3 delay:0 completion:^(BOOL finished){
            [self.patronView removeFromSuperview];
            self.patronView = nil;
            [self.noThanksBtn removeFromSuperview];
            self.noThanksBtn = nil;
            self.lastSender = nil;
            if(self.onNoThanks) self.onNoThanks(self,NO);
        }];
    }];
}
- (void) oneDollarTouched:(MysticButton *)sender;
{
    sender.enabled = NO;
    [self showActivityForDonateButton:sender];
    [[RMStore defaultStore] addPayment:@"ch.mysti.patronsupport1" success:^(SKPaymentTransaction *transaction) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if(self.wasClosed) return;
        DLog(@"success patron 1");
        [self showSuccessfulDonation];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        if(self.wasClosed) return;
        [self showFailedDonation:sender];
    }];
}
- (void) twoDollarTouched:(MysticButton *)sender;
{
    sender.enabled = NO;
    [self showActivityForDonateButton:sender];
    [[RMStore defaultStore] addPayment:@"ch.mysti.patronsupport2" success:^(SKPaymentTransaction *transaction) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if(self.wasClosed) return;
        DLog(@"success patron 2");
        [self showSuccessfulDonation];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        if(self.wasClosed) return;
        [self showFailedDonation:sender];
    }];
}
- (void) threeDollarTouched:(MysticButton *)sender;
{
    sender.enabled = NO;
    [self showActivityForDonateButton:sender];
    [[RMStore defaultStore] addPayment:@"ch.mysti.patronsupport3" success:^(SKPaymentTransaction *transaction) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if(self.wasClosed) return;
        DLog(@"success patron 3");
        [self showSuccessfulDonation];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        if(self.wasClosed) return;
        [self showFailedDonation:sender];
    }];
}

#pragma mark - Purchase Item

- (void) purchaseProduct:(NSString *)productID;
{
    [[RMStore defaultStore] addStoreObserver:self];
    
    self.lastSender = nil;
    NSDictionary *item = [MysticStore product:productID];
    self.selectedItem = item;
    
    BOOL download = [item[@"download"] boolValue];
    self.selectedItemIsDownload = download;
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:productID];
    float priceVal = item[@"price"] ? [item[@"price"] floatValue] : 0;
    float price = priceVal;
    NSString *priceStr = [[RMStore localizedPriceOfProduct:product] substringFromIndex:1] ;
    price = [priceStr floatValue];
    self.selectedProductId = productID;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   
        
#pragma mark - Request
        
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:@[self.selectedProductId]] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        NSMutableArray *productIds = [NSMutableArray arrayWithCapacity:products.count];
        for (SKProduct *product in products) {
            [productIds addObject:product.productIdentifier];
            BOOL isAdded = NO;
            for (SKProduct *p in self.products) if([p.productIdentifier isEqualToString:product.productIdentifier]) { isAdded=YES; break; }
            if(!isAdded) [self.products addObject:product];
        }
        for (NSString *invID in invalidProductIdentifiers) {
            BOOL isInvalidAdded = NO;
            for (NSString *cinvID in self.invalidProducts) if([invID isEqualToString:cinvID]) { isInvalidAdded=YES; break; }
            if(!isInvalidAdded) [self.invalidProducts addObject:invID];
        }
        
        if([invalidProductIdentifiers containsObject:self.selectedProductId])
        {
            [self.lastActivity removeFromSuperview];
            self.lastSender.enabled = YES;
            self.lastSender.selected = NO;
            self.lastSender.alpha = 1;
            self.selectedProductId = nil;
            [[RMStore defaultStore] removeStoreObserver:self];
            [MysticAlert notice:@"Item Unavailable" message:@"Sorry, but this is no longer available."];
            
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if(!self.lastSender)
            {
                [self hide];
            }
            return;
        }
#pragma mark - Purchase
        
        [[RMStore defaultStore] addPayment:self.selectedProductId success:^(SKPaymentTransaction *transaction) {
#pragma mark - Purchase Success
            [MysticUser remember:self.selectedProductId];
            
            DLog(@"payment finished: Download: %@ Product: %@", MBOOL(self.selectedItemIsDownload), self.selectedProductId);
            self.lastSender.enabled = YES;
            self.lastSender.selected = YES;
            [[RMStore defaultStore] removeStoreObserver:self];
            
            [self.lastActivity removeFromSuperview];
            self.lastSender.alpha = 1;
            if(!self.lastSender && !self.patronView)
            {
                [self hide];
            }
        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
#pragma mark - Purchase Error
            
            DLogError(@"failure for product purchase: '%@'\nError: %@", self.selectedProductId, error);
            [self.lastActivity removeFromSuperview];
            
            self.lastSender.enabled = YES;
            self.lastSender.selected = NO;
            
            self.lastSender.alpha = 1;
//            self.selectedProductId = nil;
            [[RMStore defaultStore] removeStoreObserver:self];
            NSString *title = @"Error";
            NSString *message = @"Something went wrong. Please try again.";
            if([error.localizedDescription.lowercaseString isEqualToString:@"cannot connect to itunes store"])
            {
                title = @"Something went wrong";
                message = @"Can't connect to iTunes Store. Please try again.";
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [MysticAlert notice:title message:message];
            if(!self.lastSender) [self showTryAgainButton];

        }];
        
        
        
    } failure:^(NSError *error) {
#pragma mark - Request Error
        
        [[RMStore defaultStore] removeStoreObserver:self];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.lastActivity removeFromSuperview];
        
        self.lastSender.enabled = YES;
        self.lastSender.selected = NO;
        self.lastSender.alpha = 1;
//        self.selectedProductId = nil;
        [MysticAlert notice:@"Error" message:@"Sorry, but there was an error connecting to the iTunes Store. Please check your internet connection and try again."];
        
        if(!self.lastSender) [self showTryAgainButton];
    }];
        
        
        
}
- (void) showTryAgainButton;
{
    if(self.tryAgainButton) return;
    MysticAttrString *itmBtnStrN = [MysticAttrStringStyle string:@"TRY AGAIN" style:MysticStringStyleStoreItemButton];
    MysticAttrString *itmBtnStrH = [MysticAttrStringStyle string:itmBtnStrN.attrString.string style:MysticStringStyleStoreItemButton state:UIControlStateHighlighted];
    MysticAttrString *itmBtnStrD = [MysticAttrStringStyle string:itmBtnStrN.attrString.string style:MysticStringStyleStoreItemButton state:UIControlStateDisabled];
    
    
    MysticButton *itemButton = [MysticButton buttonWithAttrStr:itmBtnStrN.attrString target:self action:@selector(tryAgainButtonTouched:)];
    [itemButton setAttributedTitle:itmBtnStrH.attrString forState:UIControlStateHighlighted];
    [itemButton setAttributedTitle:itmBtnStrD.attrString forState:UIControlStateDisabled];

    
    [itemButton setBorderColor:[UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1] forState:UIControlStateHighlighted];
    [itemButton setBorderColor:[UIColor colorWithRed:0.44 green:0.42 blue:0.38 alpha:1] forState:UIControlStateNormal];
    [itemButton setBorderColor:[UIColor colorWithRed:0.44 green:0.42 blue:0.38 alpha:1] forState:UIControlStateDisabled];
    
    
    itemButton.frame = (CGRect){0,0, itemButton.frame.size.width+12, 40};
    itemButton.enabled = YES;
    itemButton.hitInsets = (UIEdgeInsets){40,40,40,40};
    itemButton.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.25];
    itemButton.roundCorners = YES;
    itemButton.layer.borderWidth = 1;
    itemButton.layer.borderColor =[UIColor colorWithRed:0.44 green:0.42 blue:0.38 alpha:1].CGColor;
    itemButton.center = self.activity.center;
    [self.activity.superview addSubview:itemButton];
    self.activity.alpha = 0;
    self.tryAgainButton = itemButton;
}
- (void) tryAgainButtonTouched:(MysticButton *)sender;
{
    self.tryAgainButton = nil;
    sender.enabled = NO;
    [sender removeFromSuperview];
    [self showActivity:^(BOOL finished) {
        [self purchaseProduct:self.selectedProductId];
    }];
}
#pragma mark - scroll page changed

- (void) scrollViewDidChangePage:(MysticScrollView *)scrollView;
{
    NSDictionary *item = self.items.count > 0 && scrollView.currentPage < self.items.count ? [self.items objectAtIndex:scrollView.currentPage] : nil;
    if(!item) return;
    UIView *itemView = [scrollView viewWithTag:1111+scrollView.currentPage];
    UIImageView *imageView = [itemView viewWithTag:11111];
    [itemView.superview bringSubviewToFront:itemView];
    [MysticUIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if(self.focusedItemView)
        {
            UIImageView *imageViewInFocus = [self.focusedItemView viewWithTag:11111];
            imageViewInFocus.transform = CGAffineTransformIdentity;
        }
        imageView.transform = CGAffineTransformMakeScale(1.08, 1.08);
    } completion:^(BOOL finished) {
        mdispatch_high(^{
            NSString *bgImageName = item[@"background"];
            __unsafe_unretained __block UIImage *bgImage = [UIImage imageNamed:bgImageName] ;
            UIView *itemView = [self.scrollView viewWithTag:1111+self.scrollView.currentPage];
            UIImageView *imageView = [itemView viewWithTag:11111];
            UIImage *itemImage = imageView.image;
//            if(itemImage && !bgImage) bgImage = [self blurredItemImage:itemImage];
//            if(!bgImage) bgImage = [UIImage imageNamed:@"store_item_default_bg"];
            [self.blurredBackgroundView setImage:itemImage duration:0.35];
        });
    }];
    
    self.focusedItemView = itemView;
    
    
}

#pragma mark - show patron

- (void) showPatron:(MysticBlockAnimationFinished)completion  sender:(MysticButton *)sender;
{
    [@[self.scrollView, self.hideBtn, self.restoreButton, self.menu] fadeOut:0.3 delay:0.4 completion:^(BOOL finished){
        [self showPatronView:completion sender:sender];
    }];
    
}
- (void) showPatronView:(MysticBlockAnimationFinished)completion sender:(MysticButton *)sender;
{
    if(self.patronView)
    {
        [self.patronView removeFromSuperview];
        self.patronView = nil;
    }
    if(self.noThanksBtn)
    {
        [self.noThanksBtn removeFromSuperview];
        self.noThanksBtn = nil;
    }
    NSDictionary *item = self.selectedItem;
    if(sender)
    {
        int itemIndex = sender.superview.tag - 1111;
        sender.enabled = NO;
        sender.alpha = 0.25;
        item = [self.items objectAtIndex:itemIndex];
        self.selectedItemIndex = itemIndex;

    }
    
    self.selectedItem = item;
    
    BOOL download = [item[@"download"] boolValue];
    self.selectedItemIsDownload = download;
    
    NSString *productID = item[@"key"];
    
    CGFloat spacing = 20;
    UIView *access = [[UIView alloc] initWithFrame:CGRectWH(self.view.bounds, self.view.bounds.size.width, self.view.bounds.size.height - self.menu.frame.size.height - self.hideBtn.frame.size.height)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 60, 200)];
    msgLabel.tag = 5555;
    msgLabel.numberOfLines = 0;
    MysticButton *btn = [MysticButton button:[[MysticAttrString string:@"NO THANKS" style:MysticStringStyleStoreNevermindButton] attrString] target:self sel:@selector(noThanksTouched:)];
    //    [btn setAttributedTitle:[[MysticAttrString string:@"BACK" style:MysticStringStyleStoreNevermindButton] attrString] forState:UIControlStateSelected];
    
    MysticButton *btn1 = [MysticButton button:[[MysticAttrString string:@"$1" style:MysticStringStyleStoreDonateButton] attrString] target:self sel:@selector(oneDollarTouched:)];
    MysticButton *btn2 = [MysticButton button:[[MysticAttrString string:@"$2" style:MysticStringStyleStoreDonateButton] attrString] target:self sel:@selector(twoDollarTouched:)];
    MysticButton *btn3 = [MysticButton button:[[MysticAttrString string:@"$3" style:MysticStringStyleStoreDonateButton] attrString] target:self sel:@selector(threeDollarTouched:)];
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:@" "];
    [btn1 setAttributedTitle:attrStr forState:UIControlStateDisabled];
    [btn2 setAttributedTitle:attrStr forState:UIControlStateDisabled];
    [btn3 setAttributedTitle:attrStr forState:UIControlStateDisabled];
    btn.tag = 6666;
    btn1.tag = 3333;
    btn2.tag = btn1.tag+1;
    btn3.tag = btn2.tag+1;
    NSString *title = self.selectedItemIsDownload ? @"DOWNLOADING..." : @"SUPPORT MYSTIC?";
    NSString *descrpition = self.selectedItemIsDownload ? @"While you wait for your FREE art to download, would you like to support Mystic by giving us a buck or two?" : @"This add-on is free, and we need your support to keep releasing new features. Would you like to support Mystic by giving us a buck or two?";
    titleLabel.tag = 8888;
    titleLabel.attributedText = [[MysticAttrString string:title style:MysticStringStyleStoreDonateTitle] attrString];
    msgLabel.attributedText = [[MysticAttrString string:descrpition style:MysticStringStyleStoreDonateDescription] attrString];
    [titleLabel sizeToFit];
    [msgLabel sizeToFit];
    [btn sizeToFit];
    [access addSubview:titleLabel];
    [access addSubview:msgLabel];
    [access addSubview:btn1];
    [access addSubview:btn2];
    [access addSubview:btn3];
    
    
    titleLabel.frame = CGRectOffset(titleLabel.frame, 0,0);
    CGRect messageFrame = CGRectOffset(msgLabel.frame, 0,CGRectGetMaxY(titleLabel.frame) + spacing);
    msgLabel.frame = CGRectWH(messageFrame, MIN(CGRectGetWidth(messageFrame), CGRectInset(access.bounds, spacing*2, 0).size.width), CGRectGetHeight(messageFrame));
    
    btn1.frame = (CGRect){0,CGRectGetMaxY(msgLabel.frame)+spacing*2.5,80,80};
    btn2.frame = (CGRect){80 + spacing*1.5,btn1.frame.origin.y,80,80};
    btn3.frame = (CGRect){160+ spacing*3,btn1.frame.origin.y,80,80};
    
    
    
    
    btn.frame = CGRectOffset(CGRectInset(btn.frame, -spacing,-spacing/2), 0, CGRectGetMaxY(msgLabel.frame) + spacing*3);
    MBorder(btn, [UIColor colorWithRed:0.44 green:0.42 blue:0.38 alpha:1.00], 1.5);
    MBorder(btn1, [UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00], 2);
    MBorder(btn2, [UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00], 2);
    MBorder(btn3, [UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00], 2);
    
    
    btn.layer.cornerRadius = CGRectGetHeight(btn.frame)/2;
    btn1.layer.cornerRadius = CGRectGetHeight(btn1.frame)/2;
    btn2.layer.cornerRadius = CGRectGetHeight(btn2.frame)/2;
    btn3.layer.cornerRadius = CGRectGetHeight(btn3.frame)/2;
    
    
    CGSize accessSize = titleLabel.frame.size;
    accessSize.width = MAX(CGRectGetMaxX(btn3.frame),MAX(MAX(CGRectGetWidth(titleLabel.frame), CGRectGetWidth(msgLabel.frame)), CGRectGetWidth(btn.frame)));
    accessSize.height += (spacing*2) + CGRectGetHeight(titleLabel.frame) + CGRectGetHeight(msgLabel.frame) + CGRectGetHeight(btn3.frame);
    
    CGFloat btn123Margin = (accessSize.width - CGRectGetMaxX(btn3.frame))/2;
    btn1.frame = CGRectAddX(btn1.frame, btn123Margin);
    btn2.frame = CGRectAddX(btn2.frame, btn123Margin);
    btn3.frame = CGRectAddX(btn3.frame, btn123Margin);
    
    titleLabel.center = CGPointX(titleLabel.center, accessSize.width/2);
    msgLabel.center = CGPointX(msgLabel.center, accessSize.width/2);
    btn.center = CGPointXY(btn.center, self.view.center.x, CGRectGetHeight(self.view.bounds) - btn.frame.size.height - spacing);
    access.alpha = 0;
    access.frame = (CGRect){0,0,accessSize.width, accessSize.height};
    access.center = self.view.center;
    [self.view insertSubview:access aboveSubview:self.scrollView];
    self.patronView = access;
    [self.view addSubview:btn];
    self.noThanksBtn = btn;
    
    self.activity.strokeColor = [UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00];
//    self.activity.alpha = 0;
    [self.activity startLoading];
    self.activity.center = (CGPoint){self.view.center.x, self.patronView.frame.origin.y - spacing*2 - CGRectGetHeight(self.activity.frame)/2};

    [MysticUIView animate:0.3 animations:^{
        self.activity.alpha = 1;
    } completion:^(BOOL finished) {
        [@[self.noThanksBtn, self.patronView] fadeIn:0.4 delay:0 completion:completion];

    }];
}

- (void) showSuccessfulDonation;
{
    MysticButton *btn1 = [self.patronView viewWithTag:3333];
    MysticButton *btn2 = [self.patronView viewWithTag:3334];
    MysticButton *btn3 = [self.patronView viewWithTag:3335];
    [@[btn1, btn2, btn3] fadeOut:0.3 delay:0 completion:^(BOOL finished) {
        if(self.wasClosed) return;
        UILabel *msgLabel = [self.patronView viewWithTag:5555];
        msgLabel.attributedText = [[MysticAttrString string:@"Thank you for supporting Mystic!" style:MysticStringStyleAccessDescription] attrString];
        self.noThanksBtn.selected = YES;
        if(self.onDonate) self.onDonate(self,YES);
    }];
}
- (void) showFailedDonation:(MysticButton *)sender;
{
    UILabel *msgLabel = [self.patronView viewWithTag:5555];
    msgLabel.attributedText = [[MysticAttrString string:@"Something went wrong. Please try again." style:MysticStringStyleAccessDescription] attrString];
    sender.enabled = YES;
    UIActivityIndicatorView *actv = [sender viewWithTag:9999];
    [actv removeFromSuperview];
    self.noThanksBtn.selected = NO;
}
- (void) showActivityForDonateButton:(MysticButton *)sender;
{
    UIActivityIndicatorView *actv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    actv.tag = 9999;
    actv.center = (CGPoint){sender.frame.size.width/2, sender.frame.size.height/2};
    actv.color = [UIColor colorWithCGColor:sender.layer.borderColor];
    [actv startAnimating];
    [sender addSubview:actv];
}

#pragma mark - RMStore Delegate

- (void) storeDownloadCanceled:(NSNotification*)notification;
{
    [self.activity completeLoading:NO completion:nil];
    
}

- (void) storeDownloadFailed:(NSNotification*)notification ;
{
    [self.activity completeLoading:NO completion:nil];
}

- (void) storeDownloadFinished:(NSNotification*)notification;
{
    SKDownload *download = notification.rm_storeDownload; // Apple-hosted only
    NSString *productIdentifier = notification.rm_productIdentifier;
    NSURL *downloadContentURL = download.contentURL;
    
    NSString *zipPath = [[downloadContentURL path] stringByAppendingPathComponent:@"Contents"];
    NSString *unzipPath = [[[MysticCache cache:MysticCacheTypeDownloads].diskCachePath stringByAppendingPathComponent:download.contentIdentifier] suffix:@"/"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *url = [NSURL fileURLWithPath:unzipPath];
    NSError *error = nil;
    if(![fileManager fileExistsAtPath:unzipPath])
    {
        [fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
        [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    }
    
    if(!error)
    {
        NSError *error = nil;
        NSArray *files = [fileManager contentsOfDirectoryAtPath:zipPath error:&error];
        BOOL hadError = NO;
        for (NSString *file in files) {
            NSString *fullPathSrc = [zipPath stringByAppendingPathComponent:file];
            NSString *fullPathDst = [unzipPath stringByAppendingPathComponent:file];
            
            // not allowed to overwrite files - remove destination file
            [fileManager removeItemAtPath:fullPathDst error:NULL];
//            DLogSuccess(@"copying download: %@", fullPathDst);
            if ([fileManager moveItemAtPath:fullPathSrc toPath:fullPathDst error:&error] == NO) {
                DLogError(@"Error: unable to move downloaded item: %@", error);
                hadError = YES;
            }
        }
        
        if(!hadError)
        {
            NSString *filtersPath = [unzipPath stringByAppendingPathComponent:@"filters.plist"];
            NSDictionary *filters = [NSDictionary dictionaryWithContentsOfFile:filtersPath];
            
            NSMutableDictionary *newData = [NSMutableDictionary dictionaryWithDictionary:[Mystic core].data];
            newData = [newData makeMutable];
            // add pack to data
            NSMutableDictionary *packsData = newData[@"packs"];
            NSMutableDictionary *newPack = [(NSDictionary *)filters[@"pack"] makeMutable];
            [newPack setObject:productIdentifier forKey:@"product"];
            [newPack setObject:@YES forKey:@"purchased"];
//            DLogDebug(@"current packs: %lu %@", (unsigned long)packsData.allKeys.count, packsData.allKeys);
            [packsData setObject:newPack forKey:newPack[@"name"]];
//            DLogDebug(@"new packs: %lu %@", (unsigned long)packsData.allKeys.count, packsData.allKeys);
            [newData setObject:packsData forKey:@"packs"];
            // add new layers to data
            NSMutableDictionary *dataLayers = newData[newPack[@"group"]];
            for (NSString *newLayerKey in [filters[@"layers"] allKeys]) {
                NSMutableDictionary *newLayer = [NSMutableDictionary dictionaryWithDictionary:[filters[@"layers"] objectForKey:newLayerKey]];
                [newLayer setObject:[unzipPath stringByAppendingPathComponent:newLayer[@"image"]] forKey:@"image_path"];
                [newLayer setObject:[unzipPath stringByAppendingPathComponent:newLayer[@"thumb"]] forKey:@"thumb_path"];
                [newLayer setObject:productIdentifier forKey:@"product_id"];

                [dataLayers setObject:newLayer forKey:newLayerKey];
            }
            [newData setObject:dataLayers forKey:newPack[@"group"]];
            
            // add orders to data
            NSMutableDictionary *dataOrders = [newData objectForKey:@"orders"];
            NSMutableArray *dataOrdersGroup = [dataOrders objectForKey:newPack[@"group"]];
//            DLogSuccess(@"current group orders: %lu", (unsigned long)dataOrdersGroup.count);

            if(!dataOrdersGroup) { dataOrdersGroup = [NSMutableArray array]; [dataOrders setObject:dataOrdersGroup forKey:newPack[@"group"]]; }
            for (NSString *newLayerKey in [filters[@"layers"] allKeys]) {
                BOOL foundLayerInOrders = NO;
                for (NSString *lname in dataOrdersGroup) if([lname isEqualToString:newLayerKey]) { foundLayerInOrders = YES; break; }
                if(!foundLayerInOrders) [dataOrdersGroup addObject:newLayerKey];
            }
            [dataOrders setObject:dataOrdersGroup forKey:newPack[@"group"]];
//            DLogSuccess(@"new group orders: %lu", (unsigned long)dataOrdersGroup.count);
            [newData setObject:dataOrders forKey:@"orders"];

            // add group-packs order to data
            NSMutableArray *dataOrdersGroupPacks = [dataOrders[@"group-packs"] objectForKey:newPack[@"group"]];
            if(!dataOrdersGroupPacks) { dataOrdersGroupPacks = [NSMutableArray array]; [dataOrders[@"group-packs"] setObject:dataOrdersGroupPacks forKey:newPack[@"group"]]; }

            BOOL foundGroupPackInOrders = NO;
            for (NSString *packName in dataOrdersGroupPacks) if([packName isEqualToString:newPack[@"name"]]) { foundGroupPackInOrders = YES; break; }
            if(!foundGroupPackInOrders) [dataOrdersGroupPacks addObject:newPack[@"name"]];
            [dataOrders[@"group-packs"] setObject:dataOrdersGroupPacks forKey:newPack[@"group"]];
            NSMutableArray *dataOrdersPacks = dataOrders[@"packs"];
            BOOL foundPackInOrders = NO;
            for (NSString *packName in dataOrdersPacks) if([packName isEqualToString:newPack[@"name"]]) { foundPackInOrders = YES; break; }
            if(!foundPackInOrders) [dataOrdersPacks addObject:newPack[@"name"]];
            [dataOrders setObject:dataOrdersPacks forKey:@"packs"];

            [newData setObject:dataOrders forKey:@"orders"];
            
            
            [[Mystic core] saveData:newData];
            
            [[NSFileManager defaultManager] removeItemAtPath:filtersPath error:NULL];
        }
        
    }
    if(!self.patronView) return;
    UILabel *titleLabel = [self.patronView viewWithTag:8888];
    UILabel *msgLabel = [self.patronView viewWithTag:5555];
    if(self.activity) self.activity.progress = 1;

    if(!titleLabel || !msgLabel) return;
    
    [@[titleLabel, msgLabel] fadeOut:0.2 delay:0.15 completion:^(BOOL finished) {
        titleLabel.attributedText = [[MysticAttrString string:@"FINISHED" style:MysticStringStyleStoreDonateTitle] attrString];
        NSString *descrpition = @"Your FREE download is done.\nWould you like to support Mystic by giving us a buck or two?";
        msgLabel.attributedText = [[MysticAttrString string:descrpition style:MysticStringStyleStoreDonateDescription] attrString];
        [titleLabel fadeIn:0.3 delay:0 completion:^(BOOL finished) {
            
            [msgLabel fadeIn:0.3 delay:0 completion:nil];
            MysticWait(0.15, ^{
                self.activity.alpha = 0;
                [self.activity completeLoading:YES completion:nil];
                self.activity.strokeColor = [UIColor colorWithRed:0.37 green:0.80 blue:0.35 alpha:1.00];
                self.activity.transform = CGAffineTransformMakeScale(2, 2);
                [@[self.activity] fadeIn:0.3 delay:0 animations:^{
                    self.activity.transform = CGAffineTransformIdentity;
                } completion:nil];
            });
            
        }];
    }];
    
    self.noThanksBtn.selected = YES;
}

- (void)storeDownloadPaused:(NSNotification*)notification;
{
    
}

- (void)storeDownloadUpdated:(NSNotification*)notification;
{
    if(!self.patronView) [self showPatron:nil sender:self.lastSender];
    if(self.activity) self.activity.progress = notification.rm_downloadProgress;
}
- (void)storePaymentTransactionDeferred:(NSNotification*)notification;
{
    
}
- (void)storePaymentTransactionFailed:(NSNotification*)notification;
{
    
}
- (void)storePaymentTransactionFinished:(NSNotification*)notification;
{
    NSString *pid = notification.userInfo[@"productIdentifier"];
    if(pid) [MysticUser remember:pid];
    self.lastPurchaseId = pid;
    DLogError(@"Store transaction finished: %@", pid);

}
- (void)storeProductsRequestFailed:(NSNotification*)notification;
{
    
}
- (void)storeProductsRequestFinished:(NSNotification*)notification;
{
    
}
- (void)storeRefreshReceiptFailed:(NSNotification*)notification;
{
    
}
- (void)storeRefreshReceiptFinished:(NSNotification*)notification;
{
    
}
- (void)storeRestoreTransactionsFailed:(NSNotification*)notification;
{
    
}
- (void)storeRestoreTransactionsFinished:(NSNotification*)notification;
{
    
}

#pragma mark - Blur Image

- (UIImage *) blurredItemImage:(UIImage *)image;
{
    return [image
            ahk_applyBlurWithRadius:20.f
            tintColor:[UIColor colorWithRed:0.12 green:0.11 blue:0.11 alpha:0.6]
            saturationDeltaFactor:1
            maskImage:nil];
}
- (void)setUpBlurredBackgroundWithSnapshot:(UIImage *)previousKeyWindowSnapshot
{
//    previousKeyWindowSnapshot = [previousKeyWindowSnapshot
//                                    ahk_applyBlurWithRadius:15.f
//                                    tintColor:[UIColor colorWithRed:0.12 green:0.11 blue:0.11 alpha:0.7]
//                                    saturationDeltaFactor:2
//                                    maskImage:nil];
//    
    
    
    
    MysticImageView *backgroundView = [[MysticImageView alloc] initWithImage:previousKeyWindowSnapshot];
    backgroundView.frame = self.view.bounds;
    backgroundView.alpha = .8f;
    [self.view insertSubview:backgroundView atIndex:0];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.blurredBackgroundView = backgroundView;
}



@end
