//
//  MysticToolbarTitleButton.h
//  Mystic
//
//  Created by Me on 5/1/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticBarButton.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"


@interface MysticToolbarTitleButton : UIControl

@property (nonatomic, retain) MysticButton *button;
@property (nonatomic, retain) OHAttributedLabel *titleLabel;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property(nonatomic,copy) NSAttributedString *attributedText;
@property (nonatomic, assign) MysticToolType toolType;
@property (nonatomic, assign) MysticObjectType objectType;
@property (nonatomic, assign) BOOL canSelect, continueOnHold, touchUpCancelsDown, ready, useAttrText;
@property (nonatomic, assign) MysticPosition buttonPosition;
@property (nonatomic, assign) NSTimeInterval holdingInterval, holdingDelay;
@property (nonatomic, assign) BOOL cancelsEvents;
@property (nonatomic, assign) MysticColorType selectedColorType;
@property (nonatomic, retain) UIColor *selectedBackgroundColor, *normalBackgroundColor;
@property (nonatomic, assign) CGPoint positionOffset;
@property (nonatomic, assign) UIEdgeInsets hitInsets;
@property (nonatomic, retain) NSMutableDictionary *attrTitles;

+ (id) button:(id)titleOrImg action:(MysticBlockSender)action;

- (void) setTitleColor:(UIColor *)color forState:(UIControlState)state;
- (void) setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state;
- (NSString *)titleForState:(UIControlState)state;
- (void)setImage:(UIImage *)image forState:(UIControlState)state;
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
- (UIImage *)imageForState:(UIControlState)state;
- (UIImage *)backgroundImageForState:(UIControlState)state;
- (NSAttributedString *)attributedTitleForState:(UIControlState)state;
- (void) clear;
- (void) setBackgroundColor:(id)backgroundColor forState:(UIControlState)forState;
- (void) commonInit;
- (void) tap;
- (void) updateState;
- (UIColor *) titleColorForState:(UIControlState)state;

@end
