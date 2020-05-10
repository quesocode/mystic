//
//  MysticResizeableLabelOld.m
//  MysticResizableLabel
//
//  Created by travis weerts on 8/15/13.
//  Copyright (c) 2213 Mystic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MysticResizeableLabelOld.h"
#import "GCPlaceholderTextView.h"
#import "Mystic.h"
#import "PackPotionOption.h"
#import "MysticResizeableLayerBorderView.h"


@interface MysticResizeableLabelOld () <UITextFieldDelegate>
{
    CGFloat lastAngle, ratio, labelRatio;
    CGPoint mcenterPoint;
    UITextView *activeTarget, *textView;
    BOOL ignoreSingleTap;
    BOOL needsReset;
    BOOL wasSelected, wasMoving;


    
}
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGSize size;
@property (nonatomic) float deltaAngle;
@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGAffineTransform startTransform;
@property (nonatomic) CGPoint touchStart;

@end



@implementation MysticResizeableLabelOld

@synthesize text, lineBreakMode, label, insets, font, defaultText, editedBlock, editingBlock, movedBlock, selectBlock, singleTapBlock, doubleTapBlock, longPressBlock, deleteBlock, customTapBlock, keyboardWillShowBlock, keyboardWillHideBlock, borderView;
@synthesize touchStart;
@synthesize prevPoint, rotationSnapping;
@synthesize deltaAngle, startTransform; //rotation
@synthesize resizingControl, deleteControl, customControl;
@synthesize preventsPositionOutsideSuperview;
@synthesize preventsResizing;
@synthesize preventsDeleting;
@synthesize preventsCustomButton;
@synthesize selected=_selected, enabled=_enabled, normalFrame, contentScale=_contentScale, controlSize=_controlSize;
- (id)initWithFrame:(CGRect)frame scale:(CGFloat)scale;
{
    return [self initWithFrame:frame contentFrame:CGRectZero scale:scale];
}
- (id)initWithFrame:(CGRect)frame contentFrame:(CGRect)contentFrame scale:(CGFloat)scale;
{
    _contentFrame = contentFrame;
    _globalInset = UIEdgeInsetsMakeFrom(kSPUserResizableViewGlobalInset*scale);
    _contentScale = CGScaleWith(scale);
    _controlSize = (CGSize){kMYSTICLABELControlSize, kMYSTICLABELControlSize};
    _contentInset = UIEdgeInsetsMakeFrom(kMYSTICLABELInsetSize*scale);
    _actualFrame = frame;
    _borderWidth = MYSTIC_UI_LAYER_BORDER*scale;
    _borderInset = UIEdgeInsetsMake( kSPUserResizableViewBorderInset_Y*scale, kSPUserResizableViewBorderInset_X*scale, kSPUserResizableViewBorderInset_Y*scale,kSPUserResizableViewBorderInset_X*scale);
    CGSize csize = _controlSize;
    csize.width = csize.width*_contentScale.x;
    csize.height = csize.height*_contentScale.y;
    _controlSize = csize;
    
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    _globalInset = UIEdgeInsetsMakeFrom(kSPUserResizableViewGlobalInset);
    _borderInset = UIEdgeInsetsMake( kSPUserResizableViewBorderInset_Y, kSPUserResizableViewBorderInset_X, kSPUserResizableViewBorderInset_Y,kSPUserResizableViewBorderInset_X);
    _contentInset = UIEdgeInsetsMakeFrom(kMYSTICLABELInsetSize);

    _contentScale = CGScaleWith(1);
    _controlSize = (CGSize){kMYSTICLABELControlSize, kMYSTICLABELControlSize};
    _actualFrame = frame;
    
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    _globalInset = UIEdgeInsetsMakeFrom(kSPUserResizableViewGlobalInset);
    _borderInset = UIEdgeInsetsMake( kSPUserResizableViewBorderInset_Y, kSPUserResizableViewBorderInset_X, kSPUserResizableViewBorderInset_Y,kSPUserResizableViewBorderInset_X);
    _contentInset = UIEdgeInsetsMakeFrom(kMYSTICLABELInsetSize);
    _contentScale = CGScaleEqual;
    _controlSize = (CGSize){kMYSTICLABELControlSize, kMYSTICLABELControlSize};
    
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
        _actualFrame = self.frame;

    }
    return self;
}

- (void) commonInit;
{
    
}
- (void) redraw:(BOOL)layout;
{
    
}
- (void) finishedImageCapture:(CGSize)renderSize scale:(CGScale)scale;
{
    
}
- (void) prepareForImageCapture:(CGSize)renderSize scale:(CGScale)scale finished:(MysticBlock)finished;
{
    
}
- (void) updateWithEffect:(MysticLayerEffect)effect;
{
    _effect = effect;
}

- (CGFloat) fontSize; { return self.label.fontSize; }
- (NSString *) text; { return self.label.text; }
- (void) setText:(NSString *)value; {  self.label.text = value; [self.label setFontSizeThatFits]; [self resizeLabelWithText:value]; [self.label setFontSizeThatFits];}
- (void) setLabelFrame:(CGRect)frame;
{
    self.labelNormalFrame = [MysticUI normalRect:frame bounds:self.bounds];
    self.label.frame = frame;
}

- (void) resizeLabelWithText:(NSString *)theText {
    CGRect frame = self.label.frame;
    CGSize size = [theText sizeWithFont:self.label.font
                  constrainedToSize:CGSizeMake(frame.size.width, 9999)
                      lineBreakMode:self.label.lineBreakMode];
    
//    size.height = hackHeight;
    //size.height = size.height > hackHeight ? hackHeight : size.height;
    frame.size.height = size.height+0;
    frame.size.width = size.width < frame.size.width ? size.width+0 : frame.size.width;
    [self.label resetFrame:frame];
    labelRatio = frame.size.height/frame.size.width;
    [self sizeToFitLabel];
    
    frame.origin.x = _globalInset.left + MYSTIC_UI_LAYER_BORDER_SIZE/2 + _contentInset.left;
    frame.origin.y = _globalInset.top + MYSTIC_UI_LAYER_BORDER_SIZE/2 + _contentInset.top;
    [self setLabelFrame:frame];
    [self resizeScaledLabel:1.0];
    self.labelNormalFrame = [MysticUI normalRect:self.label.frame bounds:self.bounds];
}
- (void) refreshLabel:(CGFloat)scale;
{
    [self resizeScaledLabel:scale];
    
    NSString *theText = self.text;
    self.label.text = theText; [self.label setFontSizeThatFits];
    CGRect frame = self.label.frame;
    
    labelRatio = frame.size.height/frame.size.width;
    [self sizeToFitLabel];
    
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
    
}

- (void) refreshLabelAfterRotate:(CGFloat)scale;
{
    
    [self.label setFontSizeThatFits];
    [self resizeScaledLabel:1.0];
    [self.label setFontSizeThatFits];
    [self setSafeText:self.text preserveWidth:YES saveDelta:NO scaleUp:NO];
   
    
    
    CGRect labelRect = self.label.bounds;
    if(CGRectEqualToRect(CGRectZero, labelRect)) return;
    if(!labelRatio)
    {
        labelRatio = labelRect.size.width > labelRect.size.height ? labelRect.size.height/labelRect.size.width : labelRect.size.width/labelRect.size.height;
    }

    self.labelNormalFrame = [MysticUI normalRect:self.label.frame bounds:self.bounds];
    
    [self setNeedsDisplay];
    
    
    
    
    

}
- (void) resizeScaledLabel:(CGFloat)scale;
{
    CGRect scaledRect = self.label.frame;
    scaledRect.size.height = scaledRect.size.height*scale;
    scaledRect.size.width = scaledRect.size.width*scale;
    self.label.enlargedSize = scaledRect.size;
    
}

- (CGRect) resizeControlFrame;
{
    CGFloat bx = borderView.frame.origin.x + borderView.innerRect.origin.x;
    CGFloat by = borderView.frame.origin.y + borderView.innerRect.origin.y;
    
    CGFloat bw = bx + borderView.innerRect.size.width -1;
    CGFloat bh = by + borderView.innerRect.size.height - 1;
    
    return CGRectMake(-kMYSTICLABELControlInset_X + bw - (_controlSize.width/2),
                      -kMYSTICLABELControlInset_Y + bh - (_controlSize.height/2),
                      _controlSize.width, _controlSize.height);
}


- (CGRect) deleteControlFrame;
{
    CGFloat bx = borderView.frame.origin.x + borderView.innerRect.origin.x;
    CGFloat by = borderView.frame.origin.y + borderView.innerRect.origin.y + 1;
    return CGRectMake(kMYSTICLABELControlInset_X + bx - (_controlSize.width/2),
                                    kMYSTICLABELControlInset_Y + by - (_controlSize.height/2),
                                    _controlSize.width, _controlSize.height);
}

- (void) setContentScale:(CGScale)contentScale;
{
    self.borderView.borderWidth = ceilf((self.borderView.borderWidth/_contentScale.x) * contentScale.x);
    _borderWidth = self.borderView.borderWidth;
    _globalInset = UIEdgeInsetsRescale(_globalInset, _contentScale, contentScale);
    _contentInset = _globalInset;
    _borderInset = UIEdgeInsetsRescale(_borderInset, _contentScale, contentScale);

    
    CGSize csize = self.controlSize;
    csize.width = csize.width/_contentScale.x;
    csize.height = csize.height/_contentScale.y;
    csize.width = csize.width*contentScale.x;
    csize.height = csize.height*contentScale.y;
    _controlSize = csize;
    _contentScale = contentScale;
    

    
    
    CGRect customFrame = CGRectMake(self.frame.size.width-_controlSize.width,
                                    0,
                                    _controlSize.width, _controlSize.height);
    
    resizingControl.frame = [self resizeControlFrame];
    deleteControl.frame = [self deleteControlFrame];
    customControl.frame = customFrame;
    
    
    CGRect nLabelFrame = CGRectInset(UIEdgeInsetsInsetRect(self.bounds, _globalInset), MYSTIC_UI_LAYER_BORDER_SIZE/2, MYSTIC_UI_LAYER_BORDER_SIZE/2);
    
    
    
    borderView.frame = CGRectIntegral(CGRectInset(UIEdgeInsetsInsetRect(self.bounds, _borderInset),
                                   self.borderWidth,
                                   self.borderWidth));
    [borderView setNeedsDisplay];

    [self setNeedsDisplay];
}

- (CGRect) outerFrame;
{
    return self.bounds;
}
- (void) sizeToFitLabel;
{
    CGRect labelRect = self.label.bounds;
    
    if(!self.label || CGRectEqualToRect(CGRectZero, labelRect)) return;
    if(!labelRatio)
    {
        labelRatio = labelRect.size.width > labelRect.size.height ? labelRect.size.height/labelRect.size.width : labelRect.size.width/labelRect.size.height;
    }
    
    
    CGRect outerRect = labelRect;
    outerRect.size.height += (_globalInset.top+_globalInset.bottom) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.top + _contentInset.bottom);
    outerRect.size.width += (_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.left+_contentInset.right);
    
    
    
    self.size = outerRect.size;
    
    [super setCenter:mcenterPoint];
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
    self.labelNormalFrame = [MysticUI normalRect:self.label.frame bounds:self.bounds];
    return;

}
- (void)setFrame:(CGRect)newFrame {
//    FLog(@"set layer view frame", newFrame);
    
    ratio = newFrame.size.width > newFrame.size.height ? newFrame.size.height/newFrame.size.width : newFrame.size.width/newFrame.size.height;
    [super setFrame:newFrame];
    if(CGPointEqualToPoint(mcenterPoint, CGPointZero)) mcenterPoint = self.center;
    [self sizeToFitLabel];
//    [self layoutControls];

}

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self sizeToFitLabel];
}
- (void) loadView;
{
    
}
- (void) setCenter:(CGPoint)center
{
    mcenterPoint = center;
    super.center = center;
}
- (void) setSize:(CGSize)newSize;
{

    
    CGRect labelRect = self.label.frame;
    labelRect.size.width = newSize.width-((_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.top + _contentInset.bottom));
    labelRect.size.height = labelRect.size.width * labelRatio;
    
    labelRect.origin.x = newSize.width/2 - labelRect.size.width/2;
    labelRect.origin.y = newSize.height/2 - labelRect.size.height/2;
    
    
    [self setLabelFrame:labelRect];
    CGRect b = self.bounds;
    b.size = newSize;
    [super setBounds:b];
    
    [self layoutControls];    
    ratio = self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height/self.bounds.size.width : self.bounds.size.width/self.bounds.size.height;
    self.labelNormalFrame = [MysticUI normalRect:self.label.frame bounds:self.bounds];
}

- (void) layoutControls;
{
    borderView.frame = CGRectIntegral(CGRectInset(UIEdgeInsetsInsetRect(self.bounds, _borderInset),
                                   self.borderWidth,
                                   self.borderWidth));
    resizingControl.frame = [self resizeControlFrame];
    if(deleteControl) deleteControl.frame = [self deleteControlFrame];
    customControl.frame =CGRectMake(self.bounds.size.width - 2,
                                    2,
                                    _controlSize.width,
                                    _controlSize.height);
    [borderView setNeedsDisplay];
 
    
    [self setNeedsDisplay];
}
- (BOOL) isDefault;
{
    return [self.text isEqualToString:MysticDefaultFontText];
}

- (void) resetLabel;
{
    NSString *str = [self.label longestLineOfText:self.label.text];
    self.label.textForFontSizeCalculation = str;
    
    if(!needsReset) return;
    
    CGSize newSize = self.bounds.size;
    CGRect labelRect = self.label.frame;
    labelRect.size.width = newSize.width-((_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.left+_contentInset.right));
    labelRect.size.height = labelRect.size.width * labelRatio;
    
    labelRect.origin.x = newSize.width/2 - labelRect.size.width/2;
    labelRect.origin.y = newSize.height/2 - labelRect.size.height/2;
    [self.label resetFrame:labelRect fit:NO];
    [self.label saveState];
    [self.label setFontSizeThatFits];
    NSString *ttxt = self.label.text;
    self.label.text = ttxt;
     //[self updateDebug];
    
    needsReset = NO;
}
- (void) setFont:(UIFont *)newFont;
{
    
     //[self updateDebug];
    
    [self resetLabel];
    
    
    
    CGSize bs = self.bounds.size;
    
    self.label.font = newFont;
    
    [self.label setFontSizeThatFits];
    
    
    
    [self setSafeText:self.text preserveWidth:NO saveDelta:NO scaleUp:NO];
    //[self resizeLabelWithText:self.label.text];
    CGRect labelRect = self.label.frame;
    
    labelRatio = labelRect.size.height/labelRect.size.width;
    
    CGSize ns = self.bounds.size;
    if(bs.width > ns.width)
    {
        
        
        CGFloat r = bs.width/ns.width;
        
        ns.width = bs.width;
        ns.height = ns.height*r;
        
        
        
        
        
        labelRect.size.width = ns.width-((_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.top + _contentInset.bottom));
        labelRect.size.height = labelRect.size.width * labelRatio;
        
        labelRect.origin.x = _globalInset.left + MYSTIC_UI_LAYER_BORDER_SIZE/2 + _contentInset.left;
        labelRect.origin.y =_globalInset.top + MYSTIC_UI_LAYER_BORDER_SIZE/2 + _contentInset.top;
        
        [self setLabelFrame:labelRect];
        
        
//        [self.label resetFrame:labelRect fit:NO];
        
        CGRect b2 = labelRect;
        
        b2.size.height += (_globalInset.top+_globalInset.bottom) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.top + _contentInset.bottom);
        b2.size.width += (_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.left+_contentInset.right);
        
        
        b2.origin = CGPointZero;
        [super setBounds:b2];
        
        [self layoutControls];
        ratio = self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height/self.bounds.size.width : self.bounds.size.width/self.bounds.size.height;
        
        [self.label setFontSizeThatFits];
        
        
//        [self.label saveState];
        
    }
    [self setSafeText:self.text preserveWidth:NO saveDelta:NO scaleUp:YES];
    
    
     //[self updateDebug];
}


- (void) setFontSize:(CGFloat)fontSize;
{
    
    //[self updateDebug];
    
    [self resetLabel];
    
    
    
    CGSize bs = self.bounds.size;
    
    self.label.font = [self.label.font fontWithSize:fontSize];
    
    [self.label setFontSizeThatFits:fontSize];
    
    
    
    [self setSafeText:self.text preserveWidth:NO saveDelta:NO scaleUp:NO];
    //[self resizeLabelWithText:self.label.text];
    CGRect labelRect = self.label.frame;
    
    labelRatio = labelRect.size.height/labelRect.size.width;
    
    CGSize ns = self.bounds.size;
    if(bs.width > ns.width)
    {
        
        
        CGFloat r = bs.width/ns.width;
        
        ns.width = bs.width;
        ns.height = ns.height*r;
        
        
        
        
        
        labelRect.size.width = ns.width-((_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.left+_contentInset.right));
        labelRect.size.height = labelRect.size.width * labelRatio;
        
        labelRect.origin.x = _globalInset.left + MYSTIC_UI_LAYER_BORDER_SIZE/2 + _contentInset.left;
        labelRect.origin.y =_globalInset.top + MYSTIC_UI_LAYER_BORDER_SIZE/2 + _contentInset.top;
        
        [self setLabelFrame:labelRect];
        
        
        //        [self.label resetFrame:labelRect fit:NO];
        
        CGRect b2 = labelRect;
        
        b2.size.width += ((_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.left+_contentInset.right));
        b2.size.height += ((_globalInset.top+_globalInset.bottom) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.top+_contentInset.bottom));
        
        b2.origin = CGPointZero;
        [super setBounds:b2];
        
        [self layoutControls];
        ratio = self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height/self.bounds.size.width : self.bounds.size.width/self.bounds.size.height;
        
        [self.label setFontSizeThatFits];
        
        
        //        [self.label saveState];
        
    }
    [self setSafeText:self.text preserveWidth:NO saveDelta:NO scaleUp:YES];
    
    
    //[self updateDebug];
}

- (void) setSafeText:(NSString *)theText;
{
    [self setSafeText:theText preserveWidth:YES];
}
- (void) setSafeText:(NSString *)theText preserveWidth:(BOOL)preserveWidth;
{
    [self setSafeText:theText preserveWidth:preserveWidth saveDelta:YES scaleUp:NO];
}
- (void) setSafeText:(NSString *)theText preserveWidth:(BOOL)preserveWidth saveDelta:(BOOL)saveDelta scaleUp:(BOOL)scaleUp;
{
    CGSize bs = self.bounds.size;
    
    [self.label setSafeText:theText];
    
    NSString *widthTxt = theText;
    
    CGRect frame = self.label.frame;
    CGSize size = [widthTxt sizeWithFont:self.label.font
                      constrainedToSize:CGSizeMake(frame.size.width, 9999)
                          lineBreakMode:self.label.lineBreakMode];
    
    frame.size.height = size.height;
    
    CGSize change = CGSizeZero;
    change.height = frame.size.height - self.label.frame.size.height;
    if(!preserveWidth)
    {
        frame.size.width = size.width;
        change.width = frame.size.width - self.label.frame.size.width;
    }
    
    
    if(change.height != 0 || (!preserveWidth && change.width != 0))
    {
        [self.label resetFrame:frame fit:NO];
        labelRatio = frame.size.height/frame.size.width;
        
        CGRect b = self.bounds;
        b.size.height += change.height;
        if(!preserveWidth) b.size.width += change.width;
        
        [super setBounds:b];
        [self layoutControls];
        
        ratio = b.size.width > b.size.height ? b.size.height/b.size.width : b.size.width/b.size.height;
        
//        [self.label saveState];
        labelRatio = self.label.frame.size.height/self.label.frame.size.width;
        
        if(saveDelta)
        {
            [super setCenter:mcenterPoint];
            deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                               self.frame.origin.x+self.frame.size.width - self.center.x);
        }
    }
    
    
    CGSize ns = self.bounds.size;
    if(scaleUp && bs.width > ns.width)
    {
        
        
        CGFloat r = bs.width/ns.width;
        
        ns.width = bs.width;
        ns.height = ns.height*r;
        
        
        CGRect labelRect = self.label.frame;
        
        
        labelRect.size.width = ns.width-((_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.left+_contentInset.right));
        labelRect.size.height = labelRect.size.width * labelRatio;
        
        labelRect.origin.x = _globalInset.left + MYSTIC_UI_LAYER_BORDER_SIZE/2 + _contentInset.left;
        labelRect.origin.y =_globalInset.top + MYSTIC_UI_LAYER_BORDER_SIZE/2 + _contentInset.top;
        
        [self setLabelFrame:labelRect];
        
        
        
        CGRect b2 = labelRect;
        
        b2.size.width += ((_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.left+_contentInset.right));
        b2.size.height += ((_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.top+_contentInset.bottom));
        
        b2.origin = CGPointZero;
        [super setBounds:b2];
        
        [self layoutControls];
        ratio = self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height/self.bounds.size.width : self.bounds.size.width/self.bounds.size.height;
        
        [self.label setFontSizeThatFits];
        
        
        
    }
    
    
     //[self updateDebug];
}

- (void) saveLabelState;
{
    [self.label saveState];
    labelRatio = self.label.frame.size.height/self.label.frame.size.width;
    
    
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
    
    //[self updateDebug];
    
}

- (UIFont *) font; { return self.label.font; }


- (void) updateDebug;
{
//    NSString *s = [NSString stringWithFormat:@"Font: %2.0f Txt: %@  Lbl: %2.0fx%2.0f Size: %2.0fx%2.0f %@", self.fontSize, self.label.textForFontSizeCalculation ? @"YES" : @"NO", self.label.frame.size.width, self.label.frame.size.height, self.bounds.size.width, self.bounds.size.height, needsReset ? @"  RESET" : @""];
    
    
    
//    [self.delegate layerViewDebug:s];
}





- (BOOL) selected;
{
    return _selected;
}

- (void) setEnabled:(BOOL)newValue;
{
    
    if(self.selected) self.selected = NO;
    
    _enabled = newValue;
}

- (void) setSelected:(BOOL)v
{
    [self setSelected:v notify:YES];
}
- (void) setSelected:(BOOL)v notify:(BOOL)shouldNotify;
{
    
    if(!self.enabled) return;
    _selected = v;
    if(v)
    {
        [self showControls:YES];
    }
    else
    {
        [self hideControls:YES];
    }
    
    if(shouldNotify && [_delegate respondsToSelector:@selector(layerViewDidSelect:)]) {
        [_delegate layerViewDidSelect:self];
    }
    
    if(self.selectBlock) self.selectBlock(self);
}


- (UIColor *)color;
{
    return self.label.textColor;
}
- (void) setColor:(UIColor *)color;
{
    self.label.textColor = color;
}

-(void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    needsReset = YES;
    if ([recognizer state]== UIGestureRecognizerStateBegan)
    {
        [self hideControls:YES];
        prevPoint = [recognizer locationInView:self];
        [self resizeScaledLabel:2.0];
        [self setNeedsDisplay];
        if([_delegate respondsToSelector:@selector(layerViewDidBeginMoving:)]) {
            [_delegate layerViewDidBeginMoving:self];
        }
        
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        if (self.bounds.size.width < _minimumWidth || self.bounds.size.height < _minimumHeight)
        {
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     _minimumWidth+1,
                                     _minimumHeight+1);
            resizingControl.frame = [self resizeControlFrame];
            if(deleteControl) deleteControl.frame = [self deleteControlFrame];
            
            customControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,
                                            0,
                                            _controlSize.width,
                                            _controlSize.height);
            prevPoint = [recognizer locationInView:self];
            
            
        } else {
            CGPoint point = [recognizer locationInView:self];
            float wChange = 0.0, hChange = 0.0;
            
            wChange = (point.x - prevPoint.x);
            hChange = (point.y - prevPoint.y);
            
            if (ABS(wChange) > 22.0f || ABS(hChange) > 22.0f) {
                prevPoint = [recognizer locationInView:self];
                return;
            }
            
            if (YES == self.preventsLayoutWhileResizing) {
                if (wChange < 0.0f && hChange < 0.0f) {
                    float change = MIN(wChange, hChange);
                    wChange = change;
                    hChange = change;
                }
                if (wChange < 0.0f) {
                    hChange = wChange;
                } else if (hChange < 0.0f) {
                    wChange = hChange;
                } else {
                    float change = MAX(wChange, hChange);
                    wChange = change;
                    hChange = change;
                }
            }
            
            // makes the drag happen faster
            wChange = wChange*kMYSTICLAYERScaleFactor;
            hChange = hChange*kMYSTICLAYERScaleFactor;
            
            
            CGRect b = self.bounds;
            b.size.width += wChange;
            b.size.height += hChange;
            CGSize nc = b.size;
            if(b.size.width > b.size.height)
            {
                nc.height = nc.width *ratio;
                
            }
            else
            {
                nc.width = nc.height *ratio;
            }
            
            CGSize newSize = nc;
            
            CGRect labelRect = self.label.frame;
            labelRect.size.width = newSize.width-((_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.left+_contentInset.right));
            labelRect.size.height = labelRect.size.width * labelRatio;
            
            labelRect.origin.x = newSize.width/2 - labelRect.size.width/2;
            labelRect.origin.y = newSize.height/2 - labelRect.size.height/2;
            

            
            
            [self setLabelFrame:labelRect];
            
            CGRect b2 = labelRect;
            
            b2.size.width += ((_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.left+_contentInset.right));
            b2.size.height += ((_globalInset.top+_globalInset.bottom) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.top+_contentInset.bottom));
            
            b2.origin = CGPointZero;
            [super setBounds:b2];
            
            [self layoutControls];
            ratio = self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height/self.bounds.size.width : self.bounds.size.width/self.bounds.size.height;
            prevPoint = [recognizer locationInView:self];
            
        }
        
        /* Rotation */
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x);
        float angleDiff = deltaAngle - ang;
        
        if(rotationSnapping)
        {
            BOOL shouldRotate = angleDiff < -0.08 || angleDiff > 0.08 ? YES : NO;
            if(shouldRotate)
            {
                shouldRotate = angleDiff < -12 && angleDiff > -1.63 ? NO : YES;
                if(!shouldRotate)
                {
                    angleDiff = -17;
                    shouldRotate = YES;
                }
            }
            if(shouldRotate && angleDiff != -17)
            {
                shouldRotate = angleDiff > 12 && angleDiff > 1.63 ? NO : YES;
                if(!shouldRotate)
                {
                    angleDiff = 17;
                    shouldRotate = YES;
                }
            }
            angleDiff = shouldRotate ? angleDiff : 0;
        }
        if (NO == preventsResizing) {
            if([_delegate respondsToSelector:@selector(layerViewDidMove:)]) {
                [_delegate layerViewDidMove:self];
            }
            
            self.rotation = -angleDiff;
        }
        
    
        
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
//        DLog(@"translate did end");
        [self showControls:YES];
        prevPoint = [recognizer locationInView:self];
        if(self.selected && [_delegate respondsToSelector:@selector(layerViewDidEndMoving:)]) {
            [_delegate layerViewDidEndMoving:self];
        }
        //[self updateDebug];
        
        [self setNeedsDisplay];
    }
}

- (void) transformSize:(CGFloat)amount;
{
    CGRect b = self.bounds;

    CGFloat wChange = b.size.width * amount;
    CGFloat hChange = b.size.height * amount;

    b.size.width += wChange;
    b.size.height += hChange;
    CGSize nc = b.size;
    if(b.size.width > b.size.height)
    {
        nc.height = nc.width *ratio;
        
    }
    else
    {
        nc.width = nc.height *ratio;
    }
    
    CGSize newSize = nc;
    
    CGRect labelRect = self.label.frame;
    labelRect.size.width = newSize.width-((_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.left+_contentInset.right));
    labelRect.size.height = labelRect.size.width * labelRatio;
    
    labelRect.origin.x = newSize.width/2 - labelRect.size.width/2;
    labelRect.origin.y = newSize.height/2 - labelRect.size.height/2;
    
    
    
    
    [self setLabelFrame:labelRect];
    
    CGRect b2 = labelRect;
    
    b2.size.width += ((_globalInset.left+_globalInset.right) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.left+_contentInset.right));
    b2.size.height += ((_globalInset.top+_globalInset.bottom) + MYSTIC_UI_LAYER_BORDER_SIZE + (_contentInset.top+_contentInset.bottom));
    
    b2.origin = CGPointZero;
    [super setBounds:b2];
    
    [self layoutControls];
    ratio = self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height/self.bounds.size.width : self.bounds.size.width/self.bounds.size.height;
}
- (void) changeRotation:(CGFloat)change;
{
    self.rotation = lastAngle + change;
}
- (void) setRotation:(CGFloat)value;
{
    self.transform = CGAffineTransformMakeRotation(value);
    lastAngle = value;

}
- (CGFloat) rotation;
{
    return lastAngle;
}
- (void) setDefaultText:(NSString *)value
{
    defaultText = value;
    if([self.text isEqualToString:MysticDefaultFontText]) self.text = defaultText;
}
- (void) setTextAlignment:(NSTextAlignment)textAlignment;
{
    self.label.textAlignment = textAlignment;
}
- (NSTextAlignment) textAlignment;
{
    return self.label.textAlignment;
}

- (void)setupDefaultAttributes
{
    

    _rotatePosition = MysticPositionUnknown;
    _textSpacing = 1.0;
    wasSelected = NO;
    wasMoving = NO;
    _hasHiddenControls = NO;
    needsReset = NO;
    ignoreSingleTap = NO;
    self.enabled = YES;
    defaultText = MysticDefaultFontText;
    lastAngle = 0;
    self.backgroundColor = [UIColor clearColor];
    mcenterPoint  = self.center;
    rotationSnapping = NO;
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
    self.minimumFontSize = 10;

    self.insets = UIEdgeInsetsMake(_globalInset.top+_borderInset.top+_contentInset.top,
                                   _globalInset.left+_borderInset.left+_contentInset.left,
                                   _globalInset.bottom+_borderInset.bottom+_contentInset.bottom,
                                   _globalInset.right+_borderInset.right+_contentInset.right);
    
    MysticCGLabel *newLabel = [[MysticCGLabel alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, self.insets)];
    newLabel.numberOfLines = 0;
    newLabel.textAlignment = NSTextAlignmentCenter;
    newLabel.lineBreakMode = NSLineBreakByCharWrapping;
    newLabel.backgroundColor = [UIColor clearColor];
    newLabel.font = [MysticFont defaultTypeFont:14];
    newLabel.text = defaultText;
    newLabel.clipsToBounds = YES;
    self.label = newLabel;

    
    
    borderView = [[MysticResizeableLayerBorderView alloc] initWithFrame:CGRectIntegral(CGRectInset(self.bounds, _borderInset.left+_borderInset.right+self.borderWidth, _borderInset.top+_borderInset.bottom+self.borderWidth))];
    borderView.borderWidth = self.borderWidth;
    [borderView setHidden:NO];
    [borderView setNeedsDisplay];
    [self addSubview:borderView];
    

    
    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0) {
        self.minimumWidth = kSPUserResizableViewDefaultMinWidth;
        self.minimumHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
    } else {
        self.minimumWidth = self.bounds.size.width*0;
        self.minimumHeight = self.bounds.size.height*0;
    }
    self.preventsPositionOutsideSuperview = YES;
    self.preventsLayoutWhileResizing = YES;
    self.preventsResizing = NO;
    self.preventsDeleting = NO;
    self.preventsCustomButton = YES;
    
    
#ifdef MYSTICLABEL_LONGPRESS
    UILongPressGestureRecognizer* longpress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(longPress:)];
    [self addGestureRecognizer:longpress];
#endif
    deleteControl = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeLayerX) size:(CGSize){kMYSTICLAYERControlIconSize,kMYSTICLAYERControlIconSize} color:@(MysticColorTypeUnknown)] target:self sel:@selector(deleteTap:)];
    deleteControl.contentMode = UIViewContentModeCenter;
    deleteControl.frame = [self deleteControlFrame];
    deleteControl.hitInsets = UIEdgeInsetsMakeFrom(6);
    deleteControl.adjustsImageWhenHighlighted = NO;
    [self addSubview:deleteControl];
    
    resizingControl = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeLayerResize) size:(CGSize){kMYSTICLAYERControlIconSize,kMYSTICLAYERControlIconSize} color:@(MysticColorTypeUnknown)] target:nil sel:@selector(resizeTap:)];
    resizingControl.contentMode = UIViewContentModeCenter;
    resizingControl.frame = [self resizeControlFrame];
    resizingControl.hitInsets = UIEdgeInsetsMakeFrom(6);
    resizingControl.adjustsImageWhenHighlighted = NO;
    UIPanGestureRecognizer* panResizeGesture = [[UIPanGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(resizeTranslate:)];
    [resizingControl addGestureRecognizer:panResizeGesture];
    [self addSubview:resizingControl];
    
//    customControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-_controlSize.width,
//                                                                 0,
//                                                                 _controlSize.width, _controlSize.height)];
//    customControl.backgroundColor = [UIColor clearColor];
//    customControl.userInteractionEnabled = YES;
//    customControl.image = nil;
//    customControl.contentMode = UIViewContentModeScaleAspectFit;
//
//    UITapGestureRecognizer * customTapGesture = [[UITapGestureRecognizer alloc]
//                                                 initWithTarget:self
//                                                 action:@selector(customTap:)];
//    [customControl addGestureRecognizer:customTapGesture];
//    [self addSubview:customControl];
//    
//    
    
    
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
    [self.label setFontSizeThatFits];
    [self resizeLabelWithText:self.label.text];
    
    
    
}



- (void)setLabel:(MysticCGLabel *)newLabel {
//    newLabel.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.3];
    [label removeFromSuperview];
    label = newLabel;
    label.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + MYSTIC_UI_LAYER_BORDER_SIZE/2, kSPUserResizableViewGlobalInset + MYSTIC_UI_LAYER_BORDER_SIZE/2);
    [self addSubview:label];
    


    [self bringSubviewToFront:borderView];
    if(resizingControl) [self bringSubviewToFront:resizingControl];
    if(deleteControl) [self bringSubviewToFront:deleteControl];
    [self bringSubviewToFront:customControl];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

//    DLog(@"touches began");
    [super touchesBegan:touches withEvent:event];
    ignoreSingleTap = NO;
    UITouch *touch = [touches anyObject];
    wasSelected = self.selected;
    wasMoving = NO;
    touchStart = [touch locationInView:self.superview];
    if([_delegate respondsToSelector:@selector(layerViewDidBeginMoving:)]) {
        [_delegate layerViewDidBeginMoving:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
//    DLog(@"touches ended");

    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    if(touch.view != resizingControl  && wasSelected)
    {
        [self showControls:YES];
        
    }
    if([_delegate respondsToSelector:@selector(layerViewDidEndMoving:)]) {
        [_delegate layerViewDidEndMoving:self];
    }
    else if(self.movedBlock) self.movedBlock(self);
    wasMoving = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    [super touchesCancelled:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    if(touch.view != resizingControl && wasMoving && wasSelected)
    {
        [self showControls:YES];
    }
    ignoreSingleTap = NO;
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(layerViewDidCancelMoving:)]) {
        [_delegate layerViewDidCancelMoving:self];
    }
    else if([_delegate respondsToSelector:@selector(layerViewDidEndMoving:)]) {

        [_delegate layerViewDidEndMoving:self];
    }
    else if(self.movedBlock) self.movedBlock(self);
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    if(!self.selected) return;
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x,
                                    self.center.y + touchPoint.y - touchStart.y);
    if (self.preventsPositionOutsideSuperview) {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }
        if (newCenter.x < midPointX) {
            newCenter.x = midPointX;
        }
        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }
        if (newCenter.y < midPointY) {
            newCenter.y = midPointY;
        }
    }
    mcenterPoint = newCenter;
    self.center = newCenter;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

//    DLog(@"touch moved");
    [super touchesMoved:touches withEvent:event];
    wasMoving=YES;
    ignoreSingleTap = YES;
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(resizingControl.frame, touchLocation)) {
        return;
    }
    if(!self.hasHiddenControls)
    {
        [self hideControls:YES];
    }
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    [self translateUsingTouchLocation:touch];
    touchStart = touch;
    
    if(self.selected && [_delegate respondsToSelector:@selector(layerViewDidMove:)]) {
        [_delegate layerViewDidMove:self];
    }
}
#ifdef MYSTICLABEL_LONGPRESS
-(void)longPress:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if([_delegate respondsToSelector:@selector(layerViewDidLongPressed:)]) {
            [_delegate layerViewDidLongPressed:self];
        }
        else if(self.longPressBlock)
        {
            self.longPressBlock(self);
        }
    }
}
#endif
- (void) singleTap:(UITapGestureRecognizer *)recognizer;
{
    if(ignoreSingleTap) return;
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        if([_delegate respondsToSelector:@selector(layerViewDidSingleTap:)]) {
            [_delegate layerViewDidSingleTap:self];
        }
        else if(self.singleTapBlock)
        {
            self.singleTapBlock(self);
        }
        else
        {
            if(!self.enabled) return;
            if(!self.selected) self.selected = YES;
        }
    }
    
    
}
- (void) doubleTapped;
{
    
}
- (void) doubleTap:(UITapGestureRecognizer *)recognizer;
{
//    DLog(@"double tap");

    if(!self.enabled) return;
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        if([_delegate respondsToSelector:@selector(layerViewDidDoubleTap:)]) {
            [_delegate layerViewDidDoubleTap:self];
        }
        
        if(self.doubleTapBlock)
        {
            self.doubleTapBlock(self);
        }
        else
        {
            [self doubleTapped];
        }
    }
    
    
}
-(void)deleteTap:(MysticButton *)sender
{

        if([_delegate respondsToSelector:@selector(layerViewDidClose:)]) {
            [_delegate layerViewDidClose:self];
        }
        else if(self.deleteBlock)
        {
            self.deleteBlock(self);
        }
        else  if (NO == self.preventsDeleting) {
                [sender.superview removeFromSuperview];
            }
    
    
}

-(void)resizeTap:(MysticButton *)sender
{
    
    
    
    
}

-(void)customTap:(UIPanGestureRecognizer *)recognizer
{
    if(!self.enabled) return;
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (NO == self.preventsCustomButton) {
            if([_delegate respondsToSelector:@selector(layerViewDidCustomButtonTap:)]) {
                [_delegate layerViewDidCustomButtonTap:self];
            }
            else if(self.customTapBlock)
            {
                self.customTapBlock(self);
            }
        }
    }
}

- (void)hideDelHandle
{
    if(deleteControl) deleteControl.hidden = YES;
}

- (void)showDelHandle
{
    if(deleteControl) deleteControl.hidden = NO;
}

- (void)hideEditingHandles
{
    resizingControl.hidden = YES;
    if(deleteControl) deleteControl.hidden = YES;
    customControl.hidden = YES;
    [borderView setHidden:YES];
}

- (void)showEditingHandles
{
    if (NO == preventsCustomButton) {
        customControl.hidden = NO;
    } else {
        customControl.hidden = YES;
    }
    if (NO == preventsDeleting) {
        if(deleteControl) deleteControl.hidden = NO;
    } else {
        if(deleteControl) deleteControl.hidden = YES;
    }
    if (NO == preventsResizing) {
        resizingControl.hidden = NO;
    } else {
        resizingControl.hidden = YES;
    }
    [borderView setHidden:NO];
}

- (void)showCustmomHandle
{
    customControl.hidden = NO;
}

- (void)hideCustomHandle
{
    customControl.hidden = YES;
}

- (void) hideControls:(BOOL)animated;
{
    self.hasHiddenControls = YES;
    customControl.hidden = YES;
    deleteControl.hidden = YES;
    resizingControl.hidden = YES;
    borderView.hidden = YES;
}
- (void) showControls:(BOOL)animated;
{
    self.hasHiddenControls = NO;
    [self showEditingHandles];
}

- (void)setButton:(MysticLayerControl)type image:(UIImage*)image
{
    switch (type) {
        case MysticLayerControlResize:
            if(resizingControl) [resizingControl setImage:image forState:UIControlStateNormal];
            break;
        case MysticLayerControlDelete:
            if(deleteControl) [deleteControl setImage:image forState:UIControlStateNormal];
            break;
        case MysticLayerControlCustom:
            if(customControl) [customControl setImage:image forState:UIControlStateNormal];
            break;
            
        default: break;
    }
}

- (void) removeFromSuperview;
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}
#pragma mark - Keyboard Interactions




- (BOOL) becomeFirstResponder; { return NO; }
- (BOOL) canBecomeFirstResponder; { return NO; }


- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event;
{
    if(CGRectContainsPoint(self.bounds, point))
    {
        return YES;
    }
    
    for (UIView *sub in self.subviews) {
        CGRect subFrame = sub.frame;
        UIEdgeInsets hitInsets = [sub isKindOfClass:[MysticButton class]] ? [(MysticButton *)sub hitInsets] : UIEdgeInsetsMakeFrom(0);
        CGRect frame2 = CGRectMake(subFrame.origin.x +hitInsets.left,
                                   subFrame.origin.y +hitInsets.top,
                                   subFrame.size.width + (hitInsets.left*-1) + (hitInsets.right*-1),
                                   subFrame.size.height + (hitInsets.top*-1) + (hitInsets.bottom*-1));
        if(CGRectContainsPoint(frame2, point))
        {
            return YES;
        }
    }
    return NO;
}


//- (BOOL) isFirstResponder;
//{
//    return activeTarget ? YES : NO;
//}

@end
