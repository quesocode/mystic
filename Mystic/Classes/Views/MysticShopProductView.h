//
//  MysticShopProductView.h
//  Mystic
//
//  Created by travis weerts on 3/27/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticButton.h"
#import "Mystic.h"

@class MysticShopProductView;

@protocol MysticShopProductViewDelegate <NSObject>

@optional
- (void) productViewPurchaseSelected:(MysticShopProductView *)productView;

@end

@interface MysticShopProductView : UIView

@property (nonatomic, retain) UIImageView *productImageView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) MysticButton *priceButton;
@property (nonatomic, assign) MysticProductType productType;
@property (nonatomic, assign) id<MysticShopProductViewDelegate> delegate;
@property (nonatomic, retain) MysticShopProduct *product;

- (void) downloadingPriceButton:(BOOL)animated;
- (void) downloadingPriceButtonTitle:(NSString *)title animated:(BOOL)animated;
- (void) buyPriceButton:(BOOL)animated;
- (void) buyPriceButtonTitle:(NSString *)title animated:(BOOL)animated;
- (void) resetPriceButton:(BOOL)animated;
- (void) priceButtonTitle:(NSString *)title animated:(BOOL)animated;
- (void) setPriceButtonTitle:(NSString *)title animated:(BOOL)animated;
@end
