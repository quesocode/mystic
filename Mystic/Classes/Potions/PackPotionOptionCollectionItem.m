//
//  PackPotionOptionCollectionItem.m
//  Mystic
//
//  Created by Me on 6/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "PackPotionOptionCollectionItem.h"

@implementation PackPotionOptionCollectionItem

+ (id) optionWithItem:(MysticCollectionItem *)theItem;
{
    PackPotionOptionCollectionItem *option = [[self class] optionWithName:theItem.title info:theItem.info];
    option.tag = theItem.tag;
    option.name = theItem.title ? theItem.title : theItem.tag;
    option.item = theItem;
    return option;
}


- (NSString *) downloadUrlForSettings:(MysticRenderOptions)settings;
{
    NSString *downloadURL = nil;
    if(settings & MysticRenderOptionsOriginal)
    {
        downloadURL = self.item.fullResolutionURLString;
    }
    else if(settings & MysticRenderOptionsSource)
    {
        downloadURL = self.item.fullResolutionURLString;
        
    }
    else if(settings & MysticRenderOptionsPreview)
    {
        downloadURL = self.item.imageURLString;
        //        downloadURL = self.imageURLString;
        
        
    }
    else if(settings & MysticRenderOptionsThumb)
    {
        downloadURL = self.item.thumbnailURLString;
        
    }
    return downloadURL;
}

- (void) dealloc;
{
    [_item release];
    [super dealloc];
}
@end
