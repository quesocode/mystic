//
//  NavigationBar.m
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticNavigationBar.h"
#import "MysticUI.h"
#import "UIColor+Mystic.h"
#import "MysticColor.h"
#import "MysticButton.h"

@implementation MysticNavigationBar

@synthesize borderStyle, backgroundColorStyle=_backgroundColorStyle, customLayout=_customLayout;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    _height = MYSTIC_NAVBAR_HEIGHT;
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
        
    }
    return self;
}

- (void) commonInit;
{
    borderStyle = NavigationBarBorderStyleNone;
    _backgroundColorStyle = MysticColorTypeNavBar;
    _customLayout = YES;
    borderStyle = NavigationBarBorderStyleBottom;
}

- (void) setTranslucent:(BOOL)translucent;
{
    [super setTranslucent:translucent];
    [self setNeedsDisplay];
}
- (void) setBorderStyle:(NavigationBarBorderStyle)aborderStyle
{
    borderStyle = aborderStyle;
    [self setNeedsDisplay];
}
- (void) setHeight:(CGFloat)height;
{
    _height = height;
    [self.superview setNeedsLayout];
}
- (void) setBackgroundColorStyle:(MysticColorType)backgroundColorStyle
{
    BOOL needDisplay = _backgroundColorStyle != backgroundColorStyle;
    MysticColorType _prevBgColor = _backgroundColorStyle;
    _backgroundColorStyle = backgroundColorStyle;
    _drawColorStyle = _backgroundColorStyle;
    switch (backgroundColorStyle) {
        case MysticColorTypeBackgroundBrown:
        {
            [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [MysticUI gothamLight:30], UITextAttributeFont,
                                          [UIColor color:MysticColorTypeNavBarText], UITextAttributeTextColor,
                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                          [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                          nil]];
            [[[self class] appearance] setTintColor:[UIColor color:MysticColorTypeNavBar]];
            self.opaque = YES;
            self.translucent = NO;
            break;
        }
//        case MysticColorTypeNavBar:
//        {
//            [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                          [MysticUI gothamLight:30], UITextAttributeFont,
//                                          [UIColor color:MysticColorTypeNavBarText], UITextAttributeTextColor,
//                                          [UIColor clearColor], UITextAttributeTextShadowColor,
//                                          [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
//                                          nil]];
//            [[[self class] appearance] setTintColor:[UIColor color:MysticColorTypeNavBar]];
//            self.opaque = YES;
//            self.translucent = NO;
//            [self setNeedsDisplay];
//            break;
//        }
        case MysticColorTypeTranslucentNavBar:
        case MysticColorTypeJournalNavBar:
        {
            [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [MysticUI gothamBold:14], UITextAttributeFont,
                                          [UIColor color:MysticColorTypeNavBarText], UITextAttributeTextColor,
                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                          [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                          nil]];
//            [[[self class] appearance] setTitleVerticalPositionAdjustment:-200 forBarMetrics:UIBarMetricsDefault];
            [[[self class] appearance] setTintColor:[UIColor color:MysticColorTypeNavBar]];
            self.opaque = YES;
            self.translucent = YES;
            [self setNeedsLayout];
//            DLog(@"set it to nav bar style");
            break;
        }
        case MysticColorTypeNavBarTranslucentAndColor:
        {
            _drawColorStyle = _prevBgColor;
            self.opaque = YES;
            self.translucent = YES;
            needDisplay = YES;
            [self setNeedsLayout];

            break;
        }
        case MysticColorTypeClear:
        {
            self.opaque = NO;
            self.translucent = YES;
            break;
        }
        case MysticColorTypeNavBar:
        case MysticColorTypeCollectionNavBarBackground:
        {
            [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [MysticUI gothamBook:14], UITextAttributeFont,
                                          [UIColor color:MysticColorTypeCollectionNavBarText], UITextAttributeTextColor,
                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                          [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                          nil]];
            self.opaque = YES;
            self.translucent = NO;
            needDisplay = YES;
            [self setNeedsLayout];
            break;
        }
        
        default:
        {
            
            [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [MysticUI gothamLight:30], UITextAttributeFont,
                                          [UIColor color:MysticColorTypeNavBarText], UITextAttributeTextColor,
                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                          [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                          nil]];
//            [[[self class] appearance] setTintColor:[UIColor color:MysticColorTypeNavBar]];
            UIColor *bgColor = [UIColor color:_backgroundColorStyle];
            self.opaque = bgColor.alpha < 1 ? NO : YES;
            self.translucent = !self.opaque;

            break;
        }
    }
    
    if(needDisplay)
    {
        [self setNeedsDisplay];
    }
}



- (void) setItems:(NSArray *)items animated:(BOOL)animated;
{
    [super setItems:items animated:animated];
    
//    switch (_backgroundColorStyle) {
//        case MysticColorTypeBackgroundBrown:
//        {
//            break;
//        }
//        case MysticColorTypeNavBar:
//        {
//            
//            break;
//        }
//            
//        default:
//            break;
//    }
}

- (void) pushNavigationItem:(UINavigationItem *)item animated:(BOOL)animated;
{
    [super pushNavigationItem:item animated:animated];
}

- (UINavigationItem *)popNavigationItemAnimated:(BOOL)animated;
{
    UINavigationItem *navitem = [super popNavigationItemAnimated:animated];

    return navitem;
}

//- (BOOL) isTranslucent;
//{
//    return NO;
//}

- (void) setIsHiding:(BOOL)value;
{
    if(value) self.isShowing = NO;
    _isHiding = value;
}

- (void) setIsShowing:(BOOL)value;
{
    if(value) self.isHiding = NO;
    _isShowing = value;
}


- (CGSize)sizeThatFits:(CGSize)size {
    // Change navigation bar height. The height must be even, otherwise there will be a white line above the navigation bar.
//    CGSize newSize = CGSizeMake([MysticUI size].width, 50);
    CGSize newSize = CGSizeMake(self.superview.frame.size.width, _height);

    return newSize;
}
//
-(void)layoutSubviews {
    [super layoutSubviews];
    if(!self.customLayout) return;
    int i = 0;
    
    UINavigationItem* item = [self topItem];
    

    
    for (UIView *view in self.subviews) {
        

        if([view isEqual:[self topItem].titleView])continue;
        
        float centerY = self.bounds.size.height / 2.0f;
     
        
        CGPoint center = view.center;
        center.y = centerY;
        view.center = center;
        CGRect vFrame = view.frame;

        if([view isKindOfClass:[MysticButton class]])
        {
            MysticButton *viewBtn = (MysticButton *)view;
            switch (viewBtn.buttonPosition) {
                case MysticPositionLeft:
                {
                    vFrame.origin.x = 0 + viewBtn.positionOffset.x;

                    break;
                }
                case MysticPositionRight:
                {
                    vFrame.origin.x = self.frame.size.width - vFrame.size.width + viewBtn.positionOffset.x;

                    break;
                }
                default: break;
            }
            
        }
        view.frame = vFrame;
        i++;
    }
    
    [item.titleView setCenter:CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f)];
    if(item.titleView.frame.size.height == self.frame.size.height)
    {
    
        CGRect nf = item.titleView.frame;
        nf.origin.y = 0;
        item.titleView.frame = nf;
        
    }

    
}
- (void) setBarTintColor:(UIColor *)barTintColor;
{
    [self setBackgroundColor:barTintColor];
}
- (void) setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    [super setBarTintColor:backgroundColor];
    self.translucent = backgroundColor.alpha > 0 ? NO : YES;
    self.opaque = self.translucent;
    [self setNeedsDisplay];
}



- (void)drawRect:(CGRect)rect
{
    if(self.translucent && _backgroundColorStyle != MysticColorTypeNavBarTranslucentAndColor) return;
    
    switch (_drawColorStyle) {
        case MysticColorTypeClear:
        {
            UIColor *bgColor = [UIColor hex:@"303030"];
            [bgColor setFill];
            break;
        }
        default:
        {
            CGContextRef context = UIGraphicsGetCurrentContext();
//            UIColor *bgColor = [UIColor hex:@"303030"];
            UIColor *bgColor = [UIColor color:_drawColorStyle];

            [bgColor setFill];
            
            CGContextFillRect(context, rect);
//            UIImage *bgImage = [UIImage imageNamed:@"topbar-brown.png"];
//            [bgImage drawInRect:rect];
            break;
            
        }
    }
    
}
@end
