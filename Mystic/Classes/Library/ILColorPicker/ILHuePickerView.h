//
//  ILHuePicker.h
//
//  Created by Jon Gilkison on 9/1/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILView.h"
#import "UIColor+GetHSB.h"
#import "MysticColor.h"
/**
 * Controls the orientation of the picker
 */

@class ILHuePickerView;

/**
 * Hue picker delegate
 */
@protocol ILHuePickerViewDelegate

/**
 * Called when the user picks a new hue
 *
 * @param hue 0..1 The hue the user picked
 * @param picker The picker used
 */
-(void)huePicked:(float)hue picker:(ILHuePickerView *)picker;

-(void)pickerChangedShowDropper:(BOOL)show picker:(id)picker;

@end

/**
 * Displays a gradient allowing the user to select a hue
 */
@interface ILHuePickerView : ILControl {
    float hue;
}

/**
 * Delegate
 */
//@property (assign, nonatomic) IBOutlet id<ILPickerDelegate> delegate;

/**
 * The current hue
 */
@property (assign, nonatomic) float hue;

/**
 * The current color
 */

/**
 * Orientation
 */


@end
