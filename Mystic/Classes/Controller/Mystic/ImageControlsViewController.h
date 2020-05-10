//
//  ImageControlsViewController.h
//  Mystic
//
//  Created by travis weerts on 1/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EffectControl.h"
#import "Mystic.h"
#import "EffectControlProtocol.h"
#import "MysticScrollView.h"


@interface ImageControlsViewController : UIViewController <UIScrollViewDelegate, EffectControlDelegate>
@property (nonatomic, retain) NSArray *visibleEffects;
@property (nonatomic, assign) BOOL shouldScrollToActiveControl, shouldSelectActiveControls;
@property (nonatomic, retain) NSMutableDictionary *currentStateInfo;
@property (nonatomic, readonly) BOOL shouldUseTargetOption;
@property (nonatomic, assign) PackPotionOption *currentOption;
- (void) hideControls:(MysticScrollView *)scrollView completed:(void (^)())completionBlock;
- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView tileSize:(CGSize)newTileSize;

- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView;
- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView completed:(void (^)(BOOL controlsVisible))completionBlock;
- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView info:(NSDictionary *)userInfo completed:(void (^)(BOOL controlsVisible))completionBlock;

- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView animated:(BOOL)animated completed:(void (^)(BOOL controlsVisible))completionBlock;
- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView animated:(BOOL)animated tileSize:(CGSize)newTileSize completed:(void (^)(BOOL controlsVisible))completionBlock;
- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView animated:(BOOL)animated tileSize:(CGSize)newTileSize info:(NSDictionary *)userInfo completed:(void (^)(BOOL controlsVisible))completionBlock;


- (PackPotionOption *) currentOption;
- (PackPotionOption *) currentOption:(MysticObjectType)ofType;

- (NSInteger) controlIndexForOption:(id)option;

- (BOOL) areControlsVisibleFor:(UIScrollView *)scrollView;
- (void) showCancelButtonTip;
- (void) removeOptionControls:(UIView *)parentView;
- (void) removeControls:(UIView *)parentView except:(NSArray *)exceptions;
- (void) removeControls:(UIView *)parentView;
- (void) removeOptionControls:(UIView *)parentView except:(NSArray *)exceptions;
- (void) removeSubviews:(UIView *)parentView except:(NSArray *)exceptions;

- (void) revealOption:(PackPotionOption *)option scrollView:(UIScrollView *)scrollView animate:(BOOL)animated  complete:(MysticBlockSender)completeBlock;
- (void) revealControlAtIndex:(NSUInteger)theIndex scrollView:(UIScrollView *)scrollView animate:(BOOL)animated  complete:(MysticBlockSender)completeBlock;

- (void) revealSelectedControl:(UIScrollView *)scrollView animate:(BOOL)animated complete:(MysticBlockSender)completeBlock;
- (void) revealSelectedControlAtIndex:(NSUInteger)theIndex scrollView:(UIScrollView *)scrollView  animate:(BOOL)animated complete:(MysticBlockSender)completeBlock;
- (NSInteger) numberOfControls:(UIView *)parentView;
- (void) deselectControls:(UIView *)parentView;
- (CGRect) frameForTileAtIndex:(NSUInteger)index;
- (void) removeSubviews:(UIView *)parentView exceptClass:(Class)classException;
- (void) reloadControls:(UIScrollView *)scrollView;
- (BOOL) isControlActive:(PackPotionOption *)theeffect;

@end
