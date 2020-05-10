//
//  MysticResizeableLabel.m
//  MysticResizableLabel
//
//  Created by travis weerts on 8/15/13.
//  Copyright (c) 2013 Mystic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MysticResizeableLayer.h"
#import "MysticUI.h"
#import "MysticConstants.h"
#import "PackPotionOption.h"

//
//
//#define kSPUserResizableViewGlobalInset 5.0
//#define kSPUserResizableViewDefaultMinWidth 48.0
//#define kSPUserResizableViewInteractiveBorderSize 10.0
//#define _controlSize.width 36.0


@interface MysticResizeableLayer ()
{
    BOOL ignoreSingleTap;
    CGFloat _globalInset;

}

@property (strong, nonatomic) UIImageView *resizingControl;
@property (strong, nonatomic) UIImageView *deleteControl;
@property (strong, nonatomic) UIImageView *customControl;

@property (nonatomic) BOOL preventsLayoutWhileResizing;

@property (nonatomic) float deltaAngle;
@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGAffineTransform startTransform;

@property (nonatomic) CGPoint touchStart;

@end

@implementation MysticResizeableLayer

@synthesize contentView, touchStart;
@synthesize rotation=_rotation;
@synthesize prevPoint;
@synthesize deltaAngle, startTransform; //rotation
@synthesize resizingControl, deleteControl, customControl;
@synthesize preventsPositionOutsideSuperview;
@synthesize preventsResizing;
@synthesize preventsDeleting;
@synthesize preventsCustomButton;
@synthesize minWidth, minHeight, borderView;
@synthesize selected, enabled, contentScale=_contentScale, controlSize=_controlSize;
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


- (BOOL) selected;
{
    return !borderView.hidden;
}

- (void) setEnabled:(BOOL)newValue;
{
    
    if(!newValue && self.selected) [self setSelected:NO notify:NO];
    
    enabled = newValue;
}

- (void) setSelected:(BOOL)v
{
    [self setSelected:v notify:YES];
}
- (void) setSelected:(BOOL)v notify:(BOOL)shouldNotify;
{
    if(!self.enabled) return;
    if(v)
    {
        [self showEditingHandles];
    }
    else
    {
        [self hideEditingHandles];
    }
    
    if(shouldNotify && [_delegate respondsToSelector:@selector(layerViewDidSelect:)]) {
        [_delegate layerViewDidSelect:self];
    }
    
    if(self.selectBlock) self.selectBlock(self);
}

#ifdef MYSTICLABEL_LONGPRESS
-(void)longPress:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if([_delegate respondsToSelector:@selector(layerViewDidLongPressed:)]) {
            [_delegate layerViewDidLongPressed:self];
        }
    }
}
#endif

-(void)singleTap:(UIPanGestureRecognizer *)recognizer
{
//    DLog(@"singleTap: %@ | %@", MBOOL(ignoreSingleTap), [(PackPotionOption *)self.option shortName]);

    if(ignoreSingleTap) return;

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
        if (NO == self.preventsDeleting) {
            UIView * close = (UIView *)[recognizer view];
            [close.superview removeFromSuperview];
        }
    
    
}


- (void) doubleTap:(UITapGestureRecognizer *)recognizer;
{
    
    if(!self.enabled) return;
    
    if([_delegate respondsToSelector:@selector(layerViewDidDoubleTap:)]) {
        [_delegate layerViewDidDoubleTap:self];
    }
    else if(self.doubleTapBlock)
    {
        self.doubleTapBlock(self);
    }
    else
    {
        [self becomeFirstResponder];
    }
    
}


-(void)customTap:(UIPanGestureRecognizer *)recognizer
{
    if (NO == self.preventsCustomButton) {
        if([_delegate respondsToSelector:@selector(layerViewDidCustomButtonTap:)]) {
            [_delegate layerViewDidCustomButtonTap:self];
        }
    }
}

-(void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state]== UIGestureRecognizerStateBegan)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        if (self.bounds.size.width < minWidth || self.bounds.size.height < minHeight)
        {
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     minWidth+1,
                                     minHeight+1);
            resizingControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,
                                              self.bounds.size.height-_controlSize.height,
                                              _controlSize.width,
                                              _controlSize.height);
            deleteControl.frame = CGRectMake(0, 0,
                                             _controlSize.width, _controlSize.height);
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
            
            if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
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
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                                     self.bounds.size.width + (wChange),
                                     self.bounds.size.height + (hChange));
            resizingControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,
                                              self.bounds.size.height-_controlSize.height,
                                              _controlSize.width, _controlSize.height);
            deleteControl.frame = CGRectMake(0, 0,
                                             _controlSize.width, _controlSize.height);
            customControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,
                                            0,
                                            _controlSize.width,
                                            _controlSize.height);
            prevPoint = [recognizer locationInView:self];
        }
        
        /* Rotation */
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x);
        float angleDiff = deltaAngle - ang;
        if (NO == preventsResizing) {
//            self.transform = CGAffineTransformMakeRotation(-angleDiff);
            self.rotation = -angleDiff;

        }
        
        borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
        [borderView setNeedsDisplay];
        
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        if([_delegate respondsToSelector:@selector(layerViewDidResize:)]) {
            [_delegate layerViewDidResize:self];
        }
        [self setNeedsDisplay];
    }
}
- (void) resize;
{
    
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
    resizingControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,
                                      self.bounds.size.height-_controlSize.height,
                                      _controlSize.width, _controlSize.height);
    deleteControl.frame = CGRectMake(0, 0,
                                     _controlSize.width, _controlSize.height);
    customControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,
                                    0,
                                    _controlSize.width,
                                    _controlSize.height);
    
    
    borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
    [borderView setNeedsDisplay];
    
    [self setNeedsDisplay];
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
- (CGFloat) rotation;
{
    return _rotation;
}
- (void) setContentScale:(CGFloat)contentScale;
{
    self.borderView.borderWidth = (self.borderView.borderWidth/_contentScale) * contentScale;
    
    _globalInset = (_globalInset/_contentScale) * contentScale;

    CGSize csize = self.controlSize;
    

    csize.width = csize.width/_contentScale;
    csize.height = csize.height/_contentScale;
    

    

    csize.width = csize.width*contentScale;
    csize.height = csize.height*contentScale;
    _controlSize = csize;
    _contentScale = contentScale;
    
    CGRect resizeFrame = CGRectMake(self.frame.size.width-_controlSize.width,
                                    self.frame.size.height-_controlSize.height,
                                    _controlSize.width, _controlSize.height);
    
    CGRect deleteFrame = CGRectMake(0, 0,
                                    _controlSize.width, _controlSize.height);
    
    
    
    CGRect customFrame = CGRectMake(self.frame.size.width-_controlSize.width,
                                    0,
                                    _controlSize.width, _controlSize.height);
    
    resizingControl.frame = resizeFrame;
    deleteControl.frame = deleteFrame;
    customControl.frame = customFrame;
    
    
    contentView.frame = CGRectInset(self.bounds, _globalInset + kSPUserResizableViewInteractiveBorderSize/2, _globalInset + kSPUserResizableViewInteractiveBorderSize/2);
    borderView.frame = CGRectInset(self.bounds,
                                   _globalInset,
                                   _globalInset);
    
    [self setNeedsDisplay];
}
- (void)setupDefaultAttributes {
    
    _globalInset = kSPUserResizableViewGlobalInset;
    _contentScale = 1;
    _controlSize = (CGSize){kMYSTICLABELControlSize, kMYSTICLABELControlSize};
    
    ignoreSingleTap = NO;

    self.enabled = YES;
    
   
    borderView = [[MysticResizeableLayerBorderView alloc] initWithFrame:CGRectInset(self.bounds, _globalInset, _globalInset)];
    [borderView setHidden:NO];
    [self addSubview:borderView];
    
    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5) {
        self.minWidth = kSPUserResizableViewDefaultMinWidth;
        self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
    } else {
        self.minWidth = self.bounds.size.width*0.5;
        self.minHeight = self.bounds.size.height*0.5;
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
    deleteControl = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,
                                                                 _controlSize.width, _controlSize.height)];
    deleteControl.contentMode = UIViewContentModeScaleAspectFit;

    deleteControl.backgroundColor = [UIColor clearColor];
    deleteControl.image = [UIImage imageNamed:@"delete-Circle.png" ];
    deleteControl.userInteractionEnabled = YES;
    UITapGestureRecognizer * deleteTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(deleteTap:)];
    [deleteControl addGestureRecognizer:deleteTap];
    

    [self addSubview:deleteControl];
    
    resizingControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-_controlSize.width,
                                                                   self.frame.size.height-_controlSize.height,
                                                                   _controlSize.width, _controlSize.height)];
    resizingControl.backgroundColor = [UIColor clearColor];
    resizingControl.userInteractionEnabled = YES;
    resizingControl.contentMode = UIViewContentModeScaleAspectFit;

    resizingControl.image = [UIImage imageNamed:@"resize-Circle.png" ];
    UIPanGestureRecognizer* panResizeGesture = [[UIPanGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(resizeTranslate:)];
    [resizingControl addGestureRecognizer:panResizeGesture];
    [self addSubview:resizingControl];
    
    customControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-_controlSize.width,
                                                                 0,
                                                                 _controlSize.width, _controlSize.height)];
    customControl.backgroundColor = [UIColor clearColor];
    customControl.userInteractionEnabled = YES;
    customControl.image = nil;
    customControl.contentMode = UIViewContentModeScaleAspectFit;

    UITapGestureRecognizer * customTapGesture = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(customTap:)];
    [customControl addGestureRecognizer:customTapGesture];
    [self addSubview:customControl];
    
    
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
}

- (id)initWithFrame:(CGRect)frame {
    _globalInset = kSPUserResizableViewGlobalInset;
    _contentScale = 1;
    _controlSize = (CGSize){kMYSTICLABELControlSize, kMYSTICLABELControlSize};
    
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _globalInset = kSPUserResizableViewGlobalInset;
    _contentScale = 1;
    _controlSize = (CGSize){kMYSTICLABELControlSize, kMYSTICLABELControlSize};
    
    
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (void)setContentView:(UIView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    contentView.frame = CGRectInset(self.bounds, _globalInset + kSPUserResizableViewInteractiveBorderSize/2, _globalInset + kSPUserResizableViewInteractiveBorderSize/2);
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    
    for (UIView* subview in [contentView subviews]) {
        [subview setFrame:CGRectMake(0, 0,
                                     contentView.frame.size.width,
                                     contentView.frame.size.height)];
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    [self bringSubviewToFront:borderView];
    [self bringSubviewToFront:resizingControl];
    [self bringSubviewToFront:deleteControl];
    [self bringSubviewToFront:customControl];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    contentView.frame = CGRectInset(self.bounds, _globalInset + kSPUserResizableViewInteractiveBorderSize/2, _globalInset + kSPUserResizableViewInteractiveBorderSize/2);
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    for (UIView* subview in [contentView subviews]) {
        [subview setFrame:CGRectMake(0, 0,
                                     contentView.frame.size.width,
                                     contentView.frame.size.height)];
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    borderView.frame = CGRectInset(self.bounds,
                                   _globalInset,
                                   _globalInset);
    resizingControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,
                                      self.bounds.size.height-_controlSize.height,
                                      _controlSize.width,
                                      _controlSize.height);
    deleteControl.frame = CGRectMake(0, 0,
                                     _controlSize.width, _controlSize.height);
    customControl.frame =CGRectMake(self.bounds.size.width-_controlSize.width,
                                    0,
                                    _controlSize.width,
                                    _controlSize.height);
    [borderView setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    ignoreSingleTap = NO;

    UITouch *touch = [touches anyObject];
    touchStart = [touch locationInView:self.superview];
    if([_delegate respondsToSelector:@selector(layerViewDidBeginMoving:)]) {
        [_delegate layerViewDidBeginMoving:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(layerViewDidEndMoving:)]) {
        [_delegate layerViewDidEndMoving:self];
    }
    else if(self.movedBlock) self.movedBlock(self);

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    ignoreSingleTap = NO;

    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(layerViewDidCancelMoving:)]) {
        [_delegate layerViewDidCancelMoving:self];
    }
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
    self.center = newCenter;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    ignoreSingleTap = YES;

    
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(resizingControl.frame, touchLocation)) {
        return;
    }
    
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    [self translateUsingTouchLocation:touch];
    touchStart = touch;
//    
//    if(self.selected && [_delegate respondsToSelector:@selector(layerViewDidMove:)]) {
//        [_delegate layerViewDidMove:self];
//    }
}

- (void)hideDelHandle
{
    deleteControl.hidden = YES;
}

- (void)showDelHandle
{
    deleteControl.hidden = NO;
}

- (void)hideEditingHandles
{
    resizingControl.hidden = YES;
    deleteControl.hidden = YES;
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
        deleteControl.hidden = NO;
    } else {
        deleteControl.hidden = YES;
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

- (void)setButton:(MYSTICLAYER_BUTTONS)type image:(UIImage*)image
{
    switch (type) {
        case MYSTICLAYER_BUTTON_RESIZE:
            resizingControl.image = image;
            break;
        case MYSTICLAYER_BUTTON_DEL:
            deleteControl.image = image;
            break;
        case MYSTICLAYER_BUTTON_CUSTOM:
            customControl.image = image;
            break;
            
        default:
            break;
    }
}

- (NSString *) description;
{
    return [NSString stringWithFormat:@"%@ <%p>", self.option ? [self.option shortName] : @"No option", self];
}

@end