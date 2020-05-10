//
//  MysticMoveableView.m
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticMoveableView.h"
#import "MysticDotView.h"

@interface MysticMoveableView ()

@property (nonatomic, assign) CGPoint lastTouchPoint;
@property (nonatomic, retain) UITapGestureRecognizer* gestureRecognizer;
@property (nonatomic) float deltaAngle;
@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGAffineTransform startTransform;
@property (nonatomic) CGPoint touchStart;

@end


@implementation MysticMoveableView


@synthesize selected=_selected;
@synthesize enabled=_enabled;
- (void) dealloc;
{
    [_contentView release], _contentView=nil;
    [_gestureRecognizer release], _gestureRecognizer=nil;
    [_customControl release], _customControl=nil;
    [_deleteControl release], _deleteControl=nil;
    [_resizingControl release], _resizingControl=nil;
    [_borderView release], _borderView=nil;
    [_delegate release], _delegate=nil;
    [_option release], _option=nil;
    [_parentView release], _parentView=nil;
    Block_release(_editedBlock);
    Block_release(_editingBlock);
    Block_release(_selectBlock);
    Block_release(_movedBlock);
    Block_release(_longPressBlock);
    Block_release(_singleTapBlock);
    Block_release(_doubleTapBlock);
    Block_release(_deleteBlock);
    Block_release(_customTapBlock);
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame {
    _globalInset = UIEdgeInsetsMakeFrom(kSPUserResizableViewGlobalInset);
    _contentScale = CGScaleEqual;
    _controlSize = (CGSize){kMYSTICLABELControlSize, kMYSTICLABELControlSize};
    
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _globalInset = UIEdgeInsetsMakeFrom(kSPUserResizableViewGlobalInset);
    _contentScale = CGScaleEqual;
    _controlSize = (CGSize){kMYSTICLABELControlSize, kMYSTICLABELControlSize};
    
    
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (void) commonInit;
{
    _snapping = NO;
    _snapPosition = MysticSnapPositionCenters|MysticSnapPositionBounds;
    _snapOffset = 6;
    _selected = NO;
    self.clipsToBounds = NO;

}
- (void) finishedImageCapture:(CGSize)renderSize scale:(CGScale)scale;
{
    
}
- (void) prepareForImageCapture:(CGSize)renderSize scale:(CGScale)scale finished:(MysticBlock)finished;
{
    
}
- (void) singleTap:(id)sender;
{
    if(self.ignoreSingleTap) return;
    
    if([_delegate respondsToSelector:@selector(layerViewDidSingleTap:)]) {
        [_delegate layerViewDidSingleTap:self];
    }
    else if(self.singleTapBlock)
    {
        self.singleTapBlock((id)self);
    }
    else
    {
        if(!self.enabled) return;
        if(!self.selected) self.selected = YES;
    }
}

-(void)deleteTap:(UIPanGestureRecognizer *)recognizer
{
    //    if(!self.enabled) return;
    
    if([_delegate respondsToSelector:@selector(layerViewDidClose:)]) {
        [_delegate layerViewDidClose:self];
    }
    else if(self.deleteBlock)
    {
        self.deleteBlock(self);
    }
    else
        if (!self.preventsDeleting) {
            UIView * close = (UIView *)[recognizer view];
            [close.superview removeFromSuperview];
        }
    
    
}

- (void) doubleTapped;
{
    [self doubleTap:nil];
}
- (void) doubleTap:(UITapGestureRecognizer *)recognizer;
{
    if(!self.enabled) return;
    if([_delegate respondsToSelector:@selector(layerViewDidDoubleTap:)]) [_delegate layerViewDidDoubleTap:self];
    else if(self.doubleTapBlock) self.doubleTapBlock(self);
}


-(void)customTap:(UIPanGestureRecognizer *)recognizer
{
    if(!self.preventsCustomButton && [_delegate respondsToSelector:@selector(layerViewDidCustomButtonTap:)]) [_delegate layerViewDidCustomButtonTap:self];
}

- (void) setEnabled:(BOOL)enabled;
{
    if(self.selected && !enabled) [self setSelected:enabled notify:NO];
    _enabled = enabled;
    self.userInteractionEnabled = _enabled;
}




- (void) setContentView:(MysticLayerContentView *)newContentView;
{
    [_contentView removeFromSuperview];
    [_contentView release];
    _contentView = [newContentView retain];
    _contentView.frame = CGRectInset(self.bounds, self.globalInset.left + self.globalInset.right+ MYSTIC_UI_LAYER_BORDER_SIZE/2, self.globalInset.top +self.globalInset.bottom + MYSTIC_UI_LAYER_BORDER_SIZE/2);
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    for (UIView* subview in [_contentView subviews]) {
        [subview setFrame:CGRectMake(0, 0,
                                     _contentView.frame.size.width,
                                     _contentView.frame.size.height)];
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    [self addSubview:_contentView];

}
- (void) setSelected:(BOOL)v { [self setSelected:v notify:YES]; }
- (void) setSelected:(BOOL)v notify:(BOOL)shouldNotify;
{
    if(!self.enabled) return;
    
    _selected = v;
    if(v)
    {
        [self showEditingHandles];
    }
    else
    {
        [self hideEditingHandles];
    }
    ALLog(@"selected", @[@"layer", self,
                         @"select", MBOOL(v),
                       @"view", MysticPrintViewsOf(self, 0),
                       ]);
    if(shouldNotify && [_delegate respondsToSelector:@selector(layerViewDidSelect:)]) {
        [_delegate layerViewDidSelect:(id)self];
    }
    
    if(self.selectBlock) self.selectBlock((id)self);
}

- (void) changeRotation:(CGFloat)change;
{
    self.rotation = _rotation + change;

}
- (void) setRotation:(CGFloat)value;
{
    self.transform = CGAffineTransformMakeRotation(value);
    _rotation = value;
    
}
- (void) transformSize:(CGFloat)amount;
{
    CGRect b = self.bounds;
    
    CGFloat wChange = b.size.width * amount;
    CGFloat hChange = b.size.height * amount;
    
    
    
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
    
    self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                             self.bounds.size.width + (wChange),
                             self.bounds.size.height + (hChange));
    self.resizingControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,
                                      self.bounds.size.height-_controlSize.height,
                                      _controlSize.width, _controlSize.height);
    self.deleteControl.frame = CGRectMake(0, 0,
                                     _controlSize.width, _controlSize.height);
    self.customControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,
                                    0,
                                    _controlSize.width,
                                    _controlSize.height);
    
    
    self.borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
    [self.borderView setNeedsDisplay];
    
    [self setNeedsDisplay];
}



-(void)setEditable:(BOOL)editable
{
    _editable = editable;
    [self setNeedsDisplay];
    
    if (_editable) {
        if (!_gestureRecognizer) {
            _gestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped)] autorelease];
            _gestureRecognizer.numberOfTapsRequired = 2;
        }
        
        [self addGestureRecognizer:_gestureRecognizer];
        
        
    }else{
        
        [self removeGestureRecognizer:_gestureRecognizer];
    }
}

#pragma mark - UIResponder

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];

//    _lastTouchPoint = [touch locationInView:self.superview];


    UIView* superView = self;
    while (superView.superview) {
        superView = superView.superview;
        if ([superView isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView*)superView setScrollEnabled:NO];
            break;
        }
    }
    
    self.ignoreSingleTap = NO;
    
    self.touchStart = [touch locationInView:self.superview];
    if([_delegate respondsToSelector:@selector(layerViewDidBeginMoving:)]) {
        [_delegate layerViewDidBeginMoving:(id)self];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];

    CGPoint touchLocation = [touch locationInView:self];

//
//    CGRect newFrame = CGRectOffset(self.frame, touchLocation.x - _lastTouchPoint.x, touchLocation.y - _lastTouchPoint.y);
//    
//    if(self.snapping)
//    {
//        newFrame.origin = snapToPoint(newFrame, self.superview.bounds, self.snapPosition, self.snapOffset);
//    }
//    
//    if(!CGPointEqualToPoint(self.frame.origin, newFrame.origin))
//    {
//        self.frame = newFrame;
//        _lastTouchPoint = touchLocation;
//        [self setNeedsDisplay];
//    }
    
    self.ignoreSingleTap = NO;
    
    self.touchStart = [touch locationInView:self.superview];
    if([_delegate respondsToSelector:@selector(layerViewDidBeginMoving:)]) {
        [_delegate layerViewDidBeginMoving:(id)self];
    }
    
    
    if (CGRectContainsPoint(self.resizingControl.frame, touchLocation)) {
        return;
    }
    
    CGPoint touchP = [touch locationInView:self.superview];
    [self translateUsingTouchLocation:touchP];
    self.touchStart = touchP;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    UIView* superView = self;
    while (superView.superview) {
        superView = superView.superview;
        if ([superView isKindOfClass:[UIScrollView class]]) { [(UIScrollView*)superView setScrollEnabled:YES]; break; }
    }
    if([_delegate respondsToSelector:@selector(layerViewDidEndMoving:)]) [_delegate layerViewDidEndMoving:(id)self];
    else if(self.movedBlock) self.movedBlock((id)self);
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    self.ignoreSingleTap = NO;
    [super touchesCancelled:touches withEvent:event];
    UIView* superView = self;
    while (superView.superview) {
        superView = superView.superview;
        if ([superView isKindOfClass:[UIScrollView class]]) { [(UIScrollView*)superView setScrollEnabled:YES]; break; }
    }
    if([_delegate respondsToSelector:@selector(layerViewDidCancelMoving:)]) [_delegate layerViewDidCancelMoving:(id)self];
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    if(!self.selected) return;
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - self.touchStart.x,self.center.y + touchPoint.y - self.touchStart.y);
    if (self.preventsPositionOutsideSuperview) {
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX)  newCenter.x = self.superview.bounds.size.width - midPointX;
        if (newCenter.x < midPointX) newCenter.x = midPointX;
        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) newCenter.y = self.superview.bounds.size.height - midPointY;
        if (newCenter.y < midPointY) newCenter.y = midPointY;
    }
    self.center = newCenter;
}



-(void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state]== UIGestureRecognizerStateBegan)
    {
        self.prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        if (self.bounds.size.width < self.minimumWidth || self.bounds.size.height < self.minimumHeight)
        {
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     self.minimumWidth+1,
                                     self.minimumHeight+1);
            self.resizingControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,
                                              self.bounds.size.height-_controlSize.height,
                                              _controlSize.width,
                                              _controlSize.height);
            self.deleteControl.frame = CGRectMake(0, 0,
                                             _controlSize.width, _controlSize.height);
            self.customControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,
                                            0,
                                            _controlSize.width,
                                            _controlSize.height);
            self.prevPoint = [recognizer locationInView:self];
            
        } else {
            CGPoint point = [recognizer locationInView:self];
            float wChange = (point.x - self.prevPoint.x);
            float hChange = (point.y - self.prevPoint.y);
            if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) { self.prevPoint = [recognizer locationInView:self]; return; }
            
            if (YES == self.preventsLayoutWhileResizing) {
                if (wChange < 0.0f && hChange < 0.0f) {
                    float change = MIN(wChange, hChange);
                    wChange = change;
                    hChange = change;
                }
                if (wChange < 0.0f) hChange = wChange;
                else if (hChange < 0.0f) wChange = hChange;
                else {
                    float change = MAX(wChange, hChange);
                    wChange = change;
                    hChange = change;
                }
            }
            self.bounds = CGRectMake(self.bounds.origin.x,self.bounds.origin.y,self.bounds.size.width+wChange,self.bounds.size.height+hChange);
            self.resizingControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,self.bounds.size.height-_controlSize.height,_controlSize.width, _controlSize.height);
            self.deleteControl.frame = CGRectMake(0,0,_controlSize.width,_controlSize.height);
            self.customControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,0,_controlSize.width,_controlSize.height);
            self.prevPoint = [recognizer locationInView:self];
        }
        
        /* Rotation */
        float ang = atan2([recognizer locationInView:self.superview].y-self.center.y,[recognizer locationInView:self.superview].x-self.center.x);
        if (!self.preventsResizing) self.rotation = -(self.deltaAngle - ang);
        self.borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
        [self.borderView setNeedsDisplay];
        
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        self.prevPoint = [recognizer locationInView:self];
        if([self.delegate respondsToSelector:@selector(layerViewDidResize:)]) {
            [self.delegate layerViewDidResize:(id)self];
        }
        [self setNeedsDisplay];
    }
}
- (void)setupDefaultAttributes {
    
    
    _globalInset =  UIEdgeInsetsMakeFrom(kSPUserResizableViewGlobalInset);
    _contentScale = CGScaleEqual;
    _controlSize = (CGSize){kMYSTICLABELControlSize, kMYSTICLABELControlSize};
    
    self.ignoreSingleTap = NO;
    
    self.enabled = YES;
    
    
    self.borderView = [[MysticResizeableLayerBorderView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, _globalInset)];
    [self.borderView setHidden:NO];
    [self addSubview:self.borderView];
    
    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5) {
        self.minimumWidth = kSPUserResizableViewDefaultMinWidth;
        self.minimumHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
    } else {
        self.minimumWidth = self.bounds.size.width*0.5;
        self.minimumHeight = self.bounds.size.height*0.5;
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
    
    self.deleteControl = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeLayerX) size:(CGSize){kMYSTICLAYERControlIconSize,kMYSTICLAYERControlIconSize} color:@(MysticColorTypeUnknown)] target:self sel:@selector(deleteTap:)];
    self.deleteControl.contentMode = UIViewContentModeCenter;
    self.deleteControl.frame = CGRectMake(0, 0,
                                     _controlSize.width, _controlSize.height);
    self.deleteControl.hitInsets = UIEdgeInsetsMakeFrom(6);
    self.deleteControl.adjustsImageWhenHighlighted = NO;
    [self addSubview:self.deleteControl];
    
    
    
    
    
    self.resizingControl = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeLayerResize) size:(CGSize){kMYSTICLAYERControlIconSize,kMYSTICLAYERControlIconSize} color:@(MysticColorTypeUnknown)] target:nil sel:@selector(resizeTap:)];
    self.resizingControl.contentMode = UIViewContentModeCenter;
    self.resizingControl.frame = CGRectMake(self.frame.size.width-_controlSize.width,
                                       self.frame.size.height-_controlSize.height,
                                       _controlSize.width, _controlSize.height);
    self.resizingControl.hitInsets = UIEdgeInsetsMakeFrom(6);
    self.resizingControl.adjustsImageWhenHighlighted = NO;
    UIPanGestureRecognizer* panResizeGesture = [[UIPanGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(resizeTranslate:)];
    [self.resizingControl addGestureRecognizer:panResizeGesture];
    [self addSubview:self.resizingControl];
    
//    self.customControl = [[[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-_controlSize.width,
//                                                                 0,
//                                                                 _controlSize.width, _controlSize.height)] autorelease];
//    self.customControl.backgroundColor = [UIColor clearColor];
//    self.customControl.userInteractionEnabled = YES;
//    self.customControl.image = nil;
//    self.customControl.contentMode = UIViewContentModeScaleAspectFit;
//    
//    UITapGestureRecognizer * customTapGesture = [[UITapGestureRecognizer alloc]
//                                                 initWithTarget:self
//                                                 action:@selector(customTap:)];
//    [self.customControl addGestureRecognizer:customTapGesture];
//    [self addSubview:self.customControl];
    
    
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
    
    self.deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
    
//    [customTapGesture release];
    [singleTap release];
    [doubleTap release];
    [panResizeGesture release];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    self.contentView.frame = CGRectInset(UIEdgeInsetsInsetRect(self.bounds, _globalInset), MYSTIC_UI_LAYER_BORDER_SIZE/2, MYSTIC_UI_LAYER_BORDER_SIZE/2);
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    for (UIView* subview in [self.contentView subviews]) {
        [subview setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    self.borderView.frame = UIEdgeInsetsInsetRect(self.bounds, _globalInset);
    self.resizingControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,self.bounds.size.height-_controlSize.height,_controlSize.width,_controlSize.height);
    self.deleteControl.frame = CGRectMake(0, 0, _controlSize.width, _controlSize.height);
    self.customControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,0,_controlSize.width,_controlSize.height);
    [self.borderView setNeedsDisplay];
}
- (void)hideDelHandle
{
    self.deleteControl.hidden = YES;
}

- (void)showDelHandle
{
    self.deleteControl.hidden = NO;
}

- (void)hideEditingHandles
{
    self.resizingControl.hidden = YES;
    self.deleteControl.hidden = YES;
    self.customControl.hidden = YES;
    [self.borderView setHidden:YES];
}

- (void)showEditingHandles
{
    if (!self.preventsCustomButton) self.customControl.hidden = NO;
    else self.customControl.hidden = YES;
    if (!self.preventsDeleting) self.deleteControl.hidden = NO;
    else self.deleteControl.hidden = YES;
    if (!self.preventsResizing) self.resizingControl.hidden = NO;
    else self.resizingControl.hidden = YES;
    [self.borderView setHidden:NO];
}

- (void)showCustmomHandle { self.customControl.hidden = NO; }

- (void)hideCustomHandle { self.customControl.hidden = YES; }

- (void)setButton:(MysticLayerControl)type image:(UIImage*)image
{
    switch (type) {
        case MysticLayerControlResize: [self.resizingControl setImage:image forState:UIControlStateNormal]; break;
        case MysticLayerControlDelete: [self.deleteControl setImage:image forState:UIControlStateNormal]; break;
        case MysticLayerControlCustom: [self.customControl setImage:image forState:UIControlStateNormal]; break;
        default: break;
    }
}

- (NSString *) description; { return [NSString stringWithFormat:@"%@ <%p>", self.option ? [self.option shortName] : @"No option", self]; }


- (void) setContentScale:(CGScale)contentScale;
{
    self.borderView.borderWidth = (self.borderView.borderWidth/_contentScale.x) * contentScale.x;
    _globalInset = UIEdgeInsetsRescale(_globalInset, _contentScale, contentScale);
    CGSize csize = self.controlSize;
    csize.width = csize.width/_contentScale.x;
    csize.height = csize.height/_contentScale.y;
    csize.width = csize.width*contentScale.x;
    csize.height = csize.height*contentScale.y;
    _controlSize = csize;
    _contentScale = contentScale;
    self.resizingControl.frame = CGRectMake(self.frame.size.width-_controlSize.width, self.frame.size.height-_controlSize.height, _controlSize.width, _controlSize.height);
    self.deleteControl.frame = CGRectMake(0, 0, _controlSize.width, _controlSize.height);
    self.customControl.frame = CGRectMake(self.frame.size.width-_controlSize.width, 0, _controlSize.width, _controlSize.height);
    self.contentView.frame = CGRectInset(UIEdgeInsetsInsetRect(self.bounds, _globalInset), MYSTIC_UI_LAYER_BORDER_SIZE/2, MYSTIC_UI_LAYER_BORDER_SIZE/2);
    self.borderView.frame = UIEdgeInsetsInsetRect(self.bounds, _globalInset);
    [self setNeedsDisplay];
}

- (void) applyOptionsFrom:(id <MysticLayerViewAbstract>)layerView; { }
@end
