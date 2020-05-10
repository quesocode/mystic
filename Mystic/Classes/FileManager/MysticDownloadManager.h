//
//  MysticDownloadManager.h
//  Mystic
//
//  Created by travis weerts on 8/20/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"

@interface MysticDownloadManager : NSObject

+ (MysticDownloadManager *)sharedManager;

- (void) stopDownloader;
- (NSInteger) numberOfEffects;
- (NSArray *) imageURLSToDownload;
- (void) downloadEffects:(void (^)(NSUInteger, NSUInteger, BOOL))completionBlock;
- (void) downloadImage:(NSString *)url block:(void (^)(NSUInteger, NSUInteger, BOOL))block;
- (void) resumeDownloader;
- (void) resetDownloader;

@end
