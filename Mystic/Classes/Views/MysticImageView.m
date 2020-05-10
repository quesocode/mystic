//
//  MysticImageView.m
//  Mystic
//
//  Created by Me on 3/25/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import "MysticImageView.h"
#import "MysticImage.h"

@implementation MysticImageView

- (instancetype) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(!self) return self;
    self.duration = -1;
    self.userInteractionEnabled = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
    return self;
}
//- (void) setImage:(UIImage *)image;
//{
//    if(self.animateImage) [self fadeToImage:image duration:self.duration];
//    else [super setImage:image];
//}
- (void) setImage:(UIImage *)image duration:(NSTimeInterval)duration;
{
    [self fadeToImage:image duration:duration];
}
- (void) fadeToImage:(UIImage *)image;
{
    [self fadeToImage:image duration:self.duration];
}
- (void) fadeToImage:(UIImage *)image duration:(NSTimeInterval)duration;
{
    if(image) [image retain];
    mdispatch(^{
        if(!self.image || !self.superview || duration == 0) { [self setImage:[image autorelease]]; return; }
        CATransition *animation = [CATransition animation];
        animation.duration = duration < 0 ? 0.5 :duration;
        animation.type = kCATransitionFade;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [[self layer] addAnimation:animation forKey:@"imageFade"];
        [self setImage:image];
        [image autorelease];
    });
}

@end
