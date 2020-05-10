//
//  ILView.m
//
//  Created by Jon Gilkison on 7/30/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import "ILView.h"

@interface ILView(Private)

-(void)deviceRotated:(NSNotification *)notification;
-(void)forceStartupOrientation;

@end

@implementation ILView

@synthesize pickerOrientation=pickerOrientation, showDropper=_showDropper;

#pragma mark - Initialization/Deallocation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

-(void)setup
{
    self.hasColor = NO;
    self.showDropper = YES;
    self.clipsToBounds=YES;
    self.opaque=NO;
    self.backgroundColor=[UIColor clearColor];
    _hasDrawn=NO;
    pickerOrientation=0;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRotated:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // trigger the orientation change after the app has time to init
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(forceStartupOrientation) userInfo:nil repeats:NO];
}
-(void)setPickerOrientation:(ILPickerViewOrientation)po
{
    pickerOrientation=po;
    [self setNeedsDisplay];
}
-(void)setColor:(UIColor *)cc
{
    self.hasColor = cc != nil;
    if(_color) [_color release], _color=nil;
    _color = cc ? [cc retain] : nil;
//    int i = [NSStringFromClass([self class]) containsString:@"Red"] ? 1 : -1;
//    i = i!=-1 ? i : [NSStringFromClass([self class]) containsString:@"Green"] ? 2 : -1;
//    i = i!=-1 ? i : [NSStringFromClass([self class]) containsString:@"Blue"] ? 3 : -1;

}
- (void) setSourceColor:(UIColor *)sourceColor;
{
    if(_sourceColor) [_sourceColor release], _sourceColor=nil;
    _sourceColor = sourceColor ? [sourceColor retain] : nil;
    [self setNeedsDisplay];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(_color) [_color release];
    if(_sourceColor) [_sourceColor release];
    [super dealloc];
}
- (BOOL) showDropper;
{
    if(self.superview && !self.superview.userInteractionEnabled) return NO;
    return _showDropper;
}
- (void) setShowDropper:(BOOL)value;
{
    BOOL c = _showDropper!=value;
    _showDropper = value;
    
    if(self.delegate && c && value) [self.delegate pickerChangedShowDropper:value picker:self];
    _hasDrawn = NO; [self setNeedsDisplay];
}
- (void) colorPicked:(UIColor *)cc forPicker:(id)picker;
{
    [self.delegate colorPicked:cc forPicker:picker ? picker : self];
}
- (void) tunePicked:(MysticThreshold)tune forPicker:(id)picker;
{
    [self.delegate tunePicked:tune forPicker:picker ? picker : self];
}
-(void)pickerChangedShowDropper:(BOOL)show picker:(id)picker;
{
    
}
#pragma mark - Orientation

-(void)deviceDidRotate:(UIDeviceOrientation)newOrientation
{
    
}

-(void)deviceRotated:(NSNotification *)notification
{
    [self deviceDidRotate:[[UIDevice currentDevice] orientation]];
}

-(void)forceStartupOrientation
{
    [self deviceDidRotate:[UIApplication sharedApplication].statusBarOrientation];
}
- (void) drawRect:(CGRect)rect;
{
    _hasDrawn = YES;
}
- (void) setNeedsDisplay;
{
    if((!self.showDropper && self.hasDrawn)) return;
    [super setNeedsDisplay];
}


- (void)pickerTouchesBegan:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTouchesBegan:touches:event:)])
    [self.delegate pickerTouchesBegan:picker touches:touches event:event];
}
- (void)pickerTouchesMoved:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTouchesMoved:touches:event:)])
    [self.delegate pickerTouchesMoved:picker touches:touches event:event];
}
- (void)pickerTouchesEnded:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTouchesEnded:touches:event:)])
    [self.delegate pickerTouchesEnded:picker touches:touches event:event];
}
- (void)pickerTouchesCancelled:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTouchesCancelled:touches:event:)])
    [self.delegate pickerTouchesCancelled:picker touches:touches event:event];
}


@end

@implementation ILControl
- (void) dealloc;
{
    self.label = nil;
    [super dealloc];
}
- (void) setup;
{
    [super setup];
    _hidesColorDropper=NO;
    _adjustType = MysticAdjustTypeUnknown;
}
- (void) setTitle:(NSString *)title;
{
    MysticAttrString *titleStr = [MysticAttrString string:title style:MysticStringStyleInputPickerLabel];
    if(!self.label)
    {
        self.label = [[[UILabel alloc] initWithFrame:self.bounds] autorelease];
        self.label.textAlignment=NSTextAlignmentCenter;
        [self addSubview:self.label];
    }
    self.label.attributedText=titleStr.attrString;
}
- (NSString *) title; { return self.label.attributedText.string; }


-(void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event;
{
    self.touch=[[touches anyObject] locationInView:self];

}


- (void)pickerTouchesBegan:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
   // if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTouchesBegan:touches:event:)])
        [self.delegate pickerTouchesBegan:picker touches:touches event:event];
}
- (void)pickerTouchesMoved:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    
   // if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTouchesMoved:touches:event:)])
        [self.delegate pickerTouchesMoved:picker touches:touches event:event];
}
- (void)pickerTouchesEnded:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
   // if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTouchesEnded:touches:event:)])
        [self.delegate pickerTouchesEnded:picker touches:touches event:event];
}
- (void)pickerTouchesCancelled:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTouchesCancelled:touches:event:)])
        [self.delegate pickerTouchesCancelled:picker touches:touches event:event];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.gestureState = UIGestureRecognizerStateBegan;
    self.touching=YES;
    self.adjustType=MysticAdjustTypeUnknown;
    self.showDropper=YES;
    [self.delegate pickerTouchesBegan:self touches:touches event:event];

    [self handleTouches:touches withEvent:event];

    //if([self.delegate respondsToSelector:@selector(pickerTouchesBegan:touches:event:)])
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.gestureState = UIGestureRecognizerStateChanged;
    [self.delegate pickerTouchesMoved:self touches:touches event:event];

    [self handleTouches:touches withEvent:event];

    //if([self.delegate respondsToSelector:@selector(pickerTouchesMoved:touches:event:)])
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.gestureState = UIGestureRecognizerStateEnded;
    [self.delegate pickerTouchesEnded:self touches:touches event:event];


    [self handleTouches:touches withEvent:event];

    //if([self.delegate respondsToSelector:@selector(pickerTouchesEnded:touches:event:)])
    self.touching=NO;

}
- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    self.gestureState = UIGestureRecognizerStateCancelled;

    self.touching=NO;
    if([self.delegate respondsToSelector:@selector(pickerTouchesCancelled:touches:event:)])
    [self.delegate pickerTouchesCancelled:self touches:touches event:event];
}
@end
