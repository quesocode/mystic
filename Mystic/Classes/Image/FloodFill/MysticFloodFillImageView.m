//
//  FloodFillImageView.m
//  ImageFloodFilleDemo
//
//  Created by chintan on 11/07/13.
//  Copyright (c) 2013 ZWT. All rights reserved.
//
//
#import "MysticFloodFillImageView.h"

@implementation MysticFloodFillImageView

@synthesize tolerance,newcolor;

- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}
- (void) setup;
{
    tolerance = 50;
    _smooth = 0.5;
    _continuous = YES;
    _antialias = YES;
    _makeMask = YES;
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Get touch Point
    CGPoint tpoint = [[[event allTouches] anyObject] locationInView:self];
    
    //Convert Touch Point to pixel of Image
    //This code will be according to your need
    tpoint.x = tpoint.x * 2 ;
    tpoint.y = tpoint.y * 2 ;
    
    //Call function to flood fill and get new image with filled color
    UIImage *image1 = [self.image floodFillFromPoint:tpoint withColor:newcolor andTolerance:tolerance];
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        [self setImage:image1];
    });
}
- (void) replaceWith:(UIColor *)color at:(CGPoint)tpoint tolerance:(int)t antialias:(BOOL)a smooth:(CGFloat)s continous:(BOOL)continuous;
{
    tolerance = t == -1 ? tolerance : t;
    self.newcolor = color;
    self.continuous = continuous;
    self.antialias = a;
    self.smooth = s == -1 ? self.smooth : s;
    tpoint.x = tpoint.x * 2 ;
    tpoint.y = tpoint.y * 2 ;
    
    //Call function to flood fill and get new image with filled color
    UIImage *image1 = [self.image floodFillFromPoint:tpoint withColor:newcolor andTolerance:tolerance useAntiAlias:a];
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [self setImage:image1];
                   });
}
@end