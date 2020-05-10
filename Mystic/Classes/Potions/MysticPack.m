//
//  MysticPack.m
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "MysticPack.h"
#import "UIButton+WebCache.h"
#import "UserPotion.h"
#import "MysticOptionsDataSource.h"

@interface MysticPack ()
{
    
}
@end

@implementation MysticPack

@synthesize potions=_potions, numberOfPotions=_numberOfPotions, defaultPotion=_defaultPotion, packId=_packId, groupType=_groupType, featuredPack, packOptions, controlImageName=_controlImageName;


+ (Class) optionsDataSourceClass;
{
    return [MysticOptionsDataSource class];
}
+ (MysticObjectType) objectType;
{
    return [[self class] objectTypeForClass:[self class]];
}
+ (NSString *) featuredTitle;
{
    return nil;
}

+ (id) packForIndex:(MysticPackIndex *)index;
{
    if(index.featured)
    {
        return [self featuredPackForType:index.type useTypeTitle:NO max:index.maxOptions];
    }
    MysticPack *p = [self packForTag:index.tag];
    p.type = index.type;
    p.maxNumberOfPotions = index.maxOptions;
    return p;
}

+ (MysticPack *) packForTag:(NSString *)packTag;
{
    MysticPack *pack = nil;
    NSDictionary *packInfo = [MysticOptionsDataSource objectAtKeyPath:[@"packs." stringByAppendingString:packTag]];
    if(packInfo)
    {
        pack = [[[self class] optionsDataSourceClass] itemForType:MysticObjectTypePack info:packInfo itemKey:packTag class:[MysticPack class]];
    }
    
    
    
    return pack;
}
+ (MysticPack *) pack:(MysticObjectType)objType;
{
    if(!MysticTypeHasPack(objType)) return nil;
    return [self packForType:objType];
}
+ (MysticPack *) packForType:(MysticObjectType)objType;
{
    return [self featuredPackForType:objType useTypeTitle:YES max:NSNotFound];
}
+ (MysticPack *) featuredPackForType:(MysticObjectType)objType;
{
    return [self featuredPackForType:objType useTypeTitle:NO max:NSNotFound];
}
+ (MysticPack *) featuredPackForType:(MysticObjectType)objType useTypeTitle:(BOOL)useTypeTitleForFeatured max:(NSInteger)max
{
    
    NSString *groupKey = objType == MysticObjectTypePack ? @"items" : MysticObjectTypeKey(objType);
    
    NSDictionary *groupInfo = [[[self class] optionsDataSourceClass] objectAtKeyPath:[@"group-packs." stringByAppendingString:groupKey]];
 
    BOOL isAFeaturedPack = YES;
    if([(NSArray *)[groupInfo objectForKey:@"packs"] count] < 2)
    {
        NSMutableDictionary *gInfo = [NSMutableDictionary dictionaryWithDictionary:groupInfo];
        id lp = [[[self class] optionsDataSourceClass] objectAtKeyPath:[@"orders." stringByAppendingString:groupKey]];
        if(lp)
        {
            [gInfo setObject:lp forKey:@"layers_primary"];
        }
        groupInfo = gInfo;
        useTypeTitleForFeatured = YES;
        isAFeaturedPack = NO;
        
    }
    NSString *featuredTitle = [[self class] featuredTitle];
    featuredTitle = featuredTitle ? featuredTitle : (!useTypeTitleForFeatured ? [MysticSettings settingForKey:[NSString stringWithFormat:@"%@_featured_title", MysticObjectTypeKey(objType)] default:@"Featured"] : MysticObjectTypeTitleParent(objType, objType));
    
    MysticPack *pack = [[self class] packWithName:featuredTitle info:groupInfo];
    pack.featuredPack = isAFeaturedPack;
    pack.groupType = objType;
    if(max != NSNotFound) pack.maxNumberOfPotions = max;
    return pack;
}


+ (MysticPack *) packForOption:(PackPotionOption *)option;
{

    if(!option.cameFromFeaturedPack)
    {
        NSString *primaryTagName = [option.info objectForKey:@"primary_tag_name"];
        if(primaryTagName)
        {
            MysticPack *pack = [self packForTag:primaryTagName];
            if(pack) return pack;
        }
     
    }
    return [self featuredPackForType:option.type];

}
+ (MysticPack *) packWithId:(NSInteger)packId;
{

    NSArray *packs = [Mystic core].packs;
    if(packs)
    {
        for (MysticPack *pack in packs) {
            if(pack.packId == packId)
            {
                return pack;
            }
        }
    }
    return nil;
}
+ (MysticPack *) optionWithName:(NSString *)name info:(NSDictionary *)info;
{
    return [self packWithName:name info:info];
}
+ (MysticPack *) packWithName:(NSString *)name info:(NSDictionary *)info;
{
    MysticPack *pack = [[[self class] alloc] init];
    pack.name = name;
    pack.packId = [info objectForKey:@"id"] ? [[info objectForKey:@"id"] integerValue] : -1;
    pack.desc = [info objectForKey:@"description"] ? [info objectForKey:@"description"] : @"Info coming soon...";
    pack.potions = [info objectForKey:@"potions"];
    pack.tag = name;
    pack.controlImageName = [info objectForKey:@"controlImage"];
    pack.info = info;
    pack.title = [info objectForKey:@"title"] && [(NSString *)[info objectForKey:@"title"] length] > 0 ? [info objectForKey:@"title"] : nil;
    pack.subtitle = [info objectForKey:@"subtitle"] && [(NSString *)[info objectForKey:@"subtitle"] length] > 0 ? [info objectForKey:@"subtitle"] : nil;
    pack.isSpecial = [[info objectForKey:@"special"] boolValue];
    @try {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
        df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
        df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        pack.availableDate = [info objectForKey:@"available"] ? [df dateFromString:[info objectForKey:@"available"]] : nil;
        pack.unavailableDate = [info objectForKey:@"unavailable"] ? [df dateFromString:[info objectForKey:@"unavailable"]] : nil;
        [df release], df=nil;
    }
    @catch (NSException * e) {
        NSLog(@"Error parsing pack available date: %@ - %@  | Error: %@", [info objectForKey:@"available"], [info objectForKey:@"unavailable"], [e description]);
    }
    
    
    MysticObjectType agroupType = MysticObjectTypeText;
    NSString *groupTitle = [info objectForKey:@"group"];
    if(groupTitle)
    {
        if([groupTitle isEqualToString:@"text"])
        {
            agroupType = MysticObjectTypeText;
        }
        else if([groupTitle isEqualToString:@"frames"])
        {
            agroupType = MysticObjectTypeFrame;
        }
        else if([groupTitle isEqualToString:@"textures"])
        {
            agroupType = MysticObjectTypeTexture;
        }
        else if([groupTitle isEqualToString:@"lights"])
        {
            agroupType = MysticObjectTypeLight;
        }
        else if([groupTitle isEqualToString:@"badges"])
        {
            agroupType = MysticObjectTypeBadge;
        }
        else if([groupTitle isEqualToString:@"filters"])
        {
            agroupType = MysticObjectTypeFilter;
        }
        else if([groupTitle isEqualToString:@"fonts"])
        {
            agroupType = MysticObjectTypeFont;
        }
        else if([groupTitle isEqualToString:@"colors"])
        {
            agroupType = MysticObjectTypeColor;
        }
    }
    else
    {
        agroupType = [[self class] objectType];
    }
    pack.groupType = agroupType;
    pack.cancelsEffect = ![info objectForKey:@"cancel"] ? NO : [[info objectForKey:@"cancel"] boolValue];
    return [pack autorelease];
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        _numberOfItems = NSNotFound;
        self.maxNumberOfPotions = NSNotFound;
        self.optionKeys = [NSMutableArray array];

    }
    return self;
}
- (void) dealloc
{
    [_defaultPotion release];
//    _queryString = nil;
    [_potions release];
    [_optionKeys release];
    [_groupTitle release];
    [_controlImageName release];
    [_title release];
    [_subtitle release];
    [_availableDate release];
    [_unavailableDate release];
    [super dealloc];
}

- (BOOL) isAvailable;
{
    if(!self.availableDate && !self.unavailableDate) return YES;
    
    NSDate *today = [NSDate date];
    if(self.availableDate && [self.availableDate laterDate:today] == self.availableDate)
    {
        return NO;
    }
    
    if(self.unavailableDate && [self.unavailableDate laterDate:today] == today)
    {
        return NO;
    }
    
    return YES;
    
}
- (NSString *) title;
{
    if(_title)
    {
        return MyLocalStr(_title);
    }
    return self.name;
}
- (NSString *) subtitle;
{
    NSString *s = nil;
    NSInteger theCount = NSNotFound;
    BOOL replaceCount = YES;
    if(_subtitle)
    {
        s = MyLocalStr(_subtitle);
    }
    
    if(!s)
    {
        if(self.featuredPack)
        {
            id ns = [MysticSettings settingForKey:[NSString stringWithFormat:@"%@_featured_subtitle", MysticObjectTypeKey(self.groupType)]];
            if(ns) s = MyLocalStr(ns);
        }
        else if(self.isSpecial)
        {
            id ns = [MysticSettings settingForKey:[NSString stringWithFormat:@"%@_special_subtitle", MysticObjectTypeKey(self.groupType)]];
            if(ns) s = MyLocalStr(ns);
        }
        
        if(!s)
        {
            theCount = self.packOptions.count;
            
            NSString *groupSuffix = self.groupTitle;
            if(theCount == 1 && [groupSuffix hasSuffix:@"s"])
            {
                groupSuffix = [groupSuffix substringWithRange:NSMakeRange(0, groupSuffix.length -1)];
            }
            s = [NSString stringWithFormat:@"%d %@", (int)theCount, groupSuffix];
            replaceCount = NO;
        }
    }
    if(theCount == NSNotFound) theCount = self.packOptions.count;
    s = s && replaceCount ? [s stringByReplacingOccurrencesOfString:@"{count}" withString:[NSString stringWithFormat:@"%@", @(theCount)]] : s;
    return s;
}
- (NSString *) titleColorStr;
{
    return [self objectForKey:@"titleColor"];
}
- (NSString *) subTitleColorStr;
{
    return [self objectForKey:@"subTitleColor"];
}
- (NSString *) tag;
{
    if([[self.name lowercaseString] isEqualToString:@"#tags"])
    {
        return @"tags";
    }
    if(self.featuredPack)
    {
        return @"featured";
    }
    return self.name;
}

- (PackPotionOption *) sampleOption;
{
    NSArray *__packOptions = self.packOptions;
    NSString *sampleLayerKey = [self.info objectForKey:@"sample_layer_key"];
    if(sampleLayerKey && sampleLayerKey.length)
    {
        for (PackPotionOption *option in __packOptions) {
            if([option.tag isEqualToString:sampleLayerKey]) return option;
        }
    }
    return __packOptions.count ? [__packOptions objectAtIndex:0] : nil;
}

- (NSString *) groupTitle;
{
    if(_groupTitle) return _groupTitle;
    
    switch (self.groupType) {
        case MysticObjectTypeBadge:
            return @"Symbols";
        case MysticObjectTypeText:
            return @"Designs";
        case MysticObjectTypeColor:
            return @"Colors";
        case MysticObjectTypeTexture:
            return @"Textures";
        case MysticObjectTypeFrame:
            return @"Frames";
        case MysticObjectTypeFilter:
            return @"Filters";
        case MysticObjectTypeLight:
            return @"Lights";
        case MysticObjectTypeFont:
            return @"Fonts";
        case MysticObjectTypeColorOverlay:
            return @"Colors";
            
        default: break;
    }
    return MysticObjectTypeTitleParent(self.groupType, nil);
}

- (NSString *) groupName;
{
    if(self.featuredPack)
    {
        switch (self.groupType) {
            case MysticObjectTypeBadge:
                return @"badges";
            case MysticObjectTypeText:
                return @"text";
            case MysticObjectTypeColor:
                return @"colors";
            case MysticObjectTypeTexture:
                return @"textures";
            case MysticObjectTypeFrame:
                return @"frames";
            case MysticObjectTypeFilter:
                return @"filters";
            case MysticObjectTypeLight:
                return @"lights";
            case MysticObjectTypeFont:
                return @"fonts";
            case MysticObjectTypeColorOverlay:
                return @"colors";
            case MysticObjectTypeLayerShape:
            case MysticObjectTypeShape:
                return @"shapes";
            default: break;
        }
    }
    return [self.info objectForKey:@"group"] ? [[self.info objectForKey:@"group"] lowercaseString] : @"";
}
- (NSString *) specialThumbUrl;
{
    NSString *u = [self objectForKey:@"special_thumb_url"];
    if(u && u.length)
    {
        return u;
    }
    return self.controlImageURL;
}
- (BOOL) hasCustomControlImageURL;
{
    return self.controlImageURL != nil;
}
- (NSString *) controlImageURL;
{
    if(self.featuredPack)
    {
        id u = [MysticSettings settingForKey:[NSString stringWithFormat:@"%@_featured_thumb", MysticObjectTypeKey(self.groupType)]];
        if(u) return u;
    }
    return [super controlImageURL];
}
- (NSString *) controlImageName;
{
    NSString *c = [self.info objectForKey:@"control"];
    if(c && ![c isEqualToString:@""])
    {
        return c;
    }
    NSString *imgName = [[self.tag lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    return [NSString stringWithFormat:@"pack-%@-%@", self.groupName, imgName];
}
- (void) styleButton:(MysticPackButton *)button;
{
    switch (self.groupType) {
        case MysticObjectTypeLight:
        case MysticObjectTypeFrame:
        case MysticObjectTypeTexture:
        {
            if(!self.featuredPack) button.imageViewAlphaOnSelect = MysticPackButtonImageViewAlphaOnSelect;
            break;
        }
        case MysticObjectTypeText:
        {
            button.showBorder = YES;
            break;
        }
        default: break;
    }
    
    
    NSString *imgName = [self controlImageName];
    UIImage *btnImage = [UIImage imageNamed:imgName];
    if(!btnImage && self.featuredPack)
    {
        btnImage = [UIImage imageNamed:@"pack-featured.png"];
    }
    if(btnImage)
    {

        [button setImage:btnImage forState:UIControlStateNormal];

        [self styleButtonText:button];
    }
    else if([self.info objectForKey:@"controlImage_url"])
    {
        
        
        NSString *url = [self.info objectForKey:@"controlImage_url"];
        if(url && ![url isEqualToString:@""])
        {
            
            __unsafe_unretained MysticPackButton *_button = button;
            [button cancelCurrentImageLoad];
            [button setImageWithURL:[NSURL URLWithString:self.thumbURLString] forState:UIControlStateNormal placeholderImage:nil options:0 manager:MysticCache.uiManager completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                [self styleButtonText:_button];
            }];
        }
        else
        {
            [button setTitle:self.name forState:UIControlStateNormal];
            [button setTitle:self.name forState:UIControlStateHighlighted];
            [button setTitle:self.name forState:UIControlStateSelected];
        }
    }
    else
    {
        [button setTitle:self.name forState:UIControlStateNormal];
        [button setTitle:self.name forState:UIControlStateHighlighted];
        [button setTitle:self.name forState:UIControlStateSelected];
    }
}
- (void) styleButtonText:(MysticPackButton *)button;
{
    switch (self.groupType) {
        case MysticObjectTypeLight:
        case MysticObjectTypeText:
        case MysticObjectTypeFrame:
        {
            [button setTitle:@"" forState:UIControlStateNormal];
            [button setTitle:@"" forState:UIControlStateHighlighted];
            [button setTitle:@"" forState:UIControlStateSelected];
            break;
        }
        default:
        {
            button.titleLabel.numberOfLines = 2;
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button setTitleColor:[[MysticColor colorWithType:MysticColorTypeControlInactive] lighter:0.2] forState:UIControlStateNormal];
            [button setTitleColor:[MysticColor colorWithType:MysticColorTypeWhite] forState:UIControlStateSelected];
            [button setTitle:self.tag forState:UIControlStateNormal];
            break;
        }
            
    }
    
}
- (NSString *) name;
{

    NSString *__title = self.featuredPack && !super.name ? [MysticSettings settingForKey:[NSString stringWithFormat:@"%@_featured_title", MysticObjectTypeKey(self.groupType)] default:@"Featured"] : super.name;

    return NSLocalizedString(__title, nil);
}

- (void) setPotions:(NSDictionary *)potions
{
    if(_potions) [_potions release], _potions = nil;
    _potions = potions ? [potions retain] : nil;
    _numberOfPotions = _potions ? [_potions count] : 0;
}

- (NSDictionary *) potions
{
    NSMutableDictionary *returnPotions = [NSMutableDictionary dictionary];
    
    if(self.numberOfPotions)
    {
        for (NSString *potionKey in [_potions allKeys]) {
            PackPotion *potion = [PackPotion potionWithName:potionKey info:[_potions objectForKey:potionKey]];
            potion.pack = self;
            [returnPotions setObject:potion forKey:potionKey];
        }
    }
    return [NSDictionary dictionaryWithDictionary:returnPotions];
}

- (PackPotion *) defaultPotion
{
    return self.numberOfPotions > 0 ? (PackPotion *)[ [self.potions allValues] objectAtIndex:0] : nil;
}

- (NSInteger) maxNumberOfPotions;
{
    return _maxNumberOfPotions == NSNotFound && self.featuredPack ? MYSTIC_FEATURED_MAX : _maxNumberOfPotions;
}
- (NSInteger) numberOfItems;
{
    return [self numberOfItems:nil];
}
- (NSInteger) numberOfItems:(MysticBlockFilteredKeyObjBOOL)f;
{
    NSInteger c = _numberOfItems;
    c = c != NSNotFound && !f ? c : (self.optionKeys.count && !f ? self.optionKeys.count : [self packItems:f].count);
    if(!f) _numberOfItems = c;
    return c;
}
- (MysticPackIndex *) index;
{
    return [MysticPackIndex packIndexForPack:self];
}
- (MysticPackIndex *) packIndex;
{
    return self.index;
}
- (NSArray *) packOptions;
{
    return self.packItems;
}
- (void) packOptions:(MysticBlockData)finished;
{
    switch (self.groupType) {
        case MysticObjectTypeColorOverlay:
            [[Mystic core] colorOverlays:nil dataBlock:finished];
            break;
            
        default:
            if(finished) finished(self.packItems, MysticDataStateComplete|MysticDataStateNew);
            break;
    }
}
- (NSArray *) packItems;
{
    return [self packItems:nil];
}
- (NSArray *) packItems:(MysticBlockFilteredKeyObjBOOL)filter;
{
    switch (self.groupType) {
        case MysticObjectTypeColorOverlay: return [Mystic core].colorOverlays;
        default: break;
    }
    CFTimeInterval startTime = CACurrentMediaTime();
    NSMutableArray *packEffects = [NSMutableArray array];
    if([self.info objectForKey:@"layer_options"]) return [self.info objectForKey:@"layer_options"];

    NSArray *_lyrKeys = self.featuredPack ? [self.info objectForKey:@"featured_layers"] : [self.info objectForKey:@"layers_primary"];
    NSMutableArray *lyrKeys = [NSMutableArray arrayWithArray:_lyrKeys && _lyrKeys.count ? _lyrKeys : [NSArray array]];

    
    NSDictionary *options = [[[self class] optionsDataSourceClass] objectAtKeyPath:MysticObjectTypeKey(self.groupType)];
    int x = 0;
    if(self.featuredPack)
    {
        if(lyrKeys.count < 1)
        {
            for (NSString *k in options.allKeys) {
                if(options[k][@"featured"] && [options[k][@"featured"] boolValue]) { [lyrKeys addObject:k]; x++; }
                if(x > self.maxNumberOfPotions) break;
            }
        }
        if(lyrKeys.count < 1)
        {
            x = 0;
            for (NSString *k in options.allKeys) {
                [lyrKeys addObject:k]; x++;
                if(x > self.maxNumberOfPotions) break;
            }
        }
        if(lyrKeys.count > self.maxNumberOfPotions) [lyrKeys removeObjectsInRange:NSMakeRange(0, self.maxNumberOfPotions)];
    }
    else
    {
        if(lyrKeys.count < 1)
        {
            for (NSString *k in options.allKeys) {
                if(options[k][@"pack"] && [options[k][@"pack"] isEqualToString:self.info[@"tag"]]) [lyrKeys addObject:k];
            }
        }
    }

    NSMutableArray *items = [NSMutableArray array];
    for (id key in lyrKeys) {
        NSDictionary *o = [options objectForKey:key];
        if([o isKindOfClass:[NSDictionary class]] && !o[@"key"])
        {
            NSMutableDictionary *o2 = [NSMutableDictionary dictionaryWithDictionary:o];
            [o2 setObject:key forKey:@"key"];
            o = (id)o2;
        }
        if(o) [items addObject:o];
    }
    if(items.count)
    {
        Class itemClass = [[[self class] optionsDataSourceClass] itemClassForType:self.groupType];
        if(self.featuredPack)
        {
            for (int i = 0; i<items.count; i++) {
                if([[items objectAtIndex:i] isKindOfClass:[NSNumber class]]) continue;
                if(!itemClass || [NSStringFromClass(itemClass) isEqualToString:NSStringFromClass([NSDictionary class])])
                {
                    [packEffects addObject:[items objectAtIndex:i]];
                }
                else
                {
                    PackPotionOption *opt = [itemClass optionWithName:[lyrKeys objectAtIndex:i] info:[items objectAtIndex:i]];
                    opt.cameFromFeaturedPack = YES;
                    [packEffects addObject:opt];
                }
            }
        }
        else
        {
            for (int i = 0; i<items.count; i++) {
                if([[items objectAtIndex:i] isKindOfClass:[NSNumber class]]) continue;
                if(!itemClass || [NSStringFromClass(itemClass) isEqualToString:NSStringFromClass([NSDictionary class])])
                    [packEffects addObject:[items objectAtIndex:i]];
                else [packEffects addObject:[itemClass optionWithName:[lyrKeys objectAtIndex:i] info:[items objectAtIndex:i]]];
            }
        }
    }
    _numberOfItems = packEffects.count ? packEffects.count : NSNotFound;
    return packEffects;
}
- (NSString *) productID;
{
    if(!self.info[@"product"])
    {
        DLogError(@"there is no product id for pack: %@", self.name);
    }
    return self.info[@"product"];
}

- (instancetype) setUserChoice;
{
    if(self.cancelsEffect)
    {
        [UserPotion resetPotion];
    }
    else
    {
        return (id)[self.defaultPotion setUserChoice];
    }
    return self;
}


- (MysticObjectType) packType;
{
    return self.groupType;
}

- (NSString *) queryString
{
    return [NSString stringWithFormat:@"pack=%ld&order=release", (long)self.packId];
}
@end


@implementation MysticTextPack
@end

@implementation MysticLightPack
@end

@implementation MysticFramePack
@end

@implementation MysticTexturePack
@end

@implementation MysticShapePack
@end

@implementation MysticLayerShapePack

+ (NSString *) featuredTitle;
{
    return MyLocalStr(@"Featured");
}
+ (Class) optionsDataSourceClass;
{
    return [MysticOptionsDataSourceShapes class];
}
+ (MysticObjectType) objectType;
{
    return MysticOptionTypeLayerShape;
}
- (MysticObjectType) type;
{
    return MysticObjectTypeLayerShape;
}
- (MysticObjectType) groupType;
{
    return MysticObjectTypeLayerShape;
}
@end

@implementation MysticPackIndex

+ (id) packIndexForPack:(MysticPack *)pack;
{

    MysticPackIndex *m = [[MysticPackIndex alloc] init];
    
    m.tag = pack.tag;
    m.packId = pack.packId;
    m.type = pack.packType;
    m.featured = pack.featuredPack;
    m.maxOptions = pack.maxNumberOfPotions;
    return [m autorelease];
}

- (void) dealloc;
{
    [_tag release];
    [super dealloc];
}

@end