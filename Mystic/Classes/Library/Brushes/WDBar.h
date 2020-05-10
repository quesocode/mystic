//
//  WDBar.h
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2013 Steve Sprang
//

#import <UIKit/UIKit.h>

typedef enum {
    WDBarTypeView,
    WDBarTypeFlexible,
    WDBarTypeFixed
} WDBarItemType;

@interface WDBarItem : NSObject 
    
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIView *landscapeView;
@property (nonatomic, readonly) UIView *activeView;
@property (nonatomic, assign) WDBarItemType type;
@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL flexibleContent;
@property (nonatomic, assign) BOOL phoneLandscapeMode;

+ (WDBarItem *) barItemWithView:(UIView *)view;
+ (WDBarItem *) barItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
+ (WDBarItem *) barItemWithImage:(UIImage *)image landscapeImage:(UIImage *)landscapeImage target:(id)target action:(SEL)action;
+ (WDBarItem *) flexibleItem;
+ (WDBarItem *) fixedItemWithWidth:(NSUInteger)width;
+ (WDBarItem *) backButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;

- (void) setImage:(UIImage *)image;

@end

typedef enum {
    WDBarTypeBottom,
    WDBarTypeTop
} WDBarType;

@interface WDBar : UIView

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) BOOL ignoreTouches;
@property (nonatomic, assign) BOOL animateAfterLayout;
@property (nonatomic, assign) WDBarType barType;
@property (nonatomic, assign) float defaultFlexibleSpacing;
@property (nonatomic, assign) BOOL phoneLandscapeMode;
@property (nonatomic, assign) BOOL tightHitTest;

+ (WDBar *) bottomBar;
+ (WDBar *) topBar;

- (void) setTitle:(NSString *)title;
- (void) setItems:(NSArray *)items animated:(BOOL)animated;
- (void) addEdge;

- (void) setOrientation:(UIInterfaceOrientation)orientation;

@end
