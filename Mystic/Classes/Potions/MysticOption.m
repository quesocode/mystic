//
//  MysticOption.m
//  Mystic
//
//  Created by Travis on 10/9/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticOption.h"
#import "MysticPreloaderImage.h"
#import "MysticCache.h"
#import "MysticOptions.h"
#import "MysticFilterManager.h"

@interface MysticOption ()
{
    id __transformFilter, __layer;
    NSMutableArray *_optionObservers;
}
@property (nonatomic, assign) BOOL updateFiltersRequired;
@end
@implementation MysticOption

@synthesize readyForRender=_readyForRender, isDownloaded=_isDownloaded, isDownloading=_isDownloading, downloads=_downloads, numberOfDownloads=_numberOfDownloads, numberOfDownloaded=_numberOfDownloaded, numberOfDownloadsLeft, downloader=_downloader, prepared=_prepared, downloadURLs, shortName, owner=__owner, weakOwner=__weakOwner, shouldRender=_shouldRender, picture=__picture, editState=_editState, showLayerPreview=_showLayerPreview, icon=_icon, autoLevel=_autoLevel, levelRules=_levelRules, isConfirmed=_isConfirmed, lastPicked=_lastPicked, inFocus=_inFocus, hasOverlaysToRender=_hasOverlaysToRender, refreshState=_refreshState, ownedLayer=_ownedLayer, isRenderableOption=_isRenderableOption, isAdded=_isAdded, canReorder=_canReorder, sourceNeedsRefresh=_sourceNeedsRefresh, shaderIndex=_shaderIndex, imageFilter=_imageFilter, preparedWithSettings=_preparedWithSettings, targetOption=_targetOption, canReplaceColor=_canReplaceColor, state=_state, createNewCopy=_createNewCopy, instanceIndex=_instanceIndex, sourceImage=_sourceImage, renderedImage=_renderedImage, sourceImageInput=_sourceImageInput, userChoiceRequiresImageReload=_userChoiceRequiresImageReload, ignoreActualRender=_ignoreActualRender, allowColorReplacement=_allowColorReplacement, hasRendered=_hasRendered, tempInfo=_tempInfo;

+ (MysticObjectType) typeForClass:(Class)optionClass;
{
    MysticObjectType type = MysticObjectTypeUnknown;
    NSString *classStr = [NSString stringWithFormat:@"%@", optionClass];
    if([classStr hasSuffix:@"Font"])
    {
        type = MysticObjectTypeFont;
    }
    else if([classStr hasSuffix:@"Frame"])
    {
        type = MysticObjectTypeFrame;
    }
    else if([classStr hasSuffix:@"Text"])
    {
        type = MysticObjectTypeDesign;
    }
    else if([classStr hasSuffix:@"Texture"])
    {
        type = MysticObjectTypeTexture;
    }
    else if([classStr hasSuffix:@"Color"])
    {
        type = MysticObjectTypeColor;
    }
    else if([classStr hasSuffix:@"Blend"])
    {
        type = MysticObjectTypeBlend;
    }
    else if([classStr hasSuffix:@"Shape"])
    {
        type = MysticObjectTypeShape;
    }
    else if([classStr hasSuffix:@"Badge"])
    {
        type = MysticObjectTypeBadge;
    }
    else if([classStr hasSuffix:@"Light"])
    {
        type = MysticObjectTypeLight;
    }
    else if([classStr hasSuffix:@"Filter"])
    {
        type = MysticObjectTypeFilter;
    }
    else if([classStr hasSuffix:@"Setting"])
    {
        type = MysticObjectTypeSetting;
    }
    return type;
}
+ (id) option;
{
    MysticObjectType type = [[self class] typeForClass:[self class]];
    MysticOption *option = [[self class] optionWithName:MyString(type) info:@{}];
    option.type = type;
    return option;
}
+ (id) optionWithName:(NSString *)name image:(id)imageOrImageName type:(MysticObjectType)type info:(NSDictionary *)optionInfo;
{
    MysticOption *option = [[self classForType:type] optionWithName:name info:optionInfo];
    option.type = type;
    UIImage *sourceImage = nil;
    if([imageOrImageName isKindOfClass:[UIImage class]])
    {
        option.sourceImage = imageOrImageName;
    }
    else
    {
        option.sourceImageInput = imageOrImageName;
    }
    
    return option;
}
- (void) dealloc;
{
    [_optionSlotKey release];
    _imageFilter = nil;
    __owner = nil;
    __weakOwner = nil;
    [_packIndex release], _packIndex = nil;
    __transformFilter = nil;
    if(__layer) [__layer release];
    [_adjustOrder release];
    __layer = nil;
    __picture = nil;
    [_sourceImageInput release];
    [_tempInfo release];
    [_ownedLayer release];
    [_targetOption release];
    [_ownedLayer release];
    [_downloader release];
    [_downloads release];
    if(_sourceImage) [_sourceImage release];
    if(_renderedImage) [_renderedImage release];
    if(_imageViewBlock) Block_release(_imageViewBlock), _imageViewBlock=nil;
    [_optionObservers release];
    if(_iconImg) [_iconImg release];
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        _hasRendered = NO;
        _iconImg=nil;
        _resetAdjustmentsAfterCancel = YES;
        _isDefaultChoice = NO;
        _state = MysticOptionStateNone;
        _adjustOrder = [[NSMutableArray array] retain];
        _preparedWithSettings = MysticRenderOptionsNone;
        _numberOfDownloads = NSNotFound;
        _tempInfo = [[NSMutableDictionary alloc] init];
        _numberOfDownloaded = 0;
        _optionObservers = [[NSMutableArray array] retain];
        _readyForRender = NO;
        _iconImgError = NO;
        _prepared = NO;
        _cameFromFeaturedPack = NO;
        _isConfirmed = NO;
        _sourceNeedsRefresh = NO;
        _canReorder = YES;
        _setting = MysticSettingUnknown;
        _instanceIndex = NSNotFound;
        _inFocus = NO;
        _canReplaceColor = NO;
        _isRenderableOption = YES;
        _userChoiceRequiresImageReload = NO;
        _downloader = nil;
        _createNewCopy = NO;
        _refreshState = MysticSettingNone;
        __layer = nil;
        _updateFiltersRequired = NO;
        __weakOwner = nil;
        _hasOverlaysToRender = NO;
        __transformFilter = nil;
        _showLayerPreview = YES;
        _autoLevel = NSNotFound;
        _levelRules = 0;
        _lastPicked = NO;
        __owner = nil;
    }
    return self;
}

- (BOOL) shouldApplyAdjustmentsFromSimilarOption; { return YES; }
- (void) resetAdjustOrder;
{
    [self.adjustOrder removeAllObjects];
}
- (void) removeAdjustOrder:(MysticObjectType)setting;
{
    if([self.adjustOrder containsObject:@(setting)]) [self.adjustOrder removeObject:@(setting)];
}
- (void) addAdjustOrder:(MysticObjectType)setting;
{
    if(![self.adjustOrder containsObject:@(setting)]) [self.adjustOrder addObject:@(setting)];
}
- (id) tempValueForKey:(id)keyOrSettingObjKey;
{
    return keyOrSettingObjKey ? self.tempInfo[keyOrSettingObjKey]: nil;
}
- (void) setTempInfo:(id)value key:(id)keyOrSettingObjKey;
{
    if(!keyOrSettingObjKey) return;
    if(!value) { [self.tempInfo removeObjectForKey:keyOrSettingObjKey]; return; }
    self.tempInfo[keyOrSettingObjKey] = value;
}
- (UIColor *) specialColor; { return nil; }
- (void) commonInit;
{
    [super commonInit];
    if(isM(self.info[@"requiresCompleteReload"])) self.requiresCompleteReload = [self.info[@"requiresCompleteReload"] boolValue];
}
- (BOOL) hasObserver:(NSObject *)observer;
{
    return [_optionObservers containsObject:observer];
}
- (void) addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
{
    [_optionObservers addObject:observer];
    [super addObserver:observer forKeyPath:keyPath options:options context:context];
    
}

- (void) removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
{
    if([_optionObservers containsObject:observer]) [_optionObservers removeObjectAtIndex:[_optionObservers indexOfObject:observer]];
    [super removeObserver:observer forKeyPath:keyPath];
}

- (void) removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
{
    if([_optionObservers containsObject:observer]) [_optionObservers removeObjectAtIndex:[_optionObservers indexOfObject:observer]];
    [super removeObserver:observer forKeyPath:keyPath context:context];
}

- (void) setCreateNewCopy:(BOOL)createNewCopy;
{
    if(createNewCopy) self.optionSlotKey = [MysticOptions slotKeyForOption:(id)self];
    _createNewCopy = createNewCopy;
}
- (CGFloat) increment:(MysticToolType)toolType;
{
    switch (toolType)
    {
        case MysticToolTypeRotateRight:
        {
            return kRotateStepIncrement;
        }
        case MysticToolTypeRotateLeft:
        {
            return kRotateStepIncrement * -1;
        }
        case MysticToolTypeSizeBigger:
        {
            return kSizeStepIncrement;
        }
        case MysticToolTypeSizeSmaller:
        {
            return kSizeStepIncrement * -1;

        }
        case MysticToolTypePanLeft:
        {
            return kMoveStepIncrement * -1;

        }
        case MysticToolTypePanRight:
        {
            return kMoveStepIncrement;

        }
        case MysticToolTypePanUp:
        {
            return -1*kMoveStepIncrement;

        }
        case MysticToolTypePanDown:
        {
            return kMoveStepIncrement;
        }
            
        default: break;
    }
    return 0;
}
- (void) valueChanged:(MysticToolType)toolType change:(NSNumber *)amount;
{
    
}
- (MysticObjectType) accessorySetting;
{
    return self.setting;
}
- (BOOL) hasValues; { return YES; }
- (BOOL) requiresFrameRefresh; { return NO; }
- (BOOL) fillTransparency; { return NO; }
- (BOOL) fillBackgroundColor; { return NO; }
- (BOOL) canBeChosen; { return YES; }
- (BOOL) canChooseCancelColor; { return NO; }
- (BOOL) canInvertTexture; { return YES; }

- (BOOL) isSelectableOption; { return YES; }
- (void) reordered;
{
    [self update];
}
- (void) update;
{
    
}

- (void) setColorOption:(PackPotionOptionColor *)colorOption;
{
    
}
- (MysticImageLayer *) sourceImage;
{
    return [self sourceImageAtSize:MysticSizeOriginal contentMode:UIViewContentModeScaleToFill];
}
- (MysticImageLayer *) sourceImageAtSize:(CGSize)atSize;
{
    return (id)[self sourceImageAtSize:atSize contentMode:UIViewContentModeScaleToFill];
}
- (MysticImageLayer *) sourceImageAtSize:(CGSize)atSize contentMode:(UIViewContentMode)contentMode;
{
    return (id)[MysticImageLayer image:self.sourceImageInput size:atSize color:nil contentMode:contentMode];
}
- (BOOL) hasSourceImage;
{
    return _sourceImage != nil || _sourceImageInput != nil;
}
- (id) sourceImageInput;
{
    return _sourceImage ? _sourceImage : _sourceImageInput;
}
- (void) setupFilter:(MysticImageFilter *)imageFilter;
{

}

- (void) setInFocus:(BOOL)value;
{
    _inFocus = value;
    if(value)
    {
        [self disableState:MysticOptionStateOutOfFocus];
        [self enableState:MysticOptionStateInFocus];
    }
    else
    {
        [self disableState:MysticOptionStateInFocus];
        [self enableState:MysticOptionStateOutOfFocus];

    }
}
- (void) setIsConfirmed:(BOOL)value;
{
    _isConfirmed = value;
    if(value)
    {
        [self disableState:MysticOptionStateUnconfirmed];
        [self enableState:MysticOptionStateConfirmed];

    }
    else
    {
        [self disableState:MysticOptionStateConfirmed];
        [self enableState:MysticOptionStateUnconfirmed];

    }
}
- (void) enableState:(MysticOptionState)state;
{
    if(!(self.state & state))
    {
        self.state = self.state | state;
    }
}
- (void) disableState:(MysticOptionState)state;
{
    if(self.state & state)
    {
        self.state = self.state & ~state;
    }
    
}
- (void) setState:(MysticOptionState)state;
{
//    DLog(@"state: %d > %d == none: %d  |  Contains none: %@  |  Equal to none: %@", _state, state, MysticOptionStateNone, MBOOLStr((state & MysticOptionStateNone)), MBOOLStr((state == MysticOptionStateNone)));

    if(state != MysticOptionStateNone && (state & MysticOptionStateNone))
    {
        state = state & ~MysticOptionStateNone;
//        DLog(@"removing none from state: %d", state);

    }
    _state = state;

}



- (MysticOptions *) owner;
{
    if(__owner) return __owner;
    return self.weakOwner;
}
- (MysticImageFilter *) imageFilter;
{
    if([MysticOptions current])
    {
        return [MysticOptions current].filters.filter;
    }
    return nil;
}
- (NSString *) nickName;
{
    NSInteger maxLength = 15;

    
    NSString *n = super.name;
    if(!n || !n.length)
    {
        n = MyString(self.type);
    }
    
    if(n.length > maxLength)
    {
        n = [[n substringToIndex:maxLength-3] stringByAppendingString:@"..."];
    }
    return n;
}
- (NSString *) shortName;
{
    NSInteger maxLength = 15;
    return [self shortName:maxLength];
}
- (NSString *) shortName:(NSInteger)maxLength;
{
    if(self.name.length <= maxLength) return self.name;
    return [[self.name substringToIndex:maxLength-3] stringByAppendingString:@"..."];
}
- (NSString *) layerSubtitle;
{
    NSString *str = MysticObjectTypeTitleParent(self.type, self.type);
    
    return [str capitalizedWordsString];
//    return MyString(self.type);
//
//    return self.shortName;
}
- (NSString *) layerTitle;
{
    return [[self shortName:60] capitalizedWordsString];
    
}
- (void) setPicture:(GPUImagePicture *)picture;
{
    __picture = picture;
}

- (BOOL) shouldRender;
{
    return self.hasRendered ? NO : _shouldRender;
}
- (void) setOwner:(MysticOptions *)newOwner;
{
    if(__owner != newOwner && newOwner && newOwner.isLive)
    {
        if(__layer) [__layer release];
        __layer = nil;
        __transformFilter = nil;
    }
    __owner = newOwner;
    
}
- (void) setIcon:(UIImage *)i;
{
    if(_iconImg)
    {
        [_iconImg release], _iconImg=nil;
    }
    if(i)
    {
        _iconImg = [i retain];
    }
}
- (UIImage *) icon;
{
    return _iconImg;
    return [MysticIcon iconForOption:(PackPotionOption *)self color:[UIColor blackColor]];
}

- (MysticObjectType) browseState;
{
    switch (self.type) {
        case MysticObjectTypeBadge:
            return MysticSettingBadge;
        case MysticObjectTypeText:
            return MysticSettingText;
        case MysticObjectTypeTexture:
            return MysticSettingTexture;
        case MysticObjectTypeLight:
            return MysticSettingLighting;
        case MysticObjectTypeFrame:
            return MysticSettingFrame;
        case MysticObjectTypeSetting:
            return MysticSettingSettings;
        case MysticObjectTypeColor:
            return MysticSettingChooseColor;
        case MysticObjectTypeFont:
            return MysticSettingType;
        case MysticObjectTypeBlend:
            return MysticSettingBlending;
        case MysticObjectTypeFilter:
            return MysticSettingFilter;
        case MysticObjectTypeMask:
            return MysticSettingMask;
        case MysticObjectTypeImage:
            return MysticSettingSettings;
        default: break;
    }
    return MysticSettingNone;
}
- (BOOL) allowNoBlending; { return YES; }
- (BOOL) allowNormalBlending; { return YES; }

- (NSArray *) blendingModeOptions;
{
    return nil;
}
- (NSArray *) extraBlendingModes;
{
    return nil;
}
- (NSString *) normalBlendingTitle;
{
    return MyLocalStr(@"Normal");
}
- (MysticObjectType) editState;
{
    switch (self.type) {
        case MysticObjectTypeShape:
        case MysticObjectTypeBadge:
            return MysticSettingBadge;
        case MysticObjectTypeText:
            return MysticSettingText;
        case MysticObjectTypeTexture:
            return MysticSettingTexture;
        case MysticObjectTypeLight:
            return MysticSettingLighting;
        case MysticObjectTypeFrame:
            return MysticSettingFrame;
        case MysticObjectTypeSetting:
            return MysticSettingSettings;
        case MysticObjectTypeColor:
            return MysticSettingChooseColor;
        case MysticObjectTypeFont:
            return MysticSettingType;
        case MysticObjectTypeBlend:
            return MysticSettingBlending;
        case MysticObjectTypeFilter:
            return MysticSettingFilter;
        case MysticObjectTypeMask:
            return MysticSettingMask;
        case MysticObjectTypeImage:
            return MysticSettingSettings;
        default:
            return self.type;
    }
    return MysticSettingNone;
}
- (MysticObjectType) focusState;
{
    switch (self.type) {
        case MysticObjectTypeBadge:
            return MysticSettingEditBadge;
        case MysticObjectTypeText:
            return MysticSettingEditText;
        case MysticObjectTypeTexture:
            return MysticSettingEditTexture;
        case MysticObjectTypeLight:
            return MysticSettingEditLighting;
        case MysticObjectTypeFrame:
            return MysticSettingEditFrame;
        case MysticObjectTypeSetting:
            return MysticSettingEditSettings;
        case MysticObjectTypeColor:
            return MysticSettingChooseColor;
        case MysticObjectTypeFont:
            return MysticSettingEditType;
        case MysticObjectTypeBlend:
            return MysticSettingBlending;
        case MysticObjectTypeFilter:
            return MysticSettingEditFilter;
        case MysticObjectTypeMask:
            return MysticSettingEditMask;
        case MysticObjectTypeImage:
            return MysticSettingEditSettings;
        default: break;
    }
    return MysticSettingNone;
}
- (MysticOptions *) options;
{
    return self.owner;
}

- (BOOL) hasDownloads;
{
    return self.numberOfDownloads > 0;
}
- (BOOL) hasDownloadsLeft;
{
    return self.numberOfDownloadsLeft > 0;
}
- (NSInteger) numberOfDownloads;
{
    if(self.downloads) return self.downloads.count;
    return _numberOfDownloads == NSNotFound ? 0 : _numberOfDownloads;
}
- (NSInteger) numberOfDownloadsLeft;
{
    return self.numberOfDownloads - self.numberOfDownloaded;
}
- (BOOL) containsDownload:(NSString *)urlToDownload;
{
    if(!self.downloads || !self.downloads.count) return NO;
    for (NSDictionary *download in self.downloads) {
        NSURL *url = [download objectForKey:@"url"];
        if ([[url absoluteString] isEqualToString:urlToDownload]) {
            return YES;
        }
    }
    return NO;
}
- (void) removeDownload:(NSString *)urlToDownload;
{
    if(!self.downloads || !self.downloads.count || ![self containsDownload:urlToDownload]) return;
    NSMutableArray *urls = [NSMutableArray array];
    for (NSDictionary *download in self.downloads) {
        NSURL *url = [download objectForKey:@"url"];
        if (![[url absoluteString] isEqualToString:urlToDownload]) {
            [urls addObject:download];
        }
    }
    self.downloads = [NSArray arrayWithArray:urls];
}
- (void) addDownload:(NSString *)urlToDownload;
{
    [self addDownload:urlToDownload key:nil];
}
- (void) addDownload:(NSString *)urlToDownload key:(NSString *)key;
{
    if(!urlToDownload || [self containsDownload:urlToDownload]) return;
    NSMutableArray *__downloads = [NSMutableArray array];
    if(self.numberOfDownloads) [__downloads addObjectsFromArray:self.downloads];
    [__downloads addObject:@{@"url":[NSURL URLWithString:urlToDownload], @"key":[NSString stringWithFormat:@"%@", key ? key : @""]}];
    self.downloads = [NSArray arrayWithArray:__downloads];
}
- (NSDictionary *) downloadForURL:(NSURL *)url;
{
    NSString *urlStr = [url absoluteString];
    for (NSDictionary *download in self.downloads)
    {
        NSURL *_url = [download objectForKey:@"url"];
        if([[_url absoluteString] isEqualToString:urlStr])
        {
            return download;
        }
        
    }
    return nil;
}
- (NSString *) keyForURL:(NSURL *)url;
{
    NSDictionary *download = [self downloadForURL:url];
    NSString *downloadKey = download ? [download objectForKey:@"key"] : nil;
    return downloadKey && ![downloadKey isEqualToString:@""] ? downloadKey : nil;
}
- (NSArray *) downloadURLs;
{
    NSMutableArray *urls = [NSMutableArray array];
    for (NSDictionary *download in self.downloads) {
        NSURL *url = [download objectForKey:@"url"];
        if(url) [urls addObject:url];
    }
    return urls;
}
- (void) downloadAndNotify:(NSArray *)downloads;
{
    __unsafe_unretained MysticOption *weakSelf = self;
    if(weakSelf.isDownloading || weakSelf.isDownloaded || weakSelf.readyForRender)
    {
        DLog(@"Option: %@ isDownloading: %@ isDownloaded: %@ readyForRender: %@", self.shortName, MBOOLStr(self.isDownloading), MBOOLStr(self.isDownloaded), MBOOLStr(self.readyForRender));
        return;
    }
    
    
    weakSelf.isDownloading = YES;
    [self.downloader prefetchURLs:downloads progress:nil completed:^(NSUInteger finishedCount, NSUInteger totalCount, BOOL finished, UIImage *image, NSURL *url, SDImageCacheType cacheType, NSInteger currentIndex) {
        weakSelf.numberOfDownloaded++;
        
        
        [[MysticCache layerCache] storeImage:image forKey:[url absoluteString] toDisk:YES];
        
        if(!finished) return;
        weakSelf.isDownloading = NO;
        weakSelf.isDownloaded = YES;
        weakSelf.readyForRender = YES;
    }];
}

- (MysticPreloaderImage *) downloader;
{
    if(!_downloader)
    {
        _downloader = [[MysticPreloaderImage alloc] init];
        _downloader.maxConcurrentDownloads = MYSTIC_OPTION_PRELOADER_MAX_CONCURRENT_DOWNLOADS;

    }
    
    return _downloader;
}
- (BOOL) isPreparedForSettings:(MysticRenderOptions)settings;
{
//    if(_preparedSettings.count < settings) return NO;
//    return [[_preparedSettings objectAtIndex:settings] boolValue];
    BOOL isPrepared = NO;
    if(settings & MysticRenderOptionsOriginal)
    {
        isPrepared = (_preparedWithSettings & MysticRenderOptionsOriginal) != NO;
    }
    else if(settings & MysticRenderOptionsSource)
    {
        isPrepared = (_preparedWithSettings & MysticRenderOptionsSource) != NO;

    }
    else if(settings & MysticRenderOptionsPreview)
    {
        isPrepared = (_preparedWithSettings & MysticRenderOptionsPreview) != NO;
    }
    else if(settings & MysticRenderOptionsThumb)
    {
        isPrepared = (_preparedWithSettings & MysticRenderOptionsThumb) != NO;

    }
    
    return isPrepared;
}
- (void) prepareForSettings:(MysticRenderOptions)settings;
{
//    if(_preparedSettings.count < settings) return;
//    
//    [_preparedSettings replaceObjectAtIndex:settings withObject:@YES];
    
    if(settings & MysticRenderOptionsOriginal)
    {
        _preparedWithSettings = _preparedWithSettings | MysticRenderOptionsOriginal;
    }
    else if(settings & MysticRenderOptionsSource)
    {
        _preparedWithSettings = _preparedWithSettings | MysticRenderOptionsSource;
        
    }
    else if(settings & MysticRenderOptionsPreview)
    {
        _preparedWithSettings = _preparedWithSettings | MysticRenderOptionsPreview;
        
    }
    else if(settings & MysticRenderOptionsThumb)
    {
        _preparedWithSettings = _preparedWithSettings | MysticRenderOptionsThumb;
        
    }
}
- (BOOL) ignoreActualRender;
{
    if(self.ignoreRender || (self.hasRendered)) return YES;
    return _ignoreActualRender;
}
- (void) setReadyForRender:(BOOL)value andUpdateObservers:(BOOL)updateObservers;
{
    if(updateObservers)
    {
        self.readyForRender = value;
    }
    else
    {
        _readyForRender = value;
    }
}
- (void) setTransformFilter:(GPUImageTransformFilter *)transformFilter;
{
    __transformFilter = nil;
}
- (void) setOwnedLayer:(MysticFilterLayer *)value;
{
    [_ownedLayer release];
    _ownedLayer = value ? [value retain] : nil;
    if(__layer) [__layer release];
    __layer = _ownedLayer ? [_ownedLayer retain] : nil;

}
- (void) setLayer:(MysticFilterLayer *)value;
{
    if(__layer) [__layer release];
    __layer = value ? [value retain] : nil;
}

- (void) layerInfo;
{
//    ALLog(@"Option Layer Info", @[@"option", self,
//                                  @"layer", MObj(__layer),
//                                  @"trans filter", MObj(self.transformFilter),
////                                  @"ownedlayer", MObj(_ownedLayer),
//
////                                  @"weakOwner", MObj(__weakOwner),
//                                  @"__owner", MObj(__owner),
//                                  @"owner", [NSString stringWithFormat:@"<%p> %@", self.owner, self.owner ? @"YES" : @"NO"],
//
////                                  @"transform", MObj(__transformFilter),
//                                  @"self.layer", MObj(self.layer),
//                                  @"self.layer.filters", MObj(self.layer.filters),
//                                  @"__layer owner", __owner ? [__owner.filters layerForOption:self] : @"---",
//                                  @"__layer owner filters", __owner && [__owner.filters layerForOption:self] ? [__owner.filters layerForOption:self].filters : @"---",
//
//                                  @"filters", __owner ? __owner.filters.debugDescription : @"---",
//                                  ]);
}
- (void) confirmCancel;
{
    [self resetOwnerAndLayers];
    if(self.resetAdjustmentsAfterCancel)
    {
        [self resetAdjustments];
    }
}
- (void) resetOwnerAndLayers;
{
    __transformFilter = nil;
    [__layer release], __layer = nil;
    [_ownedLayer release], _ownedLayer = nil;
    self.owner = nil;
    self.weakOwner=nil;
}
- (void) resetAdjustments;
{
    
}
- (MysticFilterLayer *) layer;
{
    id aLayer = nil;
    int i = 0;
    if(__layer != nil) { i=1;  aLayer =  __layer; }
    else if(_ownedLayer != nil) { i=2; aLayer = _ownedLayer; }
    else if(self.owner)
    {
        i = 3;
        MysticFilterLayer *theLayer = [self.owner.filters layerForOption:self];
        if(theLayer && [theLayer isKindOfClass:[MysticFilterLayer class]])
        {
            if(__layer) [__layer release];
            __layer = [theLayer retain];
        }
        aLayer = theLayer;
    }
    return aLayer;
}
- (NSArray *) layers;
{
    
    NSArray *__layers = [NSArray array];
    if(self.owner && self.owner.hasFilters)
    {
        __layers = [self.owner.filters layersForOption:self];
    }
    return __layers;
}
- (MysticFilterLayer *) layerWithTag:(NSString *)layerTag;
{
    if(self.owner && self.owner.hasFilters)
    {
        MysticFilterLayer *theLayer = [self.owner.filters layerForOption:self tag:layerTag];
        if(theLayer && [theLayer isKindOfClass:[MysticFilterLayer class]])
        {
            return theLayer;
        }
    }
    return self.layer;
}
- (GPUImageTransformFilter *) transformFilter;
{
    
    if(__transformFilter != nil) return __transformFilter;
    if(self.layer)
    {
        id __tf = [self.layer filterForKey:MysticLayerKeyTransform];
        if(__tf) return __tf;
    }
    return nil;
}
- (GPUImageOutput<GPUImageInput> *) addFilters:(GPUImageOutput<GPUImageInput> *)input layer:(MysticFilterLayer *)layer effects:(MysticOptions *)options context:(NSDictionary *)userInfo;
{
    return input;
}
- (BOOL) hasFiltersMatching:(MysticFilterOption)filterOption;
{
    return [self numberOfFiltersMatchingOptions:filterOption] > 0;
}
- (NSInteger) numberOfFiltersMatchingOptions:(MysticFilterOption)filterOptions;
{
    return [self filterTypesMatchingOptions:filterOptions].count;
}
- (NSArray *) filterTypesMatchingOptions:(MysticFilterOption)filterOption;
{
    return @[];
}
- (BOOL) updateAllFilters;
{
    return [self updateFiltersMatching:MysticFilterOptionAll];
}
- (BOOL) updateFiltersMatching:(MysticFilterOption)filterOption; { return NO; }
- (BOOL) updateFilters;
{
    return !_updateFiltersRequired ? NO : [self updateFilters:self.refreshState];
}
- (BOOL) updateFilters:(MysticObjectType)settingType; { return NO; }
- (MysticObjectType) refreshStateForState:(MysticObjectType)refreshState;
{
    switch (refreshState) {
        case MysticSettingNone:
        case MysticSettingUnknown:
        case MysticObjectTypeUnknown: refreshState = MysticSettingNone; break;
        case MysticSettingVignetteColorAlpha: refreshState = MysticSettingVignette; break;
        default: break;
    }
    return refreshState;
}
- (void) setRefreshState:(MysticObjectType)refreshState;
{
    _refreshState = [self refreshStateForState:refreshState];
    _updateFiltersRequired = NO;
    switch (_refreshState) {
        case MysticSettingTransform:
        case MysticSettingTiltShift:
        case MysticSettingColorBalance:
        case MysticSettingColorBalanceRed:
        case MysticSettingColorBalanceGreen:
        case MysticSettingColorBalanceBlue:
        case MysticSettingHSB:
        case MysticSettingHSBHue:
        case MysticSettingHSBSaturation:
        case MysticSettingHSBBrightness:
        case MysticSettingCamLayerSetup:
        case MysticSettingLevels:
        case MysticSettingSharpness:
        case MysticSettingUnsharpMask:
            _updateFiltersRequired = YES; break;
        case MysticSettingVignetteColorAlpha:
        case MysticSettingVignette:
            _updateFiltersRequired = YES; break;
        default: break;
    }
    [self addAdjustOrder:_refreshState];

}

- (NSArray *) adjustmentsTypes:(BOOL)toString;
{
    return [self adjustmentsTypesMatching:MysticFilterOptionAll toString:toString];
}

- (NSArray *) adjustmentsTypesMatching:(MysticFilterOption)filterOption toString:(BOOL)toString;
{
    return nil;
}

- (id) filter:(id)filterKey;
{
    id filter = self.layer ? [self.layer filterForKey:filterKey] : nil;
    if(!filter)
    {
        for (MysticFilterLayer *theLayer in self.layers) {
            filter = [theLayer filterForKey:filterKey];
            if(filter) break;
        }
    }
    return filter;
}

- (NSString *) description;
{
    return self.debugDescription;
}
- (NSString *) debugDescription;
{
    return [NSString stringWithFormat:@"%@ ('%@') <%@ %p>%@",
            [MyString(self.type) stringByPaddingToLength:12 withString:@" " startingAtIndex:0],
            [self.shortName stringByPaddingToLength:24 withString:@" " startingAtIndex:0],
            [NSStringFromClass(self.class) stringByPaddingToLength:30 withString:@" " startingAtIndex:0],
            self,
            self.optionSlotKey ? [@"  slot: " stringByAppendingString:self.optionSlotKey] : @""];
}
- (NSString *) shortDebugDescription;
{
    return [NSString stringWithFormat:@"%@ (\"%@\")", MyString(self.type), [self.shortName stringByPaddingToLength:20 withString:@"." startingAtIndex:0]];
}
@end
