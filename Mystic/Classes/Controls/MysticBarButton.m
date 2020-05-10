//
//  MysticBarButton.m
//  Mystic
//
//  Created by Travis on 10/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticBarButton.h"
#import "MysticImage.h"

@implementation MysticBarButton

@synthesize
toolType=_toolType,
lastToolType=_lastToolType,
objectType=_objectType;

+ (MysticBarButton *) buttonWithIconType:(MysticIconType)iconType color:(id)colorOrColorType target:(id)target action:(SEL)action;
{
    return (MysticBarButton *)[super buttonWithIconType:iconType color:colorOrColorType target:target action:action];
}
+ (MysticBarButton *) buttonWithIconType:(MysticIconType)iconType color:(id)colorOrColorType action:(MysticBlockSender)action;
{
    return (MysticBarButton *)[super buttonWithIconType:iconType color:colorOrColorType action:action];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        self.lastToolType = MysticToolTypeUnknown;
        self.canSelect = YES;
    }
    return self;
}
- (MysticColorType) selectedColorType;
{
    MysticColorType s = [super selectedColorType];
    if(s == MysticColorTypeUnknown)
    {
        s = MysticColorTypeBarButtonIconSelected;
    }
    return s;
}
- (void) setSelected:(BOOL)selected;
{
    if(selected)
    {
        UIImage *selectedImg = [self imageForState:UIControlStateSelected];
        UIImage *normalImg = [self imageForState:UIControlStateNormal];
        if([normalImg isEqual:selectedImg])
        {
            UIImage *newSelectedImg = [MysticImage image:normalImg withColor:@(self.selectedColorType)];
            [self setImage:newSelectedImg forState:UIControlStateSelected];
        }
    }
    [super setSelected:selected];


}
@end
