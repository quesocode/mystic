//
//  MysticJournalCollectionViewLayoutAttributes.m
//  Mystic
//
//  Created by Me on 3/29/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticJournalCollectionViewLayoutAttributes.h"

@implementation MysticJournalCollectionViewLayoutAttributes

- (BOOL) isEqual:(id)object;
{
    BOOL isit = [super isEqual:object];
    if(isit)
    {
        isit = [(MysticJournalCollectionViewLayoutAttributes *)object hasBeenAdded] == self.hasBeenAdded;
    }
    return isit;
}

- (id) copyWithZone:(NSZone *)zone;
{
    MysticJournalCollectionViewLayoutAttributes *theCopy = [super copyWithZone:zone];
//    theCopy.hasBeenAdded = self.hasBeenAdded;
    return theCopy;
}


@end
