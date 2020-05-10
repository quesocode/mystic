//
//  MysticControlObject.m
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "MysticControlObject.h"
#import "Mystic.h"
#import "UserPotion.h"

@implementation MysticControlObject

@synthesize name=_name, controlImageName=_controlImageName, type=_type, selected=_selected, controlImage=_controlImage, selectable=_selectable, defaultControlImage=_defaultControlImage, lockedOverlayImage=_lockedOverlayImage, selectedOverlayImage=_selectedOverlayImage, updatesPhoto=_updatesPhoto, enabled=_enabled, price=_price, showsSubControls=_showsSubControls, parentControl=_parentControl, deselectable=_deselectable, desc=_desc,  cancelsEffect=_cancelsEffect, coreData=_coreData, tag=_tag, showLabel=_showLabel, alwaysShowLabel=_alwaysShowLabel, selectedControlImage=_selectedControlImage, groupType=_groupType, info=_info, controlImageURL=_controlImageURL, updatesSiblingsOnChange=_updatesSiblingsOnChange, groupName, imageURLString=_imageURLString, previewURLString, thumbURLString, level=_level, originalImageURLString=_originalImageURLString, hasAdjustableSettings, action=_action, cancelAction=_cancelAction, allowsMultipleSelections=_allowsMultipleSelections, showAllActiveControls=_showAllActiveControls, isActiveAction=_isActiveAction;

+ (id) optionWithName:(NSString *)name info:(NSDictionary *)info;
{
    MysticControlObject *pack = [[[self class] alloc] init];
    pack.name = [info objectForKey:@"name"] ? [info objectForKey:@"name"] : name;
    pack.desc = [info objectForKey:@"description"] ? [info objectForKey:@"description"] : @"Info coming soon...";
    pack.tag = name;
    pack.controlImageName = [info objectForKey:@"controlImage"];
    pack.cancelsEffect = [[info objectForKey:@"cancel"] boolValue];
    pack.info = info ? info : [NSDictionary dictionary];
    
    [pack commonInit];
    
    return [pack autorelease];
}

+ (MysticObjectType) classObjectType;
{

    return [self objectTypeForClass:[self class]];
}
+ (MysticObjectType) objectTypeForClass:(Class)theClass;
{
    NSString *classStr = NSStringFromClass(theClass);
    MysticObjectType classType;
    if([classStr isEqualToString:@"MysticPack"])
    {
        classType = MysticObjectTypePack;
    }
    else if([classStr isEqualToString:@"MysticTextPack"])
    {
        classType = MysticObjectTypeTextPack;
    }
    else if([classStr isEqualToString:@"MysticFramePack"])
    {
        classType = MysticObjectTypeFramePack;
    }
    else if([classStr isEqualToString:@"MysticTexturePack"])
    {
        classType = MysticObjectTypeTexturePack;
    }
    else if([classStr isEqualToString:@"MysticLightPack"])
    {
        classType = MysticObjectTypeLightPack;
    }
    else if([classStr isEqualToString:@"PackPotionOptionSpecial"])
    {
        classType = MysticObjectTypeSpecial;
    }
    else if([classStr isEqualToString:@"MysticBadgePack"])
    {
        classType = MysticObjectTypeBadgePack;
    }
    else if([classStr isEqualToString:@"PackPotionOptionLight"])
    {
        classType = MysticObjectTypeLight;
    }
    else if([classStr isEqualToString:@"PackPotionOptionRecipe"])
    {
        classType = MysticObjectTypePotion;
    }
    else if([classStr isEqualToString:@"PackPotionOptionCamLayer"])
    {
        classType = MysticObjectTypeCamLayer;
    }
    else if([classStr isEqualToString:@"PackPotionOptionShape"])
    {
        classType = MysticObjectTypeShape;
    }
    else if([classStr isEqualToString:@"PackPotionOptionFont"])
    {
        classType = MysticObjectTypeFont;
    }
    else if([classStr isEqualToString:@"PackPotionOptionFontStyle"])
    {
        classType = MysticObjectTypeFontStyle;
    }
    else if([classStr isEqualToString:@"PackPotionOptionTexture"])
    {
        classType = MysticObjectTypeTexture;
    }
    else if([classStr isEqualToString:@"PackPotionOptionFrame"])
    {
        classType = MysticObjectTypeFrame;
    }
    else if([classStr isEqualToString:@"PackPotionOptionMask"])
    {
        classType = MysticObjectTypeMask;
    }
    else if([classStr isEqualToString:@"PackPotionOptionFilter"])
    {
        classType = MysticObjectTypeFilter;
    }
    else if([classStr isEqualToString:@"PackPotionOptionBadge"])
    {
        classType = MysticObjectTypeBadge;
        
    }
    else if([classStr isEqualToString:@"PackPotionOptionColorOverlay"])
    {
        classType = MysticObjectTypeColorOverlay;
        
    }
    else if([classStr isEqualToString:@"PackPotionOptionColor"])
    {
        classType = MysticObjectTypeColor;
    }
    else if([classStr isEqualToString:@"PackPotionOptionText"])
    {
        classType = MysticObjectTypeText;
        
    }
    else if([classStr isEqualToString:@"PackPotionOptionSetting"])
    {
        classType = MysticObjectTypeSetting;

    }
    else if([classStr isEqualToString:@"PackPotionOption"])
    {
        classType = MysticObjectTypeOption;

    }
    else if([classStr isEqualToString:@"PackPotion"])
    {
        classType = MysticObjectTypePotion;
    }
    else
    {
        classType = MysticObjectTypeUnknown;
    }

    return classType;
}
+ (Class) classForType:(MysticObjectType)optionType;
{
    Class optionClass = [PackPotionOption class];

    switch (optionType) {
        case MysticObjectTypeLight:
            optionClass = [PackPotionOptionLight class];
            break;
        case MysticObjectTypeSpecial:
            optionClass = [PackPotionOptionSpecial class];
            break;
        case MysticObjectTypeDesign:
        case MysticObjectTypeText:
            optionClass = [PackPotionOptionText class];
            break;
        case MysticObjectTypeTexture:
            optionClass = [PackPotionOptionTexture class];
            break;
        case MysticObjectTypeFrame:
            optionClass = [PackPotionOptionFrame class];
            break;
        case MysticObjectTypeMask:
            optionClass = [PackPotionOptionMask class];
            break;
        case MysticObjectTypeShape:
            optionClass = [PackPotionOptionShape class];
            break;
        case MysticObjectTypeBadge:
            optionClass = [PackPotionOptionBadge class];
            break;
        case MysticSettingColorFilter:
        case MysticObjectTypeFilter:
            optionClass = [PackPotionOptionFilter class];
            break;
        case MysticObjectTypeColorOverlay:
            optionClass = [PackPotionOptionColorOverlay class];
            break;
        case MysticObjectTypeTextColor:
        case MysticObjectTypeColor:
            optionClass = [PackPotionOptionColor class];
            break;
        case MysticObjectTypeBadgeColor:
            optionClass = [PackPotionOptionColor class];
            break;
        case MysticObjectTypeFrameBackgroundColor:
            optionClass = [PackPotionOptionColor class];
            break;
        case MysticObjectTypeTextPack:
        case MysticObjectTypePack:
            optionClass = [MysticPack class];
            break;
            
        default: break;
    }
    return optionClass;
}

- (void) dealloc
{
    if(self.isActiveAction) self.isActiveAction = nil;
    if(self.action) self.action=nil;
    if(self.cancelAction) self.cancelAction=nil;
    [_cancelAction release], _cancelAction=nil;
    [_isActiveAction release];
    [_action release], _action=nil;
    [_selectedControlImage release];
    [_controlImage release];
    [_controlImageName release];
    [_controlImageURL release];
    [_tag release];
    [_name release];
    [_desc release];
    [_defaultControlImage release];
    [_defaultControlImageName release];
    _parentControl = nil;
    [_lockedOverlayImage release];
    [_coreData release];
    [_info release];
    
    [super dealloc];
}
- (void) setObject:(id)object forKey:(id<NSCopying>)aKey;
{
    if(!object || !aKey) return;

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:self.info];
    [d setObject:object forKey:aKey];
    self.info = [NSDictionary dictionaryWithDictionary:d];
}
- (id) init
{
    self = [super init];
    if(self)
    {
        _showAllActiveControls = NO;
        _controlImageName = nil;
        _updatesPhoto = YES;
        _selectable = YES;
        _selected = NO;
        _hasBeenDisplayed = NO;
        _allowsMultipleSelections = NO;
        _updatesSiblingsOnChange = YES;
        _showsSubControls = NO;
        _cancelsEffect = NO;
        _enabled = YES;
        _deselectable = NO;
        _showLabel = NO;
        _alwaysShowLabel = NO;
        _price = 0;
        _level = NSNotFound;
        self.alwaysShowLabel = YES;
        self.type = [[self class] classObjectType];
        switch (self.type) {
            case MysticObjectTypePack:
            {
                _showsSubControls = YES;
                _deselectable = YES;
                self.showLabel = NO;
                break;
            }
            
            case MysticObjectTypeFilter:
            {
                self.showLabel = YES;
                break;
            }
            
            case MysticObjectTypeSetting:
            {
                self.showLabel = NO;
                _alwaysShowLabel = NO;
                break;
            }
            case MysticObjectTypeOption:
            {
                _updatesPhoto = NO;
                _deselectable = YES;
                break;
            }

            case MysticObjectTypeUnknown:
            {
                _updatesPhoto = NO;
                break;
            }
            default:
            {
                break;
            }
        }
        
    }
    return self;
}
- (void) commonInit;
{
    
}

- (BOOL) hasAdjustableSettings;
{
    return !self.cancelsEffect && !self.showLabel;
}
- (NSInteger) integerValue;
{
    return self.level;
}

- (NSString *) groupName;
{
    switch (self.groupType) {
        case MysticObjectTypeBadge:
            return @"badges";
            break;
        case MysticObjectTypeText:
            return @"text";
            break;
        case MysticObjectTypeTexture:
            return @"textures";
            break;
        case MysticObjectTypeLight:
            return @"lights";
            break;
        case MysticObjectTypeFrame:
            return @"frames";
            break;
        case MysticObjectTypeFilter:
            return @"filters";
            break;
        case MysticObjectTypeColorOverlay:
            return @"colorOverlays";
            
        default: break;
    }
    return nil;
}
- (BOOL) hasCustomRender; { return NO; }
- (void) setInfo:(NSDictionary *)info
{
    
    if([info isKindOfClass:[MysticObjectItem class]])
    {
        info = [(MysticObjectItem *)info info];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary dictionaryWithDictionary:info] mutableCopy];
    
    
    NSArray *keysForNullValues = [dict allKeysForObject:@""];
    [dict removeObjectsForKeys:keysForNullValues];
    NSDictionary *info2 = [NSDictionary dictionaryWithDictionary:dict];
    [dict autorelease];
//    DLog(@"pack null values: %@", keysForNullValues);
    
    if(_info) [_info release], _info=nil;
    _info = [info2 retain];
    
//    if(![info objectForKey:@"controlImage"] || [[info objectForKey:@"controlImage"] isEqualToString:@"none_controlImage"] || [[info objectForKey:@"controlImage"] isEqualToString:@""])
//    {
//        self.showLabel = YES;
//    }
    
}
- (NSString *) controlImageURL
{
    return _info && [_info objectForKey:@"controlImage_url"] ? [_info objectForKey:@"controlImage_url"] : nil;
}

- (UIImage *) selectedControlImage
{
    NSString *n = self.cancelsEffect ? @"none-selected_controlImage.png" : nil;
    if(n==nil)
    {
        NSString *n2 = self.controlImageName;
        if(n2)
        {
            n = n2;
        }
    }
    return [UIImage imageNamed:n];
}

- (NSString *) controlImageName
{
    if(_controlImageName && ![_controlImageName isEqualToString:@""])
    {
        return _controlImageName;
    }
    NSCharacterSet *charactersToRemove =
    [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
    NSString *trimmedReplacement =
    [[ [self.name lowercaseString] componentsSeparatedByCharactersInSet:charactersToRemove ]
     componentsJoinedByString:@"" ];
    
    NSString *pathName = [NSString stringWithFormat:@"%@_controlImage", trimmedReplacement];
    NSString *path = [Mystic pathForFilename:pathName];

    return path ? pathName : [self defaultControlImageName];
}
- (NSString *) controlImageNamePath
{
    NSString *pathName = self.cancelsEffect ?  @"none_controlImage" : _controlImageName;
    if(!pathName)
    {
        NSCharacterSet *charactersToRemove =
        [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
        NSString *trimmedReplacement =
        [[ [self.name lowercaseString] componentsSeparatedByCharactersInSet:charactersToRemove ]
         componentsJoinedByString:@"" ];
        
        
        pathName = [NSString stringWithFormat:@"%@_controlImage", trimmedReplacement];
        
    }
    
    
    
    NSString *path = [Mystic pathForFilename:pathName];
    return path;
}
- (NSString *) defaultControlImageName
{
    return @"none_controlImage.png";
//    
//    if(self.parentControl) return self.parentControl.controlImageName;
//    return @"none_controlImage.png";
//    NSString *d = @"default_controlImage";
//    switch (self.type) {
//        case MysticObjectTypeFilter :
//            d = @"filter_controlImage";
//            break;
//        case MysticObjectTypePack :
//            d = @"default_controlImage";
//            break;
//        case MysticObjectTypePotion :
//            d = @"default_controlImage";
//            break;
//        case MysticObjectTypeText :
//            d = @"text_controlImage";
//            break;
//        case MysticObjectTypeTexture :
//            d = @"texture_controlImage";
//            break;
//        case MysticObjectTypeFrame :
//            d = @"frame_controlImage";
//            break;
//        case MysticObjectTypeMask :
//            d = @"mask_controlImage";
//            break;
//        case MysticObjectTypeLight :
//            d = @"light_controlImage";
//            break;
//            
//        default: break;
//    }
//    
//    return d;
}

- (void) setControlImageName:(NSString *)controlImageName
{
    if([Mystic pathForFilename:controlImageName])
    {
        if(_controlImageName) [_controlImageName release], _controlImageName = nil;
        _controlImageName = controlImageName ? [controlImageName retain] : nil;
    }
}

- (id) setUserChoice;
{
    if(self.cancelsEffect || (!self.cancelsEffect && self.type != MysticObjectTypeCamLayer))
    {
        PackPotionOption *newOption = [UserPotion setOption:(PackPotionOption *)self type:self.type];
        newOption.ignoreRender = self.cancelsEffect;
    }
    return self;
}

- (id) objectForKey:(id)key;
{
    return [self.info objectForKey:key];
}

- (void) setType:(MysticObjectType)type
{
    _type = type;
    _groupType = MysticTypeForSetting(type, self);
    switch (_groupType) {
        case MysticObjectTypeBadgeOverlay:
            _groupType = MysticObjectTypeBadge;
            break;
        case MysticObjectTypeTextOverlay:
            _groupType = MysticObjectTypeText;
            break;
        default: break;
    }
    
    if(MysticTypeSubTypeOf(type, MysticSettingSettings))
    {
        _updatesSiblingsOnChange = NO;
    }
}





- (NSString *) imageURLString;
{
    NSString * i = isM(self.info[@"image_url"]) ? [self.info objectForKey:@"image_url"] : [self.info objectForKey:@"imageURLString"];
    if(!i && isM(self.info[@"jpng_big_url"])) i = self.info[@"jpng_big_url"];
    return i;
}

- (NSString *) previewURLString;
{
    NSString * i = isM(self.info[@"preview_url"]) ? [self.info objectForKey:@"preview_url"]  : [self.info objectForKey:@"previewURLString"];
    if(!i && isM(self.info[@"jpng_small_url"])) i = self.info[@"jpng_small_url"];
    
    return i ? i : self.imageURLString;
    
}

- (NSString *) thumbURLString;
{
    
    NSString *thumbUrl  = isM(self.info[@"thumbURLString"]) ? [self.info objectForKey:@"thumbURLString"] : nil;
    
    if(!thumbUrl && self.groupName && isM(self.info[@"preview"]))
    {
     thumbUrl = [self.info objectForKey:@"thumb_url"] ? [self.info objectForKey:@"thumb_url"] : [NSString stringWithFormat:@"http://s3.amazonaws.com/files.mysti.ch/newthumb/%@/%@", self.groupName, [[self.info objectForKey:@"preview"] stringByReplacingOccurrencesOfString:@"preview-" withString:@"thumb-"]];
    }
    if(!thumbUrl && self.groupName && isM(self.info[@"thumb_url"]))
    {
        thumbUrl = self.info[@"thumb_url"];
    }
    return !thumbUrl ? nil : [thumbUrl stringByReplacingOccurrencesOfString:@"http://s3.amazonaws.com/files.mysti.ch" withString:@"http://d3b9motiviyay1.cloudfront.net"];
}


@end
