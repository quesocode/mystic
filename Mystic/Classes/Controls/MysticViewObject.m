//
//  MysticViewObject.m
//  Mystic
//
//  Created by Me on 3/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticViewObject.h"

@implementation MysticViewObject

@synthesize info=_info, view=_view;

+ (id) info:(NSDictionary *)info;
{
    MysticViewObject *obj = [[[self class] alloc] init];
    obj.info = info ? [NSMutableDictionary dictionaryWithDictionary:info] : [NSMutableDictionary dictionary];
    obj.shouldReload = obj.info[@"reload"] ? [obj.info[@"reload"] boolValue] : NO;
    return [obj autorelease];
}
+ (id) view:(UIView *)view willShow:(MysticBlockObject)willShow didShow:(MysticBlockObject)didShow;
{
    MysticViewObject *obj = [[[self class] alloc] init];
    obj.willShowBlock = willShow;
    obj.didShowBlock = didShow;
    obj.view = view;
    return [obj autorelease];
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        [self commonInit];
    }
    return self;
}
- (void) commonInit;
{
    _viewHasLoaded = NO;
    self.viewHasAppeared = NO;
    _setting = MysticObjectTypeUnknown;


}
- (NSUInteger) count;
{
    return self.info.count;
}
- (NSEnumerator *) objectEnumerator;
{
    return [self.info objectEnumerator];
}
- (NSEnumerator *) keyEnumerator;
{
    return [self.info keyEnumerator];
}
- (id) objectForKey:(id)aKey;
{
    return [self.info objectForKey:aKey];
}
- (void) willShow;
{
    if(self.willShowBlock)
    {
        self.willShowBlock(self.view);
        self.willShowBlock = nil;
    }
}
- (void) didShow;
{
    if(self.didShowBlock)
    {
        self.didShowBlock(self.view);
        self.didShowBlock = nil;
    }
}

- (void) setInfo:(NSMutableDictionary *)info;
{
    if(_info) [_info release], _info=nil;
    _info = [info retain];
    MysticObjectType __setting = [info objectForKey:@"setting"] ? [[info objectForKey:@"setting"] integerValue] : MysticObjectTypeUnknown;
    __setting = __setting == MysticObjectTypeUnknown && [info objectForKey:@"type"] ? [[info objectForKey:@"type"] integerValue] : __setting;
    self.setting = __setting;
}

- (void) willAppear;
{
    if(self.viewWillAppear)
    {
        self.viewWillAppear(self.view, self);
    }
}
- (void) didAppear;
{
    self.viewHasAppeared = YES;
    if(self.viewDidAppear)
    {
        self.viewDidAppear(self.view, self);
    }
}
- (void) willDisappear;
{
    if(self.viewWillDisappear)
    {
        self.viewWillDisappear(self.view, self);
    }
}

- (void) isReady;
{
    
    if(!self.viewHasLoaded && self.viewIsReady)
    {
        self.viewIsReady(self.view, self);
        self.viewIsReady = nil;
        self.viewHasLoaded = YES;
    }
}
- (void) isReadyAfterDelay:(NSTimeInterval)delay;
{
    if(delay <= 0)
    {
        [self isReady];
        return;
    }
    [self performSelector:@selector(isReady) withObject:nil afterDelay:delay];
}

- (void) didDisappear;
{
    if(self.viewDidDisappear)
    {
        self.viewDidDisappear(self.view, self);
    }
}
- (void) prepareContainerView:(UIView *)parentView complete:(MysticBlockObjBOOL)finished;
{
    if(self.prepareContainerView)
    {
        self.prepareContainerView(parentView, self, finished);
    }
}
- (void) didRemoveFromSuperview;
{
    if(self.viewDidRemoveFromSuperview)
    {
        self.viewDidRemoveFromSuperview(self.view, self);
    }
}

- (NSString *) description;
{
    return [NSStringFromClass([self class]) stringByAppendingString:[super description]];
}
- (void) dealloc;
{
    Block_release(_didShowBlock);
    Block_release(_willShowBlock);
    Block_release(_viewDidAppear);
    Block_release(_viewWillAppear);
    Block_release(_viewDidDisappear);
    Block_release(_viewWillDisappear);
    Block_release(_prepareContainerView);
    Block_release(_viewDidRemoveFromSuperview);
    Block_release(_viewIsReady);
    [_info release];
    [_view release];
    [super dealloc];
}


@end
