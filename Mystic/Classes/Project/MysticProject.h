//
//  MysticProject.h
//  Mystic
//
//  Created by travis weerts on 8/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"

@class MysticOptions;

@interface MysticProject : NSObject

@property (nonatomic, retain) NSDictionary *info, *options;
@property (nonatomic, readonly) NSDictionary *object;
@property (nonatomic, readonly) MysticOptions *optionsObject;
@property (nonatomic, assign) BOOL fromDownload, useCurrentSourceImage, isLoaded, isRecipe, hasBeenFeatured, hasBeenShared;
@property (nonatomic, assign) NSString *name;
@property (nonatomic, readonly) NSString *sourceImageURL, *projectID, *shareURL, *thumbnailURL, *previewURL, *projectURL,  *details, *projectFilePath, *thumbnailFilePath;
@property (nonatomic, readonly) NSArray *effects;

+ (void) openProjectWithId:(NSString *)projectId info:(NSDictionary *)options complete:(MysticBlockObjBOOL)finished;
+ (void) openProjectWithUrl:(NSString *)projectUrl info:(NSDictionary *)options complete:(MysticBlockObjBOOL)finished;

+ (MysticProject *) create;
+ (MysticProject *) project:(NSDictionary *)theInfo;
+ (MysticProject *) projectWithURL:(NSString *)url;
+ (MysticProject *) projectFromFile:(NSString *)filePath;
- (void) open:(MysticBlockObjBOOL)finished;
- (void) load:(MysticBlockObjBOOL)loaded;
- (void) share:(MysticBlockObjBOOL)finished;
- (void) share:(MysticBlockObjBOOL)finished progress:(MysticBlockAPIUpload)progressBlock;
- (void) share:(NSDictionary *)userInfo progress:(MysticBlockAPIUpload)progressBlock finished:(MysticBlockObjBOOL)finishedSaving;
- (void) feature:(MysticBlockObjBOOL)finished;
- (void) feature:(MysticBlockObjBOOL)finished progress:(MysticBlockAPIUpload)progressBlock;
- (void) save;
- (void)saveAs:(NSString *)name image:(UIImage *)thumbnail finished:(MysticBlockString)finished;
+ (void)saveAs:(NSString *)name image:(UIImage *)thumbnail finished:(MysticBlockString)finished;
- (void) delete:(MysticBlockBOOL)finished;
- (void) setObject:(id)value forKey:(id<NSCopying>)aKey;

@end


