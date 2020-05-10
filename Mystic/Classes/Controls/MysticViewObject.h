//
//  MysticViewObject.h
//  Mystic
//
//  Created by Me on 3/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "Mystic.h"

@interface MysticViewObject : NSMutableDictionary

@property (nonatomic, copy) MysticBlockObject willShowBlock;
@property (nonatomic, copy) MysticBlockObject didShowBlock;
@property (nonatomic) MysticObjectType setting;
@property (nonatomic) BOOL viewHasLoaded, shouldReload, viewHasAppeared;
@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) NSMutableDictionary *info;
@property (nonatomic, copy) MysticBlockObjObj viewDidAppear, viewWillAppear, viewWillDisappear, viewDidDisappear, viewDidRemoveFromSuperview, viewIsReady;
@property (nonatomic, copy) MysticBlockObjObjComplete prepareContainerView;

+ (id) view:(UIView *)view willShow:(MysticBlockObject)willShow didShow:(MysticBlockObject)didShow;
+ (id) info:(NSDictionary *)info;
- (void) willShow;
- (void) didShow;
- (void) willAppear;
- (void) willDisappear;
- (void) didAppear;
- (void) didDisappear;
- (void) isReady;
- (void) isReadyAfterDelay:(NSTimeInterval)delay;
- (void) didRemoveFromSuperview;
- (void) prepareContainerView:(UIView *)parentView complete:(MysticBlockObjBOOL)finished;
- (void) commonInit;

@end


