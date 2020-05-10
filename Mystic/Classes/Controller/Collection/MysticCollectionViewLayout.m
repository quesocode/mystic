//
//  MysticCollectionViewLayout.m
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionViewLayout.h"
#import "Mystic.h"

@implementation MysticCollectionViewLayout

- (id) init;
{
    self = [super init];
    if(self)
    {
        _sectionHeaderTopBorderWidth = 0;
    }
    return self;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    NSMutableArray *visibleSectionsWithoutHeader = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *itemAttributes in attributes)
    {
        if (![visibleSectionsWithoutHeader containsObject:[NSNumber numberWithInteger:itemAttributes.indexPath.section]]) {
            [visibleSectionsWithoutHeader addObject:[NSNumber numberWithInteger:itemAttributes.indexPath.section]];
        }
        if (itemAttributes.representedElementKind==UICollectionElementKindSectionHeader) {
            NSUInteger indexOfSectionObject=[visibleSectionsWithoutHeader indexOfObject:[NSNumber numberWithInteger:itemAttributes.indexPath.section]];
            if (indexOfSectionObject!=NSNotFound) {
                [visibleSectionsWithoutHeader removeObjectAtIndex:indexOfSectionObject];
            }
        }
    }
    for (NSNumber *sectionNumber in visibleSectionsWithoutHeader) {
        BOOL shouldUseHeader = [self shouldStickHeaderToTopInSection:[sectionNumber integerValue]];
        
        if (shouldUseHeader) {
            UICollectionViewLayoutAttributes *headerAttributes=[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:[sectionNumber integerValue]]];
            if (headerAttributes.frame.size.width>0 && headerAttributes.frame.size.height>0) {
                [attributes addObject:headerAttributes];
            }
        }
    }
    for (UICollectionViewLayoutAttributes *itemAttributes in attributes) {
        if (itemAttributes.representedElementKind==UICollectionElementKindSectionHeader) {
            UICollectionViewLayoutAttributes *headerAttributes = itemAttributes;
            BOOL shouldHideHeaderOnScroll = [self shouldHideHeaderOnScroll:headerAttributes.indexPath.section];
//            shouldHideHeaderOnScroll = NO;
            if ([self shouldStickHeaderToTopInSection:headerAttributes.indexPath.section]) {
                CGPoint contentOffset = self.collectionView.contentOffset;
                CGPoint originInCollectionView=CGPointMake(headerAttributes.frame.origin.x-contentOffset.x, headerAttributes.frame.origin.y-contentOffset.y);
                originInCollectionView.y-=self.collectionView.contentInset.top;
                CGRect frame = headerAttributes.frame;
                CGFloat padding = (headerAttributes.indexPath.section > 1 ? -self.sectionHeaderTopBorderWidth : 0);
                
                
                if(!shouldHideHeaderOnScroll)
                {
                    if (originInCollectionView.y<padding) {
                        
//                        DLog(@"stick header: %2.2f", originInCollectionView.y);
                        
                        frame.origin.y+=((originInCollectionView.y*-1) + padding);
                    }
                }
                else
                {
                    
                }
                
                NSUInteger numberOfSections=[self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
                if (numberOfSections>headerAttributes.indexPath.section+1) {
                    UICollectionViewLayoutAttributes *nextHeaderAttributes=[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:headerAttributes.indexPath.section+1]];
                    CGFloat maxY=nextHeaderAttributes.frame.origin.y;
                    if (CGRectGetMaxY(frame)>=maxY) {
                        frame.origin.y=maxY-frame.size.height;
                    }
                }
//                ALLog(@"header layout", @[@"collection offset", @(self.collectionView.contentOffset.y),
//                                          @"origin", @(originInCollectionView.y),
//                                          @"frame", @(frame.origin.y),
//                                          @"rect", FLogStr(rect),
//                                          @"inset", NSStringFromUIEdgeInsets(self.collectionView.contentInset),
//                                          ]);
                
                headerAttributes.frame = frame;
            }
            headerAttributes.zIndex = 1024;
            
            if (![self shouldHeaderDragInSection:headerAttributes.indexPath.section])
            {
                CGPoint contentOffset = self.collectionView.contentOffset;
                CGRect frame = headerAttributes.frame;
                CGPoint originInCollectionView=CGPointMake(headerAttributes.frame.origin.x-contentOffset.x, headerAttributes.frame.origin.y-contentOffset.y);
                originInCollectionView.y-=self.collectionView.contentInset.top;
         
                if(contentOffset.y <= 0)
                {
                    frame.origin.y = headerAttributes.frame.origin.y + contentOffset.y;

                }
//                if(headerAttributes.indexPath.section > 0)
//                {
//                ALLog(@"shouldHeaderDrag", @[@"SECTION", @(headerAttributes.indexPath.section),
//                                             @"offset", @(contentOffset.y),
//                                             @"frame", @(headerAttributes.frame.origin.y),
//                                             @"new frame", @(frame.origin.y),
//                                             @"original", @(originInCollectionView.y),
//                                             
//                                             ]);
//                }
                

                headerAttributes.frame = frame;

                headerAttributes.zIndex = 2048 - (int)headerAttributes.indexPath.section;
                
            }
            
            if(shouldHideHeaderOnScroll)
            {
                
            }
        }
    }
 
    return [attributes autorelease];
}
- (BOOL)shouldStickHeaderToTopInSection:(NSUInteger)section{
    BOOL shouldStickToTop=YES;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(MysticCollectionViewLayoutDelegate)]) {
        id<MysticCollectionViewLayoutDelegate> stickyHeadersDelegate=(id<MysticCollectionViewLayoutDelegate>)self.collectionView.delegate;
        if ([stickyHeadersDelegate respondsToSelector:@selector(shouldStickHeaderToTopInSection:)]) {
            shouldStickToTop=[stickyHeadersDelegate shouldStickHeaderToTopInSection:section];
        }
    }
    return shouldStickToTop;
}

- (BOOL)shouldHeaderDragInSection:(NSUInteger)section{
    BOOL shouldStickToTop=YES;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(MysticCollectionViewLayoutDelegate)]) {
        id<MysticCollectionViewLayoutDelegate> stickyHeadersDelegate=(id<MysticCollectionViewLayoutDelegate>)self.collectionView.delegate;
        if ([stickyHeadersDelegate respondsToSelector:@selector(shouldHeaderDragInSection:)]) {
            shouldStickToTop=[stickyHeadersDelegate shouldHeaderDragInSection:section];
        }
    }
    return shouldStickToTop;
}


- (BOOL)shouldShowFooterOnStart:(NSUInteger)section{
    BOOL shouldStickToTop=YES;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(MysticCollectionViewLayoutDelegate)]) {
        id<MysticCollectionViewLayoutDelegate> stickyHeadersDelegate=(id<MysticCollectionViewLayoutDelegate>)self.collectionView.delegate;
        if ([stickyHeadersDelegate respondsToSelector:@selector(shouldShowFooterOnStart:)]) {
            shouldStickToTop=[stickyHeadersDelegate shouldShowFooterOnStart:section];
        }
    }
    return shouldStickToTop;
}

- (BOOL)shouldHideFooterOnScroll:(NSUInteger)section{
    BOOL shouldStickToTop=YES;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(MysticCollectionViewLayoutDelegate)]) {
        id<MysticCollectionViewLayoutDelegate> stickyHeadersDelegate=(id<MysticCollectionViewLayoutDelegate>)self.collectionView.delegate;
        if ([stickyHeadersDelegate respondsToSelector:@selector(shouldHideFooterOnScroll:)]) {
            shouldStickToTop=[stickyHeadersDelegate shouldHideFooterOnScroll:section];
        }
    }
    return shouldStickToTop;
}

- (BOOL)shouldHideHeaderOnScroll:(NSUInteger)section{
    BOOL shouldStickToTop=YES;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(MysticCollectionViewLayoutDelegate)]) {
        id<MysticCollectionViewLayoutDelegate> stickyHeadersDelegate=(id<MysticCollectionViewLayoutDelegate>)self.collectionView.delegate;
        if ([stickyHeadersDelegate respondsToSelector:@selector(shouldHideHeaderOnScroll:)]) {
            shouldStickToTop=[stickyHeadersDelegate shouldHideHeaderOnScroll:section];
        }
    }
    return shouldStickToTop;
}

- (BOOL)shouldShowHeaderOnStart:(NSUInteger)section{
    BOOL shouldStickToTop=YES;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(MysticCollectionViewLayoutDelegate)]) {
        id<MysticCollectionViewLayoutDelegate> stickyHeadersDelegate=(id<MysticCollectionViewLayoutDelegate>)self.collectionView.delegate;
        if ([stickyHeadersDelegate respondsToSelector:@selector(shouldStickHeaderToTopInSection:)]) {
            shouldStickToTop=[stickyHeadersDelegate shouldShowHeaderOnStart:section];
        }
    }
    return shouldStickToTop;
}


@end
