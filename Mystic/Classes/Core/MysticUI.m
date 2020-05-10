//
//  MysticUI.m
//  Mystic
//
//  Created by travis weerts on 12/8/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "MysticUI.h"
#import "UIColor+Mystic.h"
#import "MysticConstants.h"
#import "UserPotionManager.h"
#import "MysticIcon.h"
#import "MysticButton.h"
#import <sys/utsname.h>
#import "MysticUtility.h"

@implementation MysticUI

#pragma mark -
#pragma mark Sizing methods

+(BOOL)isIOS4_2OrGreater
{
    return [UIView instancesRespondToSelector:@selector(drawRect:forViewPrintFormatter:)];
}

+(BOOL)isIOS5OrGreater
{
    return [UIAlertView instancesRespondToSelector:@selector(alertViewStyle)];
}

+(BOOL)isIOS6OrGreater
{
    return [UIViewController instancesRespondToSelector:@selector(shouldAutomaticallyForwardRotationMethods)];
}

+(BOOL)isIOS7OrGreater
{
    return [UIViewController instancesRespondToSelector:@selector(childViewControllerForStatusBarStyle)];
}

+(BOOL)isIOS8OrGreater
{
    return [UIView instancesRespondToSelector:@selector(layoutMarginsDidChange)];
}

+(BOOL)isIPad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+(BOOL)isIPhone4
{
    static bool iphone_checked = NO;
    static bool iphone4 = NO;
    if (iphone_checked==NO)
    {
        iphone_checked = YES;
        // for now, this is all we know. we assume this
        // will continue to increase with new models but
        // for now we can't really assume
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            struct utsname u;
            uname(&u);
            if (!strcmp(u.machine, "iPhone3,1"))
            {
                iphone4 = YES;
            }
        }
    }
    return iphone4;
}
+(BOOL)isRetinaFourInch
{
    CGSize mainScreenBoundsSize = [[UIScreen mainScreen] bounds].size;
    if ([self isIOS8OrGreater]) {
        return (mainScreenBoundsSize.height == 568 || mainScreenBoundsSize.width == 568);
    }
    return (mainScreenBoundsSize.height == 568);
}

+(BOOL)isRetinaiPhone6
{
    if ([self isIOS8OrGreater]) {
        CGSize mainScreenBoundsSize = [[UIScreen mainScreen] bounds].size;
        return (mainScreenBoundsSize.height == 667 || mainScreenBoundsSize.width == 667);
    }
    return NO;
}

+(BOOL)isRetinaHDDisplay
{
    if ([self isIOS8OrGreater]) {
        return ([UIScreen mainScreen].scale == 3.0);
    }
    return NO;
}

+(BOOL)isRetinaDisplay
{
    // since we call this alot, cache it
    static CGFloat scale = 0.0;
    if (scale == 0.0)
    {
        // NOTE: iPad in iPhone compatibility mode will return a scale factor of 2.0
        // when in 2x zoom, which leads to false positives and bugs. This tries to
        // future proof against possible different model names, but in the event of
        // an iPad with a retina display, this will need to be fixed.
        // Credit to Brion on github for the origional fix.
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            NSRange iPadStringPosition = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
            if(iPadStringPosition.location != NSNotFound)
            {
                scale = 1.0;
                return NO;
            }
        }
        scale = [[UIScreen mainScreen] scale];
    }
    return scale > 1.0;
}



+ (BOOL) isIPhone5
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenSize.height > 480.0f) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL) iphone5:(void (^)())iphone5Block iphone:(void (^)())iphoneBlock;
{
    return [MysticUI iphone5:iphone5Block iphone:iphoneBlock iPad:^{
        
    }];
}



+ (BOOL) iphone5:(void (^)())iphone5Block iphone:(void (^)())iphoneBlock iPad:(void (^)())ipadBlock;
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenSize.height > 480.0f) {
            /*Do iPhone 5 stuff here.*/
            iphone5Block();
            return YES;
        } else {
            /*Do iPhone Classic stuff here.*/
            iphoneBlock();
        }
    } else {
        /*Do iPad stuff here.*/
        ipadBlock();
    }
    return NO;
}
+ (CGFloat) scale; { return [Mystic scale]; }
+ (CGRect) bounds
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGSize size = [MysticUI size];
    if (![[UIApplication sharedApplication] isStatusBarHidden]){
        y = 20;
    }
    return CGRectMake(x, y, size.width, size.height);
}
+ (CGPoint) scalePoint:(CGPoint)point scale:(CGFloat)scale;
{
    scale = scale == 0.0f ? [Mystic scale] : scale;

    CGPoint newPoint = point;
    newPoint.x = newPoint.x * scale;
    newPoint.y = newPoint.y * scale;
    return newPoint;
}
+ (CGSize) pixelSize;
{
    return [MysticUI pixelBounds].size;
}
+ (CGRect) pixelBounds;
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGSize size = [MysticUI size];
    if (![[UIApplication sharedApplication] isStatusBarHidden]){
        y = 20;
    }
    return CGRectMake(x, y, size.width*[Mystic scale], size.height*[Mystic scale]);
}

+ (CGRect) frame;
{
    return [MysticUI bounds];
}
+ (CGSize) size
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGFloat _width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat _height = [[UIScreen mainScreen] bounds].size.height;
    if (![[UIApplication sharedApplication] isStatusBarHidden]){
        _height-=20;
        //_width+=20;
    }
    
    if(!UIInterfaceOrientationIsPortrait(orientation) && UIInterfaceOrientationIsLandscape(orientation))
    {
        _width = _height;
        _height = _width;
    }
    
    return CGSizeMake(_width, _height);
}

+ (CGSize) screen
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGFloat _width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat _height = [[UIScreen mainScreen] bounds].size.height;
    
    
    if(!UIInterfaceOrientationIsPortrait(orientation) && UIInterfaceOrientationIsLandscape(orientation))
    {
        _width = _height;
        _height = _width;
    }
    
    return CGSizeMake(_width, _height);
}

+ (CGSize) pixelScreen;
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGFloat _width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat _height = [[UIScreen mainScreen] bounds].size.height;
    
    
    if(!UIInterfaceOrientationIsPortrait(orientation) && UIInterfaceOrientationIsLandscape(orientation))
    {
        _width = _height;
        _height = _width;
    }
    
    return CGSizeMake(_width*[Mystic scale], _height*[Mystic scale]);
}

+ (NSString *) stringFromRect:(CGRect)rect;
{
    return [NSString stringWithFormat:@"{{%f, %f}, {%f, %f}}", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

+ (NSString *) stringFromSize:(CGSize)size;
{
    return [NSString stringWithFormat:@"{%f, %f}", size.width, size.height];
}

+ (CGRect) aspectFit:(CGRect)rect bounds:(CGRect)maxRect
{
    return CGRectFit(rect, maxRect);
}




+ (CGRect) normalize:(CGSize)size bounds:(CGSize)bounds mode:(MysticStretchMode)stretchMode;
{
    CGRect normal = CGRectMake(0, 0, 1.0f, 1.0f);
    CGRect sizeFill = CGRectZero;
    CGSize newSize = size;
    CGSize diffSize = CGSizeZero;
    CGFloat ratio = 1.0f;
    switch (stretchMode) {
        case MysticStretchModeAspectFit:
        {
            CGRect sizeRect = [MysticUI rectWithSize:size];
            CGRect boundsRect = [MysticUI rectWithSize:bounds];
            CGRect aspectRect = [MysticUI aspectFit:sizeRect bounds:boundsRect];
            CGRect newSizeRect = [MysticUI rectWithSize:aspectRect.size];
            CGRect normalized = [MysticUI normalRect:newSizeRect bounds:boundsRect];
            normal.size = normalized.size;
            break;
        }
        case MysticStretchModeAspectFill:
        {
            sizeFill = CGRectWithContentMode(CGRectSize(size), CGRectSize(bounds), UIViewContentModeScaleAspectFit);
            sizeFill.origin = CGPointZero;

            if(sizeFill.size.width == bounds.width)
            {
                sizeFill.size.width = (sizeFill.size.width*bounds.height)/sizeFill.size.height;
                sizeFill.size.height = bounds.height;
                sizeFill = CGRectCenterAround(sizeFill, CGRectSize(bounds));
                normal.size.height = 1;
                normal.size.width = (sizeFill.size.width/bounds.width);
            }
            else if(sizeFill.size.height == bounds.height)
            {
                sizeFill.size.height = (sizeFill.size.height*bounds.width)/sizeFill.size.width;
                sizeFill.size.width = bounds.width;
                sizeFill = CGRectCenterAround(sizeFill, CGRectSize(bounds));
                normal.size.width = 1;
                normal.size.height = (sizeFill.size.height/bounds.height);
                
            }
            else
            {
                normal.size = CGSizeMake(1, 1);
                normal.origin = CGPointZero;
            }
            
            if(sizeFill.origin.y != 0) normal.origin.y = fabs(sizeFill.origin.y)/bounds.height * (sizeFill.origin.y < 0 ? -1 : 1);
            if(sizeFill.origin.x != 0) normal.origin.x = fabs(sizeFill.origin.x)/bounds.width * (sizeFill.origin.x < 0 ? -1 : 1);
            break;
        }
        default: break;
    }
    return normal;
}
+ (CGRect) normalize:(CGRect)rect normalRect:(CGRect)normalr;
{
    CGRect newrect = rect;
    CGSize newSize = rect.size;
    CGSize normal = normalr.size;
    newSize.width = rect.size.width*normal.width;
    newSize.height = rect.size.height*normal.height;
    
    newrect.size = newSize;
    newrect.origin = (CGPoint){(newrect.size.width*normalr.origin.x), (newrect.size.height*normalr.origin.y)};
    
    return newrect;
}

+ (CGSize) normalize:(CGSize)size normalValues:(CGSize)normal;
{
    CGSize newSize = size;
    newSize.width = size.width*normal.width;
    newSize.height = size.height*normal.height;
    return newSize;
}

+ (CGRect) positionRect:(CGRect)rect inBounds:(CGRect)bounds position:(MysticPosition)position;
{
    CGRect newrect = rect;
    switch (position) {
        case MysticPositionTopLeft:
        {
            newrect.origin = CGPointZero;
            break;
        }
        case MysticPositionTop:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds)/2)-(CGRectGetWidth(rect)/2), 0);
            break;
        }
        case MysticPositionTopRight:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), 0);
            break;
        }
        case MysticPositionLeftTop:
        {
            newrect.origin = CGPointMake(0, ((CGRectGetHeight(bounds)/4)*1)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionRightTop:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), ((CGRectGetHeight(bounds)/4)*1)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionLeftTopAligned:
        {
            newrect.origin = CGPointMake(0, ((CGRectGetHeight(bounds)/3)*1)-(CGRectGetHeight(rect)/2)) ;
            break;
        }
        case MysticPositionRightTopAligned:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), ((CGRectGetHeight(bounds)/3)*1)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionLeft:
        {
            newrect.origin = CGPointMake(0, (CGRectGetHeight(bounds)/2)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionCenter:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds)/2)-(CGRectGetWidth(rect)/2), (CGRectGetHeight(bounds)/2)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionRight:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), (CGRectGetHeight(bounds)/2)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionLeftBottom:
        {
            newrect.origin = CGPointMake(0, ((CGRectGetHeight(bounds)/4)*3)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionRightBottom:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), ((CGRectGetHeight(bounds)/4)*3)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionLeftBottomAligned:
        {
            newrect.origin = CGPointMake(0, ((CGRectGetHeight(bounds)/3)*2)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionRightBottomAligned:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), ((CGRectGetHeight(bounds)/3)*2)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionBottomLeft:
        {
            newrect.origin = CGPointMake(0, (CGRectGetHeight(bounds))-(CGRectGetHeight(rect)));
            break;
        }
        case MysticPositionBottom:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds)/2)-(CGRectGetWidth(rect)/2), (CGRectGetHeight(bounds))-(CGRectGetHeight(rect)));

            break;
        }
        case MysticPositionBottomRight:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), (CGRectGetHeight(bounds))-(CGRectGetHeight(rect)));
            break;
        }

            
        default: break;
    }
    newrect.origin.x += bounds.origin.x;
    newrect.origin.y += bounds.origin.y;

    return newrect;
}

+ (CGSize) scaleSize:(CGSize)size bounds:(CGSize)bounds;
{
    CGSize newSize = bounds;
    if(size.width < size.height)
    {
        newSize.height = bounds.height;
        newSize.width = (bounds.height*size.width)/size.height;
    }
    else
    {
        newSize.width = bounds.width;
        newSize.height = (bounds.width*size.height)/size.width;
    }
    return newSize;
}



+ (CGRect) cloneRectangle:(CGRect)maxRect
{
    return CGRectMake(maxRect.origin.x, maxRect.origin.y, maxRect.size.width, maxRect.size.height);
}


+ (CGFloat) widthToHeight:(CGSize)sized
{
    return sized.width / sized.height;
}

+ (CGFloat) heightToWidth:(CGSize)sized
{
    return sized.height / sized.width;
}

+ (CGRect) scaleWidth:(CGRect)sizerect height:(CGFloat)_height
{
    CGRect scaled = [self cloneRectangle:sizerect];
    CGFloat ratio = [self widthToHeight:sizerect.size];
    scaled.size.width = _height * ratio;
    scaled.size.height = _height;
    return scaled;
}

+ (CGRect) scaleHeight:(CGRect)sizerect width:(CGFloat)_width
{
    CGRect scaled = [self cloneRectangle:sizerect];
    CGFloat ratio = [self heightToWidth:sizerect.size];
    scaled.size.width = _width;
    scaled.size.height = _width*ratio;
    return scaled;
}


+ (CGRect) scaleRect:(CGRect)rect scale:(CGFloat)scale
{
    CGRect newsize = [self cloneRectangle:rect];
    scale = scale == 0.0f ? [Mystic scale] : scale;

    if(scale > 0)
    {
        newsize.size.width = newsize.size.width*scale;
        newsize.size.height = newsize.size.height*scale;
    }
    
    return newsize;
}

+ (CGSize) scaleSize:(CGSize)size scale:(CGFloat)scale;
{
    CGSize newsize = size;
    scale = scale == 0.0f ? [Mystic scale] : scale;
    if(scale != 1)
    {
        newsize.width = size.width*scale;
        newsize.height = size.height*scale;
    }
    
    return newsize;
}


+ (CGSize) scaleDown:(CGSize)size scale:(CGFloat)scale;
{
    CGSize newsize = size;
    scale = scale == 0.0f ? [Mystic scale] : scale;

    if(scale != 1)
    {
        newsize.width = size.width/scale;
        newsize.height = size.height/scale;
    }
    
    return newsize;
}

+ (CGRect) scaleToFill:(CGRect)sizer bounds:(CGRect)bounds
{
    CGRect scaled = [self scaleHeight:sizer width:bounds.size.width];
    
    if (scaled.size.height < bounds.size.height)
        scaled = [self scaleWidth:sizer height:bounds.size.height];
    
    
    scaled.origin.x = (bounds.size.width - scaled.size.width)/2;
    scaled.origin.y = (bounds.size.height - scaled.size.height)/2;
    
    
    return scaled;
}
+ (CGRect) normalRect:(CGRect)rect bounds:(CGRect)bounds;
{
    CGRect normal = rect;
    normal.origin.x = normal.origin.x/bounds.size.width;
    normal.origin.y = normal.origin.y/bounds.size.height;
    
    normal.size.width = normal.size.width/bounds.size.width;
    normal.size.height = normal.size.height/bounds.size.height;
    return normal;
}
+ (CGRect) translateNormalRect:(CGRect)rect bounds:(CGRect)bounds;
{
    CGRect normal = rect;
    normal.origin.x = bounds.size.width*normal.origin.x;
    normal.origin.y = bounds.size.height*normal.origin.y;
    
    normal.size.width = bounds.size.width*normal.size.width;
    normal.size.height = bounds.size.height*normal.size.height;
    return normal;
}
+ (CGRect) rectWithSize:(CGSize)size
{
    CGRect newRect = CGRectZero;
    newRect.size = size;
    return newRect;
}

+ (CGRect) rectWithPoint:(CGPoint)point
{
    CGRect newRect = CGRectZero;
    newRect.origin = point;
    return newRect;
}

+ (void) printFrameOfView:(UIView*)node
{
    [MysticUI printFrameOfView:node depth:0 maxDepth:0];
}
+ (void) printFrameOfView:(UIView*)node depth:(int)d maxDepth:(int)max;
{
    //Tabs are just for formatting
    NSString *tabs = @"";
    for (int i = 0; i < d; i++)
    {
        tabs = [tabs stringByAppendingFormat:@"\t"];
    }
    
    DLog(@"%@%@", tabs, node);
    
    d++; //Increment the depth
    if(max > 0 &&  d >= max) return;
    for (UIView *child in node.subviews)
    {
        [self printFrameOfView:child depth:d maxDepth:max];
    }
    
}

+ (void) setBackgroundColorOfViewTree:(UIView *)view color:(UIColor *)bgcolor
{
    for (UIView *subview in view.subviews) {
        subview.backgroundColor = bgcolor;
        if([subview.subviews count])
        {
            [MysticUI setBackgroundColorOfViewTree:subview color:bgcolor];
        }
    }
}


+ (CGFloat) linearStep:(CGFloat)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;
{
    return startValue+endValue*(step/totalSteps);
}
+ (CGFloat) easeInOutQuadStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;
{
    
    if ((step/=totalSteps/2) < 1) return endValue/2*step*step + startValue;
    return -endValue/2 * ((step-1)*(step-2) - 1) + startValue;
}

+ (CGFloat) easeOutQuadStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;
{
    step/=totalSteps;
    return -endValue *(step)*(step-2) + startValue;
}

+ (CGFloat) easeInQuadStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;
{
    step/=totalSteps;
    return endValue*(step)*step + startValue;
}

+ (CGFloat) easeInCubicStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;
{
    step/=totalSteps;
    return endValue*(step)*step*step + startValue;
}

+ (CGFloat) easeInSineStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;
{
    return -endValue * cos(step/totalSteps * (M_PI/2)) + endValue + startValue;

}

+ (CGFloat) easeInQuintStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;
{
    step/=totalSteps;
    return endValue*(step)*step*step*step*step + startValue;
    
}

+ (CGFloat) easeInCircStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;
{
    step/=totalSteps;
	return -endValue * (sqrt(1 - (step)*step) - 1) + startValue;
}


+ (CGFloat) easeInExpoStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;
{
    return (step==0) ? startValue : endValue * pow(2, 10 * (step/totalSteps - 1)) + startValue;
}


+ (CGFloat) easeOutExpoStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;
{
    return (step==totalSteps) ? startValue+endValue : endValue * (-pow(2, -10 * step/totalSteps) + 1) + startValue;
}


+ (CGFloat) easeInQuartStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;
{
    float s = step/totalSteps;
    return endValue*(s)*s*s*s + startValue;

    
//    return (step==0) ? startValue : endValue * pow(2, 10 * (step/totalSteps - 1)) + startValue;
}


+ (void) layout:(NSArray *)views bounds:(CGRect)bounds mode:(MysticLayoutMode)layoutMode;
{
    if(!views || views.count < 1) return;
    CGSize spacing = CGSizeZero;
    CGSize contentSize = CGSizeZero;
    for (UIView *view in views) {
        
        contentSize.width += view.frame.size.width;
    }
    CGFloat sx = 0;
    spacing.width = (bounds.size.width - contentSize.width)/(views.count+1);
    for (UIView *view in views) {
        CGRect frame = view.frame;
        frame.origin.x = sx + spacing.width;
        view.frame = frame;
        sx += frame.size.width;
    }
}




#pragma mark - Fonts

+ (UIFont *) font:(CGFloat)size;
{
    
//    return [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:size];

    return [self gotham:size];
}

+ (UIFont *) fontBold:(CGFloat)size;
{
    return [self gothamBold:size];
}

+ (UIFont *) gothamBook:(CGFloat)size;
{
    return [UIFont fontWithName:@"GothamHTF-Book" size:size];
}

+ (UIFont *) gothamMedium:(CGFloat)size;
{
    return [UIFont fontWithName:@"GothamHTF-Medium" size:size];
}



+ (UIFont *) gotham:(CGFloat)size;
{
    return [self gothamMedium:size];
}

+ (UIFont *) gothamLight:(CGFloat)size;
{
    return [UIFont fontWithName:@"GothamHTF-Light" size:size];
}


+ (UIFont *) gothamBold:(CGFloat)size;
{
    return [UIFont fontWithName:@"GothamHTF-Bold" size:size];
}

#pragma mark - Button Items
+ (MysticBarButtonItem *) barButtonItem:(ActionBlock) action;
{
    return [MysticBarButtonItem barButtonItem:action];
}
+ (MysticBarButtonItem *) barButtonItemWithTitle:(NSString *)title action:(ActionBlock)action;
{
    return [MysticBarButtonItem barButtonItemWithTitle:title action:action];
}
            
+ (MysticBarButtonItem *) buttonItemWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
{
    return [MysticBarButtonItem buttonItemWithTitle:title target:target sel:action];
}
+ (MysticBarButtonItem *) confirmButtonItem:(MysticBlockSender) action;
{
    return [MysticBarButtonItem confirmButtonItem:action];
}
+ (MysticBarButtonItem *) cancelButtonItem:(ActionBlock) action;
{
    return [MysticBarButtonItem cancelButtonItem:action];
}

+ (MysticBarButtonItem *) barButtonItemWithImage:(UIImage *)image action:(ActionBlock) action;
{
    return [MysticBarButtonItem barButtonItemWithImage:image action:action];
}


+ (MysticBarButtonItem *) backButtonItem:(id)titleOrImg action:(ActionBlock)action;
{
    return [MysticBarButtonItem backButtonItem:titleOrImg action:action];
}

+ (MysticBarButtonItem *) forwardButtonItem:(ActionBlock)action;
{
    return [MysticBarButtonItem forwardButtonItem:action];
}

+ (MysticBarButtonItem *) buttonItemWithTitle:(NSString *)title action:(ActionBlock)action;
{
    return [MysticBarButtonItem buttonItemWithTitle:title action:action];
}

+ (MysticBarButtonItem *) forwardButtonItem:(id)titleOrImg action:(ActionBlock)action;
{
    return [MysticBarButtonItem forwardButtonItem:titleOrImg action:action];
}

+ (MysticBarButtonItem *) backButtonItem:(ActionBlock) action;
{
    return [MysticBarButtonItem backButtonItem:action];
}

+ (MysticBarButtonItem *) backButtonItemWithTarget:(id)target action:(SEL)action;
{
    return [MysticBarButtonItem backButtonItemWithTarget:target action:action];
}

+ (MysticBarButtonItem *) barButtonItemWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
{
    return [MysticBarButtonItem barButtonItemWithTitle:title senderAction:action];
}

+ (MysticBarButtonItem *) buttonItemWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
{
    return [MysticBarButtonItem buttonItemWithTitle:title senderAction:action];
}

+ (MysticBarButtonItem *) buttonItem:(id)titleOrImg senderAction:(MysticBlockSender)action;
{
    return [MysticBarButtonItem buttonItem:titleOrImg senderAction:action];
}

+ (MysticBarButtonItem *) confirmButtonItemWithTarget:(id)target sel:(SEL)action;
{
    return [MysticBarButtonItem confirmButtonItemWithTarget:target sel:action];
}

+ (MysticBarButtonItem *) cancelButtonItemWithTarget:(id)target sel:(SEL)action;
{
    return [MysticBarButtonItem cancelButtonItemWithTarget:target sel:action];
}

+ (MysticBarButtonItem *) clearButtonItemWithImage:(UIImage *)image action:(ActionBlock)action;
{
    return [MysticBarButtonItem clearButtonItemWithImage:image action:action];
}

+ (MysticBarButtonItem *) clearSwitchButtonItemTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage action:(MysticBlockSender)action;
{
    return [MysticBarButtonItem clearSwitchButtonItemTurned:isOn onImage:onImage offImage:offImage action:action];
}

+ (MysticBarButtonItem *) slideOutButtonItem:(ActionBlock)action;
{
    return [MysticBarButtonItem slideOutButtonItem:action];
}

+ (MysticBarButtonItem *) emptyItem;
{
    return [MysticBarButtonItem emptyItem];
}

+ (MysticBarButtonItem *) closeButtonItem:(ActionBlock)action;
{
    return [MysticBarButtonItem closeButtonItem:action];
}

+ (MysticBarButtonItem *) camButtonItem:(ActionBlock)action;
{
    return [MysticBarButtonItem camButtonItem:action];
}

+ (MysticBarButtonItem *) infoButtonItem:(MysticBlockSender)action;
{
    return [MysticBarButtonItem infoButtonItem:action];
}

+ (MysticBarButtonItem *) questionButtonItem:(MysticBlockSender)action;
{
    return [MysticBarButtonItem questionButtonItem:action];
}



#pragma mark - Buttons
+ (void) resizeButton:(MysticButton *)button;
{
    [MysticButton resizeButton:button];
}
+ (MysticButton *) slideOutButton:(ActionBlock)action;
{
    return [MysticButton slideOutButton:action];
}
+ (MysticButton *) camButton:(ActionBlock)action;
{
    return [MysticButton camButton:action];
}
+ (MysticButton *) closeButton:(ActionBlock)action;
{
    return [MysticButton closeButton:action];
}

+ (UIImage *) buttonBgImageNamed:(NSString *)imageName;
{
    return [MysticButton buttonBgImageNamed:imageName];
}
+ (MysticButton *) button:(id)titleOrImg action:(MysticBlockSender)action;
{
    return [MysticButton button:titleOrImg action:action];
}
+ (MysticButton *) buttonWithImage:(UIImage *)image action:(ActionBlock)action;
{
    return [MysticButton buttonWithImage:image action:action];
}
+ (MysticButton *) buttonWithImage:(UIImage *)image senderAction:(MysticBlockSender)action;
{
    return [MysticButton buttonWithImage:image senderAction:action];
}
+ (MysticButton *) clearButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
{
    return [MysticButton clearButtonWithImage:image target:target sel:action];
}
+ (MysticButton *) clearButtonWithImage:(UIImage *)image action:(ActionBlock)action;
{
    return [MysticButton clearButtonWithImage:image action:action];
}
+ (MysticButton *) buttonWithTitle:(NSString *)title action:(MysticBlock)action;
{
    return [MysticButton buttonWithTitle:title action:action];
}
+ (MysticButton *) buttonWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
{
    return [MysticButton buttonWithTitle:title senderAction:action];
}

+ (MysticButton *) backButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
{
    return [MysticButton backButtonWithImage:image target:target sel:action];
}
+ (MysticButton *) backButtonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
{
    return [MysticButton backButtonWithTitle:title target:target sel:action];
}
+ (MysticButton *) forwardButtonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
{
    return [MysticButton forwardButtonWithTitle:title target:target sel:action];
}

+ (MysticButton *) confirmButtonWithTarget:(id)target sel:(SEL)action;
{
    return [MysticButton confirmButtonWithTarget:target sel:action];
}
+ (MysticButton *) cancelButtonWithTarget:(id)target sel:(SEL)action;
{
    return [MysticButton cancelButtonWithTarget:target sel:action];
}
+ (MysticButton *) buttonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
{
    return [MysticButton buttonWithImage:image target:target sel:action];
}
+ (MysticButton *) buttonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
{
    return [MysticButton buttonWithTitle:title target:target sel:action];
}
+ (MysticButton *) moreSettingsButtonWithTarget:(id)target sel:(SEL)action;
{
    return [MysticButton moreSettingsButtonWithTarget:target sel:action];
}
+ (MysticButton *) camButtonWithTarget:(id)target sel:(SEL)action;
{
    return [MysticButton camButtonWithTarget:target sel:action];
}
+ (MysticButton *) slideOutButtonWithTarget:(id)target sel:(SEL)action;
{
    return [MysticButton slideOutButtonWithTarget:target sel:action];
}
+ (MysticButton *) closeButtonWithTarget:(id)target sel:(SEL)action;
{
    return [MysticButton closeButtonWithTarget:target sel:action];
}
+ (MysticButton *) dotsButtonWithTarget:(id)target sel:(SEL)action;
{
        return [MysticButton dotsButtonWithTarget:target sel:action];
    
}
+ (MysticButton *) switchButtonTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage target:(id)target sel:(SEL)action;
{
    return [MysticButton switchButtonTurned:isOn onImage:onImage offImage:offImage target:target sel:action];
}
+ (MysticButton *) clearSwitchButtonTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage target:(id)target sel:(SEL)action;
{
    return [MysticButton clearSwitchButtonTurned:isOn onImage:onImage offImage:offImage target:target sel:action];
}
+ (MysticButton *) clearSwitchButtonTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage action:(MysticBlockSender)action;
{
    return [MysticButton clearSwitchButtonTurned:isOn onImage:onImage offImage:offImage action:action];
}
+ (MysticButton *) confirmButton:(MysticBlockSender) action;
{
    return [MysticButton confirmButton:action];
}
+ (MysticButton *) cancelButton:(ActionBlock) action;
{
    return [MysticButton cancelButton:action];
}

+ (MysticButton *) forwardButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
{
    return [MysticButton forwardButtonWithImage:image target:target sel:action];
}

+ (MysticButton *) downArrowButtonWithTarget:(id)target sel:(SEL)action;
{
    return [MysticButton downArrowButtonWithTarget:target sel:action];
}

@end
