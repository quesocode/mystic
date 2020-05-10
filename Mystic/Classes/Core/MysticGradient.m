//
//  MysticGradient.m
//  Mystic
//
//  Created by Me on 11/14/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticGradient.h"
#import "UIColor+Mystic.h"

@implementation MysticGradient

+ (id) gradientWithColors:(NSArray *)colorsInfo;
{
    MysticGradient *g = [[[self class] alloc] init];
    g.colorsInfo = colorsInfo;
    return g;
}
+ (id) gradientWithColors:(NSArray *)colors locations:(NSArray *)locations;
{
    MysticGradient *g = [[[self class] alloc] init];
    g.colors = colors;
    g.locations = locations;
    return g;
}
- (void) dealloc;
{
    [_colorsInfo release];
    [_colors release];
    [_locations release];
    [super dealloc];
}
- (void) setColorsInfo:(NSArray *)colorsInfo;
{
    [_colorsInfo release];
    _colorsInfo = [colorsInfo retain];
    
    [_colors release], _colors = nil;
    [_locations release], _locations=nil;
    
    NSArray *c = self.colors;
    NSArray *l = self.locations;
    
    c = nil;
    l = nil;
    
//    [_colorsInfo release], _colorsInfo=nil;
}
- (NSArray *) colors;
{
    if(_colors) return _colors;
    NSArray *colors = self.colorsInfo;
    int colorCount = colors.count;
    NSMutableArray *gradientColors = [[NSMutableArray alloc] initWithCapacity:colorCount];
    
    CGFloat locations[colorCount];
    
    CGFloat currentPosition = 0.0;
    CGFloat colorPosition = 0.0;
    CGFloat colorWidth = 1.0;
    CGFloat remainingPosition = 1.0;
    id _color;
    id _finalColor;
    int x = 0;
    int remainingColors = colorCount;
    UIColor *aColor;
    
    NSMutableArray *gradientTags = [NSMutableArray array];
    for(x=0;x<colorCount;x++)
    {
        _finalColor = nil;
        aColor = nil;
        _color = [colors objectAtIndex:x];
        colorWidth = (remainingPosition / remainingColors);
        
        
        colorPosition = ((x+1)==colorCount) ? 1.0 : (x == 0 ? 0 : currentPosition);
        
        if([_color isKindOfClass:[UIColor class]])
        {
            aColor = _color;
        }
        else
        {
            if([_color isKindOfClass:[NSString class]])
            {
                _color = [_color isKindOfClass:[NSString class]] ? _color : [NSString stringWithFormat:@"%@", _color];
                NSArray *colorInfo = [_color componentsSeparatedByString:@"|"];
                if([colorInfo count] > 1)
                {
                    colorPosition = (CGFloat)[[colorInfo objectAtIndex:1] floatValue];
                    _color = [colorInfo objectAtIndex:0];
                }
                
            }
            else if([_color isKindOfClass:[NSArray class]])
            {
                _color = [(NSArray *)_color objectAtIndex:0];
                if([(NSArray *)_color count] > 1)
                {
                    colorPosition = [[(NSArray *)_color objectAtIndex:1] floatValue];
                }
                
            }
            if(!_finalColor)
            {
                _finalColor = [_color isKindOfClass:[NSString class]] ? _color : [NSString stringWithFormat:@"%@", _color];
                aColor = [UIColor string:_finalColor];
            }
        }
        
        if(aColor != nil)
        {
            [gradientColors addObject:(id)[aColor CGColor]];
        }
        [gradientTags addObject:[NSString stringWithFormat:@"rgb%@;pos(%2.2f);", ColorToString(aColor), colorPosition]];
        
        remainingPosition -= colorWidth;
        remainingColors--;
        
        
        
        locations[x] = colorPosition;
        currentPosition += colorWidth;
        
    }
    _colors = [gradientColors retain];
    return gradientColors;
}

- (NSArray *) locations;
{
    if(_locations) return _locations;
    NSArray *colors = self.colorsInfo;
    int colorCount = colors.count;
    NSMutableArray *gradientLocations = [[NSMutableArray alloc] initWithCapacity:colorCount];
    
    CGFloat locations[colorCount];
    
    CGFloat currentPosition = 0.0;
    CGFloat colorPosition = 0.0;
    CGFloat colorWidth = 1.0;
    CGFloat remainingPosition = 1.0;
    id _color;
    id _finalColor;
    int x = 0;
    int remainingColors = colorCount;
    UIColor *aColor;
    
    NSMutableArray *gradientTags = [NSMutableArray array];
    for(x=0;x<colorCount;x++)
    {
        _finalColor = nil;
        aColor = nil;
        _color = [colors objectAtIndex:x];
        colorWidth = (remainingPosition / remainingColors);
        
        
        colorPosition = ((x+1)==colorCount) ? 1.0 : (x == 0 ? 0 : currentPosition);
        
        if([_color isKindOfClass:[UIColor class]])
        {
            aColor = _color;
        }
        else
        {
            if([_color isKindOfClass:[NSString class]])
            {
                _color = [_color isKindOfClass:[NSString class]] ? _color : [NSString stringWithFormat:@"%@", _color];
                NSArray *colorInfo = [_color componentsSeparatedByString:@"|"];
                if([colorInfo count] > 1)
                {
                    colorPosition = (CGFloat)[[colorInfo objectAtIndex:1] floatValue];
                    _color = [colorInfo objectAtIndex:0];
                }
                
            }
            else if([_color isKindOfClass:[NSArray class]])
            {
                _color = [(NSArray *)_color objectAtIndex:0];
                if([(NSArray *)_color count] > 1)
                {
                    colorPosition = [[(NSArray *)_color objectAtIndex:1] floatValue];
                }
                
            }
            if(!_finalColor)
            {
                _finalColor = [_color isKindOfClass:[NSString class]] ? _color : [NSString stringWithFormat:@"%@", _color];
                aColor = [UIColor string:_finalColor];
            }
        }
        
        
        [gradientTags addObject:[NSString stringWithFormat:@"rgb%@;pos(%2.2f);", ColorToString(aColor), colorPosition]];
        
        remainingPosition -= colorWidth;
        remainingColors--;
        
        
        
        locations[x] = colorPosition;
        currentPosition += colorWidth;
        [gradientLocations addObject:@(colorPosition)];
        
    }
    _locations = [gradientLocations retain];
    return gradientLocations;
}

- (NSArray *) colorsArray;
{
    NSMutableArray *c = [NSMutableArray array];
    
    int x = 0;
    for (x = 0; x<self.colors.count; x++) {
        
        id cf = self.colors.count > x ? [self.colors objectAtIndex:x] : [NSNull null];
        id cp = self.locations.count > x ? [self.locations objectAtIndex:x] : [NSNull null];
        
        [c addObject:@[cf, cp]];
        
    }
    return c;
    
}
- (UIImage *) imageForSize:(CGSize)size scale:(CGFloat)scale;
{
    if(CGSizeEqualToSize(size, CGSizeZero)) return nil;
    return [MysticImage backgroundImageWithColor:self.colorsArray size:size scale:scale];
}

@end
