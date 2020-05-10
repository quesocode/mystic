//
//  MysticNippleView.m
//  Mystic
//
//  Created by Travis A. Weerts on 11/24/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticNippleView.h"
#import "Mystic.h"

@implementation MysticNippleView

- (id) initWithFrame:(CGRect)frame image:(id)icon color:(id)color;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.userInteractionEnabled = NO;
        self.image = [MysticImage image:icon size:frame.size color:color];
        if([icon isKindOfClass:[NSNumber class]] && [icon integerValue] == MysticIconTypeNippleTop)
        {
            self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        }
        else if([icon isKindOfClass:[NSNumber class]] && [icon integerValue] == MysticIconTypeNippleBottom)
        {
            self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        }
    }
    return self;
}

@end
