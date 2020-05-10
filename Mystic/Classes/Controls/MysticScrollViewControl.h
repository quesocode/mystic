//
//  MysticScrollViewControl.h
//  Mystic
//
//  Created by Travis A. Weerts on 10/24/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticButton.h"
#import "MysticChoice.h"


@class MysticChoice, MysticScrollViewControl, PackPotionOption;

@protocol MysticScrollViewControlDelegate <NSObject>

@optional
- (void) controlIsSelecting:(UIControl *)control effect:(MysticChoice *)effect;
- (void) controlWasSelected:(UIControl *)control effect:(MysticChoice *)effect;
- (void) controlDidTouchUp:(UIControl *)control effect:(MysticChoice *)effect;
- (void) control:(UIControl *)control accessoryTouched:(id)sender;

- (void) controlWasDeselected:(UIControl *)control effect:(MysticChoice *)effect;
- (void) controlWasHeld:(UIControl *)control effect:(MysticChoice *)effect;
- (void) userCancelledControl:(UIControl *)control effect:(MysticChoice *)effect;
- (void) userFinishedControlSelections:(UIControl *)control effect:(MysticChoice *)effect;
- (BOOL) isControlVisible:(UIControl *)control;
- (NSInteger) controlVisibilityIndex:(UIControl *)control;
- (void) controlSettingsTouched:(UIControl *)control;
- (BOOL) isControlActive:(UIControl *)control;
- (BOOL) isOptionActive:(MysticChoice *)option shouldSelectActiveControls:(BOOL)ashouldSelectActiveControls index:(NSInteger)index scrollView:(id)scrollView;


@end



@interface MysticScrollViewControl : MysticButton
@property (nonatomic, assign) MysticGridIndex gridIndex;
@property (nonatomic, assign) int position;
@property (nonatomic, assign) BOOL isFirst, isLast, wasSelected;
@property (nonatomic, retain) MysticChoice *effect;
@property (nonatomic, retain) id targetOption;
@property (nonatomic, retain) id <MysticScrollViewControlDelegate> delegate;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, assign) UIEdgeInsets insets;

- (void) reuse;
- (void) updateLabel:(BOOL)selected;
- (void) showAsSelected;
- (void) showAsSelected:(BOOL)makeSelected;
- (void) prepare;
@end
