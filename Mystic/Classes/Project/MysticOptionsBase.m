//
//  MysticOptionsBase.m
//  Mystic
//
//  Created by Me on 6/19/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticOptionsBase.h"
#import "UserPotion.h"
#import "MysticPreloaderImage.h"
#import "MysticEffectsManager.h"
#import "MysticController.h"
#import "NSArray+Mystic.h"
#import <CommonCrypto/CommonDigest.h>
#import "SDImageCache.h"
#import "MysticCacheImage.h"
#import "GPUImage.h"
#import "JPNG.h"

@interface MysticOptionsBase ()
{
    BOOL changedOptionRules;
    NSMutableArray *_options;
    NSMutableDictionary  *_textureSizes;
    NSArray *__enumOptions, *_optionsWithRules;
    NSInteger _numberOfInputs, _numberOfShaders, _numberOfPreloadedDownloads, _numberOfInputTextures;
    
}
@property (nonatomic, copy) MysticBlockSender readyBlock;
@property (nonatomic, retain) NSMutableArray *optionKeys;
@property (nonatomic, retain) MysticFilterManager *cleanFilters;

@property (nonatomic) NSInteger totalDownloads, finishedDownloads, numberOfPreloadedDownloads;
@property (nonatomic) BOOL refreshing;
@property (nonatomic, retain) NSArray *enumOptions;
@property (nonatomic, retain) NSMutableDictionary *preloads;
@end
@implementation MysticOptionsBase

@synthesize manager=_manager, finishedDownloads, optionKeys=_optionKeys, sourceImage=_sourceImage, settings=_settings, refreshing, size=_size, tagPrefix=_tagPrefix, numberOfLiveOptions, liveOptions, confirmedOptions, highestLevel=_highestLevel, lowestLevel=_lowestLevel, previousLevel=_previousLevel, nextLevel=_nextLevel, tag=_tag,  isCancelled=_isCancelled, isReady=_isReady, delegate=_delegate, preloader=_preloader, filters=_filters, index=_index, renderIndex=_renderIndex, isRenderOptions=_isRenderOptions, isLive=_isLive, needsRender=_needsRender, imageView=_imageView, renderedImage=_renderedImage, enumOptions=__enumOptions, sortOrder=_sortOrder, scale=_scale, preloads=_preloads, hasChanged=_hasChanged, optionRules=_optionRules;


+ (id) options;
{
    return [[[[self class] alloc] init] autorelease];
}
+ (NSString *) renderImageTypeString:(MysticRenderOptions)settings;
{
    NSString *s = [self renderImageTypeStr:settings];
    if(!s) return @"Unknown";
    
    return [s stringByReplacingOccurrencesOfString:@"MysticRenderOptions" withString:@""];
}
+ (NSString *) renderImageTypeStr:(MysticRenderOptions)settings;
{
    if(settings & MysticRenderOptionsOriginal)
    {
        return @"MysticRenderOptionsOriginal";
    }
    else if(settings & MysticRenderOptionsSource)
    {
        return @"MysticRenderOptionsSource";
        
    }
    else if(settings & MysticRenderOptionsPreview)
    {
        return @"MysticRenderOptionsPreview";
        
        
    }
    else if(settings & MysticRenderOptionsThumb)
    {
        return @"MysticRenderOptionsThumb";
        
    }
    return nil;
}
+ (MysticRenderOptions) renderImageType:(MysticRenderOptions)settings;
{
    if(settings & MysticRenderOptionsOriginal)
    {
        return MysticRenderOptionsOriginal;
    }
    else if(settings & MysticRenderOptionsSource)
    {
        return MysticRenderOptionsSource;
        
    }
    else if(settings & MysticRenderOptionsPreview)
    {
        return MysticRenderOptionsPreview;
        
        
    }
    else if(settings & MysticRenderOptionsThumb)
    {
        return MysticRenderOptionsThumb;
        
    }
    return MysticRenderOptionsNil;
}

+ (void) enable:(MysticRenderOptions)newOption;
{
    [[MysticOptions current] enable:newOption];
}
- (void) enable:(MysticRenderOptions)newOption;
{
    switch (newOption) {
        case MysticRenderOptionsOriginal:
        {
            [self disable:MysticRenderOptionsPreview];
            [self disable:MysticRenderOptionsThumb];
            [self disable:MysticRenderOptionsSource];
            break;
        }
        case MysticRenderOptionsSource:
        {
            [self disable:MysticRenderOptionsPreview];
            [self disable:MysticRenderOptionsThumb];
            [self disable:MysticRenderOptionsOriginal];
            break;
        }
        case MysticRenderOptionsPreview:
        {
            [self disable:MysticRenderOptionsSource];
            [self disable:MysticRenderOptionsThumb];
            [self disable:MysticRenderOptionsOriginal];
            break;
        }
        case MysticRenderOptionsThumb:
        {
            [self disable:MysticRenderOptionsOriginal];
            [self disable:MysticRenderOptionsPreview];
            [self disable:MysticRenderOptionsSource];
            break;
        }
            
        default: break;
    }
    self.settings |= newOption;
    
}



+ (void) disable:(MysticRenderOptions)newOption;
{
    [[MysticOptions current] disable:newOption];
}
- (void) disable:(MysticRenderOptions)newOption;
{
    if(![self isEnabled:newOption]) return;
    self.settings = self.settings & ~newOption;
}

+ (BOOL) isEnabled:(MysticRenderOptions)settingOption;
{
    return [[MysticOptions current] isEnabled:settingOption];
}

- (BOOL) isEnabled:(MysticRenderOptions)settingOption;
{
//    if(settingOption == MysticRenderOptionsSaveImageOutput) return NO;
    return self.settings & settingOption;
}
+ (BOOL) isDisabled:(MysticRenderOptions)settingOption;
{
    return [[MysticOptions current] isDisabled:settingOption];
}
- (BOOL) isDisabled:(MysticRenderOptions)settingOption;
{
    return ![self isEnabled:settingOption];
}

- (void) dealloc;
{
    //[self updateOptions:nil force:NO];
//    DLog(@"dealloc options: %p", self);
    
    if(_optionsWithRules)
    {
        [_optionsWithRules release], _optionsWithRules=nil;
    }
    [_cleanFilters release], _cleanFilters = nil;
    _imageView = nil;
    [_originalTag release], _originalTag=nil;
    [_preloads release], _preloads =nil;
    _delegate=nil;
    if(_filters) [_filters release], _filters=nil;
    _isCancelled = YES;
    _manager = nil;
    _optionRules = MysticRenderOptionsAuto;
    [self.preloader cancelPrefetching];
    Block_release(_readyBlock);
    Block_release(_progressBlock);
    Block_release(_progressBlockCall);
    [_renderedImage release];
    [_sourceImage release];
    [_preloader release], _preloader = nil;
    [_optionKeys release];
    [_textureSizes release];
    [_options release];
    [_tagPrefix release];
    [_tag release];
    [__enumOptions release], __enumOptions=nil;
    [_parentOptions release], _parentOptions=nil;
    [_liveTargetOptions release], _liveTargetOptions=nil;
    [super dealloc];
}
- (id) topSelf;
{
    return self.topLevelOptions ? self.topLevelOptions : self;
}
- (void) liveTargetOptions:(MysticOptions *)value;
{
    if([value isEqual:self])
    {
        self.liveTargetOptions = nil;
        return;
    }
    self.liveTargetOptions = value;
}
- (void) setIsCancelled:(BOOL)value;
{
    _isCancelled = value;
    self.readyBlock = nil;
    self.progressBlock=nil;
    self.progressBlockCall=nil;
    if(value && self.preloader)
    {
        [self.preloader cancelPrefetching];
    }
    
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        _sortOrder = MysticSortOrderNormal;
        _options = nil;
        _passIndex = -1;
        _optionKeys = nil;
        changedOptionRules = NO;
        [self setupDefaults];
        _optionsWithRules = nil;
        _options = [[NSMutableArray alloc] init];
        _textureSizes = [[NSMutableDictionary alloc] init];
        _optionKeys = [[NSMutableArray alloc] init];
        _scale = 0.0f;
        self.preloads = [NSMutableDictionary dictionary];
    }
    return self;
}
- (id) initWithOptions:(NSArray *)opts;
{
    self = [self init];
    if(self)
    {
        if(opts)
        {
            opts = [self sortedOptions:opts];
            for (PackPotionOption *o in opts) {
                [self addOption:o];
            }
        }
    }
    return self;
}



- (NSInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackBuf count:(NSUInteger)len;
{
    
    NSUInteger l = [self.enumOptions countByEnumeratingWithState:state objects:stackBuf count:len];
    if(l == 0)
    {
        [self setEnumOptions:nil];
        
    }
    return l;
    
}
- (NSEnumerator *) objectEnumerator;
{
    return self.enumOptions.objectEnumerator;
}
- (NSEnumerator *) reversedObjectEnumerator;
{
    return self.enumOptions.reverseObjectEnumerator;
    
}
- (void) setOptionRules:(MysticRenderOptions)optionRules;
{
    changedOptionRules = _optionRules != optionRules;
    
    _optionRules = optionRules;
    
    if(changedOptionRules)
    {
        NSArray *newSortedOptions = [self sortedOptions:[NSArray arrayWithArray:self.options] rules:self.optionRules];
        [self resetOptions:newSortedOptions];
        [self updateInputs];
    }
    
}
- (void) setTextureSize:(CGSize)textureSize forOption:(PackPotionOption *)option;
{
    if(CGSizeEqualToSize(textureSize, CGSizeZero)) return;
    [_textureSizes setObject:[NSValue valueWithCGSize:textureSize] forKey:option.tag];
    
    self.smallestTextureSize = CGSizeMin(self.smallestTextureSize, textureSize);
    self.smallestTextureSizeType = CGSizeEqualToSize(self.smallestTextureSize, textureSize) ? option.type : self.smallestTextureSizeType;
}
- (NSArray *) sortedRenderOptions;
{
    return self.options;
    //    return [self sortedOptions:[NSArray arrayWithArray:self.options] rules:self.optionRules];
}
- (void) setEnumOptions:(NSArray *)enumOptions;
{
    if(__enumOptions) [__enumOptions release], __enumOptions=nil;
    if(enumOptions) __enumOptions = [enumOptions retain];
    self.sortOrder = MysticSortOrderNormal;
}
- (NSArray *) enumOptions;
{
    if(__enumOptions) return __enumOptions;
    
    __enumOptions = [[NSArray arrayWithArray:self.sortedAllOptions] retain];
    return __enumOptions;
}

- (void) setupDefaults;
{
    if(_options && _options.count) [_options removeAllObjects];
    if(_optionKeys && _optionKeys.count) [_optionKeys removeAllObjects];
    _manager = nil;
    _sortOrder = MysticSortOrderNormal;
    _imageView = nil;
    _renderedImage = nil;
    _sourceImage = nil;
    _delegate = nil;
    _numberOfPreloadedDownloads = 0;
    finishedDownloads = 0;
    _renderIndex = -1;
    _needsRender = NO;
    self.refreshing=NO;
    _numberOfInputs = 1;
    _numberOfInputTextures = 1;
    _numberOfShaders = 1;
    _isReady = YES;
    _index = 0;
    _isRenderOptions = NO;
    _isCancelled = NO;
    _isLive = NO;
}

- (void) setIsLive:(BOOL)value;
{
    _isLive = value;
    if(_isLive)
    {
        //        DLog(@"updating options because isLive was set");
        [self updateOptions:self force:YES];
        
    
    
    
    }
    
    
    
}

- (void) prepare;
{
    for (PackPotionOption *o in self.allOptions)
    {
        [o registerForChangeNotification];
    }
}

- (void) unprepare;
{
    
    [self updateOptions:nil force:NO];
    _isLive = NO;
    [self clean];
    [self unregister];
    if(_filters) [_filters release], _filters = nil;
}
- (void) unregister;
{
    for (PackPotionOption *o in self.allOptions) {
        if(o.owner && [o.owner isEqual:self])
            [o unregisterForChangeNotification];
    }
}

- (void) updateOptions;
{
    
    [self updateOptions:self force:YES];
}

- (void) updateOptions:(id)newValue;
{
    [self updateOptions:newValue force:YES];
}
- (void) updateOptions:(id)newValue force:(BOOL)useForce;
{
    NSArray *a = [NSArray arrayWithArray:self.allOptions];
    for (PackPotionOption *o in a)
    {
        if(useForce)
        {
            o.owner = newValue;
        }
        else if(newValue == nil && o.owner && [o.owner isEqual:self])
        {
            o.owner = newValue;
        }
        else if(newValue != nil && ![o.owner isEqual:newValue])
        {
            o.owner = newValue;
        }
        [o update];
    }
}


- (MysticPreloaderImage *) preloader;
{
//    return [MysticPreloaderImage sharedPreloader];
//
    if(!_preloader)
    {
        _preloader = [[MysticPreloaderImage alloc] init];
        _preloader.options = 0;
        _preloader.maxConcurrentDownloads = MYSTIC_OPTIONS_PRELOADER_MAX_CONCURRENT_DOWNLOADS;
        
    }
    return _preloader;
}
- (BOOL) hasChangedValue;
{
    return _hasChanged;
}
- (BOOL) hasChanged;
{
    if(_hasChanged) return _hasChanged;
    for (PackPotionOption *o in self.allOptions) {
        if(o.hasChanged) return YES;
    }
    return NO;
}
- (void) setHasChanged:(BOOL)hv;
{
    [self setHasChanged:hv changeOptions:YES];
}
- (void) setHasChanged:(BOOL)hv changeOptions:(BOOL)shouldChangeOptions;
{
    _hasChanged = hv;
    if(!shouldChangeOptions) return;
    for (PackPotionOption *o in self.allOptions) o.hasChanged = hv;
}
- (BOOL) requiresCompleteReload;
{
    for (PackPotionOption *o in self.options) {
        if(o.requiresCompleteReload) return YES;
    }
    return NO;
}
- (BOOL) hasMadeChanges;
{
    if(self.tag && self.originalTag)
    {
        return ![self.tag isEqualToString:self.originalTag];
    }
    else if(self.tag && !self.originalTag)
    {
        return YES;
    }
    return NO;
}
- (void) setTag:(NSString *)value;
{
    [self setNeedsRender];
    [_tag release];
    if(!value) { _tag = nil; return;}
    _tag = [value retain];
}
- (NSString *) tag;
{
    if(_tag) return _tag;
    
    NSMutableString *__tag = [NSMutableString stringWithFormat:@"%@", [MysticUser user].currentProjectName];
    
    for (PackPotionOption *opt in self.allOptions) {
        [__tag appendString:opt.uniqueTag];
    }
    
    
    NSString *returnTag;
    const char *str = [__tag UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    returnTag = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                 r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    returnTag = [returnTag substringToIndex:6];
    _tag = returnTag ? [returnTag retain] : nil;    
    return _tag;
    
}

- (MysticImage *) sourceImageForSize:(CGSize)renderSize;
{
    UIImage * rimg = self.sourceImage ? self.sourceImage : [[UserPotion potion] imageForRenderSize:renderSize];
    
    
    rimg = rimg ? rimg : [UserPotion potion].sourceImage;
    
    return rimg ? [MysticImage imageWithImage:rimg] : nil;
}

- (BOOL) isEmpty;
{
    return self.count < 1 ? YES : NO;
}

- (int) saveCachedImages:(MysticBlock)finished;
{
    
    
    id m =[self retain];
    NSArray *oos = [self.options retain];
    int i = 0;
    for (PackPotionOption *option in oos) {
        if(_isCancelled) { break; }
        i += [option saveCachedImages:nil];
    }
    [oos release];
    [m release];
    return i;
}
- (NSArray *) optionsOrderedByLevel;
{
    NSMutableArray *os = [NSMutableArray array];
    NSMutableArray *so = [NSMutableArray array];
    NSMutableArray *s2 = [NSMutableArray array];
    NSMutableDictionary *old = [NSMutableDictionary dictionary];

    NSArray *s = self.sortedAllOptions;
    NSInteger l = MysticLayerLevelMax;
    [so addObjectsFromArray:s];
    [s2 addObjectsFromArray:s];

    PackPotionOption* f = nil;
    NSInteger x = 0;
    for (PackPotionOption *o in so) {
        if(o.optionSlotKey)
        {
            [old setObject:@(x) forKey:o.optionSlotKey];
        }
        l = MIN(l, o.level);
        if(l == o.level)
        {
            f = o;
        }
        x++;
    }
//    DLog(@"--------------");
//    DLog(@"Lowest: %@ = %d", f.name, (int)l);
    f = nil;
    int c = 1;
    // loop through all options
    for (PackPotionOption *o in so) {
        
//        if([os containsObject:o]) continue;
        
        NSInteger l2 = l;
        f = nil;
        // loop through a diminishing list of options
        for (PackPotionOption *o2 in s2) {
            
            
            l2 = MIN(l2, o2.level);
            if(l2 == o2.level || !f)
            {
                f = o2;
                l2 = f.level;
            }
            
            
        }
        
        if(f) {
            
            [os addObject:f];
            l = f.level;
            if([s2 containsObject:f]) [s2 removeObject:f];

        }
        
        
        if(f) f=nil;
        c++;
    }
    int h = (int)[self highestLevel:os skipPreview:YES];
    int nl = -1;

    BOOL fnl = NO;
    for (PackPotionOption *o in os) {
        if((int)(o.level) > h)
        {
            if(!fnl)
            {
                NSInteger al = o.autoLayerLevel;
                nl = (int)al;
                o.level = al;
                fnl = YES;
            }
            else
            {
                o.level = (NSInteger)(nl+1);
                nl = nl+1;
            }

        }
    }
//    NSInteger lowestLevel = [(PackPotionOption *)[os objectAtIndex:0] level];
    NSInteger i = 0;
    for (PackPotionOption *o in os) {
        if(![old objectForKey:o.optionSlotKey]) continue;
        
        NSInteger before = [[old objectForKey:o.optionSlotKey] integerValue];
//        o.level = lowestLevel;
        o.hasChanged = i != before;
        i++;
//        lowestLevel++;
    }
    
    
    [_options release];
    _options = [[NSMutableArray arrayWithArray:os] retain];
    [self updateInputs];
    for (PackPotionOption *option in _options)
    {
        [option reordered];
    }
    
//    
//    DLog(@"New Levels: %@", [_options enumerateDescription:^NSString *(PackPotionOption *obj) {
//        return [NSString stringWithFormat:@"\t\t%d: %@", (int)obj.level, obj.name];
//    }]);
    return os;
}

- (NSInteger) highestLevel;
{
    return [self highestLevel:nil skipPreview:NO];
}
- (NSInteger) highestLevel:(NSArray *)sourceOpts skipPreview:(BOOL)s;
{
    sourceOpts = sourceOpts ? sourceOpts : self.allOptions;
    int l = (int)(MysticLayerLevelAuto - 1);
    for (PackPotionOption *o in sourceOpts) {
        if((!s && o.isPreviewOption) || MysticObjectHasAutoLayer(o))
        {
            continue;
        }
      
        
        l = MAX(l,(int)o.level);
    }
    return l <= -1 ? MysticLayerLevelAuto : (NSInteger)l;
    
}



- (BOOL) isHighestOption:(PackPotionOption *)option;
{
    PackPotionOption *opt = [self highestOption:MysticObjectTypeAll];
    return [opt isEqual:option];
}
- (PackPotionOption *) highestOption:(MysticObjectType)type;
{
    
    type = MysticTypeForSetting(type, nil);
    for (PackPotionOption *opt in [self.sortedAllOptions reversedArray]) {
        if(opt.type == type || type == MysticObjectTypeAll) return opt;
    }
    return nil;
}
- (NSInteger) nextLevel;
{
    NSInteger h = self.highestLevel;
    return h != MysticLayerLevelAuto ? (self.highestLevel + 1) : h;
    
}
- (NSInteger) nextLevel:(PackPotionOption *)option;
{
    MysticOption *highest = [self highestOption:option.type];
    if(highest)
    {
        return highest.level;
    }
    NSInteger nextLevel = MysticLayerLevelAuto;
    switch (option.type)
    {
        case MysticObjectTypeFilter:
        {
            NSInteger _n = MysticLayerLevelAuto;
            
            for (PackPotionOption *o in self.allOptions)
            {
                
                if(o.blended)
                {
                    NSInteger ol = o.level;
                    _n = MAX(_n, ol);
                }
            }
            nextLevel = _n;
            break;
        }
        default:
        {
            nextLevel = self.nextLevel;
            break;
        }
            
    }
    return nextLevel == MysticLayerLevelAuto ? self.nextLevel : nextLevel;
}

- (NSInteger) previousLevel;
{
    return self.topLevel;
    
}
- (NSInteger) topLevel;
{
    NSInteger l = MysticLayerLevelAuto - 1;
    for (PackPotionOption *o in self.allOptions) {
        if(o.isPreviewOption) continue;
        NSInteger ol = o.level;
        l = l > ol ? l : ol;
    }
    return l == NSIntegerMin ? MysticLayerLevelAuto : l;
}

- (NSInteger) lowestLevel;
{
    NSInteger l = 99999999;
    for (PackPotionOption *o in self.allOptions) {
        if(o.isPreviewOption) continue;
        NSInteger ol = o.level;
        l = l < ol ? l : ol;
    }
    return l == NSIntegerMax ? MysticLayerLevelAuto : l;
}
- (NSInteger) positionOf:(PackPotionOption *)option;
{
    NSInteger p = -1;
    for (PackPotionOption *o in self.sortedAllOptions) {
        p++;
        if([Mystic option:o equals:option])
        {
            break;
        }
    }
    return p == -1 ? NSNotFound : p+1;
}
- (NSInteger) moveUp:(PackPotionOption *)option;
{
    NSInteger level = option.level;
    NSInteger nextLevel = level;
    NSInteger fNextLevel = NSNotFound;
    if(self.totalCount <= 1) return level;
    
    NSInteger ol;
    for (PackPotionOption *o in self.allOptions) {
        ol = o.level;
        
        if(ol > level && ol != level)
        {
            if(fNextLevel == NSNotFound) { fNextLevel = ol; nextLevel = ol;}
            nextLevel = MIN(ol, nextLevel);
            
        }
        
    }
    BOOL changed = nextLevel != level;
    
    NSInteger l = nextLevel;
    
    
    if(changed)
    {
        for (PackPotionOption *o in self.allOptions) {
            ol = o.level;
            if(ol == l)
            {
                o.level -= 1;
                o.hasChanged = YES;
                
            }
        }
    }
    option.level = l;
    [self resort];
    return l;
}

- (NSInteger) moveDown:(PackPotionOption *)option;
{
    NSInteger level = option.level;
    NSInteger nextLevel = level;
    NSInteger fNextLevel = NSNotFound;
    if(self.totalCount <= 1) return level;
    
    
    
    NSInteger ol;
    for (PackPotionOption *o in self.sortedAllOptions) {
        ol = o.level;
        
        if(ol < level)
        {
            if(fNextLevel == NSNotFound) { fNextLevel = ol; nextLevel = ol;}
            nextLevel = MAX(ol, nextLevel);
        }
        
    }
    
    BOOL changed = nextLevel != level;
    NSInteger l = nextLevel;
    
    if(changed)
    {
        for (PackPotionOption *o in self.allOptions) {
            ol = o.level;
            if(ol >= l && ol != level)
            {
                o.level += 1;
                o.hasChanged = ol == l;
                
            }
        }
    }
    
    
    option.level = l;
    [self resort];
    
    return l;
}
- (MysticOptions *) liveOptions;
{
    return [self liveOptions:YES];
}
- (MysticOptions *) confirmedOptions;
{
    return [self liveOptions:NO];
}
- (MysticOptions *) liveOptions:(BOOL)isLive;
{
    MysticOptions *l = [MysticOptions options];
    
    for (PackPotionOption *o in self.allOptions) {
        if(o.isPreviewOption == isLive) [l addOption:o];
    }
    return l;
}
- (PackPotionOption *) selectableOption:(MysticObjectType)btype;
{
    MysticObjectType type = MysticTypeForSetting(btype, nil);
    
    NSArray *optionsOfType = [self options:@(type)];
    PackPotionOption *o2 = nil;
    for (PackPotionOption *o in optionsOfType) {
        if(o.isSelectableOption)
        {
            //            o2 = o;
            if(o.inFocus) break;
        }
    }
    return nil;
}
- (PackPotionOption *) activeOption:(PackPotionOption *)optionInstance;
{
    return [self activeOption:optionInstance exactMatch:NO];
}
- (PackPotionOption *) activeOption:(PackPotionOption *)optionInstance exactMatch:(BOOL)checkForEqual;
{
    BOOL found = [self.allOptions containsObject:optionInstance];
    if(checkForEqual) return  found ? optionInstance : nil;
    
    PackPotionOption *active = nil;
    for (PackPotionOption *o in self.allOptions) {
        if([o isSame:optionInstance])
        {
            if([optionInstance.optionSlotKey isEqualToString:o.optionSlotKey])
            {
                return o;
            }
            if(!active)
            {
                active = o;
            }
        }
    }
    return active;
    
}
- (PackPotionOption *) option:(MysticObjectType)btype;
{
    MysticObjectType type = MysticTypeForSetting(btype, nil);
    NSArray *optionsOfType = [self options:@(type)];
    if(optionsOfType && optionsOfType.count == 1) return [optionsOfType lastObject];
    for (PackPotionOption *o in optionsOfType) if(o.inFocus) return o;
    for (PackPotionOption *o in optionsOfType) if(o.lastPicked) return o;
    return optionsOfType.count ? [optionsOfType lastObject] : nil;
}
- (NSArray *) options:(id)typeOrTypes;
{
    return [self options:typeOrTypes forState:MysticOptionStateAny];
}
- (NSArray *) options:(id)typeOrTypes forState:(MysticOptionState)optionState;
{
    MysticObjectType type = MysticObjectTypeUnknown;
    NSArray *types = [typeOrTypes isKindOfClass:[NSNumber class]] ? @[typeOrTypes] : typeOrTypes;
    NSMutableArray *returnOptions = [NSMutableArray array];
    for (NSNumber *typeObj in types)
    {
        type = MysticTypeForSetting([typeObj integerValue], nil);
        switch (type)
        {
            case MysticObjectTypeAll:
                for (PackPotionOption *o in self.allOptions) if([o inState:optionState]) [returnOptions addObject:o];
                break;
            default:
                for (PackPotionOption *o in self.allOptions) if(o.type == type && [o inState:optionState]) [returnOptions addObject:o];
                break;
        }
    }
    return returnOptions;
}
- (NSInteger) numberOfOption:(PackPotionOption *)option;
{
    return [self numberOfOption:option forState:MysticOptionStateAny];
    
}
- (NSInteger) numberOfOption:(PackPotionOption *)option forState:(MysticOptionState)optionState;
{
    NSInteger count = 0;
    for (PackPotionOption *o in self.allOptions) {
        if([o isSame:option] && [o inState:optionState])
        {
            count++;
        }
    }
    return count;
}
- (NSInteger) numberOfOptions:(id)type;
{
    return [self numberOfOptions:type forState:MysticOptionStateAny];
}
- (NSInteger) numberOfOptions:(id)type forState:(MysticOptionState)optionState;
{
    NSArray *opts = [self options:type forState:optionState];
    NSInteger c = 0;
    if(opts && opts.count) for (PackPotionOption *o in opts) c += o.count;
    return c;
}
- (NSInteger) numberOfConfirmedOptions;
{
    return [self numberOfLiveOptions:NO];
    
}
- (NSInteger) numberOfLiveOptions;
{
    return [self numberOfLiveOptions:YES];
}
- (NSInteger) numberOfLiveOptions:(BOOL)isLive;
{
    NSInteger l = 0;
    for (PackPotionOption *o in self.allOptions) {
        if(o.isPreviewOption == isLive) l++;
    }
    return l;
}
- (NSInteger) numberOfPreloadedDownloads;
{
    return _numberOfPreloadedDownloads;
}

- (BOOL) contains:(PackPotionOption *)option;
{
    return [self contains:option equal:NO];
}
- (BOOL) contains:(PackPotionOption *)option equal:(BOOL)checkForEqual;
{
    BOOL found = [self.allOptions containsObject:option];
    if(checkForEqual) return found;
    
    for (PackPotionOption *o in self.allOptions) {
        if([o isSame:option])
        {
            found = YES;
            break;
        }
    }
    
    return found;
}
- (BOOL) contains:(PackPotionOption *)option forState:(MysticOptionState)state;
{
    return [self contains:option forState:state equal:NO];
}
- (BOOL) contains:(PackPotionOption *)option forState:(MysticOptionState)state equal:(BOOL)checkForEqual;
{
    option = [self contains:option equal:checkForEqual] ? option : nil;
    return option && [option inState:state];
}
- (void) clean;
{
    self.tag = nil;
    [self.filters clean];
}
+ (void) reset;
{
    [[MysticOptions current] reset];
}
- (BOOL) hasInputAboveOption:(PackPotionOption *)option;
{
    return [self inputAboveOption:option] != nil;
}
- (id) inputAboveOption:(PackPotionOption *)option;
{
    if(!option || ![self contains:option]) return nil;
    BOOL hasImageAbove = NO;
    BOOL canCheck = NO;
    for (PackPotionOption *o in self.options) {
        BOOL isEqual = [o isEqual:option];
        if(isEqual) { canCheck = YES; continue; }
        if(!isEqual && !canCheck) continue;
        if(o.hasImage) return o;
        
    }
    
    return nil;
}
- (void) reset;
{
    [_options removeAllObjects];
    [_optionKeys removeAllObjects];
    
    [self.filters clean];
    self.tag = nil;
    self.tagPrefix = nil;
//    self.needsRender = YES;
}
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if(self.isCancelled) return;
    PackPotionOption *option = (PackPotionOption *)object;
    
    if(option.readyForRender)
    {
        [object removeObserver:self forKeyPath:keyPath];
    }
    
}
- (void) load:(MysticRenderOptions)opts progress:(MysticBlockDownloadProgress)progressBlock ready:(MysticBlockSender)onready;
{
    @autoreleasepool {
        
    
        __block  MysticOptionsBase *weakSelf = self;
        self.totalDownloads = 0;
        self.finishedDownloads = 0;
        self.isCancelled = NO;
        if(!self.count && onready)
        {
            _isReady = YES;
            onready(weakSelf);
            return;
        }
        [weakSelf removePreloads];
        NSMutableArray *_downloads = [NSMutableArray array];
        for (PackPotionOption *option in weakSelf.options) {
            
            if(![option isPreparedForSettings:weakSelf.settings])
                [option prepareForSettings:weakSelf.settings];
            if(option.numberOfDownloadsLeft)
            {
                option.isDownloading = YES;
                [self.preloads setObject:option forKey:option.tag];
                [_downloads addObjectsFromArray:option.downloadURLs];
                weakSelf.totalDownloads += option.numberOfDownloads;
                [option addObserver:weakSelf forKeyPath:@"readyForRender" options:NSKeyValueObservingOptionNew context:nil];
            }
        }
        
        if(weakSelf.totalDownloads > 0)
        {
            OptionsLog(@"OPTIONS: Waiting on %d downloads", (int)self.totalDownloads);
            weakSelf.readyBlock = nil;
            if(weakSelf.preloader)
            {
                [weakSelf.preloader cancelPrefetching];
            }
            weakSelf.readyBlock = onready;

            weakSelf.progressBlockCall = progressBlock;
            [weakSelf setProgressBlock:^(NSUInteger receivedSize, NSUInteger expectedSize){
                float percentReceived = (float)((float)receivedSize/(float)expectedSize);
                
                NSUInteger totalReceived = (NSUInteger)(weakSelf.finishedDownloads * (NSUInteger)MYSTIC_DATASIZE_NORMAL);
                NSUInteger _receivedSize = totalReceived + floor(percentReceived * (float)MYSTIC_DATASIZE_NORMAL);
                long long _expectedSize = (long long)((long long)weakSelf.totalDownloads * (long long)MYSTIC_DATASIZE_NORMAL);
                
                if(weakSelf.progressBlockCall) weakSelf.progressBlockCall(_receivedSize, _expectedSize);
            }];
            
    
            weakSelf.preloader.manager.skipStoreDisk = YES;

            [weakSelf.preloader prefetchURLs:_downloads progress:weakSelf.progressBlock completedData:^(NSUInteger finishedCount, NSUInteger totalCount, BOOL finished, UIImage *image, NSURL *url, SDImageCacheType cacheType, NSInteger currentIndex, NSData *imgData)
             {
                 
                 PackPotionOption *option = [weakSelf preloadOptionForURL:url];
                 if([url.absoluteString hasSuffix:@".jpng"])
                 {
                     NSString *jpngPath = [[MysticCache layerCache] cachePathForKey:[weakSelf.preloader.manager cacheKeyForURL:url]];
                     UIImage *compressedJPNG = imgData ? UIImageWithJPNGData(imgData, 1, UIImageOrientationUp) : nil;
                     

                     if(compressedJPNG)
                     {
                         UIGraphicsBeginImageContextWithOptions(compressedJPNG.size, NO, 1);
                         [compressedJPNG drawAtPoint:CGPointZero];
                         UIImage *uncompressedJPNG = UIGraphicsGetImageFromCurrentImageContext();
                         UIGraphicsEndImageContext();
                         
                         image = uncompressedJPNG;
                     }

                     cacheType == SDImageCacheTypeNone;
                     
                 }

                 [[MysticCache layerCache] storeImage:image forKey:[url absoluteString] toDisk:YES];
                 image = nil;
                 
                 [weakSelf preloaded:url];

                 if(weakSelf.isCancelled) {  return; }
                 
                 
                 
                 if(!finished) return;
                 
                 
                 
                 option.isDownloaded = YES;
                 weakSelf.isReady = YES;
                 weakSelf.progressBlock=nil;
                 weakSelf.progressBlockCall = nil;
                 if(weakSelf.readyBlock)
                 {
                     weakSelf.readyBlock(weakSelf);
                     weakSelf.readyBlock=nil;
                 }

                 
             }];
            
            //        });
        }
        else
        {
            _isReady = YES;
            if(onready != NULL) onready(weakSelf);
        }
    }
}

- (void) removePreloads;
{
    for (PackPotionOption *option in self.preloads.allValues) {
        if([option hasObserver:self]) [option removeObserver:self forKeyPath:@"readyForRender"];
    }
    [self.preloads removeAllObjects];

}

- (void) preloaded:(NSURL *)url;
{
    NSString *urlStr = [url absoluteString];
    self.finishedDownloads++;
    
//    OptionsLog(@"OPTIONS: Download #%d from %d options received: %@", (int)self.finishedDownloads, (int)[self.preloads allValues].count, urlStr);
    
    
    
    if(self.preloads && self.preloads.count)
    {
        for (PackPotionOption *option in [self.preloads allValues]) {
            if([option containsDownload:urlStr])
            {
                option.numberOfDownloaded++;
            }
            if (!option.hasDownloadsLeft) {
                option.isDownloading = NO;
                option.isDownloaded = YES;
                
                [option imageForSettings:self.settings size:self.size];
                
                
                
                
            }
            
//            OptionsLog(@"OPTIONS: Option '%@' finished %d of %d | Has Downloads Left: %@ | Ready: %@", MyString(option.type), (int)option.numberOfDownloaded, (int)option.numberOfDownloads, MBOOLStr(option.hasDownloadsLeft), MBOOLStr(option.readyForRender));
            
        }
    }
    
}

- (PackPotionOption *) preloadOptionForURL:(NSURL *)url;
{
    NSString *urlStr = [url absoluteString];
    
    
    if(self.preloads && self.preloads.count)
    {
        for (PackPotionOption *option in [self.preloads allValues]) {
            if([option containsDownload:urlStr])
            {
                return option;
            }
            
            
        }
    }
    return nil;
}




- (NSString *) hashTags;
{
    NSMutableArray *_tags = [NSMutableArray array];
    for (PackPotionOption *o in self.allOptions) {
        NSString *m = o.hashTags;
        
        if(m) [_tags addObject:m];
    }
    return [_tags count] ? [_tags componentsJoinedByString:@" "] : nil;
}
- (NSString *) message:(NSString *)defaultMessage prefix:(NSString *)prefix type:(MysticShareType)shareType
{
    NSString *msg = prefix ? prefix : @"";
    NSMutableArray *_tags = [NSMutableArray array];
    for (PackPotionOption *o in self.allOptions) {
        NSString *m = nil;
        switch (shareType) {
            case MysticShareTypeFacebook:
            {
                m = o.facebook;
                break;
            }
            case MysticShareTypeTwitter:
            {
                m = o.tweet;
                break;
            }
            case MysticShareTypeEmailSubject:
            {
                m = o.emailSubject;
                break;
            }
            case MysticShareTypeEmail:
            {
                m = o.emailMessage;
                break;
            }
            case MysticShareTypeEmailTo:
            {
                m = o.emailTo;
                break;
            }
            case MysticShareTypeLink:
            {
                m = o.messageLink;
                break;
            }
            default: break;
        }
        if(m && ![m isEqualToString:@""]) [_tags addObject:m];
    }
    return [_tags count] ? [msg stringByAppendingString:[_tags componentsJoinedByString:@" "]] : defaultMessage;
}
- (BOOL) hasOption:(PackPotionOption *)option;
{
    return [_optionKeys containsObject:option.tag];
}
- (void) refresh:(PackPotionOption *)option;
{
    [self.filters refresh:option];
}

- (NSInteger) groupIndexOfOption:(PackPotionOption *)currentOption;
{
    if(!currentOption) return NSNotFound;
    NSArray *currentOptions = currentOption ? [self options:@(currentOption.type)] : nil;
    NSInteger currentPage = currentOption && currentOptions ? [currentOptions indexOfObject:currentOption] : NSNotFound;
    return currentPage;
}
- (NSInteger) updateInputs;
{
    _numberOfInputs = 1;
    _numberOfShaders = 1;
    _numberOfInputTextures = 1;
    for (PackPotionOption *option in _options)
    {
        int n = option.numberOfInputTextures;
        
        if(option.hasInput && !option.ignoreActualRender) { _numberOfInputs++; _numberOfInputTextures++; }
        if(n > 1 && !option.ignoreActualRender) _numberOfInputTextures+=n-1;
        if(option.hasShader && !option.ignoreActualRender) _numberOfShaders++;
    }
    
//    DLog(@"update inputs: %d", (int)_numberOfInputs);
    return _numberOfInputs;
}
- (NSInteger) numberOfInputs; { return [self updateInputs]; }
- (NSInteger) numberOfShaders;
{
    [self updateInputs];
    return _numberOfShaders;
}

- (BOOL) cancelOption:(PackPotionOption *)option;
{
    return option ? [self removeOptions:@[option] cancel:YES] : NO;
}

#pragma mark - Set Options that Have Rendered

- (MysticOptions *) nonRenderedOptions;
{
    NSMutableArray *options = [NSMutableArray array];
    for (PackPotionOption *option in self.allOptions) {
        if(!option.hasRendered)
        {
            [options addObject:option];
        }
    }
    MysticOptions *newOptions = [self copy];
    
    [newOptions useOptions:options resetTag:NO];
//    newOptions.parentOptions = (id)self;
    return newOptions;
    
}

- (BOOL) hasRenderedOptions;
{
    for (PackPotionOption *option in self.allOptions) if(option.hasRendered) return YES;
    return NO;
}
- (BOOL) hasRendered;
{
    for (PackPotionOption *option in self.allOptions) if(!option.hasRendered) return NO;
    return YES;
}
- (void) setHasRendered:(BOOL)hasRendered;
{
    [self setOptionsToRendered:nil rendered:hasRendered];
}
- (void) setOptionsToRendered:(NSArray *)options rendered:(BOOL)hasRendered;
{
    for (PackPotionOption *option in options ? options : self.allOptions) {
        if(!option.isTransforming) option.hasRendered = hasRendered;
    }
}

- (NSString *) optionsUnrenderedAdjustmentsDescription;
{
    return [self optionsAdjustmentsDescription:@selector(unrenderedAdjustmentsDescription)];
//
//    NSMutableString *s = [NSMutableString string];
//    for (PackPotionOption *o in self.sortedRenderOptions) {
//        [s appendFormat:@"%@:  %@\n", o.shortDebugDescription, o.unrenderedAdjustmentsDescription];
//    }
//    [s appendString:@"\n\n"];
//    return s;
}

- (NSString *) optionsAndAdjustmentsDescription;
{
    return [self optionsAdjustmentsDescription:@selector(adjustmentsDescription)];

//    NSMutableString *s = [NSMutableString string];
//    for (PackPotionOption *o in self.sortedRenderOptions) {
//        [s appendFormat:@"%@:  %@\n", o.shortDebugDescription, o.adjustmentsDescription];
//    }
//    [s appendString:@"\n\n"];
//    return s;
}

- (NSString *) optionsRenderedAdjustmentsDescription;
{
    return [self optionsAdjustmentsDescription:@selector(renderedAdjustmentsDescription)];
//
//    NSMutableString *s = [NSMutableString string];
//    for (PackPotionOption *o in self.sortedRenderOptions) {
//        [s appendFormat:@"%@:  %@\n", o.shortDebugDescription, o.renderedAdjustmentsDescription];
//    }
//    [s appendString:@"\n\n"];
//    return s;
}

- (NSString *) optionsAllAdjustmentsDescription;
{
    return [self optionsAdjustmentsDescription:@selector(allAdjustmentsDescription)];
//    NSMutableString *s = [NSMutableString string];
//    for (PackPotionOption *o in self.sortedRenderOptions) {
//        [s appendFormat:@"%@:  %@\n", o.shortDebugDescription, o.allAdjustmentsDescription];
//    }
//    [s appendString:@"\n\n"];
//    return s;
}

- (NSString *) optionsAdjustmentsDescription:(SEL)selector;
{
    NSMutableString *s = [NSMutableString stringWithString:@"\n"];
    for (PackPotionOption *o in self.sortedRenderOptions) {
        [s appendFormat:@"%@:  %@\n", o.shortDebugDescription, [o performSelector:selector]];
    }
    [s appendString:@"\n\n"];
    return s;
}

- (BOOL) hasUnrenderedOptions;
{
    for (PackPotionOption *o in self) {
        if(!o.hasRendered) return YES;
    }
    return NO;
}


#pragma mark - Remove Options

- (void) removeAllOptions;
{
    [self removeOptions:nil cancel:NO];
}
- (BOOL) removeOption:(PackPotionOption *)option;
{
    return option ? [self removeOptions:@[option] cancel:YES] : NO;
    
}

- (BOOL) removeOptions:(NSArray *)options;
{
    return [self removeOptions:options cancel:YES];
}
- (BOOL) removeOptions:(NSArray *)options cancel:(BOOL)shouldCancel;
{
    
    if(_optionsWithRules) {
        [_optionsWithRules release], _optionsWithRules=nil;
        changedOptionRules = YES;
    }
//        DLog(@"OPTIONS <%p>   %@  |  Remove Options: %@", self, [self isEqual:[MysticOptions current]] ? @"Live" : @"temp", options);
    PackPotionOption *option;
    BOOL removedOption = NO;
    
    if(!options)
    {
        NSMutableArray *___options = [NSMutableArray array];
        [___options addObjectsFromArray:self.allOptions];
        options = ___options;
    }
    
    NSMutableArray *__options = [NSMutableArray array];
    [__options addObjectsFromArray:self.allOptions];
    
    NSMutableArray *__optionKeys = [NSMutableArray array];
    [__optionKeys addObjectsFromArray:self.optionKeys];
    
    NSInteger lowestRemoval = NSIntegerMax;
    for (PackPotionOption *option in options)
    {
        if(![self contains:option equal:YES]) continue;
        NSInteger ti = [__options indexOfObject:option];
        lowestRemoval = MIN(lowestRemoval, ti);
    }
    for (PackPotionOption *option in options)
    {
        if(![self contains:option equal:YES]) continue;
        if(option.hasInput) _numberOfInputs--;
        _numberOfInputTextures-=option.numberOfInputTextures;
        if(option.hasShader) _numberOfShaders--;
        if(shouldCancel) [option confirmCancel];
        NSInteger ti = [__options indexOfObject:option];
        [__optionKeys removeObjectAtIndex:ti];
        [__options removeObject:option];
        //        option.isAdded = NO;
        removedOption = YES;
        [_textureSizes removeObjectForKey:option.tag];
    }
    if(removedOption)
    {
        
        NSMutableArray *__sortedOptions = [NSMutableArray arrayWithArray:[self sortedOptions:__options]];
        [_options release];
        _options = [__sortedOptions retain];
        
        NSMutableArray *__sortedKeys = [NSMutableArray arrayWithCapacity:__optionKeys.count];
        
        for (PackPotionOption *o in __sortedOptions) {
            NSInteger index = [__sortedOptions indexOfObject:o];
            id oKey = [__optionKeys objectAtIndex:index];
            [__sortedKeys addObject:oKey];
        }
        [_optionKeys release];
        _optionKeys = [__sortedKeys retain];
        self.tag = nil;
        
        
        _hasChanged = YES;
        NSInteger i2 = 0;
        
        for (PackPotionOption *o in self.allOptions) {
            
            if(i2 >= lowestRemoval)
            {
                
                o.hasChanged = YES;
            }
            i2++;
        }
        
//        self.hasChanged = YES;
        
        
    }
    
    
    
    //    _hasChanged = YES;
    //    [self updateOptions];
    return removedOption;
}

#pragma mark - Add Options

- (void) addOption:(PackPotionOption *)option;
{
    if(option) [self addOptions:@[option]];
}
- (void) addOptions:(NSArray *)optionsToAdd;
{
    

    if(_optionsWithRules) {
        [_optionsWithRules release], _optionsWithRules=nil;
        changedOptionRules = YES;
    }
    NSMutableArray *__options = [NSMutableArray array];
    [__options addObjectsFromArray:self.allOptions];
    NSMutableArray *__optionKeys = [NSMutableArray array];
    [__optionKeys addObjectsFromArray:self.optionKeys];
//    DLogError(@"Options 1: %@", __options.count ? __options : @"----");
//    DLogError(@"Keys 1: %@", __optionKeys.count ? __optionKeys : @"----");
//
//    DLogError(@"-------\n\n");

    for (PackPotionOption *option in optionsToAdd)
    {
        option.owner = nil;
        option.weakOwner = (id)(self.topLevelOptions ? self.topLevelOptions : self);
        option.isAdded = YES;
        NSInteger numberOfEffects = [[MysticOptions current] numberOfOption:option forState:MysticOptionStateConfirmed];
        if(option.instanceIndex == NSNotFound) option.instanceIndex = numberOfEffects;
        [__optionKeys addObject:option.tag ? option.tag : option.optionSlotKey];
        [__options addObject:option];
        if(option.hasInput) _numberOfInputs++;
        _numberOfInputTextures+=option.numberOfInputTextures;
        if(option.hasShader) _numberOfShaders++;
    }
//    DLogError(@"Options 2: %@", __options.count ? __options : @"----");
//    DLogError(@"Keys 2: %@", __optionKeys.count ? __optionKeys : @"----");
//    
//    DLogError(@"------------------\n\n");
    
    NSMutableArray *__sortedOptions = [NSMutableArray arrayWithArray:[self sortedOptions:__options]];
    [_options release];
    _options = [__sortedOptions retain];
    
    NSMutableArray *__sortedKeys = [NSMutableArray arrayWithCapacity:__optionKeys.count];
    for (PackPotionOption *o in __sortedOptions) {
        [__sortedKeys addObject:[__optionKeys objectAtIndex:[__options indexOfObject:o]]];
    }
//    DLogError(@"sorted options: %@\n\nKeys: %@\n\n\n", __sortedOptions, __sortedKeys);
//    DLog(@"-----------------------------------");

    [_optionKeys release];
    _optionKeys = [__sortedKeys retain];
    self.tag = nil;
    [self setHasChanged:YES changeOptions:NO];

}



#pragma mark - Reset Options

- (void) resetOptions:(NSArray *) newOptions;
{
    NSMutableArray *__options = [NSMutableArray array];
    [__options addObjectsFromArray:self.allOptions];
    
    NSMutableArray *__optionKeys = [NSMutableArray array];
    [__optionKeys addObjectsFromArray:self.optionKeys];
    
    
    NSMutableArray *__sortedOptions = [NSMutableArray arrayWithArray:newOptions];
    [_options release];
    _options = [__sortedOptions retain];
    
    NSMutableArray *__sortedKeys = [NSMutableArray array];
    for (PackPotionOption *o in __sortedOptions) {
        NSInteger index = [__options indexOfObject:o];
        id oKey = [__optionKeys objectAtIndex:index];
        [__sortedKeys addObject:oKey];
    }
    [_optionKeys release];
    _optionKeys = [__sortedKeys retain];
}

- (PackPotionOption *) lowestOption:(MysticObjectType)type;
{
    return [self option:type];
}

- (void) setSettings:(MysticRenderOptions)newSettings;
{
    _settings = newSettings;
    if(_settings & MysticRenderOptionsForceProcess) { self.filters.sourceNeedsProcess = YES; [self setNeedsRender]; }
    if(_settings & MysticRenderOptionsRefresh) [self setNeedsRender];
    if(_settings & MysticRenderOptionsEmptyFirst) [self.filters empty];
}
- (void) prepareForRender;
{
    [self.filters clean];
    
}
- (void) finishedRendering;
{
    self.settings = self.settings & ~MysticRenderOptionsRefresh;
    self.settings = self.settings & ~MysticRenderOptionsForceProcess;
    self.settings = self.settings & ~MysticRenderOptionsEmptyFirst;
    [self setHasChanged:NO changeOptions:NO];
    [self setNeedsRender:NO];
}
- (void) setNeedsRender;
{
    [self setNeedsRender:YES];
}
- (BOOL) setNeedsRender:(BOOL)value;
{
    return [self setNeedsRender:value force:NO];
}
- (BOOL) setNeedsRender:(BOOL)value force:(BOOL)force;
{
    BOOL _needsIt = NO;
    for (PackPotionOption *o in self.allOptions) {
        if(!_needsIt && o.shouldRender != value) _needsIt = value;
        o.shouldRender = value;
        if(value && force) { o.hasRendered=NO;o.ignoreRender=NO; o.ignoreActualRender=NO;  }
    }
    _needsRender = value;
    return _needsIt;
}
- (BOOL) needsRender;
{
    if(!_needsRender) for (PackPotionOption *o in self.allOptions) if(!_needsRender && o.shouldRender) _needsRender = YES;
    return _needsRender;
}
- (NSArray *) allOptions;
{
    return [NSArray arrayWithArray:_options];
}

- (NSArray *) options;
{
    return self.allOptions;
}

- (NSArray *) optionsToRender;
{
    
    NSMutableArray *__os = [NSMutableArray array];
    NSArray *_os = [NSArray arrayWithArray:_options];
    for (PackPotionOption *o in _os) {
        if(o.shouldRender) [__os addObject:o];
    }
    return [NSArray arrayWithArray:__os];
}
- (NSArray *) transformingOptions;
{
    NSMutableArray *__opts = [NSMutableArray array];
    
    NSArray *__options = [NSArray arrayWithArray:self.allOptions];
    for (PackPotionOption *o in __options) {
        if(o.isTransforming) [__opts addObject:o];
    }
    
    return __opts;
}
- (NSArray *) optionKeys;
{
    return [NSArray arrayWithArray:_optionKeys];
}


- (NSInteger) totalCount;
{
    return _options.count;
}
- (NSInteger) numberOfOptionsToRender;
{
    return self.optionsToRender.count;
}
- (NSInteger) count;
{
    return [self.options count];
}



- (PackPotionOption *) previewOption;
{
    for (PackPotionOption *o in self.allOptions) if(o.isPreviewOption) return o;
    return nil;
}
- (PackPotionOption *) transformingOption:(MysticObjectType)orType;
{
    return [self transformingOption:orType orUseOptionOfSameType:YES];
}
- (PackPotionOption *) transformingOption:(MysticObjectType)orType orUseOptionOfSameType:(BOOL)forceFind;
{
    orType = MysticTypeForSetting(orType, nil);
    
    PackPotionOption *t = self.transformingOption;
    
    if(t && t.type != orType)
    {
        NSArray *ts = [self transformingOptions];
        for (PackPotionOption *o in ts) {
            if(o.type == orType) { t = o; break; }
        }
    }
    
    if(forceFind && (!t || t.type != orType)) t = (PackPotionOption *)[self option:orType];
    
    return t;
}
- (PackPotionOption *) transformingOption;
{
    for (PackPotionOption *o in self.allOptions) {
        if(o.isTransforming) return o;
    }
    return nil;
}
- (void) transform:(PackPotionOption *)option;
{
    for (PackPotionOption *o in self.allOptions) {
        if((!option || ![o isEqual:option]) && o.isTransforming) o.isTransforming = NO;
    }
    if(option) option.isTransforming = YES;
}

- (PackPotionOption *) pickingOption;
{
    return [self pickingOptionOfType:MysticObjectTypeAll];
}
- (PackPotionOption *) pickingOptionOfType:(MysticObjectType)type;
{
    type = MysticTypeForSetting(type, nil);
    
    for (PackPotionOption *o in self.allOptions) {
        if(!o.isConfirmed && (o.type == type || type == MysticObjectTypeAll)) return o;
    }
    return nil;
}
- (PackPotionOption *) focused:(MysticObjectType)type;
{
    type = MysticTypeForSetting(type, nil);
    
    for (PackPotionOption *o in self.allOptions) {
        if(o.inFocus && (o.type == type || type == MysticObjectTypeAll)) return o;
    }
    return nil;
}
- (void) focus:(PackPotionOption *)option;
{
    option.inFocus = YES;
    MysticObjectType type = MysticTypeForSetting(option.type, option);
    
    for (PackPotionOption *o in self.allOptions) {
        if(o.type == type)
        {
            o.inFocus = NO;
        }
    }
    option.inFocus = YES;
}
- (id) optionForSlotKey:(id)slotKey;
{
    if(!slotKey) return nil;
    for (PackPotionOption *o in self.allOptions) {
        if(o.optionSlotKey && [o.optionSlotKey isEqualToString:slotKey])
        {
            return o;
        }
    }
    return nil;
}
- (id) similarOption:(PackPotionOption *)option;
{
    if(!option) return nil;
    id sim = nil;
    if(option.optionSlotKey)
    {
        sim = [self optionForSlotKey:option.optionSlotKey];
    }
    if(!sim)
    {
        sim = [self option:option.type];
    }
    return sim;
}
- (void) pick:(PackPotionOption *)option;
{
    if(!option.isRenderableOption) return;
    BOOL foundSlot = NO;
    option.isConfirmed = NO;
    option.lastPicked = YES;
    option.inFocus = YES;
    NSInteger optionIndex = NSNotFound;
    NSMutableArray *otherPicks = [NSMutableArray array];

    if(option.optionSlotKey)
    {
        PackPotionOption *o = [self optionForSlotKey:option.optionSlotKey];

        if(o && ![o isEqual:option])
        {
            o.lastPicked = NO;
            o.inFocus = NO;
            [otherPicks addObject:o];
            optionIndex = [_options indexOfObject:o];
            if(otherPicks.count)
            {
                foundSlot = YES;
           
                option.weakOwner = (id)(self.topLevelOptions ? self.topLevelOptions : self);
                option.isAdded = YES;
                NSInteger numberOfEffects = [[MysticOptions current] numberOfOption:option forState:MysticOptionStateConfirmed];
                if(option.instanceIndex == NSNotFound)
                {
                    option.instanceIndex = numberOfEffects;
                }
                
                NSMutableArray *__options = [NSMutableArray array];
                [__options addObjectsFromArray:self.allOptions];
                
                NSMutableArray *__optionKeys = [NSMutableArray array];
                [__optionKeys addObjectsFromArray:self.optionKeys];
                [__options replaceObjectAtIndex:optionIndex withObject:option];
                [__optionKeys replaceObjectAtIndex:optionIndex withObject:option.tag];
                
                [_options release];
                _options = [__options retain];
                [_optionKeys release];
                _optionKeys = [__optionKeys retain];
                self.tag = nil;
                [o confirmCancel];
                
                [self setHasChanged:YES changeOptions:NO];


                return;
            }
        }
        else if(o)
        {

            return;
        }
        
        
    }
    
    option.optionSlotKey = option.optionSlotKey ? option.optionSlotKey : [self makeSlotKeyForOption:option];
    
    if(!foundSlot)
    {
        MysticObjectType pickedType = MysticTypeForSetting(option.type, option);
//        DLogHidden(@"no found slot: type: %@", MyString(pickedType));
        for (PackPotionOption *o in self.allOptions) {
//            DLogHidden(@"\t - confirmed: %@ -> %@  %@", MBOOL(o.isConfirmed), MyString(o.type), o);
            if(o.type == pickedType)
            {
                o.lastPicked = NO;
                o.inFocus = NO;
                if(!o.isConfirmed) [otherPicks addObject:o];
            }
        }
        if(otherPicks.count)
        {
//            DLogError(@"pick has other picks that arent confirmed: %@", otherPicks);
            [self removeOptions:otherPicks];
        }
    }

    [self addOption:option];
    [self setHasChanged:YES changeOptions:NO];
}
- (PackPotionOption *) lastPickedOptionOfType:(MysticObjectType)pickedType;
{
    return [self lastPickedOptionOfType:pickedType forState:MysticOptionStateAny];
}
- (PackPotionOption *) lastPickedOptionOfType:(MysticObjectType)pickedType forState:(MysticOptionState)optionState;
{
    for (PackPotionOption *o in self.allOptions)
    {
        if(o.type == pickedType && o.lastPicked && [o inState:optionState])
        {
            return o;
        }
    }
    return nil;
}
- (BOOL) confirm:(id)optionOrOptionsOrType;
{
    NSMutableArray *confirms = [NSMutableArray array];
    if([optionOrOptionsOrType isKindOfClass:[NSArray class]])
        for (id o in optionOrOptionsOrType) {
            if([o isKindOfClass:[NSNumber class]]) [confirms addObjectsFromArray:[self options:o]];
            else if([o isKindOfClass:[MysticOption class]]) [confirms addObject:o];
        }
    else if([optionOrOptionsOrType isKindOfClass:[NSNumber class]]) [confirms addObjectsFromArray:[self options:optionOrOptionsOrType]];
    else if([optionOrOptionsOrType isKindOfClass:[MysticOption class]]) [confirms addObject:optionOrOptionsOrType];
    for (PackPotionOption *o in confirms) o.isConfirmed = o.canBeConfirmed ? YES : o.isConfirmed;
    return confirms.count ? YES : NO;
}
+ (id) slotKeyForOption:(MysticOption *)option or:(id)obj;
{
    id slotKey = option && option.optionSlotKey ? option.optionSlotKey : nil;
    return slotKey ? slotKey : [self slotKeyForOption:(option ? option : obj) force:NO];
}
+ (NSString *) slotKeyForOption:(MysticOption *)option;
{
    return [self slotKeyForOption:option force:NO];
}
+ (NSString *) slotKeyForOption:(MysticOption *)option force:(BOOL)force;
{
    int r = 0;
    int c = 10000;
    if (&arc4random_uniform != NULL)
        r = arc4random_uniform (c);
//    else
//        r = (arc4random() % c);
    
    NSString *optKey = option && [option isKindOfClass:[PackPotionOption class]] ? MyString(option.type) : [NSString stringWithFormat:@"%@", option ? MObj(option) : @"?"];
    NSString *hash = [[NSString stringWithFormat:@"%d%d", (int)[NSDate timeIntervalSinceReferenceDate], r] md5];
    return [[NSString stringWithFormat:@"%@-%@", optKey , [hash substringToIndex:6]] lowercaseString];
}

- (id) makeSlotKeyForOption:(MysticOption *)option;
{
    return [self makeSlotKeyForOption:option force:NO];
}
- (id) makeSlotKeyForOption:(MysticOption *)option force:(BOOL)force;
{
    return [MysticOptions slotKeyForOption:option force:force];
}

- (NSArray *) types;
{
    NSMutableArray *types = [NSMutableArray array];
    for (PackPotionOption *o in self.options) [types addObject:MysticString(o.type)];
    return types;
}

- (NSDictionary *) changedOptions;
{
    return [self changedOptions:YES includeAboveOptions:NO];
}
- (NSDictionary *) renderableOptions;
{
    return [self changedOptions:YES includeAboveOptions:YES];
}
- (NSDictionary *) changedOptions:(BOOL)changedValue includeAboveOptions:(BOOL)includeAbove;
{
    BOOL foundChange = NO;
    PackPotionOption *lastOption = nil;
    PackPotionOption *previousOption = nil;
    NSMutableArray *changedEffects = [NSMutableArray array];
    NSMutableArray *beforeEffects = [NSMutableArray array];
    
    for (PackPotionOption *option in self.sortedAllOptions) {
        if((includeAbove && foundChange) || option.hasChanged == changedValue)
        {
            if(!foundChange) previousOption = lastOption;
            foundChange = YES; [changedEffects addObject:option];
        }
        if(!foundChange) [beforeEffects addObject:option];
        lastOption = option;
    }
    return previousOption ? @{@"effects":changedEffects, @"previous":previousOption, @"before":beforeEffects} : @{@"effects":changedEffects, @"before":beforeEffects};
}

- (NSArray *) sortedOptions;
{
    return [self sortedOptions:self.options];
}
- (NSArray *) sortedAllOptions;
{
    return [self sortedOptions:self.allOptions];
}
- (void) resort;
{
    return;
//    NSInteger l = 1;
//    for (PackPotionOption *o in self.sortedAllOptions) {
//        BOOL _c = o.hasChanged;
//        o.level = l;
//        o.hasChanged = _c;
//        l++;
//    }
//    self.tag = nil;
}

- (void) reorder:(NSArray *)newOrderedOptions;
{
    if(_optionsWithRules) {
        [_optionsWithRules release], _optionsWithRules=nil;
        changedOptionRules = YES;
    }
    
    NSInteger lowestLevel = NSNotFound;
    NSMutableArray *newOptions = [NSMutableArray arrayWithArray:newOrderedOptions];
    for (PackPotionOption *o in self.allOptions) {
        if(![newOptions containsObject:o])
        {
            [newOptions addObject:o];
        }
    }
    for (PackPotionOption *o in newOptions) {
        lowestLevel = MIN(lowestLevel, o.level);
    }
    for (PackPotionOption *o in newOptions) {
        NSInteger before = o.level;
        o.level = lowestLevel;
        o.hasChanged = o.level != before;
        lowestLevel++;
    }
    
    [_options release];
    _options = [[NSMutableArray arrayWithArray:[self sortedOptions:newOptions]] retain];
    [self updateInputs];
    for (PackPotionOption *option in _options)
    {
        [option reordered];
    }
    
    
}

#pragma mark - Sorted Options

- (NSArray *) sortedOptions:(NSArray *)opts;
{
    return [self sortedOptions:opts rules:MysticRenderOptionsAuto];
}
- (NSArray *) sortedOptions:(NSArray *)opts rules:(MysticRenderOptions)sortRules;
{
    //    if(sortRules != MysticRenderOptionsAuto && !changedOptionRules && _optionsWithRules){
    //        DLog(@"sorted options returning cache");
    //        return _optionsWithRules;
    //    }
    //    if(sortRules & MysticRenderOptionsFilterUpToTransform)
    //    {
    //        NSMutableArray *filterOpts = [NSMutableArray arrayWithCapacity:opts.count];
    //
    //        for (PackPotionOption *o in opts) {
    //            if(o.isTransforming)
    //            {
    //                [filterOpts addObject:o];
    //                break;
    //            }
    //            else
    //            {
    //                [filterOpts addObject:o];
    //            }
    //        }
    //
    //        opts = [NSArray arrayWithArray:filterOpts];
    //
    //        DLog(@"sortedOptions: MysticRenderOptionsFilterUpToTransform: %d", opts.count);
    //
    //    }
    //    else if(sortRules & MysticRenderOptionsFilterUpToFocus)
    //    {
    //        NSMutableArray *filterOpts = [NSMutableArray arrayWithCapacity:opts.count];
    //
    //        for (PackPotionOption *o in opts) {
    //            if(o.inFocus)
    //            {
    //                [filterOpts addObject:o];
    //                break;
    //            }
    //            else
    //            {
    //                [filterOpts addObject:o];
    //            }
    //        }
    //
    //        opts = [NSArray arrayWithArray:filterOpts];
    //
    //        DLog(@"sortedOptions: MysticRenderOptionsFilterUpToFocus: %d", opts.count);
    //
    //    }
    
    
    
    NSComparator compare;
    
    if(sortRules & MysticRenderOptionsSortFocusOptionOnTop)
    {
        
        //        DLog(@"sortedOptions: MysticRenderOptionsSortFocusOptionOnTop");
        
        
        
        compare = ^(PackPotionOption* obj1, PackPotionOption* obj2) {
            
            if (/* obj1.inFocus || */ [obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
    }
    else if(sortRules & MysticRenderOptionsSortTransformingOptionOnTop)
    {
        //        DLog(@"sortedOptions: MysticRenderOptionsSortTransformingOptionOnTop");
        
        
        compare = ^(PackPotionOption* obj1, PackPotionOption* obj2) {
            
            if (/* obj1.isTransforming || */ [obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
    }
    else
    {
        
        
        compare = ^(PackPotionOption* obj1, PackPotionOption* obj2) {
            
            if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
    }
    
    NSArray *theOptions = [opts sortedArrayUsingComparator:compare];
    
    switch (self.sortOrder) {
        case MysticSortOrderReverse:
            theOptions = [theOptions reversedArray];
            break;
        case MysticSortOrderRandom:
            theOptions = [theOptions shuffledArray];
            break;
        default: break;
    }
    //    if(theOptions.count && changedOptionRules)
    //    {
    //        if(_optionsWithRules) [_optionsWithRules release], _optionsWithRules=nil;
    //        _optionsWithRules = [theOptions retain];
    //        changedOptionRules = NO;
    //    }
    return theOptions;
}
#pragma mark -
- (void) useCleanFilters;
{
    self.filters = [MysticFilterManager manager];
    
}
- (void) setFilters:(MysticFilterManager *)value;
{
    if(self.topLevelOptions) {
        [self.topLevelOptions setFilters:value];
        return;
    }
    
    
    if(_filters) [_filters release], _filters = nil;
    if(value) value.index = self.renderIndex;
    _filters = value ? [value retain] : nil;
    
    //    DLog(@"setting filters for: Options <%p>  ==  %@", self, value);
    
}
- (MysticFilterManager *) filters;
{
    if(self.topLevelOptions) return self.topLevelOptions.filters;
    if(_filters) return _filters;

    [self setFilters:[MysticFilterManager manager]];
    return _filters;
}

- (BOOL) hasFilters;
{
    if(self.manager) return self.manager.hasFilters;

    return _filters != nil ? YES : NO;
}
- (void) recycleFilters:(MysticFilterManager *)junkFilters;
{
    if(!junkFilters) return;
    
    NSMutableArray *recycledLayers = [NSMutableArray array];
    NSMutableArray *currentLayers = nil;
    
    for (MysticOption *o in self.allOptions) {
        if(self.hasFilters && [_filters layerForOption:o]) continue;
        MysticFilterLayer *junkLayer = [junkFilters layerForOption:o];
        if(junkLayer)
        {
            [recycledLayers addObject:junkLayer];
        }
    }
    if(recycledLayers.count)
    {
        DLog(@"able to recycle %lu layers from junkFilters", (unsigned long)recycledLayers.count);
        if(!self.hasFilters)
        {
            DLog(@"doesnt have existing filters so using junk <%p>", junkFilters);
            [junkFilters removeLayersExcept:recycledLayers];
            [self setFilters:junkFilters];
        }
        else
        {
            DLog(@"does have existing filters <%p> so just using the recycled layers", _filters);
            [_filters addLayers:recycledLayers];
        }
        DLog(@"done recycling...");
    }
    
}
- (MysticOptions *) copy;
{
    return [[self duplicate] retain];
}
- (MysticOptions *) duplicate;
{
    return [[self class] duplicate:(id)self];
}
- (id) copyWithOptionsInRange:(NSRange)range;
{
    
    
    NSArray *subOpts = [self.sortedRenderOptions subarrayWithRange:range];
    MysticOptions *newOptions = [self copy];
    
    
    [newOptions useOptions:subOpts];
    
    return newOptions;
}
+ (id) duplicate:(MysticOptions *)optionsSource;
{
    MysticOptions *optionsCopy = [[self class] options];
    BOOL needsRender = optionsSource.needsRender;
    [optionsCopy useOptions:optionsSource.allOptions];
    optionsCopy.settings = optionsSource.settings;
    optionsCopy.size = optionsSource.size;
    optionsCopy.renderIndex = optionsSource.renderIndex;
    //    if(optionsSource.hasFilters)
    //    {
    //        DLog(@"copying existing filters <%p> to Options <%p>", _filters, optionsCopy);
    //        //[optionsCopy setFilters:_filters];
    //    }
    optionsCopy.isRenderOptions = optionsSource.isRenderOptions;
    //    optionsCopy.preloader = optionsSource.preloader ? optionsSource.preloader : nil;
    optionsCopy.index = optionsSource.index;
    optionsCopy.progressBlock = optionsSource.progressBlock;
    optionsCopy.progressBlockCall = optionsSource.progressBlockCall;
    optionsCopy.readyBlock = optionsSource.readyBlock;
    optionsCopy.delegate = optionsSource.delegate;
    optionsCopy.optionRules = optionsSource.optionRules;
    optionsCopy.tagPrefix = optionsSource.tagPrefix;
    optionsCopy.originalTag = optionsSource.originalTag;
    NSString *_tag = optionsSource.tag;
    optionsCopy.tag = _tag ? _tag : nil;
    optionsCopy.imageView = optionsSource.imageView;
    optionsCopy.manager = optionsSource.manager;
    optionsCopy.isReady = optionsSource.isReady;
    optionsCopy.sourceImage = optionsSource.sourceImage;
    optionsCopy.scale = optionsSource.scale;
    [optionsCopy setHasChanged:[optionsSource hasChangedValue] changeOptions:NO];
    [optionsCopy updateInputs];
    optionsCopy.needsRender = needsRender;
    return optionsCopy;
}

- (MysticOptions *)topLevelOptions;
{
    return self.manager ? self.manager : self.parentOptions;
}

- (NSUInteger) indexOfChangedOption;
{
    NSUInteger changedIndex = NSNotFound;
    NSArray *sortedRenderableEffects = [self sortedRenderOptions];
    NSUInteger i = 0;
    for (PackPotionOption *opt in sortedRenderableEffects)
    {
        if(opt.isPreviewOption || opt.hasChanged)
        {
            changedIndex = i;
            break;
        }
        i++;
        
    }
    return changedIndex;
}

- (MysticOptions *) unchangedSubsetOfOptions;
{
    MysticOptions *subset = nil;
    NSUInteger changedIndex = self.indexOfChangedOption;
    
    if(changedIndex != NSNotFound && changedIndex > 0)
    {
        NSArray *subsetOptionsOpts = [self.sortedRenderOptions subarrayWithRange:NSMakeRange(0, changedIndex)];
        subset = [self copy];
        [subset useOptions:subsetOptionsOpts];
        [subset setHasChanged:NO changeOptions:YES];

    }

    
    return [subset autorelease];
}

- (MysticOptions *) changedSubsetOfOptions;
{
    MysticOptions *subset = nil;
    NSUInteger changedIndex = self.indexOfChangedOption;
    
    if(changedIndex != NSNotFound && changedIndex > 0)
    {
        NSArray *sortedOptions = self.sortedRenderOptions;
//        changedIndex = changedIndex == NSNotFound ? 0 : changedIndex;
        int len = sortedOptions.count - changedIndex;
        NSArray *subsetOptionsOpts = [sortedOptions subarrayWithRange:NSMakeRange(changedIndex, len)];
        if(subsetOptionsOpts && subsetOptionsOpts.count)
        {
            subset = [self copy];
            [subset useOptions:subsetOptionsOpts];
            [subset setHasChanged:YES changeOptions:NO];
        }
    }
    return [subset autorelease];
}

- (void) useOptions:(NSArray *)optionsArray;
{
    [self useOptions:optionsArray resetTag:YES];
}
- (void) useOptions:(NSArray *)optionsArray resetTag:(BOOL)resetTag;
{
    _numberOfInputs = 1;
    _numberOfShaders = 1;
    
    NSMutableArray *__options = [NSMutableArray array];
    NSMutableArray *__optionKeys = [NSMutableArray array];
    
    
    for (PackPotionOption *option in optionsArray) {
        
        
        if(option.hasInput)_numberOfInputs++;
        _numberOfInputTextures+=option.numberOfInputTextures;
        if(option.hasShader) _numberOfShaders++;
        option.weakOwner = (id)(self.topLevelOptions ? self.topLevelOptions : self);
        [__optionKeys addObject:option.tag];
        [__options addObject:option];
        
    }
    
    if(__options.count)
    {
        NSMutableArray *__sortedOptions = [NSMutableArray arrayWithArray:[self sortedOptions:__options]];
        [_options release];
        _options = [__sortedOptions retain];
        
        NSMutableArray *__sortedKeys = [NSMutableArray arrayWithCapacity:__optionKeys.count];
        for (PackPotionOption *o in __sortedOptions) {
            NSInteger index = [__options indexOfObject:o];
            id oKey = [__optionKeys objectAtIndex:index];
            [__sortedKeys addObject:oKey];
        }
        [_optionKeys release];
        _optionKeys = [__sortedKeys retain];
    }
    
    
    if(resetTag) self.tag = nil;
}

- (MysticOptions *) render:(MysticOptions *)renders;
{
    if(renders)
    {
        
        if(renders.totalCount != self.totalCount)
        {
            for (PackPotionOption *o in self.allOptions) {
                o.shouldRender = [renders contains:o equal:YES];
            }
        }
        
    }
    
    return (id)self;
}

- (UIImage *) addOverlays:(UIImage *)bgImage;
{
    UIImage *rendered = bgImage;
    for (PackPotionOption *effect in self.options)
    {
        if(effect.hasOverlaysToRender)
        {
            rendered = [effect render:(id)self background:rendered];
        }
    }
    return rendered;
}



- (void) reportStatus;
{
    OptionsLog(@"OPTIONS: %@", _options);
}


+ (NSInteger) numberOfInputs:(id <NSFastEnumeration>)fromOptions;
{
    NSInteger __numberOfInputs = 1;
    for (PackPotionOption *option in fromOptions)
    {
        if(option.hasInput && !option.ignoreActualRender) __numberOfInputs++;
    }
    return __numberOfInputs;
}

+ (NSInteger) numberOfInputTextures:(id <NSFastEnumeration>)fromOptions;
{
    return [self numberOfInputTextures:fromOptions includeSubTextures:YES];
}
+ (NSInteger) numberOfInputTextures:(id <NSFastEnumeration>)fromOptions includeSubTextures:(BOOL)includeSubs;
{

    NSInteger __numberOfInputs = 1;
    for (PackPotionOption *option in fromOptions)
    {
//        if(!option.ignoreActualRender) __numberOfInputs += option.numberOfInputTextures;
        if(option.hasInput && !option.ignoreActualRender) __numberOfInputs++;
        if(option.hasMaskImage && !option.ignoreActualRender && includeSubs) __numberOfInputs++;
        if(option.adjustColorsFinal.count > 0 && !option.ignoreActualRender && includeSubs && option.hasMapImage) __numberOfInputs++;

    }
    return __numberOfInputs;
}

+ (NSInteger) numberOfShaders:(id <NSFastEnumeration>)fromOptions;
{
    NSInteger __numberOfShaders = 1;
    for (PackPotionOption *option in fromOptions)
    {
        if(option.hasShader && !option.ignoreActualRender) __numberOfShaders++;
    }
    return __numberOfShaders;
}

- (NSInteger) numberOfTextures;
{
    NSArray *sortedRenderableEffects = self.sortedRenderOptions;
    NSInteger c = 0;
    for (PackPotionOption *option in sortedRenderableEffects)
    {
        if(!option.hasShader || option.ignoreActualRender) continue;
        c++;
    }
    return c;
    
}
- (NSInteger) numberOfChangedOptions;
{
    NSInteger i = 0;
    for (PackPotionOption *o in self.allOptions) if(o.hasChanged) i+=1;
    return i;
}
- (NSInteger) numberOfUnrenderedOptions;
{
    NSInteger i = 0;
    for (PackPotionOption *o in self.allOptions) {
        if(!o.hasRendered) i+=1;
    }
    return i;
}
- (NSInteger) numberOfRenderedOptions;
{
    NSInteger i = 0;
    for (PackPotionOption *o in self.allOptions) {
        if(o.hasRendered) i+=1;
    }
    return i;
}
- (UIImage *) currentRenderedImage;
{
    UIImage *img = nil;

    @autoreleasepool {
        
        DLog(@"current rendered image 1");
        
        id lastOutput = self.filters ? self.filters.lastOutput : nil;
        
        if(lastOutput)
        {
            if([lastOutput respondsToSelector:@selector(useNextFrameForImageCapture)])
            {
                [lastOutput performSelector:@selector(useNextFrameForImageCapture)];
            }
            img = [lastOutput performSelector:@selector(imageFromCurrentFramebuffer)];
            [self disable:MysticRenderOptionsSaveImageOutput];
            [self enable:MysticRenderOptionsForceProcess];
            [self setHasChanged:YES changeOptions:NO];
            
//            DLog(@"rebuild the buffer after rendering image: %@", MBOOL([self isEnabled:MysticRenderOptionsRebuildBuffer]));

            if([self isEnabled:MysticRenderOptionsRebuildBuffer])
            {
                
                [self disable:MysticRenderOptionsRebuildBuffer];
            }
            
        }
        
        if(!lastOutput || !img)
        {
            img = [UserPotion potion].sourceImageResized;
        }
        img = img ? [[self addOverlays:img] retain] : nil;
        
        
    }
    
    return img ? [MysticImageRender image:[img autorelease]] : nil;
    
}

+ (PackPotionOption *) makeOption:(MysticObjectType)newType userInfo:(NSDictionary *)info;
{
    PackPotionOption *option = nil;
    switch (newType) {
            
        case MysticObjectTypeSourceSetting:
        {
            option = (PackPotionOption *)[PackPotionOptionSourceSetting optionWithName:@"settings-source" info:nil];
            option.ignoreRender = NO;
            option.type = MysticObjectTypeSetting;
            [option setUserChoice];
            break;
        }
        default:
        {
            MysticObjectType _newType = MysticTypeForSetting(newType, nil);
            switch (_newType) {
                    
                case MysticObjectTypeSetting:
                {
                    option = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"settings" info:nil];
                    option.ignoreRender = NO;
                    option.type = MysticObjectTypeSetting;
                    [option setUserChoice];
                    break;
                }
                    
                default:
                {
                    break;
                }
            }
            
            
            break;
        }
    }
    
    return option;
}


#pragma mark - Description



- (NSString *) debugDescription;
{
    return [super description];
}
- (NSString *) description;
{
    return [MysticOptions description:self tag:nil];
}
- (NSString *) fullDescription;
{
    return [MysticOptions description:self.allOptions tag:(NSString *)self];
}
- (NSString *) changedDescription;
{
    return [MysticOptions description:self.optionsToRender tag:[self.tag stringByAppendingString:@" - only changed options"]];
}
+ (NSString *) description:(id)opts;
{
    return [MysticOptions description:opts tag:nil];
}
+ (NSString *) description:(id)opts tag:(NSString *)theTag;
{
    MysticOptions *_opts = (MysticOptions*)opts;
    BOOL fullDesc = YES;
    
    NSInteger maxChars = 130;
    if(theTag && [theTag isKindOfClass:[MysticOptions class]])
    {
        _opts = (MysticOptions*)theTag;
        theTag = _opts.tag;
        fullDesc = YES;
    }
    if(!_opts.count && ([opts isKindOfClass:[NSArray class]] || !_opts.totalCount)) return [NSString stringWithFormat:@"--- None ---"];
    BOOL isOptions = [_opts isKindOfClass:[MysticOptions class]];
    BOOL isManager = isOptions && [_opts isKindOfClass:[MysticOptionsManager class]];
    
    
    NSArray *os = [opts isKindOfClass:[NSArray class]] ? opts : [NSArray arrayWithArray:[_opts sortedRenderOptions]];
    
    NSString *__tag = [opts isKindOfClass:[NSArray class]] ? (theTag ? theTag : nil) : _opts.tag;
    NSMutableString *d = [NSMutableString stringWithFormat:@"\n\n\t%@%@  (%@) (render: %@) (changed: %@ opts: %@)  <%p>\n\t%@\n",
                          
                          isManager ? @"Manager" : @"Options",
                          __tag ? [NSString stringWithFormat:@"  #%@", __tag] : @"",
                          fullDesc ? [NSString stringWithFormat:@"%ld of %lu", (long)_opts.count, (unsigned long)os.count] : [NSString stringWithFormat:@"%lu", (unsigned long)os.count],
                          [_opts isKindOfClass:[NSArray class]] ? @"" : MBOOLStr(_opts.needsRender),
                          [_opts isKindOfClass:[NSArray class]] ? @"" : MBOOLStr(_opts.hasChangedValue),
                          [_opts isKindOfClass:[NSArray class]] ? @"" : MBOOLStr(_opts.hasChanged),
                          self,
                          [@"" stringByPaddingToLength:maxChars+19 withString:@"-" startingAtIndex:0]];
    
    int p = 0;
    int passIndex = 1;
    BOOL appendPass = YES;
    int maxLayersPerPass = isManager ? [(MysticOptionsManager *)_opts numberOfOptionsPerPass] : MYSTIC_PROCESS_LAYERS_PER_PASS;
    int _maxLayersPerPass = maxLayersPerPass;
    
    NSArray *_passes = isManager ? [(MysticOptionsManager *)_opts passes] : nil;
    
    if(isManager && _passes) {
        
        if(_passes.count > (passIndex-1))
        {
            
            NSArray *__pass = [_passes objectAtIndex:passIndex-1];
            maxLayersPerPass = __pass.count ? __pass.count : MYSTIC_PROCESS_LAYERS_PER_PASS;
        }
        
    }
    
    
    for (PackPotionOption *o in os) {
        p++;
        if(p > maxLayersPerPass)
        {
            p = 1;
            if(isManager) {
                passIndex++;
                appendPass = YES;
                if(_passes.count > passIndex-1)
                {
                    NSArray *__pass = [_passes objectAtIndex:passIndex-1];
                    maxLayersPerPass = __pass.count ? __pass.count : _maxLayersPerPass;
                }
            }
        }
        NSString *optionTag = [o.tag copy];
        NSString *oTag = [NSString stringWithFormat:@"%@:  %@ %@",
                          MObj(MyString(o.type)),
                          MObj(o.uniqueTag),
                          MObj(optionTag ? [optionTag substringToIndex:MIN(15, optionTag.length)] : @"--")];
        [optionTag autorelease];
        
        NSString *oStr = [NSString stringWithFormat:@"\n\t%@%@ %@ [%@] <0x%@>   %@",
                          [NSString stringWithFormat:@"%d.  ", p],
                          
                          
                          [[NSString stringWithFormat:@"%@ (%@%@) ",
                                [[NSString stringWithFormat:@"%d %@ ", (int)o.level,o.shouldRender ? @" RNDR " : @"      "] stringByPaddingToLength:7 withString:@" " startingAtIndex:0],
                            
                                AdjustmentStateToString(o.hasRendered ? MysticAdjustmentStateRendered : MysticAdjustmentStateUnrendered),
                            
                                o.hasUnRenderedAdjustments ? @"+" : @""] stringByPaddingToLength:14 withString:@" " startingAtIndex:0],
                          
                          
                          [oTag stringByPaddingToLength:30 withString:@" " startingAtIndex:0],
                          MObj(o.optionSlotKey ? [o.optionSlotKey componentsSeparatedByString:@"-"].lastObject : @"      "),

                          [[[NSString stringWithFormat:@"%p", o].md5 substringToIndex:5] uppercaseString],
                          
                          o.blending ? [NSString stringWithFormat:@"(%@%@) ", o.blending, o.blended ? @"*" : @""] : o.blended ? @" (---*) " : @""                     ];
        
        if(isManager && appendPass)
        {
            NSString *passStr = [NSString stringWithFormat:@"\n\n\tPass: %d\n\n", passIndex];
            [d appendString:passStr];
        }
        appendPass = NO;
        
        [d appendFormat:@"%@%@%@  ", [oStr stringByPaddingToLength:maxChars withString:@"." startingAtIndex:0],
         o.hasChanged ? @" ( CHANGE )" : [@"." repeat:11],
         o.isTransforming ? @" ( TRANS )" : [@"." repeat:10]];
        
    }
    [d appendString:@"\n"];
    
    return d;
    
    
}

@end
