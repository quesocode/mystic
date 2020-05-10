//
//  ILColorPicker.h
//  ILColorPickerExample
//
//  Created by Jon Gilkison on 9/2/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILSaturationBrightnessPickerView.h"
#import "ILHuePickerView.h"
#import "ILHsbHuePickerView.h"
#import "ILHsbSatPickerView.h"
#import "ILHsbBrightPickerView.h"
#import "ILGreenPickerView.h"
#import "ILBluePickerView.h"
#import "ILRedPickerView.h"
#import "ILAlphaPickerView.h"
#import "ILTunePickerView.h"

/**
 * Determines the layout of the color picker
 */
typedef enum {
    
    /// Hue picker is at bottom
    ILColorPickerViewLayoutBottom  =   0,
    
    // Hue picker is at right
    ILColorPickerViewLayoutRight   =   1,
    
} ILColorPickerViewLayout;

typedef enum {
    ColorPickerModeDefault,
    ColorPickerModeHueSat = ColorPickerModeDefault,
    ColorPickerModeRGB,
    ColorPickerModeHSB,
    ColorPickerModeTone,
    ColorPickerModeTune,
    ColorPickerModeTuneThreshold,
    ColorPickerModeTuneIntensity,



} ColorPickerMode;

@class ILColorPickerView;

/**
 * Delegate for the color picker
 */
//@protocol ILColorPickerViewDelegate

/**
 * Called when the user has chosen a new color
 *
 * @param color The new color
 * @param picker The calling picker
 */
//-(void)colorPicked:(UIColor *)color forPicker:(ILColorPickerView *)picker;

//@end

/**
 * Wraps an ILSaturationBrightnessPicker and ILHuePicker into a single
 * convenient control
 */
@interface ILColorPickerView : ILView<ILPickerDelegate> {
    id<ILPickerDelegate> delegate;
    
    ILSaturationBrightnessPickerView *satPicker;
    ILHuePickerView *huePicker;
    
    ILHsbHuePickerView *hsbHPicker;
    ILHsbSatPickerView *hsbSPicker;
    ILHsbBrightPickerView *hsbBPicker;
    
    ILRedPickerView *redPicker;
    ILGreenPickerView *greenPicker;
    ILBluePickerView *bluePicker;
    ILAlphaPickerView *alphaPicker;
    
    ILTunePickerView*tuneThresholdPicker;
    ILTunePickerView*tuneSmoothPicker;
    ILTunePickerView*tuneRangePicker;
    ILTunePickerView*tuneAlphaPicker;
    ILColorPickerViewLayout pickerLayout;
}

/**
 * Delegate
 */
//@property (assign,nonatomic) IBOutlet id<ILPickerDelegate> delegate;
@property (assign, nonatomic) ColorPickerMode mode;
@property (nonatomic, assign) BOOL touchesEnded;
/**
 * The layout of the controls
 */
@property (assign,nonatomic) ILColorPickerViewLayout pickerLayout;

/**
 * Gets/sets the current color
 */
@property (retain,nonatomic) UIColor  *displayColor;
@property (nonatomic, assign) MysticThreshold threshold;
@end
