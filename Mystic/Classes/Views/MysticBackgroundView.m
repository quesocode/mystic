//
//  MysticBackgroundView.m
//  Mystic
//
//  Created by Me on 12/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticBackgroundView.h"
#import "UIColor+Mystic.h"

@implementation MysticBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundType = MysticBackgroundTypeDark;
        // Initialization code
        _showBgImage = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor hex:@"141412"];
    }
    return self;
}

- (void) setBackgroundType:(MysticBackgroundType)backgroundType;
{
    _backgroundType = backgroundType;
    
    
    switch (backgroundType) {
        case MysticBackgroundTypeLight:
        {
            
            self.backgroundColor = [UIColor hex:@"d6d0bf"];
            _showBgImage = YES;
            break;
        }
            
        default:
            self.backgroundColor = [UIColor hex:@"141412"];
            _showBgImage = NO;

            break;
    }
    [self setNeedsDisplay];
}

- (void) setShowBgImage:(BOOL)showBgImage;
{
    BOOL c = showBgImage != _showBgImage;
    _showBgImage = showBgImage;
    if(c) [self setNeedsDisplay];
}



@end
@implementation MysticSameBackgroundView

- (void) setBackgroundColor:(UIColor *)backgroundColor;
{
    [super setBackgroundColor:backgroundColor];
    self.layer.backgroundColor = backgroundColor.CGColor;
    self.layer.opaque = YES;
    
}
+ (Class)layerClass { return [MysticSameBackgroundViewLayer class]; }

@end

@implementation MysticSameBackgroundViewLayer

- (void) setBackgroundColor:(CGColorRef)backgroundColor;
{
    [super setBackgroundColor:backgroundColor];
    
    
}

@end