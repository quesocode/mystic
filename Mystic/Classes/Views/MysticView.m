//
//  MysticView.m
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticView.h"
#import "MysticGradient.h"

@interface MysticView ()

@property (nonatomic, copy) MysticBlock fadeBlock;

@end


@implementation MysticView

@synthesize debug=_debug;

- (void) dealloc;
{
    Block_release(_fadeBlock);
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    _stickToPoint = CGPointUnknown;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    _stickToPoint = CGPointUnknown;
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void) commonInit;
{
    _positionOffset = CGPointZero;
    _isShowing = NO;
    _isHiding = NO;
    _stickToPoint = CGPointUnknown;

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

- (BOOL) willBeVisible;
{
    return (self.hidden && !self.isShowing) || self.isHiding ? NO : YES;
}

- (void) setHidden:(BOOL)hidden;
{
    [super setHidden:hidden];
    self.isHiding = NO;
    self.isShowing = NO;
}

- (id) viewWithClass:(Class)viewClass;
{
    NSDictionary *vs = [self viewsWithClass:viewClass];
    NSMutableArray *v = vs[@"views"];
    NSMutableArray *h = vs[@"hidden"];
    if((v && v.count == 1) || h.count==0 || h.count == v.count) return v.lastObject;
    if([h isKindOfClass:[NSArray class]]) [v removeObjectsInArray:[NSArray arrayWithArray:h]];
    return v && v.count ? [v lastObject] : nil;
}
- (NSDictionary *) viewsWithClass:(Class)viewClass;
{
    return [self subViewsWithClass:viewClass inView:self];
}

- (id) subViewsWithClass:(Class)viewClass inView:(UIView *)parentView;
{
    NSMutableArray *subs = [[NSMutableArray array] retain];
//    DLog(@"subview class: %@ in parent: %@", NSStringFromClass(viewClass), [parentView class]);
    NSMutableArray *subsHidden = [[NSMutableArray array] retain];
    BOOL hiddenInView = NO;
    for (UIView *subview in parentView.subviews) {
        hiddenInView = subview.hidden;
        if([subview isKindOfClass:viewClass])
        {
            [subs addObject:subview];
            if(subview.hidden) [subsHidden addObject:subview];
        }
        
        if(subview.subviews.count)
        {
            NSDictionary *vf = [self subViewsWithClass:viewClass inView:subview];
            NSArray *f = vf[@"views"];
            NSArray *hf = vf[@"hidden"];
            if(f && f.count) [subs addObjectsFromArray:f];
            if(subview.hidden && f && f.count) for (UIView *hv in f) if(![subsHidden containsObject:hv]) [subsHidden addObject:hv];
            if(hf.count) for (UIView *hv in hf) if(![subsHidden containsObject:hv]) [subsHidden addObject:hv];
        }
    }
    return @{@"views":[subs autorelease],@"hidden":[subsHidden autorelease]};
}

- (id) reuseableSubViewExcept:(NSArray *)exceptions subviews:(NSArray **)returnSubs matching:(MysticBlockReturnsBOOL)reuseControlBlock;
{
    NSMutableArray *trashViews = [NSMutableArray array];
    id reuseableView = nil;
    int i = 10000;
    for (UIView *subView in self.subviews)
    {
        if([exceptions containsObject:subView]) continue;
        if(reuseControlBlock && !reuseableView && reuseControlBlock(subView))
        {
            reuseableView = subView;
            continue;
        }
        subView.tag = subView.tag ? subView.tag* MysticViewTypeRemove : (i + MysticViewTypeSubView)* MysticViewTypeRemove;
        [trashViews addObject:subView];
        i++;
    }
    
    *returnSubs = trashViews;
    return reuseableView;
}


- (void) removeSubviews:(NSArray *)trashViews;
{
    for (UIView *subView in trashViews)
    {
        [subView removeFromSuperview];
    }
}


- (void) fadeSubviews:(NSArray *)theViews hidden:(BOOL)fadeOut duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay animations:(MysticBlockObject)viewAnimationBlock complete:(MysticBlock)finished;
{
//    DLog(@"fadeOut subviews: %d = %@", theViews.count, MBOOL(fadeOut));
    self.fadeBlock = finished ? finished : nil;
    if(theViews.count)
    {
        [UIView beginAnimations:(fadeOut ? @"mviewfadeoutsubviews" : @"mviewfadeinsubviews")  context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationDelay:delay];
        [UIView setAnimationRepeatCount:0];
        [UIView setAnimationCurve:UIViewAnimationOptionCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(viewFadeSubviewsAnimationDidStop:finished:context:)];
        int i = 9999;
        for (UIView *subView in theViews)
        {
            subView.tag = fadeOut ? i * MysticViewTypeRemove : abs((int)subView.tag);
            subView.alpha = fadeOut ? 0 : subView.alpha;
            if(viewAnimationBlock) viewAnimationBlock(subView);
            i++;
        }
        [UIView commitAnimations];
    }
    else if(self.fadeBlock)
    {
        self.fadeBlock();
        self.fadeBlock = nil;
    }
}

- (void)viewFadeSubviewsAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    BOOL fadedOut = [animationID isEqualToString:@"mviewfadeoutsubviews"];
//    DLog(@"viewFadeSubviewsAnimationDidStop %@ Finished: %@ - fadedOut: %@  %@", animationID, MBOOL(finished), MBOOL(fadedOut), self.subviews);

    if(fadedOut)
    {
        for (UIView *subView in self.subviews)
        {

            if(subView.alpha <= 0 && subView.tag <= MysticViewTypeRemove)
            {
                
                [subView removeFromSuperview];
            }
        }
    }
    
    if(self.fadeBlock)
    {
        self.fadeBlock();
        self.fadeBlock = nil;
    }
}

- (void) setFrame:(CGRect)newFrame;
{
    
    if(!CGPointEqualToPoint(self.stickToPoint, CGPointUnknown))
    {
        if(self.stickToPoint.y != CGPointUnknown.y)
        {
            newFrame.origin.y = self.stickToPoint.y;

        }
        if(self.stickToPoint.x != CGPointUnknown.x)
        {
            newFrame.origin.x = self.stickToPoint.x;
        }
    }
    if(self.debug)
    {
        
        CGRect of = self.frame;
        
        CGRect nf = newFrame;
        
        
        
        int y = 0;
    }
    [super setFrame:newFrame];
}
- (void) setBackgroundGradient:(MysticGradient *)gradient;
{
    if(!gradient)
    {
        [self removeBackgroundGradient];
        return;
    }
    [self setBackgroundGradient:gradient.colors locations:gradient.locations];
}
- (void) setBackgroundGradient:(NSArray *)gradientColors locations:(NSArray *)gradientLocations;
{
    self.backgroundColor = [UIColor clearColor];

//    [self removeBackgroundGradient];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = gradientColors;
    gradientLayer.locations = gradientLocations;
    
    gradientLayer.frame = self.bounds;
    [self.layer insertSublayer:gradientLayer atIndex:0];
    
    
}
- (void) setBackgroundColor:(UIColor *)backgroundColor;
{
    [super setBackgroundColor:backgroundColor];
    if(self.hasBackgroundGradient)
    {
        [self removeBackgroundGradient];
    }
}
- (void) removeBackgroundGradient;
{
    CALayer *l = self.layer.sublayers.count ? [self.layer.sublayers objectAtIndex:0] : nil;
    if(l && [l isKindOfClass:[CAGradientLayer class]])
    {
        [l removeFromSuperlayer];
        [self setNeedsDisplay];
        [self setNeedsLayout];
    }
}

- (BOOL) hasBackgroundGradient;
{
    for (CALayer *l in self.layer.sublayers) {
        if(l && [l isKindOfClass:[CAGradientLayer class]])
        {
            return YES;
        }
    }
    return NO;
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

