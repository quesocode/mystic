//
//  MysticProject.m
//  Mystic
//
//  Created by travis weerts on 8/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticProject.h"
#import "MysticController.h"
#import "MysticAPI.h"
#import "MysticEffectsManager.h"
#import "UserPotion.h"

@implementation MysticProject

@synthesize info, options, sourceImageURL, projectID, object, fromDownload=_fromDownload, shareURL, effects, projectURL, isLoaded, isRecipe, name, details, hasBeenFeatured, hasBeenShared;

+ (MysticProject *) create;
{
    return nil;
}
- (void) feature:(MysticBlockObjBOOL)finished;
{
    [self feature:finished progress:nil];
}
- (void) feature:(MysticBlockObjBOOL)finished progress:(MysticBlockAPIUpload)progressBlock;
{
    [self share:@{@"featured":@"YES", @"community":@"NO", @"private":@"NO"} progress:progressBlock finished:finished];
}
- (void) share:(MysticBlockObjBOOL)finishedSaving;
{
    [self share:nil progress:nil finished:finishedSaving];
}
- (void) share:(MysticBlockObjBOOL)finished progress:(MysticBlockAPIUpload)progressBlock;
{
    [self share:nil progress:progressBlock finished:finished];

}
- (void) share:(NSDictionary *)userInfo progress:(MysticBlockAPIUpload)progressBlock finished:(MysticBlockObjBOOL)finishedSaving;
{
    NSString *pname = self.name;
    __unsafe_unretained MysticProject *weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            pname ? pname : [UserPotion potion].uniqueTag, @"name",
                            @"", @"description",
                            self.info, @"info",
                            @"NO", @"private",
                            @"YES", @"community",
                            @"NO", @"featured",
                            nil];
    
    if([MysticUser user].mysticUserId)
    {
        [params setObject:[MysticUser user].mysticUserId forKey:@"user_id"];
    }
    if(userInfo && userInfo.count)
    {
        for (NSString *userKey in [userInfo allKeys]) {
            [params setObject:[userInfo objectForKey:userKey] forKey:userKey];
        }
    }
    
    UIImage *previewImg = [userInfo objectForKey:@"thumbnail"] ? [userInfo objectForKey:@"thumbnail"] : [UIImage imageWithContentsOfFile:self.thumbnailFilePath];
    
    
    [MysticAPI upload:@"/potion/create" params:params uploads:nil progress:progressBlock complete:^(NSDictionary *results, NSError *error) {
        
        
        if(error)
        {
            if(finishedSaving) finishedSaving(nil, NO);
            return;
        }
        else
        {
            [[UserPotion potion].userInfoExtras addEntriesFromDictionary:results];
            
            
            NSMutableArray *uploads = [NSMutableArray array];
            NSMutableDictionary *pinfo = [NSMutableDictionary dictionaryWithDictionary:results];
            NSString *pid = [results objectForKey:@"id"];
            [pinfo setObject:[NSString stringWithFormat:@"http://i.mysti.ch/potions/%@/project.plist", pid] forKey:@"url"];
            [pinfo setObject:[NSString stringWithFormat:@"http://i.mysti.ch/potions/%@/preview.jpg", pid] forKey:@"preview"];
            [pinfo setObject:[NSString stringWithFormat:@"http://i.mysti.ch/potions/%@/preview_thumb.jpg", pid] forKey:@"thumbnail"];
            
            [pinfo setObject:[NSString stringWithFormat:@"http://i.mysti.ch/potions/%@/preview_thumb.jpg", pid] forKey:@"thumbnail"];
            
            UIImage *renderedPreviewImage = previewImg ? previewImg : [MysticEffectsManager renderedImage];
            
            if(!renderedPreviewImage)
            {
                if(finishedSaving) finishedSaving(nil, NO);
                return;
            }
            [renderedPreviewImage retain];
            
            NSData *imageData = UIImageJPEGRepresentation(renderedPreviewImage, 1);
            NSDictionary *previewUpload = [NSDictionary dictionaryWithObjectsAndKeys:
                                           imageData,@"data",
                                           @"preview.jpg", @"filename",
                                           @"preview", @"name",
                                           @"image/jpeg", @"mime",
                                           nil];
            [renderedPreviewImage release];
            
            
            [uploads addObject:previewUpload];
            PackPotionOptionCamLayer *camOption = (PackPotionOptionCamLayer *)[UserPotion confirmedOptionForType:MysticObjectTypeCamLayer];
            if(camOption)
            {
                [pinfo setObject:[NSString stringWithFormat:@"http://i.mysti.ch/potions/%@/camlayer.jpg", pid] forKey:@"camlayer"];
                NSData *data3 = [NSData dataWithContentsOfFile:camOption.originalLayerImagePath];
                NSDictionary *camUpload = [NSDictionary dictionaryWithObjectsAndKeys:
                                           data3,@"data",
                                           @"camlayer.jpg", @"filename",
                                           @"camlayer", @"name",
                                           @"image/jpeg", @"mime",
                                           nil];
                [uploads addObject:camUpload];
            }
            if(!pname)
            {
                [pinfo setObject:[NSString stringWithFormat:@"http://i.mysti.ch/potions/%@/source.jpg", pid] forKey:@"source"];
                UIImage *sourceImage = [UserPotion potion].sourceImage;
                NSData *imageData2 = UIImageJPEGRepresentation(sourceImage, 1);
                NSDictionary *sourceUpload = [NSDictionary dictionaryWithObjectsAndKeys:
                                              imageData2,@"data",
                                              @"source.jpg", @"filename",
                                              @"source", @"name",
                                              @"image/jpeg", @"mime",
                                              nil];
                [uploads addObject:sourceUpload];
                
            }
            
            NSString *uploadUri = [NSString stringWithFormat:@"/potion/upload/%@", [results objectForKey:@"id"] ? [results objectForKey:@"id"] : @""];
            [MysticAPI upload:uploadUri params:[NSDictionary dictionary] uploads:uploads progress:progressBlock complete:^(NSDictionary *results, NSError *error) {
                
                if(error)
                {
                    
                    if(finishedSaving) finishedSaving(results, NO);
                    return;
                }
                else
                {
                    [[UserPotion potion].userInfoExtras addEntriesFromDictionary:results];
                    
                    [self saveAs:pname image:previewImg finished:^(NSString *aprojectFilePath) {
                    
                        if(!aprojectFilePath)
                        {
                            [renderedPreviewImage release];
                            if(finishedSaving) finishedSaving(nil, NO);
                            return;
                        }
                        NSData *data2 = [NSData dataWithContentsOfFile:aprojectFilePath];
                        if(!data2)
                        {
                            [renderedPreviewImage release];
                            if(finishedSaving) finishedSaving(nil, NO);
                            return;
                        }
                        NSDictionary *projectUpload = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       data2, @"data",
                                                       @"project.plist", @"filename",
                                                       @"file", @"name",
                                                       @"application/xml", @"mime",
                                                       nil];
                        
                        
                        [MysticAPI upload:uploadUri params:[NSDictionary dictionary] uploads:[NSArray arrayWithObject:projectUpload] progress:progressBlock complete:^(NSDictionary *results, NSError *error) {
                            
                            
                            if(error)
                            {
                                if(finishedSaving) finishedSaving(results, NO);
                                return;
                            }
                            else
                            {
                                
                                [weakSelf setObject:[NSNumber numberWithBool:YES] forKey:@"__shared"];
                                
                                if([[params objectForKey:@"featured"] isEqualToString:@"YES"])
                                {
                                    [weakSelf setObject:[NSNumber numberWithBool:YES] forKey:@"__featured"];
                                }
                                
                                [weakSelf save];
                                MysticProject *project = [MysticProject projectFromFile:aprojectFilePath];
                                if(finishedSaving) finishedSaving(project, YES);
                            }
                        }];
                        
                    }];
                }
            }];
            
        }
        
    }];
    
    return;
}




+ (void) openProjectWithId:(NSString *)projectId info:(NSDictionary *)options complete:(MysticBlockObjBOOL)finished;
{
    [MysticAPI get:[@"/potion/" stringByAppendingString:projectId] params:nil complete:^(NSDictionary *results, NSError *error) {
        if([results objectForKey:@"url"])
        {
            [MysticProject openProjectWithUrl:[results objectForKey:@"url"] info:options complete:finished];
        }
    }];
}
+ (void) openProjectWithUrl:(NSString *)projectUrl info:(NSDictionary *)options complete:(MysticBlockObjBOOL)finished;
{
    //    [self showHUD:@"Loading Project..." checked:NO];
    [[MysticProject projectWithURL:projectUrl] load:^(MysticProject *obj, BOOL success) {
        
        
        if(success)
        {
            [obj open:finished];
            
        }
        else
        {
            if(finished) finished(obj, NO);
            
        }
    }];

    
}

+ (MysticProject *) projectWithURL:(NSString *)url;
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:url forKey:@"url"];
    return [self project:dict];
}
+ (MysticProject *) projectFromFile:(NSString *)filePath;
{
    NSDictionary *dict = [[[NSDictionary alloc] initWithContentsOfFile:filePath] autorelease];
    return [self project:dict];
}
+ (MysticProject *) project:(NSDictionary *)theInfo;
{
    return [[[MysticProject alloc] initWithInfo:theInfo] autorelease];
}

- (void) dealloc;
{
    [info release];
    [options release];
    
    [super dealloc];
}
- (id) initWithInfo:(NSDictionary *)theInfo;
{
    self = [super init];
    if(self)
    {
        self.fromDownload = NO;
        self.info = theInfo;
    }
    return self;
}
- (NSString *) shareURL;
{

    return [NSString stringWithFormat:@"http://mysti.ch/potion/%@", [self.object objectForKey:@"hash"] ? [self.object objectForKey:@"hash"] : self.projectID];
}
- (NSString *) sourceImageURL;
{
    if([self.object objectForKey:@"source"]) return [self.object objectForKey:@"source"];
    return [self.info objectForKey:@"sourceImageURL"];
}
- (NSString *) previewURL;
{
    return [self.object objectForKey:@"preview"];
}
- (NSString *) details;
{
    NSString *d = [self.object objectForKey:@"description"];
    d = [d isEqualToString:@""] ? nil : d;
    return d;
}
- (MysticOptions *) optionsObject;
{
    if([self.info objectForKey:@"data"] && [[self.info objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
    {
        return [MysticOptions optionsFromProject:[MysticUser prepareProjectForRead:[self.info objectForKey:@"data"]]];
    }
    return nil;
}
- (BOOL) hasBeenFeatured;
{
    if([self.info objectForKey:@"__featured"])
    {
        return YES;
    }
    return NO;
}
- (BOOL) hasBeenShared;
{
    if([self.info objectForKey:@"__shared"])
    {
        return YES;
    }
    return NO;
}
- (NSString *) name;
{
    return [self.object objectForKey:@"name"];
}

- (void) setName:(NSString *)value;
{
    NSMutableDictionary *__info = [NSMutableDictionary dictionaryWithDictionary:self.info];
    [__info setObject:value forKey:@"name"];
    NSMutableDictionary *__object = [NSMutableDictionary dictionaryWithDictionary:self.object ? self.object : [NSDictionary dictionary]];
    [__object setObject:value forKey:@"name"];
    [__info setObject:__object forKey:@"project"];
    
    self.info = [NSDictionary dictionaryWithDictionary:__info];
}
- (NSString *) projectURL;
{
    return [self.object objectForKey:@"url"];
}
- (NSString *) projectFilePath;
{
    return [self.info objectForKey:@"file"];
}
- (NSString *) thumbnailFilePath;
{
    return [self.info objectForKey:@"thumbnail"];
}
- (NSString *) thumbnailURL;
{
    return [self.object objectForKey:@"thumbnail"];
}

- (NSDictionary *) object;
{
    return [self.info objectForKey:@"project"] ? [self.info objectForKey:@"project"] : self.info;
}

- (NSString *) projectID;
{
    return (self.object) ? [self.object objectForKey:@"id"] : nil;
}

- (NSArray *)effects;
{
    return [self.info objectForKey:@"effects"] ? [self.info objectForKey:@"effects"] : [NSArray array];
}
- (BOOL) isLoaded;
{
    return self.projectID && [self.info objectForKey:@"effects"] ? YES : NO;
}
- (void) load:(MysticBlockObjBOOL)loaded;
{
    if(self.isLoaded)
    {
        if(loaded) loaded(self, YES);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        if(self.projectFilePath)
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:self.projectFilePath] == YES) {
                NSDictionary *obj = [NSDictionary dictionaryWithContentsOfFile:self.projectFilePath];
                self.info = obj;
                self.fromDownload = NO;
                self.isLoaded = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(loaded) loaded(self, YES);
                });
                return;
            }
            else
            {
                if(loaded) loaded(@"The project file does not exist", NO);
                return;

            }
        }
        if(!self.projectURL)
        {
            if(loaded) loaded(@"There is no project file or URL to load", NO);
            return;
        }
        [MysticAPI dictionaryFromURL:self.projectURL finished:^(NSDictionary *obj, BOOL success) {
            if(success)
            {
                
                self.info = obj;
                self.fromDownload = YES;
                self.isLoaded = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(loaded) loaded(self, YES);
                });
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(loaded) loaded(self, NO);
                });
                
            }
            
            
        }];
    });
}

- (void) open:(MysticBlockObjBOOL)finished;
{
    [self load:^(id obj, BOOL success) {
        if(success)
        {
            [UserPotion openProject:self finished:^(id obj, BOOL success) {
                
                if(finished) finished(self, success);
                
                
            }];
        }
        else
        {
            finished(self, NO);
        }
    }];
    
}
- (void) delete:(MysticBlockBOOL)finished;
{
    NSString *thumbPath = self.thumbnailFilePath;
    NSString *auserInfoPath = self.projectFilePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    
    id deleteProject = nil;
    for (NSString *projectPath in [MysticUser user].potionPaths)
    {
        if([projectPath isEqualToString:auserInfoPath])
        {
            deleteProject = projectPath;
            break;
        }
    }
    
    if(!deleteProject)
    {
        for (NSString *projectPath in [MysticUser user].potionPaths)
        {
            if (![fileManager fileExistsAtPath:projectPath]) {
                deleteProject = projectPath;
            }

        }
    }
    
    if(deleteProject)
    {
        NSMutableArray *n = [NSMutableArray arrayWithArray:[MysticUser user].potionPaths];
        [n removeObject:deleteProject];
        [[MysticUser user] setPotions:[NSArray arrayWithArray:n]];
    }
    
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:auserInfoPath] == YES) {
        [fileManager removeItemAtPath:auserInfoPath error:&error];
        if(error)
        {
            if(finished) finished(NO);
            return;
        }
    }
    NSError *error2 = nil;

    if ([fileManager fileExistsAtPath:thumbPath] == YES) {
        [fileManager removeItemAtPath:thumbPath error:&error2];
        if(error2)
        {
            DLog(@"there was an error deleting the thumb for project");
            if(finished) finished(NO);
            return;
        }
    }
    
    
    if(finished)
    {
        finished(YES);
    }
}
+ (void)saveAs:(NSString *)newName image:(UIImage *)thumbnail finished:(MysticBlockString)finished;
{
    __block __unsafe_unretained UIImage *_thumbnail = thumbnail;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSMutableDictionary *_info = [NSMutableDictionary dictionaryWithDictionary:[UserPotion userInfo]];
        [_info setObject:newName forKey:@"name"];
        MysticProject *proj = [MysticProject project:_info];
        
        if (proj) {
            _thumbnail = _thumbnail ? _thumbnail : [MysticEffectsManager renderedPreviewImage];
            [_thumbnail retain];
            [proj saveAs:newName image:_thumbnail finished:finished];
            [_thumbnail release];
        }
        else
        {
            if(finished) finished(nil);
        }
    });
}
- (void) save;
{
    [self saveAs:self.name image:nil finished:nil];
}
- (void)saveAs:(NSString *)newName image:(UIImage *)thumbnail finished:(MysticBlockString)finished;
{
    __block __unsafe_unretained UIImage *_thumbnail = thumbnail ? [thumbnail retain] : nil;
    __block __unsafe_unretained MysticProject *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        weakSelf.name = newName;
        NSMutableDictionary *_info = [NSMutableDictionary dictionaryWithDictionary:weakSelf.info];
        [_info setObject:newName forKey:@"name"];
        
        if (_info) {
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error=nil;
            
            NSString *userInfoFilename = [NSString stringWithFormat:@"/potion-%@.plist", newName];
            NSString *auserInfoPath = [[Mystic configDirSubPath:@"userPotions"] stringByAppendingString:userInfoFilename];
            [_info setObject:auserInfoPath forKey:@"file"];

            if(_thumbnail)
            {
            
                NSData *imgData = UIImageJPEGRepresentation(_thumbnail, 1);
                
                NSString *prjThumbFilename = [NSString stringWithFormat:@"/potion-%@-thumbnail.jpg", newName];
                
                
                NSString *thumbPath = [[Mystic configDirSubPath:@"userPotions"] stringByAppendingString:prjThumbFilename];
                [_info setObject:thumbPath forKey:@"thumbnail"];
                
                
                if ([fileManager fileExistsAtPath:thumbPath] == YES) {
                    [fileManager removeItemAtPath:thumbPath error:&error];
                    if(error != nil)
                    {
                        DLog(@"Save Potion Remove Existing THUMB Error: %@", error.debugDescription);
                        if(finished) finished(nil);
                        return;
                    }
                }
                
                BOOL thumbsaved =  [imgData writeToFile:thumbPath atomically:YES];
                [_thumbnail release];
                if(!thumbsaved)
                {
                    DLog(@"Save Potion Saving THUMB Error: Unable to save thumbnail image: %@", thumbPath);

                    if(finished) finished(nil);
                    return;
                }
                
            }
            
            NSError *error2=nil;

            if ([fileManager fileExistsAtPath:auserInfoPath] == YES) {
                [fileManager removeItemAtPath:auserInfoPath error:&error2];
                if(error2 != nil)
                {
                    DLog(@"Save Potion Remove Existing Info Error: %@", error2.debugDescription);
                    if(finished) finished(nil);
                    return;
                }
            }
            
            BOOL saved = [_info writeToFile:auserInfoPath atomically:YES];
            if(!saved)
            {
                DLog(@"Save Potion Saving Project Error: Unable to save project file: %@", auserInfoPath);
                if(finished) finished(nil);
                return;
            }
            if(finished) finished(auserInfoPath);
        }
        
    });
}

- (void) setObject:(id)value forKey:(id<NSCopying>)aKey;
{
    NSMutableDictionary *m = [NSMutableDictionary dictionaryWithDictionary:self.info];
    [m setObject:value forKey:aKey];
    self.info = [NSDictionary dictionaryWithDictionary:m];
}


@end
