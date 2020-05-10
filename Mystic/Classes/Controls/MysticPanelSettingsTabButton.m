//
//  MysticPanelSettingsTabButton.m
//  Mystic
//
//  Created by Me on 3/25/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPanelSettingsTabButton.h"

@implementation MysticPanelSettingsTabButton

+ (UIEdgeInsets) contentInsets;
{
    return UIEdgeInsetsMake(7, 7, 7, 7);
    
}
- (void) dealloc;
{
    [_badge release];
    [_activeView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor randomColor];
    }
    return self;
}
- (BOOL) adjustsImageWhenHighlighted; { return NO; }
- (void) setActive:(BOOL)isActive
{
    [self setActive:isActive animated:YES];
}
- (void) setActive:(BOOL)isActive animated:(BOOL)animated;
{
    BOOL changed = isActive != super.active;
    [super setActive:isActive animated:animated];
//    [self showAsSelected:isActive];
    if(changed)
    {
        if(isActive)
        {
            [self showActiveView:animated];
        }
        else
        {
            [self showActiveView:animated];
        }
    }

    
}


- (void) showActiveView:(BOOL)animated;
{
    if(self.activeView)
    {
        [self.activeView removeFromSuperview];
        self.activeView = nil;
    }
    CGRect nippleFrame = (CGRect){0,0,50,18};
    CGSize nippleImageSize = (CGSize){50,27};

    
    UIImageView *nippleView = [[UIImageView alloc] initWithFrame:(CGRect)nippleFrame];
    nippleView.image = [MysticImage image:@(MysticIconTypeArrowUp) size:nippleImageSize color:[UIColor hex:@"403834"]];
    nippleView.contentMode = UIViewContentModeScaleToFill;
    nippleFrame = CGRectAlign(nippleView.frame, self.frame, MysticAlignTypeBottom);
    nippleFrame.origin.x = self.bounds.size.width/2 - nippleFrame.size.width/2;
    nippleFrame.origin.y = self.bounds.size.height - nippleFrame.size.height + 5;

    nippleView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    nippleView.frame = nippleFrame;
    [self addSubview:nippleView];
    
    self.activeView = [nippleView autorelease];
    
    
    
}


- (void) hideActiveView:(BOOL)animated;
{
    if(self.activeView)
    {
        [self.activeView removeFromSuperview];
        self.activeView = nil;
    }
}

- (void) showBadge:(BOOL)animated;
{
    NSInteger numberOfOptions = 1;
    CGRect badgeFrame = CGRectMake(0, 0, MYSTIC_UI_TAB_BADGE_SIZE, MYSTIC_UI_TAB_BADGE_SIZE);
    MysticTabBadgeView *b = [[MysticTabBadgeView alloc] initWithFrame:badgeFrame];
    b.badgeCount = numberOfOptions;
    
    CGAffineTransform oTrans = CGAffineTransformMakeScale(0.45, 0.45);
    
    
    if(animated)
    {
        b.alpha = 0;
        
        CGAffineTransform trans = CGAffineTransformMakeScale(1, 1);
        
        b.transform = trans;
        
    }
    self.badge = b;
    if(animated)
    {
        __unsafe_unretained __block MysticPanelSettingsTabButton *weakSelf = self;
        
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
    if(!self.badge && self.active) { [self showBadge:animated]; return; }
    
    
    
    NSInteger numberOfOptions = MAX([[MysticOptions current] numberOfOptions:self.types], 0);
    
    if(numberOfOptions < 1 && self.badge.badgeCount > 0)
    {
        return;
    }
//    DLog(@"number of options: %d == %d", numberOfOptions, self.badge.badgeCount);
    if(self.badge.badgeCount == numberOfOptions) return;
    [self.badge setBadgeCount:numberOfOptions animated:animated];
}
- (void) hideBadge:(BOOL)animated;
{
    if(animated)
    {
        __unsafe_unretained __block MysticPanelSettingsTabButton *weakSelf = self;
        [MysticUIView animateWithDuration:MYSTIC_UI_BADGE_DURATION animations:^{
            weakSelf.badge.alpha = 0;
            weakSelf.badge.transform = CGAffineTransformMakeScale(0.1, 0.1);
            
        } completion:^(BOOL finished) {
            weakSelf.badge = nil;
        }];
    }
    else
    {
        self.badge = nil;
        
    }
}
- (void) setBadge:(MysticTabBadgeView *)badge;
{
    if(_badge)
    {
        [_badge removeFromSuperview];
        [_badge release], _badge=nil;
    }
    
    if(badge)
    {
        _badge = [badge retain];
        
        
        CGRect tabImgBounds = self.imageView.bounds;
        CGRect tabImgSize = CGRectSize(self.imageView.image.size);
        CGSize actualSize = [MysticUI aspectFit:tabImgSize bounds:tabImgBounds].size;
        
        CGPoint badgeCenter = CGPointMake(self.imageView.center.x + (actualSize.width/2), self.imageView.center.y - (actualSize.height/2));
        
        badgeCenter.x += MYSTIC_UI_TAB_BADGE_OFFSETX;
        badgeCenter.y += MYSTIC_UI_TAB_BADGE_OFFSETY;
        
        _badge.center = badgeCenter;
        
        [self addSubview:_badge];
        
        
    }
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
