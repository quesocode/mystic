//
//  MysticPackPickerCellSectionHeader.m
//  Mystic
//
//  Created by Me on 5/7/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPackPickerCellSectionHeader.h"
#import "UIColor+Mystic.h"
#import "MysticPackPickerItem.h"

@implementation MysticPackPickerCellSectionHeader


- (void) setCollectionItem:(MysticPackPickerItem *)collectionItem;
{
    [super setCollectionItem:collectionItem];
    
    
    self.title = [collectionItem.sectionTitle uppercaseString];
    
    

}
@end
