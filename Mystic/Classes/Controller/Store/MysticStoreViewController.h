//
//  MysticStoreViewController.h
//  Mystic
//
//  Created by Travis A. Weerts on 6/8/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticCommon.h"
#import "MysticStoreScrollView.h"
#import "MysticStoreMenuView.h"
#import "Mystic-Swift.h"
#import "RMStore.h"

@interface MysticStoreViewController : UIViewController <UIScrollViewDelegate, RMStoreObserver>

@property (nonatomic, retain) MysticStoreScrollView *scrollView;
@property (nonatomic, retain) MysticStoreMenuView *menu;
@property (nonatomic, assign) UIView *patronView;
@property (nonatomic, copy) MysticBlockObjBOOL onPurchased;
@property (nonatomic, copy) MysticBlockObjBOOL onNoThanks;
@property (nonatomic, copy) MysticBlockObjBOOL onDonate;
@property (nonatomic, copy) MysticBlockObjBOOL onHide;

@property (nonatomic, retain) MysticButton *hideBtn, *noThanksBtn;
@property (nonatomic, assign) MysticButton *restoreButton, *tryAgainButton;
@property (nonatomic, retain) activityIndicator *activity, *lastActivity;
@property (nonatomic, retain) NSString *currentType;
@property (nonatomic, retain) NSString *currentItem, *lastPurchaseId, *focusOnProductID;
@property (nonatomic, assign) MysticStoreType storeType;
@property (nonatomic, assign) BOOL shouldDownloadFocusedProduct, hideNonFocusedProducts;
@end
