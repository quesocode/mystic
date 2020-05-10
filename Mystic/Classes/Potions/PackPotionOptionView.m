//
//  PackPotionOptionView.m
//  Mystic
//
//  Created by Me on 12/2/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOptionView.h"
#import "MysticOptions.h"
#import "MysticImage.h"
#import "UserPotionManager.h"
#import "MysticOverlaysView.h"
#import "MysticLayerView.h"
#import "AppDelegate.h"

@implementation PackPotionOptionView

@synthesize view=_view, viewImage=_viewImage, overlaysView=_overlaysView, isManager=_isManager, manager=_manager, color=_color, colorOption=_colorOption;

+ (id) parentOption;
{
    PackPotionOptionView *managerOption = [[self class] optionWithName:[NSString stringWithFormat:@"%@-Manager", MyString([self classObjectType])] info:@{}];
    managerOption.isManager = YES;
    return managerOption;
}


- (void) dealloc;
{
    [super dealloc];
    [_content release];
    [_colorOption release];
    [_view release];
    [_viewImage release];
    [_color release];
    [_overlaysView release];
    [_previewImage release];
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        _alignment = MysticAlignPositionCenter;
        self.levelRules = MysticLayerLevelRuleAuto;
        [super setColorType:MysticOptionColorTypeForeground color:@(MysticColorTypeChoice1)];
    }
    return self;
}

- (BOOL) shouldRegisterForChanges; {    return NO; }
- (BOOL) canTransform; {                return NO; }
- (BOOL) hasAdjustableSettings; {       return NO; }
- (BOOL) requiresFrameRefresh; {        return NO; }
- (BOOL) allowsMultipleSelections; {    return NO; }
- (BOOL) showLabel; {                   return YES; }
- (BOOL) hasShader; {                   return self.blended; }
- (BOOL) hasInput; {                    return self.blended; }
- (BOOL) hasImage; {                    return self.blended; }
- (BOOL) hasAlphaChannel; {             return YES; }
- (BOOL) canReorder; {                  return YES; }

- (NSString *) uniqueTag:(NSArray *)onlyKeys ignoreKeys:(NSArray *)ignoreKeys;
{
    NSString *uniqTag = [super uniqueTag:onlyKeys ignoreKeys:ignoreKeys];
    if(self.isManager) for (UIView *subView in self.overlaysView.layers) uniqTag = [uniqTag stringByAppendingString:[NSString stringWithFormat:@"%d%@", (int)subView.tag, FLogStrd(subView.frame, 3)].md5];
    if(!onlyKeys)
    {
//        if(_uniqueTag) [_uniqueTag release], _uniqueTag=nil;
//        _uniqueTag = [[NSString stringWithString:uniqTag] retain];
        self.uniqueTag = uniqTag;
    }
    return uniqTag;
}
- (BOOL) hasAdjusted:(MysticObjectType)type;
{
    switch (type) {
        case MysticSettingBlending: return self.blendingMode && ![self.blendingMode isEqualToString:MysticFilterTypeToString(MysticFilterTypeBlendAlphaMix)];
        default: break;
    }
    return [super hasAdjusted:type];
    
}
- (BOOL) blended;
{
    BOOL isBlended = NO;
    if(self.weakOwner && [self.weakOwner isEnabled:MysticRenderOptionsSaveState]) isBlended = YES;
    else isBlended = [[MysticOptions current] inputAboveOption:self] != nil;
    return isBlended;
}
- (void) applyAdjustmentsFrom:(PackPotionOptionView *)otherOption;
{
    [super applyAdjustmentsFrom:otherOption];
    self.color = otherOption.color;
    self.level = otherOption.level;
}
- (UIView *) theView; { return (UIView *)self.view; }
- (NSString *) blendingMode; { return @"mix"; }

- (void) update;
{
    if(self.theView) self.theView.hidden = self.blended;

}
- (void) setColorOption:(PackPotionOptionColor *)colorOption;
{
    _colorOption = [colorOption retain];
    [super setColorOption:colorOption];
    MysticLayerBaseView *layerView = [self.overlaysView selectedLayer];
    if(layerView && [layerView respondsToSelector:@selector(setColor:)])
    {
        layerView.color = [colorOption color];
        layerView.backgroundColor = ![self hasAdjusted:MysticSettingBackgroundColor] ? [layerView.color colorWithAlphaComponent:0] : layerView.backgroundColor;
    }
    self.overlaysView.backgroundColor = [layerView.color colorWithAlphaComponent:0];
}
- (UIColor *) color;
{
    if(_color) return _color;
    return self.colorOption ? self.colorOption.color : [UIColor clearColor];
}
- (id) sourceImageInput;
{
    return self.viewImage ? self.viewImage : [super sourceImageInput];
}
- (BOOL) hasSourceImage;
{
    return self.theView || self.viewImage ? self.viewImage != nil : [super hasSourceImage];
}
- (BOOL) isPreviewOption;
{
    return self.theView ? !self.theView.hidden : [super isPreviewOption];
}
- (BOOL) hasUnRenderedAdjustments;
{
    return NO;
}
- (UIImage *) image:(MysticOptions *)effects;
{
    if(self.hasSourceImage) return [super image:effects];;
    if(self.theView)
    {
        if(self.theView.hidden) self.theView.hidden = NO;
        UIView *v = self.theView;
        UIImage *img = [MysticImage imageByRenderingView:nil size:effects.size scale:effects.scale view:v bgColor:[self.overlaysView lastLayerBackgroundColor] finished:nil];
        v.hidden = YES;
        return img;
    }
    return [super image:effects];
}

- (UIImage *) render:(MysticOptions *)effects background:(UIImage *)bgImage;
{
    if(self.theView)
    {
        BOOL changed = NO;
        if(self.theView.hidden) { changed = YES; self.theView.hidden = NO; }
        UIImage *img = [MysticImage imageByRenderingView:bgImage size:effects.size scale:effects.scale view:self.theView bgColor:[self.overlaysView lastLayerBackgroundColor] finished:nil];
        if(changed) self.theView.hidden = YES;
        return img;
    }
    return [super render:effects background:bgImage];
}


- (id) setUserChoice;
{
    
    
    if(self.isManager)
    {
        MysticLayerView *selectedLayer = self.overlaysView.selectedLayer;
        if(selectedLayer)
        {
            selectedLayer.option = self;
            [self.overlaysView changedLayer:selectedLayer];
        }
    }
    else if(self.manager)
    {
        MysticLayerView *selectedLayer = self.overlaysView.selectedLayer;
        if(selectedLayer)
        {
            [selectedLayer.option applyAdjustmentsFrom:self];
            [self.overlaysView changedLayer:selectedLayer];

        }
    }
    return self;
    

}


//- (void) setUserChoice:(BOOL)force;
//{
////    [self prepareViewImage];
//    [super setUserChoice:force];
//}

- (MysticStretchMode) stretchMode; { return MysticStretchModeNone; }

- (MysticImageType) layerImageType; {    return MysticImageTypePNG; }
- (MysticOverlaysView *)overlaysView;
{
    return _overlaysView ? _overlaysView : _manager ? _manager.overlaysView : nil;
}
- (UIImage *) prepareViewImage;
{
    return [self prepareViewImage:CGSizeUnknown complete:nil];
}
- (UIImage *) prepareViewImage:(CGSize)atSize;
{
    return [self prepareViewImage:atSize complete:nil];

}
- (UIImage *) prepareViewImageComplete:(MysticBlockObjObj)completed;
{
    return [self prepareViewImage:CGSizeUnknown complete:completed];

}
- (UIImage *) prepareViewImage:(CGSize)atSize complete:(MysticBlockObjObj)completed;
{
    if(self.isManager)
    {
        __unsafe_unretained __block MysticBlockObjObj _completed = completed ? Block_copy(completed) : nil;
        __unsafe_unretained __block PackPotionOptionView *weakSelf = [self retain];
//        DLog(@"prepare image view:  %@", s(self.overlaysView.frame.size));
        __block CGRect of = weakSelf.overlaysView.frame;
        [MysticImage imageByRenderingView:nil size:self.overlaysView.frame.size scale:[MysticUI scale] view:self.overlaysView bgColor:[self.overlaysView lastLayerBackgroundColor] finished:^(UIImage *__previewImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                CGRect nf = weakSelf.overlaysView.frame;
                nf.origin.y = [MysticUI screen].height *1.5;
                if(_completed) _completed(__previewImage, nil);
                weakSelf.overlaysView.frame = nf;
                
            });
            MysticWait(0.5, ^{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, nil), ^{
                    //                DLog(@"prepare image view 2:  %@", s(CGSizeIsUnknownOrZero(atSize) ? [MysticUser user].size : atSize));
                    
                    [MysticImage imageByRenderingView:nil size:CGSizeIsUnknownOrZero(atSize) ? [MysticUser user].size : atSize scale:1 view:weakSelf.overlaysView bgColor:[weakSelf.overlaysView lastLayerBackgroundColor] finished:^(UIImage *fullImage) {
                            weakSelf.viewImage = fullImage;
                            if(_completed)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    _completed(weakSelf.viewImage, [NSValue valueWithCGRect:of]); Block_release(_completed);
                                    [weakSelf autorelease];
                                });
                            }
                            else [weakSelf autorelease];
                    }];
                    
                });
            });
        }];
        
        return self.previewImage;
    }
    return nil;
}



- (id) setupWithOption:(PackPotionOption *)option makeLayer:(BOOL)createNewObject;
{
    MysticLayerView *sticker = nil;
    if(createNewObject)
    {
        if(self.overlaysView.shouldAddNewLayer) [self.overlaysView addNewOverlay];
        else sticker = self.overlaysView.newestOverlay;
    }
    else sticker = [self.overlaysView lastOverlayWithOption:(PackPotionOptionView *)option];
    if(sticker && !sticker.selected) sticker.selected = YES;
    return sticker;
}

- (NSString *) debugDescription;
{
    return [NSString stringWithFormat:@"%@%@ (\"%@\")  <%@ %p>", MyString(self.type), self.isManager ? @" Manager" : @"", self.name, NSStringFromClass(self.class), self];
}


@end
