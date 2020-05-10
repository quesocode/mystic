//
//  MysticResizableLabel.m
//  Mystic
//
//  Created by Me on 3/7/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import "Mystic.h"
#import "MysticResizeableLabel.h"

@implementation MysticResizeableLabel

@synthesize selected=_selected, delegate=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void) commonInit;
{
    self.font = [PackPotionOptionFont defaultFont];
    self.textColor = [UIColor whiteColor];
    self.textAlignment = MYSTIC_DEFAULT_RESIZE_LABEL_TEXTALIGN;
    self.numberOfLines = 0;
    self.text = MysticDefaultFontText;
    self.minimumScaleFactor = 1;
    self.lineHeightScale = MYSTIC_DEFAULT_RESIZE_LABEL_LINEHEIGHT_SCALE;
    self.fixedLineHeight = 0.00;
    self.fdLineScaleBaseLine = FDLineHeightScaleBaseLineCenter;
    self.fdAutoFitMode = FDAutoFitModeAutoHeight;
    self.fdLabelFitAlignment = FDLabelFitAlignmentCenter;
    self.contentInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    
    
    self.debugShowLineBreaks = YES;
    self.debugShowCoordinates = NO;
    self.debugShowFrameBounds = YES;
    self.debugShowFrameCenter = NO;
    self.debugShowPaddings = NO;
    self.debugFrameBorderWidth = MYSTIC_UI_RESIZABLE_CONTROL_BORDER;
    self.debugFrameBorderColor = [UIColor color:MysticColorTypePink];
    
}

- (void) update;
{
    
}

- (void) setTextAlignment:(NSTextAlignment)textAlignment;
{
    [super setTextAlignment:textAlignment];
    FDTextAlignment fdta = FDTextAlignmentCenter;
    switch ((MysticTextAlignment)textAlignment) {
        case NSTextAlignmentCenter:

            fdta = FDTextAlignmentCenter;
            break;
        case NSTextAlignmentLeft:

            fdta = FDTextAlignmentLeft;
            break;
        case NSTextAlignmentRight:

            fdta = FDTextAlignmentRight;
            break;
        case NSTextAlignmentJustified:
            fdta = FDTextAlignmentJustify;
            break;
            
        case MysticTextAlignmentFill:
            fdta = FDTextAlignmentFill;
            break;
            
        default: break;
    }
    self.fdTextAlignment = fdta;
}

- (void) setEnabled:(BOOL)enabled;
{
    if(self.selected && !enabled) [self setSelected:enabled notify:NO];
    [super setEnabled:enabled];

}

- (BOOL) selected; { return self.debug; }
- (void) setSelected:(BOOL)v { [self setSelected:v notify:YES]; }
- (void) setSelected:(BOOL)v notify:(BOOL)shouldNotify;
{
    if(!self.enabled) return;
    self.debug = v;
    if(shouldNotify && [_delegate respondsToSelector:@selector(layerViewDidSelect:)]) {
        [_delegate layerViewDidSelect:(id)self];
    }
}

- (void) changeRotation:(CGFloat)change;
{

}

- (void) transformSize:(CGFloat)amount;
{
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if([_delegate respondsToSelector:@selector(layerViewDidBeginMoving:)]) {
        [_delegate layerViewDidBeginMoving:(id)self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if([_delegate respondsToSelector:@selector(layerViewDidEndMoving:)]) {
        [_delegate layerViewDidEndMoving:(id)self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if([_delegate respondsToSelector:@selector(layerViewDidCancelMoving:)]) {
        [_delegate layerViewDidCancelMoving:(id)self];
    }
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if(self.selected && [_delegate respondsToSelector:@selector(layerViewDidMove:)]) {
        [_delegate layerViewDidMove:(id)self];
    }
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
