//
//  MysticInputView.m
//  Mystic
//
//  Created by Me on 11/14/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticInputView.h"
#import "Mystic.h"
#import "MysticLayersScrollView.h"
#import "MysticFontTools.h"
#import "MysticSlider.h"
#import "MysticBorderView.h"
#import "EffectControl.h"
#import "MysticScrollViewControl.h"
#import "MysticAlert.h"

@interface MysticInputView () <ILPickerDelegate, EffectControlDelegate>
@property (nonatomic, assign) BOOL  keyboardAlreadyShowed, hasInit;
@property (retain, nonatomic) IBOutlet UITextField  *hiddenTextField;
@end

static NSMutableArray *userColors;

@implementation MysticInputView
+ (NSArray *) userColors;
{
    return userColors;
}
+ (void) addUserColor:(id)colorValue;
{
    
    if(colorValue)
    {
        BOOL foundColor = NO;
        UIColor *newColor = [MysticColor color:colorValue];
        for (UIColor *color in userColors) {
            if([newColor isEqualToColor:color])
            {
                foundColor = YES;
                break;
            }
        }
        if(!foundColor)
        {
            [userColors insertObject:newColor atIndex:0];
        }
    }
}
+ (id) inputView:(UIView *)view type:(MysticInputType)inputType finished:(MysticBlockInput)finished;
{
    return [[self class] inputView:view title:nil type:inputType finished:finished];
}
+ (id) inputView:(UIView *)view title:(NSString *)title type:(MysticInputType)inputType finished:(MysticBlockInput)finished;
{
    MysticInputView *iv = [[[self class] alloc] initWithFrame:view.frame title:title];
    iv.finished = finished;
//    [iv showInView:view type:inputType];
    
    return iv;
    
}
+ (id) showInView:(UIView *)view type:(MysticInputType)inputType finished:(MysticBlockInput)finished;
{
    MysticInputView *iv = [[[self class] alloc] initWithFrame:view.frame];
    iv.finished = finished;
    iv.containerView = view;
    [iv showInView:view type:inputType];
    return iv;
    
}
- (void) dealloc;
{
    if(_selectedColorTitle) [_selectedColorTitle release], _selectedColorTitle=nil;
    if(_selectedColorWithColorTitle) [_selectedColorWithColorTitle release], _selectedColorWithColorTitle=nil;

    if(_title) [_title release], _title = nil;
    [_picker release], _picker =nil;
    [_color release], _color = nil;
    [_selectedColor release],_selectedColor=nil;
    [_targetOption release], _targetOption=nil;
    [_hiddenTextField release];
    _delegate = nil;
    [_oldColorBtn release], _oldColorBtn=nil;
    [_currentColorBtn release], _currentColorBtn=nil;
    [_toolbar release], _toolbar=nil;
    [_fontOption release];
    [_containerView release];
    [_font release];
    [_oldColor release], _oldColor=nil;
    [_hexLabel release], _hexLabel = nil;
    [_toolbarNipple release], _toolbarNipple=nil;
    Block_release(_finished);
    Block_release(_changed);
    Block_release(_refresh);
    Block_release(_update);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self commonInit];

    }
    return self;
}
- (id) initWithFrame:(CGRect)frame title:(NSString *)title;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.title = title;
        [self commonInit];
    }
    return self;
}
- (void) commonInit;
{
    userColors = userColors ? userColors : [[NSMutableArray array] retain];
    _colorPickerMode = ColorPickerModeDefault;
    _showToolbarBorder=NO;
    _showColors=YES;
    _showColorTools=NO;
    _showRemoveButton=NO;
    _selectedColorIndex = NSNotFound;
    _selectedColorPoint = CGPointUnknown;
    _allowEyeDropper=NO;
    _sendFinished = NO;
    _showHexValues = YES;
    _threshold = MysticThresholdDefault;
    self.keyboardRect = (CGRect){0,0,[MysticUI screen].width, 253};
    self.type = MysticInputTypeUnknown;
    self.textAlignment = NSTextAlignmentLeft;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}
- (void) setShowDropper:(BOOL)showDropper;
{
    self.picker.showDropper= showDropper;
}
- (BOOL) showDropper; { return self.picker.showDropper; }
- (CGFloat) colorAlpha;
{
    if(_colorAlpha) return _colorAlpha;
    return self.color ? self.color.alpha : 1;
}
- (CGRect) inputFrame;
{
    CGFloat h = self.keyboardRect.size.height;
    return CGRectMake(0, [MysticUI screen].height - h, self.keyboardRect.size.width, h);
}
- (UIColor *)oldColor; { return _oldColor ? _oldColor : _selectedColor ? _selectedColor : nil; }
- (void) setColor:(UIColor *)color;
{
    [_color release];
    _color = color ? [color retain] : nil;
    if(!self.oldColor) self.oldColor = color;
    if(self.color && self.selectedColor && ![self.color isEqualToColor:self.selectedColor]) [self setHexLabelText:self.selectedColorWithColorTitle];
    if(!self.color) [self setHexLabelText:self.selectedColorTitle];
    if(self.selectedColor) [self setHexLabelText:self.selectedColorWithColorTitle];
    if(color && self.removeBtn && self.removeBtn.hidden)
    {
        self.removeBtn.hidden = NO;
        self.removeBtn.alpha = 0;
        [MysticUIView animateWithDuration:0.3 animations:^{
            self.removeBtn.alpha=1;
        }];
    }
}
- (void) setSelectedColor:(UIColor *)selectedColor;
{
    if(_selectedColor) [_selectedColor release],_selectedColor=nil;
    if(selectedColor) _selectedColor = [selectedColor retain];
    if(self.oldColorBtn) self.oldColorBtnColor = selectedColor;
    if(!self.color && selectedColor) [self setHexLabelText:self.selectedColorWithColorTitle];
    if(selectedColor) self.picker.sourceColor=selectedColor;
    if(selectedColor && self.pickColorBtn && !self.pickColorBtn.hidden)
    {
        __unsafe_unretained __block MysticInputView *weakSelf = self;
        self.confirmBtn.enabled=YES;
        [MysticUIView animateKeyframesWithDuration:0.5 delay:0 options:nil animations:^{
            [MysticUIView addKeyframeWithRelativeStartTime:0.2/0.5 relativeDuration:0.3/0.5 animations:^{
                weakSelf.pickColorBtn.alpha = 0;
                weakSelf.confirmBtn.alpha=1;
            }];
            [MysticUIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.2/0.5 animations:^{
                UIView *_ok = [weakSelf.pickColorBtn viewWithTag:MysticViewTypeButton1];
                _ok.alpha=0;
                _ok.transform=CGAffineTransformMakeTranslation(0, 20);
            }];
        } completion:^(BOOL finished) {
            [weakSelf.pickColorBtn removeFromSuperview];
            weakSelf.pickColorBtn=nil;
        }];
    }
    if(selectedColor && self.removeBtn && self.removeBtn.hidden)
    {
        __unsafe_unretained __block MysticInputView *weakSelf = self;
        self.removeBtn.hidden = NO;
        self.removeBtn.alpha = 0;
        self.removeBtn.enabled=YES;
        [MysticUIView animateWithDuration:0.3 animations:^{ weakSelf.removeBtn.alpha=1; }];
    }
    if(self.sendDelegateMethods &&  self.delegate && [self.delegate respondsToSelector:@selector(inputViewSetSelectedColor:finished:)])
        [self.delegate inputViewSetSelectedColor:self finished:self.touchesEnded];
}
- (void) setColorAndPicker:(UIColor *)color;
{
    self.sendFinished=NO;
    [self colorPicked:color forPicker:self.picker];
    self.sendFinished=YES;
    if(color && self.removeBtn && self.removeBtn.hidden)
    {
        self.removeBtn.hidden = NO;
        self.removeBtn.alpha = 0;
        [MysticUIView animateWithDuration:0.3 animations:^{
            self.removeBtn.alpha=1;
        }];
    }
}
- (void) dismiss;
{
    if(self.sendDelegateMethods &&  self.sendFinished && self.delegate && [self.delegate respondsToSelector:@selector(inputViewFinished:)])
    {
        [self.delegate inputViewFinished:self];
    }
    if(self.sendFinished && self.finished)
    {
        self.finished(self.color, self.selectedColor, self.selectedColorPoint, self.threshold, self.selectedColorIndex, self, YES);
        self.finished=nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(self.sendDelegateMethods &&  self.delegate && [self.delegate respondsToSelector:@selector(inputViewDismissed:)])
        [self.delegate inputViewDismissed:self];
    [self.hiddenTextField resignFirstResponder];
    [self.hiddenTextField removeFromSuperview];
    
}
- (void) hideAddBtn:(BOOL)animated;
{
    [self hideControl:self.addBtn animated:animated];
}
- (void) showAddBtn:(BOOL)animated;
{
    [self showControl:self.addBtn animated:animated];
}
- (void) hideRemoveBtn:(BOOL)animated;
{
    [self hideControl:self.removeBtn animated:animated];
}
- (void) showRemoveBtn:(BOOL)animated;
{
    [self showControl:self.removeBtn animated:animated];
}
- (void) hideControl:(UIView *)control animated:(BOOL)animated;
{
    if(!control) return;
    if(!animated) { control.hidden = YES; return; }
    [MysticUIView animate:0.3 animations:^{
        control.alpha = 0;
    } completion:^(BOOL finished) {
        control.hidden = YES;
    }];
}
- (void) showControl:(UIView *)control animated:(BOOL)animated;
{
    if(!control) return;
    if(!animated) { control.hidden = NO; control.alpha = 1; return; }
    control.hidden = NO;
    [MysticUIView animate:0.3 animations:^{
        control.alpha = 1;
    }];
}
- (BOOL) beFirstResponder;
{
    BOOL b= [self.hiddenTextField becomeFirstResponder];
    return b;
}
- (void) showInView:(UIView *)view type:(MysticInputType)inputType;
{
    self.containerView = view;
    self.type = inputType;
    UITextField *fh = [[UITextField alloc] initWithFrame:CGRectMake(-1000, 0, 10, 10)];
    fh.inputView = self.inputView;
    UIView *toolbar = [self makeInputAccessoryView];
    toolbar.frame = CGRectAlign(toolbar.frame, view.bounds, MysticAlignPositionBottom);
    self.toolbar = toolbar;
    fh.inputAccessoryView = self.toolbar;
    fh.inputAccessoryView.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:1.00];
    
    [view addSubview:fh];
    self.hiddenTextField = fh;
    [fh becomeFirstResponder];
    [fh release];

    switch (self.type) {
        case MysticInputTypeColor:
        {
            [self colorPicked:self.color forPicker:self.picker];
            break;
        }
        default: break;
    }
}
- (void) keyboardDidShow:(NSNotification *)notification;
{
    _sendFinished = YES;
    if(self.keyboardAlreadyShowed) return;
    if(self.sendDelegateMethods &&  self.delegate && [self.delegate respondsToSelector:@selector(inputViewDidShow:)])
    {
        MysticWait(0.25,^{ [self.delegate inputViewDidShow:self]; });
    }
    self.keyboardAlreadyShowed=YES;
}
- (void) keyboardWillShow:(NSNotification *)notification;
{
    CGRect kFrame = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect kFrame2 = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval t = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve theCurve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    _sendFinished = NO;
//    self.keyboardRect = kFrame;
    
//    FLog(@"keyboard frame", kFrame);
}
- (void) effectControlDidTouchUp:(UIControl *)effectControl effect:(MysticControlObject *)effect;
{
    PackPotionOptionColor*color = (id)effect;
    self.picker.color = color.color;
    [self colorPicked:color.color forPicker:nil];
    [(MysticScrollView *)effectControl.superview centerOnView:effectControl animate:YES complete:nil];
}

-(void)colorPicked:(UIColor *)color forPicker:(ILColorPickerView *)picker;
{
    color = [UIColor fromHex:color.hexString];
    self.fontOption.color = [color colorWithAlphaComponent:self.colorAlpha];
    self.color = color;
    picker.color = color;

    if(self.currentColorBtn)
    {
        
        CGFloat x = self.toolbarNipple.frame.origin.x;
        CGPoint o = [self.toolbar convertPoint:self.oldColorBtn.center toView:self.toolbarNipple.superview];
        CGPoint o2 = [self.toolbar convertPoint:self.currentColorBtn.center toView:self.toolbarNipple.superview];
        NSString *hexString = nil;
        if(!self.hasOldColor || (!color || !self.oldColor || [color isEqualToColor:self.oldColor]))
        {
            if(!self.oldColor) { self.oldColor = color; }
            if(!self.oldColorBtn.backgroundColor && self.oldColor) self.oldColorBtnColor = self.oldColor;
            else if(!self.hasOldColor && color) self.oldColorBtnColor=color;
            x = !color && !self.selectedColor && !self.oldColor ? -20 : o.x - (self.toolbarNipple.frame.size.width/2);
            self.currentColorBtnColor = nil;
            if(self.showHexValues && self.hasInit)
            {
                if(color && !self.hasOldColor) hexString = [[color hexString] uppercaseString];
                else hexString = self.title ? nil : @"COLOR";
            }
        }
        else
        {
            if(self.showHexValues && self.hasInit) hexString = [[color hexString] uppercaseString];
            x = o2.x - (self.toolbarNipple.frame.size.width/2);
            self.currentColorBtnColor = [color.displayColor colorWithMinBrightness:self.toolbar.superview.backgroundColor.brightness+0.05];
        }
        if(self.hexLabel && self.showHexValues) [self setHexLabelText:self.hasInit ? hexString : nil];
        [MysticUIView animate:0.3 animations:^{ self.toolbarNipple.frame = CGRectX(self.toolbarNipple.frame, x); }];
        
    }
    if(self.sendFinished && self.changed) self.changed(self.color, self.selectedColor, self.selectedColorPoint, self.threshold, self.selectedColorIndex, self, NO);
    if(self.sendDelegateMethods &&  self.delegate && [self.delegate respondsToSelector:@selector(inputViewSetColor:finished:)])
        [self.delegate inputViewSetColor:self finished:self.touchesEnded];
    self.hasInit = YES;
}
- (BOOL) sendDelegateMethods; { return self.sendFinished && _sendDelegateMethods; }
- (void) setOldColorBtnColor:(UIColor *)color;
{
    if(!self.oldColorBtn) return;
    
    if(color && color.hsb.brightness <= 0.15)
    {
        self.oldColorBtn.layer.borderWidth=2;
        self.oldColorBtn.layer.borderColor=[UIColor fromHex:@"34312F"].CGColor;
    }
    else
    {
        self.oldColorBtn.layer.borderWidth=0;
        self.oldColorBtn.layer.borderColor=UIColor.clearColor.CGColor;
    }
    
    self.oldColorBtn.backgroundColor = color;
}

- (void) setCurrentColorBtnColor:(UIColor *)color;
{
    if(!self.currentColorBtn) return;
    
//    DLog(@"set current color:  %@   %@", ColorStr(color), color.hexString);
    if(color && color.alpha>0 && color.hsb.brightness <= 0.2 )
    {
        self.currentColorBtn.layer.borderWidth=2;
        self.currentColorBtn.layer.borderColor=[UIColor fromHex:@"34312F"].CGColor;
    }
    else
    {
        self.currentColorBtn.layer.borderWidth=0;
        self.currentColorBtn.layer.borderColor=nil;
    }
    
    self.currentColorBtn.backgroundColor = color;
}
-(void)tunePicked:(MysticThreshold)tune forPicker:(ILTunePickerView *)picker;
{
    self.threshold = tune;
    if(self.sendFinished && self.changed) self.changed(self.color, self.selectedColor, self.selectedColorPoint, self.threshold, self.selectedColorIndex, self, NO);
    if(self.sendDelegateMethods && self.delegate && [self.delegate respondsToSelector:@selector(inputViewChangedThreshold:picker:)])
        [self.delegate inputViewChangedThreshold:self picker:picker];
}
- (void)pickerTouchesBegan:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    self.touchesEnded = NO;
    self.hasOldColor= (!self.oldColor && !self.oldColorBtn.backgroundColor) ? NO : YES ;

    if(self.sendDelegateMethods && self.delegate && [self.delegate respondsToSelector:@selector(inputViewTouchesBegan:picker:touches:event:)])
        [self.delegate inputViewTouchesBegan:self picker:picker touches:touches event:event];
}
- (void)pickerTouchesMoved:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    if(self.sendDelegateMethods && self.delegate && [self.delegate respondsToSelector:@selector(inputViewTouchesMoved:picker:touches:event:)])
        [self.delegate inputViewTouchesMoved:self picker:picker touches:touches event:event];
}
- (void)pickerTouchesEnded:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    self.touchesEnded = YES;

    self.hasOldColor=YES;

    if(self.sendDelegateMethods && self.delegate && [self.delegate respondsToSelector:@selector(inputViewTouchesEnded:picker:touches:event:)])
        [self.delegate inputViewTouchesEnded:self picker:picker touches:touches event:event];
}
- (void)pickerTouchesCancelled:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    self.touchesEnded = YES;

    if(self.sendDelegateMethods && self.delegate && [self.delegate respondsToSelector:@selector(inputViewTouchesCancelled:picker:touches:event:)])
        [self.delegate inputViewTouchesCancelled:self picker:picker touches:touches event:event];
}

- (void) oldColorTouched:(id)sender;
{
    self.picker.color = self.oldColor;
    [self colorPicked:self.oldColor forPicker:self.picker];
    if(self.sendDelegateMethods && self.delegate && self.allowEyeDropper && [self.delegate respondsToSelector:@selector(inputViewSelectedColorTouched:)])
        [self.delegate inputViewSelectedColorTouched:self];
}

- (void) newColorTouched:(id)sender;
{
    self.picker.color = self.color;
    if(self.sendDelegateMethods &&  self.delegate && [self.delegate respondsToSelector:@selector(inputViewColorTouched:)])
        [self.delegate inputViewColorTouched:self];
}

- (UIView *) makeInputAccessoryView;
{
    MysticLayerToolbar *toolbar = [MysticLayerToolbar toolbarWithDelegate:self height:MYSTIC_UI_TOOLBAR_ACCESSORY_HEIGHT];
    toolbar.tag = MysticViewTypeToolbar;
    CGSize toolbarIconSize = (CGSize){35,35};
    
    MysticBlockButtonItem confirmBlock = (^MysticButton *(MysticButton *button, MysticBarButtonItem *item){
        item.width = 60;
        return button;
    });
    
    MysticBlockObj *b = [[MysticBlockObj alloc] init];
    b.buttonBlock = confirmBlock;
    CGFloat nippleX = -1;
    switch (self.type) {
        case MysticInputTypeColor:
        {
            CGRect nf = (CGRect){0,0,18,18};
            MysticBarColorButton *oldColorBtn = [[MysticBarColorButton alloc] initWithFrame:nf];
            MysticBarColorButton *currentColorBtn = [[MysticBarColorButton alloc] initWithFrame:nf];
            
            oldColorBtn.layer.cornerRadius = nf.size.height/2;
            currentColorBtn.layer.cornerRadius = nf.size.height/2;

            UIColor *oc = self.oldColor ? self.oldColor.displayColor : self.color.displayColor;
            self.oldColorBtnColor = oc;
            
            
            
            [oldColorBtn addTarget:self action:@selector(oldColorTouched:) forControlEvents:UIControlEventTouchUpInside];
            [currentColorBtn addTarget:self action:@selector(newColorTouched:) forControlEvents:UIControlEventTouchUpInside];

            self.oldColorBtn = oldColorBtn;
            self.currentColorBtn = currentColorBtn;
            
            CGFloat toolWidth = 56.0f;
            CGFloat paddingWidth = MYSTIC_UI_TOOLBAR_MARGIN;
            CGRect hexLabelFrame = CGRectMake(0, 0, [MysticUI size].width-(toolWidth*2) - (paddingWidth*6), toolbar.frame.size.height);
            
            
            MysticToolbarTitleButton *hexLabel = (MysticToolbarTitleButton *)[MysticToolbarTitleButton button:nil action:nil];
            hexLabel.frame = hexLabelFrame;
            hexLabel.canSelect = NO;
            hexLabel.backgroundColor = [UIColor clearColor];
            hexLabel.tag = MysticUITypeLabel;
            hexLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            hexLabel.textAlignment = NSTextAlignmentCenter;
            hexLabel.toolType = MysticToolTypeBrowsePacks;
            hexLabel.enabled = NO;
            nippleX = 18.5;
            [hexLabel addTarget:self action:@selector(hexLabelTouched:) forControlEvents:UIControlEventTouchUpInside];
            
            self.hexLabel = hexLabel;
            [self setHexLabelText:self.title ? nil : @"COLOR"];
            
            [toolbar useItems:@[
                                @{@"toolType": @(MysticToolTypeStatic),
                                  @"width":@(4)},
                                
                                
                                
                                @{@"toolType": @(MysticToolTypeCustom),
                                  @"target": [NSNull null],
                                  @"action": [NSNull null],
                                  @"eventAdded": @YES,
                                  @"view": oldColorBtn,
                                  @"width": @(nf.size.width+5),
                                  @"objectType":@(MysticObjectTypeColor)},
                                
                                @{@"toolType": @(MysticToolTypeStatic),
                                  @"width":@(5)},
                                
                                @{@"toolType": @(MysticToolTypeCustom),
                                  @"target": [NSNull null],
                                  @"action": [NSNull null],
                                  @"eventAdded": @YES,
                                  @"view": currentColorBtn,
                                  @"width": @(nf.size.width+5),
                                  @"objectType":@(MysticObjectTypeColor)},
                                

                                
                                @(MysticToolTypeFlexible),
                              @{@"toolType": @(MysticToolTypeCustom),
                                @"target": [NSNull null],
                                @"action": [NSNull null],
                                @"eventAdded": @YES,
                                @"view": hexLabel,
                                @"objectType":@(MysticObjectTypeColor)},
                                @(MysticToolTypeFlexible),

                                
                                @{@"toolType": @(MysticToolTypeConfirm),
                                  @"target": self,
                                  @"action": @"toolbarDone:",
                                  @"iconType":@(MysticIconTypeConfirmFat),
                                  @"eventAdded": @YES,
                                  @"color": @(MysticColorTypeInputConfirm),
                                  @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                                  @"colorSelected":@(MysticColorTypeMenuIconSelected),
                                  @"block": [[confirmBlock copy] autorelease],
                                  @"contentMode": @(UIViewContentModeCenter),
                                  @"iconSize": [NSValue valueWithCGSize:(CGSize){17,13}],
                                  @"objectType":@(MysticObjectTypeFont)},
                                
                                
                                @{@"toolType": @(MysticToolTypeStatic),
                                  @"width":@(-17),
                                  @"objectType":@(MysticObjectTypeFont)},
                                
                                
                                ]];
            [oldColorBtn release];
            [currentColorBtn release];
            
            break;
        }
            
        default:
        {
            [toolbar useItems:@[
                                @{@"toolType": @(MysticToolTypeStatic),
                                  @"width":@(-10)},
                                
                                
                                @(MysticToolTypeFlexible),
                                
                                
                                
                                @{@"toolType": @(MysticToolTypeConfirm),
                                  @"target": self,
                                  @"action": @"toolbarDone:",
                                  @"iconType":@(MysticIconTypeToolBarConfirm),
                                  @"eventAdded": @YES,
                                  @"color": @(MysticColorTypeMenuIcon),
                                  @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                                  @"colorSelected":@(MysticColorTypeMenuIconSelected),
                                  @"block": [[confirmBlock copy] autorelease],
                                  @"contentMode": @(UIViewContentModeCenter),
                                  @"iconSize": [NSValue valueWithCGSize:(CGSize){30,30}],
                                  @"objectType":@(MysticObjectTypeFont)},
                                
                                
                                @{@"toolType": @(MysticToolTypeStatic),
                                  @"width":@(-17),
                                  @"objectType":@(MysticObjectTypeFont)},
                                ]];
            break;
        }
    }
    toolbar.backgroundColor = [UIColor clearColor];
    toolbar.opaque = YES;
    CGRect toolbarFrame = toolbar.frame;
    CGRect borderFrame = toolbar.frame;
    CGFloat borderWidth = 3;
    borderFrame.size.height += borderWidth;
    MysticBorderView *border = nil;
    if(self.showToolbarBorder)
    {
        border = [[MysticBorderView alloc] initWithFrame:borderFrame];
        border.borderWidth = borderWidth;
        border.borderPosition = MysticPositionTop;
        border.borderColor = [UIColor color:MysticColorTypePanelBorderColor];
        border.showBorder = YES;
    }
    else {  border = (id)[[UIView alloc] initWithFrame:borderFrame]; }
    border.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:1.00];
    toolbar.frame = self.showToolbarBorder ? CGRectY(toolbarFrame, borderWidth) : CGRectY(toolbarFrame, borderWidth);
    [border addSubview:toolbar];
    self.toolbar = toolbar;
    if(nippleX != -1)
    {
        UIImageView *nippleView = nil;
        __block CGRect nippleFrame = CGRectZero;
        nippleView = [[UIImageView alloc] initWithFrame:(CGRect){0,0,20,10}];
        nippleView.image = [MysticImage image:@(MysticIconTypeNippleTop) size:nippleView.frame.size color:@(MysticColorTypeInputBackground)];
        nippleFrame = CGRectAlign(nippleView.frame, border.frame, MysticAlignTypeBottom);
        nippleView.frame = CGRectAddXY(nippleFrame, -20,2);
        nippleView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [border addSubview:[nippleView autorelease]];
        self.toolbarNipple = nippleView;
    }
    return [border autorelease];
}
- (MysticButton *) confirmBtn;
{
    return (MysticButton *)[(MysticLayerToolbar *)[self.toolbar viewWithTag:MysticViewTypeToolbar] buttonForType:MysticToolTypeConfirm];
}
- (void) setTitle:(NSString *)title;
{
    if(_title) [_title release],_title=nil;
    if(title) _title = [title retain];
    [self setHexLabelText:nil];
}
- (void) setHexLabelText:(NSString *)labelTitle;
{
    if((labelTitle || self.title) && self.hexLabel)
    {
        if([[self.hexLabel attributedTitleForState:UIControlStateNormal].string isEqualToString:labelTitle ? labelTitle : self.title]) return;
        NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:labelTitle ? labelTitle : self.title];
        [attrStr setFont:[MysticUI gothamBold:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
        if([labelTitle hasPrefix:@"#"])
        {
            [attrStr addAttribute:NSForegroundColorAttributeName
                            value:[UIColor color:MysticColorTypeInputToolbarText]
                            range:NSMakeRange(1, labelTitle.length-1)];
            [attrStr addAttribute:NSForegroundColorAttributeName
                            value:[UIColor color:MysticColorTypeInputToolbarTextPrefix]
                            range:NSMakeRange(0, 1)];
        }
        else [attrStr addAttribute:NSForegroundColorAttributeName
                             value:[UIColor color:MysticColorTypeInputToolbarText]
                             range:NSMakeRange(0, [labelTitle ? labelTitle : self.title length])];
        [attrStr setCharacterSpacing:MYSTIC_UI_LABEL_BTN_CHAR_SPACE];
        [self.hexLabel setAttributedTitle:attrStr forState:UIControlStateNormal];
        self.hexLabel.ready=YES;
        [self.hexLabel updateState];
    }
}

- (void) hexLabelTouched:(MysticToolbarTitleButton *)sender;
{
    MysticBlockSender actionCopy = ^(NSDictionary *obj){
        
        MysticAlert *a = obj[@"alert"];
        if(a)
        {
            NSString *v = a.firstInput.text;
            if(v && v.length)
            {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = v;
            }
        }
        
    };
    NSString *hexstr = self.color.hexStringWithoutHash;
    hexstr = hexstr && hexstr.length ? hexstr : @"";
    MysticAlert *alert = [MysticAlert input:@"Color Code" message:nil action:^(id obj1, MysticAlert *obj2) {
        
        NSString *v = obj2.firstInput.text;
        if([v hasPrefix:@"#"]) v = [v substringFromIndex:1];
        if([v length] == 6)
        {
            self.oldColor = self.color;
            self.color = [UIColor hex:v];
            [self showInView:self.containerView type:self.type];
        }
    } cancel:^(id obj1, id obj2) {
        [self showInView:self.containerView type:self.type];
    } inputs:@[@{@"text": hexstr, @"placeholder": @"FFFFFF"}] options:@{@"buttons":@[@{@"title":@"Copy",@"action":actionCopy}]}];
    
}

- (void) toolbarDone:(id)sender;
{
    BOOL foundColor = NO;
    NSInteger replaceColor = NSNotFound;
    NSInteger r = 0;
    if(self.oldColor)
    {
        for (UIColor *color in userColors) {
            if([self.oldColor isEqualToColor:color])
            {
                replaceColor = r;
                break;
            }
            r++;
            
        }
    }
    for (UIColor *color in userColors) {
        if([self.color isEqualToColor:color])
        {
            foundColor = YES;
            break;
        }
    }
    
    if(replaceColor != NSNotFound && ![self.oldColor isEqualToColor:self.color])
    {
        [userColors replaceObjectAtIndex:replaceColor withObject:self.color];
    }
    else if(!foundColor && self.color)
    {
        [userColors insertObject:self.color atIndex:0];
    }
    [self dismiss];
}


- (UIView *) inputView;
{
    CGRect newFrame = (CGRect){0,0, [MysticUI screen].width, self.keyboardRect.size.height- MYSTIC_UI_TOOLBAR_ACCESSORY_HEIGHT};
    UIView *inputView = [[UIView alloc] initWithFrame:newFrame];
    inputView.backgroundColor = [UIColor color:MysticColorTypeInputBackground];
    CGFloat bottomOffset = 26;
    self.colorAlpha = self.colorAlpha;
    switch (self.type) {
        case MysticInputTypeColor:
        {
            CGRect chipFrame = CGRectInset(inputView.frame, 15, 15);
            if(self.showColors)
            {
                CGFloat colorBtnSize = 26;
                CGFloat colorBtnBorderSize = 4;
                __block MysticColorsScrollView *colors = [[MysticColorsScrollView alloc] initWithFrame:(CGRect){chipFrame.origin.x, chipFrame.origin.y, chipFrame.size.width, colorBtnSize+colorBtnBorderSize*2}];
                colors.tileSize = (CGSize){colorBtnSize+3,colorBtnSize+3};
                colors.controlDelegate = self;
                colors.showsControlAccessory = NO;
                //                colors.tileOrigin = (CGPoint){-6,0};
                colors.clipsToBounds = YES;
                NSArray *theColorsCore = [[Mystic core] colorsForOption:(PackPotionOption *)self.targetOption option:self.colorType setting:self.setting];
                NSMutableArray *theColors = [NSMutableArray array];
                for (UIColor *color in userColors) {
                    BOOL foundColor = NO;
                    for (PackPotionOptionColor *coreColor in theColorsCore) {
                        if([coreColor.color isEqualToColor:color])
                        {
                            foundColor = YES;
                            break;
                        }
                    }
                    if(!foundColor)
                    {
                        PackPotionOptionColor *newColor = [PackPotionOptionColor option];
                        newColor.color = color;
                        [theColors addObject:newColor];
                    }
                }
                [theColors addObjectsFromArray:theColorsCore];
                for (PackPotionOptionColor *c in theColors) {
                    c.selectedSize = (CGSize){colorBtnSize+3,colorBtnSize+3};
                    c.unselectedSize = (CGSize){colorBtnSize,colorBtnSize};
                    c.borderWidth = colorBtnBorderSize;
                }
                
                [colors loadControls:theColors selectIndex:MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX animated:NO complete:^{
                    EffectControl *s = (EffectControl *)colors.selectedItem;
                    if(s) [s.effect updateLabel:nil control:s selected:YES];
                    else for (EffectControl *ec in colors.subviews) [ec.effect updateLabel:nil control:ec selected:NO];
                }];
                
                colors.showsHorizontalScrollIndicator=NO;
                colors.showsVerticalScrollIndicator=NO;
                colors.directionalLockEnabled = YES;
                [inputView addSubview:colors];
                chipFrame.origin.y += kColorPickerSpacing + colors.frame.size.height;
                chipFrame.size.height -= kColorPickerSpacing + colors.frame.size.height;
                [colors release];
                
            }
            
            if(self.showRemoveButton)
            {
                __unsafe_unretained __block MysticInputView *weakSelf = self;
                MysticButton *btn = [MysticButton button:[MysticIcon iconForType:MysticIconTypeXThick size:(CGSize){10,10} color:[UIColor color:MysticColorTypeInputToolbarText]] action:^(MysticButton *sender) {
                    NSInteger i = 0;
                    if(weakSelf.sendDelegateMethods && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(inputViewNumberOfColors:)])
                        i = [weakSelf.delegate inputViewNumberOfColors:weakSelf];
                    if(i<=1)
                    {
                        if(weakSelf.sendDelegateMethods && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(inputViewRemoveTouched:)])
                            [weakSelf.delegate inputViewRemoveTouched:weakSelf];
                        weakSelf.showDropper=NO;
                        weakSelf.selectedColor=nil;
                        weakSelf.oldColor = nil;
                        weakSelf.color = nil;
                        weakSelf.showDropper = NO;
                        weakSelf.toolbarNipple.frame = CGRectX(weakSelf.toolbarNipple.frame, -20);
                        weakSelf.currentColorBtn.backgroundColor = nil;
                        weakSelf.oldColorBtnColor = nil;
                        weakSelf.picker.userInteractionEnabled = NO;
                        
                        [weakSelf dismiss];
                        return;
                        /*
                        MysticAttrString *attrStr = [MysticAttrString string:@"TAP A COLOR IN PHOTO\n\nand adjust it using the tools below.\n\nTo adjust another color, \ntap & hold on any spot in your photo\nor tap the " MYSTIC_TEXT_PLUS " button" style:MysticStringStyleInputPickColor];
                        
                        weakSelf.pickColorBtn = [MysticButton button:attrStr action:^(MysticButton *sender2) {
                            [weakSelf setHexLabelText:self.selectedColorWithColorTitle];
                            weakSelf.confirmBtn.enabled=YES;
                            weakSelf.removeBtn.enabled=YES;
                            [MysticUIView animateKeyframesWithDuration:0.5 delay:0 options:nil animations:^{
                                [MysticUIView addKeyframeWithRelativeStartTime:0.2/0.5 relativeDuration:0.3/0.5 animations:^{
                                    weakSelf.pickColorBtn.alpha = 0;
                                    weakSelf.confirmBtn.alpha=1;
                                }];
                                [MysticUIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.2/0.5 animations:^{
                                    UIView *_ok = [weakSelf.pickColorBtn viewWithTag:MysticViewTypeButton1];
                                    _ok.alpha=0;
                                    _ok.transform=CGAffineTransformMakeTranslation(0, 20);
                                }];
                            } completion:^(BOOL finished) {
                                [weakSelf.pickColorBtn removeFromSuperview];
                                weakSelf.pickColorBtn=nil;
                            }];
                        }];
                        sender.enabled=NO;
                        weakSelf.pickColorBtn.titleEdgeInsets = UIEdgeInsetsMake(-35,0,0,0);
                        weakSelf.pickColorBtn.frame = newFrame;
                        weakSelf.pickColorBtn.backgroundColor = [[weakSelf.removeBtn.superview.backgroundColor alpha:0.95] lighter:0.1];
                        weakSelf.pickColorBtn.alpha = 0;
                        
                        MysticAttrString *okAttr = [MysticAttrString string:@"OK" style:MysticStringStyleInputBlack state:UIControlStateHighlighted];
                        MysticAttrString *okAttrH = [MysticAttrString string:@"OK" style:MysticStringStyleInputBlack];
                        MysticButton *okBtn = [MysticButton button:okAttr action:^(MysticButton *sender3) {
                            [weakSelf setHexLabelText:self.selectedColorWithColorTitle];
                            weakSelf.confirmBtn.enabled=YES;
                            weakSelf.removeBtn.enabled=YES;
                            [MysticUIView animateKeyframesWithDuration:0.5 delay:0 options:nil animations:^{
                                [MysticUIView addKeyframeWithRelativeStartTime:0.2/0.5 relativeDuration:0.3/0.5 animations:^{
                                    weakSelf.pickColorBtn.alpha = 0;
                                    weakSelf.confirmBtn.alpha=1;
                                }];
                                [MysticUIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.2/0.5 animations:^{
                                    UIView *_ok = [weakSelf.pickColorBtn viewWithTag:MysticViewTypeButton1];
                                    _ok.alpha=0;
                                    _ok.transform=CGAffineTransformMakeTranslation(0, 20);
                                }];
                            } completion:^(BOOL finished) {
                                [weakSelf.pickColorBtn removeFromSuperview];
                                weakSelf.pickColorBtn=nil;
                            }];
                            
                            
                        }];
                        [okBtn setAttributedTitle:okAttrH.attrString forState:UIControlStateHighlighted];
                        okBtn.frame = CGRectXYWH(okBtn.frame, CGPointCenter(newFrame).x - (okBtn.frame.size.width+10)/2, CGPointCenter(newFrame).y + 15 + attrStr.size.height/2, okBtn.frame.size.width+20, okBtn.frame.size.height-10);
                        okBtn.frame = CGRectAddY(okBtn.frame, weakSelf.pickColorBtn.titleEdgeInsets.top+20);
                        okBtn.transform = CGAffineTransformMakeTranslation(0, 20);
                        okBtn.layer.cornerRadius = CGRectH(okBtn.frame)/2;
                        okBtn.layer.borderWidth =1.5;
                        okBtn.alpha = 0;
                        okBtn.tag = MysticViewTypeButton1;
                        [okBtn setBorderColor:[UIColor hex:@"695D56"] forState:UIControlStateHighlighted];
                        [okBtn setBorderColor:[UIColor color:MysticColorTypePink] forState:UIControlStateNormal];
                        [weakSelf.pickColorBtn addSubview:okBtn];
                        [weakSelf.removeBtn.superview addSubview:weakSelf.pickColorBtn];
                        [MysticUIView animateKeyframesWithDuration:0.5 delay:0 options:nil animations:^{
                            [MysticUIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.3/0.5 animations:^{
                                weakSelf.confirmBtn.alpha = 0;
                                weakSelf.pickColorBtn.alpha = 1;
                            }];
                            [MysticUIView addKeyframeWithRelativeStartTime:0.3/0.5 relativeDuration:0.2/0.5 animations:^{
                                UIView *_ok = [weakSelf.pickColorBtn viewWithTag:MysticViewTypeButton1];
                                _ok.alpha=1;
                                _ok.transform=CGAffineTransformIdentity;
                            }];
                        } completion:^(BOOL finished) {
                            weakSelf.confirmBtn.enabled = NO;
                        }];
                        [MysticUIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{ sender.alpha=0; } completion:^(BOOL f) { sender.hidden = YES; }];
                        return;
                         */
                    }
                    MysticBlockObject bl = Block_copy(^(id obj){
                        weakSelf.showDropper=NO;
                        weakSelf.selectedColor=nil;
                        weakSelf.oldColor = nil;
                        weakSelf.colorAndPicker = nil;
                        if(weakSelf.sendDelegateMethods && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(inputViewRemoveAllTouched:)])
                            [weakSelf.delegate inputViewRemoveAllTouched:weakSelf];
                    });
                    [[MysticAlert alert:@"Remove All?" message:@"Do you want to remove this color or all of them?" action:^(id obj1, id obj2) {
                        if(weakSelf.sendDelegateMethods && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(inputViewRemoveTouched:)])
                            [weakSelf.delegate inputViewRemoveTouched:weakSelf];
                    } cancel:^(id obj1, id obj2) { } options:@{@"button":@"Remove", @"buttons":@[@{@"title":@"Remove All",@"action":bl}]}] showWithKeyboard:nil];
                    Block_release(bl);
                }];
                [btn setImage:[MysticIcon iconForType:MysticIconTypeXThick size:(CGSize){10,10} color:[UIColor color:MysticColorTypePink]] forState:UIControlStateHighlighted];
                btn.frame = CGRectXYH(btn.frame, chipFrame.origin.x, CGRectH(chipFrame)-bottomOffset+chipFrame.origin.y, 30);

                btn.hitInsets=UIEdgeInsetsMake(10, 10, 10, 10);
                [inputView addSubview:btn];
                self.removeBtn=btn;
            }
            if(self.showNewButton)
            {
                __unsafe_unretained __block MysticInputView *weakSelf = self;
                MysticButton *btn = [MysticButton button:[MysticIcon iconForType:MysticIconTypeToolPlus size:(CGSize){12,12} color:[UIColor color:MysticColorTypeInputToolbarText]] action:^(id sender) {
                    if(weakSelf.sendDelegateMethods && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(inputViewNewTouched:)])
                        [weakSelf.delegate inputViewNewTouched:weakSelf];
                    [weakSelf setHexLabelText:self.selectedColorWithColorTitle];
                    if(weakSelf.removeBtn && weakSelf.removeBtn.hidden)
                    {
                        weakSelf.removeBtn.alpha = 0;
                        weakSelf.removeBtn.hidden = NO;
                        [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                            weakSelf.removeBtn.alpha = 1;
                        }];
                    }
                }];
                [btn setImage:[MysticIcon iconForType:MysticIconTypeToolPlus size:(CGSize){12,12} color:[UIColor color:MysticColorTypePink]] forState:UIControlStateHighlighted];
                btn.frame = CGRectXYH(btn.frame, CGRectGetMaxX(chipFrame)-CGRectW(btn.frame), CGRectH(chipFrame)-bottomOffset+chipFrame.origin.y, 30);
                btn.hitInsets=UIEdgeInsetsMake(10, 10, 10, 10);
                [inputView addSubview:btn];
                self.addBtn=btn;
            }
            if(self.showColorTools)
            {
                __unsafe_unretained __block MysticInputView *weakSelf = self;
                UIView *colorTools = [[UIView alloc] initWithFrame:CGRectYH(chipFrame, CGRectH(chipFrame)-bottomOffset+chipFrame.origin.y, 30)];
                MysticAttrString *attrStr = [MysticAttrString string:@"RGB" style:MysticStringStyleInputToolbarBottom];
                MysticAttrString *attrStrH = [MysticAttrString string:attrStr style:MysticStringStyleInputToolbarBottom state:UIControlStateSelected];
//                
//                MysticButton *rgbBtn = [MysticButton button:attrStr action:^(MysticButton* sender) {
//                    sender.selected = YES;
//                    for (MysticButton*b in sender.siblings) b.selected = NO;
//                    weakSelf.picker.mode = ColorPickerModeRGB;
////                    [MysticUser setTemp:@(ColorPickerModeRGB) key:@"color-input-mode"];
//                    if(weakSelf.sendDelegateMethods && [weakSelf.delegate respondsToSelector:@selector(inputViewSwitchedMode:)])
//                        [weakSelf.delegate inputViewSwitchedMode:weakSelf];
//                }];
//                [rgbBtn setAttributedTitle:attrStrH.attrString forState:UIControlStateSelected];
//                rgbBtn.tag = MysticViewTypeButton1;
                attrStr = [MysticAttrString string:@"HSB" style:MysticStringStyleInputToolbarBottom];
                attrStrH = [MysticAttrString string:attrStr style:MysticStringStyleInputToolbarBottom state:UIControlStateSelected];
                MysticButton *hsbBtn = [MysticButton button:attrStr action:^(MysticButton* sender) {
                    sender.selected=YES;
                    for (MysticButton*b in sender.siblings) b.selected = NO;
                    weakSelf.picker.mode = ColorPickerModeHSB;
//                    [MysticUser setTemp:@(ColorPickerModeHSB) key:@"color-input-mode"];
                    if(weakSelf.sendDelegateMethods && [weakSelf.delegate respondsToSelector:@selector(inputViewSwitchedMode:)])
                        [weakSelf.delegate inputViewSwitchedMode:weakSelf];
                }];
                [hsbBtn setAttributedTitle:attrStrH.attrString forState:UIControlStateSelected];
                hsbBtn.tag = MysticViewTypeButton2;
                
                attrStr = [MysticAttrString string:@"HUE" style:MysticStringStyleInputToolbarBottom];
                attrStrH = [MysticAttrString string:attrStr style:MysticStringStyleInputToolbarBottom state:UIControlStateSelected];
                MysticButton *hueBtn = [MysticButton button:attrStr action:^(MysticButton* sender) {
                    sender.selected=YES;
                    for (MysticButton*b in sender.siblings) b.selected = NO;
                    weakSelf.picker.mode = ColorPickerModeTone;
//                    [MysticUser setTemp:@(ColorPickerModeTone) key:@"color-input-mode"];
                    if(weakSelf.sendDelegateMethods && [weakSelf.delegate respondsToSelector:@selector(inputViewSwitchedMode:)])
                        [weakSelf.delegate inputViewSwitchedMode:weakSelf];
                }];
                [hueBtn setAttributedTitle:attrStrH.attrString forState:UIControlStateSelected];
                hueBtn.tag = MysticViewTypeButton3;
                
                
                attrStr = [MysticAttrString string:@"TUNE" style:MysticStringStyleInputToolbarBottom];
                attrStrH = [MysticAttrString string:attrStr style:MysticStringStyleInputToolbarBottom state:UIControlStateSelected];
                MysticButton *tuneBtn = [MysticButton button:attrStr action:^(MysticButton* sender) {
                    sender.selected=YES;
                    for (MysticButton*b in sender.siblings) b.selected = NO;
                    weakSelf.picker.mode = ColorPickerModeTune;
//                    [MysticUser setTemp:@(ColorPickerModeTune) key:@"color-input-mode"];
                    if(weakSelf.sendDelegateMethods && [weakSelf.delegate respondsToSelector:@selector(inputViewSwitchedMode:)])
                        [weakSelf.delegate inputViewSwitchedMode:weakSelf];
                }];
                [tuneBtn setAttributedTitle:attrStrH.attrString forState:UIControlStateSelected];
                tuneBtn.tag = MysticViewTypeButton4;
                
                CGFloat div = 30;
                hueBtn.frame = CGRectHeight(hueBtn.frame,colorTools.frame.size.height);
//                rgbBtn.frame = CGRectXH(hueBtn.frame, hueBtn.frame.size.width+div,colorTools.frame.size.height);
                hsbBtn.frame = CGRectXH(hsbBtn.frame, CGRectGetMaxX(hueBtn.frame)+div,colorTools.frame.size.height);
                tuneBtn.frame = CGRectXH(tuneBtn.frame, CGRectGetMaxX(hsbBtn.frame)+div,colorTools.frame.size.height);
                
                switch(self.colorPickerMode)
                {
                    case ColorPickerModeHSB: hsbBtn.selected = YES; break;
                    case ColorPickerModeTone: hueBtn.selected = YES; break;
                    case ColorPickerModeTune: tuneBtn.selected = YES; break;
                    default: /*rgbBtn.selected = YES;*/ break;
                }
                [colorTools addSubview:hueBtn];
//                [colorTools addSubview:rgbBtn];
                [colorTools addSubview:hsbBtn];
                [colorTools addSubview:tuneBtn];
                [colorTools centerViews:nil];
                [inputView addSubview:colorTools];
                chipFrame.size.height -= kColorPickerSpacing + 30;
            }
            ILColorPickerView *picker = [[ILColorPickerView alloc] initWithFrame:CGRectAddXH(chipFrame, 0, 30-bottomOffset)];
            picker.backgroundColor = inputView.backgroundColor;
            
            picker.delegate = (id <ILPickerDelegate>)self;
            if(self.color) picker.color = self.color;
            picker.mode = self.colorPickerMode;
            [picker setNeedsDisplay];
            [inputView addSubview:picker];
            self.picker = [picker autorelease];
            if(self.addBtn) [inputView bringSubviewToFront:self.addBtn];
            if(self.removeBtn) [inputView bringSubviewToFront:self.removeBtn];
            break;
        }
        case MysticInputTypeFont:
        {
            MysticFontListScrollView *scrollView = [[MysticFontListScrollView alloc] initWithFrame:inputView.bounds];
            scrollView.showsHorizontalScrollIndicator=NO;
            scrollView.showsVerticalScrollIndicator=NO;
            scrollView.directionalLockEnabled = YES;
            scrollView.backgroundColor = [inputView.backgroundColor lighter:0.05];
            CGRect f = CGRectMake(0, 0, inputView.bounds.size.width, 42);
            NSInteger i = 0;
            MysticButton *selectedFont = nil;
            for (PackPotionOptionFont *font in [Mystic core].fonts) {
                
                MysticButton *fontBtn = [[MysticButton alloc] initWithFrame:f];
                fontBtn.backgroundColor = inputView.backgroundColor;
                [fontBtn setTitleColor:[UIColor color:MysticColorTypeMenuText] forState:UIControlStateNormal];
                [fontBtn setTitleColor:[UIColor color:MysticColorTypePink] forState:UIControlStateSelected];
                [fontBtn setTitleColor:[UIColor color:MysticColorTypeMenuText] forState:UIControlStateHighlighted];
                [fontBtn setBackgroundColor:[UIColor blackColor] forState:UIControlStateSelected];
                [fontBtn setBackgroundColor:scrollView.backgroundColor forState:UIControlStateHighlighted];
                fontBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
                fontBtn.font = [font.font fontWithSize:18];
                fontBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
                fontBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [fontBtn addTarget:self action:@selector(fontSelected:) forControlEvents:UIControlEventTouchUpInside];
                [fontBtn setTitle:font.name forState:UIControlStateNormal];
                fontBtn.tag = MysticViewTypeButton1 + i;
                [scrollView addSubview:fontBtn];
                
                if(!selectedFont && [self.font.fontName isEqualToString:fontBtn.font.fontName])
                {
                    self.fontOption = font;
                    selectedFont = fontBtn;
                }
                
                f.origin.y = f.origin.y+ f.size.height + 1;
                i++;
                
            }
            scrollView.contentSize = (CGSize){scrollView.frame.size.width, f.origin.y};
            
            if(selectedFont)
            {
                selectedFont.selected = YES;
                [scrollView scrollRectToVisible:selectedFont.frame animated:YES];
            }
            [inputView addSubview:scrollView];
            break;
        }
        case MysticInputTypeFontEffect:
        {
            CGFloat h = inputView.frame.size.height/3;
            MysticLayerToolbar *effectToolbar = [MysticLayerToolbar toolbarWithDelegate:self height:h];
            CGSize toolbarIconSize = (CGSize){20,20};
            
            [effectToolbar useItems:@[
                                      @(MysticToolTypeNoMarginLeft),
                                      
                                      @(MysticToolTypeFlexible),
                                      @{@"toolType":@(MysticToolTypeAlignLeft),
                                        @"iconType": @(MysticIconTypeAlignLeft),
                                        @"color": @(MysticColorTypeMenuIcon),
                                        @"colorSelected": @(MysticColorTypeMenuIconSelected),
                                        @"target": self,
                                        @"action":@"fontAlignLeft:",
                                        @"useDelegate":@YES,
                                        @"iconSize": [NSValue valueWithCGSize:toolbarIconSize],
                                        @"selected": @(self.textAlignment == NSTextAlignmentLeft),
                                        
                                        },
                                      @(MysticToolTypeFlexible),
                                      @{@"toolType":@(MysticToolTypeAlignCenter),
                                        @"iconType": @(MysticIconTypeAlignCenter),
                                        @"color": @(MysticColorTypeMenuIcon),
                                        @"colorSelected": @(MysticColorTypeMenuIconSelected),
                                        @"target": self,
                                        @"action":@"fontAlignCenter:",
                                        @"useDelegate":@YES,
                                        @"iconSize": [NSValue valueWithCGSize:toolbarIconSize],
                                        @"selected": @(self.textAlignment == NSTextAlignmentCenter),
                                        
                                        },
                                      @(MysticToolTypeFlexible),
                                      @{@"toolType":@(MysticToolTypeAlignRight),
                                        @"iconType": @(MysticIconTypeAlignRight),
                                        @"color": @(MysticColorTypeMenuIcon),
                                        @"colorSelected": @(MysticColorTypeMenuIconSelected),
                                        @"target": self,
                                        @"action":@"fontAlignRight:",
                                        @"useDelegate":@YES,
                                        @"iconSize": [NSValue valueWithCGSize:toolbarIconSize],
                                        @"selected": @(self.textAlignment == NSTextAlignmentRight),
                                        
                                        },
                                      
                                      
                                      @(MysticToolTypeFlexible),
                                      @(MysticToolTypeNoMarginRight),
                                      
                                      
                                      ]];
            effectToolbar.tag = MysticToolTypeAlign;
            [inputView addSubview:effectToolbar];
            
            MysticFontSpacingControl *spacingControl = [[MysticFontSpacingControl alloc] initWithFrame:CGRectMake(165, h, 145, h)];
            MysticFontLineHeightControl *lineHeightControl = [[MysticFontLineHeightControl alloc] initWithFrame:CGRectMake(10, h, 145, h)];
            if(self.fontOption && [self.fontOption hasValues]) lineHeightControl.value = [self.fontOption lineHeightScale];
            if(self.fontOption && [self.fontOption hasValues]) spacingControl.value = [self.fontOption spacing];
            
            
            [spacingControl addTarget:self action:@selector(spacingControlChanged:) forControlEvents:UIControlEventValueChanged];
            [lineHeightControl addTarget:self action:@selector(lineHeightControlChanged:) forControlEvents:UIControlEventValueChanged];
            
            [inputView addSubview:spacingControl];
            [inputView addSubview:lineHeightControl];
            
            MysticBorderView *border = [[MysticBorderView alloc] initWithFrame:(CGRect){0,0,inputView.frame.size.width, inputView.frame.size.height}];
            border.borderPosition = MysticPositionThirdsHorizontal;
            border.borderColor = [inputView.backgroundColor lighter:0.05];
            border.borderWidth = 1;
            border.showBorder = YES;
            [inputView insertSubview:border atIndex:0];
            
            MysticSlider *slider = [MysticSlider sliderWithFrame:(CGRect){15,h*2,inputView.frame.size.width-30, h}];
            [slider addTarget:self action:@selector(opacitySliderChanged:) forControlEvents:UIControlEventValueChanged];
            slider.value = self.colorAlpha;
            slider.minimumValue = 0;
            slider.maximumValue = 1;
            slider.lowerHandleHidden = YES;
            slider.minimumRange = 0;
            [inputView addSubview:slider];
            break;
        }
        default: break;
    }
    return inputView;
}

@end


