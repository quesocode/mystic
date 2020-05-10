//
//  ILView.h
//
//  Created by Jon Gilkison on 7/30/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+GetHSB.h"
#import "UIColor+Mystic.h"
#import "MysticUtility.h"

typedef enum {
    ILPickerViewOrientationHorizontal,
    ILPickerViewOrientationVertical,
    
} ILPickerViewOrientation;
@protocol ILPickerDelegate <NSObject>

@optional
- (void) colorPicked:(UIColor *)color forPicker:(id)picker;
- (void) tunePicked:(MysticThreshold)tune forPicker:(id)picker;

-(void)pickerChangedShowDropper:(BOOL)show picker:(id)picker;

- (void) pickerTouchesBegan:(id)picker touches:(NSSet *)touches event:(UIEvent *)event;
- (void) pickerTouchesMoved:(id)picker touches:(NSSet *)touches event:(UIEvent *)event;
- (void) pickerTouchesEnded:(id)picker touches:(NSSet *)touches event:(UIEvent *)event;
- (void) pickerTouchesCancelled:(id)picker touches:(NSSet *)touches event:(UIEvent *)event;

@end
/**
 * Base view that handles orientation notification and a setup method that
 * is called regardless of which of the many ways the view was instantiated.
 */
@interface ILView : UIView <ILPickerDelegate> {
    
}
@property (nonatomic, assign) BOOL hasDrawn, touching;

@property (assign, nonatomic) BOOL showDropper;
@property (assign, nonatomic) BOOL hasColor;
@property (assign, nonatomic) IBOutlet id<ILPickerDelegate> delegate;
@property (retain, nonatomic) UIColor *color, *sourceColor;
@property (assign, nonatomic) MysticColorHSB hsb;
@property (nonatomic, assign) MysticRGB rgb;

@property (assign, nonatomic) ILPickerViewOrientation pickerOrientation;

@property (assign, nonatomic) CGPoint touch;
/** 
 * Override in subclasses to do your setup code
 */
-(void)setup;

/**
 * Override in subclasses to handle device orientation changes.
 *
 * @param newOrientation The new device orientation
 */
-(void)deviceDidRotate:(UIDeviceOrientation)newOrientation;

@end

@interface ILControl : ILView {
    
}
@property (nonatomic, assign) UILabel *label;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) MysticAdjustType adjustType;
@property (nonatomic, assign) BOOL hidesColorDropper;
@property (nonatomic, assign) UIGestureRecognizerState gestureState;
-(void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event;


@end