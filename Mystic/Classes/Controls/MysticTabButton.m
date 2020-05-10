//
//  MysticTabButton.m
//  Mystic
//
//  Created by Me on 2/4/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticTabButton.h"

@implementation MysticTabButton


@synthesize badge=_badge;

- (void) dealloc;
{
    [_badge release];
    [super dealloc];
}

- (Class) backgroundViewClass;
{
    return [MysticTabButtonBackgroundView class];
}
- (BOOL) adjustsImageWhenHighlighted; { return NO; }
- (CGFloat) maxImageHeight;
{
    return 23.0f;
}
- (CGFloat) titleIconSpacing;
{
    return 6;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
//        self.layer.borderColor = [[UIColor color:MysticColorTypePanelTabBackground] lighter:0.1].CGColor;
//        self.layer.borderWidth = 0.5;

//        self.imageView.layer.borderColor = [[UIColor red] colorWithAlphaComponent:0.3].CGColor;
//        self.imageView.layer.borderWidth = 0.5;
//        self.titleLabel.layer.borderColor = [[UIColor blueColor] colorWithAlphaComponent:1].CGColor;
//        self.titleLabel.layer.borderWidth = 0.5;
//        self.imageView.contentMode = UIViewContentModeCenter;
        
        self.autoresizesSubviews = YES;
    }
    return self;
}

+ (UIEdgeInsets) contentInsets;
{
    return UIEdgeInsetsMake(1, 0, 1, 0);
    
}

- (void) setActive:(BOOL)isActive
{
    [self setActive:isActive animated:YES];
}
- (void) setActive:(BOOL)isActive animated:(BOOL)animated;
{
    BOOL changed = isActive != super.active;
    [super setActive:isActive animated:animated];
    if(changed)
    {
        if(isActive)
        {
            [self showBadge:animated];
        }
        else
        {
            [self hideBadge:animated];
        }
    }
    else
    {
        if(isActive)
        {
            [self updateBadge:animated];
        }
    }
    
}

- (void) showBadge:(BOOL)animated;
{
    return;
    DLog(@"Show badge for: %@", MysticString(self.type));
    
    NSInteger numberOfOptions = MAX([[MysticOptions current] numberOfOptions:self.types], 0);
    CGRect badgeFrame = CGRectMake(0, 0, MYSTIC_UI_TAB_BADGE_SIZE, MYSTIC_UI_TAB_BADGE_SIZE);
    MysticTabBadgeView *b = [[MysticTabBadgeView alloc] initWithFrame:badgeFrame];
    switch (self.type) {
        case MysticSettingLayers:
            b.useCheckmark = NO;
            break;
        case MysticObjectTypeSetting:
            numberOfOptions = numberOfOptions >= 1 ? 1 : numberOfOptions;
            break;
        default: break;
    }
    b.badgeCount = numberOfOptions;
    
    CGAffineTransform oTrans = CGAffineTransformMakeScale(MYSTIC_UI_TAB_BADGE_SCALE, MYSTIC_UI_TAB_BADGE_SCALE);
    

    if(animated)
    {
        b.alpha = 0;
        
        CGAffineTransform trans = CGAffineTransformMakeScale(1.65, 1.65);
        
        b.transform = trans;
        
    }
    self.badge = b;
    if(animated)
    {
        __unsafe_unretained __block MysticTabButton *weakSelf = self;

        [MysticUIView animateWithDuration:MYSTIC_UI_BADGE_DURATION animations:^{
            weakSelf.badge.alpha = 1;
            weakSelf.badge.transform = oTrans;
        }];
    }
    else
    {
        self.badge.transform = oTrans;
    }
    [b release];
}
- (void) updateBadge:(BOOL)animated;
{
    return;

//    if(!self.badge && self.active) { [self showBadge:animated]; return; }
//    
//    NSInteger numberOfOptions = MAX([[MysticOptions current] numberOfOptions:self.types forState:MysticOptionStateConfirmed], 0);
//    switch (self.type) {
//        case MysticObjectTypeSetting:
//            numberOfOptions = numberOfOptions >= 1 ? 1 : numberOfOptions;
//            break;
//        default: break;
//    }
//    if(self.badge.badgeCount == numberOfOptions) return;
//    [self.badge setBadgeCount:numberOfOptions animated:animated];
}
- (void) hideBadge:(BOOL)animated;
{
    return;
//
//    if(animated)
//    {
//        __unsafe_unretained __block MysticTabButton *weakSelf = self;
//        [MysticUIView animateWithDuration:MYSTIC_UI_BADGE_DURATION animations:^{
//            weakSelf.badge.alpha = 0;            
//            weakSelf.badge.transform = CGAffineTransformMakeScale(0.4, 0.4);
//            
//        } completion:^(BOOL finished) {
//            weakSelf.badge = nil;
//        }];
//    }
//    else
//    {
//        self.badge = nil;
//
//    }
}
- (void) setBadge:(MysticTabBadgeView *)badge;
{
    return;
//
//    if(_badge)
//    {
//        [_badge removeFromSuperview];
//        [_badge release], _badge=nil;
//    }
//    
//    if(badge)
//    {
//        _badge = [badge retain];
//        
//        _badge.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
//        
//        CGRect tabImgBounds = self.imageView.bounds;
//        CGRect tabImgSize = CGRectSize(self.imageView.image.size);
//        CGSize actualSize = [MysticUI aspectFit:tabImgSize bounds:tabImgBounds].size;
//
//        CGPoint badgeCenter = CGPointMake(self.imageView.center.x + actualSize.width/2, self.imageView.center.y - actualSize.height/2);
//        
//        badgeCenter.x += MYSTIC_UI_TAB_BADGE_OFFSETX;
//        badgeCenter.y += MYSTIC_UI_TAB_BADGE_OFFSETY;
//
//        _badge.center = badgeCenter;
//        
//        [self addSubview:_badge];
//
//    }
}

- (void) layoutSubviews;
{
    [super layoutSubviews];
    if(_badge)
    {
        CGRect tabImgBounds = self.imageView.bounds;
        CGRect tabImgSize = CGRectSize(self.imageView.image.size);
        CGSize actualSize = [MysticUI aspectFit:tabImgSize bounds:tabImgBounds].size;
        
        CGPoint badgeCenter = CGPointMake(self.imageView.center.x + (actualSize.width/2), self.imageView.center.y - (actualSize.height/2));
        
        badgeCenter.x += MYSTIC_UI_TAB_BADGE_OFFSETX;
        badgeCenter.y += MYSTIC_UI_TAB_BADGE_OFFSETY;
        
        _badge.center = badgeCenter;

        
    }
}

@end





@interface MysticTabButtonBackgroundView ()
{
    
}
@end

@implementation MysticTabButtonBackgroundView

- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.showDots = NO;
    }
    return self;
}
@end
