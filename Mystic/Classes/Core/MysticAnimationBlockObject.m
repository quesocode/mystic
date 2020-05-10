//
//  MysticAnimationBlockObject.m
//  Mystic
//
//  Created by Me on 9/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticAnimationBlockObject.h"
#import "UIView+Mystic.h"
#import "MysticUser.h"

@interface MysticAnimationBlockObject ()
@property (nonatomic, retain) NSMutableArray *nextAnimations;
@property (nonatomic, assign) int finishedNextAnimations;
@property (nonatomic, readonly) NSTimeInterval durationValue, delayValue;
@property (nonatomic, readonly) CGFloat dampingValue, velocityValue;

@end
@implementation MysticAnimationBlockObject

@synthesize animated=_animated, duration=_duration;
static NSMutableDictionary *storedAnimations;
+ (void) initialize;
{
    storedAnimations = [[NSMutableDictionary alloc] init];
}
+ (void) removeAllAnimationsFrom:(UIView *)view;
{
    [self removeAllAnimationsFromLayer:view.layer];
    for (UIView *subview in view.subviews) {
        [self removeAllAnimationsFrom:subview];
    }
}
+ (void) removeAllAnimationsFromLayer:(CALayer *)layerParent;
{
    [layerParent removeAllAnimations];
    for (CALayer *layer in [layerParent.sublayers copy]) {
        [self removeAllAnimationsFromLayer:layer];
    }
}
+ (void) removeAllAnimations;
{
    [storedAnimations removeAllObjects];
}
+ (void) removeAnimations:(NSString *)prefix;
{
    if(!prefix || prefix.length <= 0) return [[self class] removeAllAnimations];
    
    NSMutableDictionary *s = [NSMutableDictionary dictionaryWithDictionary:storedAnimations];
    for (NSString *key in storedAnimations.allKeys) {
        if([key isEqualToString:prefix] || [key hasPrefix:prefix]) [s removeObjectForKey:key];
    }
    [storedAnimations removeAllObjects];
    [storedAnimations addEntriesFromDictionary:s];
}
+ (instancetype) animationForKey:(NSString *)name;
{
    return !name ? nil : [storedAnimations objectForKey:name];
}
+ (void) setAnimation:(MysticAnimationBlockObject *)obj2;
{
    [[self class] setAnimation:obj2 forKey:obj2.name];
}
+ (void) setAnimation:(MysticAnimationBlockObject *)obj2 forKey:(NSString *)name;
{
    name = name ? name : obj2.name;
    if(!name) return;
    if(!obj2)
    {
        [storedAnimations removeObjectForKey:name];
        return;
    }
    if(!obj2.name) obj2.name = name;
    [storedAnimations setObject:obj2 forKey:name];
}
+ (instancetype) animate:(NSString *)name;
{
    return [[self class] animate:name complete:nil];
}
+ (instancetype) animate:(NSString *)name complete:(MysticBlockAnimationComplete)animComplete;
{
    if(!name) return nil;
    MysticAnimationBlockObject *anim = [storedAnimations objectForKey:name];
    if(anim) [anim animateAndFinish:animComplete];
    return anim;
}
+ (id) animation;
{
    return [[self class] animationWithDuration:0];
}
+ (id) animationWithAnimations:(MysticBlockAnimation)obj2;
{
    MysticAnimationBlockObject *obj = [[self class] animation];
    [obj addAnimation:obj2];
    return obj;
}
+ (id) animationWithAnimation:(MysticAnimationBlockObject *)obj2;
{
    MysticAnimationBlockObject *obj = [[self class] animation];
    [obj addAnimations:obj2];
    return obj;
}
+ (id) animationWithType:(MysticAnimationType)type duration:(NSTimeInterval)duration;
{
    return [[self class] animationWithType:type duration:duration delay:0 options:0];
    
}
+ (id) animationWithDuration:(NSTimeInterval)duration;
{
    return [[self class] animationWithType:MysticAnimationTypeKeyFrame duration:duration delay:0 options:0];
}
+ (id) animationWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
{
    return [[self class] animationWithType:MysticAnimationTypeKeyFrame duration:duration delay:delay options:0];
}
+ (id) animationWithType:(MysticAnimationType)type duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options;
{
    MysticAnimationBlockObject *obj = [self class].new;
    obj.animationType = type;
    obj.duration = duration;
    obj.delay = delay;
    obj.animationOptions = options;
    return obj;
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        _finishedNextAnimations = 0;
        _completeAfterNextAnimations = NO;
        _animated = YES;
        _shouldClean = YES;
        [self clean];
        self.finished = NO;
        self.name = nil;
        self.nextAnimations = [NSMutableArray array];
    }
    return self;
}

- (void) clean;
{
    if(!self.shouldClean) return;
    self.animationType = MysticAnimationTypeKeyFrame;
    self.duration = NAN;
    self.delay = NAN;
    self.animationOptions = UIViewAnimationOptionTransitionNone;
    self.velocity = 0.5;
    self.damping = 0.7;

    self.animationBlocks = [NSMutableArray array];
    self.animationsCompleteBlocks = [NSMutableArray array];
    self.preAnimationBlocks = [NSMutableArray array];
    self.allFinishedAnimationBlocks = [NSMutableArray array];

    
}
- (CGFloat) dampingValue; { return _damping; }
- (CGFloat) velocityValue; { return _velocity; }

- (NSTimeInterval) durationValue; { return _duration; }
- (NSTimeInterval) duration; { return isnan(_duration) ? 0 : _duration; }
- (NSTimeInterval) delayValue; { return _delay; }
- (NSTimeInterval) delay; { return isnan(_delay) ? 0 : _delay; }

- (id) addAnimations:(MysticAnimationBlockObject *)obj2;
{
    if([obj2 isKindOfClass:[self class]])
    {
        self.duration = MAX(obj2.duration, self.duration);
        self.delay = MAX(obj2.delay, self.delay);
        self.animationOptions = obj2.animationOptions|self.animationOptions;
        [self.preAnimationBlocks addObjectsFromArray:obj2.preAnimationBlocks];
        [self.animationBlocks addObjectsFromArray:obj2.animationBlocks];
        [self.animationsCompleteBlocks addObjectsFromArray:obj2.animationsCompleteBlocks];
        self.animationType = obj2.animationType;
        self.damping = obj2.damping;
        self.velocity = obj2.velocity;
        self.animated = obj2.animated;
    }
    else if(obj2 && [obj2 isKindOfClass:[NSNumber class]] && ![obj2 isEqual:@(0)] && ![obj2 isEqual:@(1)] && [(NSNumber *)obj2 floatValue] > 0 && [(NSNumber *)obj2 floatValue] != 1.0)
    {
        self.animated = [(NSNumber *)obj2 floatValue] > 0;
    }
    else
    {
        self.animated = obj2 != nil ? [(NSNumber *)obj2 boolValue] : YES;
    }
    return self;
}
- (void) finished:(MysticBlockAnimationComplete)completion;
{
    if(completion) [self.allFinishedAnimationBlocks addObject:completion];

}


- (id) addPreAnimation:(MysticBlockObject)preAnimationBlock;
{
    [self addPreAnimation:preAnimationBlock context:nil];
    return self;

}
- (id) addPreAnimation:(MysticBlockObject)preAnimationBlock context:(id)context;
{
    if(preAnimationBlock) [self.preAnimationBlocks addObject:@{@"block": preAnimationBlock, @"context": context ? context :self}];
    return self;

}
- (id) addAnimation:(MysticBlockAnimation)animations;
{
    [self addAnimation:animations complete:nil];
    return self;
}
- (id) addAnimationComplete:(MysticBlockAnimationComplete)complete;
{
    [self addAnimation:nil complete:complete];
    return self;
}
- (id) addAnimation:(MysticBlockAnimation)animations complete:(MysticBlockAnimationComplete)complete;
{
    self.animationsCompleteBlocks = self.animationsCompleteBlocks ? self.animationsCompleteBlocks : [NSMutableArray array];

  
    if(animations) [self addKeyOrAnimation:0 duration:self.duration animations:animations];
    if(complete) [self.animationsCompleteBlocks addObject:complete];
    return self;


}
- (id) addKeyOrAnimation:(NSTimeInterval)startTime duration:(NSTimeInterval)duration animations:(MysticBlockAnimation)animations;
{
    
    [self addKeyFrame:startTime duration:duration animations:animations];
    return self;

}
- (id) addKeyFrame:(NSTimeInterval)startTime duration:(NSTimeInterval)duration animations:(MysticBlockAnimation)animations;
{
    float nd = MAX(self.duration, startTime + duration);
    __block float start = startTime/nd;
    __block float time = duration/nd;
    if(startTime > 0 && self.animationType != MysticAnimationTypeKeyFrame) self.animationType = MysticAnimationTypeKeyFrame;
    self.duration = nd;
    [self addAnimationToAnimations:@{@"start": @(start),
                                     @"time": @(time),
                                     @"startTime": @(startTime),
                                     @"duration": @(duration),
                                     @"_block": animations,
                                     @"old":  @{@"start": @(start), @"time": @(time), @"startTime": @(startTime), @"duration": @(duration)}}];
    return self;
}
- (id) addAnimationToAnimations:(id)animations;
{
    self.animationBlocks = self.animationBlocks ? self.animationBlocks : [NSMutableArray array];
    if(animations && [animations isKindOfClass:[NSDictionary class]]) [self.animationBlocks addObject:animations];
    else [self.animationBlocks addObject:@{@"_block": animations}];
    [self recalculate];
    return self;
}
- (id) addNextAnimationWithDuration:(NSTimeInterval)duration animations:(MysticBlockAnimation)animations;
{
    return [self addNextAnimationWithDuration:duration animations:animations complete:nil];
}
- (id) addNextAnimationWithDuration:(NSTimeInterval)duration animations:(MysticBlockAnimation)animations complete:(MysticBlockAnimationComplete)complete;
{
    MysticAnimation *anim = [MysticAnimation animationWithDuration:duration];
    [anim addAnimation:animations complete:complete];
    return [self addNextAnimation:anim];
}

- (id) addNextAnimationsFromArray:(NSArray *)animations;
{
    if(!animations.count) return self;
    [self.nextAnimations addObjectsFromArray:animations];
    return animations.lastObject;
}
- (id) addNextAnimations:(NSArray *)animations;
{
    if(!animations.count) return self;
    MysticAnimation *nextAnim = self.nextAnimations.count ? self.nextAnimations.lastObject : nil;
    if(nextAnim) [nextAnim addNextAnimations:animations];
    else
    {
        for (MysticAnimation *obj2 in animations) [self _addNextAnimation:obj2];
    }
    return animations.lastObject;
}

- (id) addNextAnimation:(MysticAnimationBlockObject *)obj2;
{
    if(!obj2) return nil;
    MysticAnimation *nextAnim = self.nextAnimations.count ? self.nextAnimations.lastObject : nil;
    if(nextAnim) [nextAnim addNextAnimation:obj2];
    else if(obj2) [self _addNextAnimation:obj2];
    return obj2;
}
- (id) _addNextAnimation:(MysticAnimationBlockObject *)obj2;
{
    obj2.completeAfterNextAnimations = self.completeAfterNextAnimations;
    obj2.animationOptions = self.animationOptions;
    obj2.duration = isnan(obj2.durationValue) ? self.durationValue : obj2.duration;
    obj2.damping = self.damping;
    obj2.velocity = self.velocity;
    obj2.animated = self.animated;
    obj2.shouldClean = self.shouldClean;

    if(!obj2.name) obj2.name = [NSString stringWithFormat:@"%@-%d", self.name ? self.name : @"NextAnim", (int)self.nextAnimations.count];
    [self.nextAnimations addObject:obj2];
    return obj2;
}

- (void) recalculate;
{
    NSArray *subArray = [NSArray arrayWithArray:self.animationBlocks];
    for (int i = 0; i<subArray.count; i++) {
        NSDictionary *obj = [self.animationBlocks objectAtIndex:i];
        float startTime = [obj objectForKey:@"startTime"] ? [[obj objectForKey:@"startTime"] floatValue] : 0;
        float duration = [obj objectForKey:@"duration"] ? [[obj objectForKey:@"duration"] floatValue] : -1;
        self.duration = duration < 0 ? self.duration : MAX(self.duration, startTime + duration);
    }
//    self.duration=self.duration>0&&self.animationType==MysticAnimationTypeKeyFrame?self.duration*[MysticUser getf:Mk_TIME]:self.duration;


}
- (void) prepAnimations;
{
//    NSTimeInterval duration=self.duration>0&&self.animationType!=MysticAnimationTypeKeyFrame?self.duration*[MysticUser getf:Mk_TIME]:self.duration;
//    NSTimeInterval delay=self.delay>0&&self.animationType!=MysticAnimationTypeKeyFrame?self.delay*[MysticUser getf:Mk_TIME]:self.delay;

    
    NSArray *subArray = [NSArray arrayWithArray:self.animationBlocks];
    [self recalculate];
    NSTimeInterval finalDuration=self.duration>0&&self.animationType==MysticAnimationTypeKeyFrame?self.duration*[MysticUser getf:Mk_TIME]:self.duration;
    for (int i = 0; i<subArray.count; i++) {
        NSDictionary *obj = [self.animationBlocks objectAtIndex:i];
        NSDictionary *obj2 = [obj objectForKey:@"old"] ? [obj objectForKey:@"old"] : @"";
        float startTime = [obj objectForKey:@"startTime"] ? [[obj objectForKey:@"startTime"] floatValue] : 0;
        float duration = [obj objectForKey:@"duration"] ? [[obj objectForKey:@"duration"] floatValue] : self.duration;
        startTime=startTime>0&&self.animationType==MysticAnimationTypeKeyFrame?startTime*[MysticUser getf:Mk_TIME]:startTime;
        duration=duration>0&&self.animationType==MysticAnimationTypeKeyFrame?duration*[MysticUser getf:Mk_TIME]:duration;
        float start = startTime/finalDuration;
        float time = duration/finalDuration;
        MysticBlockAnimation _block = [obj objectForKey:@"_block"];
        MysticBlockAnimationKeyFrame keyFrame = [obj objectForKey:@"block"];
        if(!keyFrame)
        {
            keyFrame = ^(float _start, float _time){
                [MysticUIView addKeyframeWithRelativeStartTime:(double)_start relativeDuration:(double)_time animations:_block];
            };
        }
        [self.animationBlocks replaceObjectAtIndex:i withObject:@{@"block": keyFrame, @"_block": _block, @"start": @(start), @"time": @(time), @"startTime": @(startTime), @"duration": @(duration), @"old": obj2}];
    }
    self.duration=finalDuration;
    self.delay=self.delay>0&&self.animationType==MysticAnimationTypeKeyFrame?self.delay*[MysticUser getf:Mk_TIME]:self.delay;
}
- (void) execAnimations;
{
    for (int i = 0; i<self.animationBlocks.count; i++) {
        NSDictionary *obj = [self.animationBlocks objectAtIndex:i];
        switch (self.animationType) {
            case MysticAnimationTypeKeyFrame:
            {
                MysticBlockAnimationKeyFrame block = [obj objectForKey:@"block"];
                if(self.animated && block)
                {
                    block([[obj objectForKey:@"start"] floatValue], [[obj objectForKey:@"time"] floatValue]); break;
                }
            }
            default:
            {
                MysticBlockAnimation _block = [obj objectForKey:@"_block"];
                if(_block) _block();
                break;
            }
        }
    }
}

- (void) execAnimationComplete:(BOOL)finished;
{
    self.finishedNextAnimations = 0;
    int nc = (int)self.nextAnimations.count;
    if(nc == 0 || !self.completeAfterNextAnimations)
    {
        [self execAllAnimationsComplete:finished];
        if(nc == 0 && self.allFinishedAnimationBlocks.count > 0)
        {
            [self execAllAnimationsFinished:finished];
        }
    }
    
    
    if(nc > 0)
    {

        __block MysticAnimationBlockObject *weakSelf = self;
        NSMutableArray *nexts = [NSMutableArray arrayWithArray:self.nextAnimations];
        for (MysticAnimation *anim in nexts) {
                [anim startAnimation:anim.animated complete:^(BOOL finished2, MysticAnimationBlockObject *obj) {
                    weakSelf.finishedNextAnimations++;

                    if(weakSelf.finishedNextAnimations == nc)
                    {
                        if(weakSelf.completeAfterNextAnimations) [weakSelf execAllAnimationsComplete:finished2 && finished];
                        if(weakSelf.allFinishedAnimationBlocks.count > 0)
                        {
                            [weakSelf execAllAnimationsFinished:finished2 && finished];
                        }
                    }
                }];
        }
    }
    
    
}
- (void) execAllAnimationsFinished:(BOOL)finished;
{
    for (int i = 0; i<self.allFinishedAnimationBlocks.count; i++) {
        MysticBlockAnimationComplete anim = [self.allFinishedAnimationBlocks objectAtIndex:i];
        if(anim) anim(finished, self);
    }
}
- (void) execAllAnimationsComplete:(BOOL)finished;
{
    for (int i = 0; i<self.animationsCompleteBlocks.count; i++) {
        MysticBlockAnimationComplete anim = [self.animationsCompleteBlocks objectAtIndex:i];
        if(anim) anim(finished, self);
    }
}
- (BOOL) canUseSpecialAnimation;
{
    return usingIOS7();
}
- (MysticAnimationType) animationType;
{
    switch (_animationType) {
        case MysticAnimationTypeKeyFrame:
        case MysticAnimationTypeSpring:
            if(!usingIOS7()) return MysticAnimationTypeNormal;
            break;
        default: break;
    }
    return _animationType;
}

- (void) setPaused:(BOOL)paused;
{
    _paused = paused;
    if(!_paused && self.isAnimating) [self startAnimation];
}
- (BOOL) animated;
{
    return _animated && self.duration > 0 ? YES : NO;
}
- (void) setFinished:(BOOL)finished;
{
    _finished = finished;
    if(finished && self.isAnimating) self.isAnimating = NO;
}
- (void) animate:(MysticBlockAnimationComplete)completion;
{
    [self addAnimationComplete:completion];
    [self startAnimation:self.animated complete:nil];
}
- (void) animateAndFinish:(MysticBlockAnimationComplete)completion;
{
    if(completion) [self.allFinishedAnimationBlocks addObject:completion];

    [self startAnimation:self.animated complete:nil];
}
- (void) animate;
{
    [self startAnimation:self.animated complete:nil];
}
- (void) startAnimation;
{
    [self startAnimation:self.animated animations:nil complete:nil];
}
- (void) startAnimation:(BOOL)animated complete:(MysticBlockAnimationComplete)completion;
{
    [self startAnimation:animated animations:nil complete:completion];
}
- (void) startAnimations:(MysticBlockAnimation)newAnimations complete:(MysticBlockAnimationComplete)completion;
{
    [self startAnimation:self.animated animations:newAnimations complete:completion];
}
- (void) startAnimation:(BOOL)animated animations:(MysticBlockAnimation)newAnimations complete:(MysticBlockAnimationComplete)completion;
{
    self.finished = NO;
    self.isAnimating = YES;
    self.animated = animated;
    if(newAnimations) [self addAnimation:newAnimations];
    if(completion) [self addAnimation:nil complete:completion];
    if(self.paused) return;
    [self prepAnimations];
    if(self.preAnimationBlocks.count)
    {
        for (NSDictionary *preObj in self.preAnimationBlocks) {
            MysticBlockObject preBlock = [preObj objectForKey:@"block"];
            if(preBlock) preBlock([preObj objectForKey:@"context"]);
        }
    }
    if(!self.animated)
    {
        [self execAnimations];
        self.finished = YES;
        [self execAnimationComplete:YES];
    }
    else
    {
        __block MysticAnimationBlockObject *weakSelf = self;
        
        switch (self.animationType) {
            case MysticAnimationTypeSpring:
            {
                [MysticUIView animateWithDuration:self.duration delay:self.delay usingSpringWithDamping:self.damping initialSpringVelocity:self.velocity options:self.animationOptions animations:^{
                    [weakSelf execAnimations];
                } completion:^(BOOL finished) {
                    weakSelf.finished = finished;
                    [weakSelf execAnimationComplete:finished];
                }];
                break;
            }
            case MysticAnimationTypeKeyFrame:
            {
                [MysticUIView animateKeyframesWithDuration:self.duration delay:self.delay options:self.animationOptions animations:^{
                    [weakSelf execAnimations];
                } completion:^(BOOL finished) {
                    weakSelf.finished = finished;
                    [weakSelf execAnimationComplete:finished];
                }];
                break;
            }
                
            default:
            {
                [MysticUIView animateWithDuration:self.duration delay:self.delay options:self.animationOptions animations:^{
                    [weakSelf execAnimations];
                } completion:^(BOOL finished) {
                    weakSelf.finished = finished;
                    [weakSelf execAnimationComplete:finished];
                }];
                break;
            }
        }
    }
}

- (void) finishedDescription;
{
//    ALLog(@"ANIMATION FINISHED", @[@"name", MObj(self.name),
//                                   @"duration", @(self.duration),
//                                   @"finished", MBOOL(self.finished),
//                                   @"animations", @(self.animationBlocks.count),
////                                   @"animations", self.animationBlocks,
//
//                                   ]);
}
- (NSString *) description;
{
    NSString *type = @"Normal";
    switch (self.animationType) {
        case MysticAnimationTypeKeyFrame:
            type = @"KeyFrame";
            break;
        case MysticAnimationTypeSpring:
            type = @"Spring";
            break;
        default: break;
    }
    return ALLogStrf([@"Animation: " stringByAppendingString:self.name ? self.name : @"(no name)"],
                                @[@"type", MObj(type),
                                  @"animated", MBOOL(self.animated),
                                  @"paused", MBOOL(self.paused),
                                  @"finished", MBOOL(self.finished),
                                  
                                  @"duration", @(self.duration),
                                  @"delay", @(self.delay),
                                  LINE,
                                  @"animations", @(self.animationBlocks.count),
                                  @"completes", @(self.animationsCompleteBlocks.count),
                                  LINE,
                                  @"animations", self.animationBlocks,
                                
                                ]);
}
@end

@implementation MysticAnimation

@end
