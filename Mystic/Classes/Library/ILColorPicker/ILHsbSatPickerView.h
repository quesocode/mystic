//
//  ILHsbSatPickerView.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/1/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "UIColor+GetHSB.h"
#import "MysticColor.h"
#import "ILRGBPickerView.h"



@class ILHsbSatPickerView;

/**
 * Hue picker delegate
 */


@interface ILHsbSatPickerView : ILHSBPickerView <ILPickerDelegate>
{
//    id<ILHsbSatPickerViewDelegate> delegate;
//    float sat;
//    ILHsbSatPickerViewOrientation pickerOrientation;
}

/**
 * Delegate
 */

/**
 * The current hue
 */
@property (assign, nonatomic) float sat;

/**
 * The current color
 */


/**
 * Orientation
 */



@end
