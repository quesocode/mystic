//
//  MysticShopProductView.m
//  Mystic
//
//  Created by travis weerts on 3/27/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticShopProductView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Mystic.h"

@interface MysticShopProductView ()
{
    CGSize size;
}

@end
@implementation MysticShopProductView

static CGFloat kButtonPadding = 30;

@synthesize priceButton=_priceButton, productImageView=_productImageView, titleLabel=_titleLabel, productType, delegate, product=_product;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImageView *bgImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(41.0f, 15.0f, 237.0f, 246.0f)] autorelease];
        
        bgImageView.image = [UIImage imageNamed:@"shop-thumbnail-bg.jpg"];
        
        [self addSubview:bgImageView];
        
        //        self.layer.borderColor = [UIColor red].CGColor;
        //        self.layer.borderWidth = 1.0f;
        size = CGSizeZero;
        
        self.productImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(45.0f, bgImageView.frame.origin.y+4.0f, 228.0f, 229.0f)] autorelease];
        
        [self addSubview:self.productImageView];
        
        size.height += CGRectGetHeight(bgImageView.frame);
        
//        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.productImageView.frame.origin.x, bgImageView.frame.origin.y+ bgImageView.frame.size.height+padding, self.productImageView.frame.size.width, 30.0f)];
//        self.titleLabel.backgroundColor =[UIColor clearColor];
//        self.titleLabel.textAlignment = NSTextAlignmentCenter;
//        self.titleLabel.font = [MysticUI gothamLight:16];
//        self.titleLabel.text = @"Product Name";
//        self.titleLabel.textColor = [UIColor mysticTitleDarkColor];
//        self.titleLabel.shadowColor = [UIColor whiteColor];
//        self.titleLabel.shadowOffset = CGSizeMake(0, 1);
//        [self addSubview:self.titleLabel];
//        size.height += CGRectGetHeight(self.titleLabel.frame);
        
        

        
        
        

        self.priceButton = [MysticUI buttonWithTitle:@"FREE" action:nil];
        
        self.priceButton.frame = CGRectMake(frame.size.width/2 - 60.0f/2, bgImageView.frame.origin.y + bgImageView.frame.size.height+10.0f, 60.0f, 34.0f);
        self.priceButton.clipsToBounds = YES;
        self.priceButton.titleLabel.clipsToBounds = YES;
        self.priceButton.titleLabel.font = [MysticUI gotham:15];
        self.priceButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.priceButton.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.priceButton.adjustsImageWhenHighlighted = YES;
        
        
        
        [self addSubview:self.priceButton];
        
        
        
        
        [self resetPriceButton:NO];
        
        
        size.height += CGRectGetHeight(self.priceButton.frame) + 10.0f;
        
        
        
        
        
        
    }
    return self;
}

- (void) buyPriceButton:(BOOL)animated;
{
    NSString *buyTitle = self.product.charity ? @"DONATE" : @"BUY";
    [self buyPriceButtonTitle:buyTitle animated:animated];
}
- (void) buyPriceButtonTitle:(NSString *)title animated:(BOOL)animated;
{
    if(animated)
    {
        [UIView beginAnimations:@"priceButtonBuy" context:nil];
        [UIView setAnimationDuration:0.2];
    }
    [self.priceButton setBackgroundImage:[MysticUI buttonBgImageNamed:@"button-green-bg.png"] forState:UIControlStateNormal];
    [self.priceButton setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [self.priceButton setTitle:title forState:UIControlStateNormal];
    [self.priceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.priceButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    [self.priceButton setBackgroundImage:[MysticUI buttonBgImageNamed:@"button-green-bg-highlighted.png"] forState:UIControlStateHighlighted];
    [self.priceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.priceButton setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    
    CGRect bframe = self.priceButton.frame;
    CGSize bsize = [title sizeWithFont:self.priceButton.titleLabel.font];
    bframe.size.width = bsize.width + kButtonPadding;
    bframe.origin.x = self.frame.size.width/2 - bframe.size.width/2;
    self.priceButton.frame = bframe;
    
    
    
    if(animated)
    {
        [UIView commitAnimations];
    }
}
- (void) downloadingPriceButton:(BOOL)animated;
{
    [self downloadingPriceButtonTitle:@"DOWNLOADING" animated:animated];
}
- (void) downloadingPriceButtonTitle:(NSString *)title animated:(BOOL)animated;
{
    if(animated)
    {
        [UIView beginAnimations:@"priceButtonD" context:nil];
        [UIView setAnimationDuration:0.2];
    }
    [self.priceButton setBackgroundImage:[MysticUI buttonBgImageNamed:@"button-white-inset-bg.png"] forState:UIControlStateNormal];
    [self.priceButton setTitleShadowColor:[UIColor string:@"f7f7f0"] forState:UIControlStateNormal];
    [self.priceButton setTitle:title forState:UIControlStateNormal];
    [self.priceButton setTitleColor:[UIColor string:@"9d9d98"] forState:UIControlStateNormal];
    self.priceButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    
    [self.priceButton setBackgroundImage:[MysticUI buttonBgImageNamed:@"button-white-inset-bg-highlighted.png"] forState:UIControlStateHighlighted];
    [self.priceButton setTitleColor:[UIColor string:@"9d9d98"] forState:UIControlStateHighlighted];
    [self.priceButton setTitleShadowColor:[UIColor string:@"f7f7f0"] forState:UIControlStateHighlighted];
    
    CGRect bframe = self.priceButton.frame;
    CGSize bsize = [title sizeWithFont:self.priceButton.titleLabel.font];
    bframe.size.width = bsize.width + kButtonPadding;
    bframe.origin.x = self.frame.size.width/2 - bframe.size.width/2;
    self.priceButton.frame = bframe;
    
    if(animated)
    {
        [UIView commitAnimations];
    }
}

- (void) resetPriceButton:(BOOL)animated;
{
    
    NSString *title = self.product ? self.product.priceString : @"FREE";
    [self priceButtonTitle:title animated:animated];
    [self.priceButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        
        NSString *buyTitle = self.product.charity ? @"DONATE" : @"BUY";
        BOOL isBuy = [[self.priceButton titleForState:UIControlStateNormal] isEqualToString:buyTitle];
        BOOL isDownloading = [[self.priceButton titleForState:UIControlStateNormal] isEqualToString:@"DOWNLOADING"];
        [MysticUIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            if(isDownloading)
            {
                [self resetPriceButton:NO];
            }
            else if(!isBuy)
            {
                
                [self buyPriceButton:NO];
                
            }
            CGRect bframe = self.priceButton.frame;
            CGSize bsize = [[self.priceButton titleForState:UIControlStateNormal] sizeWithFont:self.priceButton.titleLabel.font];
            bframe.size.width = bsize.width + kButtonPadding;
            bframe.origin.x = self.frame.size.width/2 - bframe.size.width/2;
            self.priceButton.frame = bframe;
            
        } completion:^(BOOL finished) {
            if(isBuy && self.delegate && [self.delegate respondsToSelector:@selector(productViewPurchaseSelected:)])
            {
                [self.delegate productViewPurchaseSelected:self];
            }
        }];
        
    }];
}

- (void) priceButtonTitle:(NSString *)title animated:(BOOL)animated;
{
    if(animated)
    {
        [UIView beginAnimations:@"priceButtont" context:nil];
        [UIView setAnimationDuration:0.2];
    }
    [self.priceButton setTitle:title forState:UIControlStateNormal];
    [self.priceButton setBackgroundImage:[MysticUI buttonBgImageNamed:@"button-white-bg.png"] forState:UIControlStateNormal];
    [self.priceButton setTitleColor:[UIColor mysticTitleDarkColor] forState:UIControlStateNormal];
    [self.priceButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.priceButton setTitleShadowColor:[UIColor mysticReallyLightGrayColor] forState:UIControlStateHighlighted];
    self.priceButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    
    [self.priceButton setBackgroundImage:[MysticUI buttonBgImageNamed:@"button-white-bg-highlighted.png"] forState:UIControlStateHighlighted];
    [self.priceButton setTitleColor:[UIColor mysticTitleDarkColor] forState:UIControlStateHighlighted];
    [self.priceButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    CGRect bframe = self.priceButton.frame;
    CGSize bsize = [title sizeWithFont:self.priceButton.titleLabel.font];
    bframe.size.width = bsize.width + kButtonPadding;
    bframe.origin.x = self.frame.size.width/2 - bframe.size.width/2;
    self.priceButton.frame = bframe;
    
    if(animated)
    {
        [UIView commitAnimations];
    }
    
}

- (void) setPriceButtonTitle:(NSString *)title animated:(BOOL)animated;
{
    if(animated)
    {
        [UIView beginAnimations:@"priceButton" context:nil];
        [UIView setAnimationDuration:0.2];
    }
    [self.priceButton setTitle:title forState:UIControlStateNormal];
    
    
    CGRect bframe = self.priceButton.frame;
    CGSize bsize = [title sizeWithFont:self.priceButton.titleLabel.font];
    bframe.size.width = bsize.width + kButtonPadding;
    bframe.origin.x = self.frame.size.width/2 - bframe.size.width/2;
    self.priceButton.frame = bframe;
    
    if(animated)
    {
        [UIView commitAnimations];
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGFloat topOffset = (CGFloat)((int)((self.frame.size.height -size.height)/2));
    CGFloat nextY = topOffset;
    CGRect resetFrame = [(UIView *)[self.subviews objectAtIndex:0] frame];
    resetFrame.origin.y = topOffset;
    [(UIView *)[self.subviews objectAtIndex:0] setFrame:resetFrame];
    topOffset += resetFrame.size.height;
    resetFrame = self.productImageView.frame;
    
    resetFrame.origin.y = nextY + 4.0f;
    
    self.productImageView.frame = resetFrame;
    
//    resetFrame = self.titleLabel.frame;
//    resetFrame.origin.y = topOffset ;
//    
//    nextY = resetFrame.origin.y + resetFrame.size.height+10.0f;
    
//    self.titleLabel.frame = resetFrame;
//    
    resetFrame = self.priceButton.frame;
    resetFrame.origin.y = topOffset+10.0f;
    
    self.priceButton.frame = resetFrame;
    
    
    
}

- (void) setProduct:(MysticShopProduct *)product
{
    if(_product) [_product release], _product=nil;
    _product = [product retain];
    
    self.titleLabel.text = product.title;
    
    self.priceButton.enabled = YES;
    SKProduct *myProduct = [MysticShop purchasedProduct:product.productID];
    
    if(myProduct)
    {
        BOOL isDownloaded = [MysticShop downloadedProduct:product.productID];
        if(myProduct.downloadable && !isDownloaded)
        {
            [self priceButtonTitle:@"DOWNLOAD" animated:NO];
            [self.priceButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
                if(self.delegate && [self.delegate respondsToSelector:@selector(productViewPurchaseSelected:)])
                {
                    [self.delegate productViewPurchaseSelected:self];
                }
            }];
        }
        else if(myProduct.downloadable && isDownloaded)
        {
            [self downloadingPriceButtonTitle:@"DOWNLOADED" animated:NO];
            [self.priceButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
               
                [self buyPriceButtonTitle:@"DOWNLOAD" animated:NO];
                [self.priceButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
                    if(self.delegate && [self.delegate respondsToSelector:@selector(productViewPurchaseSelected:)])
                    {
                        [self.delegate productViewPurchaseSelected:self];
                    }
                }];
                
            }];
        }
        else
        {
            [self downloadingPriceButtonTitle:@"PURCHASED" animated:NO];
            self.priceButton.enabled = NO;
        }
    }
    else
    {
        [self resetPriceButton:NO];
    }
    
    
    
    
    
    
    self.productImageView.image = [UIImage imageNamed:product.imageName];
    self.productType = product.type;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
