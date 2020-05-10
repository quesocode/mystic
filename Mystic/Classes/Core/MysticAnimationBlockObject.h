//
//  MysticAnimationBlockObject.h
//  Mystic
//
//  Created by Me on 9/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticBlockObj.h"


@interface MysticAnimationBlockObject : MysticBlockObj
@property (nonatomic, retain) NSMutableArray *preAnimationBlocks;
@property (nonatomic, retain) NSMutableArray *allFinishedAnimationBlocks;

@property (nonatomic, retain) NSMutableArray *animationBlocks;
@property (nonatomic, retain) NSMutableArray *animationsCompleteBlocks;
@property (nonatomic, assign) NSTimeInterval duration, delay;
@property (nonatomic, assign) UIViewAnimationOptions animationOptions;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) MysticAnimationType animationType;
@property (nonatomic, assign) CGFloat damping, velocity;
@property (nonatomic, assign) BOOL animated, finished, isAnimating, paused, completeAfterNextAnimations, shouldClean;


+ (instancetype) animationForKey:(NSString *)name;
+ (void) setAnimation:(MysticAnimationBlockObject *)obj2;
+ (void) setAnimation:(MysticAnimationBlockObject *)obj2 forKey:(NSString *)name;
+ (instancetype) animate:(NSString *)name;
+ (instancetype) animate:(NSString *)name complete:(MysticBlockAnimationComplete)animComplete;
+ (void) removeAllAnimations;
+ (void) removeAllAnimationsFrom:(UIView *)view;
+ (void) removeAllAnimationsFromLayer:(CALayer *)layerParent;

+ (void) removeAnimations:(NSString *)prefix;

+ (id) animation;
+ (id) animationWithAnimations:(MysticBlockAnimation)obj2;
+ (id) animationWithAnimation:(MysticAnimationBlockObject *)obj2;
+ (id) animationWithType:(MysticAnimationType)type duration:(NSTimeInterval)duration;
+ (id) animationWithDuration:(NSTimeInterval)duration;
+ (id) animationWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

+ (id) animationWithType:(MysticAnimationType)type duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options;
- (void) animate:(MysticBlockAnimationComplete)completion;
- (void) animateAndFinish:(MysticBlockAnimationComplete)completion;

- (id) addAnimations:(MysticAnimationBlockObject *)obj2;
- (id) addNextAnimation:(MysticAnimationBlockObject *)obj2;
- (id) addNextAnimationWithDuration:(NSTimeInterval)duration animations:(MysticBlockAnimation)animations;
- (id) addNextAnimationWithDuration:(NSTimeInterval)duration animations:(MysticBlockAnimation)animations complete:(MysticBlockAnimationComplete)complete;

- (id) addNextAnimations:(NSArray *)animations;
- (id) addNextAnimationsFromArray:(NSArray *)animations;

- (id) addAnimation:(MysticBlockAnimation)animations;
- (id) addAnimationComplete:(MysticBlockAnimationComplete)complete;
- (id) addAnimation:(MysticBlockAnimation)animations complete:(MysticBlockAnimationComplete)complete;
- (id) addKeyOrAnimation:(NSTimeInterval)startTime duration:(NSTimeInterval)duration animations:(MysticBlockAnimation)animations;
- (void) finished:(MysticBlockAnimationComplete)completion;
- (id) addKeyFrame:(NSTimeInterval)startTime duration:(NSTimeInterval)duration animations:(MysticBlockAnimation)animations;
- (void) finishedDescription;
- (void) execAnimations;
- (void) execAnimationComplete:(BOOL)finished;
- (void) startAnimation;
- (void) startAnimation:(BOOL)animated complete:(MysticBlockAnimationComplete)completion;
- (void) startAnimations:(MysticBlockAnimation)newAnimations complete:(MysticBlockAnimationComplete)completion;
- (void) startAnimation:(BOOL)animated animations:(MysticBlockAnimation)newAnimations complete:(MysticBlockAnimationComplete)completion;
- (id) addPreAnimation:(MysticBlockObject)preAnimationBlock context:(id)context;
- (id) addPreAnimation:(MysticBlockObject)preAnimationBlock;
- (void) animate;

@end
@interface MysticAnimation : MysticAnimationBlockObject;
@end