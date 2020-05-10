//
//  MysticLayerBaseView.m
//  Mystic
//
//  Created by Me on 12/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLayerBaseView.h"
#import "MysticOverlaysView.h"
#import "MysticLayerContentView.h"
#import "MysticDrawLayerView.h"

@interface MysticLayerBaseView ()
{
    CGPoint _resizeSupStartPoint;
}
@end
@implementation MysticLayerBaseView

@synthesize showDropShadowWhenSelected=_showDropShadowWhenSelected, userResized=_userResized;

+ (UIEdgeInsets) contentInsetsForScale:(CGFloat)_scale;
{
    UIEdgeInsets _borderInset = UIEdgeInsetsMake(kSPUserResizableViewBorderInset_Y*_scale,
                                                 kSPUserResizableViewBorderInset_X*_scale,
                                                 kSPUserResizableViewBorderInset_Y*_scale,
                                                 kSPUserResizableViewBorderInset_X*_scale);
    
    UIEdgeInsets _globalInset = UIEdgeInsetsMakeFrom(kSPUserResizableViewGlobalInset*_scale);
    
    UIEdgeInsets c = UIEdgeInsetsMake(MYSTIC_LAYER_CONTENT_INSET_TOP *_scale,
                                                  MYSTIC_LAYER_CONTENT_INSET_LEFT *_scale,
                                                  MYSTIC_LAYER_CONTENT_INSET_BTM *_scale,
                                                  MYSTIC_LAYER_CONTENT_INSET_RIGHT *_scale);
    
    
    UIEdgeInsets ins = UIEdgeInsetsMake((_globalInset.top+_borderInset.top+c.top),
                                        (_globalInset.left+_borderInset.left+c.left),
                                        (_globalInset.bottom+_borderInset.bottom+c.bottom),
                                        (_globalInset.right+_borderInset.right+c.right));
    return ins;
}
+ (CGPoint) originForContentFrame:(CGRect)contentFrame scale:(CGFloat)_scale;
{
    UIEdgeInsets _borderInset = UIEdgeInsetsMake(kSPUserResizableViewBorderInset_Y*_scale, kSPUserResizableViewBorderInset_X*_scale, kSPUserResizableViewBorderInset_Y*_scale, kSPUserResizableViewBorderInset_X*_scale);
    UIEdgeInsets _globalInset = UIEdgeInsetsMakeFrom(kSPUserResizableViewGlobalInset*_scale);
    UIEdgeInsets c = UIEdgeInsetsMake(MYSTIC_LAYER_CONTENT_INSET_TOP *_scale, MYSTIC_LAYER_CONTENT_INSET_LEFT *_scale, MYSTIC_LAYER_CONTENT_INSET_BTM *_scale, MYSTIC_LAYER_CONTENT_INSET_RIGHT *_scale);
    CGFloat _borderWidth = MYSTIC_UI_LAYER_BORDER*_scale;
    
    return CGPointMake(_globalInset.left+_borderInset.left+c.left, _globalInset.top+_borderInset.top+c.top);
}
+ (CGRect) frameForContentBounds:(CGRect)contentBounds scale:(CGFloat)_scale;
{
    UIEdgeInsets _borderInset = UIEdgeInsetsMake(kSPUserResizableViewBorderInset_Y*_scale,
                                                 kSPUserResizableViewBorderInset_X*_scale,
                                                 kSPUserResizableViewBorderInset_Y*_scale,
                                                 kSPUserResizableViewBorderInset_X*_scale);
    
    UIEdgeInsets _globalInset = UIEdgeInsetsMakeFrom(kSPUserResizableViewGlobalInset*_scale);
    
    UIEdgeInsets c = UIEdgeInsetsMake(MYSTIC_LAYER_CONTENT_INSET_TOP *_scale,
                                                  MYSTIC_LAYER_CONTENT_INSET_LEFT *_scale,
                                                  MYSTIC_LAYER_CONTENT_INSET_BTM *_scale,
                                                  MYSTIC_LAYER_CONTENT_INSET_RIGHT *_scale);
    
    
    return UIEdgeInsetsInsetRect(CGRectSizeCeil(contentBounds), UIEdgeInsetsInverse(UIEdgeInsetsMake(_globalInset.top+_borderInset.top+c.top,
                                                                                                     _globalInset.left+_borderInset.left+c.left,
                                                                                                     _globalInset.bottom+_borderInset.bottom+c.bottom,
                                                                                                     _globalInset.right+_borderInset.right+c.right)));
}
+ (CGRect) boundsForContent:(id)content target:(CGSize)targetSize context:(MysticDrawingContext **)context scale:(CGFloat)_scale;
{
    CGRect newBounds = CGRectSize(targetSize);
    if(!content) return newBounds;
    
    CGSize contentSize = CGSizeZero;
    if([content respondsToSelector:@selector(size)])
    {
        contentSize = [(UIImage *)content size];
    }
    else if([content respondsToSelector:@selector(frame)])
    {
        contentSize = [(UIView *)content frame].size;
    }
    else if([content respondsToSelector:@selector(bounds)])
    {
        contentSize = [(UIView *)content bounds].size;
    }
    
    return CGSizeIsZero(contentSize) ? newBounds : CGRectWithContentMode(CGRectSize(contentSize), newBounds, UIViewContentModeScaleAspectFit);
}

#pragma mark - Dealloc

- (void) dealloc;
{
    _delegate = nil;
    _parentView = nil;
    [_contentView release], _contentView=nil;
    [_borderView release], _borderView=nil;
    [_color release], _color=nil;
    [_borderColor release], _borderColor=nil;
    /* added release */
    [_rasterImageView release], _rasterImageView=nil;
    Block_release(_editingBlock);
    [_option release];
    [_content release];
    [_contentInfo release];
    /* end of added release */
    _option=nil;
    _activeTarget = nil;
    _textView = nil;
    _drawView = nil;
    _transView = nil;
    Block_release(_selectBlock);
    Block_release(_editedBlock);
    Block_release(_editedBlock);
    Block_release(_movedBlock);
    Block_release(_longPressBlock);
    Block_release(_singleTapBlock);
    Block_release(_doubleTapBlock);
    Block_release(_deleteBlock);
    Block_release(_customTapBlock);
    Block_release(_keyboardWillHideBlock);
    Block_release(_keyboardWillShowBlock);
    [_resizingControl release], _resizingControl=nil;
    [_deleteControl release], _deleteControl=nil;
    [_customControl release], _customControl=nil;
    [super dealloc];
}

#pragma mark - Init

- (id) init; {  _shouldRedraw = YES; self = [super init]; _previousAlpha = NAN; _scale = MYSTIC_FLOAT_UNKNOWN; return self; }
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame]; if(self) { _frameValue = frame; [self commonInit]; }
    return self;
}
- (id)initWithFrame:(CGRect)frame scale:(CGFloat)scale;
{
    return [self initWithFrame:frame contentFrame:CGRectZero scale:scale context:nil];
}
- (id) initWithFrame:(CGRect)frame contentFrame:(CGRect)contentFrame scale:(CGFloat)scale context:(MysticDrawingContext *)context;
{
    self = [super initWithFrame:frame];
    if(self) {
        _frameValue = frame;
        _scale = scale;
        _contentFrame = contentFrame;
        _drawContext=context ? [context copy] : nil;
        [self commonInit];
    }
    return self;
}


#pragma mark - CommonInit Reset & Update

- (void) commonInit;
{
    self.autoresizesSubviews = NO;
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
    _userResized = NO;
    _position = MysticPositionCenter;
    _showDropShadowWhenSelected = YES;
    _showContentDropShadowWhenSelected = NO;
    _hasChangedShadow = NO;
    _type = MysticObjectTypeUnknown;
    _option = nil;
    _track = NO;
    _state = UIControlStateNormal;
    _delegate = nil;
    _adjustsAspectRatioOnResize = NO;
    _index = 0;
    _shouldRelayout = NO;
    _isDisposable = NO;
    _shouldFactorOnResize = YES;
    _maxBounds = CGRectZero;
    _boundingRect = CGRectZero;
    _lastAngle = 0;
    _minimumRotationChange = 0.06f;
    _rotationSnapping = YES;
    _editable = _usesBorderControl = _preventsCustomButton = YES;
    _preventsDeleting = _scalesUpContent = NO;
    _preventsPositionOutsideSuperview = NO;
    _contentScale = CGScaleZero;
    _rotatePosition = MysticPositionUnknown;
    _minimumHeight = kSPUserResizableViewDefaultMinHeight;
    _minimumWidth = kSPUserResizableViewDefaultMinWidth;
    _minWidthNoScale = _minimumWidth;
    _minHeightNoScale = _minimumHeight;
    _handles = MysticPositionRight|MysticPositionLeft|MysticPositionBottom;
    _canHold = YES;
    _preventsLayoutWhileResizing = YES;
    _centerPoint = self.center;
    _previousAlpha = NAN;
    _resizeScaleFactor = MYSTIC_LAYER_RESIZE_SCALE_FACTOR;
    _alignPosition = MysticPositionCenter;
    self.scale = _scale == MYSTIC_FLOAT_UNKNOWN ? 1 : _scale;
    [self reset];
}

- (void) reset;
{
    _selected = _isKeyObject = NO;
    _enabled = YES;
    _previouslyEnabled = YES;
    _hasHiddenControls = NO;
    _effect = MysticLayerEffectNone;
    _previousAlpha = NAN;
}
- (void) update; {}



- (MysticChoice *) choice; { return (id)self.content; }
- (void) setChoice:(MysticChoice *)choice;
{
    self.content = choice;
}

- (CGRect) boundingRect;
{
    if(!CGRectEqualToRect(_boundingRect, CGRectZero)) return _boundingRect;
    if(self.superview) return self.superview.bounds;
    if(self.layersView) return [(UIView *)self.layersView bounds];
    return _boundingRect;
}
- (CGFloat) contentViewRescale;
{
    return 1;
//    return MAX([Mystic scale], 2);
}
- (CGScale) contentViewScale;
{
    return self.contentView.transformScale;
}

#pragma mark - Load View

- (void) loadView;
{
    if(self.usesBorderControl)
    {
        _borderView = [[MysticResizeableLayerBorderView alloc] initWithFrame:[self frameForControl:MysticLayerControlBorder]];
        _borderView.borderWidth = self.borderWidth;
        _borderView.handlePostions = _handles;
        _borderView.handleScale = _scale;
        [self addSubview:_borderView];
    }
    
    if(!self.preventsDeleting)
    {
        _deleteControl = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeLayerX) size:_controlSize color:@(MysticColorTypeUnknown)] target:self sel:@selector(delete:)];
        _deleteControl.contentMode = UIViewContentModeCenter;
        _deleteControl.frame = [self frameForControl:MysticLayerControlDelete];
        _deleteControl.hitInsets = UIEdgeInsetsMakeFrom(kMYSTICLAYERControlHitInset*_scale);
        [self addSubview:_deleteControl];
    }
    
    if(!self.preventsResizing)
    {
        _resizingControl = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeLayerResize) size:_controlSize color:@(MysticColorTypeUnknown)] target:nil sel:@selector(resizeTap:)];
        _resizingControl.contentMode = UIViewContentModeCenter;
        _resizingControl.frame = [self frameForControl:MysticLayerControlResize];
        _resizingControl.hitInsets = UIEdgeInsetsMakeFrom(kMYSTICLAYERControlHitInset*_scale);
        [_resizingControl addGestureRecognizer:[[[UIPanGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(resize:)] autorelease]];
        [self addSubview:_resizingControl];
    }
    
    if(!self.preventsCustomButton)
    {
        _customControl = [MysticButton buttonWithImage:[MysticImage image:@(_customControlIconType) size:_controlSize color:@(MysticColorTypeWhite)] target:self sel:@selector(custom:)];
        _customControl.contentMode = UIViewContentModeCenter;
        _customControl.hitInsets = UIEdgeInsetsMakeFrom(kMYSTICLAYERControlHitInset*_scale);
        _customControl.frame = [self frameForControl:MysticLayerControlCustom];
        [self addSubview:_customControl];
    }
    
    if(self.canHold)
    {
        UILongPressGestureRecognizer* longpress = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(longPress:)];
        [self addGestureRecognizer:[longpress autorelease]];
    }
    
    UITapGestureRecognizer * doubleTap = [[[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(doubleTap:)] autorelease];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer * singleTap = [[[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(singleTap:)] autorelease];
    singleTap.numberOfTapsRequired = 1;
    
    [self addGestureRecognizer:singleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    CGRect cFrame = CGRectIsZero(_contentFrame) ? [self frameForControl:MysticLayerControlContent] : _contentFrame;
    MysticLayerContentView *cview = [[MysticLayerContentView alloc] initWithFrame:cFrame];
    cview.layerView = self;
    cview.scale = self.contentViewRescale;
    self.contentView = [cview autorelease];
    [self addSubview:self.contentView];
    [self sendSubviewToBack:self.contentView];
    self.ratio = CGRectRatio(self.bounds);
    self.deltaAngle = CGRectAtan2(self.frame, self.center);

}

- (void) setDrawView:(MysticDrawLayerView *)drawView;
{
    if(self.contentView) {
        drawView.frame = self.contentView.contentBounds;
        self.contentView.view = drawView;
    }
}
- (MysticDrawLayerView *) drawView;
{
    return [self.contentView.view isKindOfClass:[MysticDrawLayerView class]] ? (id)self.contentView.view : nil;
}


#pragma mark - Set scaling

- (void) setScale:(CGFloat)scale;
{
    BOOL c = scale != _scale;
    _scale = scale;
    _borderInset = UIEdgeInsetsMake(kSPUserResizableViewBorderInset_Y*_scale, kSPUserResizableViewBorderInset_X*_scale, kSPUserResizableViewBorderInset_Y*_scale, kSPUserResizableViewBorderInset_X*_scale);
    _globalInset = UIEdgeInsetsMakeFrom(kSPUserResizableViewGlobalInset*_scale);
    _contentInset = UIEdgeInsetsMake(MYSTIC_LAYER_CONTENT_INSET_TOP *_scale, MYSTIC_LAYER_CONTENT_INSET_LEFT *_scale, MYSTIC_LAYER_CONTENT_INSET_BTM *_scale, MYSTIC_LAYER_CONTENT_INSET_RIGHT *_scale);
    _borderWidth = MYSTIC_UI_LAYER_BORDER*_scale;
    _controlSize = (CGSize){kMYSTICLAYERControlIconSize*_scale, kMYSTICLAYERControlIconSize*_scale};
    _controlInset = UIEdgeInsetsMake(kMYSTICLAYERControlInset_T*_scale, kMYSTICLAYERControlInset_L*_scale, kMYSTICLAYERControlInset_B*_scale, kMYSTICLAYERControlInset_R*_scale);
    if(CGScaleIsZero(self.contentScale)) self.contentScale = CGScaleWith(_scale);
    if(_borderView) _borderView.handleScale = _scale;
    
    self.minimumHeight = self.minHeightNoScale;
    self.minimumWidth = self.minWidthNoScale;

    if(c) [self setNeedsLayout];
}

- (void) setMinimumHeight:(CGFloat)v;
{
    UIEdgeInsets ins = [self insetsForControl:MysticLayerControlContent];
    _minimumHeight = (v*_scale) + ins.top + ins.bottom;
    self.minHeightNoScale = v;
}

- (void) setMinimumWidth:(CGFloat)v;
{
    UIEdgeInsets ins = [self insetsForControl:MysticLayerControlContent];
    _minimumWidth = (v*_scale) + ins.left + ins.right;
    self.minWidthNoScale = v;
}





#pragma mark - Interface Controls

- (void) setHandles:(MysticPosition)handles;
{
    _handles = handles;
    if(!self.usesBorderControl) return;
    if(_borderView)
    {
        _borderView.handlePostions = handles;
    }
}
- (void) setIsInBackground:(BOOL)isInBackground;
{
    CGFloat pa = self.alpha;
    self.alpha = isInBackground ? 0.15 : isnan(_previousAlpha) ? 1 : _previousAlpha;
    _isInBackground = isInBackground;
    if(!_isInBackground && isnan(_previousAlpha))
    {
        _previousAlpha = pa;
    }
    else if(!_isInBackground)
    {
        _previousAlpha = NAN;
    }
    if(_isInBackground)
    {
        [self setEnabledAndKeepSelection:NO];
    }
    else
    {
        [self setEnabledAndKeepSelection:self.previouslyEnabled];
    }
    if(isnan(_previousAlpha) && _isInBackground) _previousAlpha = pa;

    
}
- (void) hideControls:(BOOL)animated;
{
    [self hideControls:MysticLayerControlAll animated:animated];
}
- (void) hideControls:(MysticLayerControl)controlTypes animated:(BOOL)animated;
{
    if(controlTypes & MysticLayerControlNone) return;
    
    self.hasHiddenControls = YES;
    if(controlTypes & MysticLayerControlAll)
    {
        _customControl.hidden = YES;
        _deleteControl.hidden = YES;
        _resizingControl.hidden = YES;
        _borderView.hidden = YES;
    }
    else
    {
        if(controlTypes & MysticLayerControlCustom)    _customControl.hidden = YES;
        if(controlTypes & MysticLayerControlDelete)    _deleteControl.hidden = YES;
        if(controlTypes & MysticLayerControlResize)    _resizingControl.hidden = YES;
        if(controlTypes & MysticLayerControlBorder)    _borderView.hidden = YES;
        if(controlTypes & MysticLayerControlHandles)   _borderView.handlesHidden = YES;
    }
}
- (void) showControls:(BOOL)animated;
{
    [self showControls:MysticLayerControlAll animated:animated];
}
- (void) showControls:(MysticLayerControl)controlTypes animated:(BOOL)animated;
{
    if(controlTypes & MysticLayerControlNone) return;
    
    self.hasHiddenControls = NO;
    if(controlTypes & MysticLayerControlAll)
    {
        _customControl.hidden = NO;
        _deleteControl.hidden = NO;
        _resizingControl.hidden = NO;
        _borderView.hidden = NO;
        
        _customControl.alpha = _customControl.alpha==0 ? 1 : _customControl.alpha;
        _deleteControl.alpha = _deleteControl.alpha==0 ? 1 : _deleteControl.alpha;
        _resizingControl.alpha = _resizingControl.alpha==0 ? 1 : _resizingControl.alpha;
        _borderView.alpha = _borderView.alpha==0 ? 1 : _borderView.alpha;
        
    }
    else
    {
        if(controlTypes & MysticLayerControlCustom)  {  _customControl.hidden = NO; _customControl.alpha = _customControl.alpha==0 ? 1 : _customControl.alpha; }
        if(controlTypes & MysticLayerControlDelete)  { _deleteControl.hidden = NO; _deleteControl.alpha = _deleteControl.alpha==0 ? 1 : _deleteControl.alpha; }
        if(controlTypes & MysticLayerControlResize)  { _resizingControl.hidden = NO; _resizingControl.alpha = _resizingControl.alpha==0 ? 1 : _resizingControl.alpha; }
        if(controlTypes & MysticLayerControlBorder)  { _borderView.hidden = NO; _borderView.alpha = _borderView.alpha==0 ? 1 : _borderView.alpha; }
        if(controlTypes & MysticLayerControlHandles) { _borderView.handlesHidden = NO; }
    }
}

- (CGFloat) offsetHeight;
{
    return (self.contentView.bounds.size.height/3)*.4;
}
- (BOOL) rebuildContext;
{
    return self.drawContext ? [self.drawContext setNextTargetSize:_contentFrame.size] : NO;
}
- (void) endDraw:(CGRect)rect;
{
    
}

- (void) setButton:(MysticLayerControl)type image:(UIImage*)image;
{
    switch (type) {
        case MysticLayerControlResize:
            if(_resizingControl) [_resizingControl setImage:image forState:UIControlStateNormal];
            break;
        case MysticLayerControlDelete:
            if(_deleteControl) [_deleteControl setImage:image forState:UIControlStateNormal];
            break;
        case MysticLayerControlCustom:
            if(_customControl) [_customControl setImage:image forState:UIControlStateNormal];
            break;
        default:  break;
    }
}
- (void) redraw;
{
    [self redraw:YES];
}
- (void) redraw:(BOOL)layout;
{
    if(self.rasterImageView) [self.rasterImageView removeFromSuperview], self.rasterImageView = nil;
}
- (BOOL) hidden;
{
    return super.hidden;
}
#pragma mark - Adjustments

- (void) applyOptionsFrom:(id <MysticLayerViewAbstract>)layerView;
{
    
}



#pragma mark - Resize -------------

- (void) resize:(UIPanGestureRecognizer *)recognizer;
{
    BOOL skipResizeScale = NO;
    BOOL skipRotate = NO;
    CGPoint point = [recognizer locationInView:self];
    CGPoint sPoint = [recognizer locationInView:self.superview];
    CGRect bounds = self.bounds;
    CGFloat pointAngle = 0, startPointAngle=0;
    if ([recognizer state]== UIGestureRecognizerStateBegan)
    {
        _centerPoint = self.center;
        _prevResizePoint = point;
        _prevResizeSupPoint = sPoint;
        _prevDistFromCenter = CGPointDistanceFrom(self.center, _prevResizePoint);
        _prevPointFromCenter = CGPointDiff(self.center, point);
        _startBounds = bounds;
        [self setNeedsDisplay];
        [self delegate:@selector(layerViewDidBeginMoving:)];
        
    }
    else
    {
        self.userResized = YES;
        CGFloat distFromCenter = CGPointDistanceFrom(self.center, point);
        CGPoint pointFromCenter = CGPointDiff(self.center, point);

        if ([recognizer state] == UIGestureRecognizerStateChanged)
        {
            if (bounds.size.width < _minimumWidth || bounds.size.height < _minimumHeight)
            {
                [self setNewBounds:[self adjustedBounds:CGRectS(bounds, (CGSize){MIN(_minimumWidth,bounds.size.width),
                    MIN(_minimumHeight,bounds.size.height)})]];
                _prevResizePoint = point;
                _prevDistFromCenter = distFromCenter;
                _prevPointFromCenter = pointFromCenter;
                _prevResizeSupPoint = sPoint;
            }
            else
            {
                float wChange = (point.x - _prevResizePoint.x);
                float hChange = (point.y - _prevResizePoint.y);
                if (ABS(MAX(wChange, hChange)) > 22.0f) {
                    _prevResizePoint = point;
                    _prevDistFromCenter = distFromCenter;
                    _prevPointFromCenter = pointFromCenter;
                    _prevResizeSupPoint = sPoint;
                    return;
                }
                if (self.preventsLayoutWhileResizing) {
                    wChange = (wChange < 0.0f || hChange < 0.0f) ?  MIN(wChange, hChange) : MAX(wChange, hChange);
                    hChange = wChange;
                }
                
                // makes the drag happen faster
                if(_shouldFactorOnResize)
                {
                    wChange = wChange*self.resizeScaleFactor;
                    hChange = hChange*self.resizeScaleFactor;
                }

                if(CGRectIsTall(bounds))
                {
                    bounds.size.height+=hChange;
                    bounds.size.width=bounds.size.height*self.ratio;
                }
                else
                {
                    bounds.size.width+=wChange;
                    bounds.size.height=bounds.size.width*self.ratio;
                }
                bounds = CGRectz(UIEdgeInsetsInsetRect(CGRectApplyRatio(UIEdgeInsetsInsetRect(bounds, self.totalContentInsets), CGRectRatio(self.contentView.frame)), UIEdgeInsetsInverse(self.totalContentInsets)));

                if (bounds.size.width >= _minimumWidth || bounds.size.height >= _minimumHeight)
                {
                    [self setNewBounds:bounds];
                    [self layoutControls];
                    _addedInsets = UIEdgeInsetsScale(_addedInsets, self.contentViewScale);
                    _prevResizePoint = point;
                    _prevDistFromCenter = distFromCenter;
                    _prevPointFromCenter = pointFromCenter;
                    _prevResizeSupPoint = sPoint;
                }
            }
            
            if(!skipRotate)
            {
                float angleDiff = self.deltaAngle - atan2(sPoint.y - self.center.y, sPoint.x - self.center.x);
                if(self.rotationSnapping)
                {
                    BOOL shouldRotate = angleDiff < -_minimumRotationChange || angleDiff > _minimumRotationChange ? YES : NO;
                    if(shouldRotate)
                    {
                        shouldRotate = !(angleDiff < -12 && angleDiff > -1.63);
                        if(!shouldRotate) angleDiff = -17;
                    }
                    if(shouldRotate && angleDiff != -17)
                    {
                        shouldRotate = !(angleDiff > 12 && angleDiff > 1.63);
                        if(!shouldRotate) angleDiff = 17;
                    }
                    angleDiff = shouldRotate || fabs(angleDiff)==17 ? angleDiff : 0;
                }
                if (!_preventsResizing) {
                    [self delegate:@selector(layerViewDidMove:)];
                    self.rotation = -angleDiff;
                }
            }
        }
        else if ([recognizer state] == UIGestureRecognizerStateEnded)
        {
            [self setCenter:self.center];
            [self showControls:YES];
            _prevResizePoint = point;
            _prevDistFromCenter = distFromCenter;
            _prevResizeSupPoint = sPoint;
            _prevPointFromCenter = pointFromCenter;
            if(self.selected) [self delegate:@selector(layerViewDidEndMoving:)];
            [self rebuildContext];
            [self setNeedsDisplay];
        }
    }
}

- (void) transformSize:(CGFloat)percent;
{
    CGRect newBounds = self.bounds;
    newBounds.size.width += newBounds.size.width*percent;
    newBounds.size.height += newBounds.size.height*percent;
    newBounds = [self adjustedBounds:newBounds];
    newBounds.origin = CGPointZero;
    
    CGRect contentFrame = [self.contentView adjustedBounds:[self frameForControl:MysticLayerControlContent bounds:newBounds]];
    newBounds = [self boundsForContentFrame:contentFrame];
    if (newBounds.size.width >= _minimumWidth || newBounds.size.height >= _minimumHeight)
    {
        [self setNewBounds:newBounds];
        [self layoutControls];
        [self rebuildContext];
    }
}


#pragma mark - Rotation

- (CGFloat) rotation; { return _lastAngle; }
- (void) changeRotation:(CGFloat)change; { self.rotation = _lastAngle + change; [self rebuildContext]; }
- (void) setRotation:(CGFloat)value;
{
    self.transform = CGAffineTransformMakeRotation(value);
    _lastAngle = value;
}


#pragma mark - Events

- (void) delete:(MysticButton *)sender;
{
    if(![self delegate:@selector(layerViewDidClose:)] && self.deleteBlock)
    {
        self.deleteBlock(self);
    }
    else  if (NO == self.preventsDeleting) {
        [sender.superview removeFromSuperview];
    }
}

- (void) custom:(MysticButton *)sender;
{
    [self delegate:@selector(layerViewDidCustomButtonTap:)];
}

- (void) singleTap:(UITapGestureRecognizer *)recognizer;
{
    if(_ignoreSingleTap || recognizer.state != UIGestureRecognizerStateEnded || !self.enabled) return;
    
    if(![self delegate:@selector(layerViewDidSingleTap:)] && self.singleTapBlock)
    {
        self.singleTapBlock(self);
    }
    else
    {
        if(!self.enabled) return;
        if(!self.selected) self.selected = YES;
    }
    
}
- (void) doubleTapped; {}
- (void) doubleTap:(UITapGestureRecognizer *)recognizer;
{
    if(recognizer.state != UIGestureRecognizerStateEnded) return;
    [self delegate:@selector(layerViewDidDoubleTap:)];
    
    if(self.doubleTapBlock)
        self.doubleTapBlock(self);
    else
        [self doubleTapped];
    
}

- (void) longPress:(UILongPressGestureRecognizer *)gesture;
{
    if(gesture.view == _resizingControl || gesture.view == _deleteControl || !self.enabled) return;
//    DLog(@"long press detected: %@", self);
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        [self delegate:@selector(layerViewWillLongPress:gesture:) object:self object:gesture];

    }
    else
    {
        [self delegate:@selector(layerViewDidLongPress:gesture:) object:self object:gesture];


    }
}

- (void) setCanHold:(BOOL)canHold;
{
    if(!canHold && _canHold)
    {
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
            if([gesture isKindOfClass:[UILongPressGestureRecognizer class]])
            {
                [self removeGestureRecognizer:gesture]; break;
            }
        }
    }
    _canHold = canHold;

}

#pragma mark - Touches


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    _wasMoving=NO; _ignoreSingleTap = NO;

    [super touchesBegan:touches withEvent:event];
    if(!self.enabled) return;

    UITouch *touch = [touches anyObject];
    _ignoreSingleTap = NO; _wasSelected = self.selected; _wasMoving = NO;
    _touchStart = [touch locationInView:self.superview];
    [self delegate:@selector(layerViewDidBeginMoving:)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    _wasMoving=NO; _ignoreSingleTap = NO;

    [super touchesEnded:touches withEvent:event];
    if(!self.enabled) return;
    UITouch *touch = [touches anyObject];
    if(touch.view != _resizingControl  && _wasSelected) [self showControls:YES];
    if(![self delegate:@selector(layerViewDidEndMoving:)] && self.movedBlock) self.movedBlock(self);
    _wasMoving = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{
    _wasMoving=NO; _ignoreSingleTap = NO;

    [super touchesCancelled:touches withEvent:event];
    if(!self.enabled) return;

    UITouch *touch = [touches anyObject];
    if(touch.view != _resizingControl && _wasMoving && _wasSelected) [self showControls:YES];
    _ignoreSingleTap = NO;
    if(![self delegate:@selector(layerViewDidCancelMoving:)] &&
            ![self delegate:@selector(layerViewDidEndMoving:)] &&
            self.movedBlock)
        self.movedBlock(self);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    

    [super touchesMoved:touches withEvent:event];
    if(!self.enabled) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.superview];
    
    _wasMoving=NO; _ignoreSingleTap = NO;

    if (CGPointEqualToPoint(touchPoint, _touchStart) ||  CGRectContainsPoint(_resizingControl.frame, touchPoint)) return;
    _wasMoving=YES; _ignoreSingleTap = YES;

    if(!self.hasHiddenControls) [self hideControls:YES];
    [self translateUsingTouchLocation:touchPoint];
    _touchStart = touchPoint;
    [self delegate:@selector(layerViewDidMove:)];
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
//    DLog(@"trans: selected: %@  |  %@", MBOOL(self.selected), MBOOL(self.enabled));
    
    if(!self.selected || !self.enabled)  return;

    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - _touchStart.x,
                                    self.center.y + touchPoint.y - _touchStart.y);
    
    if (self.preventsPositionOutsideSuperview)
    {
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }
        if (newCenter.x < midPointX)
            newCenter.x = midPointX;
        
        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }
        if (newCenter.y < midPointY)
            newCenter.y = midPointY;
        
    }

    
    _centerPoint = newCenter;
    self.center = newCenter;
}




#pragma mark - Select & Enable
- (void) setEnabledAndKeepSelection:(BOOL)enabled;
{
    _previouslyEnabled = _enabled;
    _enabled = enabled;
    self.userInteractionEnabled = _enabled;

}
- (void) setEnabled:(BOOL)newValue;
{
    if(self.selected) self.selected = NO;
    [self setEnabledAndKeepSelection:newValue];
}

- (void) setSelected:(BOOL)v {    [self setSelected:v notify:YES]; }
- (void) setSelected:(BOOL)v notify:(BOOL)shouldNotify;
{
    if(!self.enabled) return;
    _selected = v;
    if(v)
        [self showControls:YES];
    else
        [self hideControls:YES];
    
    if(shouldNotify) [self delegate:@selector(layerViewDidSelect:)];
    
    if(self.selectBlock) self.selectBlock(self);
    [self setShowDropShadowWhenSelected:v ? self.showDropShadowWhenSelected : NO];
}
- (BOOL) showDropShadowWhenSelected;
{
    if(self.layersView)
    {
        return self.layersView.count > 1;
    }
    return _showDropShadowWhenSelected;
}
- (void) setShowDropShadowWhenSelected:(BOOL)showDropShadowWhenSelected;
{
    _showDropShadowWhenSelected = showDropShadowWhenSelected;
    if(_showDropShadowWhenSelected)
    {
        self.borderView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.borderView.layer.shadowOffset = (CGSize){1,1};
        self.borderView.layer.shadowRadius = 0.5;
        self.borderView.layer.shadowOpacity = 0.3;
    }
    else
    {
        self.borderView.layer.shadowColor = nil;
        self.borderView.layer.shadowOffset = (CGSize){0,0};
        self.borderView.layer.shadowRadius = 0;
        self.borderView.layer.shadowOpacity = 0;
    }
    
    if(_showDropShadowWhenSelected && self.showContentDropShadowWhenSelected && !self.hasChangedShadow)
    {
        self.contentView.layer.shadowColor = self.borderView.layer.shadowColor;
        self.contentView.layer.shadowOffset = self.borderView.layer.shadowOffset;
        self.contentView.layer.shadowRadius = 0;
        self.contentView.layer.shadowOpacity = 0.2;
    }
    else if(!self.hasChangedShadow)
    {
        self.contentView.layer.shadowColor = nil;
        self.contentView.layer.shadowOffset = (CGSize){0,0};
        self.contentView.layer.shadowRadius = 0;
        self.contentView.layer.shadowOpacity = 0;
    }
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event;
{
    return [super pointInside:point withEvent:event];
}

- (void) loseKeyObject;
{
    self.isKeyObject = NO;
}
- (void) setKeyObject;
{
    self.isKeyObject = YES;
}

- (void) setIsKeyObject:(BOOL)value;
{
    _isKeyObject = value;
    if(_isKeyObject)
    {
        self.layersView.keyObjectLayer = self;
    }
    else if(self.layersView.keyObjectLayer == self)
    {
        self.layersView.keyObjectLayer = nil;
    }
}
- (void) setHidden:(BOOL)hidden;
{
    [super setHidden:hidden];
}

#pragma mark - Animations

- (void) animateBorderIn:(MysticBlockAnimationFinished)completion;
{
    self.borderView.hidden = YES;
    self.deleteControl.hidden = YES;
    self.resizingControl.hidden = YES;
    CGFloat a = self.borderView.alpha;
    self.borderView.alpha = 0;
    CGFloat da = self.deleteControl.alpha;
    self.deleteControl.alpha = 0;
    CGFloat ra = self.resizingControl.alpha;
    self.resizingControl.alpha = 0;
    CGAffineTransform t = self.borderView.transform;
    CGAffineTransform rt = !self.resizingControl ? CGAffineTransformIdentity : self.resizingControl.transform;
    CGAffineTransform dt = !self.deleteControl ? CGAffineTransformIdentity : self.deleteControl.transform;

    CGSize c = CGSizeScale(CGSizeDiff(CGRectTransform(self.borderView.frame, CGAffineTransformScale(t, 1.25, 1.25)).size, self.borderView.frame.size), 0.5);
    
    self.borderView.transform = CGAffineTransformScale(t, 1.25, 1.25);
    if(self.resizingControl) self.resizingControl.transform = CGAffineTransformTranslate(rt, c.width, c.height);
    if(self.deleteControl) self.deleteControl.transform =  CGAffineTransformTranslate(dt, -c.width, -c.height);
    self.borderView.hidden = NO;
    self.deleteControl.hidden = NO;
    self.resizingControl.hidden = NO;

    
    __unsafe_unretained __block MysticLayerBaseView *weakSelf = self;
    [MysticUIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.borderView.transform = t;
        weakSelf.borderView.alpha = a;
        weakSelf.resizingControl.transform = rt;
        weakSelf.resizingControl.alpha = ra;
        weakSelf.deleteControl.transform = dt;
        weakSelf.deleteControl.alpha = da;
    } completion:completion];
}
- (void) animateBorderOut:(MysticBlockAnimationFinished)completion;
{
    CGAffineTransform t = self.borderView.transform;
    CGAffineTransform t2 = CGAffineTransformScale(t, 1.25, 1.25);
    CGSize c = CGSizeScale(CGSizeDiff(CGRectTransform(self.borderView.frame, t2).size, self.borderView.frame.size),0.5);
    
    CGAffineTransform rt2 = !self.resizingControl ? CGAffineTransformIdentity : CGAffineTransformTranslate(!self.resizingControl ? CGAffineTransformIdentity : self.resizingControl.transform, c.width, c.height);
    CGAffineTransform dt2 = !self.deleteControl ? CGAffineTransformIdentity : CGAffineTransformTranslate(!self.deleteControl ? CGAffineTransformIdentity : self.deleteControl.transform, -c.width, -c.height);
    __unsafe_unretained __block MysticLayerBaseView *weakSelf = self;
    __unsafe_unretained __block MysticBlockAnimationFinished _completion = completion ? Block_copy(completion) : nil;
    [MysticUIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.borderView.transform = t2;
        weakSelf.borderView.alpha = 0;
        weakSelf.deleteControl.transform = dt2;
        weakSelf.deleteControl.alpha = 0;
        weakSelf.resizingControl.transform = rt2;
        weakSelf.resizingControl.alpha = 0;
    } completion:^(BOOL f) {
        weakSelf.borderView.transform = t;
        weakSelf.deleteControl.transform = CGAffineTransformTranslate(dt2, c.width, c.height);
        weakSelf.resizingControl.transform = CGAffineTransformTranslate(rt2, -c.width, -c.height);
        if(_completion) { _completion(f); Block_release(_completion); }
    }];
}

#pragma mark - Raasterize

- (CGSize) rasterSize; { return self.isRasterized ? self.rasterImageView.frame.size : self.contentView.frame.size; }
- (BOOL) isRasterized; { return self.rasterImageView != nil && self.rasterImageView.superview == self; }
- (void) unRasterize;
{
    if(self.rasterImageView) [self.rasterImageView removeFromSuperview], self.rasterImageView = nil;
    self.contentView.hidden = NO;
}
- (UIImage *) rasterImage; { return [self rasterImage:0]; }
- (UIImage *) rasterImage:(CGFloat)scale;
{
    if(self.rasterImageView) return self.rasterImageView.image;
    UIGraphicsBeginImageContextWithOptions(CGSizeCeil(self.contentView.bounds.size), NO, scale == 0 ? [MysticUI scale] : scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.contentView.layer renderInContext:context];
    UIImage *rasteredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rasteredImage;
}

- (void) rasterize;
{
    [self rasterize:0];
}
- (void) rasterize:(CGFloat)scale;
{
    UIImage *rasterImage = [self rasterImage:scale];
    if(!self.rasterImageView) self.rasterImageView = [[[UIImageView alloc] initWithFrame:self.contentView.frame] autorelease];
    if(!self.rasterImageView.superview) [self addSubview:self.rasterImageView];
    self.rasterImageView.contentMode = UIViewContentModeCenter;
    self.rasterImageView.image = rasterImage;
    self.contentView.hidden = YES;
}

#pragma mark - Delegate Action

- (BOOL) delegate:(SEL)action;
{
    if(!_delegate || ![_delegate respondsToSelector:action]) return NO;
    [_delegate performSelector:action withObject:self];
    return YES;
}
- (BOOL) delegate:(SEL)action object:(id)obj;
{
    if(!self.delegate || ![self.delegate respondsToSelector:action]) return NO;
    [self.delegate performSelector:action withObject:obj];
    return YES;
}
- (BOOL) delegate:(SEL)action object:(id)obj object:(id)obj2;
{
    if(!self.delegate || ![self.delegate respondsToSelector:action]) return NO;
    [self.delegate performSelector:action withObject:obj withObject:obj2];
    return YES;
}

#pragma mark - Content & Replace Content

- (void) setNewBounds:(CGRect)bnds;
{
    [super setBounds:bnds];
    _centerPoint = self.center;
    CGFloat r = self.ratio;
    self.ratio = CGRectRatio(self.bounds);
    if(r!=self.ratio) self.deltaAngle = CGRectAtan2(bnds, self.center);
}
- (CGRect) maxBounds;
{
    return !CGRectIsZero(_maxBounds) ? _maxBounds : (self.layersView ? CGRectInset(self.layersView.bounds, 40, 40) : (self.superview ? self.superview.bounds : self.bounds));
}

- (CGFloat) contentRatio;
{
    return self.contentView.ratio;
}
- (UIEdgeInsets) remainderContentInsetsFrom:(UIEdgeInsets)ins;
{
    UIEdgeInsets i = UIEdgeInsetsCopy(ins);
    i.top = i.top - (_globalInset.top+_borderInset.top+_contentInset.top);
    i.bottom = i.bottom - (_globalInset.bottom+_borderInset.bottom+_contentInset.bottom);
    i.left = i.left - (_globalInset.left+_borderInset.left+_contentInset.left);
    i.right = i.right - (_globalInset.right+_borderInset.right+_contentInset.right);
    return i;
    
}
- (UIEdgeInsets) totalContentInsets;
{
    UIEdgeInsets i = UIEdgeInsetsZero;
    i.top = (_globalInset.top+_borderInset.top+_contentInset.top+self.addedInsets.top);
    i.bottom = (_globalInset.bottom+_borderInset.bottom+_contentInset.bottom+self.addedInsets.bottom);
    i.left = (_globalInset.left+_borderInset.left+_contentInset.left+self.addedInsets.left);
    i.right = (_globalInset.right+_borderInset.right+_contentInset.right+self.addedInsets.right);
    return i;
}
- (CGRect) contentFrameInset:(CGRect)frame;
{
    UIEdgeInsets cins = [self insetsForControl:MysticLayerControlContent];
    return CGRectXY(frame, cins.left, cins.top);
}
// this is a debug function to see what the content bounds are
- (CGRect) boundsInset:(BOOL)useOriginal;
{
    UIEdgeInsets t = UIEdgeInsetsMake(_globalInset.top+_borderInset.top,
                     _globalInset.left+_borderInset.left,
                     _globalInset.bottom+_borderInset.bottom,
                                      _globalInset.right+_borderInset.right);
    
    return UIEdgeInsetsInsetRect(self.bounds, useOriginal ? UIEdgeInsetsAdd(t, UIEdgeInsetsMake(MYSTIC_LAYER_CONTENT_INSET_TOP *_scale, MYSTIC_LAYER_CONTENT_INSET_LEFT *_scale, MYSTIC_LAYER_CONTENT_INSET_BTM *_scale, MYSTIC_LAYER_CONTENT_INSET_RIGHT *_scale)) : [self insetsForControl:MysticLayerControlContent]);
}

- (UIEdgeInsets) resetContentInsets;
{
    _addedInsets = UIEdgeInsetsZero;
    return _contentInset;
}
- (UIEdgeInsets) increaseContentInsets:(UIEdgeInsets)add;
{
    _addedInsets = add;
    self.minimumHeight = self.minHeightNoScale;
    self.minimumWidth = self.minWidthNoScale;
    return UIEdgeInsetsAdd(_contentInset, _addedInsets);
}

- (UIEdgeInsets) layerInsets; { return [[self class] contentInsetsForScale:_scale]; }
- (void) setContentFrameAndLayout:(CGRect)contentFrame;
{
    self.contentFrame = [self contentFrameInset:contentFrame];
    [self setNewBounds:[self boundsForContentFrame:self.contentFrame]];
    [self layoutControls:MysticLayerControlAllExceptContent];
}
- (void) setContentFrame:(CGRect)contentFrame;
{
    _contentFrame = contentFrame;
    [self.contentView setNewFrame:_contentFrame];
}
- (void) setContent:(id)content;
{
    [self setContent:content updateView:self];
}
- (void) setContent:(id)content updateView:(id)theView;
{
    if(![content isKindOfClass:[MysticChoice class]] && [content respondsToSelector:@selector(objectForKey:)]) content = [MysticChoice choiceWithInfo:content key:nil type:self.type];
    else if(![content isKindOfClass:[MysticChoice class]] && content) content = [MysticChoice choiceWithInfo:@{@"content":content} key:content type:self.type];
    if(content) [content retain];
    if(_content) [_content release], _content=nil;
    if(content) _content = [(MysticChoice *)content setNeedsLayout];
}
- (void) setContent:(id)content color:(UIColor *)color;
{
    self.color = color;
    self.content = content;
}


- (CGFrameBounds) contentSize:(MysticChoice *)choice adjust:(BOOL)adjust;
{
    return (CGFrameBounds){_contentFrame,self.bounds};
}

- (CGRect) boundsForContentFrame:(CGRect)contentFrame;
{
    return CGRectz(UIEdgeInsetsInsetRect(contentFrame, UIEdgeInsetsInverse(self.totalContentInsets)));
}
- (CGRect) frameForControl:(MysticLayerControl)controlType;
{
    return [self frameForControl:controlType bounds:self.bounds];
}
- (CGRect) frameForControl:(MysticLayerControl)controlType bounds:(CGRect)boundRect;
{
    switch (controlType)
    {
        case MysticLayerControlResize:    return CGRectMake(-_controlInset.left + CGRectGetMinX(_borderView.frame) + CGRectGetMinX(_borderView.innerRect) + CGRectW(_borderView.innerRect) -1 - (_controlSize.width/2),
                              -_controlInset.top + CGRectGetMinY(_borderView.frame) + CGRectGetMinY(_borderView.innerRect) + CGRectH(_borderView.innerRect) -1 - (_controlSize.height/2),
                              _controlSize.width, _controlSize.height);
        case MysticLayerControlDelete:    return CGRectMake(_controlInset.left + CGRectGetMinX(_borderView.frame) + CGRectGetMinX(_borderView.innerRect) - (_controlSize.width/2),
                              _controlInset.top + CGRectGetMinY(_borderView.frame) + CGRectGetMinY(_borderView.innerRect) + 1 - (_controlSize.height/2),
                              _controlSize.width, _controlSize.height);

        case MysticLayerControlCustom:    return CGRectMake(_controlInset.left + CGRectGetMinX(_borderView.frame) + CGRectGetMinX(_borderView.innerRect) + CGRectW(_borderView.innerRect) -1 - (_controlSize.width/2),
                              _controlInset.top + CGRectGetMinY(_borderView.frame) + CGRectGetMinY(_borderView.innerRect) + 1 - (_controlSize.height/2),
                              _controlSize.width, _controlSize.height);
        case MysticLayerControlBorder:    return CGRectIntegral(CGRectInsetBy(UIEdgeInsetsInsetRect(boundRect,_borderInset), self.borderWidth));
        case MysticLayerControlContent:   return UIEdgeInsetsInsetRect(boundRect, self.totalContentInsets);
            
        default: break;
    }
    return CGRectZero;
}
- (UIEdgeInsets) insetsForControl:(MysticLayerControl)controlType;
{
    switch (controlType)
    {
        case MysticLayerControlResize:
        case MysticLayerControlDelete:
        case MysticLayerControlCustom: return _controlInset;
        case MysticLayerControlBorder: return UIEdgeInsetsAdd(_borderInset, UIEdgeInsetsMakeFrom(self.borderWidth));
        case MysticLayerControlContent: return self.totalContentInsets;
            
        default: break;
    }
    return UIEdgeInsetsZero;
}


- (void) setCenter:(CGPoint)center
{
    _centerPoint = center;
    super.center = center;
}
- (void) setRatio:(CGFloat)ratio;
{
//    DLogHidden(@"     setting ratio: %2.2f", ratio);
    _ratio = ratio;
}
- (CGRect) adjustedBounds:(CGRect)newBounds;
{
    if(self.adjustsAspectRatioOnResize) return newBounds;
    if(newBounds.size.width > newBounds.size.height)
    {
        newBounds.size.height = newBounds.size.width *_ratio;
        if(newBounds.size.height < _minimumHeight)
        {
            newBounds.size.height = _minimumHeight;
            newBounds.size.width = newBounds.size.height/_ratio;
        }
    }
    else
    {
        newBounds.size.width = newBounds.size.height *_ratio;
        if(newBounds.size.width < _minimumWidth)
        {
            newBounds.size.width = _minimumWidth;
            newBounds.size.height = newBounds.size.width/_ratio;
        }
    }
    return newBounds;
}
- (void) relayoutSubviews;
{
    CGPoint c = self.center;
    CGRect dr = CGRectSize(self.drawContext.totalSize);
    if(self.shouldRelayout &&  !CGRectIsInfinite(dr))
    {
        self.bounds = CGRectSize([self boundsForContentFrame:CGRectSize(dr.size)].size);
        self.center = c;
        [self layoutControls];
        
    }
    
    self.shouldRelayout = NO;
}
- (void) layoutControls;
{
    [self layoutControls:MysticLayerControlAll animated:NO];
}
- (void) layoutControls:(MysticLayerControl)controlTypes;
{
    [self layoutControls:controlTypes animated:NO];
    
}
- (void) layoutControls:(MysticLayerControl)controlTypes animated:(BOOL)animated;
{
    BOOL all = controlTypes & MysticLayerControlAll || controlTypes & MysticLayerControlAllExceptContent;
    BOOL allExcept = controlTypes & MysticLayerControlAllExceptContent;
    if((all || controlTypes & MysticLayerControlBorder) && _usesBorderControl && _borderView ) { _borderView.frame = [self frameForControl:MysticLayerControlBorder]; }
    if(_resizingControl && (all || controlTypes & MysticLayerControlResize)) _resizingControl.frame = [self frameForControl:MysticLayerControlResize];
    if(_deleteControl && (all || controlTypes & MysticLayerControlDelete)) _deleteControl.frame = [self frameForControl:MysticLayerControlDelete];
    if(_customControl && (all || controlTypes & MysticLayerControlCustom)) _customControl.frame = [self frameForControl:MysticLayerControlCustom];
    if(((all && !allExcept) || controlTypes & MysticLayerControlContent))
    {
        _contentFrame = [self frameForControl:MysticLayerControlContent];
        self.contentView.frame = _contentFrame;
//        [self setContentFrame:_contentFrame];
    }
    if(_borderView && (all || controlTypes & MysticLayerControlContent)) [_borderView setNeedsDisplay];
    [self setNeedsDisplay];
    
}
#pragma mark - Replace Content

- (BOOL) replaceContent:(id)content adjust:(BOOL)adjust scale:(CGSize)scale;
{
    BOOL isChoice = self.choice != nil;
    BOOL isSame = self.choice && [self.choice isSame:content];
    UIView *contentView = self.choice.contentView;
    self.content = content;
    [self redraw:NO];
    [self.choice setNeedsLayout];
    [self resetContentInsets];
    self.choice.refitFrame = YES;
    self.choice.rebuildFrame = YES;
    if(isChoice && !isSame) self.choice.originalContentFrame = CGRectUnknown;
    return isChoice ? !isSame : NO;
}

#pragma mark - Prepare for Render

- (void) prepareForImageCapture:(CGSize)renderSize scale:(CGScale)scale finished:(MysticBlock)finished;
{
    UIView *contentView = self.transView ? self.transView : self.contentView;
    if(self.choice.hasShadow)
    {
        
//        DLogDebug(@"prepare scale:layer: %p   %@  scale: %2.2f     radius:  %2.2f ->  %2.2f  \n\n%@", self, s(renderSize), scale.scale, self.contentView.layer.shadowRadius, self.contentView.layer.shadowRadius *scale.scale, self.choice);
        contentView.layer.shadowOffset = CGSizeScaleWithScale(self.choice.shadowOffset, scale);
        contentView.layer.shadowRadius = self.choice.shadowRadius * scale.scale;

    }
    if(self.choice.hasCornerRadius) contentView.layer.cornerRadius *= scale.scale;
    if([self.choice setScale:scale scaleProperties:YES]) [self setNeedsDisplay];

}
- (void) finishedImageCapture:(CGSize)renderSize scale:(CGScale)scale;
{

    scale = CGScaleInverse(scale);
    if(self.choice.hasShadow)
    {
        
        self.contentView.layer.shadowOffset = CGSizeScaleWithScale(self.contentView.layer.shadowOffset, scale);
        self.contentView.layer.shadowRadius *=scale.scale;
    }
    if(self.choice.hasCornerRadius) self.contentView.layer.cornerRadius *=scale.scale;
    if([self.choice setScale:scale scaleProperties:YES]) [self setNeedsDisplay];
}
- (id) deepCopyOf:(MysticLayerBaseView *)view;
{
    
    
    
    
    return self;
}

#pragma mark - Responder

- (BOOL) becomeFirstResponder;      {    return NO; }
- (BOOL) canBecomeFirstResponder;   {    return NO; }


#pragma mark - Description

- (NSString *) debugDescription;
{
    return ALLogStrf([NSString stringWithFormat:@"%@ #%d", NSStringFromClass(self.class), (int)self.index],
                            @[@"frame", FLogStr(self.frame),
                              @"content.frame", FLogStr(self.contentView.bounds),
                              @"content.bounds", FLogStr(self.contentView.bounds),
                              @"contentScale", @(self.contentView.scale),
                              @"contentTransformScale", sc(self.contentView.transformScale),
                              @"rotation", @(self.rotation),
                              LINE,
                              @"renderRect", self.drawView ? FLogStr(self.drawView.renderRect) : @"---",
                              ]);
}

- (NSString *) description; { return [NSString stringWithFormat:@" <%@ %p> #%d: ", [self class], self, self.index]; }

@end
