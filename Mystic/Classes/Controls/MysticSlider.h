//
//  MysticSlider.h
//  Mystic
//
//  Created by travis weerts on 1/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"
#import "NMRangeSlider2.h"
#import "MysticSliderBlocks.h"


@class  PackPotionOption;

typedef enum
{
    MysticSliderTypeNormal,
    MysticSliderTypeMini,
    MysticSliderTypeTiny,
    MysticSliderTypePanel,
    MysticSliderTypeTrackless,
    MysticSliderTypeVertical,
    MysticSliderTypeVerticalMinimal,

} MysticSliderType;


@interface MysticSlider : NMRangeSlider2
{
    MysticObjectType _setting;
}
@property (nonatomic, retain) NSTimer *timer, *timer2;
@property (nonatomic, retain) UIColor *minimumTrackTintColor, *maximumTrackTintColor;
@property (nonatomic, assign) float value, proportionMidValue, proportionPointValue;
@property (nonatomic, assign) BOOL preventsRender, onlyTouchControls;
@property(copy, nonatomic) MysticBlockSliderValue valueBlock;

@property (nonatomic, assign) int sliderCalls;
@property (nonatomic, assign) CGSize insetSize;
@property (nonatomic, assign) id imageViewDelegate;
@property (nonatomic, assign) SEL refreshAction, reloadAction, finishAction, stillAction;
@property (nonatomic, assign) MysticObjectType setting;
@property (nonatomic, assign) MysticSliderType sliderType;
@property (nonatomic, assign) PackPotionOption *targetOption;
@property (nonatomic, assign) CGFloat defaultValue;
@property (nonatomic, retain) UIImage *minimumValueImage, *maximumValueImage;
@property (nonatomic, retain) NSMutableDictionary *testFilters;
@property (nonatomic, copy) MysticSliderBlock changeBlock, finishBlock, stillBlock;
@property (nonatomic, assign) MysticSliderState colorState;
@property (nonatomic, assign) UIEdgeInsets thumbInsets, trackInsets;
+ (id) sliderWithFrame:(CGRect)frame;
+ (id) panelSliderWithFrame:(CGRect)frame;
+ (id) sliderWithFrame:(CGRect)frame type:(MysticSliderType)type;

- (id)initWithFrame:(CGRect)frame type:(MysticSliderType)sliderType;
- (void) setSetting:(MysticObjectType)setting animated:(BOOL)animated;
- (void) resetValue:(BOOL)animated;
- (void) setSetting:(MysticObjectType)setting animated:(BOOL)animated setValue:(BOOL)shouldSetValue;

- (void) commonInit;
- (void) resetLastValue:(BOOL)animated finished:(MysticBlockAnimationFinished)finished;
#ifdef DEBUG
- (void) setTestFilter:(id)filter forKey:(id)key;
#endif

- (void) setupActionsForSetting:(MysticObjectType)setting option:(PackPotionOption *)option animated:(BOOL)animated;

- (void) setFinishBlockForSetting:(MysticObjectType)setting option:(PackPotionOption *)option;
- (void) setChangeBlockForSetting:(MysticObjectType)setting option:(PackPotionOption *)option;
- (void) setStillBlockForSetting:(MysticObjectType)setting option:(PackPotionOption *)option;
- (void) resetToDefaultValues;
- (void) resetToDefaultValues:(id)animated finished:(MysticBlockAnimationFinished)finished;
- (void) resetToValue:(float)u animated:(id)animated finished:(MysticBlockAnimationFinished)finished;
- (void) fixValue:(MysticBlockSliderValue)block;
@end

@interface MysticScrollViewSlider : MysticSlider

@end

@interface MysticSliderBrush : MysticSlider
@property (nonatomic, assign) MysticPosition horizontalAlignment;
@property (nonatomic, assign) CGSize originalThumbSize, highlightedThumbSize;
@end
