//
//  MysticPackPickerItem.m
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPackPickerItem.h"
#import "PackPotionOption.h"
@interface MysticPackPickerItem ()
{
    NSString *_subTitle, *_thumbnailURLString;
}
@end

@implementation MysticPackPickerItem

- (void) dealloc;
{
    [_pack release];
    if(_subTitle) [_subTitle release], _subTitle=nil;
    if(_thumbnailURLString) [_thumbnailURLString release], _thumbnailURLString=nil;

    [super dealloc];

}
- (void) prepare;
{
    [self subtitle];
    [self thumbnailURLString];
}
- (NSString *) subtitle;
{
    if(_subTitle) return _subTitle;
    
    _subTitle = [self.pack.subtitle retain];
    return _subTitle;
}

- (NSString *) title;
{
    return self.pack ? self.pack.title : [super title];
    
//    return self.pack ? (self.pack.featuredPack ? [@"\u2606 " stringByAppendingString:self.pack.name] : self.pack.name) : [super title];
}

- (NSString *) thumbnailURLString;
{
    if(self.pack.isSpecial)
    {
        NSString *u = self.pack.specialThumbUrl;
        if(u) return u;
    }
    if(_thumbnailURLString) return _thumbnailURLString;
    NSString *thumbURLStr = self.pack && self.pack.controlImageURL ? self.pack.controlImageURL : [super thumbnailURLString];
    thumbURLStr = thumbURLStr && [thumbURLStr isEqualToString:@""] ? nil : thumbURLStr;
    if(!thumbURLStr && self.pack && !self.pack.featuredPack)
    {
//        NSArray *packOptions = self.pack.packOptions ;
//        
//        PackPotionOption *firstPotion = packOptions && packOptions.count ? [packOptions objectAtIndex:0] : nil;
        
        PackPotionOption *sampleOption = self.pack.sampleOption;
        
        if(sampleOption)
        {
            thumbURLStr = sampleOption.previewURLString;
        }
    }
    _thumbnailURLString = [thumbURLStr retain];
    
    return _thumbnailURLString;
}
@end
