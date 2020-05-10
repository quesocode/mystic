//
//  MysticBackgroundsDataSource.m
//  Mystic
//
//  Created by Me on 5/5/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticBackgroundsDataSource.h"
#import "MysticImageAssetCell.h"

@implementation MysticBackgroundsDataSource

+ (NSString *) cellIdentifier;
{
    static NSString *cellIdentifier=@"MysticCollectionViewCellAssetImage";
    return cellIdentifier;
}

+ (Class) collectionItemClass;
{
    return [MysticAssetCollectionItem class];
}

+ (Class) cellClassForIdentifier:(NSString *)identifier;
{
    if([identifier isEqualToString:[[self class] sectionHeaderCellIdentifier]])
    {
        return [MysticCollectionSectionUnderHeader class];
    }
    return [MysticImageAssetCell class];
}

+ (NSString *) dataSourceURL;
{
    return MYSTIC_BACKGROUNDS_URL;
}

- (void) reloadDataInCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)startBlock ready:(MysticBlockObject)onReady  complete:(MysticBlockObjObjBOOL)finished;
{
    [self reloadDataWithKeys:@[@"items", @"items-gradients", @"items-colors"] start:startBlock complete:finished];
}
- (void) reloadDataWithKeys:(NSArray *)keys start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;
{

    
    NSString *urlStr = [[self class] dataSourceURL];
    
    if(hasBeenLoaded)
    {
        finished([NSArray arrayWithArray:self.items], nil, YES);
        return;
    }
    
    hasBeenLoaded = NO;
    //    [_items removeAllObjects];
    

    NSString *cachedPath = [[NSBundle mainBundle] pathForResource:@"backgrounds" ofType:@"plist"] ;
    
    __unsafe_unretained __block MysticBlockObjObjBOOL __finished = finished ? Block_copy(finished) : nil;

//    [MysticDictionaryDownloader removeCacheForURL:[NSURL URLWithString:urlStr]];
    __unsafe_unretained __block MysticCollectionViewDataSource *weakSelf = self;
    __unsafe_unretained __block NSArray *weakKeys = keys ? [keys retain] : nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [MysticDictionaryDownloader dictionaryWithURL:[NSURL URLWithString:urlStr] orDictionary:cachedPath state:^(id data, MysticDataState dataState) {
            
            

            NSArray *theItems=nil;
            if(dataState & MysticDataStateNew)
            {
                theItems  = [weakSelf itemsFromDictionary:data keys:weakKeys];
                if(__finished)
                {
                    __finished(theItems, nil, dataState & MysticDataStateComplete ? YES : NO);
                }
            }
            
            if(dataState & MysticDataStateComplete)
            {
                hasBeenLoaded = YES;
                [weakKeys release];
                if(__finished)
                {
                    Block_release(__finished);
                }
            }
            

        }];
    });

}


- (NSArray *) itemsWithKeys:(NSArray *)keys start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;
{
    __unsafe_unretained __block MysticBlockObjObjBOOL __finished = finished ? Block_copy(finished) : nil;

    return [self itemsWithKeys:keys dataBlock:^(id data, MysticDataState dataState) {
        if(dataState & MysticDataStateNew)
        {
            
            if(__finished)
            {
                __finished(data, @(dataState), dataState & MysticDataStateComplete ? YES : NO);
                if(dataState & MysticDataStateComplete)
                {
                    Block_release(__finished);
                }
            }
        }
    }];
}
- (NSArray *) itemsWithKeys:(NSArray *)keys dataBlock:(MysticBlockData)finished;
{
    NSString *urlStr = [[self class] dataSourceURL];

 
    hasBeenLoaded = NO;
//    [_items removeAllObjects];
    
    NSString *cachedPath = [[NSBundle mainBundle] pathForResource:@"backgrounds" ofType:@"plist"] ;
    
    __unsafe_unretained __block MysticBlockData __finished = finished ? Block_copy(finished) : nil;
//    [MysticDictionaryDownloader removeCacheForURL:[NSURL URLWithString:urlStr]];
    __unsafe_unretained __block MysticCollectionViewDataSource *weakSelf = self;
    __unsafe_unretained __block NSArray *weakKeys = keys ? [keys retain] : nil;
    
    
    
//    NSDictionary *localDict = [MysticDictionaryDownloader dictionaryWithURL:[NSURL URLWithString:urlStr] orDictionary:cachedPath state:!__finished ? nil : ^(id data, MysticDataState dataState)
//        {
////            
////            if(dataState & MysticDataStateNew && data && weakKeys && [data isKindOfClass:[NSDictionary class]])
////            {
////                
////                DLog(@"data:  %@  keys:  %@", data, weakKeys);
////                NSArray *theItems  = [weakSelf itemsFromDictionary:data keys:weakKeys];
////                if(__finished) __finished(theItems, dataState);                    
////            }
////            if(dataState & MysticDataStateComplete)
////            {
////                
////                if(__finished) Block_release(__finished);
////                if(weakKeys) { [weakKeys release]; weakKeys=nil; }
////            }
//        }];
    
    NSDictionary *localDict = [[[NSDictionary alloc] initWithContentsOfFile:cachedPath] autorelease];
    
//    DLog(@"localDict:  %@  |  %@", localDict, cachedPath);
    NSArray *items = [self itemsFromDictionary:localDict keys:[weakKeys autorelease]];
    return items && items.count ? items : nil;
    
}



- (NSArray *) itemsFromDictionary:(NSDictionary *)itemsInfo keys:(NSArray *)keys;
{

    if(!hasBeenLoaded && itemsInfo)
    {
        keys = keys != nil ? keys : itemsInfo.allKeys;
        hasBeenLoaded = YES;
        int x = 0;
        NSMutableArray *__items = [NSMutableArray array];
        NSMutableArray *itemsArray = [NSMutableArray array];
        for (NSString *key in keys) {
            [itemsArray addObjectsFromArray:([itemsInfo objectForKey:key] ? [itemsInfo objectForKey:key] : @[])];

        }

        for (NSDictionary *itemDict in itemsArray) {
            MysticAssetCollectionItem *theItem = [[[self class] collectionItemClass] itemWithDictionary:itemDict indexPath:[NSIndexPath indexPathForRow:x inSection:0]];
            if(!theItem.enabled) continue;
            [__items addObject:theItem];
            x++;
        }
        
        [self.items addObject:@{@"items":[NSArray arrayWithArray:__items]}];
    }
    return [NSArray arrayWithArray:self.items];
}

- (id) itemWithTag:(NSString *)lookupTag info:(NSDictionary *)itemInfo;
{
    if(!lookupTag) return nil;
    
    NSArray *collectionItems = [self itemsWithKeys:@[@"items-gradients", @"items-colors"] dataBlock:nil];
    
    
    for (MysticAssetCollectionItem *item in [[collectionItems lastObject] objectForKey:@"items"]) {
        if([item.tag isEqualToString:lookupTag])
        {
            return item;
        }
    }
    return nil;
    
    
}

@end
