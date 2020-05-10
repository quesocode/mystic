//
//  ILColorPicker.m
//  ILColorPickerExample
//
//  Created by Jon Gilkison on 9/2/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import "ILColorPickerView.h"
#import "MysticConstants.h"

@interface ILColorPickerView ()

@property (nonatomic, assign) BOOL hasSetColor, hasSetMode;

@end
@implementation ILColorPickerView

@synthesize pickerLayout, showDropper=_showDropper;

#pragma mark - Setup


-(void)setup
{
    [super setup];
    _hasSetMode = NO;
    _mode = ColorPickerModeHueSat;
    self.opaque=NO;
    self.backgroundColor=[UIColor clearColor];
    _threshold = MysticThresholdDefault;
}

-(void)dealloc
{
    [self destroyControls];
    [super dealloc];
}

#pragma mark - Property Set/Get

-(void)setPickerLayout:(ILColorPickerViewLayout)layout
{
    pickerLayout=layout;

    if (satPicker!=nil)
    {
        [satPicker removeFromSuperview];   
        [satPicker release];
        satPicker=nil;
    }
    if (huePicker!=nil)
    {
        [huePicker removeFromSuperview];
        [huePicker release];
        huePicker=nil;
    }
    
    
    
    if (layout==ILColorPickerViewLayoutBottom)
    {
        huePicker=[[ILHuePickerView alloc] initWithFrame:CGRectZero];
        huePicker.pickerOrientation=0;
        huePicker.backgroundColor = self.backgroundColor;
        [huePicker setFrame:CGRectMake(0, self.frame.size.height-kHuePickerHeight, self.frame.size.width, kHuePickerHeight)];
        satPicker=[[ILSaturationBrightnessPickerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-kColorPickerSpacing-kHuePickerHeight)];
        satPicker.backgroundColor = self.backgroundColor;
        satPicker.delegate=self;
        huePicker.delegate=satPicker;
        [self addSubview:satPicker];
        [self addSubview:huePicker];
    }
    else
    {
        huePicker=[[ILHuePickerView alloc] initWithFrame:CGRectZero];
        huePicker.pickerOrientation=1;
        huePicker.backgroundColor = self.backgroundColor;
        [huePicker setFrame:CGRectMake(self.frame.size.width-kHuePickerHeight, 0, kHuePickerHeight, self.frame.size.height)];
        satPicker=[[ILSaturationBrightnessPickerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-kColorPickerSpacing-kHuePickerHeight, self.frame.size.height)];
        satPicker.backgroundColor = self.backgroundColor;
        satPicker.delegate=self;
        huePicker.delegate=satPicker;
        [self addSubview:satPicker];
        [self addSubview:huePicker];
    }

}
- (void) destroyControls;
{
    if(hsbBPicker)        [hsbBPicker release],hsbBPicker=nil;
    if(hsbSPicker)        [hsbSPicker release],hsbSPicker=nil;
    if(hsbHPicker)        [hsbHPicker release],hsbHPicker=nil;
    if(redPicker)         [redPicker release],redPicker=nil;
    if(greenPicker)       [greenPicker release],greenPicker=nil;
    if(bluePicker)        [bluePicker release],bluePicker=nil;
    if(huePicker)         [huePicker release],huePicker=nil;
    if(satPicker)         [satPicker release],satPicker=nil;
    if(tuneThresholdPicker)     [tuneThresholdPicker release],tuneThresholdPicker=nil;
    if(tuneSmoothPicker)   [tuneSmoothPicker release],tuneSmoothPicker=nil;
    if(tuneRangePicker)    [tuneRangePicker release],tuneRangePicker=nil;
}
- (void) setMode:(ColorPickerMode)mode;
{
    _hasSetMode = YES;
    _mode = mode;
    UIColor *newColor = self.hasColor ? [self.color retain] : nil;
    
    BOOL isHSB = mode != ColorPickerModeRGB;
    
    MysticHSB hsb = (MysticHSB){newColor.hsb.hue,newColor.hsb.saturation, newColor.hsb.brightness};
    
    
    for (UIView *v in self.subviews) [v removeFromSuperview];
    [self destroyControls];
    
    CGFloat o = 5;
    CGFloat d = self.frame.origin.x+o;
    CGFloat h = (self.frame.size.height-(d*2))/3;
    d -= o-2;
    
    switch (mode) {
        case ColorPickerModeTone:
        {
            satPicker=[[ILSaturationBrightnessPickerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            satPicker.backgroundColor = self.backgroundColor;
            satPicker.delegate=self;
            [self addSubview:satPicker];
            break;
        }
        case ColorPickerModeHSB:
        {
            hsbSPicker = [[ILHsbSatPickerView alloc] initWithFrame:CGRectMake(0,o,CGRectW(self.frame),h)];
            hsbSPicker.backgroundColor = self.backgroundColor;
            hsbBPicker = [[ILHsbBrightPickerView alloc] initWithFrame:CGRectMake(0,h+d+o,CGRectW(self.frame),h)];
            hsbBPicker.backgroundColor = self.backgroundColor;
            hsbHPicker = [[ILHsbHuePickerView alloc] initWithFrame:CGRectMake(0,h*2+d*2+o,CGRectW(self.frame),h)];
            hsbHPicker.backgroundColor = self.backgroundColor;
            hsbSPicker.delegate=self;
            hsbBPicker.delegate=hsbSPicker;
            hsbHPicker.delegate=hsbBPicker;
            [self addSubview:hsbBPicker];
            [self addSubview:hsbSPicker];
            [self addSubview:hsbHPicker];
            break;
        }
        case ColorPickerModeRGB:
        {
            redPicker = [[ILRedPickerView alloc] initWithFrame:CGRectMake(0,o,CGRectW(self.frame),h)];
            redPicker.backgroundColor = self.backgroundColor;
            greenPicker = [[ILGreenPickerView alloc] initWithFrame:CGRectMake(0,h+d+o,CGRectW(self.frame),h)];
            greenPicker.backgroundColor = self.backgroundColor;
            bluePicker = [[ILBluePickerView alloc] initWithFrame:CGRectMake(0,h*2+d*2+o,CGRectW(self.frame),h)];
            bluePicker.backgroundColor = self.backgroundColor;
            redPicker.delegate=self;
            greenPicker.delegate=self;
            bluePicker.delegate=self;
            [self addSubview:redPicker];
            [self addSubview:greenPicker];
            [self addSubview:bluePicker];
            break;
        }
        case ColorPickerModeTune:
        {
            d = self.frame.origin.x-2;
            h = (self.frame.size.height-(d*2))/3;
            tuneThresholdPicker = [[ILTunePickerView alloc] initWithFrame:CGRectMake(0,o,CGRectW(self.frame),h)];
            tuneThresholdPicker.backgroundColor = self.backgroundColor;
            tuneSmoothPicker = [[ILTunePickerView alloc] initWithFrame:CGRectMake(0,h+d+o,CGRectW(self.frame),h)];
            tuneSmoothPicker.backgroundColor = self.backgroundColor;
            
            tuneAlphaPicker = [[ILTunePickerView alloc] initWithFrame:CGRectMake(0,h*3+d*3+o,CGRectW(self.frame),h)];
//            tuneRangePicker = [[ILTunePickerView alloc] initWithFrame:CGRectMake(0,h*2+d*2+o,CGRectW(self.frame),h)];
//            tuneRangePicker.backgroundColor = self.backgroundColor;
//            tuneRangePicker.frame = CGRectMake(0,0,CGRectW(self.frame),h);
//            tuneThresholdPicker.frame = CGRectMake(0,h+d,CGRectW(self.frame),h);
//            tuneSmoothPicker.frame = CGRectMake(0,h*2+d*2,CGRectW(self.frame),h);
//            tuneAlphaPicker.frame = CGRectMake(0,h*3+d*3,CGRectW(self.frame),h);
            
            tuneThresholdPicker.frame = CGRectMake(0,0,CGRectW(self.frame),h);
            tuneSmoothPicker.frame = CGRectMake(0,h+d,CGRectW(self.frame),h);
            tuneAlphaPicker.frame = CGRectMake(0,h*2+d*2,CGRectW(self.frame),h);
            
            
            tuneAlphaPicker.backgroundColor = self.backgroundColor;
            tuneThresholdPicker.delegate=      self;
            tuneSmoothPicker.delegate=         tuneThresholdPicker;
            tuneRangePicker.delegate=          tuneSmoothPicker;
            tuneAlphaPicker.delegate=          self;
            tuneThresholdPicker.tune=          MysticTuneThreshold;
            tuneRangePicker.tune=              MysticTuneRange;
            tuneSmoothPicker.tune=             MysticTuneSmooth;
            tuneAlphaPicker.tune=              MysticTuneAlpha;
            [self addSubview:tuneThresholdPicker];
            [self addSubview:tuneSmoothPicker];
//            [self addSubview:tuneRangePicker];
            [self addSubview:tuneAlphaPicker];
            self.showDropper =      _showDropper;
            tuneThresholdPicker.rgb = self.color.rgb;
            tuneAlphaPicker.rgb = self.color.rgb;
            tuneSmoothPicker.rgb = self.color.rgb;
            tuneRangePicker.rgb = self.color.rgb;
            tuneThresholdPicker.threshold =     self.threshold;
            tuneSmoothPicker.threshold =   self.threshold;
//            tuneRangePicker.threshold =    self.threshold;
            tuneAlphaPicker.threshold =  self.threshold;
            tuneAlphaPicker.title=@"INTENSITY";
            tuneRangePicker.title=@"RANGE";
            tuneSmoothPicker.title=@"SMOOTH";
            tuneThresholdPicker.title=@"THRESHOLD";
            self.sourceColor=self.sourceColor;
            
            return;
        }
        default: [self setPickerLayout:pickerLayout]; break;
    }
    self.sourceColor=self.sourceColor;
    self.showDropper = _showDropper;
    if(newColor || !_hasSetColor) { self.color = newColor; return; }
    if(self.displayColor) self.displayColor = self.displayColor;
}
- (void) setNeedsDisplay;
{
    if(!_hasSetMode) self.mode = _mode;
    for (ILView *v in self.subviews) {
        if(![v isKindOfClass:[ILView class]]) continue;
        [v setColor:self.color];
        [v setNeedsDisplay];
    }
    [super setNeedsDisplay];
}
- (void) setShowDropper:(BOOL)showDropper;
{
    _showDropper = showDropper;
    for (ILView *v in self.subviews) {
        if(![v isKindOfClass:[ILView class]]) continue;
        v.showDropper=showDropper;
    }
}
- (UIColor *) color; { return super.color; }
-(void)setColor:(UIColor *)newColor;
{
    _hasSetColor=YES;
    [super setColor:newColor];
    if(!self.showDropper && newColor!=nil) self.showDropper = YES;
    for (ILView *v in self.subviews) {
        if(![v isKindOfClass:[ILControl class]]) continue;
        v.color = newColor;
    }
}
-(void)setSourceColor:(UIColor *)newColor;
{
    [super setSourceColor:newColor];
//    if(!self.showDropper && newColor!=nil) self.showDropper = YES;
    for (ILView *v in self.subviews) {
        if(![v respondsToSelector:@selector(setSourceColor:)]) continue;
        v.sourceColor = newColor;
    }
}
- (void) setDisplayColor:(UIColor *)c;
{
    if(_displayColor) [_displayColor release], _displayColor=nil;
    if(c) _displayColor = [c retain];
    for (ILView *v in self.subviews) {
        if(![v isKindOfClass:[ILControl class]]) continue;
        v.color = c;
    }
}
#pragma mark - ILSaturationBrightnessPickerDelegate

-(void)colorPicked:(UIColor *)newColor forPicker:(id)picker
{
    switch(self.mode)
    {
        case ColorPickerModeHSB:
            self.color = [UIColor colorWithHSB:(MysticColorHSB){hsbHPicker.hue,hsbSPicker.sat,hsbBPicker.brightness,1.0}];
            
            break;
        case ColorPickerModeRGB:
            self.color = [UIColor colorWithRGB:(MysticRGB){redPicker.rgb.red,greenPicker.rgb.green,bluePicker.rgb.blue}];
            
            break;
        case ColorPickerModeTone:
        default:
            self.color = newColor;
            
            break;
    }
    [self.delegate colorPicked:self.color forPicker:self];
}
-(void)tunePicked:(MysticThreshold)tune forPicker:(ILTunePickerView *)picker;
{
    MysticThreshold nrgb = tune;
    switch(self.mode)
    {
        case ColorPickerModeTune:
        default: nrgb = (MysticThreshold){tuneRangePicker.threshold.range,tuneThresholdPicker.threshold.threshold,tuneSmoothPicker.threshold.smoothing,tuneAlphaPicker.threshold.intensity}; break;
    }
    [self.delegate tunePicked:nrgb forPicker:picker];

}
-(void)pickerChangedShowDropper:(BOOL)show picker:(id)picker;
{
    self.showDropper = show;
}

- (void)pickerTouchesBegan:(ILControl *)picker touches:(NSSet *)touches withEvent:(UIEvent *)event;
{
    self.touchesEnded = NO;
    if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTouchesBegan:touches:event:)])
        [self.delegate pickerTouchesBegan:picker touches:touches event:event];
}
- (void)pickerTouchesMoved:(ILControl *)picker touches:(NSSet *)touches withEvent:(UIEvent *)event;
{

    if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTouchesMoved:touches:event:)])
        [self.delegate pickerTouchesMoved:picker touches:touches event:event];
}
- (void)pickerTouchesEnded:(ILControl *)picker touches:(NSSet *)touches withEvent:(UIEvent *)event;
{
    self.touchesEnded = YES;

    if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTouchesEnded:touches:event:)])
        [self.delegate pickerTouchesEnded:picker touches:touches event:event];
}
- (void)pickerTouchesCancelled:(ILControl *)picker touches:(NSSet *)touches withEvent:(UIEvent *)event;
{
    self.touchesEnded = YES;

    if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTouchesCancelled:touches:event:)])
        [self.delegate pickerTouchesCancelled:picker touches:touches event:event];
}
@end
