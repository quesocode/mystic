//
//  MysticPhotoContainerView.m
//  Mystic
//
//  Created by travis weerts on 3/6/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticPhotoContainerView.h"
#import "MysticGPUImageView.h"
#import "PackPotionOption.h"
#import "UIImage+Aspect.h"
#import "MysticImageView.h"
#import "UIImage+FloodFill.h"
#import "MysticDotView.h"
#import "UserPotion.h"

@implementation MysticPhotoScrollViewZoomView

@end

@interface MysticPhotoScrollView ()
@property (nonatomic, assign) CGSize fullImageSize;
@property (nonatomic, assign) BOOL ignoreZoom, hasRotated;
@property (nonatomic, assign) float rotation;
@end
@implementation MysticPhotoScrollView
@synthesize tapAction=_tapAction;
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(!self) return nil;
    [self setup];
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(!self) return nil;
    [self setup];
    return self;
}
- (void) setup;
{
    _ignoreZoom = NO;
    _hasRotated = NO;
    _rotation = 0;
    self.minimumZoomScale = 0.75;
    self.maximumZoomScale = 6.0;
    self.zoomScale = 1.0;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.bounces = YES;
    self.alwaysBounceVertical=YES;
    self.alwaysBounceHorizontal=YES;
    self.userInteractionEnabled=YES;
    self.multipleTouchEnabled=YES;
    self.delegate = self;
    self.clipsToBounds = NO;
    self.scrollEnabled = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    _centeredFrame = CGRectZero;
    _insets = UIEdgeInsetsZero;
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)] autorelease];
    tap.numberOfTapsRequired = 2;
    UILongPressGestureRecognizer *longpress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)] autorelease];
    UIRotationGestureRecognizer  *rotation = [[[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotate:)] autorelease];
    [self addGestureRecognizer:rotation];
    [self addGestureRecognizer:longpress];
    [self addGestureRecognizer:tap];
    self.doubleTapGesture = tap;
    self.panGestureRecognizer.minimumNumberOfTouches = 2;

}
- (void) setTapAction:(SEL)tapAction;
{
    if(!tapAction)
    {
        _tapAction = nil;
        if(self.singleTapGesture) [self removeGestureRecognizer:self.singleTapGesture];
        self.singleTapGesture = nil;
        return;
    }
    _tapAction = tapAction;
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)] autorelease];
    tap.numberOfTapsRequired = 1;
    if(self.doubleTapGesture) [tap requireGestureRecognizerToFail:self.doubleTapGesture];
    [self addGestureRecognizer:tap];
    self.singleTapGesture = tap;
    
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{

    CGAffineTransform t = CGAffineTransformMakeScale(recognizer.scale, recognizer.scale);
    self.zoomingView.transform = CGAffineTransformRotate(t, self.rotation);
    [self showZoomMessage];
}

- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    
    self.transform = snapRotation45and90(CGAffineTransformRotate(self.transform, recognizer.rotation));
    _hasRotated = !CGAffineTransformIsIdentity(self.transform);
    self.rotation = recognizer.rotation;
    recognizer.rotation = 0;
    
}
- (void)tapped:(UITapGestureRecognizer *)gesture {
    
    if(!self.tapAction) return;
    if(self.gestureDelegate && [self.gestureDelegate respondsToSelector:self.tapAction])
        [self.gestureDelegate performSelector:self.tapAction withObject:gesture];
}
- (void)longGesture:(UILongPressGestureRecognizer *)gesture {
    
    if(self.gestureDelegate && [self.gestureDelegate respondsToSelector:self.longpressAction])
        [self.gestureDelegate performSelector:self.longpressAction withObject:gesture];
}
- (void)doubleTapped:(UITapGestureRecognizer *)tapGesture {
    UIView *t = self;
    _ignoreZoom = YES;
    [MysticUIView animate:0.3 animations:^{
        if((self.zoomScale == 1) && rotationDegrees(t.transform) == 0.0)
        {
            CGRect zoomRect = CGRectMake(0, 0, self.zoomingView.bounds.size.width/self.maximumZoomScale/1.5, self.zoomingView.bounds.size.height/self.maximumZoomScale/1.5);
            CGPoint loc = [tapGesture locationInView:self.zoomingView];
            zoomRect.origin.x = loc.x - zoomRect.size.width/2;
            zoomRect.origin.y = loc.y - zoomRect.size.height/2;
            [self zoomToRect:zoomRect animated:NO];
        }
        else [self setZoomScale:1 animated:NO];
        t.transform = CGAffineTransformIdentity;

        [self centerContent];
    } completion:^(BOOL finished) {
        _ignoreZoom = NO;
  
    }];
}
- (void)centerContent {
    CGFloat top = 0, left = 0;
    self.zoomingView.frame = CGRectz(self.zoomingView.frame);
    if (self.contentSize.width < self.bounds.size.width) left = (self.bounds.size.width-self.contentSize.width) * 0.5f;
    if (self.contentSize.height < self.bounds.size.height) top = (self.bounds.size.height-self.contentSize.height) * 0.5f;
    self.contentInset = UIEdgeInsetsMake(top, left, top, left);
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
//    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) return NO;
    return YES;
}
- (CGRect) imageViewFrame;
{
    CGRect r = self.zoomingView.frame;
    r = CGRectScale(r, self.zoomScale);
    r.origin.y = self.contentInset.top + self.frame.origin.y;
    r.origin.x = self.contentInset.left+ self.frame.origin.x;
    
    return r;
}

- (void) resetPosition:(BOOL)animated;
{
    UIView *t = self;
    if(self.zoomScale == 1 && CGAffineTransformIsIdentity(self.transform)) return;
    if(animated)
    {
        [MysticUIView animate:0.3 animations:^{
            [self setZoomScale:1 animated:NO];
            t.transform = CGAffineTransformIdentity;
        }];
        return;
    }
    [self setZoomScale:1 animated:YES];
    t.transform = CGAffineTransformIdentity;

}
- (void) addView:(UIView *)view;
{
    
    if(!self.zoomingView)
    {
        MysticPhotoScrollViewZoomView *zoomingView = [[[MysticPhotoScrollViewZoomView alloc] initWithFrame:view.bounds] autorelease];
        self.zoomingView = zoomingView;
        [self addSubview:self.zoomingView];
    }
    CGPoint newCenter = (CGPoint){self.zoomingView.bounds.size.width/2, self.zoomingView.bounds.size.height/2};
    if(self.zoomingView.subviews.count > 0)
    {
        newCenter = [self.zoomingView.subviews.firstObject center];
    }

    view.center = newCenter;
    [self.zoomingView addSubview:view];
    CGPoint zoomCenter = self.zoomingView.center;
    self.zoomingView.bounds = CGRectz(view.frame);
    self.zoomingView.center = zoomCenter;

    _centeredFrame = self.zoomingView.bounds;
    self.contentSize = self.zoomingView.bounds.size;
    [self centerContent];
    
    

}
- (void) updateZoomViewFrame:(UIView *)view;
{
    CGPoint zoomCenter = self.zoomingView.center;
    self.zoomingView.bounds = CGRectz(view.frame);
    self.zoomingView.center = zoomCenter;
    
    _centeredFrame = self.zoomingView.bounds;
    self.contentSize = self.zoomingView.bounds.size;
    [self centerContent];
}
- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
//    if(!self.zoomingView) self.zoomingView = subview;
    CGPoint zoomCenter = self.zoomingView.center;
    self.zoomingView.bounds = CGRectz(subview.frame);
    self.zoomingView.center = zoomCenter;
    _centeredFrame = self.zoomingView.bounds;
    self.contentSize = self.zoomingView.bounds.size;
    
    [self centerContent];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView;
{

    if(!_ignoreZoom) [self centerContent];
    if([self.scrollViewDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) [self.scrollViewDelegate scrollViewDidZoom:self];

    
    
}
- (void) showZoomMessage;
{

    
    float yPosition = runningOnPhone() ? 20 : 30;
    [self showMessage:[NSString stringWithFormat:@"%d%%", (int)((self.zoomScale/self.maximumZoomScale)*100)]
             autoHide:YES
             position:CGPointMake(CGRectGetMidX(self.superview.bounds), yPosition)
             duration:kMysticMessageFadeDelay];
}

- (void) nixMessageLabel
{
    if (self.messageTimer) {
        [self.messageTimer invalidate];
        self.messageTimer = nil;
    }
    
    if (_messageLabel) {
        [_messageLabel removeFromSuperview];
        _messageLabel = nil;
    }
}
- (void) hideMessage:(NSTimer *)timer
{
    [UIView animateWithDuration:0.2f
                     animations:^{ _messageLabel.alpha = 0.0f; }
                     completion:^(BOOL finished) {
                         [self nixMessageLabel];
                     }];
    
}
- (void) showMessage:(NSString *)message
{
    [self showMessage:message autoHide:YES position:MCenterOfRect(self.superview.bounds) duration:kMysticMessageFadeDelay];
}

- (void) showMessage:(NSString *)message autoHide:(BOOL)autoHide position:(CGPoint)position duration:(float)duration
{
    if(self.preventMessages) return;
    BOOL created = NO;
    
    
    if (!_messageLabel) {
        _messageLabel = [[MysticMessage alloc] initWithFrame:CGRectInset(CGRectMake(0,0,100,40), -8, -8)];
        _messageLabel.label.textColor = [UIColor whiteColor];
        _messageLabel.label.font = [UIFont boldSystemFontOfSize:24.0f];
        _messageLabel.label.textAlignment = UITextAlignmentCenter;
        _messageLabel.opaque = NO;
        _messageLabel.backgroundColor = nil;
        _messageLabel.alpha = 0;
        created = YES;
    }
    
    if ([message length] > 20 && runningOnPhone()) {
        _messageLabel.label.font = [UIFont boldSystemFontOfSize:15.0f];
    } else {
        _messageLabel.label.font = [UIFont boldSystemFontOfSize:24.0f];
    }
    
    _messageLabel.text = message;
    [_messageLabel sizeToFit];
    
    CGRect frame = _messageLabel.frame;
    frame.size.width = MAX(frame.size.width, kMysticMinimumMessageWidth);
    frame = CGRectInset(frame, -12, -8);
    _messageLabel.frame = frame;
    _messageLabel.sharpCenter = position;
    if (created) {
        [self.superview addSubview:_messageLabel];
        [UIView animateWithDuration:0.2f animations:^{ _messageLabel.alpha = 1; }];
    }
    
    // start message dismissal timer
    if (self.messageTimer) {
        [self.messageTimer invalidate];
        self.messageTimer = nil;
    }
    
    if (autoHide) self.messageTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(hideMessage:) userInfo:nil repeats:NO];
    
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if(!_ignoreZoom) [self centerContent];
}
- (void) setZoomingView:(MysticPhotoScrollViewZoomView *)zoomingView;
{
    _zoomingView = zoomingView;
    _centeredFrame = zoomingView.bounds;
    self.contentSize = _zoomingView.bounds.size;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.subviews.firstObject;
}

@end

@implementation MysticPhotoView

- (void) setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    if(self.scrollView) [self.scrollView updateZoomViewFrame:self];
}
@end

@implementation MysticPhotoOverlaysView
@end

@interface MysticPhotoContainerView ()
{
    CGFloat lipOffset;
    CGSize _imageSize;
    BOOL setLastImage, setImageViewFrame;
}
//@property (nonatomic, retain) UIImageView *lipView;

@property (nonatomic, assign) MysticDotView *centerDot, *imageViewCenterDot;

@end


@implementation MysticPhotoContainerView


static UIEdgeInsets defaultImageViewInsets, currentImageViewInsets;


@synthesize imageView=_imageView,  size=_size,   imageViewFrame, overlays, delegate=_delegate;

- (void) dealloc;
{
    [_previewOrRenderView release];
    [_imageViewGPU release];
    [_imageViewPlaceholder release];
    [_imageView release];
    [super dealloc];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) [self setup];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self setup];
    return self;
}

- (void) setup
{
    _originalImageViewFrame = CGRectZero;
    setImageViewFrame = NO;
    setLastImage = NO;
    lipOffset = 2.0f;
    _offset = CGPointZero;
    _transformSize = CGSizeMake(1, 1);
    self.scrollView = [[[MysticPhotoScrollView alloc] initWithFrame:self.bounds] autorelease];
    self.scrollView.scrollViewDelegate = self;
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    CGFloat bw = 2;
    self.previewOrRenderView = [[[MysticRoundView alloc] initWithFrame:CGRectMake(10, 10, 6+bw*2, 6+bw*2)] autorelease];
    self.previewOrRenderView.borderColor = [[UIColor hex:@"141412"] alpha:1];
    self.previewOrRenderView.borderWidth = bw;
    self.debugColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.previewOrRenderView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.previewOrRenderView.hidden = ![MysticUser is:Mk_DEBUG];
    defaultImageViewInsets = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? UIEdgeInsetsMake(MYSTIC_UI_IMAGEVIEW_INSET_TOP, MYSTIC_UI_IMAGEVIEW_INSET_LEFT, MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM, MYSTIC_UI_IMAGEVIEW_INSET_RIGHT) : UIEdgeInsetsMake(10, 10, 18, 10);
    [MysticPhotoContainerView setInsets:defaultImageViewInsets];
    self.imageView = [[[MysticPhotoView alloc] initWithFrame:self.bounds] autorelease];
    self.imageView.userInteractionEnabled = NO;
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.autoresizesSubviews=YES;
    self.imageView.scrollView = self.scrollView;
    [self addSubview:self.previewOrRenderView];
    self.delegate = self;
    [self.scrollView addView:self.imageView];
    [self addSubview:self.scrollView];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

}

- (BOOL) hasSetSize; { return setImageViewFrame; }
- (CGSize) size; { return _imageSize; }
- (void) setSize:(CGSize)size; { [self setSize:size force:NO]; }
- (void) setSize:(CGSize)size force:(BOOL)force
{
    if(!setImageViewFrame || force)
    {
        setImageViewFrame = NO;
        _originalImageViewFrame = CGRectInt([MysticUI rectWithSize:size]);
        _imageSize = _originalImageViewFrame.size;
        self.imageViewFrame = _originalImageViewFrame;
        self.imageView.transform = CGAffineTransformIdentity;
        [self setNeedsDisplay];
    }
    else self.imageViewFrame = CGRectS(self.imageViewFrame, size);
    [self centerImageView];
    setImageViewFrame = YES;
}


- (void) resetFrame; { setImageViewFrame = NO; }
- (void) setImageViewFrame:(CGRect)value;
{
    [self setImageViewFrame:value normalize:YES];
}
- (void) setImageViewFrame:(CGRect)value normalize:(BOOL)normalize;
{
    _imageFrame = value;
    if(!setImageViewFrame)
    {
        self.imageView.transform = CGAffineTransformIdentity;
        self.imageView.frame = value;
    }
    else
    {
        CGRect nf = normalize ? [MysticUI normalRect:value bounds:_originalImageViewFrame] : CGRectMake(0,0,1,1);
        CGAffineTransform trans = CGAffineTransformIdentity;
        self.transformSize = CGSizeMinWH(nf.size) < 1 ? nf.size : CGSizeOne;
        self.imageView.transform = CGTransformSize(self.transformSize);
        CGRect insetRect = InsetRect(self.bounds, [MysticPhotoContainerView insets]);
        self.imageView.center =  CGPointAddXY(CGPointCenter(insetRect),self.offset.x+insetRect.origin.x,self.offset.y+insetRect.origin.y);
    }
    if([self.delegate respondsToSelector:@selector(photoViewContainer:didChangeFrame:original:)]) [self.delegate photoViewContainer:self didChangeFrame:value original:_originalImageViewFrame];
    [self configureForImageSize:CGSizeUnknown];
//    ALLog(@"photo container", @[@"view", VLLogStr(self)]);

}
- (CGAffineTransform) imageTransform; { return self.imageView.transform; }
//- (void) setHidden:(BOOL)hidden; { [super setHidden:hidden]; }
- (CGRect) imageViewFrame; { return self.imageView.frame; }
- (BOOL) renderIsHidden; {   return self.imageViewPlaceholder.superview != nil; }
- (BOOL) previewIsHidden; { return self.imageViewPlaceholder.superview == nil; }
- (BOOL) revealRenderImageView;
{
    return [self revealRenderImageView:0];
}
- (BOOL) revealRenderImageView:(NSTimeInterval)duration;
{
    if(duration > 0)
    {
        [self renderImageView];
        if(self.imageViewPlaceholder && self.imageViewPlaceholder.superview)
        {
            [MysticUIView animate:duration animations:^{
                self.imageViewPlaceholder.alpha=0;
                if(self.imageViewGPU) self.debugColor = [UIColor greenColor];
            } completion:^(BOOL finished) {
                self.imageViewPlaceholder.image = nil;
                [self.imageViewPlaceholder removeFromSuperview];
            }];
        }
        return self.imageViewGPU != nil;
    }
    if(self.imageViewPlaceholder && self.imageViewPlaceholder.superview)
    {
        self.imageViewPlaceholder.image = nil;
        [self.imageViewPlaceholder removeFromSuperview];
    }
    if(self.imageViewGPU) self.debugColor = [UIColor greenColor];
    return self.imageViewGPU != nil;
}
- (MysticGPUImageView *) renderImageView;
{
    if(!self.imageViewGPU) self.imageViewGPU = [[[MysticGPUImageView alloc] initWithFrame:self.imageView.bounds] autorelease];
    if(!self.imageViewGPU.superview) [self.imageView insertSubview:self.imageViewGPU atIndex:0];
    return self.imageViewGPU;
}
- (MysticGPUImageView *) showGPUImageView;
{
    [self renderImageView];
    if(self.imageViewPlaceholder && self.imageViewPlaceholder.superview) [self.imageViewPlaceholder removeFromSuperview];
    return self.imageViewGPU;
}
- (BOOL) revealPlaceholder;
{
    if(self.imageViewPlaceholder)
    {
        if(!self.imageViewPlaceholder.superview) [self.imageView addSubview:self.imageViewPlaceholder];
        
        else [self.imageView bringSubviewToFront:self.imageViewPlaceholder];
    }
    for (UIView *v in self.imageView.subviews) {
        if([v isKindOfClass:[MysticGPUImageView class]] || [v isKindOfClass:[MysticImageView class]]) continue;
        [self.imageView bringSubviewToFront:v];
    }
    self.imageViewPlaceholder.clipsToBounds=NO;
    [self destroyRenderImageView];
    return self.imageViewPlaceholder != nil;
}
- (MysticImageView *) showPlaceholder:(UIImage *)image;
{
    return [self showPlaceholder:image duration:0];
}
- (MysticImageView *) showPlaceholder:(UIImage *)image duration:(NSTimeInterval)duration;
{
    if(!self.imageViewPlaceholder) self.imageViewPlaceholder = [[[MysticImageView alloc] initWithFrame:self.imageView.bounds] autorelease];
    if(duration > 0) self.imageViewPlaceholder.alpha=0;
    if(!self.imageViewPlaceholder.superview) {
        if(self.imageViewGPU) [self.imageView insertSubview:self.imageViewPlaceholder aboveSubview:self.imageViewGPU];
        else [self.imageView insertSubview:self.imageViewPlaceholder atIndex:0];
    }
    if(self.imageViewGPU) { self.imageViewPlaceholder.frame = self.imageViewGPU.frame; }
    [self.imageView setNeedsDisplay];
    self.imageViewPlaceholder.clipsToBounds=NO;
    if(duration < 0) [self setImage:image duration:0];
    else if(duration == 0) self.image = image;
    else [self setImage:image duration:duration];
    
    if(duration > 0)
    {
        [MysticUIView animate:duration animations:^{
            self.debugColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.19 alpha:1];
            self.imageViewPlaceholder.alpha=1;
        } completion:^(BOOL finished) {
            MysticWait(0.2, ^{ [self destroyRenderImageView]; });
        }];
        return self.imageViewPlaceholder;
    }
    self.debugColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.19 alpha:1];
    MysticWait(0.2, ^{ [self destroyRenderImageView]; });
    return self.imageViewPlaceholder;
}
- (void) setDebugColor:(UIColor *)color;
{
    if(!color)
    {
        if(self.imageViewPlaceholder && self.imageViewPlaceholder.superview && self.imageViewPlaceholder.image) color = [UIColor colorWithRed:0.2 green:0.2 blue:0.19 alpha:1];
        else if(self.imageViewPlaceholder && self.imageViewPlaceholder.superview && !self.imageViewPlaceholder.image) color = [UIColor redColor];
        else if(self.imageViewGPU && self.imageViewGPU.superview) color = [UIColor colorWithRed:0.2 green:0.2 blue:0.19 alpha:1];
        else color = [UIColor yellowColor];
    }
    if(color == self.previewOrRenderView.backgroundColor) return;
    self.previewOrRenderView.backgroundColor = color;
    [self setNeedsLayout];

}
- (void) addView:(UIView *)view;
{
    [self.scrollView addView:view];
}
- (UIColor *) debugColor; { return self.previewOrRenderView.backgroundColor; }
- (void) hideImageViews;
{
    [self destroyPlaceholderImageView];
    [self destroyRenderImageView];
}
- (void) destroyRenderImageView;
{
    if(!self.imageViewGPU) return;
    if(self.imageViewGPU.superview) [self.imageViewGPU removeFromSuperview];
    self.imageViewGPU = nil;
}
- (void) destroyPlaceholderImageView;
{
    if(!self.imageViewPlaceholder.superview) return;
    self.imageViewPlaceholder.image = nil;
    [self.imageViewPlaceholder removeFromSuperview];
}
- (UIImage *) image; { return self.imageViewPlaceholder ? self.imageViewPlaceholder.image : nil; }
- (void) setImage:(UIImage *)image; { if(self.imageViewPlaceholder) [self.imageViewPlaceholder fadeToImage:image duration:1]; }
- (void) setImage:(UIImage *)image duration:(NSTimeInterval)dur; { if(self.imageViewPlaceholder) [self.imageViewPlaceholder fadeToImage:image duration:dur]; }

- (void) quickLookAtImage:(UIImage *)image duration:(NSTimeInterval)duration;
{
    if(!self.quickView)
    {
        self.quickView = [[[MysticImageView alloc] initWithFrame:self.imageView.bounds] autorelease];
        self.quickView.clipsToBounds=NO;
        self.quickView.image = image;
    }
    
    if((duration > 0 || duration == -1) && self.quickView.alpha > 0) self.quickView.alpha=0;
    if(!self.quickView.superview) {
        if(self.imageViewGPU || self.imageViewPlaceholder)
        {
            [self.imageView insertSubview:self.quickView aboveSubview:self.imageViewGPU && self.imageViewGPU.superview ? self.imageViewGPU : self.imageViewPlaceholder];
        }
        else
        {
            [self.imageView addSubview:self.quickView];
        }
    }

    if(duration == -1)
    {
        self.debugColor = [UIColor cyanColor];
        return;
    }
    if(duration > 0)
    {
        [MysticUIView animate:duration animations:^{
            self.debugColor = [UIColor cyanColor];
            self.quickView.alpha=1;
        } completion:^(BOOL finished) {
            
        }];
        return;
    }
    self.debugColor = [UIColor cyanColor];

}
- (void) hideQuickLook:(NSTimeInterval)duration;
{
    if(!self.quickView) return;
    if(!self.quickView.superview)
    {
        self.quickView = nil;
        self.debugColor = nil;
        return;
    }
    if(self.quickView.hidden || self.quickView.alpha == 0)
    {
        [self.quickView removeFromSuperview];
        self.quickView = nil;
        self.debugColor = nil;
        return;
    }
    
    if(duration > 0)
    {
        [MysticUIView animate:duration animations:^{
            self.debugColor = nil;
            self.quickView.alpha=0;
        } completion:^(BOOL finished) {
            [self.quickView removeFromSuperview];
            self.quickView=nil;
        }];
        return;
    }

    [self.quickView removeFromSuperview];
    self.quickView=nil;
    self.debugColor = nil;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView; { return self.imageView; }
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView
//{
//    UIView *subView = self.imageView;
////    
////    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
////    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
//////    DLog(@"zoom scale: %2.2f", scrollView.zoomScale);
////    offsetY -= (currentImageViewInsets.bottom/2)*(scrollView.zoomScale < 1.0 ? scrollView.zoomScale : 1.0);
////    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
////                                 scrollView.contentSize.height * 0.5 + offsetY);
//    CGPoint p = self.imageView.center;
//    p = [self convertPoint:p fromView:self.scrollView];
//    self.imageViewCenterDot.center = p;
//    self.centerDot.center = CGPointAddY(self.scrollView.center, -currentImageViewInsets.bottom/2);
//
//}
- (void)configureForImageSize:(CGSize)imageSize
{
//    _imageSize = imageSize;
//    self.scrollView.contentSize = imageSize;
//    [self.scrollView setContentSize:self.imageView.bounds.size];
    
//    [self.scrollView setContentSize:self.imageView.bounds.size];
}


- (void) setOffset:(CGPoint)offset; { _offset = offset; }
- (CGRect) centerImageView; { return [self centerImageView:currentImageViewInsets]; }
- (CGRect) reCenterImageView; { return [self centerImageView:defaultImageViewInsets]; }
- (CGRect) centerImageViewFrame:(UIEdgeInsets)insets;
{
    return CGRectInt(CGRectFit(self.imageView.bounds, CGRectz(InsetRect(self.bounds,insets))));
}
- (CGRect) centerImageView:(UIEdgeInsets)insets;
{
    self.centeredInsets = insets;
    [self setImageViewFrame:[self centerImageViewFrame:insets] normalize:NO];
    
    CGRect sf = self.bounds;
    sf.size.height -= insets.top + insets.bottom;
    sf.origin.y = insets.top;
    self.scrollView.ignoreZoom = YES;
    self.scrollView.frame = sf;
    self.scrollView.ignoreZoom = NO;

    self.imageView.center = CGPointMid(self.scrollView.bounds);
    return self.imageFrame;
}
- (void) setCenteredInsets:(UIEdgeInsets)centeredInsets;
{
    _centeredInsets = centeredInsets;
    self.scrollView.insets = _centeredInsets;
    [MysticPhotoContainerView setInsets:_centeredInsets];
}
- (CGRect) offsetImageView:(CGPoint)offset;
{
    CGPoint c = CGPointAdd(self.imageView.center, offset);
    CGRect ifrm = _imageFrame;
    ifrm.origin = CGPointAdd(ifrm.origin, offset);
    self.imageView.center = c;
    self.lastOffset = offset;
    return CGRectMove(_imageFrame, offset);
}
- (CGRect) removeOffset;
{
    if(CGPointIsZero(self.lastOffset)) return _imageFrame;
    CGPoint offset = CGPointInverse(self.lastOffset);
    self.lastOffset = CGPointZero;
    return [self offsetImageView:offset];
}


+ (UIEdgeInsets) insets; { return currentImageViewInsets; }
+ (void) setInsets:(UIEdgeInsets)insets; { currentImageViewInsets=insets; }
+ (UIEdgeInsets) defaultInsets; { return defaultImageViewInsets; }
+ (UIEdgeInsets) resetInsets;
{
    currentImageViewInsets = defaultImageViewInsets;
    return defaultImageViewInsets;
}

- (MysticFloodFillImageView *) showFloodView:(UIImage *)image duration:(NSTimeInterval)duration;
{
    if(!self.floodView)
    {
        self.floodView = [[[MysticFloodFillImageView alloc] initWithFrame:self.imageView.bounds] autorelease];
        
    }
    
    if(duration > 0) self.floodView.alpha=0;
    if(!self.floodView.superview) {
        //        [self.imageView addSubview:self.imageViewPlaceholder];
        if(self.imageViewGPU || self.imageViewPlaceholder)
        {
            [self.imageView insertSubview:self.floodView aboveSubview:self.imageViewGPU && self.imageViewGPU.superview ? self.imageViewGPU : self.imageViewPlaceholder];
        }
        else
        {
            [self.imageView addSubview:self.floodView];
        }
    }
    self.floodView.clipsToBounds=NO;
    self.floodView.image = image;
    MBord(self.floodView);
    if(duration > 0)
    {
        [MysticUIView animate:duration animations:^{
            self.debugColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.19 alpha:1];
            self.floodView.alpha=1;
        } completion:^(BOOL finished) {
            if(self.imageViewGPU) { [self destroyRenderImageView]; self.floodView.tag = 11117438; }
            else if(self.imageViewPlaceholder) { [self destroyPlaceholderImageView]; self.floodView.tag = 11117439; }
        }];
        return self.floodView;
    }
    self.debugColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.19 alpha:1];
    if(self.imageViewGPU) { [self destroyRenderImageView]; self.floodView.tag = 11117438; }
    else if(self.imageViewPlaceholder) { [self destroyPlaceholderImageView]; self.floodView.tag = 11117439; }
    return self.floodView;
}
- (void) hideFloodView:(NSTimeInterval)duration;
{
    if(!self.floodView) return;
    if(!self.floodView.superview)
    {
        self.floodView = nil;
        self.debugColor = nil;
        return;
    }
    if(self.floodView.hidden || self.floodView.alpha == 0)
    {
        [self.floodView removeFromSuperview];
        self.floodView = nil;
        self.debugColor = nil;
        return;
    }
    
    if(duration > 0)
    {
        if(self.floodView.tag == 11117439) { [self revealPlaceholder]; }
        else { [self revealRenderImageView]; }
            
        [MysticUIView animate:duration animations:^{
            self.debugColor = nil;
            self.floodView.alpha=0;
        } completion:^(BOOL finished) {
            [self.floodView removeFromSuperview];
            self.floodView=nil;
        }];
        return;
    }
    if(self.floodView.tag == 11117439) { [self revealPlaceholder]; }
    else { [self revealRenderImageView]; }
    [self.floodView removeFromSuperview];
    self.floodView=nil;
    self.debugColor = nil;
    
}
- (MysticCIView *) showFilterView:(MysticCIType)type image:(UIImage *)image duration:(NSTimeInterval)duration;
{
    if(!self.filterView)
    {
        self.filterView = [[[[MysticCIView classForCIType:type] alloc] initWithFrame:self.imageView.bounds] autorelease];
        self.filterView.clipsToBounds=NO;
        self.filterView.sourceImage = image;
    }
    
    if((duration > 0 || duration == -1) && self.filterView.alpha > 0) self.filterView.alpha=0;
    if(!self.filterView.superview) {
        //        [self.imageView addSubview:self.imageViewPlaceholder];
        if(self.imageViewGPU || self.imageViewPlaceholder)
        {
            [self.imageView insertSubview:self.filterView aboveSubview:self.imageViewGPU && self.imageViewGPU.superview ? self.imageViewGPU : self.imageViewPlaceholder];
        }
        else
        {
            [self.imageView addSubview:self.filterView];
        }
    }
    
//    [self.filterView display];
//    MBord(self.filterView);
    if(duration == -1)
    {
        self.debugColor = [UIColor purpleColor];
        return self.filterView;
    }
    if(duration > 0)
    {
        [MysticUIView animate:duration animations:^{
            self.debugColor = [UIColor purpleColor];
            self.filterView.alpha=1;
        } completion:^(BOOL finished) {
            if(self.imageViewGPU) { [self destroyRenderImageView]; self.filterView.tag = 11117438; }
            else if(self.imageViewPlaceholder) { [self destroyPlaceholderImageView]; self.filterView.tag = 11117439; }
        }];
        return self.filterView;
    }
    self.debugColor = [UIColor purpleColor];
    if(self.imageViewGPU) { [self destroyRenderImageView]; self.filterView.tag = 11117438; }
    else if(self.imageViewPlaceholder) { [self destroyPlaceholderImageView]; self.filterView.tag = 11117439; }
    return self.filterView;
}
- (void) hideFilterView:(NSTimeInterval)duration;
{
    if(!self.filterView) return;
    if(!self.filterView.superview)
    {
        self.filterView = nil;
        self.debugColor = nil;
        return;
    }
    if(self.filterView.hidden || self.filterView.alpha == 0)
    {
        [self.filterView removeFromSuperview];
        self.filterView = nil;
        self.debugColor = nil;
        return;
    }
    
    if(duration > 0)
    {
        if(self.filterView.tag == 11117439) { [self revealPlaceholder]; }
        else { [self revealRenderImageView]; }
        
        [MysticUIView animate:duration animations:^{
            self.debugColor = nil;
            self.filterView.alpha=0;
        } completion:^(BOOL finished) {
            [self.filterView removeFromSuperview];
            self.filterView=nil;
        }];
        return;
    }
    if(self.filterView.tag == 11117439) { [self revealPlaceholder]; }
    else { [self revealRenderImageView]; }
    [self.filterView removeFromSuperview];
    self.filterView=nil;
    self.debugColor = nil;
}
- (void) layoutSubviews;
{
    [self.previewOrRenderView.superview bringSubviewToFront:self.previewOrRenderView];
    self.centerDot.center = CGPointAddY(self.scrollView.center, -currentImageViewInsets.bottom);
}


- (void) showScribbleView:(UIImage *)image duration:(NSTimeInterval)duration;
{
    if(!self.scribbleView)
    {
        self.scribbleView = [[[MysticScribbleView alloc] initWithFrame:self.imageView.bounds] autorelease];
        self.scribbleView.clipsToBounds=NO;
        self.scribbleView.image = image;
        self.scribbleView.userInteractionEnabled=YES;
        self.scribbleView.multipleTouchEnabled=YES;
    }
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    if((duration > 0 || duration == -1) && self.quickView.alpha > 0) self.quickView.alpha=0;
    if(!self.scribbleView.superview) {
        if(self.imageViewGPU || self.imageViewPlaceholder)
        {
            [self.imageView insertSubview:self.scribbleView aboveSubview:self.imageViewGPU && self.imageViewGPU.superview ? self.imageViewGPU : self.imageViewPlaceholder];
        }
        else
        {
            [self.imageView addSubview:self.scribbleView];
        }
    }
    
    if(duration == -1)
    {
        self.debugColor = [UIColor magentaColor];
        return;
    }
    if(duration > 0)
    {
        [MysticUIView animate:duration animations:^{
            self.debugColor = [UIColor magentaColor];
            self.scribbleView.alpha=1;
        }];
        return;
    }
    self.debugColor = [UIColor magentaColor];
    self.scribbleView.alpha = 1;
    
}
- (void) hideScribbleView:(NSTimeInterval)duration;
{
    self.userInteractionEnabled = NO;
    self.multipleTouchEnabled = NO;
    
    if(!self.scribbleView) return;
    if(!self.scribbleView.superview)
    {
        self.scribbleView = nil;
        self.debugColor = nil;
        return;
    }
    if(self.scribbleView.hidden || self.scribbleView.alpha == 0)
    {
        [self.scribbleView removeFromSuperview];
        self.scribbleView = nil;
        self.debugColor = nil;
        return;
    }
    
    if(duration > 0)
    {
        [MysticUIView animate:duration animations:^{
            self.debugColor = nil;
            self.scribbleView.alpha=0;
        } completion:^(BOOL finished) {
            [self.scribbleView removeFromSuperview];
            self.scribbleView=nil;
        }];
        return;
    }
    
    [self.scribbleView removeFromSuperview];
    self.scribbleView=nil;
    self.debugColor = nil;
}
- (void) setUserInteractionEnabled:(BOOL)userInteractionEnabled;
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.imageView.userInteractionEnabled = userInteractionEnabled;
    self.scribbleView.userInteractionEnabled = userInteractionEnabled;
    
}
- (void) setMultipleTouchEnabled:(BOOL)multipleTouchEnabled;
{
    [super setMultipleTouchEnabled:multipleTouchEnabled];
    self.imageView.multipleTouchEnabled=multipleTouchEnabled;
    self.scribbleView.multipleTouchEnabled=multipleTouchEnabled;
}
@end
