//
//  MysticInstagramAPI.h
//  Mystic
//
//  Created by travis weerts on 9/12/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mystic.h"
#import "MysticInstagramPhoto.h"

@interface MysticInstagramAPI : NSObject

+ (void) photosForTag:(NSString *)tagName finished:(MysticBlockObjBOOL)finished;
+ (void) get:(NSString *)uri params:(NSDictionary *)params complete:(MysticBlockAPI)completed;
+ (void) recentPhotos:(MysticBlockObjBOOL)finished;
+ (void) openTagInInstagram:(NSString *)tagName;
+ (void) openMediaInInstagram:(NSString *)mediaId;
+ (void) openUserInInstagram:(NSString *)username;
+ (void) openLocationInInstagram:(NSString *)locationId;

+ (BOOL) hasInstagramApp;



@end
