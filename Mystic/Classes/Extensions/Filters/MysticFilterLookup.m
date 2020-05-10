//
//  MysticFilterLookup.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/6/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticFilterLookup.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"

@implementation MysticFilterLookup

- (id)initWithImage:(UIImage *)image;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
//    UIImage *image = [UIImage imageNamed:@"lookup_amatorka.png"];

    
//    NSAssert(image, @"To use GPUImageAmatorkaFilter you need to add lookup_amatorka.png from GPUImage/framework/Resources to your application bundle.");
    
    lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    [self addFilter:lookupFilter];
    
    [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
    [lookupImageSource processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
    self.terminalFilter = lookupFilter;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

@end

