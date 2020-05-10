//
//  UIView+Mystic.h
//  Mystic
//
//  Created by Me on 9/26/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"

#ifndef IOS_MAJOR_VERSION
#define IOS_MAJOR_VERSION (((NSString*)[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."][0]).integerValue)
#endif

#ifndef IOS_MINOR_VERSION
#define IOS_MINOR_VERSION (((NSString*)[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."][1]).integerValue)
#endif

@class MysticRectView;

typedef NS_ENUM(NSInteger, UIViewBlurStyle) {
    UIViewBlurExtraLightStyle,
    UIViewBlurLightStyle,
    UIViewBlurDarkStyle
};

@interface UIView (Mystic)

- (UIImage * _Nullable)renderedImage;


/* The UIToolbar/UIVisualEffectView(ios8) that has been put on the current view, use it to do your bidding */
@property (strong,nonatomic,readonly) UIView* _Nullable blurBackground;

/* The UIVisualEffectView that should be used for vibrancy element, add subviews to .contentView */

@property (strong,nonatomic,readonly) UIVisualEffectView* _Nullable blurVibrancyBackground NS_AVAILABLE_IOS(8_0);

@property (nonatomic,readonly) NSArray * _Nullable allSubLayers, * _Nullable siblings,* _Nullable allSiblings, * _Nullable subviewsSorted, * _Nullable subviewsSortedByY, * _Nullable siblingsWithFrame, * _Nullable siblingsWithSize, * _Nullable subviewsSortedByX;
@property (nonatomic,readonly) int subviewsDepth;
@property (nonatomic,readonly) UIView * _Nullable smallestSubview, * _Nullable biggestSubview;
@property (nonatomic,readonly) UIView *_Nullable topSuperview;
@property (nonatomic,readonly) CALayer * _Nullable smallestLayer, * _Nullable biggestLayer;
@property (nonatomic,readonly) BOOL ignoreLayerDebug, ignoreDebug;
@property (strong,nonatomic) UIColor* _Nullable  blurTintColor;
@property (assign,nonatomic) double blurTintColorIntensity;
@property (nonatomic,readonly) CGRect originalFrame, smallestSubviewFrame, biggestSubviewFrame, smallestSubviewBounds, biggestSubviewBounds, biggestLayerFrame, smallestLayerFrame;
@property (readonly,nonatomic) BOOL isBlurred;
@property (assign,nonatomic) CGRect frameAndCenter;
@property (assign,nonatomic) UIViewBlurStyle blurStyle;
@property (assign,nonatomic) BOOL roundCorners;
- (NSInteger) numberOfSubviewsOfClass:(Class _Nonnull) subviewClass;
- (UIView * _Nullable) containerOfSuperview:(UIView * _Nullable)topView;
- (id _Nullable) subviewOfClass:(Class _Nonnull)viewClass;
- (NSArray * _Nullable) subviewsOfClass:(Class _Nonnull)viewClass returnViews:(NSMutableArray * _Nullable)subs;

- (CGRect) resizeToSmallestSubview;
- (UIView * _Nullable ) smallestSubview:(CGRect)minBounds;
- (CGRect) smallestSubviewFrame:(CGRect)minBounds;
- (CGRect) resizeToSmallestLayer;
- (CGRect) resizeToBiggestLayer;
- (CGRect) resizeToBiggestSubview:(UIView * _Nullable)inView;
- (CGRect) resizeToSmallestSubview:(UIView * _Nullable)inView;

- (CGRect) resizeToBiggestSubview;
- (UIView * _Nullable ) biggestSubview:(CGRect)maxBounds;
- (CGRect) biggestSubviewFrame:(CGRect)maxBounds;

- (NSInteger) numberOfSubviewsWithClass:(Class _Nullable )viewClass;
- (UIView * _Nullable) containerOfClass:(Class _Nullable)viewClass;
- (BOOL) containedInClass:(Class _Nullable)viewClass;
- (UIView *_Nullable) superviewOfClass:(Class _Nullable)viewClass;
-(void)enableBlur:(BOOL) enable;
- (id _Nullable) findFirstResponder;
- (void) setSiblingsToSelected:(BOOL)selected;
- (id _Nullable) selectedSibling;
- (MysticRectView * _Nullable) addRect:(CGRect)frame border:(id _Nullable)borderWidth color:(id _Nullable)color;
- (MysticRectView * _Nullable) addRect:(CGRect)frame border:(id _Nullable)borderWidth color:(id _Nullable)color context:(UIView * _Nullable)context;
- (MysticRectView * _Nullable) addRectForView:(UIView *_Nullable)view border:(id _Nullable)borderWidth color:(id _Nullable)color;
- (id _Nullable) addDot:(CGPoint)point size:(CGFloat)size color:(MysticColorType)colorType context:(UIView * _Nullable)context;
- (void) removeDots;
- (void) removeRects;
- (void) removeRects:(id _Nullable)color;
- (void) removeDebugViews;
- (void) removeAllDebugViews;
- (void) removeAllRects;
- (NSArray *_Nullable) addAllNewRects;
- (void) centerViews:(NSArray * _Nullable)views;
- (void) position:(MysticPosition)position views:(NSArray * _Nullable)views;

- (id _Nullable) deepCopy:(UIView * _Nullable)view;
-(NSUInteger)getSubviewIndex;

-(void)bringToFront;
-(void)sendToBack;

-(void)bringOneLevelUp;
-(void)sendOneLevelDown;

-(BOOL)isInFront;
-(BOOL)isAtBack;

-(void)swapDepthsWithView:(UIView* _Nonnull)swapView;
-(void)sendAbove:(UIView* _Nonnull)swapView;
-(void)sendBelow:(UIView* _Nonnull)swapView;

- (void) fadeIn;
- (void) fadeOut;
- (void) fadeIn:(NSTimeInterval)duration;
- (void) fadeOut:(NSTimeInterval)duration;
- (void) fadeIn:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void) fadeOut:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void) fadeIn:(NSTimeInterval)duration completion:(void (^ _Nullable)(BOOL finished))completion;
- (void) fadeOut:(NSTimeInterval)duration completion:(void (^ _Nullable)(BOOL finished))completion;

- (void) fadeIn:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^ _Nullable)(BOOL finished))completion;
- (void) fadeOut:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^ _Nullable)(BOOL finished))completion;




- (NSArray *_Nullable) addAllRects;
- (NSArray *_Nullable) addAllRects:(id _Nullable)border;
- (NSArray *_Nullable) addAllRects:(id _Nullable)border context:(UIView *_Nullable)context;
- (NSArray *_Nullable) addRects:(id _Nullable)border context:(UIView * _Nullable)context;
- (MysticRectView * _Nullable) addRectForView:(UIView *_Nullable)view border:(id _Nullable)borderWidth color:(id _Nullable)color context:(UIView * _Nullable)context;
- (NSArray *_Nullable) addRects:(id _Nullable)border;
- (id _Nullable) subviewsOfClass:(Class _Nullable)viewClass inView:(UIView * _Nullable)parentView andHidden:(BOOL)showHidden recursive:(BOOL)deep;
- (NSArray * _Nullable) subviewsOfClass:(Class _Nullable)viewClass;

- (NSArray *_Nullable) addRects;
- (NSArray *_Nullable) addAllRects:(id _Nullable)border context:(UIView * _Nullable)context container:(UIView * _Nullable)container;
+ (void) animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^ _Nullable)(void))animations;
+ (void) animateWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^ _Nullable)(void))animations;

@end

@interface MysticUIView : NSObject
+ (void)addKeyframeWithRelativeStartTime:(double)frameStartTime relativeDuration:(double)frameDuration animations:(void (^ _Nonnull)(void))animations;
+ (void) animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^ _Nullable)(void))animations completion:(void (^ _Nullable)(BOOL finished))completion;
+ (void) animateWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^ _Nullable)(void))animations;
+ (void) animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^ _Nullable)(void))animations;
+ (void) animateWithDuration:(NSTimeInterval)duration animations:(void (^ _Nullable)(void))animations;
+ (void) animateWithDuration:(NSTimeInterval)duration animations:(void (^ _Nullable)(void))animations completion:(void (^ _Nullable)(BOOL finished))completion;
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^ _Nonnull)(void))animations completion:(void (^ _Nullable)(BOOL finished))completion;
+ (void)animateKeyframesWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewKeyframeAnimationOptions)options animations:(void (^ _Nonnull)(void))animations completion:(void (^ _Nullable)(BOOL finished))completion;
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^ _Nonnull)(void))animations;
+ (void)animateQuickSpringWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^ _Nonnull)(void))animations;
+ (void) animate:(NSTimeInterval)duration animations:(void (^ _Nonnull)(void))animations completion:(void (^ _Nullable)(BOOL finished))completion;
+ (void) animate:(NSTimeInterval)duration animations:(void (^ _Nonnull)(void))animations;

+ (void)animateSpring:(NSTimeInterval)duration animations:(void (^ _Nonnull)(void))animations;



@end
