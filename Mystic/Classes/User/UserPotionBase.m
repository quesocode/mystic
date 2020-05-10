//
//  UserPotionBase.m
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//
#import <objc/message.h>
#import <dispatch/dispatch.h>
#import "UserPotionBase.h"
#import "UIColor+Mystic.h"
#import "NSTimer+Blocks.h"
#import "MysticSettingsController.h"
#import "MysticEffectsManager.h"
#import "PackPotionOptionSetting.h"
#import "MysticConfigManager.h"
#import "MysticAPI.h"
#import "MysticController.h"
#import "SDWebImageManager.h"
#import "MysticCore.h"
#import "MysticOptions.h"


@interface UserPotionBase ()
{
    dispatch_queue_t backgroundQueue;
    NSString *lastRenderTag;
    NSArray *targets;
    BOOL changed;
    CGSize sourceSize;
    int highestCachedLevel;
    NSMutableIndexSet *cachedLevels, *activeLevels;
    GPUImageOutput<GPUImageInput> *lastOutputImage;
    NSMutableArray *renderQueue, *tempOutputs, *_layers;
    BOOL queueRunning, _isSavingImage;
    NSDictionary *activeParams;
    NSUInteger activeQueueIndex;
    NSMutableDictionary *_sourceTransforms;
}

@property (nonatomic, readonly) NSInteger historyIndexZero;
@end


static NSUInteger highestReloadIndex=0;
@implementation UserPotionBase

@synthesize effects=_effects, tint=_tint,
sourceImagePath=_sourceImagePath,
sourceImageResizedPath=_sourceImageResizedPath,
originalImagePath=_originalImagePath,
sourceImageURL=_sourceImageURL,
originalImageTag,
sourceImageTag,
sourceImageResizedTag,
tag=_tag,
layers,
userInfo,
originalImage=_originalImage,
cropRect=_cropRect,
flipHorizontal=_flipHorizontal,
flipVertical=_flipVertical,
applySettingsFirst=_applySettingsFirst,
applyFilterToTexture=_applyFilterToTexture,
applyFilterToBadge=_applyFilterToBadge,
applyFilterToLight=_applyFilterToLight,
applyFilterToFrame=_applyFilterToFrame,
applyFilterToText=_applyFilterToText,
applySunshineToFilter=_applySunshineToFilter,
sourceImageSize=_sourceImageSize,
lastSettingsResult, currentSettingsResult,
textOption=_textOption,
frameOption=_frameOption,
textureOption=_textureOption,
badgeOption=_badgeOption,
filterOption=_filterOption,
maskOption=_maskOption,
whiteLevels=_whiteLevels,
blackLevels=_blackLevels,
haze=_haze,
unsharpMask=_unsharpMask,
previewOptionBadge=_previewOptionBadge,
previewOptionFilter=_previewOptionFilter,
previewOptionFrame=_previewOptionFrame,
previewOptionLight=_previewOptionLight,
previewOptionMask=_previewOptionMask,
previewOptionText=_previewOptionText,
previewOptionTexture=_previewOptionTexture,
previewOptionSettings=_previewOptionSettings,
settingsOption=_settingsOption,
media=_media,
invertBadgeColor=_invertBadgeColor,
invertTextColor=_invertTextColor,
invertTextureColor=_invertTextureColor,
invertFrameColor=_invertFrameColor,
invertLightColor=_invertLightColor,
lightOption=_lightOption,
delegate=_delegate,
frameAlpha=_frameAlpha,
vignetteValue=_vignetteValue,
sourceImage=_sourceImage,
sourceImageResized=_sourceImageResized,
brightness=_brightness,
temperature=_temperature,
tiltShift=_tiltShift,
colorAlpha=_colorAlpha,
finalImage=_finalImage,
renderedOptions = _renderedOptions,
cachedLayerImages=_cachedLayerImages,
gamma=_gamma,
exposure=_exposure,
lastCachedImg=_lastCachedImg,
lastCachedLevel=_lastCachedLevel,
editingType=_editingType,
badgeColor=_badgeColor,
textColor=_textColor,
frameRotation=_frameRotation,
textureRotation=_textureRotation,
moreSettingsToggled=_moreSettingsToggled,
lightRotation=_lightRotation,
badgeRotation=_badgeRotation,
textRotation=_textRotation,
maskRotation=_maskRotation,
camLayerOption=_camLayerOption,
transformCamLayerRect=_transformCamLayerRect,
camLayerRotation=_camLayerRotation,
applyFilterToCamLayer=_applyFilterToCamLayer,
invertCamLayerColor=_invertCamLayerColor,
camLayerAlpha=_camLayerAlpha,
rotation=_rotation,
frameBackgroundColor=_frameBackgroundColor,
textureAlpha=_textureAlpha, lightingAlpha=_lightingAlpha, textAlpha=_textAlpha,
transformRect=_transformRect, transformBadgeRect=_transformBadgeRect, transformTextRect=_transformTextRect, contrast=_contrast, shadows=_shadows, highlights=_highlights, saturation=_saturation, sharpness=_sharpness, vignetteStart=_vignetteStart, vignetteEnd=_vignetteEnd, badgeAlpha=_badgeAlpha, transformMaskRect=_transformMaskRect, mode=_mode,
uniqueTag=_uniqueTag,
rgb;

static UserPotionBase *UserPotionInstance = nil;
static BOOL ignoreChanges = NO;
static CGRect kDefaultTransform;
static NSString *userInfoPath = nil;
static NSMutableDictionary *projects = nil;

- (void) dealloc
{
    [self setDefaults];
    self.imagePicture = nil;
    self.renderedOptions = nil;
    self.cachedLayerImages = nil;
    self.sourceImageURL = nil;
    self.userInfoExtras = nil;
    self.tag = nil;
    [_uniqueTag release], _uniqueTag = nil;
    [cachedLevels release], cachedLevels=nil;
    [super dealloc];
}

+ (UserPotionBase *) potion
{
    if(!UserPotionInstance) UserPotionInstance = [[[self class] alloc] init];
    return UserPotionInstance;
}



- (id) init
{
    self = [super init];
    if(self)
    {
        NSUserDefaults *userChoices = [NSUserDefaults standardUserDefaults];
        MysticMode currentMode = [userChoices objectForKey:@"mysticMode"] ? [userChoices integerForKey:@"mysticMode"] : MysticModeOff;
        self.mode = currentMode;
        changed = NO;
        highestReloadIndex = 0;
        queueRunning = NO;
        _editingType = MysticSettingNone;
        _moreSettingsToggled = NO;
        _sourceTransforms = [[NSMutableDictionary dictionary] retain];
        renderQueue = [[NSMutableArray array] retain];
        _layers = [[NSMutableArray array] retain];
        _previewSize = [MysticUI screen];
        kDefaultTransform = CGRectMake(0,0,1.0f,1.0f);
        self.rgb = (GPUVector3){1.0f,1.0f,1.0f};
        self.history = [NSMutableArray array];
        self.historyIndex = NSNotFound;
        self.historyChangeIndex = 0;
        self.userInfoExtras = [NSMutableDictionary dictionary];
        self.renderSize = CGSizeZero;
        self.invertFrameColor = NO;
        self.invertTextColor = NO;
        self.invertBadgeColor = NO;
        self.invertTextureColor = NO;
        self.invertLightColor = NO;
        self.applyFilterToText = kApplyFilterToText;
        self.applyFilterToTexture = kApplyFilterToTexture;
        self.applyFilterToBadge = kApplyFilterToBadge;
        self.applyFilterToFrame = kApplyFilterToFrame;
        self.applyFilterToLight = kApplyFilterToLight;
        self.applySunshineToFilter = kApplySunshineToFilter;
        self.applySettingsFirst = kApplySettingsFirst;
        self.applyFilterToCamLayer = kApplyFilterToCamLayer;
        self.renderedOptions = [[[NSMutableDictionary alloc] init] autorelease];
        self.sourceImageSize = CGSizeZero;
        lastSettingsResult = kNoSettingsApplied;
        cachedLevels = [[NSMutableIndexSet alloc] init];
        self.uniqueTag = [@"proj-" stringByAppendingString:[Mystic randomHash]];
    }
    return self;
}
- (void) setUniqueTag:(NSString *)uniqueTag;
{
    if(_uniqueTag && [uniqueTag isEqualToString:_uniqueTag]) return;
    [_uniqueTag release], _uniqueTag=nil;
    if(uniqueTag) _uniqueTag = [uniqueTag retain];
    if([MysticOptions current]) [MysticOptions current].projectName = uniqueTag;
}
#pragma mark - History

+ (NSInteger) numberOfHistoryItems; { return [[self class] potion].history.count; }
+ (void) addHistoryItem:(NSDictionary *)item;
{
    if(item) {
        if([[self class] potion].historyIndex != NSNotFound && [[self class] potion].historyIndex+1 < [[self class] numberOfHistoryItems]) {
            [[[self class] potion].history removeObjectsInRange:NSMakeRange([[self class] potion].historyIndex+1, [[self class] numberOfHistoryItems] - ([[self class] potion].historyIndex+1))];
        }
        [[[self class] potion].history addObject:item];
        [[self class] potion].historyIndex = [[[self class] potion].history indexOfObject:item];
        [[self class] potion].historyChangeIndex += 1;
        [[NSNotificationCenter defaultCenter] postNotificationName:kMysticUndoRedoChangedNotification object:item];

        return;
    }
    [[self class] potion].historyIndex = ([[self class] potion].historyIndex < 0 || [[self class] potion].historyIndex == NSNotFound ? -1 : [[self class] potion].historyIndex)+1;
    [[self class] potion].historyChangeIndex += 1;
    if(item) [[NSNotificationCenter defaultCenter] postNotificationName:kMysticUndoRedoChangedNotification object:item];
    
    

}
+ (NSDictionary *) topHistoryItem; { return [[self class] potion].history.lastObject; }

+ (NSDictionary *) currentHistoryItem;
{
    return [[self class] historyItemAtIndex:[[self class] potion].historyIndex];
}
+ (NSDictionary *) historyItemAtHistoryIndex:(NSInteger)i;
{
    return [[self class] historyItemAtIndex:i-1];
}
+ (UIImage *) historySourceImageAndResized:(BOOL)resized;
{
    return [[self class] historyImageAtIndex:0 resized:resized];
}
+ (UIImage *) historyImageAtIndex:(NSInteger)index resized:(BOOL)useResized;
{
    NSDictionary *item = [[self class] historyItemAtIndex:index];
    if(!item) return nil;
    
    NSString *sourceImagePath = [[UserPotionManager projectPath] stringByAppendingPathComponent:item[@"source"]];
    NSString *sourceImageResizedPath = [[UserPotionManager projectPath] stringByAppendingPathComponent:item[@"resized"]];

    return [UIImage imageWithContentsOfFile:useResized ? sourceImageResizedPath : sourceImagePath];
}

+ (NSDictionary *) historyItemAtIndex:(NSInteger)index;
{
    if(index == NSNotFound || index < 0 || [[self class] numberOfHistoryItems] == 0 || index > [[self class] numberOfHistoryItems]-1) return nil;
    return [[[self class] potion].history objectAtIndex:index];
}
+ (NSInteger) indexOfHistoryItemBefore:(id)item;
{
    if(!item) return NSNotFound;
    NSInteger i = [[[self class] potion].history indexOfObject:item];
    return i == NSNotFound ? NSNotFound : i == 0 ? NSNotFound : i-1;
}
+ (NSInteger) indexOfHistoryItem:(id)item;
{
    if(!item) return NSNotFound;
    NSInteger i = [[[self class] potion].history indexOfObject:item];
    return i == NSNotFound ? NSNotFound : i;
}
+ (NSInteger) indexOfHistoryItemAfter:(id)item;
{
    if(!item) return NSNotFound;
    NSInteger i = [[[self class] potion].history indexOfObject:item];
    return i == NSNotFound ? NSNotFound : i == [[self class] numberOfHistoryItems]-1 ? NSNotFound : i+1;
}
+ (NSDictionary *) useNextHistoryItem;
{
    NSDictionary *item = [[self class] nextHistoryItem];
    if(!item) return nil;
    [[self class] potion].historyIndex = [[[self class] potion].history indexOfObject:item];
    
    NSString *sourceImagePath = [[UserPotionManager projectPath] stringByAppendingPathComponent:item[@"source"]];
    NSString *sourceImageResizedPath = [[UserPotionManager projectPath] stringByAppendingPathComponent:item[@"resized"]];
    
    [[self class] potion].sourceImagePath = sourceImagePath;
    [[self class] potion].sourceImageResizedPath = sourceImageResizedPath;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMysticUndoRedoChangedNotification object:nil];
    return item;
}
+ (NSDictionary *) useLastHistoryItem;
{
    NSDictionary *item = [[self class] currentHistoryItem];
    NSInteger i = [[self class] indexOfHistoryItemBefore:item];
    
    
    if(!item || i==NSNotFound) return nil;
    
    [[self class] potion].historyIndex = i;
    item = [[self class] historyItemAtIndex:i];
    if(!item) return nil;
    
    NSString *sourceImagePath = [[UserPotionManager projectPath] stringByAppendingPathComponent:item[@"source"]];
    NSString *sourceImageResizedPath = [[UserPotionManager projectPath] stringByAppendingPathComponent:item[@"resized"]];
    
    [[self class] potion].sourceImagePath = sourceImagePath;
    [[self class] potion].sourceImageResizedPath = sourceImageResizedPath;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMysticUndoRedoChangedNotification object:nil];
    
    return item;
}

+ (NSDictionary *) useCurrentHistoryItem;
{
    NSDictionary *item = [[self class] currentHistoryItem];
    NSInteger i = [[self class] indexOfHistoryItem:item];
    
    
    if(!item) return nil;
    
    NSString *sourceImagePath = [[UserPotionManager projectPath] stringByAppendingPathComponent:item[@"source"]];
    NSString *sourceImageResizedPath = [[UserPotionManager projectPath] stringByAppendingPathComponent:item[@"resized"]];
    
    [[self class] potion].sourceImagePath = sourceImagePath;
    [[self class] potion].sourceImageResizedPath = sourceImageResizedPath;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMysticUndoRedoChangedNotification object:nil];
    
    return item;
}

+ (NSDictionary *) lastHistoryItem;
{
    if([[self class] numberOfHistoryItems] < 1 || [[self class] potion].historyIndex < 0) return nil;
    return [[self class] historyItemAtIndex:MIN([[self class] numberOfHistoryItems]-1, MAX(0,[[self class] potion].historyIndex - 1))];
}

+ (NSDictionary *) nextHistoryItem;
{
    if([[self class] numberOfHistoryItems] < 1 || [[self class] potion].historyIndex + 1 >= [[self class] numberOfHistoryItems]) return nil;
    return [[self class] historyItemAtIndex:MIN([[self class] numberOfHistoryItems]-1,MAX(0,[[self class] potion].historyIndex + 1))];
}

+ (void) removeLastHistoryItem;
{
    if(![[self class] numberOfHistoryItems]) return;
    [[[self class] potion].history removeLastObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMysticUndoRedoChangedNotification object:nil];

}
- (NSInteger) historyIndexZero; { return self.historyIndex == NSNotFound || self.historyIndex < 0 ? 0 : self.historyIndex; }
+ (void) resetHistory:(NSArray *)history; {
    [[self class] clearHistory];
    if(history && [history isKindOfClass:[NSArray class]]) [[[self class] potion].history addObjectsFromArray:history];
}

+ (void) clearHistory; {
    [[[self class] potion].history removeAllObjects];
    [[self class] potion].historyIndex = NSNotFound;
    [[self class] potion].historyChangeIndex = 0;

}
+ (BOOL) hasHistory;
{
    return [[self class] potion].history.count > 1;
}

+ (BOOL) canUndo;
{
    return [self hasPreviousHistory];
}
+ (BOOL) canRedo;
{
    return [self hasNextHistory];
}
+ (BOOL) hasPreviousHistory;
{
    return [[self class] potion].historyIndex != NSNotFound && [[self class] potion].historyIndex > 0 && [[self class] numberOfHistoryItems] > 1;
}

+ (BOOL) hasNextHistory;
{
    return [[self class] numberOfHistoryItems] > 1 && [[self class] potion].historyIndex != NSNotFound && ([[self class] numberOfHistoryItems]-1) > [[self class] potion].historyIndex ? YES : NO;
}

#pragma mark - Tag

- (NSString *) tag; { return self.uniqueTag; }



+ (BOOL) confirmed; { return YES; }
+ (void)saveAndUploadRecipe:(NSString *)recipeName image:(UIImage *)preview finished:(MysticBlockObjBOOL)finishedSaving;
{
    [self saveAndUploadProject:recipeName image:preview finished:finishedSaving];
}
+ (void)saveAndUploadProject:(MysticBlockObjBOOL)finishedSaving;
{
    [self saveAndUploadProject:nil image:nil finished:finishedSaving];
}
+ (void)saveAndUploadProject:(NSString*)pname image:(UIImage *)preview finished:(MysticBlockObjBOOL)finishedSaving
{
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            pname ? pname : [[self class] potion].uniqueTag, @"name",
                            @"", @"description",
                            [[self class] userInfo], @"info",
                            [[MysticUser get:@"settings-private"] boolValue] ? @"YES" : @"NO", @"private",
                            pname && ![Mystic isRiddleAnswer:MysticChiefPassword] ? @"YES" : @"NO", @"community",
                            pname && [Mystic isRiddleAnswer:MysticChiefPassword] ? @"YES" : @"NO", @"featured",
                            nil];
    
    
    
    [MysticAPI upload:@"/potion/create" params:params uploads:nil progress:nil complete:^(NSDictionary *results, NSError *error) {
        
        
        if(error) { if(finishedSaving) finishedSaving(nil, NO); return; }
        else
        {
            [[[self class] potion].userInfoExtras addEntriesFromDictionary:results];
            NSMutableArray *uploads = [NSMutableArray array];
            NSMutableDictionary *pinfo = [NSMutableDictionary dictionaryWithDictionary:results];
            NSString *pid = [results objectForKey:@"id"];
            [pinfo setObject:[NSString stringWithFormat:@"http://i.mysti.ch/potions/%@/project.plist", pid] forKey:@"url"];
            [pinfo setObject:[NSString stringWithFormat:@"http://i.mysti.ch/potions/%@/preview.jpg", pid] forKey:@"preview"];
            [pinfo setObject:[NSString stringWithFormat:@"http://i.mysti.ch/potions/%@/preview_thumb.jpg", pid] forKey:@"thumbnail"];
            [pinfo setObject:[NSString stringWithFormat:@"http://i.mysti.ch/potions/%@/preview_thumb.jpg", pid] forKey:@"thumbnail"];
            UIImage *renderedPreviewImage = preview ? preview : [MysticEffectsManager renderedImage];
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
            PackPotionOptionCamLayer *camOption = (PackPotionOptionCamLayer *)[[self class] confirmedOptionForType:MysticObjectTypeCamLayer];
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
                UIImage *sourceImage = [[self class] potion].sourceImage;
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
            [MysticAPI upload:uploadUri params:[NSDictionary dictionary] uploads:uploads progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                
            } complete:^(NSDictionary *results, NSError *error) {
                
                if(error)
                {
                    if(finishedSaving) finishedSaving(results, NO);
                    return;
                }
                else
                {
                    [[[self class] potion].userInfoExtras addEntriesFromDictionary:results];
            
                    [self saveProject:^(NSString *projectFilePath) {
                        
                        NSData *data2 = [NSData dataWithContentsOfFile:projectFilePath];
                        if(!data2)
                        {
                            if(finishedSaving) finishedSaving(nil, NO);
                            return;
                        }
                        NSDictionary *projectUpload = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       data2, @"data",
                                                       @"project.plist", @"filename",
                                                       @"file", @"name",
                                                       @"application/xml", @"mime",
                                                       nil];

                        
                        [MysticAPI upload:uploadUri params:[NSDictionary dictionary] uploads:[NSArray arrayWithObject:projectUpload] progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                            
                            
                        } complete:^(NSDictionary *results, NSError *error) {
                            
                    
                            if(error)
                            {
                                if(finishedSaving) finishedSaving(results, NO);
                                [renderedPreviewImage release];
                                return;
                            }
                            else
                            {
                        
                                MysticProject *project = [MysticProject projectFromFile:projectFilePath];
                                if(finishedSaving) finishedSaving(project, YES);
                                
                                
                                
                            }
                        }];
                    }];
                }
            }];
            
        }
        
    }];
}

+ (void)saveProject; { [self saveProject:nil]; }
+ (void)saveProject:(MysticBlockString)finished;
{
    if(!projects) projects = [[NSMutableDictionary dictionary] retain];
    mdispatch_default(^{
        NSDictionary *_info = [[self class] userInfo];
        if (_info) {
            NSString *p = [[self class] userInfoFilePath];
            if ([[NSFileManager defaultManager] fileExistsAtPath:p]) [[NSFileManager defaultManager] removeItemAtPath:p error:nil];
            [_info writeToFile:p atomically:YES];
            if(finished) finished(p);
        }
    });
}

+ (void) startNewProject;
{
    [UserPotionManager clearCachedFilesWithTags:[NSArray arrayWithObjects:@"userphoto", nil]];
    if([[self class] projectExists])
    {
        if([[self class] previousProjectExists]) [[NSFileManager defaultManager] removeItemAtPath:[[self class] previousUserInfoFilePath] error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:[[self class] userInfoFilePath] toPath:[[self class] previousUserInfoFilePath] error:nil];
    }
}
+ (NSDictionary *) previousProject;
{
    return [[self class] previousProjectExists] ? [[[NSDictionary alloc] initWithContentsOfFile:[[self class] previousUserInfoFilePath]] autorelease] : nil;
}
+ (NSDictionary *) currentProject;
{
    return [[self class] projectExists] ? [[[NSDictionary alloc] initWithContentsOfFile:[[self class] userInfoFilePath]] autorelease] : nil;
}
+ (BOOL) previousProjectExists;
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[[self class] previousUserInfoFilePath]];
}
+ (BOOL) projectExists;
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[[self class] userInfoFilePath]];
}
+ (NSString *) userInfoFilePath;
{
    return [[self class] userInfoFilePath:@"current"];
}

+ (NSString *) previousUserInfoFilePath;
{
    return [[self class] userInfoFilePath:@"last"];
}

+ (NSString *) userInfoFilePath:(NSString *)name;
{
    return nil;
}




+ (NSDictionary *)userInfo;
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[[self class] potion].userInfo];
    NSMutableArray *effectsInfo = [NSMutableArray array];
    for (PackPotionOption *effect in [[self class] effects]) [effectsInfo addObject:effect.userInfo];
    [userInfo setObject:effectsInfo forKey:@"effects"];
    return [NSDictionary dictionaryWithDictionary:userInfo];
}

+ (void) openProject:(MysticProject *)project finished:(MysticBlockObjBOOL)finished;
{
    [[[self class] potion] openProject:project finished:finished];
}



- (void) openProject:(MysticProject *)projectObj finished:(MysticBlockObjBOOL)finished;
{
    NSDictionary *project = projectObj.info;
    BOOL downloadSourceImage = projectObj.fromDownload && projectObj.sourceImageURL && !projectObj.useCurrentSourceImage;
    [[self class] resetSettings];
    [[self class] resetPotion];
    if(downloadSourceImage)
    {
        self.sourceImageResized = nil;
        self.sourceImage = nil;
        self.sourceImagePath = nil;
        self.originalImagePath = nil;
        self.sourceImageResizedPath = nil;
    }
    
    NSArray *floatProps = [NSArray arrayWithObjects:@"brightness", @"contrast", @"exposure", @"gamma", @"whiteLevels", @"blackLevels", @"midLevels", @"saturation", @"highlights", @"shadows", @"haze", @"vignetteEnd", @"vignetteState", @"vignetteValue", @"tiltShift", @"sharpness", @"rotation", @"unsharpMask", @"tint", @"temperature", nil];
    
    void (*objc_msgSendFloat)(id self, SEL _cmd, float value) = (void*)objc_msgSend;

    float floatval;
    SEL sel;
    NSString *selStr;
    for (NSString *floatStr in floatProps) {
        if([project objectForKey:floatStr]){
            floatval = [[project objectForKey:floatStr] floatValue];
            NSString *floatStrC = [NSString stringWithFormat:@"%@%@",[[floatStr substringToIndex:1] uppercaseString],[floatStr substringFromIndex:1] ];

            
            selStr = [NSString stringWithFormat:@"set%@:", floatStrC];
            sel = NSSelectorFromString(selStr);
            if([self respondsToSelector:sel])
            {
                objc_msgSendFloat(self, sel, floatval);
            }
        }
    }
    
    void (*objc_msgSendBOOL)(id self, SEL _cmd, BOOL value) = (void*)objc_msgSend;
    
    NSArray *boolProps = [NSArray arrayWithObjects:@"flipVertical", @"flipHorizontal", @"desaturate", @"applySettingsFirst", @"applyFilterToBadge", @"applyFilterToText", @"applyFilterToTexture", @"applyFilterToFrame", @"applyFilterToLight", @"applyFilterToCamLayer", @"applySunshineToFilter", nil];
    
    BOOL boolval;

    for (NSString *keyStr in boolProps) {
        if([project objectForKey:keyStr]){
            boolval = [[project objectForKey:keyStr] boolValue];
            NSString *keyStrC = [NSString stringWithFormat:@"%@%@",[[keyStr substringToIndex:1] uppercaseString],[keyStr substringFromIndex:1] ];
            selStr = [NSString stringWithFormat:@"set%@:", keyStrC];
            sel = NSSelectorFromString(selStr);
            if([self respondsToSelector:sel]) objc_msgSendBOOL(self, sel, boolval);
        }
    }
    
    void (*objc_msgSendRect)(id self, SEL _cmd, CGRect value) = (void*)objc_msgSend;
    
    NSArray *rectProps = [NSArray arrayWithObjects:@"transformRect", @"cropRect", nil];
    
    CGRect rectVal;
    
    for (NSString *keyStr in rectProps) {
        if([project objectForKey:keyStr]){
            rectVal = CGRectFromString([project objectForKey:keyStr]);
            NSString *keyStrC = [NSString stringWithFormat:@"%@%@",[[keyStr substringToIndex:1] uppercaseString],[keyStr substringFromIndex:1] ];
            selStr = [NSString stringWithFormat:@"set%@:", keyStrC];
            sel = NSSelectorFromString(selStr);
            if([self respondsToSelector:sel]) objc_msgSendRect(self, sel, rectVal);
        }
    }
    
    void (*objc_msgSendSize)(id self, SEL _cmd, CGSize value) = (void*)objc_msgSend;

    NSArray *sizeProps = downloadSourceImage ? [NSArray arrayWithObjects:@"previewSize", @"sourceImageSize", @"originalImageSize", nil] : [NSArray arrayWithObjects:@"unknown", nil];
    
    CGSize sizeVal;
    
    for (NSString *keyStr in sizeProps) {
        if([project objectForKey:keyStr]){
            sizeVal = CGSizeFromString([project objectForKey:keyStr]);
            NSString *keyStrC = [NSString stringWithFormat:@"%@%@",[[keyStr substringToIndex:1] uppercaseString],[keyStr substringFromIndex:1] ];
            selStr = [NSString stringWithFormat:@"set%@:", keyStrC];
            sel = NSSelectorFromString(selStr);
            if([self respondsToSelector:sel]) objc_msgSendSize(self, sel, sizeVal);
        }
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    id val;
    
    if(!projectObj.fromDownload)
    {
        NSArray *pathProps = [NSArray arrayWithObjects:@"originalImagePath", @"sourceImagePath", @"sourceImageResizedPath", nil];
        
        
        
        for (NSString *keyStr in pathProps) {
            if([project objectForKey:keyStr]){
                val = [project objectForKey:keyStr];
                if(![fileManager fileExistsAtPath:val]) continue;
                NSString *keyStrC = [NSString stringWithFormat:@"%@%@",[[keyStr substringToIndex:1] uppercaseString],[keyStr substringFromIndex:1] ];
                selStr = [NSString stringWithFormat:@"set%@:", keyStrC];
                sel = NSSelectorFromString(selStr);
                if([self respondsToSelector:sel])
                {
                    objc_msgSend(self, sel, val);
                }
            }
        }
        
        
    }
    
    
    NSArray *otherProps = !projectObj.fromDownload ? [NSArray arrayWithObjects:@"project", nil] : [NSArray arrayWithObjects:@"uniqueTag", @"project", nil];
    
    
    for (NSString *keyStr in otherProps) {
        if([project objectForKey:keyStr]){
            val = [project objectForKey:keyStr];
            NSString *keyStrC = [NSString stringWithFormat:@"%@%@",[[keyStr substringToIndex:1] uppercaseString],[keyStr substringFromIndex:1] ];
            selStr = [NSString stringWithFormat:@"set%@:", keyStrC];
            sel = NSSelectorFromString(selStr);
            if([self respondsToSelector:sel]) objc_msgSend(self, sel, val);
        }
    }
    
    
    
    NSArray *effects = projectObj.effects;
    if(effects && [effects count])
    {
        for (NSDictionary *effectInfo in effects) {
            MysticObjectType effectType = [[effectInfo objectForKey:@"type"] integerValue];
            BOOL shouldStop = NO;
            switch (effectType) {
                case MysticObjectTypeCamLayer:
                case MysticObjectTypeSetting: shouldStop = YES; break;
                default: break;
            }
            if(shouldStop) continue;
            PackPotionOption *option = [Mystic findOptionWithType:effectType tag:[effectInfo objectForKey:@"tag"]];
            
            if(option)
            {
                option.isPreviewOption = NO;
                [option setUserInfo:effectInfo];
                [[self class] setOption:option type:effectType];
            }
            else if(effectType != MysticObjectTypeSetting)
            {
                PackPotionOption *o = [PackPotionOption optionWithType:effectType info:effectInfo];
                [o setUserInfo:effectInfo];
                [[self class] setOption:o type:effectType];
            }
        }
    }
    
    if(downloadSourceImage)
    {
        NSString *sourceUrl = projectObj.sourceImageURL;
        self.sourceImagePath = nil;
        self.sourceImageResizedPath = nil;
        self.originalImagePath = nil;
        
        CGSize previewSize = [MysticController controller].view.frame.size;
        previewSize.height -= kBottomToolBarHeight;
        
        
        NSString *sourceCacheKey = [SDWebImageManager.sharedManager cacheKeyForURL:[NSURL URLWithString:sourceUrl]];
        UIImage *img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:sourceCacheKey];
        if(img) [self prepareWithSource:img previewSize:previewSize media:nil finished:^(CGSize size, UIImage *image2, NSString *imageFilePath) {
            if(finished) finished(projectObj, YES);
            }];
        else
        {
            [SDWebImageManager.sharedManager downloadWithURL:[NSURL URLWithString:sourceUrl] options:nil progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL done) {
                if(!done) return;
                [self prepareWithSource:image previewSize:previewSize media:nil finished:^(CGSize size, UIImage *image2, NSString *imageFilePath) {
                    if(finished) finished(projectObj, YES);
                }];
            }];
        }
    }
    else if(finished) finished(projectObj, YES);
}

- (NSDictionary *)userInfo;
{
    NSMutableDictionary *_userInfo = [NSMutableDictionary dictionary];
    [_userInfo setObject:[NSDate date] forKey:@"date"];
    [_userInfo setObject:[MysticUI stringFromRect:self.transformRect] forKey:@"transformRect"];
    [_userInfo setObject:[MysticUI stringFromRect:self.cropRect] forKey:@"cropRect"];
    [_userInfo setObject:[MysticUI stringFromSize:self.previewSize] forKey:@"previewSize"];
    [_userInfo setObject:[MysticUI stringFromSize:self.previewSize] forKey:@"sourceImageSize"];
    [_userInfo setObject:[MysticUI stringFromSize:self.previewSize] forKey:@"originalImageSize"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.brightness] forKey:@"brightness"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.contrast] forKey:@"contrast"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.exposure] forKey:@"exposure"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.gamma] forKey:@"gamma"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.whiteLevels] forKey:@"whiteLevels"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.midLevels] forKey:@"midLevels"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.blackLevels] forKey:@"blackLevels"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.saturation] forKey:@"saturation"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.highlights] forKey:@"highlights"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.shadows] forKey:@"shadows"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.haze] forKey:@"haze"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.vignetteEnd] forKey:@"vignetteEnd"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.vignetteStart] forKey:@"vignetteStart"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.vignetteValue] forKey:@"vignetteValue"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.tiltShift] forKey:@"tiltShift"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.sharpness] forKey:@"sharpness"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.rotation] forKey:@"rotation"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.unsharpMask] forKey:@"unsharpMask"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.tint] forKey:@"tint"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.temperature] forKey:@"temperature"];
    [_userInfo setObject:self.uniqueTag forKey:@"uniqueTag"];
    [_userInfo setObject:[NSNumber numberWithBool:self.flipVertical] forKey:@"flipVertical"];
    [_userInfo setObject:[NSNumber numberWithBool:self.flipHorizontal] forKey:@"flipHorizontal"];
    [_userInfo setObject:[NSNumber numberWithBool:self.desaturate] forKey:@"desaturate"];
    [_userInfo setObject:[NSNumber numberWithBool:self.applySettingsFirst] forKey:@"applySettingsFirst"];
    [_userInfo setObject:[NSNumber numberWithBool:self.applyFilterToBadge] forKey:@"applyFilterToBadge"];
    [_userInfo setObject:[NSNumber numberWithBool:self.applyFilterToCamLayer] forKey:@"applyFilterToCamLayer"];
    [_userInfo setObject:[NSNumber numberWithBool:self.applyFilterToFrame] forKey:@"applyFilterToFrame"];
    [_userInfo setObject:[NSNumber numberWithBool:self.applyFilterToLight] forKey:@"applyFilterToLight"];
    [_userInfo setObject:[NSNumber numberWithBool:self.applyFilterToText] forKey:@"applyFilterToText"];
    [_userInfo setObject:[NSNumber numberWithBool:self.applyFilterToTexture] forKey:@"applyFilterToTexture"];
    [_userInfo setObject:[NSNumber numberWithBool:self.applySunshineToFilter] forKey:@"applySunshineToFilter"];
    if(_originalImagePath) [_userInfo setObject:_originalImagePath forKey:@"originalImagePath"];
    if(_sourceImagePath) [_userInfo setObject:_sourceImagePath forKey:@"sourceImagePath"];
    if(_sourceImageResizedPath) [_userInfo setObject:_sourceImageResizedPath forKey:@"sourceImageResizedPath"];
    [_userInfo setObject:(self.userInfoExtras ? self.userInfoExtras : [NSDictionary dictionary]) forKey:@"project"];
    return [NSDictionary dictionaryWithDictionary:_userInfo];
}

- (void) setProject:(NSDictionary *)ainfo; { if(ainfo) [self.userInfoExtras addEntriesFromDictionary:ainfo]; }
+ (BOOL) isIgnoringChanges; { return ignoreChanges; }
+ (void) ignoreChanges; { ignoreChanges = YES; }
+ (BOOL) isSavingImage; { return CGSizeEqualToSize([MysticUser user].size, [[self class] potion].renderSize); }
+ (void) reset; { [[self class] reset:NO]; }
+ (void) reset:(BOOL)clearTag;
{
    [[self class] potion].finalImage = nil;
    [[self class] potion].sourceImage = nil;
    [[self class] potion].sourceImageResized = nil;
    [[self class] clearHistory];
    if(clearTag) [[self class] potion].uniqueTag = nil;
    [[self class] resetPotion];
    if([[self class] potion].mode == MysticModeOn) [[self class] potion].mode = MysticModeOn;
}
+ (void) resetEdits;
{
    [[self class] resetPotion];
    [[self class] resetSettings];
    [[MysticOptions current] reset];
}
+ (void) resetSettings; { [[[self class] potion] setDefaultSettings]; }
+ (void) resetPotion; { [[[self class] potion] setDefaults]; }

- (CGAffineTransform) currentSourceImageTransform;
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    MysticObjectType _type = self.editingType;
    switch(_type)
    {
        case MysticSettingNone:
        case MysticSettingNoneFromLoadProject:
        case MysticSettingNoneFromBack:
        case MysticSettingNoneFromCancel:
        case MysticSettingNoneFromConfirm: _type = MysticSettingCropSourceImage; break;
        default: break;
    }
    NSValue *tobj = [_sourceTransforms objectForKey:MysticObjectTypeToString(_type)];
    if(tobj)
    {
        transform = [tobj CGAffineTransformValue];
    }

    
    return transform;
}
- (void) setTransform:(CGAffineTransform)transform forType:(MysticObjectType)type;
{
    MysticObjectType _type = self.editingType;
    switch(_type)
    {
        case MysticSettingNone:
        case MysticSettingNoneFromLoadProject:
        case MysticSettingNoneFromBack:
        case MysticSettingNoneFromCancel:
        case MysticSettingNoneFromConfirm:
        {
            _type = MysticSettingCropSourceImage;
            break;
        }
        default: break;
    }
    
    
    
    if(CGAffineTransformIsIdentity(transform))
    {
        [_sourceTransforms removeObjectForKey:MysticObjectTypeToString(_type)];
        return;
    }
    
    
    [_sourceTransforms setObject:[NSValue valueWithCGAffineTransform:transform] forKey:MysticObjectTypeToString(_type)];
}

+ (BOOL) canRender;
{
    if([[self class] potion].sourceImage || [[self class] potion].sourceImageResized)
    {
        return YES;
    }
    return NO;
}


+ (BOOL) hasChanges
{
    return [[[self class] potion] hasChanges];
}

+ (BOOL) hasUserAppliedSettingOfType:(MysticObjectType)type;
{
    return [[self class] hasUserAppliedSettingOfType:type option:nil];
}
+ (BOOL) hasUserAppliedSettingOfType:(MysticObjectType)type option:(PackPotionOption *)option;
{
    option = option ? option : (PackPotionOption *)[[self class] optionForType:MysticObjectTypeSetting];
    if(!option && type != MysticSettingColorFilter && type != MysticSettingChooseColorFilter && type != MysticObjectTypeFilter) return NO;
    switch (type) {
        case MysticObjectTypeSetting:
        {
            return [[self class] optionForType:MysticObjectTypeSetting] != nil;
        }
        case MysticSettingColorFilter:
        case MysticSettingChooseColorFilter:
        {
        
            return [[self class] optionForType:MysticObjectTypeFilter] ? YES : NO;
        }
        case MysticSettingBrightness:
        {
            return option.brightness != kBrightness;
        }
        case MysticSettingGamma:
        {
            return option.gamma != kGamma;
        }
        case MysticSettingExposure:
        {
            return option.exposure != kExposure;
        }
        case MysticSettingVignette:
        {
            return option.vignetteEnd != option.vignetteStart;
        }
        case MysticSettingUnsharpMask:
            return option.unsharpMask != kUnsharpMask;
            
        case MysticSettingTemperature:
        {
            return option.temperature != kTemperature || option.tint != kTint;
        }
        case MysticSettingCamLayerSetup:
        case MysticSettingLevels:
        {
            return option.blackLevels != kLevelsMin || option.whiteLevels != kLevelsMax;
        }
        case MysticSettingHaze:
        {
            return option.haze != kHaze;
        }
        case MysticSettingSaturation:
        {
            return option.saturation != kSaturation;
        }
        case MysticSettingTiltShift:
        {
            return option.tiltShift != kTiltShift;
        }
        case MysticSettingContrast:
        {
            return option.contrast != kContrast;
        }
        case MysticSettingSharpness:
        {
            return option.sharpness != kSharpness;
        }
        case MysticSettingShadows:
        {
            return option.shadows != kShadows;
        }
        case MysticSettingHighlights:
        {
            return option.highlights != kHighlights;
        }
        case MysticSettingColorBalance:
        {
            return option.rgb.one != 1.0f || option.rgb.two != 1.0f || option.rgb.three != 1.0f;
        }
        case MysticSettingBlending:
        {
            if([option respondsToSelector:@selector(blendingMode)] && option.blendingMode)
            {
                return YES;
            }
            return NO;
        }
        default:
        {
            return NO;
        }
    }
    return NO;
}

+ (PackPotionOption *) optionForType:(MysticObjectType)type;
{
    if(!UserPotionInstance) return nil;
    switch (type) {
        case MysticSettingSettings:
        case MysticObjectTypeSetting:
            return [[self class] potion].settingsOption;
            
        case MysticSettingText:
        case MysticSettingTextAlpha:
        case MysticObjectTypeText:
        case MysticSettingChooseText:
        case MysticSettingTextColor:
        {
            return [[self class] potion].textOption;
        }
        case MysticSettingTexture:
        case MysticSettingTextureAlpha:
        case MysticObjectTypeTexture:
            return [[self class] potion].textureOption;
        
        case MysticObjectTypeMixture:
        case MysticSettingMixtures:
        {
            if([[self class] potion].textureOption) return [[self class] potion].textureOption;
            return [[self class] potion].lightOption;
        }
            
        case MysticSettingFrame:
        case MysticSettingFrameAlpha:
        case MysticObjectTypeFrame:
            return [[self class] potion].frameOption;
            
        case MysticSettingLighting:
        case MysticSettingLightingAlpha:
        case MysticObjectTypeLight:
            return [[self class] potion].lightOption;
            
        case MysticObjectTypeBadge:
        case MysticSettingBadge:
        case MysticSettingBadgeAlpha:
        case MysticSettingBadgeColor:
            return [[self class] potion].badgeOption;
            
        case MysticSettingMask:
        case MysticObjectTypeMask:
            return [[self class] potion].maskOption;
        
        case MysticSettingColorFilter:
        case MysticSettingChooseColorFilter:
        case MysticSettingFilter:
        case MysticSettingFilterAlpha:
        case MysticObjectTypeFilter:
            return [[self class] potion].filterOption;
            
        case MysticSettingCamLayerAlpha:
        case MysticSettingCamLayerTakePhoto:
        case MysticObjectTypeCamLayer:
        case MysticSettingCamLayer:
        case MysticSettingCamLayerColor:
            return [[self class] potion].camLayerOption;
        default:
        {
            
            for (PackPotionOption *opt in [[self class] potion].layers) {
                if(opt.type == type){
                    return opt;
                }
            }
            break;
        }
    }
    return nil;
}
+ (void) removeOption:(MysticOption *)option;
{
    [[self class] onlyRemoveOption:option];
}
+ (void) onlyRemoveOption:(MysticOption *)option;
{
    switch (option.type) {
        case MysticObjectTypeSetting:
            if([[[self class] potion].settingsOption isEqual:option]) [[self class] potion].settingsOption = nil;
            break;
        case MysticObjectTypeText:
            if([[[self class] potion].textOption isEqual:option]) [[self class] potion].textOption = nil;
            break;
        case MysticObjectTypeTexture:
            if([[[self class] potion].textureOption isEqual:option]) [[self class] potion].textureOption = nil;
            break;
        case MysticObjectTypeFrame:
            if([[[self class] potion].frameOption isEqual:option]) [[self class] potion].frameOption = nil;
            break;
        case MysticObjectTypeLight:
            if([[[self class] potion].lightOption isEqual:option]) [[self class] potion].lightOption = nil;
            break;
        case MysticObjectTypeBadge:
            if([[[self class] potion].badgeOption isEqual:option]) [[self class] potion].badgeOption = nil;
            break;
        case MysticObjectTypeMask:
            if([[[self class] potion].maskOption isEqual:option]) [[self class] potion].maskOption = nil;
            break;
        case MysticSettingColorFilter:
        case MysticObjectTypeFilter:
            if([[[self class] potion].filterOption isEqual:option]) [[self class] potion].filterOption = nil;
            break;
        case MysticObjectTypeCamLayer:
            if([[[self class] potion].camLayerOption isEqual:option]) [[self class] potion].camLayerOption = nil;
            break;
        default:
        {
            NSMutableArray *set = [NSMutableArray array];
            for (PackPotionOption *opt in [[self class] potion].layers) {
                if([opt isEqual:option])
                {
                    [set addObject:opt];
                }
            }
            if([set count])
            {
                for (id obj in set) {
                    [[[self class] potion].layers removeObject:obj];
                }
            }
            break;
        }
    }
}
+ (void) onlyRemoveOptionWithType:(MysticOption *)option;
{
    switch (option.type) {
        case MysticObjectTypeSetting:
            [[self class] potion].settingsOption = nil;
            break;
        case MysticObjectTypeText:
            [[self class] potion].textOption = nil;
            break;
        case MysticObjectTypeTexture:
            [[self class] potion].textureOption = nil;
            break;
        case MysticObjectTypeFrame:
            [[self class] potion].frameOption = nil;
            break;
        case MysticObjectTypeLight:
            [[self class] potion].lightOption = nil;
            break;
        case MysticObjectTypeBadge:
            [[self class] potion].badgeOption = nil;
            break;
        case MysticObjectTypeMask:
            [[self class] potion].maskOption = nil;
            break;
        case MysticSettingColorFilter:
        case MysticObjectTypeFilter:
            [[self class] potion].filterOption = nil;
            break;
        case MysticObjectTypeCamLayer:
            [[self class] potion].camLayerOption = nil;
            break;
        default:
        {
            NSMutableArray *set = [NSMutableArray array];
            for (PackPotionOption *opt in [[self class] potion].layers) {
                if(opt.type == option.type)
                {
                    [set addObject:opt];
                }
            }
            if([set count])
            {
                for (id obj in set) {
                    [[[self class] potion].layers removeObject:obj];
                }
            }
            break;
        }
    }
}
+ (void) cancelOption:(MysticOption *)option;
{
    [[self class] cancelOptionForType:option.type];
}
+ (void) cancelOptionForType:(MysticObjectType)type;
{
    PackPotionOption *opt = [[self class] optionForType:type];
    if(!UserPotionInstance) return;
    if(opt)
    {
        return [[self class] removeOption:opt];
    }
    [[self class] removeOptionForType:type];
}
+ (void) removeOptionForType:(MysticObjectType)type;
{
    if(!UserPotionInstance) return;
    PackPotionOption *opt = [[self class] optionForType:type];
    [[self class] onlyRemoveOptionWithType:opt];
}

+ (PackPotionOption *) setOption:(PackPotionOption *)option type:(MysticObjectType)type;
{
    if(!UserPotionInstance) { return nil; }
    switch (type) {
        case MysticObjectTypeText:
            [[self class] potion].textOption = (PackPotionOptionText *)option;
            break;
        case MysticObjectTypeTexture:
            [[self class] potion].textureOption = (PackPotionOptionTexture *)option;
            break;
        case MysticObjectTypeFrame:
            
            [[self class] potion].frameOption = (PackPotionOptionFrame *)option;
            break;
        case MysticObjectTypeLight:
            [[self class] potion].lightOption = (PackPotionOptionLight *)option;
            break;
        case MysticObjectTypeBadge:
            [[self class] potion].badgeOption = (PackPotionOptionBadge *)option;
            break;
        case MysticObjectTypeMask:
            [[self class] potion].maskOption = (PackPotionOptionMask *)option;
            break;
        case MysticSettingChooseColorFilter:
        case MysticSettingColorFilter:
        case MysticObjectTypeFilter:
            [[self class] potion].filterOption = (PackPotionOptionFilter *)option;
            break;
        case MysticObjectTypeCamLayer:
            [[self class] potion].camLayerOption = (PackPotionOptionCamLayer *)option;
            break;
        case MysticSettingTemperature:
        case MysticSettingSaturation:
        case MysticSettingRGB:
        case MysticSettingTiltShift:
        case MysticSettingShadows:
        case MysticSettingSharpness:
        case MysticSettingBrightness:
        case MysticSettingContrast:
        case MysticSettingExposure:
        case MysticSettingGamma:
        case MysticSettingHighlights:
        case MysticSettingHaze:
        case MysticSettingLevels:
        case MysticObjectTypeSetting:
            [[self class] potion].settingsOption = (PackPotionOptionSetting *)option;
            break;
        default:
//            DLogError(@"trying to set unknown type: %@ '%@'", MysticObjectTypeToString(type), option.tag);
            if(option.optionSlotKey)
            {
                NSArray *narray = [NSArray arrayWithArray:[[self class] potion].layers];
                for (PackPotionOption *no in narray) {
                    if(option.optionSlotKey && no.optionSlotKey && [option.optionSlotKey isEqualToString:no.optionSlotKey])
                    {
                        [[[self class] potion].layers removeObject:no];
                    }
                }
            }
            [[[self class] potion].layers addObject:option];
//            DLogHidden(@"trying to set unknown type to: %@", [[self class] potion].layers );

            break;
    }
    return option;
}

- (void) applyAdjustmentsFrom:(PackPotionOption *)otherOption;
{
    PotionLog(@"apply settings option to UserPotion");
    
}



+ (BOOL) confirmOptionType:(MysticObjectType)type;
{
    PackPotionOption *option = [[self class] optionForType:type];
    return [[self class] confirmOption:option];
}
+ (BOOL) confirmOption:(PackPotionOption *)option;
{
    MysticObjectType type = option.type;
    if(!UserPotionInstance) return NO;
    BOOL cancelled = NO;
    if(option.ignoreRender)
    {
        [[self class] cancelOptionForType:type];
        cancelled = YES;
    }
    else if(option.isPreviewOption)
    {
        [[[self class] potion] confirmOptionType:type];
        
    }
    return cancelled;
}

- (BOOL) confirmOptionType:(MysticObjectType)type;
{
    if(!UserPotionInstance) return NO;
    PackPotionOption *option = [[self class] optionForType:type];
    return [self confirmOption:option];
}
- (BOOL) confirmOption:(PackPotionOption *)option;
{
    BOOL cancelled = NO;
    MysticObjectType type = option.type;
    if(option.ignoreRender || option.cancelsEffect)
    {
        [[self class] cancelOptionForType:type];
        cancelled = YES;
    }
    else
    {
        if(option && option.isPreviewOption && option != [[self class] confirmedOptionForType:type])
        {
            [[MysticUser user] usedItemRecently:option];
            switch (type) {
                case MysticObjectTypeText:
                {
                    if(_textOption) [_textOption release], _textOption=nil;
                    _textOption = (PackPotionOptionText *)[option retain];
                    _textOption.isPreviewOption = NO;
                    [_previewOptionText release], _previewOptionText=nil;
                    break;
                }
                case MysticObjectTypeTexture:
                {
                    if(_textureOption) [_textureOption release], _textureOption=nil;
                    _textureOption = (PackPotionOptionTexture *)[option retain];
                    _textureOption.isPreviewOption = NO;
                    [_previewOptionTexture release], _previewOptionTexture=nil;
                    break;
                }
                case MysticObjectTypeFrame:
                {
                    if(_frameOption) [_frameOption release], _frameOption=nil;
                    _frameOption = (PackPotionOptionFrame *)[option retain];
                    _frameOption.isPreviewOption = NO;
                    [_previewOptionFrame release], _previewOptionFrame=nil;
                    break;
                }
                case MysticObjectTypeLight:
                {
                    if(_lightOption) [_lightOption release], _lightOption=nil;
                    _lightOption = (PackPotionOptionLight *)[option retain];
                    _lightOption.isPreviewOption = NO;
                    [_previewOptionLight release], _previewOptionLight=nil;
                    break;
                }
                case MysticObjectTypeMask:
                {
                    if(_maskOption) [_maskOption release], _maskOption=nil;
                    _maskOption = (PackPotionOptionMask *)[option retain];
                    _maskOption.isPreviewOption = NO;
                    [_previewOptionMask release], _previewOptionMask=nil;
                    break;
                }
                case MysticSettingColorFilter:
                case MysticObjectTypeFilter:
                {
                    if(_filterOption) [_filterOption release], _filterOption=nil;
                    _filterOption = (PackPotionOptionFilter *)[option retain];
                    _filterOption.isPreviewOption = NO;
                    [_previewOptionFilter release], _previewOptionFilter=nil;
                    break;
                }
                case MysticObjectTypeBadge:
                {
                    if(_badgeOption) [_badgeOption release], _badgeOption=nil;
                    _badgeOption = (PackPotionOptionBadge *)[option retain];
                    _badgeOption.isPreviewOption = NO;
                    [_previewOptionBadge release], _previewOptionBadge=nil;
                    break;
                }
                case MysticObjectTypeCamLayer:
                {
                    if(_camLayerOption) [_camLayerOption release], _camLayerOption=nil;
                    _camLayerOption = (PackPotionOptionCamLayer *)[option retain];
                    _camLayerOption.isPreviewOption = NO;
                    [_previewOptionCamLayer release], _previewOptionCamLayer=nil;
                    break;
                }
                default:
                    option.isPreviewOption = NO;
                    break;
            }
        }
    }
    return cancelled;
}
+ (void) removePreviewsForType:(MysticObjectType)type;
{
    if(!UserPotionInstance) return;
    switch (type) {
        case MysticObjectTypeText:
        {
            [[self class] potion].previewOptionText = nil;

            break;
        }
        case MysticObjectTypeTexture:
        {
            [[self class] potion].previewOptionTexture = nil;

            break;
        }
        case MysticObjectTypeFrame:
        {
            [[self class] potion].previewOptionFrame = nil;

            break;
        }
        case MysticObjectTypeLight:
        {
            [[self class] potion].previewOptionLight = nil;
            break;
        }
        case MysticObjectTypeMask:
        {
            [[self class] potion].previewOptionMask = nil;

            break;
        }
        case MysticSettingColorFilter:
        case MysticObjectTypeFilter:
        {
            [[self class] potion].previewOptionFilter = nil;

            break;
        }
        case MysticObjectTypeBadge:
        {
            [[self class] potion].previewOptionBadge = nil;

            break;
        }
        case MysticObjectTypeCamLayer:
        {
            [[self class] potion].previewOptionCamLayer = nil;

            break;
        }
        default:
            
            break;
    }
}
+ (void) removePreviews;
{
    if(!UserPotionInstance) return;
    [[self class] potion].previewOptionLight = nil;
    [[self class] potion].previewOptionFrame = nil;
    [[self class] potion].previewOptionFilter = nil;
    [[self class] potion].previewOptionBadge = nil;
    [[self class] potion].previewOptionMask = nil;
    [[self class] potion].previewOptionText = nil;
    [[self class] potion].previewOptionTexture = nil;
    [[self class] potion].previewOptionCamLayer = nil;
}

+ (BOOL) isChoosingType:(MysticObjectType)type;
{
    return [[self class] hasChosenType:type] && ![[self class] confirmedOptionForType:type];
}
+ (BOOL) isChangingType:(MysticObjectType)type;
{
    return [[self class] confirmedOptionForType:type] && [[self class] previewOptionForType:type];
}
+ (BOOL) hasChosenType:(MysticObjectType)type;
{
    return [[self class] optionForType:type] ? YES : NO;
}
+ (BOOL) hasChosenToCancelType:(MysticObjectType)type;
{
    return ![[self class] optionForType:type] || [[self class] optionForType:type].ignoreRender ? YES : NO;
}
+ (BOOL) hasConfirmedType:(MysticObjectType)type;
{
    return [[self class] confirmedOptionForType:type] ? YES : NO;
}
+ (BOOL) isChangingButMadeNoChoice:(MysticObjectType)type;
{
    return [[self class] confirmedOptionForType:type] && [[self class] confirmedOptionForType:type].isPreviewOption;
}



#pragma mark -
#pragma mark - Rendering

- (NSMutableArray *) layers;
{
    return _layers;
}
- (UIImage *) imageForRenderSize:(CGSize)size;
{
    if(CGSizeLess(self.previewSize, size)) return [self.sourceImage imageScaledToSize:CGSizeScaleDown(size, 0)];
    return self.sourceImageResized;
}




- (BOOL) effectOfType:(MysticObjectType)type effects:(NSArray *)effects;
{
    for (PackPotionOption *effect in effects) {
        if(effect.type == type) return YES;
    }
    return NO;
}

#pragma mark - renderEffects

+ (MysticOptions *) renderEffects;
{
    return [[self class] effects:YES];
}
+ (MysticOptions *)effects;
{
    return [[self class] potion].effects;
}

+ (MysticOptions *)effects:(BOOL)enabled;
{
    MysticOptions *options = [[self class] potion].effects;
    NSMutableArray *_opts = [NSMutableArray array];
    for (PackPotionOption *theOption in options.allOptions) {
        if(theOption.ignoreRender!=enabled)
        {
            [_opts addObject:theOption];
        }
    }
    return [[[MysticOptions alloc] initWithOptions:_opts] autorelease];
}

- (MysticOptions *) effects;
{
    return [self effectsWithEffects:nil];
}
- (MysticOptions *) effectsWithEffects:(id)effs;
{
    
    PackPotionOption *theOption;
    NSMutableArray *theEffects = [NSMutableArray array];
    
    if(effs && [effs isKindOfClass:[PackPotionOption class]])
    {
        effs = [NSArray arrayWithObject:effs];
    }
    
    if(effs && [effs isKindOfClass:[NSArray class]])
    {
        [theEffects addObjectsFromArray:effs];
    }
    
    if(![self effectOfType:MysticObjectTypeFrame effects:theEffects])
    {
        theOption = [[self class] optionForType:MysticObjectTypeFrame];
        if(theOption) [theEffects addObject:theOption];
    }
    
    if(![self effectOfType:MysticObjectTypeTexture effects:theEffects])
    {
        theOption = [[self class] optionForType:MysticObjectTypeTexture];
        if(theOption) [theEffects addObject:theOption];
    }
    if(![self effectOfType:MysticObjectTypeLight effects:theEffects])
    {
        theOption = [[self class] optionForType:MysticObjectTypeLight];
        if(theOption) [theEffects addObject:theOption];
    }
    if(![self effectOfType:MysticObjectTypeBadge effects:theEffects])
    {
        theOption = [[self class] optionForType:MysticObjectTypeBadge];
        if(theOption) [theEffects addObject:theOption];
    }
    if(![self effectOfType:MysticObjectTypeCamLayer effects:theEffects])
    {
        theOption = [[self class] optionForType:MysticObjectTypeCamLayer];
        if(theOption) [theEffects addObject:theOption];
    }
    if(![self effectOfType:MysticObjectTypeMask effects:theEffects])
    {
        theOption = [[self class] optionForType:MysticObjectTypeMask];
        if(theOption) [theEffects addObject:theOption];
    }
    if(![self effectOfType:MysticObjectTypeFilter effects:theEffects])
    {
        theOption = [[self class] optionForType:MysticObjectTypeFilter];
        if(theOption) [theEffects addObject:theOption];
    }
    if(![self effectOfType:MysticObjectTypeText effects:theEffects])
    {
        theOption = [[self class] optionForType:MysticObjectTypeText];
        if(theOption) [theEffects addObject:theOption];
    }
    if(![self effectOfType:MysticObjectTypeSetting effects:theEffects])
    {
        theOption = [[self class] optionForType:MysticObjectTypeSetting];
        if(theOption && theOption.hasAdjustments)
        {
            [theEffects addObject:theOption];
        }
    }

    
    [theEffects addObjectsFromArray:self.layers];
    return [[[MysticOptions alloc] initWithOptions:theEffects] autorelease];
    
}


+ (GPUImageOutput<GPUImageInput> *) input:(GPUImageOutput<GPUImageInput> *)parent hasTarget:(GPUImageOutput<GPUImageInput> *)target;
{
    if(!parent) parent = (GPUImageOutput<GPUImageInput> *) [[self class] potion].imagePicture;
    if(![parent.targets count]) return nil;
    if([parent.targets containsObject:target]) return parent;
    for (GPUImageOutput<GPUImageInput> *subTarget in parent.targets) {
        GPUImageOutput<GPUImageInput> *possibleTarget = [[self class] input:subTarget hasTarget:target];
        if(possibleTarget) return possibleTarget;
    }
    return nil;
}




+ (PackPotionOption *) confirmedOptionForType:(MysticObjectType)type;
{
    return [[[self class] potion] confirmedOptionForType:type];
}
- (PackPotionOption *) confirmedOptionForType:(MysticObjectType)type;
{
    switch (type) {
        case MysticObjectTypeMixture:
            return _textureOption ? _textureOption : _lightOption;
        case MysticObjectTypeText:
            return _textOption;
        case MysticObjectTypeTexture:
            return _textureOption;
        case MysticObjectTypeFrame:
            return _frameOption;
        case MysticObjectTypeLight:
            return _lightOption;
        case MysticObjectTypeMask:
            return _maskOption;
        case MysticObjectTypeBadge:
            return _badgeOption;
        case MysticSettingColorFilter:
        case MysticObjectTypeFilter:
            return _filterOption;
        case MysticObjectTypeCamLayer:
            return _camLayerOption;
        default: break;
    }
    for (PackPotionOption *option in [MysticOptions current]) {
        if(option.type == type && option.isConfirmed) return option;
    }
    return nil;
}
+ (PackPotionOption *) previewOptionForType:(MysticObjectType)type;
{
    return [[[self class] potion] previewOptionForType:type];
}
- (PackPotionOption *) previewOptionForType:(MysticObjectType)type;
{
    switch (type) {
        case MysticObjectTypeText:
            return _previewOptionText;
        case MysticObjectTypeTexture:
            return _previewOptionTexture;
        case MysticObjectTypeFrame:
            return _previewOptionFrame;
        case MysticObjectTypeLight:
            return _previewOptionLight;
        case MysticObjectTypeBadge:
            return _previewOptionBadge;
        case MysticObjectTypeMask:
            return _previewOptionMask;
        case MysticSettingColorFilter:
        case MysticObjectTypeFilter:
            return _previewOptionFilter;
        case MysticObjectTypeCamLayer:
            return _previewOptionCamLayer;
        default: break;
    }
    return nil;
}

+ (BOOL) hasOption:(MysticControlObject *)option;
{

    
    if(option)
    {
        switch (option.type) {
            case MysticObjectTypeText:
                return [Mystic option:option equals:[[self class] potion].textOption];
                break;
            case MysticObjectTypeBadge:
                return [Mystic option:option equals:[[self class] potion].badgeOption];
                break;
                
            case MysticObjectTypeFrame:
                return [Mystic option:option equals:[[self class] potion].frameOption];
                break;
            case MysticObjectTypeTexture:
                return [Mystic option:option equals:[[self class] potion].textureOption];
                break;
            case MysticSettingColorFilter:
            case MysticObjectTypeFilter:
                return [Mystic option:option equals:[[self class] potion].filterOption];
                break;
            case MysticObjectTypeMask:
                return [Mystic option:option equals:[[self class] potion].maskOption];
                break;
            case MysticObjectTypeLight:
                return  [Mystic option:option equals:[[self class] potion].lightOption];
                break;
            case MysticObjectTypeCamLayer:
                return [Mystic option:option equals:[[self class] potion].camLayerOption];
                break;
            
            default:
            {
                MysticObjectType parentType = MysticTypeForSetting(option.type, option);
                switch (parentType) {
                    case MysticObjectTypeSetting:
                    {
                        PackPotionOptionSetting *settingsOption = (PackPotionOptionSetting *)[[MysticOptions current] option:MysticObjectTypeSetting];
                        return [settingsOption hasAdjusted:option.type];
                    }
                    default:
                        break;
                }
                
                
            }
        }

    }
    return NO;
}


- (void) setMode:(MysticMode)mode
{
    _mode = mode;
    NSUserDefaults *userChoices = [NSUserDefaults standardUserDefaults];
    [userChoices setInteger:mode forKey:@"mysticMode"];
    [userChoices synchronize];
    
    switch (mode) {
        case MysticModeOn:
        {
            BOOL lightyesOrNo = [Mystic getYesOrNo];
            BOOL textyesOrNo = [Mystic getYesOrNo];
            BOOL badgeYesOrNo = [Mystic getYesOrNo];
            if(!badgeYesOrNo) textyesOrNo = YES;
            
            
            
            self.lightOption = lightyesOrNo ? (PackPotionOptionLight *)[Mystic randomOptionOfType:MysticObjectTypeLight] : nil;
            //self.maskOption = (PackPotionOptionMask *)[Mystic randomOptionOfType:MysticObjectTypeMask];
            self.textOption = textyesOrNo ? (PackPotionOptionText *)[Mystic randomOptionOfType:MysticObjectTypeText] : nil;
            //            self.frameOption = (PackPotionOptionFrame *)[Mystic randomOptionOfType:MysticObjectTypeFrame];
            self.badgeOption = badgeYesOrNo ? (PackPotionOptionBadge *)[Mystic randomOptionOfType:MysticObjectTypeBadge] : nil;
            self.filterOption = (PackPotionOptionFilter *)[Mystic randomOptionOfType:MysticObjectTypeFilter];
            //            self.textureOption = (PackPotionOptionTexture *)[Mystic randomOptionOfType:MysticObjectTypeTexture];
            NSUInteger randomLightAlpha = arc4random() % 100;
            //float rL2 = (float)randomLightAlpha;
            float rL = (float)randomLightAlpha/100.0f;
            
            NSUInteger randomFilterAlpha = arc4random() % 100;
            //float rF2 = (float)randomFilterAlpha;
            float rF = (float)randomFilterAlpha/100.0f;
            
            NSUInteger randomBadgeAlpha = arc4random() % 100;
            //float rb2 = (float)randomBadgeAlpha;
            float rb = (float)randomBadgeAlpha/100.0f;
            if(lightyesOrNo) self.lightingAlpha = 0.2 + (0.5 * rL);
            if(badgeYesOrNo) self.badgeAlpha = (1.0 * rb) < 0.25 ? 0.25 : (1.0 *rb);
            self.colorAlpha = 0.75+(0.25*rF);
            if(textyesOrNo) self.textAlpha = 1.6;

        }
            break;
        case MysticModeOff:
            [self setDefaults];
            break;
        default: break;
    }
}

- (void) setDefaults;
{
    
    
    [self setDefaultSettings];
    self.lightOption = nil;
    self.maskOption = nil;
    self.textOption = nil;
    self.frameOption = nil;
    self.badgeOption = nil;
    self.settingsOption = nil;
    self.filterOption = nil;
    self.textureOption = nil;
    self.camLayerOption=nil;
    self.colorAlpha = kColorAlpha;
    self.frameAlpha = kFrameAlpha;
    self.lightingAlpha = kLightAlpha;
    self.textAlpha = kTextAlpha;
    self.textureAlpha = kTextureAlpha;
    self.camLayerAlpha = kCamLayerAlpha;
    self.rgb = (GPUVector3){1.0f,1.0f,1.0f};
    self.badgeAlpha = kBadgeAlpha;
    self.transformRect = kDefaultTransform;
    self.transformTextRect = kDefaultTransform;
    self.transformBadgeRect = kDefaultTransform;
    self.transformMaskRect = kDefaultTransform;
    
    self.textRotation = kDefaultRotation;
    self.badgeRotation = kDefaultRotation;
    self.frameRotation = kDefaultRotation;
    self.textureRotation = kDefaultRotation;
    self.lightRotation = kDefaultRotation;
    self.rotation = kDefaultRotation;
    self.maskRotation = kDefaultRotation;
    self.camLayerRotation = kDefaultRotation;
    
    self.textColor = nil;
    self.badgeColor = nil;
    self.frameBackgroundColor = nil;
    self.lastSettingsResult = kNoSettingsApplied;
    [self.layers removeAllObjects];
    
}

- (void) setDefaultSettings;
{
    self.brightness = kBrightness;
    self.temperature = kTemperature;
    self.tiltShift = kTiltShift;
    self.gamma = kGamma;
    self.exposure = kExposure;
    self.shadows = kShadows;
    self.highlights = kHighlights;
    self.sharpness = kSharpness;
    self.contrast = kContrast;
    self.saturation = kSaturation;
    self.vignetteStart = kVignette;
    self.vignetteEnd = kVignette;
    self.haze = kHaze;
    self.whiteLevels = kLevelsMax;
    self.blackLevels = kLevelsMin;
    self.unsharpMask = kUnsharpMask;
    self.rgb = (GPUVector3){1.0f,1.0f,1.0f};

    self.tint = kTint;
}


- (BOOL) hasSettingsApplied
{
    return [self hasSettingsAppliedOrFilter:NO];
}
- (BOOL) hasSettingsAppliedOrFilter:(BOOL)checkFilter;
{
    PackPotionOptionSetting *option = (PackPotionOptionSetting *)[[self class] optionForType:MysticObjectTypeSetting];
    

    
    
    if(option)
    {
        return option.hasAdjustments;
    }
    else if(checkFilter && [[self class] optionForType:MysticObjectTypeFilter])
    {
        return YES;
    }
    return NO;
}

- (float) currentSettingsResult
{
    float __currentSettingsResult = kNoSettingsApplied;
    if(self.brightness != kBrightness)
    {
        __currentSettingsResult += kSettingBrightnessApplied;
        __currentSettingsResult += self.brightness;
    }
    if(self.temperature != kTemperature)
    {
        __currentSettingsResult += kSettingTemperatureApplied;
        __currentSettingsResult += self.temperature;
    }
    if(self.tint != kTint)
    {
        __currentSettingsResult += kSettingTemperatureApplied;
        __currentSettingsResult += self.tint;
    }
    if(self.tiltShift != kTiltShift)
    {
        __currentSettingsResult += kSettingTiltShiftApplied;
        __currentSettingsResult += self.tiltShift;
    }
    if(self.vignetteStart != kVignette || self.vignetteEnd != kVignette)
    {
        __currentSettingsResult += kSettingVignetteApplied;
        __currentSettingsResult +=  self.vignetteStart + self.vignetteEnd;
    }
    if(self.exposure != kExposure)
    {
        __currentSettingsResult += kSettingExposureApplied;
        __currentSettingsResult += self.exposure;
    }
    if(self.gamma != kGamma)
    {
        __currentSettingsResult += kSettingGammaApplied;
        __currentSettingsResult +=  self.gamma;
    }
    if(self.saturation != kSaturation)
    {
        __currentSettingsResult += kSettingSaturationApplied;
        __currentSettingsResult +=  self.saturation;
    }
    if(self.contrast != kContrast)
    {
        __currentSettingsResult += kSettingContrastApplied;
        __currentSettingsResult += self.contrast;
    }
    if(self.shadows != kShadows)
    {
        __currentSettingsResult += kSettingShadowApplied;
        __currentSettingsResult += self.shadows;
    }
    if(self.highlights != kHighlights)
    {
        __currentSettingsResult += kSettingHighlightApplied;
        
        __currentSettingsResult += self.highlights;
    }
    if(self.sharpness != kSharpness)
    {
        __currentSettingsResult += kSettingSharpnessApplied;
        
        __currentSettingsResult += self.sharpness;
    }
    return __currentSettingsResult;
}





- (BOOL) hasChanges
{
    CGRect defaultTransformRect = CGRectMake(0, 0, 1.0f, 1.0f);
    if(self.textOption ||
       self.textureOption ||
       self.maskOption ||
       self.lightOption ||
       self.camLayerOption ||
       self.filterOption ||
       self.frameOption ||
       self.badgeOption ||
       self.textColor ||
       self.badgeColor ||
       self.frameBackgroundColor ||
       !CGRectEqualToRect(self.transformRect, defaultTransformRect) ||
       !CGRectEqualToRect(self.transformTextRect, defaultTransformRect) ||
       !CGRectEqualToRect(self.transformBadgeRect, defaultTransformRect) ||
       !CGRectEqualToRect(self.transformMaskRect, defaultTransformRect) ||
       self.brightness != kBrightness ||
       self.temperature != kTemperature ||
       self.tiltShift != kTiltShift ||
       self.colorAlpha != kColorAlpha ||
       self.gamma != kGamma ||
       self.tint != kTint ||
       self.exposure != kExposure ||
       self.textureAlpha != kTextureAlpha ||
       self.lightingAlpha != kLightAlpha ||
       self.textAlpha != kTextAlpha ||
       self.contrast != kContrast ||
       self.saturation != kSaturation ||
       self.whiteLevels != kLevelsMax ||
       self.blackLevels != kLevelsMin ||
       self.haze != kHaze ||
       self.unsharpMask != kUnsharpMask ||
       self.highlights != kHighlights ||
       self.shadows != kShadows ||
       self.sharpness != kSharpness ||
       self.vignetteStart != kVignetteStart ||
       (self.rgb.one != 1.0f || self.rgb.two != 1.0f || self.rgb.three != 1.0f) ||
       self.vignetteEnd != kVignetteEnd)
    {
        return YES;
    }
    return NO;
}



- (BOOL) isCurrentPotion
{
    return UserPotionInstance == self ? YES : NO;
}

- (void) changed:(id)option type:(MysticObjectType)optionType
{
    if(![self isCurrentPotion]) return;
    changed = YES;
    NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:optionType], @"type", nil];
    //PotionLog(@"changing... %@", MysticObjectTypeToString(optionType));
    [[NSNotificationCenter defaultCenter] postNotificationName:MysticUserPotionChangedEventName object:nil userInfo:obj];
}

- (PackPotionOptionBadge *) badgeOption
{
    if(_previewOptionBadge) return _previewOptionBadge;
    return _badgeOption;
}

- (PackPotionOptionText *) textOption
{
    if(_previewOptionText) { /*PotionLog(@"ret preview txt: %@", _previewOptionText.isPreviewOption ? @"YES" : @"NO"); */return _previewOptionText; };
    return _textOption;
}

- (PackPotionOptionTexture *) textureOption
{
    if(_previewOptionTexture) return _previewOptionTexture;
    return _textureOption;
}

- (PackPotionOptionLight *) lightOption
{
    if(_previewOptionLight) return _previewOptionLight;
    return _lightOption;
}

- (PackPotionOptionFrame *) frameOption
{
    if(_previewOptionFrame) return _previewOptionFrame;
    return _frameOption;
}

- (PackPotionOptionFilter *) filterOption
{
    if(_previewOptionFilter) return _previewOptionFilter;
    return _filterOption;
}

- (PackPotionOptionCamLayer *) camLayerOption
{
    if(_previewOptionCamLayer) return _previewOptionCamLayer;
    return _camLayerOption;
}

- (PackPotionOptionMask *) maskOption
{
    if(_previewOptionMask) return _previewOptionMask;
    return _maskOption;
}
- (void) setPreviewSize:(CGSize)previewSize;
{
    if(CGSizeEqualToSize(previewSize, CGSizeZero)) return;
    _previewSize = previewSize;
//    SLog(@"setting userpotion preview size", _previewSize);
    
    
}
- (void) setInputSourceImage:(UIImage *)inputSourceImage;
{
    @autoreleasepool {
        if(!inputSourceImage) return;
        self.originalImageSize = CGSizeMake(CGImageGetWidth(inputSourceImage.CGImage), CGImageGetHeight(inputSourceImage.CGImage));
        self.originalImagePath =  [UserPotionManager setImage:inputSourceImage tag:self.originalImageTag cacheType:MysticCacheTypeProject];
    }
}

- (UIImage *) inputSourceImage;
{
    NSString *path = self.originalImagePath;
    if(!path || ![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
    UIImage *simg = [[UIImage alloc] initWithContentsOfFile:path];
    return [simg autorelease];
}

#pragma mark - Prepare Photo


- (void) preparePhoto:(id)media previewSize:(CGSize)size reset:(BOOL)shouldReset finished:(MysticBlockSizeImagePath)finished;
{
    [userInfoPath release], userInfoPath=nil;
    UIImage *oImage = [media isKindOfClass:[UIImage class]] ? media : [media objectForKey:UIImagePickerControllerOriginalImage];
    if(shouldReset)
    {
        self.isPrepared = NO;
        self.sourceImagePath = nil;
        self.sourceImageResizedPath = nil;
        self.thumbnailImagePath = nil;
    }
    [self prepareWithSource:oImage previewSize:size media:media finished:finished];
    
}
- (void) prepareWithSource:(UIImage *)oImage previewSize:(CGSize)size media:(NSDictionary *)media finished:(MysticBlockSizeImagePath)finished;
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    UIImage *sourceImage = media && [media isKindOfClass:[NSDictionary class]] && [media objectForKey:UIImagePickerControllerEditedImage] ? [media objectForKey:UIImagePickerControllerEditedImage] : oImage;

    if(!oImage || !sourceImage)
    {
        if(finished) finished(MysticSizeUnknown, nil, nil);
        [pool drain]; pool = nil;
        return;
    }
    
    CGSize __sourceSize = [MysticImage sizeInPixels:sourceImage];
    CGSize fullSize = [MysticUI scaleSize:size scale:[Mystic scale]];
    CGRect cropRect = CGRectz(CGRectIntegral([MysticUI aspectFit:[MysticUI rectWithSize:__sourceSize] bounds:[MysticUI rectWithSize:fullSize]]));
    UIGraphicsBeginImageContextWithOptions(cropRect.size, YES, 1);
    CGRect drawRect = cropRect;
    [sourceImage drawInRect:drawRect];
    UIImage* newResizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    __unsafe_unretained __block UserPotionBase *ws = self;
    __unsafe_unretained __block MysticBlockSizeImagePath f = finished ? Block_copy(finished) : nil;
    __unsafe_unretained __block UIImage *__newResizedImage = newResizedImage ? [newResizedImage retain] : nil;
    self.renderSize = CGSizeMake(CGImageGetWidth(newResizedImage.CGImage), CGImageGetHeight(newResizedImage.CGImage));
    self.previewSize = self.renderSize;
    if(!self.sourceImagePath && sourceImage)
    {
        [MysticImage scaledImage:sourceImage toSize:CGSizeConstrain([MysticImage sizeInPixels:sourceImage], [MysticUser user].maximumRenderSize) withQuality:1 finished:^(UIImage *newSourceImage) {
            __unsafe_unretained __block UIImage *__newSourceImage = newSourceImage ? [newSourceImage retain] : nil;
            [ws setSourceImage:__newSourceImage finished:^{
                [ws setSourceImageResized:__newResizedImage finished:^{
                    if(ws.sourceImageResizedPath && ws.sourceImagePath && !ws.isPrepared)
                    {
                        NSString *sourcePath = ws.sourceImagePath;
                        NSString *resizePath = ws.sourceImageResizedPath;
                        sourcePath = [sourcePath lastPathComponent];
                        resizePath = [resizePath lastPathComponent];
                        [[ws class] addHistoryItem:@{@"source": sourcePath,@"resized": resizePath}];
                        ws.isPrepared = YES;
                        mdispatch(^{
                                if(f) { f(ws.previewSize, __newSourceImage, ws.sourceImagePath); Block_release(f); }
                                if(__newSourceImage) [__newSourceImage release];
                                if(__newResizedImage) [__newResizedImage release];
                            });
                        
                        
                        
                        
                        mdispatch_bg(^{ if(!ws.originalImagePath && ws.historyIndex == NSNotFound && ws.historyIndex != 0) ws.originalImagePath = ws.sourceImagePath; });
                        
                    }
                }];
            }];
        }];
    }
    else if(self.sourceImagePath && !self.isPrepared)
    {
        self.isPrepared = YES;
        if(f) { f(cropRect.size, __newResizedImage, self.sourceImagePath); Block_release(f); }
        if(__newResizedImage) [__newResizedImage release];
    }
    else
    {
        if(__newResizedImage) [__newResizedImage release];
        if(f) Block_release(f);

    }
    [pool drain];

}
- (void) setMedia:(NSDictionary *)media
{
    UIImage *oImage = [media objectForKey:UIImagePickerControllerOriginalImage];
    [UserPotionManager setImage:oImage layerLevel:kPhotoLayerLevel tag:@"original" type:MysticImageTypeJPG cacheType:MysticCacheTypeProject];
    self.originalImageSize = CGSizeMake(CGImageGetWidth(oImage.CGImage), CGImageGetHeight(oImage.CGImage));
    
    
    self.sourceImage = [media objectForKey:UIImagePickerControllerEditedImage] ? [media objectForKey:UIImagePickerControllerEditedImage] : [media objectForKey:UIImagePickerControllerOriginalImage];
}


- (NSString *) originalImageTag;
{
    return [NSString stringWithFormat:@"%@-original", self.historyChangeIndex == self.historyIndexZero ? @(self.historyIndexZero) : [NSString stringWithFormat:@"%d-%d", (int)self.historyIndexZero, (int)self.historyChangeIndex]];
}
- (NSString *) sourceImageTag;
{
    return [NSString stringWithFormat:@"%@-source",  self.historyChangeIndex == self.historyIndexZero ? @(self.historyIndexZero) : [NSString stringWithFormat:@"%d-%d", (int)self.historyIndexZero, (int)self.historyChangeIndex]];
}
- (NSString *) sourceImageResizedTag;
{
    return [NSString stringWithFormat:@"%@-small",  self.historyChangeIndex == self.historyIndexZero ? @(self.historyIndexZero) : [NSString stringWithFormat:@"%d-%d", (int)self.historyIndexZero, (int)self.historyChangeIndex]];
    
}
- (NSString *) thumbnailTag;
{
    return [NSString stringWithFormat:@"%@-thumb",  self.historyChangeIndex == self.historyIndexZero ? @(self.historyIndexZero) : [NSString stringWithFormat:@"%d-%d", (int)self.historyIndexZero, (int)self.historyChangeIndex]];
    
}
- (UIImage *) originalImage;
{
    if(self.originalImagePath && [[NSFileManager defaultManager] fileExistsAtPath:self.originalImagePath])
    {
        UIImage *simg = [[UIImage alloc] initWithContentsOfFile:self.originalImagePath];;
        if(simg) return [simg autorelease];
    }
    if(CGSizeEqualToSize(self.originalImageSize, CGSizeZero)) return nil;
    return [UserPotionManager getProjectImageForSize:self.originalImageSize layerLevel:kPhotoLayerLevel tag:[self originalImageTag]];
}

- (UIImage *) sourceImage
{
    if(self.sourceImagePath)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:self.sourceImagePath])
        {
            UIImage *simg = [[UIImage alloc] initWithContentsOfFile:self.sourceImagePath];
            
            if(simg) return [simg autorelease];
        }
    }
    
    if(CGSizeEqualToSize(self.sourceImageSize, CGSizeZero)) return nil;
    UIImage *img = [UserPotionManager getProjectImageForSize:self.sourceImageSize layerLevel:kPhotoLayerLevel tag:[self sourceImageTag]];
    return img;
}




- (UIImage *) sourceImageResized:(CGSize)size
{
    if(CGSizeEqualToSize(size, CGSizeZero)) return nil;
    UIImage *i = [UserPotionManager getProjectImageForSize:size layerLevel:kPhotoLayerLevel tag:self.tag];
    
    return i ? i : nil;
}

- (UIImage *) sourceImageResized
{
    NSString *path = self.sourceImageResizedPath;
    if(path)
    {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:path])
        {
            UIImage *simg = [[UIImage alloc] initWithContentsOfFile:path];
        
            if(simg) return [simg autorelease];
        }
    }
    return [self sourceImageResized:self.previewSize];
}

- (void) setSourceImage:(UIImage *)sourceImage;
{
    [self setSourceImage:sourceImage finished:nil];
}

- (void) setSourceImage:(UIImage *)sourceImage finished:(MysticBlock)finished;
{
    @autoreleasepool {
        
        
        [self.renderedOptions removeAllObjects];
        if(resizedImages) [resizedImages removeAllObjects];
        
        self.uniqueTag = self.uniqueTag ? [self.uniqueTag copy] : [@"proj-" stringByAppendingString:[Mystic randomHash]];
        
        if(sourceImage)
        {
            self.sourceImageSize = CGSizeConstrain([MysticImage sizeInPixels:sourceImage], [MysticUser user].maximumRenderSize);
            if(self.originalImagePath && CGSizeEqualToSize(self.sourceImageSize, self.originalImageSize) && (self.historyIndex == NSNotFound && self.historyIndex != 0))
            {
                self.sourceImagePath = self.originalImagePath;
                if(finished) finished();
            }
            else
            {
                __unsafe_unretained __block MysticBlock __finished = finished ? Block_copy(finished) : nil;
                __unsafe_unretained __block UserPotionBase *ws = self;
                
                [UserPotionManager setImage:sourceImage layerLevel:0 tag:[self sourceImageTag] type:MysticImageTypeJPG cacheType:MysticCacheTypeProject finishedPath:^(NSString *string) {
                    ws.sourceImagePath = string;
                    BOOL exists = NO;
                    while (!exists) {
                        exists = [[NSFileManager defaultManager] fileExistsAtPath:string];
                        if(exists && __finished) { __finished(); Block_release(__finished); }
                    }
                }];
            }
            [self changed:sourceImage type:MysticObjectTypeImage];
        }
        else
        {
            self.sourceImagePath=nil;
            [self changed:sourceImage type:MysticObjectTypeImage];
            if(finished) finished();
        }
    }
}
- (UIImage *)thumbnailPreviewImage;
{
    UIImage *thumb = self.thumbnailImage;
    return !thumb ? [UIImage imageNamed:@"none_controlImage"] : thumb;
}
- (UIImage *)thumbnailImage;
{
    if(self.thumbnailImagePath)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:self.thumbnailImagePath])
        {
            UIImage *simg = [[UIImage alloc] initWithContentsOfFile:self.thumbnailImagePath];
            if(simg) return [simg autorelease];
        }
    }
    return nil;
}

- (void) setThumbnailImage:(UIImage *)image;
{
    if(!image) { self.thumbnailImagePath = nil; return; }
    @autoreleasepool {
        self.thumbnailImagePath = [UserPotionManager setImage:[[[UIImage alloc] initWithData:UIImageJPEGRepresentation(image, 0.7) scale:image.scale] autorelease] layerLevel:kPhotoLayerLevel tag:self.thumbnailTag type:MysticImageTypeJPG cacheType:MysticCacheTypeProject];
    }
}

- (void) setSourceImageResized:(UIImage *)sourceImageResized
{
    [self setSourceImageResized:sourceImageResized finished:nil];
}
- (void) setSourceImageResized:(UIImage *)sourceImageResized finished:(MysticBlock)finished;
{
    if(sourceImageResized)
    {
        __unsafe_unretained __block MysticBlock __finished = finished ? Block_copy(finished) : nil;
        __unsafe_unretained __block UserPotionBase *ws = self;
        __unsafe_unretained __block UIImage *__sourceImageResized = [sourceImageResized retain];
        [UserPotionManager setImage:__sourceImageResized layerLevel:0 tag:[[self sourceImageResizedTag] stringByAppendingString:@"preview"] type:MysticImageTypeJPG cacheType:MysticCacheTypeProject finishedPath:^(NSString *string) {
            ws.sourceImageResizedPath = string;
            
            
            [MysticImage scaledImage:__sourceImageResized toSize:CGSizeConstrain([MysticImage sizeInPixels:__sourceImageResized], CGSizeMake(350, 350)) withQuality:0.5 finished:^(UIImage *newThumbImage) {
                ws.thumbnailImage = newThumbImage;
                [__sourceImageResized release];
                
            }];
            BOOL exists = NO;
            while (!exists) {
                exists = [[NSFileManager defaultManager] fileExistsAtPath:string];
                if(exists && __finished) runBlock(__finished);
            }
            
        }];
    }
    else
    {
        self.sourceImageResizedPath = nil;
        if(finished) finished();
    }
}


+ (UIImage *) imageOfRenderSize:(UIImage *)img;
{
    return [[self class] imageOfSize:[[self class] potion].renderSize image:img];
}
+ (UIImage *) imageOfSize:(CGSize)size image:(UIImage *)img;
{
    UIImage *sourceImg = img;
    CGRect imageSourceSize = CGRectZero;
    imageSourceSize.size = sourceImg.size;
    CGRect cropRect = [MysticUI aspectFit:CGRectMake(0, 0, size.width, size.height) bounds:imageSourceSize];
    return [[sourceImg imageByCroppingToRect:cropRect] imageScaledToSize:size];
}

static NSMutableDictionary *resizedImages;

+ (UIImage *) imageOfSize:(CGSize)size;
{
    if(!resizedImages)
    {
        resizedImages = [[NSMutableDictionary dictionary] retain];
        
    }
    NSString *sizeKey = [NSString stringWithFormat:@"%2.0fx%2.0f", size.width, size.height];
    
    if([resizedImages objectForKey:sizeKey])
    {
        return [resizedImages objectForKey:sizeKey];
    }
    
    
    UIImage *sourceImg = [[self class] potion].sourceImageResized;
    sourceImg = sourceImg ? sourceImg : [[self class] potion].sourceImage;
    CGRect imageSourceSize = CGRectZero;
    imageSourceSize.size = sourceImg.size;
    CGRect cropRect = [MysticUI aspectFit:CGRectMake(0, 0, size.width, size.height) bounds:imageSourceSize];
    UIImage *finalImg = [[sourceImg imageByCroppingToRect:cropRect] imageScaledToSize:size];
    
    [resizedImages setObject:finalImg forKey:sizeKey];
    
    return finalImg;
}

#pragma mark - Setters










- (void) setLightOption:(PackPotionOptionLight *)lightOption
{
//    if(_lightOption || _previewOptionLight) { [lightOption applyAdjustmentsFrom:(_previewOptionLight ? _previewOptionLight : _lightOption)]; }

    if(lightOption && lightOption.isPreviewOption) return [self setPreviewOptionLight:lightOption];
    if([Mystic option:lightOption equals:_lightOption]) return;
    if(lightOption == nil || ![Mystic option:lightOption equals:_lightOption])
    {
        
        _lightRotation = kDefaultRotation;
        if(lightOption == nil) {
            _lightingAlpha = kLightAlpha;
            _applyFilterToLight = kApplyFilterToLight;
            self.previewOptionLight = nil;
        }
    }
    
//    if(_lightOption) [_lightOption release], _lightOption = nil;
    if(_lightOption) {
        //[lightOption applyAdjustmentsFrom:_lightOption];
        [_lightOption release], _lightOption = nil;
    };
    _lightOption = lightOption ? [lightOption retain] : nil;
    [self changed:lightOption type:MysticObjectTypeLight];
    
}

- (void) setBadgeOption:(PackPotionOptionBadge *)badgeOption
{
//    if(_badgeOption || _previewOptionBadge) { [badgeOption applyAdjustmentsFrom:(_previewOptionBadge ? _previewOptionBadge : _badgeOption)]; }

    if(badgeOption && badgeOption.isPreviewOption) return [self setPreviewOptionBadge:badgeOption];
    if([Mystic option:badgeOption equals:_badgeOption]) return;
    if(badgeOption == nil  || ![Mystic option:badgeOption equals:_badgeOption])
    {
        
        _badgeRotation = kDefaultRotation;
        
        _transformBadgeRect = CGRectMake(0, 0, 1.0f, 1.0f);
        if(badgeOption == nil){
            _applyFilterToBadge = kApplyFilterToBadge;
            _badgeAlpha = kBadgeAlpha;
            _invertBadgeColor = NO;
            self.previewOptionBadge = nil;
        }
    }
    if(_badgeOption) { //
        //[badgeOption applyAdjustmentsFrom:_badgeOption];
        [_badgeOption release], _badgeOption = nil;
    };
    _badgeOption = badgeOption ? [badgeOption retain] : nil;
    [self changed:badgeOption type:MysticObjectTypeBadge];
    
}

- (void) setMaskOption:(PackPotionOptionMask *)maskOption
{
//    if(_maskOption || _previewOptionMask) { [maskOption applyAdjustmentsFrom:(_previewOptionMask ? _previewOptionMask : _maskOption)]; }
    if(maskOption && maskOption.isPreviewOption) return [self setPreviewOptionMask:maskOption];
    if([Mystic option:maskOption equals:_maskOption]) return;
    if(maskOption == nil  || ![Mystic option:maskOption equals:_maskOption])
    {
        
        _maskRotation = kDefaultRotation;
        self.previewOptionMask = nil;
        _transformMaskRect = CGRectMake(0, 0, 1.0f, 1.0f);
        if(maskOption == nil){

        }
    }
    if(_maskOption) {
        //[maskOption applyAdjustmentsFrom:_maskOption];
        [_maskOption release], _maskOption = nil;
    }
    _maskOption = maskOption ? [maskOption retain] : nil;
    [self changed:_maskOption type:MysticObjectTypeMask];
    
}



- (void) setTextOption:(PackPotionOptionText *)textOption
{
//    if(_textOption || _previewOptionText) { [textOption applyAdjustmentsFrom:(_previewOptionText ? _previewOptionText : _textOption)]; }
    if(textOption && textOption.isPreviewOption)
    {
        return [self setPreviewOptionText:textOption];
    }
    if([Mystic option:textOption equals:_textOption]) return;
    if(textOption == nil || ![Mystic option:textOption equals:_textOption])
    {
        
        
        _textRotation = kDefaultRotation;
        
        _transformTextRect = CGRectMake(0, 0, 1.0f, 1.0f);
        if(textOption == nil) {
            _applyFilterToText = kApplyFilterToText;
            _textAlpha = kTextAlpha;
            _invertTextColor = NO;
            self.previewOptionText = nil;
        }
    }
    if(_textOption) {
//        [textOption applyAdjustmentsFrom:_textOption];
        [_textOption release], _textOption = nil;
    };
    _textOption = textOption ? [textOption retain] : nil;
    [self changed:textOption type:MysticObjectTypeText];
    
}

- (void) setCamLayerOption:(PackPotionOptionCamLayer *)camLayerOption
{
//    if(_camLayerOption || _previewOptionCamLayer) { [camLayerOption applyAdjustmentsFrom:(_previewOptionCamLayer ? _previewOptionCamLayer : _camLayerOption)]; }

    if(_camLayerOption) { camLayerOption.blendingMode = _camLayerOption.blendingMode; }
    if(camLayerOption && camLayerOption.isPreviewOption) return [self setPreviewOptionCamLayer:camLayerOption];
    if([Mystic option:camLayerOption equals:_camLayerOption]) return;
    if(camLayerOption == nil || ![Mystic option:camLayerOption equals:_camLayerOption])
    {
        
        
        _camLayerRotation = kDefaultRotation;
        
        _transformCamLayerRect = CGRectMake(0, 0, 1.0f, 1.0f);
        if(camLayerOption == nil) {
            _applyFilterToCamLayer = kApplyFilterToText;
            _camLayerAlpha = kCamLayerAlpha;
            _invertCamLayerColor = NO;
            self.previewOptionCamLayer = nil;
        }
    }
    if(_camLayerOption) { //[camLayerOption applyAdjustmentsFrom:_camLayerOption];
        [_camLayerOption release], _camLayerOption = nil;
    };
    _camLayerOption = camLayerOption ? [camLayerOption retain] : nil;
    [self changed:camLayerOption type:MysticObjectTypeCamLayer];
    
}

- (void) setFrameOption:(PackPotionOptionFrame *)frameOption
{
//    if(_frameOption || _previewOptionFrame) { [frameOption applyAdjustmentsFrom:(_previewOptionFrame ? _previewOptionFrame : _frameOption)]; }

    if(_frameOption) { frameOption.blendingMode = _frameOption.blendingMode; }
    if(frameOption && frameOption.isPreviewOption) return [self setPreviewOptionFrame:frameOption];
    if([Mystic option:frameOption equals:_frameOption]) return;
    if(frameOption == nil || ![Mystic option:frameOption equals:_frameOption])
    {
        
        _frameRotation = kDefaultRotation;
        _invertFrameColor = NO;
        _transformMaskRect = CGRectMake(0, 0, 1.0f, 1.0f);
        if(frameOption == nil)
        {
            self.previewOptionFrame = nil;
            _frameAlpha = kFrameAlpha;
            
            _applyFilterToFrame = kApplyFilterToFrame;
        }
    }
    if(_frameOption) {
        //[frameOption applyAdjustmentsFrom:_frameOption];
        [_frameOption release], _frameOption = nil;
    };
    _frameOption = frameOption ? [frameOption retain] : nil;
    [self changed:frameOption type:MysticObjectTypeFrame];
    
}

- (void) setTextureOption:(PackPotionOptionTexture *)textureOption
{
//    if(_textureOption || _previewOptionTexture) { [textureOption applyAdjustmentsFrom:(_previewOptionTexture ? _previewOptionTexture : _textureOption)]; }

    if(_textureOption) { textureOption.blendingMode = _textureOption.blendingMode; }
    if(textureOption && textureOption.isPreviewOption) return [self setPreviewOptionTexture:textureOption];
    if([Mystic option:textureOption equals:_textureOption]) return;
    if(textureOption == nil || ![Mystic option:textureOption equals:_textureOption])
    {
        
        _textureRotation = kDefaultRotation;
        if(textureOption == nil)
        {
            _textureAlpha = kTextureAlpha;
            _applyFilterToTexture = kApplyFilterToTexture;
            self.previewOptionTexture = nil;
        }
    }
    if(_textureOption) {
        //[textureOption applyAdjustmentsFrom:_textureOption];
        [_textureOption release], _textureOption = nil;
    };
    _textureOption = textureOption ? [textureOption retain] : nil;
    [self changed:textureOption type:MysticObjectTypeTexture];
    
}

- (void) setFilterOption:(PackPotionOptionFilter *)filterOption
{
//    if(_filterOption || _previewOptionFilter) { [filterOption applyAdjustmentsFrom:(_previewOptionFilter ? _previewOptionFilter : _filterOption)]; }

    if(_filterOption) { filterOption.blendingMode = _filterOption.blendingMode; }
    if(filterOption && filterOption.isPreviewOption) return [self setPreviewOptionFilter:filterOption];
    if([Mystic option:filterOption equals:_filterOption]) return;
    if(filterOption == nil || ![Mystic option:filterOption equals:_filterOption])
    {
        if(filterOption == nil)
        {
            _colorAlpha = kColorAlpha;
            self.previewOptionFilter = nil;
        }
    }
    if(_filterOption) {
        //[filterOption applyAdjustmentsFrom:_filterOption];
        [_filterOption release], _filterOption = nil;
    };
    _filterOption = filterOption ? [filterOption retain] : nil;
    [self changed:filterOption type:MysticObjectTypeFilter];
}



- (void) setInvertTextColor:(BOOL)invertTextColor
{
    _invertTextColor = invertTextColor;
    [self changed:[NSNumber numberWithBool:invertTextColor] type:MysticObjectTypeText];
}


- (void) setInvertCamLayerColor:(BOOL)invertColor
{
    _invertCamLayerColor = invertColor;
    [self changed:[NSNumber numberWithBool:invertColor] type:MysticObjectTypeCamLayer];
}


- (void) setInvertBadgeColor:(BOOL)invertBadgeColor
{
    _invertBadgeColor = invertBadgeColor;
    [self changed:[NSNumber numberWithBool:invertBadgeColor] type:MysticObjectTypeBadge];
}


- (void) setInvertFrameColor:(BOOL)invertFrameColor
{
    _invertFrameColor = invertFrameColor;
    [self changed:[NSNumber numberWithBool:invertFrameColor] type:MysticObjectTypeFrame];
}

- (void) setApplyFilterToBadge:(BOOL)newValue
{
    _applyFilterToBadge = newValue;
    MysticObjectType ot = MysticObjectTypeBadge;
    [[self class] optionForType:ot].blended = newValue;
    [self changed:[NSNumber numberWithBool:newValue] type:ot];
    

}

- (void) setApplyFilterToFrame:(BOOL)newValue
{
    _applyFilterToFrame = newValue;
    MysticObjectType ot = MysticObjectTypeFrame;
    [[self class] optionForType:ot].blended = newValue;
    [self changed:[NSNumber numberWithBool:newValue] type:ot];
    
    
}

- (void) setApplyFilterToText:(BOOL)newValue
{
    _applyFilterToText = newValue;
    MysticObjectType ot = MysticObjectTypeText;
    [[self class] optionForType:ot].blended = newValue;
    [self changed:[NSNumber numberWithBool:newValue] type:ot];
    
    
}

- (void) setApplyFilterToTexture:(BOOL)newValue
{
    _applyFilterToTexture = newValue;
    MysticObjectType ot = MysticObjectTypeTexture;
    [[self class] optionForType:ot].blended = newValue;
    [self changed:[NSNumber numberWithBool:newValue] type:ot];
    
    
}

- (void) setApplyFilterToLight:(BOOL)newValue
{
    _applyFilterToLight = newValue;
    MysticObjectType ot = MysticObjectTypeLight;
    [[self class] optionForType:ot].blended = newValue;
    [self changed:[NSNumber numberWithBool:newValue] type:ot];
    
    
}

- (void) setApplySunshineToFilter:(BOOL)newValue
{
    _applySunshineToFilter = newValue;
    MysticObjectType ot = MysticObjectTypeFilter;
    [[self class] optionForType:ot].applySunshine = newValue;
    [self changed:[NSNumber numberWithBool:newValue] type:ot];
    
    
}


- (void) setBadgeAlpha:(float)badgeAlpha
{
    _badgeAlpha=badgeAlpha;
    [self changed:[NSNumber numberWithFloat:badgeAlpha] type:MysticSettingBadgeAlpha];
}

- (void) setTextAlpha:(float)textAlpha
{
    _textAlpha=textAlpha;
    [self changed:[NSNumber numberWithFloat:textAlpha] type:MysticSettingTextAlpha];
}

- (void) setTextRotation:(float)newValue;
{
    _textRotation = newValue;
    [[self class] optionForType:MysticObjectTypeText].rotation = newValue;
    
}



- (void) setCamLayerAlpha:(float)alpha
{
    _camLayerAlpha=alpha;
    [self changed:[NSNumber numberWithFloat:alpha] type:MysticSettingCamLayerAlpha];
}

- (void) setTextureAlpha:(float)textureAlpha
{
    _textureAlpha=textureAlpha;
    [self changed:[NSNumber numberWithFloat:textureAlpha] type:MysticSettingTextureAlpha];
}

- (void) setLightingAlpha:(float)lightingAlpha
{
    _lightingAlpha=lightingAlpha;
    [self changed:[NSNumber numberWithFloat:lightingAlpha] type:MysticSettingLightingAlpha];
}

- (void) setBrightness:(float)brightness
{
    _brightness=brightness;
    [self changed:[NSNumber numberWithFloat:brightness] type:MysticSettingBrightness];
}

- (void) setTemperature:(float)temperature
{
    _temperature=temperature;
    [self changed:[NSNumber numberWithFloat:temperature] type:MysticSettingTemperature];
}

- (void) setTiltShift:(float)tiltShift
{
    _tiltShift=tiltShift;
    [self changed:[NSNumber numberWithInt:tiltShift] type:MysticSettingTiltShift];
}

- (void) setColorAlpha:(float)colorAlpha
{
    _colorAlpha=colorAlpha;
    [self changed:[NSNumber numberWithFloat:colorAlpha] type:MysticSettingFilterAlpha];
}

- (void) setHighlights:(float)highlights
{
    _highlights=highlights;
    [self changed:[NSNumber numberWithFloat:highlights] type:MysticSettingHighlights];
}

- (void) setHaze:(float)value
{
    _haze=value;
    [self changed:[NSNumber numberWithFloat:value] type:MysticSettingHaze];
}

- (void) setWhiteLevels:(float)value
{
    _whiteLevels=value;
    [self changed:[NSNumber numberWithFloat:value] type:MysticSettingLevels];
}

- (void) setUnsharpMask:(float)value
{
    _unsharpMask=value;
    [self changed:[NSNumber numberWithFloat:value] type:MysticSettingUnsharpMask];
}

- (void) setBlackLevels:(float)value
{
    _blackLevels=value;
    [self changed:[NSNumber numberWithFloat:value] type:MysticSettingLevels];
}

- (void) setShadows:(float)shadows
{
    _shadows=shadows;
    [self changed:[NSNumber numberWithFloat:shadows] type:MysticSettingShadows];
}

- (void) setContrast:(float)contrast
{
    _contrast=contrast;
    [self changed:[NSNumber numberWithFloat:contrast] type:MysticSettingContrast];
}

- (void) setSharpness:(float)sharpness
{
    _sharpness=sharpness;
    [self changed:[NSNumber numberWithFloat:sharpness] type:MysticSettingSharpness];
}

- (void) setSaturation:(float)saturation
{
    _saturation=saturation;
    [self changed:[NSNumber numberWithFloat:saturation] type:MysticSettingSaturation];
}

- (void) setVignetteEnd:(float)vignetteEnd
{
    _vignetteEnd=vignetteEnd;
    [self changed:[NSNumber numberWithFloat:vignetteEnd] type:MysticSettingVignette];
}

- (void) setVignetteStart:(float)vignetteStart
{
    _vignetteStart=vignetteStart;
    [self changed:[NSNumber numberWithFloat:vignetteStart] type:MysticSettingVignette];
}

- (void) setTextColor:(UIColor *)textColor
{
    if(_textColor) [_textColor release], _textColor=nil;
    _textColor = [textColor retain];
    [self changed:textColor type:MysticSettingTextColor];
}

- (void) setBadgeColor:(UIColor *)badgeColor
{
    if(_badgeColor) [_badgeColor release], _badgeColor=nil;
    _badgeColor = [badgeColor retain];
    [self changed:badgeColor type:MysticSettingTextColor];
}

- (void) setFrameBackgroundColor:(UIColor *)frameBackgroundColor
{
    if(_frameBackgroundColor) [_frameBackgroundColor release], _frameBackgroundColor=nil;
    _frameBackgroundColor = [frameBackgroundColor retain];
    [self changed:_frameBackgroundColor type:MysticSettingFrameColor];
}

- (void) setExposure:(float)exposure
{
    _exposure=exposure;
    [self changed:[NSNumber numberWithFloat:exposure] type:MysticSettingExposure];
}

- (void) setGamma:(float)gamma
{
    _gamma=gamma;
    [self changed:[NSNumber numberWithFloat:gamma] type:MysticSettingGamma];
}

- (void) setTransformRect:(CGRect)transformRect
{
    _transformRect = transformRect;
    [self changed:[NSValue valueWithCGRect:transformRect] type:MysticSettingTransform];
}

- (void) setTransformMaskRect:(CGRect)transformMaskRect
{
    _transformMaskRect=transformMaskRect;
    [[self class] optionForType:MysticObjectTypeFrame].transformRect = transformMaskRect;
    [self changed:[NSValue valueWithCGRect:transformMaskRect] type:MysticSettingMaskTransform];
}

- (void) setTransformTextRect:(CGRect)newValue
{
    _transformTextRect=newValue;
//    [[self class] optionForType:MysticObjectTypeText].transformRect = newValue;
    [self changed:[NSValue valueWithCGRect:newValue] type:MysticSettingTextTransform];
}

- (void) setTransformCamLayerRect:(CGRect)newValue;
{
    _transformCamLayerRect=newValue;
//    [[self class] optionForType:MysticObjectTypeCamLayer].transformRect = newValue;
    [self changed:[NSValue valueWithCGRect:newValue] type:MysticSettingCamLayer];
}



- (void) setTransformBadgeRect:(CGRect)transformBadgeRect
{
    _transformBadgeRect=transformBadgeRect;
//    [[self class] optionForType:MysticObjectTypeBadge].transformRect = transformBadgeRect;
    [self changed:[NSValue valueWithCGRect:transformBadgeRect] type:MysticSettingBadgeTransform];
}

- (void) setPreviewOptionBadge:(PackPotionOptionBadge *)option
{
    option.isPreviewOption = YES;
    if([Mystic option:option equals:_previewOptionBadge]) return;
    if(option == nil || ![Mystic option:option equals:_previewOptionBadge])
    {
        
        _badgeRotation = kDefaultRotation;
        _transformBadgeRect = kDefaultTransform;
        if(option == nil)
        {
            _badgeAlpha = kBadgeAlpha;
            _applyFilterToBadge = kApplyFilterToBadge;
        }
        
    }
    if(_previewOptionBadge) {
        //[option applyAdjustmentsFrom:_previewOptionBadge];
        [_previewOptionBadge release], _previewOptionBadge = nil;
    };
    _previewOptionBadge = option ? [option retain] : nil;
    [self changed:option type:option.type];
}

- (void) setPreviewOptionText:(PackPotionOptionText *)option
{
    option.isPreviewOption = YES;
    if(_previewOptionText) { _previewOptionText.isPreviewOption=YES; option.blendingMode = _previewOptionText.blendingMode; }
    if([Mystic option:option equals:_previewOptionText]) {  return;}
    if(option == nil || ![Mystic option:option equals:_previewOptionText])
    {
        
        _textRotation = kDefaultRotation;
        _transformTextRect = kDefaultTransform;
        if(option == nil)
        {
            _textAlpha = kTextAlpha;
            _applyFilterToText = kApplyFilterToText;
        }
    }
    if(_previewOptionText) {
        //[option applyAdjustmentsFrom:_previewOptionText];
        [_previewOptionText release], _previewOptionText = nil;
    };
    _previewOptionText = option ? [option retain] : nil;
    
    [self changed:option type:option.type];
}
- (void) setPreviewOptionTexture:(PackPotionOptionTexture *)option
{
    option.isPreviewOption = YES;
    if([Mystic option:option equals:_previewOptionTexture]) return;
    if(option == nil || ![Mystic option:option equals:_previewOptionTexture])
    {
        
        _textureRotation = kDefaultRotation;
        if(option == nil)
        {
            _textureAlpha = kTextureAlpha;
            _applyFilterToTexture = kApplyFilterToTexture;
        }
    }
    if(_previewOptionTexture) { //[option applyAdjustmentsFrom:_previewOptionTexture];
        [_previewOptionTexture release], _previewOptionTexture = nil; };
    _previewOptionTexture = option ? [option retain] : nil;
    [self changed:option type:option.type];
}
- (void) setPreviewOptionFrame:(PackPotionOptionFrame *)option
{
    option.isPreviewOption = YES;
    if([Mystic option:option equals:_previewOptionFrame]) return;
    if(option == nil || ![Mystic option:option equals:_previewOptionFrame])
    {
        
        _frameRotation = kDefaultRotation;
        _transformMaskRect = kDefaultTransform;
        if(option == nil)
        {
            _frameAlpha = kFrameAlpha;
            _applyFilterToFrame = kApplyFilterToFrame;
        }
    }
    if(_previewOptionFrame) { //[option applyAdjustmentsFrom:_previewOptionFrame];
        [_previewOptionFrame release], _previewOptionFrame = nil;
    };
    _previewOptionFrame = option ? [option retain] : nil;
    [self changed:option type:option.type];
}
- (void) setPreviewOptionLight :(PackPotionOptionLight *)option
{
    option.isPreviewOption = YES;
    if([Mystic option:option equals:_previewOptionLight]) return;
    if(option == nil || ![Mystic option:option equals:_previewOptionLight])
    {
        
        _lightRotation = kDefaultRotation;
        if(option == nil)
        {
            _lightingAlpha = kLightAlpha;
            _applyFilterToLight = kApplyFilterToLight;
        }
    }
    if(_previewOptionLight) { //[option applyAdjustmentsFrom:_previewOptionLight];
        [_previewOptionLight release], _previewOptionLight = nil;
    };
    _previewOptionLight = option ? [option retain] : nil;
    [self changed:option type:option.type];
}
- (void) setPreviewOptionFilter:(PackPotionOptionFilter *)option
{
    option.isPreviewOption = YES;
    if([Mystic option:option equals:_previewOptionFilter]) return;
    if(option == nil || ![Mystic option:option equals:_filterOption])
    {
        
        if(option == nil)
        {
            _colorAlpha = kColorAlpha;
        }
    }
    if(_previewOptionFilter) { //[option applyAdjustmentsFrom:_previewOptionFilter];
        [_previewOptionFilter release], _previewOptionFilter = nil;
    };
    _previewOptionFilter = option ? [option retain] : nil;
    [self changed:option type:option.type];
}


- (void) setSettingsOption:(PackPotionOptionSetting *)option
{
//    if(_settingsOption || _previewOptionSettings) { [option applyAdjustmentsFrom:(_previewOptionSettings ? _previewOptionSettings : _settingsOption)]; }
    
    if(option && option.isPreviewOption) return [self setPreviewOptionSettings:option];
    if([Mystic option:option equals:_settingsOption]) return;
    if(option == nil || ![Mystic option:option equals:_settingsOption])
    {
        if(option == nil)
        {
            self.previewOptionSettings = nil;
        }
    }
    if(_settingsOption) {
        //[option applyAdjustmentsFrom:_settingsOption];
        [_settingsOption release], _settingsOption = nil;
    };
    _settingsOption = option ? [option retain] : nil;
    [self changed:option type:option.type];
    
}

- (void) setPreviewOptionSettings:(PackPotionOptionSetting *)option;
{
    option.isPreviewOption = YES;
    if([Mystic option:option equals:_previewOptionSettings]) return;

    if(_previewOptionSettings) { //[option applyAdjustmentsFrom:_previewOptionSettings];
        [_previewOptionSettings release], _previewOptionSettings = nil;
    };
    _previewOptionSettings = option ? [option retain] : nil;
    [self changed:option type:option.type];
}



@end
