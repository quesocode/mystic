//
//  MysticImageViewGallery.m
//  Mystic
//
//  Created by travis weerts on 3/6/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticImageViewGallery.h"
#import "Mystic.h"
#import <QuartzCore/QuartzCore.h>


#define TRANSITION_DURATION 0.15

@implementation MysticImageViewGallery





@synthesize intermediateTransitionView = mIntermediateTransitionView;
@synthesize originalImageViewContainerView = mOriginalImageViewContainerView;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}
- (BOOL) canBecomeFirstResponder;
{
    return self.userInteractionEnabled;
}
- (void) setUserInteractionEnabled:(BOOL)__userInteractionEnabled;
{
    [super setUserInteractionEnabled:__userInteractionEnabled];
    if(__userInteractionEnabled)
    {
        
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if(!self.userInteractionEnabled) return;
    
    
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(mysticImageView:touchesBegan:withEvent:)])
    {
        [self.delegate mysticImageView:self touchesBegan:touches withEvent:event];
    }
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if(!self.userInteractionEnabled) return;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(mysticImageView:touchesMoved:withEvent:)])
    {
        [self.delegate mysticImageView:self touchesMoved:touches withEvent:event];
    }
    
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if(!self.userInteractionEnabled) return;
//    self.layer.borderWidth = 0;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(mysticImageView:touchesEnded:withEvent:)])
    {
        [self.delegate mysticImageView:self touchesEnded:touches withEvent:event];
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)dealloc
{
    [self setOriginalImageViewContainerView:nil];
    [self setIntermediateTransitionView:nil];
    [super dealloc];
}


#pragma mark -
#pragma mark Animation methods
-(void)setImage:(UIImage *)inNewImage withTransitionAnimation:(BOOL)inAnimation
{
    if (!inAnimation)
    {
        [self setImage:inNewImage];
    }
    else
    {
        
        if([self intermediateTransitionView])
        {
            [self setAlpha:1.0];
            
            // Set the image to the main imageView:
            [self setImage:[[self intermediateTransitionView] image]];
            
            [[self intermediateTransitionView] removeFromSuperview];
            [self setIntermediateTransitionView:nil];
            
            [[self originalImageViewContainerView] removeFromSuperview];
            [self setOriginalImageViewContainerView:nil];
        }
        
        // Create a transparent imageView which will display the transition image.
        CGRect rectForNewView = [self frame];
        rectForNewView.origin = CGPointZero;
        UIImageView *intermediateView = [[UIImageView alloc] initWithFrame:rectForNewView];
        [intermediateView setBackgroundColor:[UIColor clearColor]];
        [intermediateView setContentMode:[self contentMode]];
        [intermediateView setClipsToBounds:[self clipsToBounds]];
        
        [intermediateView setImage:inNewImage];
        
        // Create the image view which will contain original imageView's contents:
        UIImageView *originalView = [[UIImageView alloc] initWithFrame:rectForNewView];
        [originalView setBackgroundColor:[UIColor clearColor]];
        [originalView setContentMode:[self contentMode]];
        [originalView setClipsToBounds:[self clipsToBounds]];
        
        
        
        [originalView setImage:[self image]];
        
        // Remove image from the main imageView and add the originalView as subView to mainView:
        [self addSubview:originalView];
        [self setImage:nil];
        
        
        // Add the transparent imageView as subview whose dimensions are same as the view which holds it.
        [self addSubview:intermediateView];
        
        // Set alpha value to 0 initially:
        [intermediateView setAlpha:0.0];
        [originalView setAlpha:1.0];
        [self setIntermediateTransitionView:intermediateView];
        [self setOriginalImageViewContainerView:originalView];
        [intermediateView release];
        [originalView release];
        
        // Begin animations:
        [UIView beginAnimations:@"ImageViewTransitions" context:nil];
        [UIView setAnimationDuration:(double)TRANSITION_DURATION];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [[self intermediateTransitionView] setAlpha:1.0];
        //[[self originalImageViewContainerView] setAlpha:0.0];
        [UIView commitAnimations];
    }
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.originalImageViewContainerView.frame = self.bounds;
    self.intermediateTransitionView.frame = self.bounds;
    
}
-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    // Reset the alpha of the main imageView
    [self setAlpha:1.0];
    
    // Set the image to the main imageView:
    [self setImage:[[self intermediateTransitionView] image]];
    
    [[self intermediateTransitionView] removeFromSuperview];
    [self setIntermediateTransitionView:nil];
    
    [[self originalImageViewContainerView] removeFromSuperview];
    [self setOriginalImageViewContainerView:nil];
}

@end