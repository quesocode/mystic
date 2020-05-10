//
//  MysticFontStyleLabelView.m
//  Mystic
//
//  Created by Me on 3/9/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import "Mystic.h"
#import "MysticFontStyleLabelView.h"

@implementation MysticFontStyleLabelView

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
    self.text = @"";
    self.minimumScaleFactor = 0.00;
    self.lineHeightScale = MYSTIC_DEFAULT_RESIZE_LABEL_LINEHEIGHT_SCALE;
    self.fixedLineHeight = 0.00;
    self.fdLineScaleBaseLine = FDLineHeightScaleBaseLineCenter;
    self.fdAutoFitMode = FDAutoFitModeAutoHeight;
    self.fdLabelFitAlignment = FDLabelFitAlignmentCenter;
    self.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    
//    self.debug = YES;
    self.debugShowLineBreaks = NO;
    self.debugShowCoordinates = NO;
    self.debugShowFrameBounds = YES;
    self.debugShowFrameCenter = NO;
    self.debugShowPaddings = NO;
    self.debugFrameBorderWidth = MYSTIC_UI_RESIZABLE_CONTROL_BORDER;
    self.debugFrameBorderColor = [UIColor color:MysticColorTypePink];
    
}

- (void) setTextAlignment:(NSTextAlignment)textAlignment;
{
    
    [super setTextAlignment:textAlignmentValue(textAlignment)];
    FDTextAlignment fdta = FDTextAlignmentCenter;
    switch ((MysticTextAlignment)textAlignment) {
        case MysticTextAlignmentCenter:
        case NSTextAlignmentCenter:
            
            fdta = FDTextAlignmentCenter;
            break;
        case MysticTextAlignmentLeft:
        case NSTextAlignmentLeft:
            
            fdta = FDTextAlignmentLeft;
            break;
        case MysticTextAlignmentRight:
        case NSTextAlignmentRight:
            
            fdta = FDTextAlignmentRight;
            break;
            
        case MysticTextAlignmentJustified:
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
