//
//  MysticTools.h
//  Mystic
//
//  Created by travis weerts on 3/2/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mystic.h"
#import "MysticController.h"
#import "MysticTransformButton.h"

@class MysticTools;

@protocol MysticToolsDelegate <NSObject>

@optional

- (void) mysticTools:(MysticTools *)toolsView toolIsBeingHeld:(MysticTransformButton *)toolButton;
- (void) mysticTools:(MysticTools *)toolsView toolTouchedUp:(MysticTransformButton *)toolButton;



@end


@interface MysticTools : UIView

@property (nonatomic, copy) MysticBlockTools onTransform;
@property (nonatomic, retain) UIImageView *blurView;
@property (nonatomic, assign) MysticObjectType currentSetting;
@property (nonatomic, assign) PackPotionOption *option;
@property (nonatomic, readonly) PackPotionOption *currentOption;
@property (nonatomic, readonly) CGRect innerFrame;
@property (nonatomic, assign) CGFloat toolSize, toolHitInsets;
@property (nonatomic, assign) MysticController *viewController;
@property (nonatomic, assign) MysticToolsTransformType lastActiveTransform;
@property (nonatomic, assign) BOOL hideControlsWhenDone;
- (id)initWithFrame:(CGRect)frame setting:(MysticObjectType)setting;
- (void) resetDefaults;
- (void) fadeOut;
- (void) fadeIn;
- (void) fadeInFast;
- (void) fadeInFastAfterDelay:(NSTimeInterval)delay;
- (void) fadeInFastAfterDelay:(NSTimeInterval)delay completion:(MysticBlockBOOL)finishedAnim;

- (void) fadeOutFast;
- (void) fadeOutFastAfterDelay:(NSTimeInterval)delay;
- (void) fadeOutFastAfterDelay:(NSTimeInterval)delay completion:(MysticBlockBOOL)finishedAnim;

- (void) fadeOutRealFast;
- (void) startTimer;
- (void) fadeOutWithTimer;
- (void) fadeInWithTimer;
- (void) fadeInWithTimer:(NSTimeInterval)fadeOutDelay;

- (void) stopTimer;

- (void) reloadImage;
- (void) reloadImageWithCompletion:(MysticBlock)finished;

- (void) fadeOut:(MysticBlockBOOL)finishedAnim;
- (void) fadeIn:(MysticBlockBOOL)finishedAnim;
- (void) fadeOutRealFast:(MysticBlockBOOL)finishedAnim;
- (void) fadeOutFast:(MysticBlockBOOL)finishedAnim;
- (void) fadeInFast:(MysticBlockBOOL)finishedAnim;
- (void) setToolHitInsets:(UIEdgeInsets)v forType:(MysticToolsTransformType)type;

@end
