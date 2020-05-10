//
//  UIImage+Launch.m
//  Mystic
//
//  Created by Me on 11/19/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "UIImage+Launch.h"

@implementation UIImage_Launch

+(NSString*)getLaunchImageName
{
    
/*0*/    NSArray* images= @[ @"Default.png",
/*1*/                       @"Default@2x.png",
/*2*/                       @"Default-Portrait~iphone@2x.png",
/*3*/                      @"Default-Portrait~iphone568h@2x.png",
/*4*/                       @"Default-Portrait~iphone568h@2x.png",
/*5*/                      @"Default-Portrait@2x~ipad.png",
/*6*/                      @"Default-Portrait@2x~ipad.png",
/*7*/                       @"Default-Portrait~ipad.png",
/*8*/                       @"Default-Portrait~ipad.png",
/*9*/                       @"Default-Landscape@2x~ipad.png",
/*10*/                       @"Default-Landscape@2x~ipad.png",
/*11*/                      @"Default-Landscape~ipad.png",
/*12*/                      @"Default-Landscape~ipad.png"];
    
    UIImage *splashImage;
    
    if ([self isDeviceiPhone])
    {
        if ([self isDeviceiPhone4] && [self isDeviceRetina])
        {
            splashImage = [UIImage imageNamed:images[1]];
            if (splashImage.size.width!=0)
                return images[1];
            else
                return images[2];
        }
        else if ([self isDeviceiPhone5])
        {
            splashImage = [UIImage imageNamed:images[1]];
            if (splashImage.size.width!=0)
                return images[3];
            else
                return images[4];
        }
        else
            return images[0]; //Non-retina iPhone
    }
    else if ([[UIDevice currentDevice] orientation]==UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)//iPad Portrait
    {
        if ([self isDeviceRetina])
        {
            splashImage = [UIImage imageNamed:images[5]];
            if (splashImage.size.width!=0)
                return images[5];
            else
                return images[6];
        }
        else
        {
            splashImage = [UIImage imageNamed:images[7]];
            if (splashImage.size.width!=0)
                return images[7];
            else
                return images[8];
        }
        
    }
    else
    {
        if ([self isDeviceRetina])
        {
            splashImage = [UIImage imageNamed:images[9]];
            if (splashImage.size.width!=0)
                return images[9];
            else
                return images[10];
        }
        else
        {
            splashImage = [UIImage imageNamed:images[11]];
            if (splashImage.size.width!=0)
                return images[11];
            else
                return images[12];
        }
    }
}
+(BOOL)isDeviceiPhone
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return TRUE;
    }
    
    return FALSE;
}

+(BOOL)isDeviceiPhone4
{
    if ([[UIScreen mainScreen] bounds].size.height==480)
        return TRUE;
    
    return FALSE;
}


+(BOOL)isDeviceRetina
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0))        // Retina display
    {
        return TRUE;
    }
    else                                          // non-Retina display
    {
        return FALSE;
    }
}


+(BOOL)isDeviceiPhone5
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height>480)
    {
        return TRUE;
    }
    return FALSE;
}

@end
