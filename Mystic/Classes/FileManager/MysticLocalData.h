//
//  MysticDownloadManager.h
//  Mystic
//
//  Created by travis weerts on 8/20/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"

@interface MysticLocalData : NSObject

@property (nonatomic, retain) NSMutableDictionary *data, *layers, *urls, *packs;
@property (nonatomic, retain) NSMutableArray *finishedKeys, *keys;
@property (nonatomic, assign) BOOL downloadThumb, downloadImage, downloadMask, downloadOriginal, downloadPreview;
@property (nonatomic, retain) id currentKey, typeKey;

@property (nonatomic, copy) MysticBlockObject finished;
+ (void) data:(MysticDictionary *)data finished:(MysticBlockObject)finished;
+ (instancetype) manager;


@end
