//
//  EffectControlProtocol.h
//  Mystic
//
//  Created by Travis on 10/21/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#ifndef Mystic_EffectControlProtocol_h
#define Mystic_EffectControlProtocol_h

@class MysticControlObject, EffectControl, PackPotionOption;

@protocol EffectControlDelegate <NSObject>

@optional
- (void) effectControlIsSelecting:(UIControl *)effectControl effect:(MysticControlObject *)effect;
- (void) effectControlWasSelected:(UIControl *)effectControl effect:(MysticControlObject *)effect;
- (void) effectControlDidTouchUp:(UIControl *)effectControl effect:(MysticControlObject *)effect;
- (void) effectControl:(EffectControl *)effectControl accessoryTouched:(id)sender;

- (void) effectControlWasDeselected:(UIControl *)effectControl effect:(MysticControlObject *)effect;
- (void) effectControlWasHeld:(UIControl *)effectControl effect:(MysticControlObject *)effect;
- (void) userCancelledEffectControl:(UIControl *)effectControl effect:(MysticControlObject *)effect;
- (void) userFinishedEffectControlSelections:(UIControl *)effectControl effect:(MysticControlObject *)effect;
- (BOOL) isEffectControlVisible:(EffectControl *)control;
- (NSInteger) effectControlVisibilityIndex:(EffectControl *)control;
- (void) effectControlSettingsTouched:(EffectControl *)control;
- (BOOL) isEffectControlActive:(EffectControl *)control;
- (BOOL) isOptionActive:(PackPotionOption *)option shouldSelectActiveControls:(BOOL)ashouldSelectActiveControls index:(NSInteger)index scrollView:(id)scrollView;


@end

#endif
