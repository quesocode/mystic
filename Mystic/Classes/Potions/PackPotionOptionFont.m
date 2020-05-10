//
//  PackPotionOptionFont.m
//  Mystic
//
//  Created by Travis on 8/12/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOptionFont.h"
#import "EffectControl.h"
#import "MysticController.h"
#import "MysticLabelsView.h"
#import "MysticFontStyleViewBasic.h"

@implementation PackPotionOptionFont

@synthesize text=_text, fontFamily=_fontFamily, fontName=_fontName, fontSize=_fontSize, textAlignment=_textAlignment, font=_font, colorIndex, fontIndex, view=_view, fontStyle=_fontStyle, spacing=_spacing, lineHeightScale=_lineHeightScale, lineHeight=_lineHeight;

static CGFloat kMysticDefaultFontSize = MYSTIC_DEFAULT_RESIZE_LABEL_FONTSIZE;
static NSString *kMysticDefaultFontName = @"HelveticaNeue-Bold";

+ (UIFont *) defaultFont;
{
    return [MysticFont defaultTypeFont:MYSTIC_DEFAULT_RESIZE_LABEL_FONTSIZE];
}


+ (id) optionWithName:(NSString *)name info:(NSDictionary *)info;
{
    PackPotionOptionFont *option = [super optionWithName:name info:info];
    option.alignment = MysticAlignPositionCenter;
    option.fontFamily = [info objectForKey:@"fontName"] ? [info objectForKey:@"fontName"] : kMysticDefaultFontName;
    return option;
}

- (void) commonInit;
{
    self.text = MYSTIC_DEFAULT_FONT_TEXT;
}



- (void) dealloc;
{
    [_text release];
    [_fontFamily release];
    [_fontName release];
    [_font release];
    [_attributedString release];
    [super dealloc];
}



- (id) init;
{
    self = [super init];
    if(self)
    {
        _fontSize = kMysticDefaultFontSize;
        _fontStyle = MysticFontStyleNormal;
        _lineHeightScale = NSNotFound;
        fontIndex = NSNotFound;
        colorIndex = NSNotFound;
        _textAlignment = textAlignment(NSTextAlignmentCenter);
        self.fontFamily = kMysticDefaultFontName;
    }
    return self;
}
- (BOOL) canReorder; { return NO; }
- (BOOL) requiresFrameRefresh; { return NO; }
- (void) setHasRendered:(BOOL)hasRendered;
{
    [super setHasRendered:hasRendered];
    if(hasRendered && self.isManager)
    {
        [self.overlaysView removeLayers:nil];
        self.overlaysView.hidden = YES;
        self.view.hidden = YES;

    }
    else
    {
        self.overlaysView.hidden = NO;
        self.view.hidden = NO;

    }

    
    
}
- (void) setAlignment:(MysticAlignPosition)alignment;
{
    [super setAlignment:alignment];
    if(self.view && self.viewLabel)
    {
        CGRect newRect = MysticPositionRect(self.viewLabel.frame, self.view.bounds, MysticPositionFromAlignment(alignment));
        if(!CGRectEqualToRect(self.viewLabel.frame, newRect)) self.viewLabel.frame = newRect;
        
    }
}




- (BOOL) hasValues;
{
    return self.viewLabel != nil;
}

- (NSString *) name;
{
    if(self.view)
    {
        UILabel *vl = self.viewLabel;
        if(vl && [vl respondsToSelector:@selector(text)])
        {
            return self.viewLabel.text;
        }
    }
    return super.name;
}

- (NSString *) layerTitle;
{
    if(self.overlaysView)
    {
        NSString *__name = @"";
        for (MysticFontStyleViewBasic *l in self.overlaysView.overlays) {
            __name = [__name stringByAppendingFormat:@"%@ ", l.text];
        }
        __name = [__name stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        __name = [__name stringByReplacingOccurrencesOfString:@"\r" withString:@" "];

        return [__name capitalizedWordsString];
    }
    return [self.name capitalizedWordsString];
}

- (UIColor *) color;
{
    UIColor *c = _color;
    c = !c && self.colorOption ? self.colorOption.color : c ? c : [UIColor color:MysticColorTypeChoice1];
    c = c && c.alpha <= 0 ? [c colorWithAlphaComponent:1] : c;
    return c && c.alpha > 0 ? c : [UIColor color:MysticColorTypeChoice1];
}

- (void) setColorType:(MysticOptionColorType)optType color:(id)color;
{
    [super setColorType:optType color:color];
    MysticLayerTypeView *label = self.theView ? (id)self.theView : (id)[MysticController controller].labelsView.selectedLayer;

    UIColor *c = [MysticColor color:color];
    if(!color) return;

    if(label && [label respondsToSelector:@selector(setColor:)])
    {
        label.color = c;
        label.backgroundColor = optType == MysticOptionColorTypeForeground && ![self hasAdjusted:MysticSettingBackgroundColor] ? [c colorWithAlphaComponent:0] : (optType != MysticOptionColorTypeForeground ? c : label.backgroundColor);
    }
    [MysticController controller].labelsView.backgroundColor = [c colorWithAlphaComponent:0];
}

- (NSInteger) count;
{
    if(self.overlaysView) return self.overlaysView.overlays.count;
    return [super count];
}


- (UILabel *)viewLabel;
{
    return self.overlaysView && [self.overlaysView selectedLayer] ? [self.overlaysView selectedLayer] : nil;
}
- (BOOL) isActive;
{
    if(self.isActiveAction)
    {
        return self.isActiveAction(self);
    }
    MysticFontStyleViewBasic *label = [self.overlaysView selectedLayer];

    if(label)
    {
        UIFont *selectedFont = label ? label.font : nil;
        if(selectedFont)
        {
            NSString *sFamilyName = [selectedFont.familyName hasPrefix:@".Helvetica"] ? @"Helvetica Neue" : selectedFont.familyName;
            if([sFamilyName isEqualToString:self.font.familyName])
            {

                return YES;
            }
        }
    }
    return NO;
}
- (NSString *) layerSubtitle;
{
    return NSLocalizedString(@"Text", nil);
}
//- (NSString *) layerTitle;
//{
//    return NSLocalizedString(@"Text", nil);
//}
- (PackPotionOptionFont *) fontOption;
{
    return _fontOption ? _fontOption : self;
}
- (UIView *) renderView;
{
    return self.view ? self.view : self.overlaysView;
}
- (UIImage *) icon;
{
    if(_iconImg) return _iconImg;
    UIImage *imgSource = nil;
    if(self.isManager && self.viewImage)
    {
        imgSource = self.viewImage;
    }
    else if(self.view || self.overlaysView)
    {
        imgSource = [MysticImage renderedImageWithBounds:CGSizeMake(100, 100) view:self.renderView finished:nil];
    }
    
    if(imgSource)
    {
        CGRect rect = CGRectMake(0, 0, 100, 100);
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[MysticColor colorWithType:MysticColorTypeLayerIconBackground] setFill];
        CGContextFillRect(context, rect);
        CGRect newrect = rect;
        
        newrect = CGRectInset(rect, rect.size.width*.1, rect.size.height*.1);

        [imgSource drawInRect:CGRectIntegral(newrect) blendMode:kCGBlendModeNormal alpha:1];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        newImage = [UIImage imageWithCGImage:newImage.CGImage scale:newImage.scale orientation:UIImageOrientationUp];
        UIGraphicsEndImageContext();
        _iconImg = [newImage retain];
        return newImage;
    }
    
    return super.icon;
}

- (CGFloat) fontSize;
{
    return self.viewLabel ? [self.viewLabel.font pointSize] : _fontSize;
}
- (void) setFontSize:(CGFloat)value;
{
    _fontSize = value;
    MysticLayerView *label = [self.overlaysView selectedLayer];
    if(label)
    {
        //label.font = [label.font fontWithSize:_fontSize];
//        label.font = [label.font fontWithSize:_fontSize];
//        [label setFontSize:_fontSize];
        [label update];
    }

}

- (void) setTextAlignment:(MysticTextAlignment)value;
{
    _textAlignment = value;
    MysticFontStyleViewBasic *label = [self.overlaysView selectedLayer];

    if(label)
    {
//        label.textAlignment = _textAlignment;
        [label update];
    }
}

- (void) setLineHeightScale:(CGFloat)value;
{
    _lineHeightScale = value;
    MysticLayerView *label = [self.overlaysView selectedLayer];
    
    if(label)
    {
        [label update];
//        label.lineHeightScale = _lineHeightScale;
    }
}

- (void) setTransformRect:(CGRect)transformRect;
{
    [super setTransformRect:transformRect];
}

- (void) setRotation:(float)rotation;
{
    [super setRotation:rotation];
}
- (CGFloat) increment:(MysticToolType)toolType;
{
    switch (toolType)
    {
        case MysticToolTypeRotateClockwise:
        {
            return kRotateStepIncrement;
        }
        case MysticToolTypeRotateCounterClockwise:
        {
            return -1*kRotateStepIncrement;
        }
        case MysticToolTypeRotateRight:
        {
            return 0.01;
        }
        case MysticToolTypeRotateLeft:
        {
            return -0.01;
        }
        case MysticToolTypeSizeBigger:
        {
            return kSizeStepIncrement;
        }
        case MysticToolTypeSizeSmaller:
        {
            
            return kSizeStepIncrement * -1;
            
        }
        case MysticToolTypePanLeft:
        {
            return -1.0;
            
        }
        case MysticToolTypePanRight:
        {
            return 1.0;
            
        }
        case MysticToolTypeMoveUp:
        case MysticToolTypePanUp:
        {
            return -1.0;
            
        }
        case MysticToolTypeMoveDown:
        case MysticToolTypePanDown:
        {
            return 1.0;
        }
            
        default: break;
    }
    return 0;
}
- (void) valueChanged:(MysticToolType)toolType change:(NSNumber *)amount;
{
    CGFloat floatAmount = 0;
    MysticFontStyleViewBasic *selectedView = self.overlaysView ? [self.overlaysView selectedLayer] : nil;
    if(!selectedView) return;
//    CGRect rect = selectedView.frame;
    CGPoint center = selectedView.center;
//    CGRect superrect = self.view.frame;
//    CGFloat increment = [self increment:toolType];
    switch (toolType)
    {
        case MysticToolTypeRotateRight:
        {
            [selectedView changeRotation:[amount floatValue]];

            break;
        }
        case MysticToolTypeRotateLeft:
        {
            [selectedView changeRotation:[amount floatValue]];

            break;
        }
        case MysticToolTypeSizeBigger:
        {
            floatAmount = [amount floatValue];

//            DLog(@"MysticToolTypeSizeBigger: %2.3f -> %2.3f", floatAmount, increment);

//            selectedView.transform = CGAffineTransformConcat(selectedView.transform, CGAffineTransformMakeScale(self.transformRect.size.width, self.transformRect.size.height));
            
            [selectedView transformSize:floatAmount];
            
            break;
        }
        case MysticToolTypeSizeSmaller:
        {
            floatAmount = [amount floatValue];

            
//            DLog(@"MysticToolTypeSizeSmaller: %2.3f -> %2.3f", floatAmount, increment);

            [selectedView transformSize:floatAmount];

//            rect.size.width += superrect.size.height * floatAmount;
            
//            selectedView.transform = CGAffineTransformConcat(selectedView.transform, CGAffineTransformMakeScale(self.transformRect.size.width, self.transformRect.size.height));

            
            break;
        }
        case MysticToolTypePanLeft:
        {
            floatAmount = [amount floatValue];
//            floatAmount = superrect.size.width*floatAmount;

//            selectedView.transform = CGAffineTransformConcat(selectedView.transform, CGAffineTransformMakeTranslation(floatAmount, 0));
            center.x += floatAmount;
            selectedView.center = center;

            break;
        }
        case MysticToolTypePanRight:
        {
            floatAmount = [amount floatValue];
//            floatAmount = superrect.size.width*floatAmount;

            center.x += floatAmount;
            selectedView.center = center;

//            selectedView.transform = CGAffineTransformConcat(selectedView.transform, CGAffineTransformMakeTranslation(floatAmount, 0));
            break;
        }
        case MysticToolTypePanUp:
        {
            floatAmount = [amount floatValue];
            
            center.y += floatAmount;
            selectedView.center = center;

//            selectedView.transform = CGAffineTransformConcat(selectedView.transform, CGAffineTransformMakeTranslation(0, floatAmount));
            break;
        }
        case MysticToolTypePanDown:
        {
            floatAmount = [amount floatValue];
            
            center.y += floatAmount;
            selectedView.center = center;
            break;
        }
            
        default: break;
    }
}


- (void) confirmCancel;
{
    if(self.view)
    {
        [self.overlaysView disableOverlays];
        [self.overlaysView hideGrid:nil];
        [self.overlaysView removeOverlays];
    }
    [super confirmCancel];
}


- (MysticFilterType) filterType;
{
    return MysticFilterTypeBlendAlphaMix;
}
- (UILabel *) label;
{
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0f, 320.0f)];
    timeLabel.font = [UIFont fontWithName:self.fontFamily size:self.fontSize];
    timeLabel.text = self.text;
    timeLabel.textAlignment = self.textAlignment;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = self.color;
    timeLabel.adjustsFontSizeToFitWidth = true;
    timeLabel.numberOfLines = 10;
    
    return [timeLabel autorelease];
}

- (UIFont *) font;
{
    return _font ? [_font fontWithSize:self.fontSize] : [UIFont fontWithName:self.fontOption.fontFamily size:self.fontSize];
}

- (void) thumbnail:(EffectControl *)control effect:(MysticControlObject *)effect;
{
    control.titleLabel.frame = control.imageView.frame;
    control.titleLabel.text = @"Abc";
    control.titleLabel.font=[UIFont fontWithName:self.fontFamily size:20];
    control.titleLabel.textColor = [UIColor whiteColor];
    control.titleLabel.textAlignment = NSTextAlignmentCenter;
    control.titleLabel.backgroundColor = [UIColor clearColor];
    control.titleLabel.shadowColor = nil;
    control.titleLabel.shadowOffset = CGSizeZero;
}

- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
{
    control.backgroundView.backgroundColor = [MysticColor colorWithType:(isSelected ?MysticColorTypeControlActive : MysticColorTypeControlInactive)];
    control.titleLabel.textAlignment = NSTextAlignmentCenter;
    control.titleLabel.frame = control.imageView.frame;
    control.titleLabel.font=[UIFont fontWithName:self.fontFamily size:20];
    control.titleLabel.textColor = [UIColor whiteColor];
    control.titleLabel.shadowColor = nil;
    control.titleLabel.shadowOffset = CGSizeZero;
}

- (void) prepareControlForReuse:(EffectControl *)control;
{
    control.alpha = 1.0f;
}
- (void) enableControl:(EffectControl *)control;
{
    if(control.isEnabled)
    {
        control.alpha = 1.0f;
    }
    else
    {
        control.alpha = 0.5f;
    }
}






@end
