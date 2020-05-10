//
//  UIView+Mystic.m
//  Mystic
//
//  Created by Me on 9/26/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import <objc/runtime.h>
#import "UIView+Mystic.h"
#import "MysticRectView.h"
#import "MysticDotView.h"
#import "NSArray+Mystic.h"
#import "MysticUtility.h"

NSString const *blurBackgroundKey = @"blurBackgroundKey";
NSString const *blurVibrancyBackgroundKey = @"blurVibrancyBackgroundKey";
NSString const *blurTintColorKey = @"blurTintColorKey";
NSString const *blurTintColorIntensityKey = @"blurTintColorIntensityKey";
NSString const *blurTintColorLayerKey = @"blurTintColorLayerKey";
NSString const *blurStyleKey = @"blurStyleKey";

@implementation MysticUIView
+ (void)addKeyframeWithRelativeStartTime:(double)s relativeDuration:(double)d animations:(void (^ _Nonnull)(void))animations;
{
//    s=s>0?s*[MysticUser getf:Mk_TIME]:0;d=d>0?d*[MysticUser getf:Mk_TIME]:0;
    [UIView addKeyframeWithRelativeStartTime:s relativeDuration:d animations:animations];
}
+ (void)animateKeyframesWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewKeyframeAnimationOptions)options animations:(void (^ _Nonnull)(void))animations completion:(void (^ _Nullable)(BOOL finished))completion;
{
//    duration=duration>0?duration*[MysticUser getf:Mk_TIME]:0;delay=delay>0?delay*[MysticUser getf:Mk_TIME]:0;
    [UIView animateKeyframesWithDuration:duration delay:delay options:options animations:animations completion:completion];
}
+ (void)animateSpring:(NSTimeInterval)duration animations:(void (^ _Nonnull)(void))animations;
{
    [MysticUIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveLinear animations:animations completion:nil];
}
+ (void)animateQuickSpringWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^ _Nonnull)(void))animations;
{
    [MysticUIView animateWithDuration:duration delay:delay usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:options animations:animations completion:nil];
}
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^ _Nonnull)(void))animations;
{
    [MysticUIView animateWithDuration:duration delay:delay usingSpringWithDamping:dampingRatio initialSpringVelocity:velocity options:options animations:animations completion:nil];
}
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^ _Nonnull)(void))animations completion:(void (^ _Nullable)(BOOL finished))completion;
{
    duration=duration>0?duration*[MysticUser getf:Mk_TIME]:0;delay=delay>0?delay*[MysticUser getf:Mk_TIME]:0;
    [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:dampingRatio initialSpringVelocity:velocity options:options animations:animations completion:completion];
}
+ (void) animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ _Nullable)(BOOL finished))completion;
{
    duration=duration>0?duration*[MysticUser getf:Mk_TIME]:0;delay=delay>0?delay*[MysticUser getf:Mk_TIME]:0;
    [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
}
+ (void) animateWithDuration:(NSTimeInterval)duration animations:(void (^ _Nullable)(void))animations completion:(void (^ _Nullable)(BOOL))completion;
{
    [MysticUIView animateWithDuration:duration delay:0 options:nil animations:animations completion:completion];
}
+ (void) animate:(NSTimeInterval)duration animations:(void (^)(void))animations;
{
    [MysticUIView animateWithDuration:duration delay:0 options:nil animations:animations completion:nil];

}
+ (void) animate:(NSTimeInterval)duration animations:(void (^ _Nonnull)(void))animations completion:(void (^ _Nullable)(BOOL finished))completion;
{
    [MysticUIView animateWithDuration:duration delay:0 options:nil animations:animations completion:completion];

}
+ (void) animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;
{
    [MysticUIView animateWithDuration:duration delay:0 options:nil animations:animations completion:nil];
}
+ (void) animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations;
{
    [MysticUIView animateWithDuration:duration delay:delay options:options animations:animations completion:nil];
}
+ (void) animateWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations;
{
    [MysticUIView animateWithDuration:duration delay:0 options:options animations:animations completion:nil];
}


@end


@implementation UIView (Mystic)

@dynamic frameAndCenter;
+ (void) animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations;
{
    [MysticUIView animateWithDuration:duration delay:delay options:options animations:animations completion:nil];
}
+ (void) animateWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations;
{
    [MysticUIView animateWithDuration:duration delay:0 options:options animations:animations completion:nil];
}
- (BOOL) roundCorners; { return self.layer.cornerRadius == CGRectGetHeight(self.bounds)/2; }
- (void) setRoundCorners:(BOOL)roundCorners;
{
    self.layer.cornerRadius = roundCorners ? CGRectGetHeight(self.bounds)/2 : 0;
}

- (BOOL) ignoreDebug; { return NO; }
- (BOOL) ignoreLayerDebug; { return NO; }

- (CGRect) resizeToSmallestSubview;
{
    return [self resizeToSmallestSubview:nil];
}
- (CGRect) resizeToSmallestSubview:(UIView *)inView;
{
    inView = inView?inView:self;
    UIView *view = inView.smallestSubview;
    if(!view) return self.frame;
    CGRect newFrame = [self convertRect:view.frame fromView:view.superview];
    if (view && !CGSizeEqual(self.frame.size, newFrame.size))  self.frameAndCenter = newFrame;
    return self.frame;
}
- (CGRect) smallestSubviewFrame:(CGRect)minBounds;
{
    UIView *s = [self smallestSubview:minBounds];
    return s ? s.frame : self.frame;
}
- (CGRect) smallestSubviewFrame;
{
    UIView *s = self.smallestSubview;
    return s ? [self convertRect:s.frame fromView:s] : self.frame;
}
- (CGRect) smallestSubviewBounds;
{
    UIView *s = self.smallestSubview;
    return s ? s.frame : self.frame;
}

- (UIView *) smallestSubview;
{
    return [self smallestSubview:CGRectZero];
}
- (UIView *) smallestSubview:(CGRect)minBounds;
{
    if(!self.subviews.count) return nil;
    CGRect f = self.frame;
    CGRect sf = f;
    UIView *sub = nil;
    for (UIView *s in self.subviews) {
        UIView *_s = s;
        UIView *_sub = sub;
        if(_s.subviews.count)
        {
            UIView *_s2 = _s.smallestSubview;
            _s = _s2 ? _s2 : _s;
        }
        sf = [self convertRect:_s.frame fromView:_s];
        sub = !CGRectUnknownOrZero(f) && !CGRectUnknownOrZero(sf) ? CGRectLess(sf, f) && (CGRectIsZero(minBounds) || CGRectGreater(sf, minBounds)) ? _s : sub : sub;
        sf = sub ? [self convertRect:sub.frame fromView:sub] : f;
        sub = sub && CGRectLess(sf, f) ? sub : _sub;
        f = sub ? CGRectMin(sf, f) : _s.frame;
    }
    return sub;
}
- (CGRect) smallestLayerFrame;
{
    CALayer *l = self.smallestLayer;
    return l ? l.frame : self.frame;
}
- (CALayer *) smallestLayer;
{
    return [self smallestLayer:CGRectZero];
}
- (CALayer *) smallestLayer:(CGRect)minBounds;
{
    NSArray *layers = [self allSubLayers];
    CGRect smallest = CGRectMake(0, 0, CGFLOAT_MAX, CGFLOAT_MAX);
    CALayer *layer = nil;
    for (CALayer *l in layers) {
        if(!layer) { layer = l; continue; }
        if(CGSizeLess(l.frame.size, layer.frame.size)) layer = l;
    }
    return layer ? layer : self.layer;
}
- (CGRect) biggestLayerFrame;
{
    CALayer *l = self.biggestLayer;
    return l ? l.frame : self.frame;
}
- (CALayer *) biggestLayer;
{
    return [self biggestLayer:CGRectZero];
}
- (CALayer *) biggestLayer:(CGRect)minBounds;
{
    NSArray *layers = [self allSubLayers];
    CGRect smallest = CGRectZero;
    CALayer *layer = nil;
    for (CALayer *l in layers) {
        if(!layer) { layer = l; continue; }
        if(CGSizeGreater(l.frame.size, layer.frame.size)) layer = l;
    }
    return layer ? layer : self.layer;
}
- (CALayer *) biggestLayerView:(CGRect)minBounds;
{
    NSArray *layers = [self allSubLayers];
    CGRect smallest = CGRectZero;
    CALayer *layer = nil;
    for (CALayer *l in layers) {
        if(!layer) { layer = l; continue; }
        if(CGSizeGreater(l.frame.size, layer.frame.size)) layer = l;
    }
    return layer ? layer : self.layer;
}
- (NSArray *) allSubLayers;
{
    return [self allSubLayers:nil];
}
- (NSMutableArray *) allSubLayers:(NSMutableArray *)layers;
{
    layers = layers ? layers : [NSMutableArray array];
    if(![layers containsObject:self.layer]) [layers addObject:self.layer];
    if(self.layer.mask && ![layers containsObject:self.layer.mask])
    {
        [layers addObject:self.layer.mask];
    }
    if(self.layer.sublayers.count>0)
    {
        for (CALayer *subLayer in self.layer.sublayers) {
            if(![layers containsObject:subLayer]) [layers addObject:subLayer];
            if(subLayer.mask && ![layers containsObject:subLayer.mask]) [layers addObject:subLayer.mask];
        }
    }
    
    for (UIView *s in self.subviews) {
        layers = [s allSubLayers:layers];
    }
    return layers;
}
- (CGRect) resizeToBiggestLayer;
{
    CALayer *view = self.biggestLayer;
    if(!view) return self.frame;
    CGRect newFrame = [view convertRect:view.frame fromLayer:view.superlayer];
    if (view && !CGSizeEqual(self.layer.frame.size, newFrame.size))  { self.frameAndCenter = newFrame; return newFrame; }
    return self.layer.frame;
}
- (CGRect) resizeToSmallestLayer;
{
    CALayer *view = self.smallestLayer;
    if(!view) return self.frame;
    CGRect newFrame = [view convertRect:view.frame fromLayer:view.superlayer];
    
    if (view && !CGSizeEqual(self.layer.frame.size, newFrame.size))  { self.frameAndCenter = newFrame; return newFrame; }
    return self.layer.frame;
}
- (CGRect) resizeToBiggestSubview;
{
    return [self resizeToBiggestSubview:nil];
}
- (CGRect) resizeToBiggestSubview:(UIView *)inView;
{
    inView = inView ? inView:self;
    UIView *view = inView.biggestSubview;
    if(!view) return self.frame;
    CGRect newFrame = [self convertRect:view.frame fromView:view.superview];
    if (view && !CGSizeEqual(self.frame.size, newFrame.size))  self.frameAndCenter = newFrame;
    return self.frame;
}
- (CGRect) biggestSubviewFrame:(CGRect)minBounds;
{
    UIView *s = [self biggestSubview:minBounds];
    return s ? s.frame : self.frame;
}
- (CGRect) biggestSubviewBounds;
{
    UIView *s = self.biggestSubview;
    return s ? s.frame : self.frame;
}
- (CGRect) biggestSubviewFrame;
{
    UIView *s = self.biggestSubview;
    return s ? [self convertRect:s.frame fromView:s] : self.frame;
}
- (UIView *) biggestSubview;
{
    return [self biggestSubview:CGRectZero];
}
- (UIView *) biggestSubview:(CGRect)maxBounds;
{
    if(!self.subviews.count) return nil;
    CGRect f = CGRectZero;
    CGRect sf = f;
    UIView *sub = nil;
    for (UIView *sv in self.subviews) {
        UIView *_s = sv;
        UIView *_sub = sub;
        if(sv.subviews.count)
        {
            UIView *_s2 = _s.biggestSubview;
            _s = _s2 ? _s2 : _s;
        }
        sf = [self convertRect:_s.frame fromView:_s];
        sub = CGRectUnknownOrZero(f) ? _s : CGRectUnknownOrZero(sf) ? CGRectGreater(sf, f) && (CGRectIsZero(maxBounds) || CGRectLess(sf, maxBounds)) ? _s : sub : sub;
        sf = sub ? [self convertRect:sub.frame fromView:sub] : f;
        sub = sub && CGRectGreater(sf, f) ? sub : _sub;
        f = sub ? CGRectMax(sf, f) : _s.frame;
    }
    return sub;
}


- (BOOL) containedInClass:(Class)viewClass;
{
    id view = [self containerOfClass:viewClass];
    return view && ![view isEqual:self];
}
- (UIView *) superviewOfClass:(Class)viewClass;
{
    id superv = [self containerOfClass:viewClass];
    return superv ? superv : self.superview;
}
- (UIView *) containerOfClass:(Class)viewClass;
{
    if([self isKindOfClass:viewClass]) return self;
    if(!self.superview) return nil;
    if([self.superview isKindOfClass:viewClass] || !viewClass) return self.superview;
    return [self.superview containerOfClass:viewClass];
}
- (UIImage *)renderedImage;
{
    CGRect rect = self.frame;
    UIView* viewToRender = self.superview;
    while (!viewToRender.opaque) { if (viewToRender.superview) viewToRender = viewToRender.superview; else  break; }
    CGRect renderRect = [viewToRender convertRect:rect fromView:self];
    UIGraphicsBeginImageContextWithOptions(rect.size, self.opaque, 0);
    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformMake( 1, 0, 0, -1, 0, renderRect.size.height ));
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -CGRectGetMinX(renderRect), CGRectGetMaxY(renderRect));
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0f, -1.0f);
    [viewToRender.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *returnImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImg;
}

- (void) setFrameAndCenter:(CGRect)frame;
{
    CGPoint c = self.center;
    self.frame = frame;
    self.center = c;
}



@dynamic blurBackground;
@dynamic blurTintColor;
@dynamic blurTintColorIntensity;
@dynamic isBlurred;
@dynamic blurStyle;

#pragma mark - category methods
-(void)enableBlur:(BOOL) enable
{

    if(enable) {
        

        if(IOS_MAJOR_VERSION>=8) {
            UIVisualEffectView* view = (UIVisualEffectView*)self.blurBackground;
            UIVisualEffectView* vibrancyView = self.blurVibrancyBackground;
            if(!view || !vibrancyView) {
                [self blurBuildBlurAndVibrancyViews];
            }
            
        } else {
            UIToolbar* view = (UIToolbar*)self.blurBackground;
            if(!view) {
                // use UIToolbar
                view = [[UIToolbar alloc] initWithFrame:self.bounds];
                objc_setAssociatedObject(self, &blurBackgroundKey, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            [view setFrame:self.bounds];
            view.clipsToBounds = YES;
            view.translucent = YES;
            
            // add the toolbar layer as sublayer
            [self.layer insertSublayer:view.layer atIndex:0];
        }
        
        
        //        view.barTintColor = [self.blurTintColor colorWithAlphaComponent:0.4f];
    } else {
        if(IOS_MAJOR_VERSION>=8) {
            if(self.blurBackground) {
                [self.blurBackground removeFromSuperview];
                objc_setAssociatedObject(self, &blurBackgroundKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        } else {
            if(self.blurBackground) {
                [self.blurBackground.layer removeFromSuperlayer];
            }
        }
    }
    
}

-(void) blurBuildBlurAndVibrancyViews NS_AVAILABLE_IOS(8_0)
{
    UIBlurEffectStyle style = UIBlurEffectStyleDark;
    
    if(self.blurStyle == UIViewBlurExtraLightStyle) {
        style = UIBlurEffectStyleExtraLight;
    } else if(self.blurStyle == UIViewBlurLightStyle) {
        style = UIBlurEffectStyleLight;
    }
    // use UIVisualEffectView
    UIVisualEffectView* view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    view.frame = self.bounds;
    [self addSubview:view];
    objc_setAssociatedObject(self, &blurBackgroundKey, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // save subviews of existing vibrancy view
    NSArray* subviews = self.blurVibrancyBackground.contentView.subviews;
    
    // create vibrancy view
    UIVisualEffectView* vibrancyView = [[UIVisualEffectView alloc]initWithEffect:[UIVibrancyEffect effectForBlurEffect:(UIBlurEffect*)view.effect]];
    vibrancyView.frame = self.bounds;
    [view.contentView addSubview:vibrancyView];
    view.contentView.backgroundColor = [self.blurTintColor colorWithAlphaComponent:self.blurTintColorIntensity];
    
    // add back subviews to vibrancy view
    if(subviews) {
        for (UIView* v in subviews) {
            [vibrancyView.contentView addSubview:v];
        }
    }
    objc_setAssociatedObject(self, &blurVibrancyBackgroundKey, vibrancyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - getters/setters
-(UIColor*) blurTintColor
{
    UIColor* color = objc_getAssociatedObject(self, &blurTintColorKey);
    if(!color) {
        color = [UIColor clearColor];
        objc_setAssociatedObject(self, &blurTintColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return color;
}

-(void) setBlurTintColor:(UIColor *)blurTintColor
{
    objc_setAssociatedObject(self, &blurTintColorKey, blurTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if(IOS_MAJOR_VERSION>=8) {
        ((UIVisualEffectView*)self.blurBackground).contentView.backgroundColor = [blurTintColor colorWithAlphaComponent:self.blurTintColorIntensity];
    } else {
        if(self.blurBackground) {
            UIToolbar *toolbar = ((UIToolbar*)self.blurBackground);
            CALayer *colorLayer = objc_getAssociatedObject(self, &blurTintColorLayerKey);
            if(colorLayer==nil) {
                colorLayer = [CALayer layer];
            } else {
                [colorLayer removeFromSuperlayer];
            }
            
            if(self.blurStyle == UIViewBlurDarkStyle) {
                toolbar.barStyle = UIBarStyleBlackTranslucent;
            } else {
                toolbar.barStyle = UIBarStyleDefault;
            }
            colorLayer.frame = toolbar.frame;
            colorLayer.opacity = (float)(0.5*self.blurTintColorIntensity);
            colorLayer.opaque = NO;
            [toolbar.layer insertSublayer:colorLayer atIndex:1];
            colorLayer.backgroundColor = blurTintColor.CGColor;
            
            objc_setAssociatedObject(self, &blurTintColorLayerKey, colorLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
}

-(UIView*)blurBackground
{
    return objc_getAssociatedObject(self, &blurBackgroundKey);
}
#if defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0

-(UIVisualEffectView*) blurVibrancyBackground NS_AVAILABLE_IOS(8_0)
{
    return objc_getAssociatedObject(self, &blurVibrancyBackgroundKey);
}
#endif
-(UIViewBlurStyle) blurStyle
{
    NSNumber* style = objc_getAssociatedObject(self, &blurStyleKey);
    if(!style) {
        style = @0;
    }
    return (UIViewBlurStyle)style.integerValue;
}

-(void)setBlurStyle:(UIViewBlurStyle)viewBlurStyle
{
    NSNumber *style = [NSNumber numberWithInteger:viewBlurStyle];
    objc_setAssociatedObject(self, &blurStyleKey, style, OBJC_ASSOCIATION_RETAIN);
    
    if(IOS_MAJOR_VERSION>=8) {
        if(self.blurBackground) {
            [self.blurBackground removeFromSuperview];
            [self blurBuildBlurAndVibrancyViews];
        }
    } else {
        if(self.blurBackground) {
            if(viewBlurStyle == UIViewBlurDarkStyle) {
                ((UIToolbar*)self.blurBackground).barStyle = UIBarStyleBlackTranslucent;
            } else {
                ((UIToolbar*)self.blurBackground).barStyle = UIBarStyleDefault;
            }
        }
    }
}

-(void)setBlurTintColorIntensity:(double)blurTintColorIntensity
{
    NSNumber *intensity = [NSNumber numberWithDouble:blurTintColorIntensity];
    objc_setAssociatedObject(self, &blurTintColorIntensityKey, intensity, OBJC_ASSOCIATION_RETAIN);
    
    if(IOS_MAJOR_VERSION<8) {
        if(self.blurBackground) {
            CALayer *colorLayer = objc_getAssociatedObject(self, &blurTintColorLayerKey);
            if(colorLayer) {
                colorLayer.opacity = 0.5f*intensity.floatValue;
            }
        }
    }
}

-(double)blurTintColorIntensity
{
    NSNumber *intensity = objc_getAssociatedObject(self, &blurTintColorIntensityKey);
    if(!intensity) {
        intensity = @0.3;
    }
    return intensity.doubleValue;
}

- (id) findFirstResponder;
{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}

- (NSArray *) allSiblings;
{
    if(!self.superview) return nil;
    
    NSMutableArray *a = [NSMutableArray array];
    for (UIView *v in self.superview.subviews) {
        if(![v isEqual:self]) [a addObject:v];
    }
    return a;
    
}
- (NSArray *) siblings;
{
    if(!self.superview) return nil;
    
    NSMutableArray *a = [NSMutableArray array];
    for (UIView *v in self.superview.subviews) {
        if(![v isEqual:self] && [v isKindOfClass:[self class]]) [a addObject:v];
    }
    return a;
    
}
- (NSArray *) siblingsWithFrame;
{
    if(!self.superview) return nil;
    
    NSMutableArray *a = [NSMutableArray array];
    for (UIView *v in self.superview.subviews) {
        if(![v isEqual:self] && [v isKindOfClass:[self class]] && CGRectEqual(v.frame, self.frame)) [a addObject:v];
    }
    return a;
}
- (NSArray *) siblingsWithSize;
{
    if(!self.superview) return nil;
    
    NSMutableArray *a = [NSMutableArray array];
    for (UIView *v in self.superview.subviews) {
        if(![v isEqual:self] && [v isKindOfClass:[self class]] && CGRectSizeEqual(v.frame, self.frame)) [a addObject:v];
    }
    return a;
}
- (void) setSiblingsToSelected:(BOOL)selected;
{
    for (UIControl *sibling in self.siblings) {
        if([sibling respondsToSelector:@selector(setSelected:)]) sibling.selected = selected;
    }
}
- (id) selectedSibling;
{
    for (UIControl *sibling in self.siblings) {
        if([sibling respondsToSelector:@selector(setSelected:)] && sibling.selected) return sibling;
    }
    return nil;
}
- (id) addDot:(CGPoint)point size:(CGFloat)size color:(MysticColorType)colorType context:(UIView *)context;
{
    point = !context ? point : [self convertPoint:point fromView:context];
    id d = [MysticDotView dot:point color:colorType size:size];
    [self addSubview:d];
    return d;
}
- (NSArray *) addRects;
{
    return [self addRects:nil context:self];
}
- (NSArray *) addRects:(id)border;
{
    return [self addRects:border context:self];
}
- (NSArray *) addAllNewRects;
{
    [self removeAllRects];
    return [self addAllRects];
}
- (NSArray *) addAllRects;
{
//    [self removeRects];
    return [self addAllRects:nil context:self];
}
- (NSArray *) addAllRects:(id)border;
{
    if([border isKindOfClass:[UIView class]])
    {
        return [self addAllRects:nil context:nil container:border];
    }
    return [self addAllRects:border context:self];
}
- (NSArray *) addAllRects:(id)border context:(UIView *)context;
{
    return [self addAllRects:border context:context container:self];
}
- (NSArray *) addAllRects:(id)border context:(UIView *)context container:(UIView *)container;
{
    return [self addAllRects:border context:context container:container depth:0];
}
- (NSArray *) addAllRects:(id)border context:(UIView *)context container:(UIView *)container depth:(int)depth;
{
    if([border isKindOfClass:[NSNumber class]] && [(NSValue *)border isBoolean]) border = nil;
    for (UIView *sub in self.subviews) {
        if(![sub isKindOfClass:[MysticRectView class]]) continue;
        sub.alpha = 0.65;
    }
    container = container ? container : self;
    NSMutableArray *rects = [NSMutableArray array];
    for (UIView *sub in self.subviews)
    {
        if([sub isKindOfClass:[MysticRectView class]] || [sub isKindOfClass:[MysticDotView class]] || sub.hidden) continue;
        MysticRectView *rect = [container addRectForView:sub border:border color:[UIColor randomColor] context:nil];
        rect.depth = depth+1;
        rect.fromView = sub;
        [rects addObject:rect];
        if(![sub isKindOfClass:[UIControl class]])
        {
            [rects addObjectsFromArray:[sub addAllRects:border context:nil container:container depth:depth++]];
        }
    }
    return rects;
}
- (NSArray *) addRects:(id)border context:(UIView *)context;
{
//    [self removeRects];
    NSMutableArray *rects = [NSMutableArray array];
    for (UIView *sub in self.subviews)
    {
        [rects addObject:[self addRectForView:sub border:border color:[UIColor randomColor] context:context ? context : self]];
    }
    return rects;
}
- (void) removeRects:(id)color;
{
    for (MysticRectView *sub in self.subviews)
    {
        if([sub isKindOfClass:[MysticRectView class]])
        {
            if([sub hasColor:color]) [sub removeFromSuperview];
        }
    }
    
}
- (id) addRectForView:(UIView *)view border:(id)borderWidth color:(id)color;
{
    MysticRectView *r = [self addRect:view.frame border:borderWidth color:color context:view.superview];
    r.viewInfo = [NSString format:@"%@", view.class];
    return r;
}
- (id) addRectForView:(UIView *)view border:(id)borderWidth color:(id)color context:(UIView *)context;
{
    MysticRectView *r =  [self addRect:view.frame border:borderWidth color:color context:context ? context : view.superview];
    r.viewInfo = [NSString format:@"%@", view.class];
    return r;
}
- (id) addRect:(CGRect)frame border:(id)borderWidth color:(id)color;
{
    return [self addRect:frame border:borderWidth color:color context:nil];
}
- (id) addRect:(CGRect)frame border:(id)borderWidth color:(id)color context:(UIView *)context;
{
    frame = !context ? frame : [self convertRect:frame fromView:context];
    id v = [MysticRectView viewWithFrame:frame border:borderWidth color:color];
    [self addSubview:v];
    return v;
}
- (void) removeDebugViews;
{
    [self removeRects];
    [self removeDots];
}
- (void) removeAllRects;
{
    [self removeRects];
    for (UIView *sub in self.subviews) [sub removeAllRects];

}
- (void) removeAllDebugViews;
{
    [self removeDebugViews];
    for (UIView *sub in self.subviews) [sub removeAllDebugViews];
}
- (void) removeDots;
{
    for (UIView *v in self.subviews) {
        if([v isKindOfClass:[MysticDotView class]]) [v removeFromSuperview];
    }
}
- (void) removeRects;
{
    for (UIView *v in self.subviews) {
        if([v isKindOfClass:[MysticRectView class]]) [v removeFromSuperview];
    }
}
- (NSInteger) numberOfSubviewsWithClass:(Class)viewClass;
{
    NSInteger i = 0;
    for (UIView *v in self.subviews) {
        if([v isKindOfClass:viewClass]) i ++;
    }
    return i;
}

- (NSArray * _Nullable) subviewsOfClass:(Class _Nonnull)viewClass returnViews:(NSMutableArray * _Nullable)subs;
{
    NSMutableArray *ss = subs ? subs : [NSMutableArray array];
    for (UIView *sub in self.subviews) {
        if([sub isKindOfClass:viewClass]) [ss addObject:sub];
        [sub subviewsOfClass:viewClass returnViews:ss];
    }
    return ss;
}
- (id _Nullable) subviewOfClass:(Class _Nonnull)viewClass;
{
    if([self isKindOfClass:viewClass]) return self;
    for (UIView *sub in self.subviews) {
        UIView *found = [sub subviewOfClass:viewClass];
        if(found) return found;
    }
    return nil;
}
- (UIView *) topSuperview;
{
    if(self.superview) return self.superview.topSuperview;
    return self;
}
- (UIView *) containerOfSuperview:(UIView *)topView;
{
    if(!topView) return nil;
    if(self.superview && [self.superview isKindOfClass:topView.class]) return self;
    return !self.superview ? nil : [self.superview containerOfSuperview:topView];
}
- (NSArray *) subviewsSorted;
{
    return [[self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *  _Nonnull obj1, UIView *  _Nonnull obj2) {
        float z = obj1.frame.origin.x + obj1.frame.origin.y;
        float z2 = obj1.frame.origin.x + obj1.frame.origin.y;

        if (z > z2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (z < z2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }] reversedArray];
}
- (NSArray *) subviewsSortedByX;
{
    return [[self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *  _Nonnull obj1, UIView *  _Nonnull obj2) {
        if (obj1.frame.origin.x > obj2.frame.origin.x) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (obj1.frame.origin.x < obj2.frame.origin.x) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }] reversedArray];
}
- (NSArray *) subviewsSortedByY;
{
    return [[self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *  _Nonnull obj1, UIView *  _Nonnull obj2) {
        if (obj1.frame.origin.y > obj2.frame.origin.y) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (obj1.frame.origin.y < obj2.frame.origin.y) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }] reversedArray];
}
- (CGRect) originalFrame; { return self.frame; }
- (int) subviewsDepth;
{
    return VTotalDepth(self, -1, 0);
}
- (NSInteger) numberOfSubviewsOfClass:(Class _Nonnull) subviewClass;
{
    NSInteger i = 0;
    for (id v in self.subviews) if([v isKindOfClass:subviewClass]) i++;
    return i;
}
- (NSArray *) subviewsOfClass:(Class)viewClass;
{
    return [self subviewsOfClass:viewClass inView:self andHidden:NO recursive:NO];
}

- (id) subviewsOfClass:(Class)viewClass inView:(UIView *)parentView andHidden:(BOOL)showHidden recursive:(BOOL)deep;
{
    NSMutableArray *subs = [NSMutableArray array];
    //    DLog(@"subview class: %@ in parent: %@", NSStringFromClass(viewClass), [parentView class]);
    NSMutableArray *subsHidden = [NSMutableArray array];
    BOOL hiddenInView = NO;
    for (UIView *subview in parentView.subviews) {
        hiddenInView = subview.hidden;
        if([subview isKindOfClass:viewClass])
        {
            [subs addObject:subview];
            if(showHidden && subview.hidden) [subsHidden addObject:subview];
        }
        
        if(deep && subview.subviews.count)
        {
            NSDictionary *vf = [self subviewsOfClass:viewClass inView:subview andHidden:showHidden recursive:YES];
            NSArray *f = showHidden ? vf[@"views"] : (id)vf;
            NSArray *hf = showHidden ? vf[@"hidden"] : nil;
            if(f && f.count) [subs addObjectsFromArray:f];
            if(showHidden && subview.hidden && f && f.count) for (UIView *hv in f) if(![subsHidden containsObject:hv]) [subsHidden addObject:hv];
            if(showHidden && hf.count) for (UIView *hv in hf) if(![subsHidden containsObject:hv]) [subsHidden addObject:hv];
        }
    }
    return showHidden ? @{@"views":subs,@"hidden":subsHidden} : subs;
}

- (void) centerViews:(NSArray * _Nullable)views;
{
    [self position:MysticPositionCenter views:views];
}
- (void) position:(MysticPosition)position views:(NSArray *)views;
{
    views = views ? views : self.subviews;
    if(!views || views.count<1) return;
    CGRect r = CGRectMake(99999,0,0,0);
    switch (position) {
        case MysticPositionCenter:
        {
            for (UIView *v in views) {
                r.origin.x = MIN(r.origin.x,v.frame.origin.x);
                r.size.width = MAX(r.size.width,CGRectGetMaxX(v.frame));
            }
            r.size.width -= r.origin.x;
            CGFloat ox = self.frame.size.width/2 - r.size.width/2;
            for (UIView *v in views) {
                v.frame = CGRectX(v.frame,ox+(v.frame.origin.x - r.origin.x));
            }
            break;
        }
        default: break;
    }
}
- (id) deepCopy:(UIView *)view;
{
    self.hidden=view.hidden;
    self.alpha=view.alpha;
    self.backgroundColor=view.backgroundColor;
    self.opaque=view.opaque;
    self.bounds = view.bounds;
    self.transform = view.transform;
    self.center = view.center;
    self.layer.cornerRadius=view.layer.cornerRadius;
    self.layer.shadowColor=view.layer.shadowColor;
    self.layer.borderColor=view.layer.borderColor;
    self.layer.borderWidth=view.layer.borderWidth;
    self.layer.shadowOffset=view.layer.shadowOffset;
    self.layer.shadowOpacity=view.layer.shadowOpacity;
    self.layer.shadowRadius=view.layer.shadowRadius;
    self.layer.opacity = view.layer.opacity;
    self.layer.opaque=view.layer.opaque;
    if(view.layer.shadowPath) self.layer.shadowPath=[[UIBezierPath bezierPathWithCGPath:view.layer.shadowPath] safeCopy].CGPath;
    if([self respondsToSelector:@selector(deepCopyOf:)]) [self performSelector:@selector(deepCopyOf:) withObject:view];
    for (int i = 0; i<self.subviews.count; i++) {
        [[self.subviews objectAtIndex:i] deepCopy:[view.subviews objectAtIndex:i]];
    }
    return self;
    
}
- (void) fadeIn;
{
    [self fadeIn:0.35 completion:nil];
}
- (void) fadeOut;
{
    [self fadeOut:0.35 completion:nil];
}
- (void) fadeIn:(NSTimeInterval)duration;
{
    [self fadeIn:duration completion:nil];
}
- (void) fadeOut:(NSTimeInterval)duration;
{
    [self fadeOut:duration completion:nil];
}
- (void) fadeIn:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
{
    [self fadeIn:duration delay:delay completion:nil];

}
- (void) fadeOut:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
{
    [self fadeOut:duration delay:delay completion:nil];

}
- (void) fadeIn:(NSTimeInterval)duration completion:(MysticBlockAnimationCompleteBOOL)complete;
{
    [self fadeIn:duration delay:0 completion:complete];

}
- (void) fadeOut:(NSTimeInterval)duration completion:(MysticBlockAnimationCompleteBOOL)complete;
{
    [self fadeOut:duration delay:0 completion:complete];
}

- (void) fadeIn:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(MysticBlockAnimationCompleteBOOL)complete;
{
    [MysticUIView animate:duration animations:^{
        self.alpha = 1.0;
    } completion:complete];
}

- (void) fadeOut:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(MysticBlockAnimationCompleteBOOL)complete;
{
    [MysticUIView animate:duration animations:^{
        self.alpha = 0.0;
    } completion:complete];
}

-(NSUInteger)getSubviewIndex
{
    return [self.superview.subviews indexOfObject:self];
}

-(void)bringToFront
{
    [self.superview bringSubviewToFront:self];
}

-(void)sendToBack
{
    [self.superview sendSubviewToBack:self];
}

-(void)bringOneLevelUp
{
    int currentIndex = [self getSubviewIndex];
    [self.superview exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:currentIndex+1];
}

-(void)sendOneLevelDown
{
    int currentIndex = [self getSubviewIndex];
    [self.superview exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:currentIndex-1];
}

-(BOOL)isInFront
{
    return ([self.superview.subviews lastObject]==self);
}

-(BOOL)isAtBack
{
    return ([self.superview.subviews objectAtIndex:0]==self);
}

-(void)swapDepthsWithView:(UIView*)swapView
{
    [self.superview exchangeSubviewAtIndex:[self getSubviewIndex] withSubviewAtIndex:[swapView getSubviewIndex]];
}
-(void)sendAbove:(UIView* _Nonnull)swapView;
{
    NSUInteger i = [self getSubviewIndex];
    NSUInteger i2 = [swapView getSubviewIndex];
    if(i == NSNotFound || i2 == NSNotFound || i > i2) return;
    [self swapDepthsWithView:swapView];
}
-(void)sendBelow:(UIView* _Nonnull)swapView;
{
    NSUInteger i = [self getSubviewIndex];
    NSUInteger i2 = [swapView getSubviewIndex];
    if(i == NSNotFound || i2 == NSNotFound || i < i2) return;
    [self swapDepthsWithView:swapView];
}
@end
