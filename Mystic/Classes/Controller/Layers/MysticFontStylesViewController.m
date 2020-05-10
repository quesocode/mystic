//
//  MysticLabelsViewController.m
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import "MysticConstants.h"
#import "MysticFontStylesViewController.h"
#import "MysticController.h"
#import "MysticDotView.h"

@interface MysticFontStylesViewController ()

@end



@implementation MysticFontStylesViewController

+ (Class) optionClass; { return [PackPotionOptionFontStyle class]; }
+ (Class) layerViewClass; { return [MysticLayerTypeView class]; }
+ (Class) overlaysViewClass; { return [MysticFontOverlaysView class]; }
+ (CGRect) maxLayerBounds;
{
    return [MysticController controller].labelsView.maxLayerBounds;
}
- (CGFrameBounds) newOverlayFrame;
{
    MysticDrawingContext *context = [[[MysticDrawingContext alloc] init] autorelease];
    context.minimumScaleFactor = 1;
    context.fontSizePointFactor = 0.5;
    context.sizeOptions = MysticSizeOptionMatchDefault;
    context.minimumRatio = (CGSize){0.7,0.7};
    CGRect gripFrame = CGRectInset(CGRectSize((CGSize){[[self class] maxLayerBounds].size.width, MYSTIC_LAYER_TYPE_HEIGHT}), MYSTIC_LAYERS_BOUNDS_INSET, 0);
    CGRect newGripFrameContent = CGRectWithPointAndSize([MysticLayerTypeView originForContentFrame:newGripFrameContent scale:self.contentScale], [MysticLayerTypeView boundsForContent:nil target:gripFrame.size context:&context scale:self.contentScale].size);
    gripFrame = [MysticLayerTypeView frameForContentBounds:newGripFrameContent scale:self.contentScale];
    return (CGFrameBounds){gripFrame, newGripFrameContent};
}
- (id) addNewOverlay:(BOOL)copyLastOverlay option:(PackPotionOptionView *)option frame:(CGRect)newFrame;
{
    MysticLayerTypeView *layer = [super addNewOverlay:copyLastOverlay option:option frame:newFrame];
    MysticChoice *choice = [MysticChoice choiceWithInfo:@{@"content":MYSTIC_DEFAULT_FONT_TEXT} key:MYSTIC_DEFAULT_FONT_TEXT type:MysticObjectTypeFont];
    layer.content = choice;
    layer.center = (CGPoint){self.overlaysView.frame.size.width/2, self.overlaysView.frame.size.height/2};

    return layer;
}
- (id) makeOverlay:(PackPotionOptionFont *)option frame:(CGRect)newFrame context:(MysticDrawingContext **)_context;
{
    option = option ? option : (PackPotionOptionFont *)[[[self class] optionClass] optionWithName:[NSString stringWithFormat:@"%@ Font Layer %d", [self class], (int)self.overlays.count] info:nil];
    BOOL isLayerView = [NSStringFromClass([[self class] layerViewClass]) isEqualToString:@"MysticLayerTypeView"];
    
    MysticDrawingContext *context = _context != NULL ? *_context : nil;
    if(_context == NULL)
    {
        context = [[[MysticDrawingContext alloc] init] autorelease];
        context.minimumScaleFactor = 1;
        context.fontSizePointFactor = 0.5;
        context.sizeOptions = MysticSizeOptionMatchDefault;
        context.minimumRatio = (CGSize){0.7,0.7};
        if(_context != NULL) *_context = context;
    }
    
    CGRect gripFrameBounds = [[self class] maxLayerBounds];
    BOOL isNewOverlay = CGRectIsZero(newFrame);
    CGRect gripFrame2 = isNewOverlay  ? CGRectMake(0, 0, gripFrameBounds.size.width, MYSTIC_LAYER_TYPE_HEIGHT) : newFrame;
    gripFrame2 = isNewOverlay ? CGRectInset(gripFrame2, MYSTIC_LAYERS_BOUNDS_INSET, 0) : gripFrame2;
    CGRect newGripFrameContent = gripFrame2;
    CGPoint newGripFrameContentOrigin = gripFrame2.origin;
    CGRect newGripFrame = gripFrame2;
    
    if(isNewOverlay || !isLayerView)
    {
        newGripFrameContent = isLayerView ? [MysticLayerTypeView boundsForContent:nil target:gripFrame2.size context:&context scale:self.contentScale] : gripFrame2;
        newGripFrameContentOrigin = isLayerView ? [MysticLayerTypeView originForContentFrame:newGripFrameContent scale:self.contentScale] : gripFrame2.origin;
        newGripFrameContent.origin = newGripFrameContentOrigin;
        newGripFrame = isLayerView ? [MysticLayerTypeView frameForContentBounds:newGripFrameContent scale:self.contentScale] : gripFrame2;
    }
    else
    {
        UIEdgeInsets ins = [MysticLayerTypeView contentInsetsForScale:self.contentScale];
        newGripFrameContent = CGRectMake(ins.left, ins.top, newGripFrame.size.width - (ins.left + ins.right), newGripFrame.size.height - (ins.top + ins.bottom));
    }
    numberOfOverlaysMade++;
    MysticLayerTypeView *newOverlay = [[[[self class] layerViewClass] alloc] initWithFrame:newGripFrame contentFrame:newGripFrameContent scale:self.contentScale context:context];
    newOverlay.layersView = (id)self.overlaysView;
    newOverlay.index = self.nextLayerIndex;
    newOverlay.enabled = self.enabled;
    newOverlay.editable = YES;
    newOverlay.tag = numberOfOverlaysMade;
    newOverlay.delegate = self;
    newOverlay.option = option;
    newOverlay.color = option.color;
    newOverlay.rotationSnapping = YES;
    newOverlay.preventsPositionOutsideSuperview = NO;
    newOverlay.preventsCustomButton = NO;
    newOverlay.preventsResizing = NO;
    newOverlay.preventsDeleting = NO;
    
    if(!isLayerView)
    {
        newOverlay.borderView.borderColor = [UIColor color:MysticColorTypeOrange];
        newOverlay.minimumHeight = kSPUserResizableViewDefaultMinHeight;
        newOverlay.minimumWidth = kSPUserResizableViewDefaultMinWidth;
        newOverlay.selected = NO;
    }
    else
    {
        newOverlay.borderView.borderColor = [UIColor color:MysticColorTypeOrange];
        [newOverlay loadView];
    }
    return [newOverlay autorelease];
}
- (id) disposableLayer:(id <MysticLayerViewAbstract>)layer;
{
    MysticLayerTypeView *clonedLayer = layer ? layer : self.keyObjectLayer;
    if(!clonedLayer) return nil;
    MysticDrawingContext *clonedContext = clonedLayer.drawContext ? [clonedLayer.drawContext copy] : nil;
    CGRect cf = clonedLayer.contentFrame;
    CGRect nf = [[clonedLayer class] frameForContentBounds:cf scale:clonedLayer.scale];
    CGRect nb = CGRectSize(nf.size);
    MysticLayerTypeView *clone = [self makeOverlay:nil frame:nf context:clonedContext ? &clonedContext : nil];
    
    CGPoint c = clone.center;
    c.x = self.originalFrame.size.width/2;
    c.y = self.originalFrame.size.height/2;
    clone.center = c;
    clone.drawView.scaledAttributedText = [(MysticLayerTypeView *)layer drawView].scaledAttributedText;
    clone.drawView.renderRect = [(MysticLayerTypeView *)layer drawView].renderRect;
    [clone setNewBounds:clonedLayer.bounds];
    clone.contentView.bounds = clonedLayer.contentView.bounds;
    clone.contentView.frame = clonedLayer.contentView.frame;
    clone.contentFrame = clonedLayer.contentFrame;
    [clone layoutControls:MysticLayerControlAllExceptContent];
    clone.ratio = clonedLayer.ratio;
    [clone applyOptionsFrom:(id)clonedLayer];
    clone.option = (id)clonedLayer.option;
    clone.alpha = clonedLayer.alpha;
    clone.textAlignment = clonedLayer.textAlignment;
    clone.lineHeightScale = clonedLayer.lineHeightScale;
    clone.textSpacing = clonedLayer.textSpacing;
    clone.lineHeight = clonedLayer.lineHeight;
    clone.lineBreakMode = clonedLayer.lineBreakMode;
    clone.attributedText = clonedLayer.attributedText;
    clone.drawView.attributedText = clonedLayer.drawView.attributedText;
    MysticChoice *choice = [clonedLayer.content copy];
    choice.attributedString = clonedLayer.attributedText;
    clone.color = clonedLayer.color;

    [choice scale:choice.propertiesScaleInverse];
    choice.propertiesScaleInverse=CGScaleEqual;
    [clone replaceContent:choice adjust:NO scale:CGSizeZero];
    clone.addedInsets = clonedLayer.addedInsets;
    clone.rotation = clonedLayer.rotation;
    [choice addChoice:clonedLayer.content];
    [choice release];
    clone.isDisposable = YES;
//
//    
//    MysticChoice *choice = [MysticChoice choiceWithInfo:clonedLayer.choice key:nil type:clonedLayer.choice.type];
//    choice.attributedString = clonedLayer.attributedText;
//    clone.color = clonedLayer.color;
//    [clone replaceContent:choice adjust:NO scale:CGSizeZero];
//    clone.addedInsets = clonedLayer.addedInsets;
//    clone.rotation = clonedLayer.rotation;
//    clone.isDisposable = YES;
    return [clone deepCopy:clonedLayer];
}

- (id) duplicateLayer:(id <MysticLayerViewAbstract>)layer option:(PackPotionOptionView *)option;
{
    return [self duplicateLayer:layer option:option animated:YES];
}
- (id) duplicateLayer:(id <MysticLayerViewAbstract>)layer option:(PackPotionOptionView *)option animated:(BOOL)animated;
{
    return [self duplicateLayer:layer option:option animated:animated offset:CGPointZero];
}

- (id) duplicateLayer:(id <MysticLayerViewAbstract>)layer option:(PackPotionOptionView *)option animated:(BOOL)animated offset:(CGPoint)offsetPoint;
{
    MysticLayerTypeView *clonedLayer = layer ? layer : self.keyObjectLayer;
    if(!clonedLayer) return nil;
    MysticLayerTypeView *clone = [self disposableLayer:clonedLayer];
    clone.isDisposable = NO;
    [self activateLayer:(id)clone notify:NO];
    [self addOverlay:(id)clone];
    [self deselectLayersExcept:(id)clone];
    [self delegate:@selector(layersViewDidAddLayer:) object:clone perform:YES];
    self.keyObjectLayer = clone;
    CGPoint startCenter = clonedLayer.center;
    CGPoint endPoint = [self layer:clonedLayer centerWithOffset:offsetPoint];
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = YES;
    CGPoint diff = CGPointDiff(endPoint, startCenter);
    CGPoint controlPoint = startCenter;
    controlPoint.x += (diff.x *1.2);
    controlPoint.y += -(diff.y*0.8);
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, startCenter.x, startCenter.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, controlPoint.x, controlPoint.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    pathAnimation.removedOnCompletion =YES;
    CGPathRelease(curvedPath);
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeBackwards;
    group.removedOnCompletion = NO;
    [group setAnimations:[NSArray arrayWithObjects:pathAnimation, nil]];
    group.duration = 0.35f;
    group.delegate = (id<CAAnimationDelegate>)self;
    [group setValue:clone forKey:@"imageViewBeingAnimated"];
    [clone.layer addAnimation:group forKey:@"savingAnimation"];
    clone.center = endPoint;
    clone.layer.position = endPoint;
    return clone;
}

- (void) changedLayer:(MysticLayerView *)sticker;
{
    [self removeOverlays];
    [self addNewOverlay:NO option:sticker.option];
}

- (PackPotionOptionView *) confirmOverlays:(PackPotionOptionView *)newOption complete:(MysticBlockObject)complete;
{
    self.allowGridViewToHide = YES;
    self.allowGridViewToShow = YES;
    [self hideGrid:nil];
    [self disableOverlays];
    newOption.overlaysView = self.overlaysView;
#ifdef MYSTIC_IGNORE_DEFAULT_TEXT
    
    for (MysticLayerTypeView *layerView in self.overlays) if([layerView.text isEqualToString:MYSTIC_DEFAULT_FONT_TEXT]) [self removeOverlay:layerView];
#endif
    
    MysticObjectType optionType = newOption ? newOption.type : MysticObjectTypeFont;
    PackPotionOption *oldOption = [[MysticOptions current] option:optionType];
    if(oldOption) [[MysticOptions current] removeOptions:@[oldOption] cancel:NO];
    newOption = self.overlays.count ? newOption : nil;
    if(newOption)
    {
        [newOption setUserChoice:YES finished:nil];
        if(oldOption) [newOption applyAdjustmentsFrom:oldOption];
    }
    if(complete) complete(newOption);
    return newOption;
}

- (void) finishedMovingLayers:(NSArray *)layerViews;
{
    if(layerViews.count == 0) return;
    for (MysticLayerTypeView *otherLayer in layerViews) if(otherLayer.hasHiddenControls) [otherLayer showControls:YES];
}
- (void) moveLayers:(NSArray *)layerViews distance:(CGPoint)diffPoint;
{
    if(!layerViews.count) return;
    for (MysticFontStyleViewBasic *otherLayer in layerViews) {
        if(!otherLayer.hasHiddenControls) [otherLayer hideControls:YES];
        otherLayer.center = CGPointAdd(otherLayer.center, diffPoint);
    }
}

- (void) copyMenuTouched:(id)sender;
{
    [super copyMenuTouched:sender];
    if(self.layerUsingMenu) [[(MysticLayerTypeView *)self.layerUsingMenu attributedText].string copyToClipboard];
}
@end
