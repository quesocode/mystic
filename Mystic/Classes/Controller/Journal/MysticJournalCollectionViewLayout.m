//
//  MysticJournalCollectionViewLayout.m
//  Mystic
//
//  Created by Me on 3/29/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticJournalCollectionViewLayout.h"
#import "MysticJournalCollectionViewLayoutAttributes.h"
#import "Mystic.h"

@interface MysticJournalCollectionViewLayout ()
{
    
}
@property (nonatomic, assign) BOOL isBoring;
@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *removedIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedSectionIndices;
@property (nonatomic, strong) NSMutableArray *removedSectionIndices;

// Caches for keeping current/previous attributes
@property (nonatomic, strong) NSMutableDictionary *currentCellAttributes;
@property (nonatomic, strong) NSMutableDictionary *currentSupplementaryAttributesByKind;
@property (nonatomic, strong) NSMutableDictionary *cachedCellAttributes;
@property (nonatomic, strong) NSMutableDictionary *cachedSupplementaryAttributesByKind;

@end


@implementation MysticJournalCollectionViewLayout

+ (Class)layoutAttributesClass
{
    return [MysticJournalCollectionViewLayoutAttributes class];
}


- (void) dealloc;
{
    [_insertedIndexPaths release];
    [_removedIndexPaths release];
    [_insertedSectionIndices release];
    [_removedSectionIndices release];
    [_currentCellAttributes release];
    [_currentSupplementaryAttributesByKind release];
    [_cachedCellAttributes release];
    [_cachedSupplementaryAttributesByKind release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.isBoring = NO;
        self.currentCellAttributes = [NSMutableDictionary dictionary];
        self.currentSupplementaryAttributesByKind = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{

    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.isBoring = NO;
        self.currentCellAttributes = [NSMutableDictionary dictionary];
        self.currentSupplementaryAttributesByKind = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)makeBoring
{
    self.isBoring = YES;
}


- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
//    DLog(@"layout for item: %d, %d", itemIndexPath.section, itemIndexPath.item);
    if (!self.isBoring)
    {
//        if ([self.insertedIndexPaths containsObject:itemIndexPath])
//        {
//            // If this is a newly inserted item, make it grow into place from its nominal index path
//            attributes = [[self.currentCellAttributes objectForKey:itemIndexPath] copy];
//            attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
//        }
//        else if ([self.insertedSectionIndices containsObject:@(itemIndexPath.section)])
//        {
//            // if it's part of a new section, fly it in from the left
//            attributes = [[self.currentCellAttributes objectForKey:itemIndexPath] copy];
//            attributes.transform3D = CATransform3DMakeTranslation(-self.collectionView.bounds.size.width, 0, 0);
//        }
        
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes*)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if (!self.isBoring)
    {
        
//        if ([self.removedIndexPaths containsObject:itemIndexPath] || [self.removedSectionIndices containsObject:@(itemIndexPath.section)])
//        {
//            // Make it fall off the screen with a slight rotation
//            attributes = [[self.cachedCellAttributes objectForKey:itemIndexPath] copy];
//            CATransform3D transform = CATransform3DMakeTranslation(0, self.collectionView.bounds.size.height, 0);
//            transform = CATransform3DRotate(transform, M_PI*0.2, 0, 0, 1);
//            attributes.transform3D = transform;
//            attributes.alpha = 0.0f;
//        }
    }
    return attributes;
}


- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    if (!self.isBoring)
    {
        // Keep track of updates to items and sections so we can use this information to create nifty animations
        self.insertedIndexPaths     = [NSMutableArray array];
        self.removedIndexPaths      = [NSMutableArray array];
        self.insertedSectionIndices = [NSMutableArray array];
        self.removedSectionIndices  = [NSMutableArray array];
        
        [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
            if (updateItem.updateAction == UICollectionUpdateActionInsert)
            {
                // If the update item's index path has an "item" value of NSNotFound, it means it was a section update, not an individual item.
                // This is 100% undocumented but 100% reproducible.
                
                if (updateItem.indexPathAfterUpdate.item == NSNotFound)
                {
                    [self.insertedSectionIndices addObject:@(updateItem.indexPathAfterUpdate.section)];
                }
                else
                {
                    [self.insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
                }
            }
            else if (updateItem.updateAction == UICollectionUpdateActionDelete)
            {
                if (updateItem.indexPathBeforeUpdate.item == NSNotFound)
                {
                    [self.removedSectionIndices addObject:@(updateItem.indexPathBeforeUpdate.section)];
                    
                }
                else
                {
                    [self.removedIndexPaths addObject:updateItem.indexPathBeforeUpdate];
                }
            }
        }];
    }
}


- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    
    self.insertedIndexPaths     = nil;
    self.removedIndexPaths      = nil;
    self.insertedSectionIndices = nil;
    self.removedSectionIndices  = nil;
}


- (void)prepareLayout
{
    [super prepareLayout];
    
    // Deep-copy attributes in current cache
    self.cachedCellAttributes = [[[NSMutableDictionary alloc] initWithDictionary:self.currentCellAttributes copyItems:YES] autorelease];
    self.cachedSupplementaryAttributesByKind = [NSMutableDictionary dictionary];
    [self.currentSupplementaryAttributesByKind enumerateKeysAndObjectsUsingBlock:^(NSString *kind, NSMutableDictionary * attribByPath, BOOL *stop) {
        NSMutableDictionary * cachedAttribByPath = [[NSMutableDictionary alloc] initWithDictionary:attribByPath copyItems:YES];
        [self.cachedSupplementaryAttributesByKind setObject:cachedAttribByPath forKey:kind];
        [cachedAttribByPath release];
    }];
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{

    NSArray * attributes = [super layoutAttributesForElementsInRect:rect];

    // Always cache all visible attributes so we can use them later when computing final/initial animated attributes
    // Never clear the cache as certain items may be removed from the attributes array prior to being animated out
    [attributes enumerateObjectsUsingBlock:^(MysticJournalCollectionViewLayoutAttributes *attributes, NSUInteger idx, BOOL *stop) {

        if (attributes.representedElementCategory == UICollectionElementCategoryCell)
        {

            attributes.hasBeenAdded = [self.currentCellAttributes objectForKey:attributes.indexPath] != nil;
            
            [self.currentCellAttributes setObject:attributes
                                           forKey:attributes.indexPath];
        }
        else if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView)
        {
            NSMutableDictionary *supplementaryAttribuesByIndexPath = [self.currentSupplementaryAttributesByKind objectForKey:attributes.representedElementKind];
            if (supplementaryAttribuesByIndexPath == nil)
            {
                supplementaryAttribuesByIndexPath = [NSMutableDictionary dictionary];
                [self.currentSupplementaryAttributesByKind setObject:supplementaryAttribuesByIndexPath forKey:attributes.representedElementKind];
            }
            
            [supplementaryAttribuesByIndexPath setObject:attributes
                                                  forKey:attributes.indexPath];
        }
        
    }];
    
    return attributes;
}



@end
