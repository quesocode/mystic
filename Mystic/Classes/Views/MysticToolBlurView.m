//
//  MysticToolBlurView.m
//  Mystic
//
//  Created by Me on 2/9/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticToolBlurView.h"
//#import "LEColorPicker.h"


@implementation MysticToolBlurView

- (void) dealloc;
{
    [_tintColor release];
    [_underlyingImage release];
    [_underlyingView release];
    [super dealloc];
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        self.blendMode = kCGBlendModeLuminosity;
       
    }
    return self;
}
- (void) setTintColor:(UIColor *)tintColor;
{
    if(_tintColor)
    {
        [_tintColor release], _tintColor=nil;
    }
    _tintColor = [tintColor retain];
    self.backgroundColor = [_tintColor colorWithAlphaComponent:1.0];
}

//- (void) setUnderlyingImage:(UIImage *)underlyingImage;
//{
//    LEColorPicker *colorPicker = [[LEColorPicker alloc] init];
//    LEColorScheme *colorScheme = [colorPicker colorSchemeFromImage:underlyingImage];
//    UIColor *bgColor = [colorScheme backgroundColor];
//    
//    ALLog(@"setting setUnderlyingImage", @[@"bgcolor", ColorToString(bgColor), @"brightness", @([MysticColor brightness:bgColor])]);
//    [colorPicker release];
//    [super setUnderlyingImage:underlyingImage];
//}
//- (UIImage *)blurredSnapshot:(UIImage *)snapshot
//{
//    LEColorPicker *colorPicker = [[LEColorPicker alloc] init];
//    LEColorScheme *colorScheme = [colorPicker colorSchemeFromImage:snapshot];
//    UIColor *bgColor = [colorScheme backgroundColor];
//    
//    ALLog(@"setting blurred snapshot", @[@"bgcolor", ColorToString(bgColor), @"brightness", @([MysticColor brightness:bgColor])]);
//    [colorPicker release];
//    return [super blurredSnapshot:snapshot];
//    
//}

@end
