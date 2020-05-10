//
//  MysticSectionToolbar.m
//  Mystic
//
//  Created by Travis on 10/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticSectionToolbar.h"
#import "MysticSectionToolbarItem.h"

@implementation MysticSectionToolbar

+ (CGFloat) height;
{
    return MYSTIC_UI_TABLE_SECTION_HEIGHT_TOOLBAR;
}

- (Class) itemClass;
{
    return [MysticSectionToolbarItem class];
}

- (id) initWithFrame:(CGRect)frame items:(NSArray *)theItems;
{
    self = [super initWithFrame:frame items:theItems];
    if(self)
    {
        self.backgroundColor = [UIColor color:MysticColorTypeDrawerSectionToolbar];

    }
    return self;
}

@end
