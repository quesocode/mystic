//
//  MysticLayerShapeView.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/17/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticLayerShapeView.h"
#import "MysticChoice.h"


@implementation MysticLayerShapeView


- (void) commonInit;
{
    [super commonInit];
    self.showContentDropShadowWhenSelected = YES;
    self.minimumHeight = kSPUserResizableViewDefaultMinHeightShape;
    self.minimumWidth = kSPUserResizableViewDefaultMinWidthShape;
    self.type = MysticObjectTypeLayerShape;
}
- (void) loadView;
{
    [super loadView];
    self.contentView.view = [[[MysticTransView alloc] initWithFrame:self.contentView.contentBounds] autorelease];
    _transView = (id)self.contentView.view;
}

- (CGFloat) contentViewRescale; { return 1; }
- (CGFloat) offsetHeight; { return CGSizeInverseScale(CGSizeScale(self.transView.bounds.size, 0.35), self.contentView.scale).height; }

- (BOOL) replaceContent:(MysticChoice *)choice adjust:(BOOL)adjust scale:(CGSize)scale;
{
    MysticTransView *choiceView = choice.contentView ? [(id)[choice.contentView retain] autorelease] : nil;
    BOOL diff = [super replaceContent:choice adjust:adjust scale:scale];
    if(diff) self.transView.frame = CGRectz(CGRectFitSquare(CGRectSize(choice.size), self.transView.frame));
    self.transView.frame = [choice updateView:(id)self.transView].bounds;
    if(choiceView)
    {
        self.transView.frame = [[choice scale:[choice scaleOfView:self fromView:choiceView].scale] updateView:(id)self.transView].bounds;
    }
    if(self.transView.hasBorderView) [self increaseContentInsets:UIEdgeInsetsMinus(UIEdgeInsetsRectDiff(self.transView.borderView.borderLayer.pathBounds,self.transView.innerFrame),UIEdgeInsetsRectDiff(self.transView.frame, self.transView.innerFrame))];
    [self setContentFrameAndLayout:self.transView.frame];
    return diff;
}

- (CGFrameBounds) contentSize:(MysticChoice *)choice adjust:(BOOL)adjust;
{
    BOOL changeSize = !CGSizeIsUnknownOrZero(self.transView.view.frame.size) && adjust;
    CGAffineTransform contentTransform = CGAffineTransformIdentity;
    CGRect frame = changeSize && !self.userResized ? CGRectWithin(CGRectTransform(self.transView.smallestSubviewFrame, contentTransform), self.layersView.newOverlayFrame.frame, self.layersView.maxLayerBounds).frame : self.contentFrame;
    return (CGFrameBounds){.frame=[self contentFrameInset:frame], .bounds = [[self class] frameForContentBounds:frame scale:self.scale]};
}

- (void) redraw:(BOOL)layout;
{
    [super redraw:layout];
    if(self.drawView && !self.transView)
    {
        self.shouldRelayout = layout;
        self.drawView.alignPosition = self.alignPosition;
        [self relayoutSubviews];
        [self.drawView setNeedsDisplay];
    }
}


- (BOOL) rebuildContext;
{
    if(![super rebuildContext]) return NO;
    MysticDrawingContext *newContext = [self.drawContext copy];
    newContext.adjustContentSizeToFit = NO;
    if(self.drawView) {
        [[self.drawView class] boundsForContent:self.content target:self.contentFrame.size context:&newContext scale:self.layersView.contentScale];
        self.drawView.contextSizeContext = newContext;
    }
    self.drawContext = [newContext autorelease];
    return YES;
}

- (UIImage *) rasterImage:(CGFloat)scale;
{
    CGFloat a = self.contentView.alpha;
    self.contentView.alpha = 1;
    UIImage *img = [super rasterImage:scale];
    self.contentView.alpha = a;
    return img;
}

@end
