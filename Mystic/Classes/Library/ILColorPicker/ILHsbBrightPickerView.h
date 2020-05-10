//
//  ILHsbBrightPickerView.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/1/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "ILView.h"
#import "UIColor+GetHSB.h"
#import "MysticColor.h"




@class ILHsbBrightPickerView;

/**
 * Hue picker delegate
 */
@protocol ILHsbBPickerViewDelegate <ILPickerDelegate>

/**
 * Called when the user picks a new hue
 *
 * @param hue 0..1 The hue the user picked
 * @param picker The picker used
 */
-(void)hsbBrightPicked:(UIColor*)color picker:(ILHsbBrightPickerView *)picker;
-(void)pickerChangedShowDropper:(BOOL)show picker:(id)picker;

@end

@interface ILHsbBrightPickerView : ILControl <ILPickerDelegate>
{
    //    id<ILHsbSatPickerViewDelegate> delegate;
    //    float sat;
    //    ILHsbSatPickerViewOrientation pickerOrientation;
}

/**
 * Delegate
 */
//@property (assign, nonatomic) IBOutlet id<ILPickerDelegate> delegate;

/**
 * The current hue
 */
@property (assign, nonatomic) float brightness;

/**
 * The current color
 */

/**
 * Orientation
 */




@end
