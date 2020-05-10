//
//  MysticCore.m
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "NavigationViewController.h"
#import "SDImageCache.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "MysticAPI.h"
#import "EffectControl.h"
#import "MysticController.h"
#import "UIDevice+Machine.h"
#import "MysticEffectsManager.h"
#import "UserPotion.h"
#import "MysticData.h"
#import "MysticBackgroundsDataSource.h"

#ifdef BUILDNO

#define BUILDN BUILDNO

#else

#define BUILDN 0

#endif

@interface Mystic ()
{
    
}
@end

@implementation Mystic

@synthesize packs=_packs, options=_options, data=_data, filters, frames, colors, texts, textures, lights, masks, badges, settings, camLayerTools=_camLayerTools, layerSettings=_layerSettings, recipes=_recipes, fonts, fontFamilies;

//static Mystic *MysticCoreInstance;

static BOOL isInternetReachable = NO;
static BOOL hasAnsweredRiddle = NO;

static NSString *riddleAnswer = nil;

+ (Mystic *) core
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

+ (void) freeMemory;
{
    [MysticEffectsManager clearMemory];
//    [MysticCache clearMemory];
}
+ (void) resignFirstResponder;
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

}
+ (NSTimeInterval) timestamp;
{
    return [[NSDate date] timeIntervalSince1970];
}

+ (NSString *) version;
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *) buildNumber;
{
    return nil;
    
    //return [NSString stringWithFormat:@"%d", BUILDN];
}
+ (NSString *) randomHash;
{
    return [self randomHash:6];
}
+ (NSString *) randomHash:(int)charCount;
{
    NSString *pName = [NSString stringWithFormat:@"%d", (int)[NSDate timeIntervalSinceReferenceDate]];
    return [[pName md5] substringToIndex:charCount];
}
+ (NSArray *) mainObjectTypes;
{
    return @[
      @(MysticObjectTypeTexture),
      @(MysticObjectTypeFrame),
      @(MysticObjectTypeLight),
      @(MysticObjectTypeText),
      @(MysticObjectTypeBadge),
      ];
}

+ (NSString *) imageCapturePreset;
{
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType hasPrefix:@"iPod"])
    {
        return AVCaptureSessionPreset640x480;
    }
    return AVCaptureSessionPresetPhoto;
}

+ (CGRect) cropRectForImageCapture;
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 0.75f);
    
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType hasPrefix:@"iPhone"])
    {
        if([MysticUI isIPhone5])
        {
            CGSize ssize = [MysticUI screen];
            rect.size.height = ssize.width/ssize.height;
        }
    }
    FLog(deviceType, rect);
    return rect;
}


+ (NSArray *) effectsOfType:(MysticObjectType)objectType;
{
    NSMutableArray *effects = [NSMutableArray array];
    
    return effects;
}

+ (BOOL) option:(MysticControlObject *)option1 equals:(MysticControlObject *)option2;
{
    if((option1 == nil && option2.cancelsEffect) || (option2 == nil && option1.cancelsEffect)) return YES;
    
    if(option1 && option2 && option1.groupType==option2.groupType)
    {
        if([option1.tag isEqualToString:option2.tag])
        {
            return YES;
        }
    }
    return NO;
}

+ (PackPotionOption *) findOptionWithType:(MysticObjectType)optionType tag:(NSString *)tag;
{
    
    NSArray *options = [NSArray array];
    
    
    switch (optionType) {
        case MysticObjectTypeCamLayer:
            break;
        case MysticObjectTypeLight:
            options = [Mystic core].lights;
            break;
        case MysticObjectTypeText:
            options = [Mystic core].texts;
            break;
        case MysticObjectTypeTexture:
            options = [Mystic core].textures;
            break;
        case MysticObjectTypeFrame:
            options = [Mystic core].frames;
            
            break;
        case MysticObjectTypeMask:
            options = [Mystic core].masks;
            
            break;
        case MysticObjectTypeBadge:
            options = [Mystic core].badges;
            
            break;
        case MysticObjectTypeFilter:
            options = [Mystic core].filters;
            
            break;
            
            
        default: break;
    }
    
    for (PackPotionOption *opt in options) {
        if([opt.tag isEqualToString:tag]) return opt;
    }
    return nil;
}


+ (NSArray *) packTitles;
{
    
    NSMutableArray *arr = [NSMutableArray array];
    for (MysticPack *pack in [[Mystic core] packs]) {
        [arr addObject:pack.name];
    }
    return arr;
}
- (NSArray *) fontFamilies;
{
    NSMutableArray *__fonts = [NSMutableArray array];
    NSMutableArray *__families = [NSMutableArray array];
    BOOL verizon = NO;
    
    UIFont *font = [MysticFont defaultTypeFont:14];
    [__fonts addObject:[NSDictionary dictionaryWithObjectsAndKeys:font.fontName, @"title", font.fontName, @"fontName", font.familyName, @"familyName", nil]];
    
    font = [UIFont fontWithName:@"AmericanTypewriter" size:14];
    [__fonts addObject:[NSDictionary dictionaryWithObjectsAndKeys:font.fontName, @"title", font.fontName, @"fontName", font.familyName, @"familyName", nil]];
    
    font = [UIFont fontWithName:@"Cochin" size:14];
    [__fonts addObject:[NSDictionary dictionaryWithObjectsAndKeys:font.fontName, @"title", font.fontName, @"fontName", font.familyName, @"familyName", nil]];
    
    NSString *fontName;
    NSDictionary *fontInfo;
    
//    if ([[[UIDevice currentDevice] machine] rangeOfString:@"iPhone3,3"].location != NSNotFound) {
//        verizon = YES;
//    }
    
    int c = 0;
    for (NSString *fontFile in [[NSBundle mainBundle] pathsForResourcesOfType:@"ttf" inDirectory:@"Fonts"])
    {
        fontName = [[fontFile componentsSeparatedByString:@"/"] lastObject];
        fontName = [[fontName componentsSeparatedByString:@"."] objectAtIndex:0];
        UIFont *font = [UIFont fontWithName:fontName size:10];
        
        if(font.familyName)
        {
            NSString *familyName = font.familyName ? font.familyName : fontName;
            if(![__families containsObject:familyName])
            {
                fontInfo = [NSDictionary dictionaryWithObjectsAndKeys:fontName, @"title", fontName, @"fontName", fontFile, @"path", familyName, @"familyName", nil];
                
                [__families addObject:familyName];
                [__fonts addObject:fontInfo];
            }
        }
        else
        {
//            DLog(@"font.ttf BROKEN: %@ -> %@", fontName, font.fontName);

        }
        c++;
        
    }
    
    for (NSString *fontFile in [[NSBundle mainBundle] pathsForResourcesOfType:@"otf" inDirectory:@"Fonts"])
    {
        fontName = [[fontFile componentsSeparatedByString:@"/"] lastObject];
        fontName = [[fontName componentsSeparatedByString:@"."] objectAtIndex:0];
        UIFont *font = [UIFont fontWithName:fontName size:10];
        

        if(font.familyName)
        {
            
            if(![__families containsObject:font.familyName])
            {
                fontInfo = [NSDictionary dictionaryWithObjectsAndKeys:fontName, @"title", fontName, @"fontName", fontFile, @"path", font.familyName, @"familyName", nil];
                
                [__families addObject:font.familyName];
                [__fonts addObject:fontInfo];
            }
        }
        else
        {
//            DLog(@"font.otf BROKEN: %@ -> %@", fontName, font.fontName);
            
        }
        c++;
        
    }
    
    return [NSArray arrayWithArray:__fonts];
}

- (NSArray *) fonts;
{
    NSMutableArray *__fonts = [NSMutableArray array];
    PackPotionOptionFont *font;
    for (NSDictionary *family in self.fontFamilies) {
        
        font = (PackPotionOptionFont *)[PackPotionOptionFont optionWithName:[family objectForKey:@"fontName"] info:family];
        [__fonts addObject:font];
        
    }
    
    return [NSArray arrayWithArray:__fonts];
}

- (NSArray *) fontStyles;
{

    NSString *cachedPath = [[NSBundle mainBundle] pathForResource:@"fontStyles" ofType:@"plist"] ;
    
    NSDictionary *styleData = [[NSDictionary alloc] initWithContentsOfFile:cachedPath];
    NSMutableArray *__styles = [NSMutableArray array];
    PackPotionOptionFontStyle *style;
    for (NSDictionary *styleObject in [styleData objectForKey:@"styles"]) {
        
        style = (PackPotionOptionFontStyle *)[PackPotionOptionFontStyle optionWithName:[styleObject objectForKey:@"name"] info:styleObject];
        style.type = MysticObjectTypeFontStyle;
        [__styles addObject:style];
        
    }
    [styleData release];
    
    return [NSArray arrayWithArray:__styles];
}


- (NSArray *) quoteCategories;
{
    
    NSString *cachedPath = [[NSBundle mainBundle] pathForResource:@"Quotes" ofType:@"plist"] ;
    
    NSDictionary *data = [[[NSDictionary alloc] initWithContentsOfFile:cachedPath] autorelease];

    
    NSMutableArray *__data = [NSMutableArray array];
    PackPotionOptionFontStyle *style;
    NSArray *quotes = [data objectForKey:@"Quotes"];
    for (NSDictionary *quoteCategory in quotes) {
        
        [__data addObject:[quoteCategory objectForKey:@"title"]];
        
    }
    
    return [NSArray arrayWithArray:__data];
}

- (NSArray *) quotes;
{
    
    NSString *cachedPath = [[NSBundle mainBundle] pathForResource:@"Quotes" ofType:@"plist"] ;
    
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:cachedPath];
    NSMutableArray *__data = [NSMutableArray array];
    PackPotionOptionFontStyle *style;
    NSArray *quotes = [data objectForKey:@"Quotes"];
    for (NSDictionary *quoteCategory in quotes) {
        
        [__data addObjectsFromArray:[quoteCategory objectForKey:@"quotes"]];
        
    }
    [data release];
    
    return [NSArray arrayWithArray:__data];
}
- (NSArray *) quotesFromCategoryAtIndex:(NSInteger)categoryIndex;
{
    return [self quotesFromCategory:[[self quoteCategories] objectAtIndex:categoryIndex]];
}
- (NSArray *) quotesFromCategory:(NSString *)categoryTitle;
{
    
    NSString *cachedPath = [[NSBundle mainBundle] pathForResource:@"Quotes" ofType:@"plist"] ;
    
    NSDictionary *data = [[[NSDictionary alloc] initWithContentsOfFile:cachedPath] autorelease];
    NSArray *quotes = [data objectForKey:@"Quotes"];
    for (NSDictionary *quoteCategory in quotes) {
        
        if([[quoteCategory objectForKey:@"title"] isEqualToString:categoryTitle])
        {
            return [quoteCategory objectForKey:@"quotes"];
        }
        
    }
    
    
    
    return nil;
}


- (NSArray *) packs;
{
    
    
    
    
    return [Mystic optionsForType:MysticObjectTypePack];
}

- (NSArray *) texts;
{
    return [Mystic optionsForType:MysticObjectTypeText];
}

- (NSArray *) filters;
{
    return [Mystic optionsForType:MysticObjectTypeFilter];
}

- (NSArray *) colorFilters;
{
    NSArray *options = [Mystic optionsForType:MysticSettingColorFilter];
//    for (PackPotionOptionFilter *filter in options) {
//        filter.type = MysticSettingColorFilter;
//    }
    return options;
}

- (NSArray *) blendingModes;
{
    NSMutableArray *modes = [NSMutableArray array];
    NSArray *m = @[
//                        @{@"name": @"Auto", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendAuto]},
                        @{@"name": @"Screen", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendScreen]},
                        @{@"name": @"Multiply", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendMultiply]},
                        @{@"name": @"Lighten", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendLighten]},
                        @{@"name": @"Darken", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendDarken]},
                        @{@"name": @"Color", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendColor]},

                        @{@"name": @"Overlay", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendOverlay]},
                        @{@"name": @"Soft", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendSoftlight]},
                        @{@"name": @"Hard", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendHardlight]},
                        @{@"name": @"Burn", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendColorBurn]},
//                        @{@"name": @"Linear Burn", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendLinearBurn]},
                        @{@"name": @"Add", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendAdd]},
                        @{@"name": @"Subtract", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendSubtract]},
                        @{@"name": @"Divide", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendDivide]},
                        @{@"name": @"Reverse", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendDifference]},
//                        @{@"name": @"Color Dodge", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendColorDodge]},
//                        @{@"name": @"Saturation", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendSaturation]},
                        @{@"name": @"Luminous", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendLuminosity]},

                  ];
    for (NSDictionary *b in m) {
        [modes addObject:[PackPotionOptionBlend optionWithName:[b objectForKey:@"name"] info:b]];
    }
    
    return modes;
    
}

- (NSArray *) colorOverlays;
{
    return [self colorOverlays:nil dataBlock:nil];
}
- (NSArray *) colorOverlays:(MysticBlockObjBOOL)startBlock dataBlock:(MysticBlockData)finished;
{
    __unsafe_unretained __block MysticBlockData _f = finished ? Block_copy(finished) : nil;
    __unsafe_unretained __block MysticBackgroundsDataSource *dataSource = [[MysticBackgroundsDataSource alloc] init];
    NSArray *r =  [[dataSource autorelease] itemsWithKeys:@[@"items-gradients", @"items-colors"] dataBlock:^(NSArray *dataItems, MysticDataState dataState) {
        if(dataState & MysticDataStateNew)
        {
            NSMutableArray *_items = [NSMutableArray array];
            NSArray *items = [[dataItems lastObject] objectForKey:@"items"];
            if(items && items.count)
            {
                
                for (MysticAssetCollectionItem *item in items) {
                    PackPotionOptionColorOverlay *colorOverlay = [PackPotionOptionColorOverlay optionWithItem:item];
                    if(colorOverlay) [_items addObject:colorOverlay];
                    
                }
                
                if(_f)
                {
                    _f(_items, dataState);
                }
            }
        }
        if(dataState & MysticDataStateComplete)
        {
            DLog(@"color overlays complete");
            if(_f) Block_release(_f);
            [dataSource release];
        }
    }];
    
    NSMutableArray *_items = [NSMutableArray array];
    NSArray *items = [[r lastObject] objectForKey:@"items"];
    if(items && items.count)
    {
        
        for (MysticAssetCollectionItem *item in items) {
            PackPotionOptionColorOverlay *colorOverlay = [PackPotionOptionColorOverlay optionWithItem:item];
            if(colorOverlay) [_items addObject:colorOverlay];
            
        }
//        if(_f) _f(_items, MysticDataStateComplete);
    }
    
    
    if(_f) Block_release(_f);
    return _items;
}

+ (void) specialOptions:(MysticBlockData)finished;
{
    [[Mystic core] specialOptions:finished];
}
- (void) specialOptions:(MysticBlockData)finished;
{
    __unsafe_unretained __block MysticBlockData _f = finished ? Block_copy(finished) : nil;
    
    NSDictionary *data = [MysticShaderData data];
    
    
    
    
    [MysticShaderData items:^(NSArray *dataItems, MysticDataState dataState) {
        if(dataState & MysticDataStateNew)
        {
            
            if(_f)
            {
                _f(dataItems, dataState);
            }
            
        }
        if(dataState & MysticDataStateComplete)
        {
            if(_f) Block_release(_f);
        }
    }];
}

- (NSArray *) frames;
{
    return [Mystic optionsForType:MysticObjectTypeFrame];
}

- (NSArray *) masks;
{
    return [Mystic optionsForType:MysticObjectTypeMask];
}

- (NSArray *) lights;
{
    return [Mystic optionsForType:MysticObjectTypeLight];
}

- (NSArray *) textures;
{
    return [Mystic optionsForType:MysticObjectTypeTexture];
}

- (NSArray *) mixtures;
{
    NSMutableArray *m = [NSMutableArray arrayWithArray:self.textures];
    [m addObjectsFromArray:self.lights];
    return m;
}

- (NSArray *) camLayerTools
{
    NSMutableArray *_settings = [NSMutableArray array];
    PackPotionOption *setting;
    
    setting = (PackPotionOption *)[PackPotionOptionCamLayer optionWithName:@"cancel" info:nil];
    setting.cancelsEffect = YES;
    setting.type = MysticObjectTypeCamLayer;
    [_settings addObject:setting];
    
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"cleanup" info:nil];
    setting.type = MysticSettingCamLayerSetup;
    //    setting.controlImageName = @"thumb140_controlImage_exposure";
    [_settings addObject:setting];
    
//    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"sharpness" info:nil];
    setting.type = MysticSettingSharpness;
    //    setting.controlImageName = @"thumb140_controlImage_sharpness";
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"exposure" info:nil];
    setting.type = MysticSettingExposure;
    //    setting.controlImageName = @"thumb140_controlImage_exposure";
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"contrast" info:nil];
    setting.type = MysticSettingContrast;
    //    setting.controlImageName = @"thumb140_controlImage_contrast";
    [_settings addObject:setting];
    
    
    
    
//    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Unsharp Mask" info:nil];
    setting.type = MysticSettingUnsharpMask;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"blending mode" info:nil];
    setting.type = MysticSettingBlending;
    
    //    setting.controlImageName = @"thumb140_controlImage_brightness";
    [_settings addObject:setting];
    
    
    
    
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"gamma" info:nil];
    setting.type = MysticSettingGamma;
    //    setting.controlImageName = @"thumb140_controlImage_gamma";
    [_settings addObject:setting];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Color" info:nil];
    //    setting.controlImageName = @"thumb140_controlImage_color";
    setting.type = MysticSettingSaturation;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"inner shadow" info:nil];
    setting.type = MysticSettingVignette;
    //    setting.controlImageName = @"thumb140_controlImage_inner-shadow";
    [_settings addObject:setting];
    
//    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"focus blur" info:nil];
//    setting.type = MysticSettingTiltShift;
//    //    setting.controlImageName = @"thumb140_controlImage_focus";
//    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Tone" info:nil];
    //    setting.controlImageName = @"thumb140_controlImage_tone";
    setting.type = MysticSettingTemperature;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"brightness" info:nil];
    setting.type = MysticSettingBrightness;
    //    setting.controlImageName = @"thumb140_controlImage_brightness";
    [_settings addObject:setting];
    
    
//    
//    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"shadows" info:nil];
//    setting.type = MysticSettingShadows;
//    //    setting.controlImageName = @"thumb140_controlImage_shadows";
//    [_settings addObject:setting];
    
//    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"highlights" info:nil];
//    setting.type = MysticSettingHighlights;
//    //    setting.controlImageName = @"thumb140_controlImage_highlights";
//    [_settings addObject:setting];
    
//    
//    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"reset" info:nil];
//    setting.type = MysticSettingReset;
//    //    setting.controlImageName = @"thumb140_controlImage_reset";
//    [_settings addObject:setting];
    
    return _settings;
}

- (NSArray *) badges;
{
    return [MysticData shapes];
    return [Mystic optionsForType:MysticObjectTypeBadge];
}

- (NSArray *) settings;
{
    return [self settingsWithFilter:NO];
}

- (NSArray *) settingsForOption:(PackPotionOption *)targetOption;
{
    NSMutableArray *_settings = [NSMutableArray array];
    PackPotionOption *setting;
    
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Tone" info:nil];
    setting.type = MysticSettingTemperature;
    setting.targetOption = targetOption;
    [_settings addObject:setting];
    
    
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Saturation" info:nil];
    setting.type = MysticSettingHSBSaturation;
    setting.targetOption = targetOption;

    [_settings addObject:setting];
    
    
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"brightness" info:nil];
    setting.type = MysticSettingHSBBrightness;
    setting.targetOption = targetOption;

    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"contrast" info:nil];
    setting.type = MysticSettingContrast;
    setting.targetOption = targetOption;

    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"gamma" info:nil];
    setting.type = MysticSettingGamma;
    setting.targetOption = targetOption;

    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"exposure" info:nil];
    setting.type = MysticSettingExposure;
    setting.targetOption = targetOption;

    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"levels" info:nil];
    setting.type = MysticSettingLevels;
    setting.targetOption = targetOption;

    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Color Balance" info:nil];
    setting.type = MysticSettingColorBalance;
    setting.targetOption = targetOption;

    [_settings addObject:setting];
    
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Hue" info:nil];
    setting.type = MysticSettingHSBHue;
    setting.targetOption = targetOption;
    
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"shadows" info:nil];
    setting.type = MysticSettingShadows;
    setting.targetOption = targetOption;

    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"highlights" info:nil];
    setting.type = MysticSettingHighlights;
    setting.targetOption = targetOption;

    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"haze" info:nil];
    setting.type = MysticSettingHaze;
    setting.targetOption = targetOption;

    [_settings addObject:setting];
    
    
    // pre filter effects
    /*
     setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Vignette" info:nil];
     setting.type = MysticSettingVignette;
     setting.targetOption = targetOption;

     [_settings addObject:setting];
     
     setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"focus" info:nil];
     setting.type = MysticSettingTiltShift;
     setting.targetOption = targetOption;

     [_settings addObject:setting];
     
     setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"sharpness" info:nil];
     setting.type = MysticSettingSharpness;
     setting.targetOption = targetOption;

     [_settings addObject:setting];
     
     
     setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Unsharp Mask" info:nil];
     setting.type = MysticSettingUnsharpMask;
     setting.targetOption = targetOption;

     [_settings addObject:setting];
     */
    
    //    Reset Setting
    //    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"reset" info:nil];
    //    setting.targetOption = targetOption;
    //    setting.type = MysticSettingReset;
    //    [_settings addObject:setting];
    
    return _settings;
}


- (NSArray *) settingsWithFilter:(BOOL)withFilter;
{
    NSMutableArray *_settings = [NSMutableArray array];
    PackPotionOption *setting;
    
    if(withFilter)
    {
        setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Color Filter" info:nil];
        setting.type = MysticSettingChooseColorFilter;
        [_settings addObject:setting];
    }
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Tone" info:nil];
    setting.type = MysticSettingTemperature;
    [_settings addObject:setting];
    
    
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Saturation" info:nil];
//    setting.type = MysticSettingSaturation;
    setting.type = MysticSettingHSBSaturation;

    [_settings addObject:setting];
    
    
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"brightness" info:nil];
//    setting.type = MysticSettingBrightness;
    setting.type = MysticSettingHSBBrightness;

    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"contrast" info:nil];
    setting.type = MysticSettingContrast;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"gamma" info:nil];
    setting.type = MysticSettingGamma;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"exposure" info:nil];
    setting.type = MysticSettingExposure;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"levels" info:nil];
    setting.type = MysticSettingLevels;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Color Balance" info:nil];
    setting.type = MysticSettingColorBalance;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Hue" info:nil];
    setting.type = MysticSettingHSBHue;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"shadows" info:nil];
    setting.type = MysticSettingShadows;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"highlights" info:nil];
    setting.type = MysticSettingHighlights;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"haze" info:nil];
    setting.type = MysticSettingHaze;
    [_settings addObject:setting];
    
    
    // pre filter effects
    /*
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Vignette" info:nil];
    setting.type = MysticSettingVignette;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"focus" info:nil];
    setting.type = MysticSettingTiltShift;
    [_settings addObject:setting];
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"sharpness" info:nil];
    setting.type = MysticSettingSharpness;
    [_settings addObject:setting];
    
    
    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"Unsharp Mask" info:nil];
    setting.type = MysticSettingUnsharpMask;
    [_settings addObject:setting];
    */
    
//    Reset Setting
//    setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"reset" info:nil];
//    setting.type = MysticSettingReset;
//    [_settings addObject:setting];
    
    return _settings;
}

+ (void) potions:(MysticBlockData)finished;
{
    
    [self recipesWithType:MysticRecipesTypeAll finished:finished];

}
+ (void) potionsWithType:(MysticRecipesType)type finished:(MysticBlockData)finished;
{
    [self recipesWithType:type finished:finished];
}
+ (void) recipes:(MysticBlockData)finished;
{
    [self recipesWithType:MysticRecipesTypeAll finished:finished];
}
+ (void) recipesWithType:(MysticRecipesType)type finished:(MysticBlockData)finished;
{
    NSString *uri = @"/potions";
    switch (type) {
        case MysticRecipesTypeAll:
            uri = @"/potions";
            break;
        case MysticRecipesTypeFeatured:
            uri = @"/potions/featured";
            break;
        case MysticRecipesTypeCommunity:
            uri = @"/potions/community";
            break;
        case MysticRecipesTypeProject:
            uri = @"/potions/project";
            break;

        case MysticRecipesTypeSaved:
            uri = nil;
            break;
            
        default: break;
    }
    if(uri)
    {
        

        __unsafe_unretained __block MysticBlockData _finished = finished ? Block_copy(finished) : nil;
        [MysticDictionaryDownloader dictionaryWithURL:[MysticAPI url:uri] orDictionary:nil state:^(NSDictionary *results, MysticDataState dataState) {
            
        
            BOOL success = !(dataState & MysticDataStateError);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                NSMutableArray *__recipes = [NSMutableArray array];
                
                
                if(dataState & MysticDataStateNew)
                {
                    NSArray *resultItems = [MysticDictionaryDataSource itemsForType:MysticObjectTypePotion info:[results objectForKey:@"items"] keyOrder:[results objectForKey:@"order"]];
                    
                    
                    for (PackPotionOptionRecipe *recipe in resultItems) {
                        
                        recipe.recipeType = type;
                        if(!recipe.thumbURLString || [recipe.thumbURLString isKindOfClass:[NSNull class]])
                        {
                            
                            continue;
                        }
                        
                        [__recipes addObject:recipe];
                    }
                }
                if(_finished)
                {
                    _finished(__recipes, dataState);
                    if(dataState & MysticDataStateComplete)
                    {
                        
                        Block_release(_finished);
                        
                    }
                }
            });
            
            
        }];

       
    }
    else
    {

        NSMutableArray *__recipes = [NSMutableArray arrayWithArray:[MysticUser user].potions];
        
        if(finished) finished(__recipes, MysticDataStateInit|MysticDataStateFinish|MysticDataStateNew);
    }
}
- (NSArray *) potions;
{
    return self.recipes;
}
- (NSArray *) recipes;
{
    NSMutableArray *__recipes = [NSMutableArray array];
//    PackPotionOption *recipe;
//    
//    recipe = (PackPotionOptionRecipe *)[PackPotionOptionRecipe optionWithName:@"New" info:nil];
//    recipe.type = MysticSettingRecipe;
//    recipe.action = ^(EffectControl *control, BOOL isSelected){
//        [PackPotionOptionRecipe create];
//    };
//    
//    [__recipes addObject:recipe];
    
    
        
    return __recipes;
}

+ (id) sharedLibrary;
{
    return [MysticLibrary sharedLibrary];
 
    
    
}
+ (NSArray *) topicsForType:(MysticObjectType)objType;
{
    NSInteger maxFeatured = (NSInteger)MYSTIC_FEATURED_MAX;
    switch (objType) {
        case MysticObjectTypeColorOverlay:
            maxFeatured = NSNotFound;
            break;
            
        default: break;
    }
    return [self topicsForType:objType includeFeatured:maxFeatured];
}
+ (NSArray *) topicsForType:(MysticObjectType)objType includeFeatured:(NSInteger)includeFeaturedCount;
{
    
    
    NSMutableArray *arr = [NSMutableArray array];
    NSString *groupKey = MysticObjectTypeKey(objType);
    
    NSDictionary *groupDict = [MysticOptionsDataSource objectAtKeyPath:[@"group-packs." stringByAppendingString:groupKey] filter:nil];
    
    if(groupDict)
    {
        
        NSDictionary *packsDict = [MysticOptionsDataSource objectAtKeyPath:@"packs" filter:nil];
        for (NSString *packTag in [groupDict objectForKey:@"packs"]) {
            NSDictionary *packInfo = [packsDict objectForKey:packTag];
            MysticPack *pack = [MysticOptionsDataSource itemForType:MysticObjectTypePack info:packInfo itemKey:packTag class:[MysticPack class]];
            if(!pack) continue;
            [arr addObject:pack];
            
        }
        
        if(includeFeaturedCount > 0 || includeFeaturedCount == NSNotFound)
        {
            NSString *featuredTitle = arr.count ? [MysticSettings settingForKey:[NSString stringWithFormat:@"%@_featured_title", MysticObjectTypeKey(objType)] default:@"Featured"] : MysticObjectTypeTitleParent(objType, objType);
            NSDictionary *featuredInfo = @{@"layers_featured": [groupDict objectForKey:@"featured"] ? [groupDict objectForKey:@"featured"] : [groupDict objectForKey:@"featured_layers"],
                                           @"layers_count_featured": [groupDict objectForKey:@"featured_count"],
                                           @"name": featuredTitle};
            MysticPack *p = [MysticPack packWithName:featuredTitle info:featuredInfo];
            p.featuredPack = YES;
            p.groupType = objType;
            if(includeFeaturedCount != NSNotFound) p.maxNumberOfPotions = includeFeaturedCount;
            [arr insertObject:p atIndex:0];
        }
    
    }
    else
    {
        NSString *packTitle = MysticObjectTypeTitleParent(objType, objType);
        id lopts = [self optionsForType:objType];
        NSDictionary *packInfo = @{@"layer_options": lopts ? lopts : [NSNull null],
                                       
                                   @"name": packTitle ? packTitle : @""};
        MysticPack *p = [MysticPack packWithName:packTitle info:packInfo];
        p.featuredPack = NO;
        p.groupType = objType;
        [arr insertObject:p atIndex:0];
    }
    
    
    
    
    
    
    
    return arr;
    
}

- (NSArray *) layerSettings;
{
    
    NSMutableArray *_settings = [NSMutableArray array];
    PackPotionOption *setting = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"blending mode" info:nil];
    setting.type = MysticSettingBlending;
    [_settings addObject:setting];
    [_settings addObjectsFromArray:self.settings];

    
    return _settings;
}

- (NSArray *) colors;
{
    return [self colorsForObject:MysticObjectTypeUnknown option:MysticOptionColorTypeForeground setting:MysticSettingUnknown];
}
- (NSArray *) colorsForObject:(MysticObjectType)objectType option:(MysticOptionColorType)optionType;
{
    return [self colorsForObject:objectType option:optionType setting:MysticSettingUnknown];
}
- (NSArray *) colorsForObject:(MysticObjectType)objectType option:(MysticOptionColorType)optionType setting:(MysticObjectType)setting;
{
    NSMutableArray *_colors = [NSMutableArray array];
    
    PackPotionOptionColor *color;

    
    NSInteger x = MysticColorTypeChoice1;
    for(x=MysticColorTypeChoice1;x<MysticColorTypeLast;x++)
    {
        color = (PackPotionOptionColor *)[PackPotionOptionColor optionWithName:@"color" info:nil];
        color.colorType = x;
        color.objectType = objectType;
        color.optionType = optionType;
        color.setting = setting;

        [_colors addObject:color];
        
    }
    
    
    return _colors;
    
}
- (NSArray *) colorsForOption:(PackPotionOption *)option option:(MysticOptionColorType)optionType;
{
    return [self colorsForOption:option option:optionType setting:option.setting];
}
- (NSArray *) colorsForOption:(PackPotionOption *)option option:(MysticOptionColorType)optionType setting:(MysticObjectType)setting;
{
    NSMutableArray *_colors = [NSMutableArray array];
    PackPotionOptionColor *color=nil, *firstColor=nil;
    if(option && option.canChooseCancelColor)
    {
        color = (PackPotionOptionColor *)[PackPotionOptionColor optionWithName:@"color" info:nil];
        color.colorType = MysticColorTypeAuto;
        color.objectType = option.type;
        color.optionType = optionType;
        color.targetOption = option;
        color.setting = setting;
        firstColor = color;
        [_colors addObject:color];
    }
    
    NSInteger x = MysticColorTypeChoice1;
    for(x=MysticColorTypeChoice1;x<MysticColorTypeLast;x++)
    {
        color = (PackPotionOptionColor *)[PackPotionOptionColor optionWithName:@"color" info:nil];
        color.colorType = x;
        color.objectType = option.type;
        color.optionType = optionType;
        color.targetOption = option;
        color.setting = setting;
        if(firstColor && [color.color isEqualToColor:firstColor.color]) continue;
        [_colors addObject:color];
    }
    
    
    return _colors;
    
}

- (NSArray *) dataForKey:(NSString *)key
{
    NSDictionary *mainData = self.data;
    NSMutableArray *returnPacksArray = [NSMutableArray array];
    NSDictionary *keyData = [mainData objectForKey:key];
    NSArray *keyOrder = [[mainData objectForKey:@"orders"] objectForKey:key];
    if(keyOrder)
    {
        for (NSString *packName in keyOrder) {
            [returnPacksArray addObject:[MysticPack packWithName:packName info:[keyData objectForKey:packName]]];
        }
    }
    else
    {
        [returnPacksArray addObjectsFromArray:[keyData allValues]];
    }
    return [[returnPacksArray retain] autorelease];
}

+ (PackPotionOption *) randomOptionOfType:(MysticObjectType)optionType
{
    NSArray *options = [Mystic optionsForType:optionType];
    if([options count])
    {
        NSUInteger randomIndex = arc4random() % [options count];
        return [options objectAtIndex:randomIndex];
        
    }
    return nil;
}
+ (NSArray *) options:(MysticObjectType)optionType;
{
    switch (optionType) {
        case MysticObjectTypeShape:
            return [MysticData shapes];
            
        default: break;
    }
    NSDictionary *mainData = [Mystic core].data;
    return [Mystic optionsForType:optionType info:mainData];
    
}
+ (NSArray *) optionsForType:(MysticObjectType)optionType;
{
    return [self options:optionType];
    
}

+ (NSArray *) optionsForType:(MysticObjectType)optionType info:(NSDictionary *)mainData;
{
    switch (optionType)
    {
        case MysticObjectTypeColorOverlay:
        {
            return [Mystic core].colorOverlays;
        }
        case MysticObjectTypeMixture:
        {
            NSMutableArray *mixtures = [NSMutableArray array];
            [mixtures addObjectsFromArray:[Mystic optionsForType:MysticObjectTypeTexture info:mainData]];
            [mixtures addObjectsFromArray:[Mystic optionsForType:MysticObjectTypeLight info:mainData]];
            return mixtures;
        }
            
        default: break;
    }
    
    NSArray *keyOrder = nil;
    Class optionClass = [PackPotionOption class];
    NSDictionary *optionsDict = nil;
    NSMutableArray *newOptions = [NSMutableArray array];
    switch (optionType) {
        case MysticObjectTypeLight:
            optionClass = [PackPotionOptionLight class];
            optionsDict = [mainData objectForKey:@"lights"];
            keyOrder = [[mainData objectForKey:@"orders"] objectForKey:@"lights"];
            break;
        case MysticObjectTypeText:
            optionClass = [PackPotionOptionText class];
            optionsDict = [mainData objectForKey:@"text"];
            keyOrder = [[mainData objectForKey:@"orders"] objectForKey:@"text"];
            break;
        case MysticObjectTypeTexture:
            optionClass = [PackPotionOptionTexture class];
            optionsDict = [mainData objectForKey:@"textures"];
            keyOrder = [[mainData objectForKey:@"orders"] objectForKey:@"textures"];
            break;
        case MysticObjectTypeFrame:
            optionClass = [PackPotionOptionFrame class];
            optionsDict = [mainData objectForKey:@"frames"];
            keyOrder = [[mainData objectForKey:@"orders"] objectForKey:@"frames"];
            break;
        case MysticObjectTypeMask:
            optionClass = [PackPotionOptionMask class];
            optionsDict = [mainData objectForKey:@"masks"];
            keyOrder = [[mainData objectForKey:@"orders"] objectForKey:@"masks"];
            break;
        case MysticObjectTypeBadge:
            optionClass = [PackPotionOptionBadge class];
            optionsDict = [mainData objectForKey:@"badges"];
            keyOrder = [[mainData objectForKey:@"orders"] objectForKey:@"badges"];
            break;
        case MysticSettingColorFilter:
        case MysticObjectTypeFilter:
            optionClass = [PackPotionOptionFilter class];
            optionsDict = [mainData objectForKey:@"filters"];
            keyOrder = [[mainData objectForKey:@"orders"] objectForKey:@"filters"];
            break;
        case MysticObjectTypeTextColor:
        case MysticObjectTypeColor:
            optionClass = [PackPotionOptionColor class];
            optionsDict = [mainData objectForKey:@"colors"];
            keyOrder = [[mainData objectForKey:@"orders"] objectForKey:@"colors"];
            break;
        case MysticObjectTypeBadgeColor:
            optionClass = [PackPotionOptionColor class];
            optionsDict = [mainData objectForKey:@"colors"];
            keyOrder = [[mainData objectForKey:@"orders"] objectForKey:@"colors"];
            break;
        case MysticObjectTypeFrameBackgroundColor:
            optionClass = [PackPotionOptionColor class];
            optionsDict = [mainData objectForKey:@"colors"];
            keyOrder = [[mainData objectForKey:@"orders"] objectForKey:@"colors"];
            break;
        case MysticObjectTypeTextPack:
        case MysticObjectTypePack:
            optionClass = [MysticPack class];
            optionsDict = [mainData objectForKey:@"packs"];
            keyOrder = [[mainData objectForKey:@"orders"] objectForKey:@"packs"];
            break;
            
        default: break;
    }
    
    keyOrder = keyOrder ? keyOrder : [optionsDict allKeys];
    for (NSString *optionKey in keyOrder) {
        if(![optionsDict objectForKey:optionKey]) continue;
        BOOL isCancel = [[[optionsDict objectForKey:optionKey] objectForKey:@"cancel"] boolValue];
        if(isCancel) continue;
        PackPotionOption *newObj = [optionClass optionWithName:optionKey info:[optionsDict objectForKey:optionKey]];
        newObj.position = newOptions.count;
        [newOptions addObject:newObj];
    }
    return newOptions;
}

- (NSArray *) options;
{
    
    
    
    NSDictionary *mainData = [self.data retain];
    NSArray *order = [@"text,frames,textures,filters,lights,masks,badges,colors" componentsSeparatedByString:@","];
    NSMutableArray *returnPacksArray = [NSMutableArray array];
    NSMutableSet *optionsSet = [NSMutableSet set];
    NSDictionary *__packs = [[NSDictionary alloc] initWithDictionary:[mainData objectForKey:@"orders"]];
    for (NSString *packName in [__packs allKeys]) {
        [optionsSet addObject:[PackPotionOption optionWithName:packName info:[__packs objectForKey:packName]]];
    }
    for (NSString *optName in order) {
        for (PackPotionOption *opt in optionsSet) {
            if([opt.name isEqualToString:optName])
            {
                [returnPacksArray addObject:opt];
                break;
            }
        }
    }
    [__packs release];
    [mainData release];
    return returnPacksArray;
}




+ (BOOL) hasUserSeenTipWithName:(MysticTipName)tipName;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *tips = [defaults objectForKey:@"tips"];
    if(tips)
    {
        NSString *tip = [NSString stringWithFormat:@"tipName-%d", tipName];
        for (NSString *aTip in tips) {
            if([aTip isEqualToString:tip]) return YES;
        }
    }
    return NO;
}
+ (void) rememberUserSeenTipWithName:(MysticTipName)tipName;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tips = [defaults objectForKey:@"tips"] ? [NSMutableArray arrayWithArray:[defaults objectForKey:@"tips"]] : [NSMutableArray array];
    
    [tips addObject:[NSString stringWithFormat:@"tipName-%d", tipName]];
    [defaults setObject:[NSArray arrayWithArray:tips] forKey:@"tips"];
    
    [defaults synchronize];
}

+ (void) forgetUserSeenTipWithName:(MysticTipName)tipName;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tips = [defaults objectForKey:@"tips"] ? [NSMutableArray arrayWithArray:[defaults objectForKey:@"tips"]] : [NSMutableArray array];
    if(tips)
    {
        NSString *tip = [NSString stringWithFormat:@"tipName-%d", tipName];
        id removeTip = nil;
        for (NSString *aTip in tips) {
            if([aTip isEqualToString:tip]) {removeTip = aTip; break; }
        }
        if(removeTip) [tips removeObject:removeTip];
    }
//    if([tips containsObject:[NSString stringWithFormat:@"tipName-%d", tipName]]) [tips removeObject:[NSString stringWithFormat:@"tipName-%d", tipName]];
    [defaults setObject:[NSArray arrayWithArray:tips] forKey:@"tips"];
    
    [defaults synchronize];
}
+ (void) resetUserTips;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"mystic.pastMessages"];
    [defaults removeObjectForKey:@"tips"];
    
    [defaults synchronize];
}

+ (void) showTip:(MysticTipName)tipName;
{
    [Mystic showTip:tipName title:nil message:nil button:nil complete:nil];
}
+ (void) showTip:(MysticTipName)tipName title:(NSString *)title message:(NSString *)message button:(NSString *)buttonTitle complete:(MysticBlock)buttonBlock;
{
    

    if( ![Mystic hasUserSeenTipWithName:tipName])
    {
        title = title ? title :@"Tip";
        buttonTitle = buttonTitle ? buttonTitle :@"OK";
        
        switch (tipName) {
            case MysticTipNameBlendingNoFilter:
                message = message ? message : @"Blending works best if you also add a filter effect to your image.";
                break;
                
            default: break;
        }
        
        [MysticAlert notice:title message:message action:^(id object, id o2) {
            if(buttonBlock) buttonBlock();
        } options:@{@"button": buttonTitle}];
        
        [Mystic rememberUserSeenTipWithName:MysticTipNameBlendingNoFilter];
    }
}
+ (BOOL) hasInternetConnection;
{
    return isInternetReachable;
}

+ (BOOL) isRiddleAnswer:(NSString *)answer;
{
    // disable this line for live
#ifdef MYSTIC_ADMIN_MODE
    
    if([answer isEqualToString:MysticChiefPassword]) return YES;

#endif
    
    return riddleAnswer ? [[answer lowercaseString] isEqualToString:[riddleAnswer lowercaseString]] : NO;
}

+ (BOOL) hasAnsweredRiddle;
{
    return hasAnsweredRiddle;
}
+ (void) setAnsweredRiddle:(BOOL)answered;
{
    hasAnsweredRiddle = answered;
}

+ (NSString *) setRiddleAnswer:(NSString *)answered finished:(MysticBlockObjBOOL)finishedAnswer;
{
    NSString *unlockStr = nil;
    if(riddleAnswer) [riddleAnswer release], riddleAnswer=nil;
    riddleAnswer = [[answered lowercaseString] retain];
    
    if([riddleAnswer isEqualToString:@"testlayers"])
    {
        unlockStr = @"You can now test the layers!";
        if(finishedAnswer) finishedAnswer(unlockStr, YES);
    }
    else if([riddleAnswer isEqualToString:MysticChiefPassword])
    {
        unlockStr = @"Mystic Cheif Mode Unlocked!";
        [MysticUser user].type = MysticUserTypeChief;
        
        [[SDImageCache sharedImageCache] clearDisk];
        [[SDImageCache sharedImageCache] clearMemory];
        [[MysticController controller] setState:MysticSettingNone animated:NO complete:^{
            if(finishedAnswer) finishedAnswer(unlockStr, YES);
        }];
        
    }
    else if([riddleAnswer isEqualToString:@"fontz"])
    {
        unlockStr = @"Font Mode Unlocked!";
        [[MysticController controller] setState:MysticSettingNone animated:NO complete:^{
            if(finishedAnswer) finishedAnswer(unlockStr, YES);
        }];
        
    }
    else if([riddleAnswer isEqualToString:@"clean"])
    {
        unlockStr = @"All Cleaned Up!";
        [MysticCache cleanAll];
        [[MysticController controller] dismissViewControllerAnimated:YES completion:^{
            [[MysticController controller] setState:MysticSettingNone animated:NO complete:^{
                if(finishedAnswer) finishedAnswer(unlockStr, YES);
            }];
        }];
        
        
    }
    else if([riddleAnswer isEqualToString:@"mem"])
    {
        [MysticCache clearMemory];
        unlockStr = @"Memory = Gone!";
        [[MysticController controller] dismissViewControllerAnimated:YES completion:^{
            [[MysticController controller] setState:MysticSettingNone animated:NO complete:^{
                if(finishedAnswer) finishedAnswer(unlockStr, YES);
            }];
        }];
        
        
    }
    else if([riddleAnswer isEqualToString:@"clear"])
    {
        [MysticCache clearAll];
        unlockStr = @"Free & Clear!";
        [[MysticController controller] dismissViewControllerAnimated:YES completion:^{
            [[MysticController controller] setState:MysticSettingNone animated:NO complete:^{
                if(finishedAnswer) finishedAnswer(unlockStr, YES);
            }];
        }];
        
        
    }
    else if([riddleAnswer isEqualToString:@"sync"])
    {
        unlockStr = @"Syncing...";

        [MysticCache clearAllSafely];
        [[Mystic core] updateConfigUsingForce:YES start:^(BOOL startingDownload) {
            
            if(finishedAnswer) finishedAnswer(startingDownload ? @"Downloading updates..." : @"No need to sync!", YES);

            
            
            
        } complete:^(BOOL success) {
            
            
            if(finishedAnswer) finishedAnswer(success ? @"Sync Complete!" : @"Sync failed", success);

            
            
            
            
        }];
        
        
    }
    else if([riddleAnswer isEqualToString:@"potion"])
    {
        unlockStr = @"Sharing your potion...";
        [UserPotion saveAndUploadProject:^(NSString *projectFilePath, BOOL uploaded) {
            
            
            if(finishedAnswer) finishedAnswer(@"Potion shared", uploaded);
        }];
    }
    else if([riddleAnswer isEqualToString:@"lettherebelight"])
    {
        unlockStr = @"Loading Mystic Light Mode...";
        [MysticUser user].appVersion = MysticVersionLight;
        [NSTimer wait:1.2 block:^{
            __unsafe_unretained __block AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

            [appDelegate.visibleController dismissViewControllerAnimated:YES completion:^{
                [appDelegate setupNewProject:NO];
                if(finishedAnswer) finishedAnswer(unlockStr, YES);
            }];
        }];
    }
    else if([riddleAnswer isEqualToString:@"jerusalem"])
    {
        unlockStr = @"Loading Mystic Cosmos Mode...";
        [MysticUser user].appVersion = MysticVersionCosmos;
        [NSTimer wait:1.2 block:^{
            __unsafe_unretained __block AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            [appDelegate.visibleController dismissViewControllerAnimated:YES completion:^{
                [appDelegate setupNewProject:NO];
                if(finishedAnswer) finishedAnswer(unlockStr, YES);
            }];
        }];
        
    }
    else
    {
        if(finishedAnswer) finishedAnswer(unlockStr, NO);
    }
    RiddleLog(@"Riddle Answer: %@ -> unlock: %@", riddleAnswer, unlockStr ? unlockStr : @" ---");
    
    return unlockStr;
}

+ (BOOL) trackDiagnostics;
{
    return [[[Mystic core].data objectForKey:@"diagnostics"] boolValue];
}

+ (BOOL) storeEnabled;
{
    return [[[Mystic core].data objectForKey:@"store"] boolValue] && kEnableStore;
}

+ (BOOL) useNativeShare;
{
    return [[[Mystic core].data objectForKey:@"nativeShare"] boolValue] && kEnableNativeShare;
}

+ (BOOL) useWriteOnCam;
{
    return [[[Mystic core].data objectForKey:@"writeOnCam"] boolValue] && kEnableWriteMeCam;
}

+ (NSString *) riddleQuestion;
{
    return [[Mystic core].data objectForKey:@"riddleQuestion"];
}
+ (NSString *) riddleAnswer;
{
    return [[Mystic core].data objectForKey:@"riddleAnswer"];
}
+ (NSString *) riddleTitle;
{
    return [[Mystic core].data objectForKey:@"riddleTitle"];
}

+ (NSString *) messageText;
{
    return [[Mystic core].data objectForKey:@"message"];
}
+ (NSString *) messageTitle;
{
    NSString *cancelTitle = [[Mystic core].data objectForKey:@"message_title"];
    if(cancelTitle && [cancelTitle isEqualToString:@""]) return nil;
    return cancelTitle;
    
}
+ (NSString *) messageKey;
{
    return [[Mystic core].data objectForKey:@"message_key"];
}
+ (NSString *) messageUrl;
{
    NSString *cancelTitle = [[Mystic core].data objectForKey:@"message_url"];
    if(cancelTitle && [cancelTitle isEqualToString:@""]) return nil;
    return cancelTitle;
}
+ (NSString *) messageCancelUrl;
{
    NSString *cancelTitle = [[Mystic core].data objectForKey:@"message_cancel_url"];
    if(cancelTitle && [cancelTitle isEqualToString:@""]) return nil;
    return cancelTitle;
    
}
+ (NSString *) messageConfirmTitle;
{
    return [[Mystic core].data objectForKey:@"message_confirm"];
}
+ (NSString *) messageCancelTitle;
{
    NSString *cancelTitle = [[Mystic core].data objectForKey:@"message_cancel"];
    if(cancelTitle && [cancelTitle isEqualToString:@""]) return nil;
    return cancelTitle;
}
+ (BOOL) messageIsReminder;
{
    return [[[Mystic core].data objectForKey:@"message_remind"] boolValue];
}
+ (BOOL) hasUnseenMessage;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *pastMessages = [defaults objectForKey:@"mystic.pastMessages"] ? [defaults objectForKey:@"mystic.pastMessages"] : [NSArray array];
    
    if(![pastMessages containsObject:[Mystic messageKey]])
    {
        return YES;
    }
    
    return NO;
}

+ (void) displayMessage;
{
    if(![Mystic messageKey] || ![Mystic hasUnseenMessage])  return;
    [MysticAlert show:[Mystic messageTitle] message:[Mystic messageText] action:^(id o, id o2){
        
        [Mystic rememberMessageKey];
        
        if([Mystic messageUrl])
        {
            [NSTimer wait:0.4 block:^{
                
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Mystic messageUrl]]];
                
                
            }];
        }
        
    } cancel:^(id object, id o2) {
        if([Mystic messageCancelUrl])
        {
            [NSTimer wait:0.4 block:^{
                
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Mystic messageCancelUrl]]];
                
            }];
        }
        
        if(![Mystic messageIsReminder]) { [Mystic rememberMessageKey]; }
    } options:@{@"button": [Mystic messageConfirmTitle], @"cancelTitle":[Mystic messageCancelTitle]}];
    
    
}
+ (void) rememberMessageKey;
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *pastMessages = [defaults objectForKey:@"mystic.pastMessages"] ? [defaults objectForKey:@"mystic.pastMessages"] : [NSArray array];
    if(![pastMessages containsObject:[Mystic messageKey]])
    {
        NSMutableArray *pmsgs = [NSMutableArray arrayWithArray:pastMessages];
        [pmsgs addObject:[Mystic messageKey]];
        [defaults setObject:[NSArray arrayWithArray:pmsgs] forKey:@"mystic.pastMessages"];
        [defaults synchronize];
    }
    
}

#pragma mark - Mystic Instance Methods

- (id) init
{
    self = [super init];
    if(self)
    {
        
        
        
        [self setData:[self fileData:nil useDefaultAsBackUp:YES] localize:NO];
//        self.data = [self fileData];
        
        
        // allocate a reachability object
        Reachability* reach = [Reachability reachabilityWithHostname:REACHABLE_HOST];
        
        // set the blocks
        reach.reachableBlock = ^(Reachability*reach)
        {
            isInternetReachable = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:MysticInternetAvailableEventName object:nil];
        };
        
        reach.unreachableBlock = ^(Reachability*reach)
        {
            isInternetReachable = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:MysticInternetUnavailableEventName object:nil];
            
        };
        
        // start the notifier which will cause the reachability object to retain itself!
        [reach startNotifier];
        
        
    }
    return self;
}



- (id) data;
{
    return [super data];
}










@end
