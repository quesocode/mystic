//
//  NavigationBar.m
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "NavigationBar.h"
#import "MysticUI.h"
#import "UIColor+Mystic.h"
#import "MysticColor.h"

@implementation NavigationBar

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
    // Initialization code
    borderStyle = NavigationBarBorderStyleBottom;
}

- (void) setBorderStyle:(NavigationBarBorderStyle)aborderStyle
{
    borderStyle = aborderStyle;
    [self setNeedsDisplay];
}

- (void) setBackgroundColorStyle:(MysticColorType)backgroundColorStyle
{
    BOOL needDisplay = _backgroundColorStyle != backgroundColorStyle;
    
    _backgroundColorStyle = backgroundColorStyle;
    
    switch (_backgroundColorStyle) {
        case MysticColorTypeBackgroundBrown:
        {
            [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [MysticUI gothamLight:30], UITextAttributeFont,
                                          [UIColor color:MysticColorTypeNavBar], UITextAttributeTextColor,
                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                          [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                          nil]];
            [[[self class] appearance] setTintColor:[UIColor color:MysticColorTypeNavBar]];

            break;
        }
        case MysticColorTypeNavBar:
        {
            [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [MysticUI gothamLight:30], UITextAttributeFont,
                                                                  [UIColor mysticChocolateColor], UITextAttributeTextColor,
                                                                  [UIColor clearColor], UITextAttributeTextShadowColor,
                                                                  [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                                  nil]];
            [[[self class] appearance] setTintColor:[UIColor color:MysticColorTypeNavBar]];

            
            break;
        }
            
        default: break;
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

- (CGSize)sizeThatFits:(CGSize)size {
    // Change navigation bar height. The height must be even, otherwise there will be a white line above the navigation bar.
//    CGSize newSize = CGSizeMake([MysticUI size].width, 50);
    CGSize newSize = CGSizeMake(self.superview.frame.size.width, 50);

    return newSize;
}
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
-(void)layoutSubviews {
    [super layoutSubviews];
    if(!self.customLayout) return;
    
    
    // Make items on navigation bar vertically centered.
    int i = 0;
    for (UIView *view in self.subviews) {
        i++;
        if (i == 0)
            continue;
        
        float centerY = self.bounds.size.height / 2.0f;
        
        CGPoint center = view.center;
        center.y = centerY;
        view.center = center;
    }
    
    UINavigationItem* item = [self topItem]; // (Current navigation item)
    
    [item.titleView setCenter:CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f)];
    
    
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    switch (_backgroundColorStyle) {
        case MysticColorTypeDrawerNavBar:
        {
            UIColor *bgColor = [UIColor colorWithType:MysticColorTypeDrawerNavBar];
            [bgColor setFill];
            CGContextFillRect(context, rect);

            break;
        }
        default:
        {
            UIColor *bgColor = [UIColor hex:@"303030"];
            [bgColor setFill];
            
            CGContextFillRect(context, rect);
//            UIImage *bgImage = [UIImage imageNamed:@"topbar-brown.png"];
//            [bgImage drawInRect:rect];
            break;
        }
    }
    
    
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    UIColor *bgColor = [MysticColor colorWithType:_backgroundColorStyle];
//    [bgColor setFill];
//    
//    CGContextFillRect(context, rect);
//    
//    if(self.borderStyle == NavigationBarBorderStyleBottom)
//    {
//        CGRect newRect = CGRectMake(0, 48, rect.size.width, 2.0f);
//        
//        CGContextClipToRect(context, newRect);
//        
//        UIImage *dottedTile = [MysticIcon imageNamed:@"dottedTile.png" color:[bgColor darker:0.15]];
//        CGContextDrawTiledImage(context, CGRectMake(0,0, 6, 2.0f), dottedTile.CGImage);
//    }
}
@end
