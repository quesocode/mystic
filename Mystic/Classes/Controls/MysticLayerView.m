//
//  MysticLayerView.m
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLayerView.h"

@interface MysticLayerView ()
{
    
}


@end






@implementation MysticLayerView

@synthesize contentInset=_contentInset;
@synthesize debug=_debug;
@synthesize hasChanges=_hasChanges;
@synthesize option=_option;
@synthesize delegate=_delegate;
@synthesize effect=_effect;

@dynamic parentView, color;


- (void) commonInit;
{
    [super commonInit];
    self.hasChanges = NO;
    self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.autoresizesSubviews = NO;
    self.clipsToBounds = NO;
    _effect = MysticLayerEffectOne;
    
}

- (void) setContentInset:(UIEdgeInsets)contentInset;
{
    _contentInset = contentInset;
    CGRect f = self.frame;
    f.origin = CGPointZero;
    _contentBounds = UIEdgeInsetsInsetRect(f, _contentInset);
}



- (void) update;
{

}
- (MysticOverlaysView *)overlaysView;
{
    return (MysticOverlaysView *)self.superview;
}
- (CGRect) originalFrame;
{
    return self.overlaysView.originalFrame;
}
- (void) updateWithEffect:(MysticLayerEffect)effect;
{
    _effect = effect;
}
- (void) setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    self.contentInset = _contentInset;
//    [self update];
}


- (void) applyOptionsFrom:(MysticLayerView *)otherLayerView;
{
    
}

- (void) setOption:(PackPotionOptionView *)newOption;
{
    if(_option)
    {
        PackPotionOptionView *oldOption = _option;
        newOption.view = oldOption.view;
        newOption.overlaysView = oldOption.overlaysView;
        [newOption applyAdjustmentsFrom:oldOption];
//        oldOption.view = nil;
//        oldOption.overlaysView = nil;
        [_option release], _option = nil;
    }
    else
    {
        newOption.view = (id)self;
    }
    [super setOption:newOption];
    [self update];
    [self setNeedsLayout];
}






#pragma mark - Interactions


- (void) doubleTapped;
{

    [super doubleTapped];
    [self.delegate layerViewDidDoubleTap:self];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [_delegate layerViewDidBeginMoving:self];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [_delegate layerViewDidEndMoving:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [_delegate layerViewDidCancelMoving:self];

}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [_delegate layerViewDidMove:self];
}


@end


