//
//  PackPotionOptionShape.m
//  Mystic
//
//  Created by Me on 11/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import "PackPotionOptionShape.h"
#import "EffectControl.h"
#import "MysticShapesView.h"
#import "MysticShapeView.h"
#import "MysticController.h"

@implementation PackPotionOptionShape

@dynamic view;

@synthesize shapesView=_shapesView;

+ (id) option;
{
    PackPotionOptionShape *option = [PackPotionOptionShape optionWithName:@"Shapes" image:Nil type:MysticObjectTypeShape info:@{}];
    option.shapesView = [MysticController controller].shapesView;
    return option;
}
- (void) dealloc;
{
    _shapesView = nil;
    [super dealloc];
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        self.levelRules = MysticLayerLevelRuleAuto;
        [super setColorType:MysticOptionColorTypeForeground color:@(MysticColorTypeClear)];
    }
    return self;
}
- (BOOL) requiresFrameRefresh; {    return NO; }
- (NSInteger) count;
{
    return self.shapesView ? self.shapesView.layers.count : [super count];
}

- (UIColor *) color;
{
    UIColor *c = _color ? _color : (self.colorOption ? self.colorOption.color : nil);
    return c ? c : nil;
}

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
    if(self.shapesView && self.view)
    {
        CGRect newRect = MysticPositionRect(self.view.frame, self.shapesView.bounds, MysticPositionFromAlignment(alignment));
        if(!CGRectEqualToRect(self.view.frame, newRect)) self.view.frame = newRect;
    }
}


- (MysticShapesOverlaysView *) shapesView;
{
    if(_shapesView) return _shapesView;
    return !self.isSelectableOption ? (id)self.view : nil;
}
- (void) confirmCancel;
{
    if(self.shapesView)
    {
        
        if(!self.isSelectableOption)
        {
            [self.shapesView disableOverlays];
            [self.shapesView hideGrid:nil];
            [self.shapesView removeOverlays];
            self.viewImage = nil;
            [super confirmCancel];

        }
    }
}
- (id) sourceImageInput;
{
    if(!self.isSelectableOption)
    {
        return self.viewImage;
    }
    return [super sourceImageInput];
}
- (BOOL) isSelectableOption;
{
    return !self.view || [self.view isKindOfClass:[MysticShapeView class]];
}

- (BOOL) hasOverlaysToRender;
{
    return self.view != nil && [self.view isKindOfClass:[MysticShapesView class]] && [(MysticShapesView *)self.view overlays].count;
}

- (UIImage *) render:(MysticOptions *)effects background:(UIImage *)bgImage;
{
    if(self.view && [self.view isKindOfClass:[MysticShapesView class]])
    {
        UIImage *img = [(MysticShapesView *)self.view imageByRenderingView:bgImage size:effects.size scale:effects.scale];
        return img;
    }
    return [super render:effects background:bgImage];
}
- (MysticImageType) layerImageType;
{
    return MysticImageTypePNG;
}

- (MysticStretchMode) stretchMode;
{
    return MysticStretchModeAspectFit;
}

- (MysticImage *) sourceImageAtSize:(CGSize)atSize contentMode:(UIViewContentMode)contentMode;
{
    if([self.sourceImageInput isKindOfClass:[UIImage class]])
    {
        UIImage *img = self.sourceImageInput;
        if(CGSizeEqualToSize(img.size, atSize)) return (id)img;
        if(CGSizeEqualToSize([MysticImage sizeInPixels:img], atSize)) return (id)img;

    }
    return [MysticImage image:self.sourceImageInput size:atSize color:nil contentMode:UIViewContentModeScaleToFill];
}
- (UIColor *) color:(MysticOptionColorType)ctype;
{
    UIColor *fColor = [super color:ctype];
    switch (ctype) {
        case MysticOptionColorTypeForeground:
        {
            if(!fColor)
            {
                return [UIColor whiteColor];
            }
            break;
        }
        default: break;
    }
    return fColor;
}

- (void) prepareControlForReuse:(EffectControl *)control;
{
    control.selected = NO;

    control.backgroundView.backgroundColor = [MysticColor colorWithType:MysticColorTypeControlInactive];
    
    control.imageView = nil;
    
//    control.imageView.image = nil;
//    control.imageView.contentMode = UIViewContentModeCenter;
//    control.imageView.highlightedImage = nil;
//    control.imageView.highlighted = NO;
//    control.imageView.alpha = 1;

    
}
- (UIColor *) controlCurrentBackgroundColor:(EffectControl *)control;
{
    return control.selected ? [MysticColor colorWithType:MysticColorTypeObjectText] : [MysticColor colorWithType:MysticColorTypeControlInactive];
}
- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
{
    label.hidden = YES;
    control.imageView.highlighted = isSelected;
    control.imageView.alpha = 1;
    
    if(!isSelected)
    {
        control.backgroundView.backgroundColor = [MysticColor colorWithType:MysticColorTypeControlInactive];

    }
    else
    {
        control.backgroundView.backgroundColor = [MysticColor colorWithType:MysticColorTypeObjectText];
    }
    
    [control updateControl];
}
- (void) thumbnail:(EffectControl *)control effect:(PackPotionOption *)effect;
{
    if(effect.cancelsEffect) return;
    [self prepareControlForReuse:control];
    __unsafe_unretained EffectControl *_control = control;
    __unsafe_unretained PackPotionOptionShape *weakSelf = self;
    
    MysticBlockImageObj readyBlock = nil;
    NSInteger visiblePosition = _control.visiblePosition;
    CGFloat imageViewAlpha = visiblePosition == NSNotFound ? 1 : 0;
    
    
    if(self.thumbnail)
    {
        _control.imageView.image = self.thumbnail;
        _control.imageView.highlightedImage = self.thumbnailHighlighted;
        _control.imageView.alpha = 1;
        _control.imageView.contentMode = UIViewContentModeCenter;

    }
    else
    {
        readyBlock = ^(UIImage *img, EffectControl *theControl){
            
            CGRect rect = CGRectMake(0, 0, CGImageGetWidth(img.CGImage), CGImageGetHeight(img.CGImage));
            UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0f);
//            CGContextRef context = UIGraphicsGetCurrentContext();
            
//            [[MysticColor colorWithType:MysticColorTypeControlInactive] setFill];
//            CGContextFillRect(context, rect);
            
            [img drawInRect:rect blendMode:MysticFilterTypeBlendNormal alpha:1];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            newImage = [UIImage imageWithCGImage:newImage.CGImage scale:img.scale orientation:UIImageOrientationUp];
            UIGraphicsEndImageContext();
            _control.imageView.image = newImage;
            [weakSelf setThumbnail:newImage];
            
            UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0f);

//            context = UIGraphicsGetCurrentContext();
//            [[MysticColor colorWithType:MysticColorTypeObjectText] setFill];
//            CGContextFillRect(context, rect);
            
            [img drawInRect:rect blendMode:MysticFilterTypeBlendNormal alpha:1];
            UIImage *newImage2 = UIGraphicsGetImageFromCurrentImageContext();
            _control.imageView.highlightedImage = [UIImage imageWithCGImage:newImage2.CGImage scale:img.scale orientation:UIImageOrientationUp];
            [weakSelf setThumbnailHighlighted:_control.imageView.highlightedImage];
            UIGraphicsEndImageContext();
            if(visiblePosition != NSNotFound)
            {
                [MysticUIView animateWithDuration:0.3 delay:0.1*(visiblePosition-1) options:nil animations:^{
                    _control.imageView.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    _control.imageView.alpha = 1;
                    
                }];
            }
        };
        
        _control.imageView.alpha = imageViewAlpha;
        _control.imageView.contentMode = UIViewContentModeCenter;
         UIImage *image = [MysticImage image:self.sourceImageInput size:CGRectInset(control.imageView.frame, MYSTIC_UI_CONTROL_IMAGE_INSET_SHAPE, MYSTIC_UI_CONTROL_IMAGE_INSET_SHAPE).size color:@(MysticColorTypeWhite)];
        
        
        if(image) if(readyBlock) readyBlock(image, _control);
        
    }
}
- (BOOL) selected;
{
    if(self.isSelectableOption && self.view) return self.view.selected;
    return [super selected];
}
- (BOOL) isActive;
{
    if(self.isSelectableOption && self.view && self.view.selected && [self.view.option isEqual:self])
    {
        return YES;
    }
    return NO;
}
- (BOOL) canBeChosen; { return YES; }

- (CGFloat) increment:(MysticToolType)toolType;
{
    switch (toolType)
    {
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
    MysticShapeView *selectedView = self.shapesView ? [self.shapesView selectedLayer] : nil;
    if(!selectedView) return;
//    CGRect rect = selectedView.frame;
    CGPoint center = selectedView.center;
//    CGRect superrect = self.view.frame;
    CGFloat increment = [self increment:toolType];
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
            
            DLog(@"MysticToolTypeSizeBigger: %2.3f -> %2.3f", floatAmount, increment);
            
            //            selectedView.transform = CGAffineTransformConcat(selectedView.transform, CGAffineTransformMakeScale(self.transformRect.size.width, self.transformRect.size.height));
            
            [selectedView transformSize:floatAmount];
            
            break;
        }
        case MysticToolTypeSizeSmaller:
        {
            floatAmount = [amount floatValue];
            
            
            DLog(@"MysticToolTypeSizeSmaller: %2.3f -> %2.3f", floatAmount, increment);
            
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
            
            //            selectedView.transform = CGAffineTransformConcat(selectedView.transform, CGAffineTransformMakeTranslation(0, floatAmount));
            
            break;
        }
            
        default: break;
    }
}



@end
