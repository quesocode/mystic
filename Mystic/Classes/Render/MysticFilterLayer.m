//
//  MysticFilterLayer.m
//  Mystic
//
//  Created by Me on 11/13/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticFilterLayer.h"
#import "GPUImagePicture+TextureSubimage.h"
#import "MysticGPUImageFilterGroup.h"


@interface MysticFilterLayer ()
{
    NSMutableDictionary *_keys;
    MysticGPUImageLayerPicture *_processSourcePicture;
}
@end
@implementation MysticFilterLayer

@synthesize sourcePicture=_sourcePicture,
level=_level,
option=_option,
index=_index,
image=_image,
lastOutput=_lastOutput,
filters=_filters,
refreshAll=_refreshAll,
tag=_tag,
forceRequiresRefresh=_forceRequiresRefresh,
added=_added;

+ (MysticFilterLayer *) layerFromOption:(PackPotionOption *)opt;
{
    return [[self class] layerFromOption:opt tag:nil];
}
+ (MysticFilterLayer *) layerFromOption:(PackPotionOption *)opt tag:(NSString *)tag;
{
    
    MysticFilterLayer *l = [[[self class] alloc] initWithOption:opt];
    l.tag = tag;
    return [l autorelease];
}




- (id) init;
{
    self = [super init];
    if(self)
    {
        _hasGroupFilter = NO;
        _textures = [[NSMutableDictionary alloc] init];
        _requiresRefresh = NO;
        _isSourceLayer = NO;
        _setUseNextFrame = NO;
        _forceRequiresRefresh = NO;
        _index = NSNotFound;
        _keys = [[NSMutableDictionary alloc] init];
        _added = NO;
        _hasSiblings = NO;
        _filterKeys = [[NSMutableArray array] retain];
        self.filters = [NSMutableDictionary dictionary];
        
    }
    return self;
}




- (id) initWithOption:(PackPotionOption *)opt;
{
    self = [self init];
    if(self)
    {
        self.option = opt;
    }
    return self;
}

- (void) setOption:(PackPotionOption *)option;
{
    if(_option) [_option release]; _option=nil;
    if(option)
    {
        _option = [option retain];
        switch (_option.type) {
            case MysticObjectTypeFilter: _requiresRefresh = YES; break;
            default: break;
        }
    }
    
}


- (NSString *) tag;
{
    if(_tag) return _tag;
    if(_option) return [MysticFilterManager optionTag:(PackPotionOption *)_option];
    return nil;
}






- (NSInteger) position;
{
    return self.index != NSNotFound ? self.index + 1 : NSNotFound;
}

- (BOOL) hasGroupFilter;
{
    for (id filter in self.filters.allValues) {
        if([filter isKindOfClass:[MysticGPUImageFilterGroup class]]) return YES;
            
    }
    return NO;
}


- (id) addFilter:(id)obj;
{
    return [self addFilter:obj forKey:obj];
}




- (id) addFilter:(id)obj forKey:(id)key;
{
    if(!obj || !key) return nil;
    if(!self.requiresRefresh) self.requiresRefresh = YES;
    if([obj isKindOfClass:[MysticGPUImageFilterGroup class]])
    {
        [_filterKeys insertObject:key atIndex:0];
    }
    else
    {
        [_filterKeys addObject:key];
    }

    [self.filters setObject:obj forKey:key];
    
    return key;
    
}
- (id) setFilter:(id)obj forKey:(id)key;
{
    if(!obj) return nil;
    
    [self addFilter:obj forKey:key];
    return key;
    
}
- (void) setSourcePicture:(MysticGPUImageLayerPicture *)sourcePicture;
{
    if(_sourcePicture) [_sourcePicture release];
    _sourcePicture = [sourcePicture retain];
    _processSourcePicture = [_sourcePicture isKindOfClass:[GPUImagePicture class]] ? _sourcePicture : nil;
}



- (NSArray *) orderedFilters;
{
    NSMutableArray *a = [NSMutableArray array];
    for (id k in _filterKeys) {
        if([self.filters objectForKey:k]) [a addObject:[self.filters objectForKey:k]];
    }
    return a;
}


- (GPUImageOutput <GPUImageInput> *) lastOutput;
{
    if(self.filters.allValues.count && [self.filters objectForKey:_filterKeys.lastObject])
    {
        if(self.hasGroupFilter) return [self firstOutput];
        return [self.filters objectForKey:_filterKeys.lastObject];
    }
    return (GPUImageOutput <GPUImageInput> *)self.sourcePicture;
}

- (GPUImageOutput <GPUImageInput> *) firstOutput;
{
    return _filterKeys.count ? [self.filters objectForKey:[_filterKeys objectAtIndex:0]] : nil;
}

- (BOOL) hasSiblings; { return self.siblings && self.siblings.count; }
- (id) filterForKey:(id)key;
{
    id filter = [self.filters objectForKey:key];
    if(!filter && self.hasSiblings)
    {
            for (MysticFilterLayer *subLayer in self.siblings) {
                if([subLayer isEqual:self]) continue;
                id subFilter = [subLayer.filters objectForKey:key];
                if(subFilter)
                {
                    filter = subFilter;
                    break;
                }
            }
    }
    return filter ? [[filter retain] autorelease] : nil;
}




- (NSString *) filterKeysDescription;
{
    NSMutableString *s = [NSMutableString stringWithFormat:@"Layer #%ld Filter Keys:\r\n", (long)self.position];
    for (id k in _filterKeys) {
        [s appendFormat:@"\r\n\tKey: %@ <%p>  |  Value: %@", k, k, [self.filters objectForKey:k]];
    }
    return s;
}



- (id) currentKeyFor:(id)key;
{
    NSString *nks = [NSString stringWithFormat:@"%@", key];
    for (id k in self.filters.allKeys) {
        NSString *ks = [NSString stringWithFormat:@"%@", k];
        if([ks isEqualToString:nks]) return k;
    }
    return key;
}




- (void) removeFilterForKey:(id)key;
{
    [_filterKeys removeObject:key];
    [self.filters removeObjectForKey:key];
    
}

- (BOOL) requiresRefresh; {
    if(self.forceRequiresRefresh) { return YES; }
    return self.isSourceLayer ? NO : _requiresRefresh;
}


- (void) refresh:(PackPotionOption *)option;
{
    if(!self.requiresRefresh) return;
    @autoreleasepool {
        self.setUseNextFrame = !self.setUseNextFrame && [self.lastOutput respondsToSelector:@selector(useNextFrameForImageCapture)];
        [_processSourcePicture processImage];
        for (NSDictionary*texture in self.textures.allValues) [(GPUImagePicture *)texture[@"texture"] processImage];
    }
}




- (NSString *) debugDescription;
{
    return [NSString stringWithFormat:@"FilterLayer: (%p:%@) = %@", self.option, MysticString(self.option.type), self.tag];
}

- (NSInteger) level;
{
    return self.option ? self.option.level : NSNotFound;
}



- (MysticObjectType) type;
{
    return self.option ? self.option.type : MysticObjectTypeUnknown;
}

- (void) cleanAll;
{
    self.sourcePicture = nil;
    _processSourcePicture = nil;
    self.image = nil;
    self.lastOutput = nil;
    self.setUseNextFrame = NO;

}
- (void) prepareForUse;
{
    [self clean];
    
}
- (void) cleanFilters;
{
    self.filters = [NSMutableDictionary dictionary];
    [_filterKeys removeAllObjects];
//    self.lastOutput = nil;
}

- (void) clean;
{
    [self cleanFilters];
    //    self.sourcePicture = nil;
    //    self.image = nil;
    //    self.lastOutput = nil;
}

- (void) empty;
{
    _isSourceLayer = NO;
    _requiresRefresh = NO;
    _processSourcePicture = nil;
    [_lastOutput release], _lastOutput=nil;
    [_option release], _option=nil;
    [_sourcePicture release], _sourcePicture=nil;
    [_image release], _image=nil;
    [_siblings release], _siblings=nil;
    [_tag release], _tag=nil;
    [_filters release], _filters=nil;
    [_filterKeys removeAllObjects];
    [_keys release], _keys = nil;
}

- (void) addTexture:(MysticGPUImageLayerTexture *)texture forKey:(id)key;
{
    [self.textures setObject:@{@"texture":texture} forKey:key];
}
- (void) addTextureFilter:(id)texture forKey:(id)key textureKey:(id)textureKey;
{
    NSDictionary *t = self.textures[textureKey];
    NSMutableDictionary *t2 = [NSMutableDictionary dictionaryWithDictionary:t?t:@{}];
    if(!texture) [t2 removeObjectForKey:key];
    else [t2 setObject:texture forKey:key];
    if(t) [self.textures setObject:t2 forKey:textureKey];
}
- (void) replaceTexture:(id)textureKey image:(UIImage *)textureImage;
{
    if(!textureKey || !textureImage) return;
    MysticGPUImageLayerTexture *texture = self.textures[textureKey];
    if(texture) [texture replaceTextureWithSubimage:textureImage];
}
- (void) dealloc;
{
    [_textures release];
    _processSourcePicture = nil;
    [_filterKeys release];
    [_siblings release];
    [_tag release];
    _lastOutput = nil;
    _index = NSNotFound;
    [_keys release];
    [_filters release];
    [_sourcePicture release];
    [_option release];
    [_image release];
    [super dealloc];
}


@end
