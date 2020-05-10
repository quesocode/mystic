//
//  MysticAlbumDataSource.h
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionViewDataSource.h"
#import "MysticAssetCollectionItem.h"
#import "MysticCollectionSectionUnderHeader.h"

@interface MysticAlbumDataSource : MysticCollectionViewDataSource
@property (nonatomic, assign) BOOL reversePhotos, reverseAlbums;
@property (nonatomic, retain) ALAssetsGroup *album;

- (void) albums:(MysticBlockObjObjBOOL)block;

@end
