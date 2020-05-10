//
//  MysticLayerAdjustView.m
//  Mystic
//
//  Created by Sara Acker on 6/4/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticLayerAdjustView.h"
#import "Mystic.h"

@implementation MysticLayerAdjustView

@synthesize imageView=_imageView;
- (void) dealloc
{
    [_imageView release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.alpha = 0.8;
        [self addSubview:_imageView];
        self.maximumZoomScale = 3.0f;
        self.zoomScale = 1.0f;
        self.minimumZoomScale = 0.1f;
        self.delegate = self;
        
        
    }
    return self;
}

- (void) setImage:(UIImage *)image
{
    _imageView.image = image;
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    return frameToCenter;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //PLog(@"adjust zoom", self.contentOffset);
    
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale;
{
    //self.imageView.frame = [self centeredFrameForScrollView:self andUIView:self.imageView];
    CGRect rect = self.imageView.frame;
    rect.origin.x = (self.contentOffset.x *-1) *scale;
    rect.origin.y = (self.contentOffset.y *-1)*scale;
    self.imageView.frame = rect;
    
    self.contentOffset = CGPointZero;
}

@end
