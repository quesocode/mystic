//
//  MysticShapesViewController.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/17/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//
#import "MysticConstants.h"
#import "MysticShapesViewController.h"
#import "MysticShapesOverlaysView.h"
#import "MysticLayerShapeView.h"
#import "MysticController.h"

@interface MysticShapesViewController ()

@end

@implementation MysticShapesViewController


+ (Class) optionClass; { return [PackPotionOptionShape class]; }
+ (Class) layerViewClass; { return [MysticLayerShapeView class]; }
+ (Class) overlaysViewClass; { return [MysticShapesOverlaysView class]; }
+ (CGRect) maxLayerBounds; { return [MysticController controller].shapesView.maxLayerBounds; }

- (id) addNewOverlay:(BOOL)copyLastOverlay option:(PackPotionOptionView *)option frame:(CGRect)newFrame;
{
    MysticLayerShapeView *layer = [super addNewOverlay:copyLastOverlay option:option frame:newFrame];
    NSString *defaultKey = [MysticOptionsDataSourceShapes objectAtKeyPath:@"default"];
    if(defaultKey)
    {
        NSDictionary *defaultChoiceInfo = [MysticOptionsDataSourceShapes objectAtKeyPath:[@"items." stringByAppendingString:defaultKey]];
        if(!defaultChoiceInfo)
        {
            defaultKey = [[MysticOptionsDataSourceShapes objectAtKeyPath:@"group-packs.items.featured_layers"] objectAtIndex:0];
            defaultChoiceInfo = [MysticOptionsDataSourceShapes objectAtKeyPath:[@"items." stringByAppendingString:defaultKey]];
        }
        [layer replaceContent:[MysticChoice choiceWithInfo:defaultChoiceInfo key:defaultKey type:[MysticOptionsDataSourceShapes itemsType]] adjust:NO scale:CGScaleEqual.size];
    }
    return layer;
}
- (id) makeOverlay:(PackPotionOptionShape *)option frame:(CGRect)newFrame context:(MysticDrawingContext **)_context;
{
    option = option ? option : (PackPotionOptionShape *)[[[self class] optionClass] optionWithName:[NSString stringWithFormat:@"%@ Shape Layer %d", [self class], (int)self.overlays.count] info:nil];
    BOOL isLayerView = [NSStringFromClass([[self class] layerViewClass]) isEqualToString:@"MysticLayerShapeView"];
    MysticDrawingContext *context = _context != NULL ? *_context : nil;
    if(_context == NULL)
    {
        context = [[[MysticDrawingContext alloc] init] autorelease];
        context.minimumScaleFactor = 1;
        context.sizeOptions = MysticSizeOptionMatchDefault;
        context.minimumRatio = (CGSize){0.7,0.7};
        if(_context != NULL) *_context = context;
    }
    
    CGRect maxBounds = [[self class] maxLayerBounds];
    BOOL isNewOverlay = CGRectIsZero(newFrame);
    CGFloat heightOrWidth = MAX(maxBounds.size.width, maxBounds.size.height);
    maxBounds = isNewOverlay  ? CGRectMake(0, 0, heightOrWidth*.5, heightOrWidth*.5) : newFrame;
    UIEdgeInsets ins = [MysticLayerShapeView contentInsetsForScale:self.contentScale];
    CGRect contentFrame = CGRectMake(ins.left, ins.top, maxBounds.size.width - (ins.left + ins.right), maxBounds.size.height - (ins.top + ins.bottom));
    numberOfOverlaysMade++;
    MysticLayerShapeView *layer = [[[[self class] layerViewClass] alloc] initWithFrame:maxBounds contentFrame:contentFrame scale:self.contentScale context:context];
    if(!isLayerView)
    {
        layer.layersView = (id)self.overlaysView;
        layer.index = self.nextLayerIndex;
        layer.enabled = self.enabled;
        layer.editable = YES;
        layer.tag = numberOfOverlaysMade;
        layer.delegate = self;
        layer.option = option;
        layer.borderView.borderColor = [UIColor hex:@"CC8A42"];
        layer.rotationSnapping = YES;
        layer.preventsPositionOutsideSuperview = NO;
        layer.preventsCustomButton = NO;
        layer.preventsResizing = NO;
        layer.preventsDeleting = NO;
        layer.minimumHeight = kSPUserResizableViewDefaultMinHeight;
        layer.minimumWidth = kSPUserResizableViewDefaultMinWidth;
        layer.selected = NO;
        layer.color = option.color;
    }
    else
    {
        layer.layersView = (id)self.overlaysView;
        layer.index = self.nextLayerIndex;
        layer.enabled = self.enabled;
        layer.tag = numberOfOverlaysMade;
        layer.delegate = self;
        layer.option = option;
        layer.borderView.borderColor = [UIColor color:MysticColorTypeOrange];
        layer.color = option.color;
        [layer loadView];
    }
    return [layer autorelease];
}
- (id) disposableLayer:(id <MysticLayerViewAbstract>)layer;
{
    MysticLayerShapeView *clonedLayer = layer ? layer : self.keyObjectLayer;
    if(!clonedLayer) return nil;
    MysticDrawingContext *clonedContext = clonedLayer.drawContext ? [clonedLayer.drawContext copy] : nil;
    MysticLayerShapeView *clone = [self makeOverlay:nil frame:[clonedLayer boundsForContentFrame:clonedLayer.contentFrame] context:clonedContext ? &clonedContext : nil];
    clone.center = CGPointAddXY( clone.center, self.originalFrame.size.width/2, self.originalFrame.size.height/2);
    clone.ratio = clonedLayer.ratio;
    clone.drawView.renderRect = CGRectScale([(MysticLayerTypeView *)layer drawView].renderRect, clonedLayer.contentView.transformScale.width);
    clone.addedInsets = clonedLayer.addedInsets;
    [clone setNewBounds:clonedLayer.bounds];
    [clone.contentView setNewFrame:clonedLayer.contentView.originalFrame layout:clonedLayer.contentView.layoutFrame];
    clone.contentFrame = clonedLayer.contentFrame;
    [clone layoutControls:MysticLayerControlAll];
    [clone applyOptionsFrom:(id)clonedLayer];
    clone.option = (id)clonedLayer.option;
    clone.alpha = clonedLayer.alpha;
    clone.color = clonedLayer.color;
    clone.rotation = clonedLayer.rotation;
    clone.isDisposable = YES;
    [clone.contentInfo addEntriesFromDictionary:clonedLayer.contentInfo];
    MysticChoice *choice = [clonedLayer.content copy];
    [choice scale:choice.propertiesScaleInverse];
    choice.propertiesScaleInverse=CGScaleEqual;
    [clone replaceContent:choice adjust:NO scale:CGSizeZero];
    clone.addedInsets = clonedLayer.addedInsets;
    [choice addChoice:clonedLayer.content];
    [choice release];
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
    MysticLayerShapeView *clonedLayer = layer ? layer : self.keyObjectLayer;
    if(!clonedLayer) return nil;
    MysticLayerShapeView *clone = [self disposableLayer:clonedLayer];
    clone.isDisposable = NO;
    [self activateLayer:(id)clone notify:NO];
    [self addOverlay:(id)clone];
    [self deselectLayersExcept:(id)clone];
    [self delegate:@selector(layersViewDidAddLayer:) object:clone perform:YES];
    self.keyObjectLayer = clone;
    
    CGPoint endPoint = [self layer:clonedLayer centerWithOffset:offsetPoint];
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = YES;
    CGPoint diff = CGPointDiff(endPoint, clonedLayer.center);
    CGPoint curvePoint = CGPointAdd(clonedLayer.center, (CGPoint){(diff.x *1.2), -(diff.y*0.8)});
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, clonedLayer.center.x, clonedLayer.center.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, curvePoint.x, curvePoint.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    pathAnimation.removedOnCompletion =YES;
    CGPathRelease(curvedPath);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeBackwards;
    group.removedOnCompletion = NO;
    [group setAnimations:[NSArray arrayWithObjects:pathAnimation, nil]];
    group.duration = 0.35f;
    group.delegate = (id <CAAnimationDelegate>)self;
    [group setValue:clone forKey:@"imageViewBeingAnimated"];
    [clone.layer addAnimation:group forKey:@"savingAnimation"];
    clone.center = endPoint;
    clone.layer.position = endPoint;
    return clone;
}
- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
{

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
    
//    newOption.overlaysView = self.overlaysView;
    PackPotionOptionView *oldOption = (id)[[MysticOptions current] option:MysticObjectTypeShape];

    if(oldOption) [[MysticOptions current] removeOptions:@[oldOption] cancel:NO];

    newOption = self.overlays.count ? newOption : nil;
    if(newOption)
    {
        if(oldOption) [newOption applyAdjustmentsFrom:oldOption];
        [newOption setUserChoice:YES finished:nil];
    }
    if(complete) complete(newOption);
    return newOption;
}

- (void) finishedMovingLayers:(NSArray *)layerViews;
{
    if(!layerViews.count) return;
    for (MysticLayerShapeView *otherLayer in layerViews) {
        if(otherLayer.hasHiddenControls) [otherLayer showControls:YES];
    }
}
- (void) moveLayers:(NSArray *)layerViews distance:(CGPoint)diffPoint;
{
    if(!layerViews.count) return;
    for (MysticLayerShapeView *otherLayer in layerViews) {
        if(!otherLayer.hasHiddenControls) [otherLayer hideControls:YES];
        otherLayer.center = CGPointAdd(otherLayer.center, diffPoint);
    }
}

- (void) copyMenuTouched:(id)sender;
{
    [super copyMenuTouched:sender];
    if(self.layerUsingMenu)
    {
        [[(MysticLayerShapeView *)self.layerUsingMenu attributedText].string copyToClipboard];
    }
    
}
@end
