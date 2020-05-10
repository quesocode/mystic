//
//  MysticQuoteViewController.h
//  Mystic
//
//  Created by Me on 3/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticViewController.h"
#import "MysticTransView.h"
#import "MysticLayerEditViewController.h"
#import "MysticLayerTypeView.h"

@class MysticQuoteViewController, PackPotionOptionFont, MysticLayerToolbar,  MysticLayerTypeView;

@protocol MysticQuoteViewControllerDelegate <NSObject>

@required

- (void) quoteViewController:(MysticQuoteViewController *)controller didChooseQuote:(id)content;

- (void) quoteViewControllerDidCancel:(MysticQuoteViewController *)controller;


@end


@interface MysticQuoteViewController : MysticLayerEditViewController
@property (retain, nonatomic) PackPotionOptionFont *fontOption;
@property (nonatomic, retain) NSString *quoteText;
@property (nonatomic, retain) MysticTransView *transLayer;
@property (nonatomic, retain) NSArray *quotes;
@property (nonatomic, retain) MysticLayerTypeView *fontView;
@property (nonatomic, assign) UIFont *font;
@property (nonatomic, assign) float lineHeight, spacing;
@property (nonatomic, assign) MysticSlider *lineHeightSlider, *textSpacingSlider;
@property (nonatomic, assign) NSTextAlignment textAlignment;
- (id) initWithQuote:(NSString *)quoteText;

- (void) presentInView:(UIView *)view fromView:(UIView *)fromView;
- (void) dismissToView:(UIView *)fromView animations:(MysticBlockAnimationInfo)animations complete:(MysticBlockBOOL)finished;

- (void) unloadViews;

@end
