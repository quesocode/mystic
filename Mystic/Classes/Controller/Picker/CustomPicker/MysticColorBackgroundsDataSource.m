//
//  MysticColorBackgroundsDataSource.m
//  Mystic
//
//  Created by Me on 5/5/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticColorBackgroundsDataSource.h"
#import "MysticColorBackgroundCell.h"
#import "MysticAssetCollectionItem.h"
#import "Mystic.h"
#import "UIColor+Mystic.h"

@implementation MysticColorBackgroundsDataSource

+ (NSString *) cellIdentifier;
{
    static NSString *cellIdentifier=@"MysticCollectionViewCellAssetColorImage";
    return cellIdentifier;
}

+ (Class) collectionItemClass;
{
    return [MysticAssetCollectionItem class];
}

+ (Class) cellClassForIdentifier:(NSString *)identifier;
{
    return [MysticColorBackgroundCell class];
}

+ (NSString *) dataSourceURL;
{
    return MYSTIC_COLOR_BACKGROUNDS_URL;
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        hasBeenLoaded = NO;
    }
    return self;
}

- (void) reloadDataInCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)startBlock ready:(MysticBlockObject)onReady  complete:(MysticBlockObjObjBOOL)finished;
{
    
    NSString *urlStr = [[self class] dataSourceURL];
    
    if(hasBeenLoaded)
    {
        finished([NSArray arrayWithArray:self.items], nil, YES);
        return;
    }
    
    hasBeenLoaded = NO;
//    [_items removeAllObjects];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *cachedPath = [[NSBundle mainBundle] pathForResource:@"colors" ofType:@"plist"] ;
        __unsafe_unretained __block MysticBlockObjObjBOOL __finished = finished ? Block_copy(finished) : nil;
        [MysticDictionaryDownloader removeCacheForURL:[NSURL URLWithString:urlStr]];
        __unsafe_unretained __block MysticCollectionViewDataSource *weakSelf = self;
        [MysticDictionaryDownloader dictionaryWithURL:[NSURL URLWithString:urlStr] orDictionary:cachedPath state:^(id data, MysticDataState dataState) {
            
            BOOL success = !(dataState & MysticDataStateError);
            
            NSArray *theItems = [weakSelf itemsFromDictionary:data];
            hasBeenLoaded = success ? YES : hasBeenLoaded;
            if(dataState & MysticDataStateComplete)
            {
                if(__finished)
                {
                    __finished(theItems, nil, success);
                    Block_release(__finished);
                }
            }
        }];
        
    });
}

- (NSArray *) itemsFromDictionary:(NSDictionary *)itemsInfo;
{
    if(!hasBeenLoaded && itemsInfo)
    {
        hasBeenLoaded = YES;
        NSMutableArray *__items = [NSMutableArray array];
        NSArray *itemsArray = [itemsInfo objectForKey:@"items"] ? [itemsInfo objectForKey:@"items"] : @[];
        int x = 0;
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


@end
