//
//  EffectControl.m
//  Mystic
//
//  Created by travis weerts on 12/8/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#include <stdlib.h>

#import "EffectControl.h"
#import "MysticEffectsManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MysticController.h"
#import "UIView+Mystic.h"

@interface EffectControl ()
{
    BOOL _downloadingControlImage;
}
@end


@implementation EffectControl

static CGFloat overlayImageNippleHeight = 7;

@synthesize  imageView=_imageView, selectedOverlayView=_selectedOverlayView, cancelsEffect;
@synthesize effect=_effect, showLabel, titleLabel=_titleLabel, deselectable,  position, isLast, isFirst, action=_action, updatesSiblingsOnChange, insets=_insets, targetOption=_targetOption, backgroundView=_backgroundView, delegate=_delegate, accessoryView=_accessoryView, margin=_margin, wasSelected=_wasSelected;

+ (CGFloat) overlayNippleHeight
{
    return overlayImageNippleHeight;
}


- (void) dealloc
{
    
    _delegate = nil;
    [_backgroundView release];
    [_targetOption release], _targetOption=nil;
    [_selectedOverlayView release];
    [_titleLabel release];
    [_accessoryView release];
    [_effect release];
    [_imageView release];
    if(_action)
    {
        Block_release(_action);
    }
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame effect:(MysticControlObject *)effectObject action:(EffectContolAction)anAction;
{
    self = [self initWithFrame:frame effect:effectObject];
    
    if(self)
    {
        self.action = anAction;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame effect:(MysticControlObject *)effectObject;
{
    return [self initWithFrame:frame effect:effectObject position:NSNotFound];
}
- (id)initWithFrame:(CGRect)frame effect:(MysticControlObject *)effectObject position:(NSInteger)theIndex;
{
    return [self initWithFrame:frame effect:effectObject position:theIndex action:nil margin:kExtraWidth];
}
- (id)initWithFrame:(CGRect)frame effect:(MysticControlObject *)effectObject position:(NSInteger)theIndex action:(EffectContolAction)anAction;
{
    return [self initWithFrame:frame effect:effectObject position:theIndex action:anAction margin:kExtraWidth];
}
- (id)initWithFrame:(CGRect)frame effect:(MysticControlObject *)effectObject position:(NSInteger)theIndex action:(EffectContolAction)anAction margin:(CGFloat)margins;
{
    return [self initWithFrame:frame effect:effectObject position:theIndex action:anAction marginInsets:UIEdgeInsetsMake(margins, 0, 0, margins)];
}
- (id)initWithFrame:(CGRect)frame effect:(MysticControlObject *)effectObject position:(NSInteger)theIndex action:(EffectContolAction)anAction marginInsets:(UIEdgeInsets)marginInsets;
{
    self = [super initWithFrame:frame];
    if (self) {
        _margin = marginInsets.right;
        PackPotionOption *option = (PackPotionOption *)effectObject;
        _downloadingControlImage = NO;
        self.autoresizesSubviews = NO;
        self.clipsToBounds = NO;
        self.userInteractionEnabled = YES;
        self.position = theIndex;
        self.insets = marginInsets;
        self.wasSelected = super.selected;
        self.action = anAction ? anAction : effectObject.action ? effectObject.action : nil;
        _effect = [effectObject retain];
        [self stateWasUpdated];
    }
    return self;
}
- (void) commonInit;
{
    _margin = kExtraWidth;
}

- (void) setTitleLabel:(UILabel *)view;
{
    if(!view && _titleLabel) [_titleLabel removeFromSuperview];
    if(_titleLabel) [_titleLabel release],_titleLabel=nil;
    _titleLabel = !view ? nil : [view retain];
}
- (void) setImageView:(MysticImageView *)view;
{
    if(!view && _imageView) [_imageView removeFromSuperview];
    if(_imageView) [_imageView release],_imageView=nil;
    _imageView = !view ? nil : [view retain];
}
- (void) setSelectedOverlayView:(MysticImageView *)view;
{
    if(!view && _selectedOverlayView) [_selectedOverlayView removeFromSuperview];
    if(_selectedOverlayView) [_selectedOverlayView release],_selectedOverlayView=nil;
    _selectedOverlayView = !view ? nil : [view retain];
}
- (void) setBackgroundView:(MysticView *)view;
{
    if(!view && _backgroundView) [_backgroundView removeFromSuperview];
    if(_backgroundView) [_backgroundView release],_backgroundView=nil;
    _backgroundView = !view ? nil : [view retain];
}
- (BOOL) hasBackgroundView; { return _backgroundView!=nil; }
- (BOOL) hasImageView; { return _imageView!=nil; }
- (BOOL) hasSelectedOverlayView; { return _selectedOverlayView!=nil; }

- (MysticView *) backgroundView;
{
    if(!_backgroundView)
    {
        _backgroundView = [[MysticView alloc] initWithFrame:self.contentFrame];
        _backgroundView.debug = YES;
        _backgroundView.backgroundColor = [MysticColor colorWithType:MysticColorTypeControlInactive];
        _backgroundView.userInteractionEnabled = NO;
        [self addSubview:_backgroundView];
        [self sendSubviewToBack:_backgroundView];
    }
    return _backgroundView;
}
- (UILabel *) titleLabel;
{
    if(!self.showLabel) return nil;
    if(!_titleLabel)
    {
        CGRect insetFrame = UIEdgeInsetsInsetRect(self.bounds, _insets);
        UIFont *labelFont = [MysticUI gothamLight:10];
        CGRect labelFrame = insetFrame;
        labelFrame.size.height = labelFont.lineHeight*2;
        labelFrame.origin.y = insetFrame.size.height - labelFrame.size.height + insetFrame.origin.y;
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.hidden = YES;
        label.font = labelFont;
        _titleLabel = label;
        if(_selectedOverlayView)
        {
            [self insertSubview:_titleLabel belowSubview:_selectedOverlayView];
        }
        else
        {
            [self addSubview:_titleLabel];
        }
        [self updateLabel:NO];
    }
    return _titleLabel;
}
- (MysticImageView *) imageView;
{
    if(!_imageView)
    {
        MysticImageView *view = [[MysticImageView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, _insets)];
        view.backgroundColor = [UIColor clearColor];
        view.contentMode = UIViewContentModeScaleToFill;
        view.clipsToBounds = YES;
        _imageView = view;
        
        [self addSubview:_imageView];
    }
    return _imageView;
}
- (MysticImageView *) selectedOverlayView;
{
    if(!_selectedOverlayView)
    {
        MysticImageView *selectedOverlayView = [[MysticImageView alloc] initWithFrame:CGRectMake(_insets.left, _insets.top, self.frame.size.width-_insets.left-_insets.right, self.frame.size.height-_insets.top-_insets.bottom)];
        selectedOverlayView.userInteractionEnabled = YES;
        [selectedOverlayView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchUpInside:)] autorelease]];
        selectedOverlayView.backgroundColor = [UIColor clearColor];
        _selectedOverlayView = selectedOverlayView;
        if(self.hasImageView) [self insertSubview:_selectedOverlayView aboveSubview:_imageView];
        else [self addSubview:self.selectedOverlayView];
    }
    return _selectedOverlayView;
}
- (void) setCornerRadius:(CGFloat)radius;
{
    if(_imageView) _imageView.layer.cornerRadius = radius;
    if(self.hasBackgroundView) self.backgroundView.layer.cornerRadius = radius;
    if(_selectedOverlayView) _selectedOverlayView.layer.cornerRadius = radius;
    
}
- (void) blendingButtonTouched:(MysticButton *)sender;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(effectControlSettingsTouched:)])
    {
        [self.delegate effectControlSettingsTouched:self];
    }
}

- (void) cancelButtonTouched:(MysticButton *)sender;
{
    if([self.effect respondsToSelector:@selector(cancelEffect:)])
    {
        [self.effect cancelEffect:self];
        return;
    }
    self.selected = NO;
    self.effect.cancelsEffect = YES;
    [self.effect setUserChoice];
    
    [self didTouchUpInside:self];
    self.effect.cancelsEffect = NO;
}
- (void) setAccessoryView:(UIView *)accessoryView;
{
    [self setAccessoryView:accessoryView center:CGPointCenter(self.bounds)];
}
- (void) setAccessoryView:(UIView *)accessoryView center:(CGPoint)newCenter;
{
    if(_accessoryView) { [_accessoryView removeFromSuperview]; [_accessoryView release], _accessoryView=nil; }
    
    if(accessoryView)
    {
        _accessoryView = [accessoryView retain];
        _accessoryView.alpha = 0;
        _accessoryView.center = newCenter;
        [self addSubview:_accessoryView];
        [self bringSubviewToFront:_accessoryView];
        __unsafe_unretained __block UIView *__accessoryView = _accessoryView;
        [MysticUIView animateWithDuration:0.1f animations:^{
            __accessoryView.alpha = 1.0f;
        }];
        
    }
}

- (void) accessoryTouched:(id)sender;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(effectControl:accessoryTouched:)])
    {
        [self.delegate effectControl:self accessoryTouched:sender];
    }
}

- (void) setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    [self setFrame:self.frame];
    
}


- (void) toggle;
{
    [self didTouchDown:self];
    [self didTouchUpInside:self];
}
- (NSInteger) visiblePosition;
{
    return [self.delegate effectControlVisibilityIndex:self];
}
- (void) reuse;
{
//    self.pageControl.hidden = YES;
    self.targetOption = nil;
    if(self.effect && [self.effect respondsToSelector:@selector(prepareControlForReuse:)])
    {
        [self.effect prepareControlForReuse:self];
    }
}
- (UIScrollView *)scrollView;
{
    return (self.superview && [self.superview isKindOfClass:[UIScrollView class]]) ? (id)self.superview : nil;
}

- (UIColor *) currentBackgroundColor;
{
    if([self.effect respondsToSelector:@selector(controlCurrentBackgroundColor:)])
    {
        return [self.effect controlCurrentBackgroundColor:self];
    }
    else
    {
        if(self.hasBackgroundView)  return self.backgroundView.backgroundColor;
    }
    return [UIColor clearColor];
}
- (void) didTouchUpInside:(id) sender
{
    if(self.action)
    {
        self.action(self, self.selected);
    }
    else if(self.effect.action)
    {
        self.effect.action(self, self.selected);
    }
    else if([self.effect respondsToSelector:@selector(controlTouched:)])
    {
        [self.effect controlTouched:self];
    }
    else if(self.delegate && [self.delegate respondsToSelector:@selector(effectControlDidTouchUp:effect:)])
    {
        [self touchedUpEffect];
    }
    
    
}

- (void) didTouchDown:(id) sender
{
    if (self.scrollView.isDecelerating) return;
}
- (void) touchedUpEffect;
{
    [self touchedEffect];
    
    [self.delegate effectControlDidTouchUp:self effect:self.effect];
}
- (void) touchedEffect;
{
    if(_imageView) _imageView.alpha = 1.0f;
    
    [self updateSiblings:!self.selected];
    [self showAsSelected:!self.selected];
    
    self.alpha = 1;
    if(!self.selected || (self.selected && self.deselectable))
    {
        self.selected = !self.selected;
    }
}

- (void) updateSiblings:(BOOL)willSelect
{
    
    if(!self.updatesSiblingsOnChange && !self.effect.cancelsEffect) {
        
        if(self.superview.subviews.count)
        {
            NSMutableSet *siblings = [NSMutableSet setWithArray:self.superview.subviews];
            [siblings removeObject:self];
            for (UIView *subview in siblings) {
                if(![subview isKindOfClass:[self class]] || [(EffectControl *)subview effect].cancelsEffect) continue;
                [(UIControl *)subview setSelected:NO];
            }
        }
        return;
    }
    if(self.superview.subviews.count)
    {
        NSMutableSet *siblings = [NSMutableSet setWithArray:self.superview.subviews];
        [siblings removeObject:self];
        for (UIView *subview in siblings) {
            if(![subview isKindOfClass:[self class]] || ![(UIControl *)subview isSelected]) continue;
            [(UIControl *)subview setSelected:NO];
        }
    }
}


#pragma mark - Show Cancel

- (BOOL) showCancel;
{
    if([self.effect respondsToSelector:@selector(controlShouldShowCancel:)])
    {
        return [self.effect controlShouldShowCancel:self];
    }
    switch (self.effect.type) {
        case MysticObjectTypeFilter:
        case MysticObjectTypeFrame:
        case MysticObjectTypeText:
        case MysticObjectTypeTexture:
        case MysticObjectTypeBadge:
        case MysticObjectTypeLight:
        case MysticObjectTypeMask:
        case MysticObjectTypePotion:
        case MysticObjectTypeSetting:
//        case MysticObjectTypeColor:
            return YES;
            break;
            
        default:
        {
            if(MysticTypeSubTypeOf(self.effect.type, MysticSettingSettings))
            {
                return YES;
            }
            break;
        }
    }
    
    return NO;
}
#pragma mark - Set Effect
- (BOOL) isActive;
{
    if(_effect)
    {
        PackPotionOption *option = (PackPotionOption *)_effect;
        return option.isActive;
    }
    return NO;
}
- (void) setEffect:(MysticControlObject *)value
{
    if(_effect) [_effect release], _effect = nil;
    _effect = [value retain];
    [self prepare];
}

- (void) viewDidBecomeActive;
{
    if([self.effect respondsToSelector:@selector(controlBecameActive:)])
    {
        [self.effect controlBecameActive:self];
    }
}
- (void) viewDidBecomeInactive;
{
    if([self.effect respondsToSelector:@selector(controlBecameInactive:)])
    {
        [self.effect controlBecameInactive:self];
    }
}

- (UIButton *) settingsButton;
{
    return _selectedOverlayView ? (UIButton *)[self.selectedOverlayView viewWithTag:MysticButtonTypeSettings] : nil;
}
- (UIButton *) cancelButton;
{
    return _selectedOverlayView ? (UIButton *)[self.selectedOverlayView viewWithTag:MysticButtonTypeCancel] : nil;
}



#pragma mark - 
#pragma mark - Prepare Effect Thumbnail

- (void) prepare;
{
    if(_effect)
    {
        self.cancelsEffect = NO;
        
        self.updatesSiblingsOnChange = _effect.updatesSiblingsOnChange;
        self.selectable = _effect.selectable;
        self.deselectable = _effect.deselectable;
        self.enabled = _effect.enabled;
        self.showLabel = _effect.showLabel /* && !effect.cancelsEffect */;

        UIView *_settingsBtn = (UIView *)self.settingsButton;
        UIView *_cancelBtn = (UIView *)self.cancelButton;
        
        [_settingsBtn setHidden:!_effect.hasAdjustableSettings];
        [_cancelBtn setHidden:!self.showCancel];
        
        
        _cancelBtn.frame = CGRectMake(self.frame.size.width-32, 0, 32, 32);
        _settingsBtn.frame = CGRectMake(0, 0, 32, 32);
        
        if(_selectedOverlayView) _selectedOverlayView.userInteractionEnabled = !(!self.showCancel && !_effect.hasAdjustableSettings);
        
        
        
        if(self.showLabel && !_effect.cancelsEffect)
        {
            self.titleLabel.hidden = NO;
            self.titleLabel.text = _effect.name;
        }
        else
        {
            self.titleLabel = nil;
        }
        

        
        [self updateControl];
        
        
        [self removeTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self removeTarget:self action:@selector(didTouchDown:) forControlEvents:UIControlEventTouchDown];
        
        
        [self addTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(didTouchDown:) forControlEvents:UIControlEventTouchDown];
        
        self.gestureRecognizers = nil;
        


        if(_imageView) _imageView.image = nil;
        
        if([_effect respondsToSelector:@selector(thumbnail:effect:)])
        {
            [_effect performSelector:@selector(thumbnail:effect:) withObject:self withObject:_effect];
        }
        else
        {
            NSString *file = [_effect controlImageNamePath];
            if(file)
            {
                _downloadingControlImage = NO;
                self.imageView.image = [[[UIImage alloc] initWithContentsOfFile:file] autorelease];
            }
            else if(self.option.hasSourceImage)
            {
                UIImage *sourceImage = [MysticImage image:self.option.sourceImageInput size:CGRectInset(self.imageView.frame, MYSTIC_UI_CONTROL_IMAGE_INSET, MYSTIC_UI_CONTROL_IMAGE_INSET).size color:@(MysticColorTypeControlIconInactive)];
                self.imageView.contentMode = UIViewContentModeCenter;
                self.imageView.image = sourceImage;
            }
            else if(self.effect.thumbURLString)
            {
                _downloadingControlImage = YES;
                __block CGFloat beforeAlpha = self.imageView.alpha;
                self.imageView.alpha = 0;
                __unsafe_unretained __block  EffectControl *weakSelf = self;
                [self.imageView cancelCurrentImageLoad];
                [self.imageView setImageWithURL:[NSURL URLWithString:self.effect.thumbURLString] placeholderImage:nil options:0 manager:MysticCache.uiManager progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    BOOL fadeIn = [weakSelf.delegate respondsToSelector:@selector(isEffectControlVisible:)] ? [weakSelf.delegate isEffectControlVisible:weakSelf] : NO;
                    BOOL _isSelected = weakSelf.selected || [(PackPotionOption *)weakSelf.effect isActive];
                    weakSelf.effect.hasBeenDisplayed = YES;
                    if(fadeIn)
                    {
                        [MysticUIView animateWithDuration:MYSTIC_UI_CONTROL_FADE_DURATION animations:^{
                            weakSelf.imageView.alpha = _isSelected ? kMYSTICControlSelectedImageViewAlpha : beforeAlpha;
                        } completion:nil];
                    }
                    else
                    {
                        weakSelf.imageView.alpha = _isSelected ? kMYSTICControlSelectedImageViewAlpha : beforeAlpha;
                    }
                }];
            }
        }
        
    }
    if(_imageView) [_imageView setNeedsDisplay];
    
}

- (void) setCancelsEffect:(BOOL)_cancelsEffect
{
    cancelsEffect = _cancelsEffect;
    if(cancelsEffect)
    {
        if(_selectedOverlayView) [_selectedOverlayView removeFromSuperview];
        if(_imageView) _imageView.backgroundColor = [UIColor clearColor];
    }
}
- (void) setSuperSelected:(BOOL)isSelected
{
    self.wasSelected = [super isSelected];
    [super setSelected:isSelected];
}
- (void) setSelected:(BOOL)isSelected
{
    if(!self.selectable) return;
    [self setSuperSelected:isSelected];
    if(cancelsEffect && isSelected && self.delegate && [self.delegate respondsToSelector:@selector(userCancelledEffectControl:effect:)])
        [self.delegate userCancelledEffectControl:self effect:self.effect];
    else if(!cancelsEffect)
    {
        
        if(!isSelected) { if(_selectedOverlayView) self.selectedOverlayView = nil; }
        else
        {
            if(_selectedOverlayView) _selectedOverlayView.alpha = 1;
            if([self.delegate respondsToSelector:@selector(effectControlWasSelected:effect:)])
                [self.delegate effectControlWasSelected:self effect:self.effect];
        }

        if(isSelected && [self.delegate respondsToSelector:@selector(effectControlIsSelecting:effect:)])
            [self.delegate effectControlIsSelecting:self effect:self.effect];
        else if(!isSelected && [self.delegate respondsToSelector:@selector(effectControlWasDeselected:effect:)])
            [self.delegate effectControlWasDeselected:self effect:self.effect];
    }

    if(isSelected && self.showLabel && !self.effect.cancelsEffect )
    {
        self.titleLabel.hidden = NO;
    }
    else if(!isSelected && self.showLabel && !self.effect.cancelsEffect )
    {
        self.titleLabel.hidden = NO;
    }
    
    [self updateLabel:isSelected];
    [self stateWasUpdated];
}
- (PackPotionOption *) option;
{
    if(self.effect)
    {
        return (PackPotionOption *)self.effect;
    }
    return nil;
}
- (void) updateControl;
{
    [self updateControl:self.targetOption];
    
}
- (void) updateControl:(PackPotionOption *)currentOption;
{
    if([self.effect respondsToSelector:@selector(enableControl:)])
    {
        [self.effect enableControl:self];
    }

}

- (void) updateLabel:(BOOL)isSelected;
{
    if([self.effect respondsToSelector:@selector(updateLabel:control:selected:)])
    {
        return [self.effect updateLabel:_titleLabel control:self selected:isSelected];
    }
    else if([self.effect respondsToSelector:@selector(updateLabel:control:)])
    {
        [self.effect performSelector:@selector(updateLabel:control:) withObject:_titleLabel withObject:self];
        return;
    }
    if(!self.showLabel || self.cancelsEffect || !self.titleLabel) return;

    if(isSelected)
    {
        if(self.hasBackgroundView) self.backgroundView.backgroundColor = [MysticColor colorWithType:MysticColorTypeControlActive];
        _titleLabel.font = [MysticUI gothamLight:10];
        _titleLabel.textColor = [MysticColor colorWithType:MysticColorTypeBackgroundWhite];
        if([self showLabelBackground])
        {
            _titleLabel.backgroundColor = [[UIColor colorWithCGColor:self.selectedOverlayView.layer.borderColor] colorWithAlphaComponent:1.0f];
        }
        else
        {
            _titleLabel.backgroundColor = [UIColor clearColor];
        }
    }
    else
    {
        if(self.hasBackgroundView) self.backgroundView.backgroundColor = [MysticColor colorWithType:MysticColorTypeControlInactive];

        _titleLabel.font = [MysticUI gothamLight:10];
        _titleLabel.textColor = [UIColor mysticWhiteColor];
        if([self showLabelBackground])
        {
            _titleLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
            _titleLabel.shadowColor = nil;
        }
        else
        {
            _titleLabel.backgroundColor = [UIColor clearColor];
        }
    }

    CGRect insetFrame = UIEdgeInsetsInsetRect(self.bounds, _insets);
    CGRect labelFrame = insetFrame;
    labelFrame.size.height = _titleLabel.font.lineHeight*2;
    labelFrame.origin.y = insetFrame.size.height - labelFrame.size.height + insetFrame.origin.y;
    _titleLabel.frame = labelFrame;
}
- (BOOL) showLabelBackground;
{
    return !MysticTypeSubTypeOf(self.effect.type, MysticSettingSettings);
}

- (void) showAsSelected { [self showAsSelected:YES]; }
- (void) showAsSelected:(BOOL)makeSelected;
{
    if([self.effect respondsToSelector:@selector(updateControl:selected:)])
    {
        return [self.effect updateControl:self selected:makeSelected];
    }
    else if([self.effect respondsToSelector:@selector(updateControl:)])
    {
        return [self.effect updateControl:self];
    }
    
    [self setSuperSelected:makeSelected];
    if(makeSelected) self.selectedOverlayView.alpha = 1;
    else self.selectedOverlayView = nil;
    [self updateLabel:makeSelected];
}



- (UIImage *) selectedOverlayImage
{
    UIImage *effectImage = self.effect.selectedOverlayImage;
    return effectImage ? effectImage : (self.effect.showsSubControls ? [UIImage imageNamed:@"filter-locked-overlay.png"] : [UIImage imageNamed:@"filter-selected-overlay.png"]);
}


- (UIImage *) canceledImage
{
    return [UIImage imageNamed:@"filter-cancel"];
}

- (UIImage *) cancelHighlightedImage
{
    return [UIImage imageNamed:@"filter-cancel-highlighted"];
}


- (void) setHighlighted:(BOOL)highlighted
{
    BOOL _prevHighlighted = self.highlighted;
    [super setHighlighted:highlighted];
    if(_prevHighlighted!=highlighted) [self stateWasUpdated];
}

- (void)setEnabled:(BOOL)newEnabled {

    BOOL _prev = self.enabled;
    [super setEnabled:newEnabled];
    if(_prev!=newEnabled) [self stateWasUpdated];
    if([self.effect respondsToSelector:@selector(enableControl:)])
    {
        [self.effect enableControl:self];
    }
}

- (void)stateWasUpdated {
    // Add your custom code here to respond to the change in state


}

- (CGRect) contentFrame;
{
    return UIEdgeInsetsInsetRect(self.bounds, _insets);
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGRect insetFrame = UIEdgeInsetsInsetRect(self.bounds, _insets);
    if(_imageView) _imageView.frame = insetFrame;
    if(_backgroundView) _backgroundView.frame = insetFrame;
    
    
    if(_titleLabel && self.showLabel)
    {
        CGRect labelFrame = insetFrame;
        labelFrame.size.height = _titleLabel.font.lineHeight*2;
        labelFrame.origin.y = insetFrame.size.height - labelFrame.size.height + insetFrame.origin.y;
        _titleLabel.frame = labelFrame;
        [self updateLabel:self.selected];
    }
    else if(!self.showLabel)
    {
        self.titleLabel = nil;
    }
    if(_selectedOverlayView)
    {
        UIView *_settingsBtn = (UIView *)[_selectedOverlayView viewWithTag:MysticButtonTypeSettings];
        UIView *_cancelBtn = (UIView *)[_selectedOverlayView viewWithTag:MysticButtonTypeCancel];
        
        _cancelBtn.frame = CGRectMake(insetFrame.size.width-32, 0, 32, 32);
        _settingsBtn.frame = CGRectMake(0, 0, 32, 32);
    }
    
}

- (PackPotionOption *) targetOption;
{
    if(_targetOption) return _targetOption;
    return (PackPotionOption *)self.option.targetOption;
}

@end
