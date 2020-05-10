//
//  MysticFilterManager.m
//  Mystic
//
//  Created by Travis on 10/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticFilterManager.h"
#import "MysticEffectsManager.h"
#import "MysticGPUImageView.h"
#import "MysticFilterDebug.h"
#import "MysticImageFilter.h"
#import "MysticRenderQueue.h"



@implementation MysticFilterManager

@synthesize sourcePicture=_sourcePicture,
allLayers=_allLayers,
layerKeys=_layerKeys,
lastOutput=_lastOutput,
index=_index,
//image=_image,
filter=_filter,
imageView=_imageView,
shader=_shader,
sourceNeedsProcess=_sourceNeedsProcess;




+ (MysticFilterManager *) manager;
{
    return [[[MysticFilterManager alloc] init] autorelease];
}





- (NSString *) debugDescription;
{
    return [MysticFilterDebug debugDescription:self];
}


- (void) dealloc;
{
    
    _imageView=nil;
    [_allLayers release];
    [_lastOutput release];
    [_layerKeys release];
    [_filter release];
    [_sourcePicture release];
    [_shader release];
//    [_image release];
    [super dealloc];
}





- (id) init;
{
    self = [super init];
    if(self)
    {
        self.sourceNeedsProcess = YES;
        self.sourcePicture = nil;
        self.allLayers = [NSMutableArray array];
        self.layerKeys = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void) clearCurrentLayers;
{
    [self removeFromTarget];
    self.sourcePicture = nil;
    self.lastOutput = nil;
    self.filter = nil;
//    self.image = nil;
    self.shader = nil;
    [self.allLayers removeAllObjects];
    [self.layerKeys removeAllObjects];
}

- (void) clearLayersForOptions:(MysticOptions *)theOptions
{
    [self removeFromTarget];

    self.lastOutput = nil;
    self.filter = nil;
//    self.image = nil;
    self.sourcePicture = nil;
    self.shader = nil;
    
    NSMutableArray *layersToRemove = [NSMutableArray array];
    for (MysticFilterLayer *layer in self.allLayers) {
        if(layer.option && [theOptions contains:layer.option])
        {
            [layersToRemove addObject:layer];
        }
    }
    for (MysticFilterLayer *layer in layersToRemove)
    {
//        DLog(@"Removing layer: \n%@\n--------------------------------\n", [MysticFilterDebug layerDebugDescription:layer]);
        [self.layerKeys removeObjectForKey:layer.tag];
        [self.allLayers removeObject:layer];
    }
}

- (void) clean;
{
    NSMutableArray *theLayers = [NSMutableArray array];
    NSMutableDictionary *theLayerKeys = [NSMutableDictionary dictionary];
//    NSInteger startingCount = theLayers.count;
    
    for (MysticFilterLayer *aLayer in self.allLayers) {
        if(aLayer.option)
        {
            if([[MysticOptions current] contains:aLayer.option equal:YES])
            {
                [theLayers addObject:aLayer];
            }
        }
    }
    
//    NSInteger endCount = theLayers.count;

    
    int i = 0;
    for (MysticFilterLayer *layer in theLayers) {
        layer.index = i+1;
        layer.added = YES;
        layer.option.layer = nil;
        
        [theLayerKeys setObject:[NSIndexPath indexPathForItem:i inSection:0] forKey:layer.tag];
        i++;
    }
    
    self.layerKeys = theLayerKeys;
    self.allLayers = theLayers;


}




- (void) empty;
{
    [self cleanUpNonDisplayFilters];
    for (MysticFilterLayer *layer in self.allLayers) [layer empty];
    [self removeFromTarget];
    [self removeAllLayers];
    self.sourcePicture = nil;
    self.filter = nil;
    self.lastOutput = nil;
    self.shader = nil;
    self.sourceNeedsProcess = YES;
    self.imageView = nil;
}


- (void) removeFromTarget;
{
    
    
    [self.lastOutput removeAllTargets];

}

- (BOOL) filter:(GPUImageOutput *)filter targetOf:(GPUImageOutput *)output;
{
    if([filter isEqual:output]) return YES;
    if([filter respondsToSelector:@selector(targets)])
    {
        for (GPUImageOutput <GPUImageInput> *filterTarget in filter.targets)
        {
//            DLogDebug(@"filterTarget: %@ -> %@ -> %@", filter, output, filterTarget);
            if([filterTarget isEqual:output] || [filterTarget isEqual:filter])
            {
                return YES;
            }
            else if([filterTarget respondsToSelector:@selector(targets)] && filterTarget.targets.count)
            {
                BOOL f = [self filter:filterTarget targetOf:output];
                if(f) return f;
            }
        }
    }
    return NO;
}
- (void)cleanUpNonDisplayFilters;
{
    BOOL logIt = [MysticUser is:Mk_DEBUG];
    logIt = NO;
    id lastFilter = self.lastOutput;

//    if(logIt)
//    {
//        DLog(@" ");
//        DLog(@" ");
//
//        DLog(@"CLEAN UP-------------------");
//        DLog(@" ");
//
//        DLog(@"First Input: %@", self.firstInput);
//        DLog(@"Last Target: %@", self.lastLayerOutput);
//        DLog(@"Output: %@", lastFilter);
//        DLog(@" ");
//    }
    NSMutableArray *ls = [NSMutableArray arrayWithArray:self.allLayers];
    for (MysticFilterLayer *layer in ls) {
//        if(logIt) DLog(@"\tLayer: %@  (source: %p)", layer.option.name, layer.sourcePicture);
        
        BOOL hasFilters = NO;
        NSMutableArray *lks = [NSMutableArray array];
        [lks addObjectsFromArray:layer.filters.allKeys];
        if(!lks.count || layer.sourcePicture)
        {
            hasFilters = YES;
            if(layer.sourcePicture)
            {
                hasFilters = [self filter:layer.sourcePicture targetOf:lastFilter];
                
//                if(logIt) DLog(@"\t\tLayer Source Targets: %@  == %@", layer.sourcePicture.targets, MBOOL(hasFilters));
            }
        }
        for (id layerFilterKey in lks) {
            id layerFilter = [layer.filters objectForKey:layerFilterKey];
            BOOL foundIt = [self filter:layerFilter targetOf:lastFilter];
            
//            if(logIt) DLog(@"\t\tFilter: %@ == %@", [[NSString stringWithFormat:@"%@ (%p)", [layerFilter class], layerFilter] stringByPaddingToLength:65 withString:@" " startingAtIndex:0 ], MBOOL(foundIt));

            if(foundIt)
            {
                hasFilters = YES;
            }
            else
            {
//                if(logIt) DLog(@"\t\t\tRemove Layer Filter: %@ (%p)", [layerFilter class], layerFilter);

                [layer removeFilterForKey:layerFilterKey];
            }
            
        }
        if(!hasFilters)
        {
            [layer cleanAll];
//            DLog(@"\t\tRemove Layer: %@", layer.option.name);

//            [self removeLayer:layer];
        }
    }
    
    [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
    
//    if(logIt)
//    {
//        DLog(@" ");
//        DLog(@"Done cleaning --------------------");
//        DLog(@" ");
//        DLog(@" ");
//
//    }
    
    
}

- (NSString *) logTargetsTree;
{
    ALLog(@"log tree error:", @[@"filter", MObj(self.filter),
                                @"last output", MObj(self.lastOutput),
                                @"first", MObj(self.firstInput),
                                @"layers", MObj(self.allLayers),
                                ]);
    return self.allLayers.count ? [MysticFilterDebug logTargets:self.firstInput depth:0] : @"Output: none";
}
- (id) lastLayerOutput;
{
    return [(MysticFilterLayer *)self.allLayers.lastObject lastOutput];
}
- (id) firstInput;
{
    if([self.filter respondsToSelector:@selector(targets)] && self.filter.targets.count)
    {
        for (id target in self.filter.targets) {
            if(![target isKindOfClass:[GPUImageView class]])
            {
                return self.filter;
            }
        }
    }
    id lastLayerFirstInput = [(MysticFilterLayer *)self.allLayers.lastObject firstOutput];
    if(!lastLayerFirstInput)
    {
        for (MysticFilterLayer *l in self.allLayers) {
            id l2 = l.firstOutput;
            if(l2)
            {
                lastLayerFirstInput = l2;
            }
        }
    }
    return lastLayerFirstInput ? lastLayerFirstInput : self.lastOutput;
}

- (MysticFilterLayer *) layerFromOption:(PackPotionOption *)opt tag:(NSString *)layerTag;
{
    if(!opt)
    {
        ErrorLog(@"There is no option for layer");
        return nil;
    }
    layerTag = [MysticFilterManager optionTag:opt layerTag:layerTag];
    if(!self.allLayers.count) return [MysticFilterLayer layerFromOption:opt tag:layerTag];
    
    for (MysticFilterLayer *aLayer in self.allLayers)
    {
        if(aLayer.option && [aLayer.option isEqual:opt])
        {
            if(!layerTag || (layerTag && aLayer.tag && [layerTag isEqualToString:aLayer.tag]))
            {
                return aLayer;
            }
        }
    }
    return [MysticFilterLayer layerFromOption:opt tag:layerTag];
}



- (NSArray *) layersForOption:(MysticOption *)option;
{
    NSMutableArray *__layers = [NSMutableArray array];
    if(option)
    {
        for (MysticFilterLayer *layer in self.allLayers) {
            if(layer.option && [layer.option isEqual:option])
            {
                [__layers addObject:layer];
            }
        }
    }
    return __layers;
}







- (BOOL) usesSameShadersAs:(MysticFilterManager *)otherManager;
{
    return self.shader && otherManager.shader ? [self.shader isEqual:otherManager.shader] : NO;
}

- (void) removeAllLayers;
{
    NSArray *oldLayers = [[NSArray arrayWithArray:self.allLayers] retain];
    NSDictionary *oldKeys = [[NSDictionary dictionaryWithDictionary:self.layerKeys] retain];
    [self.layerKeys removeAllObjects];
    [self.allLayers removeAllObjects];
    [oldKeys autorelease];
    [oldLayers autorelease];
}


- (void) setFilter:(MysticImageFilter *)filter;
{
    if(_filter) [_filter release], _filter=nil;
    if(filter) _filter = [filter retain];
    
    
}



- (void) removeLayersExcept:(NSArray *)exceptions;
{
    
    if(!exceptions)
    {
        [self removeAllLayers];
        return;
    }
    exceptions = [exceptions isKindOfClass:[NSArray class]] ? exceptions : [NSArray arrayWithObject:exceptions];
    NSMutableArray *_newLayers = [NSMutableArray array];
    NSMutableDictionary *_newLayerKeys = [NSMutableDictionary dictionary];

    NSArray *_layers = [NSArray arrayWithArray:self.allLayers];
    for (MysticFilterLayer *cl in _layers) {
        if([exceptions containsObject:cl])
        {
            cl.index = _newLayers.count;
            [_newLayers addObject:cl];
            [_newLayerKeys setObject:[NSIndexPath indexPathForItem:_newLayers.count-1 inSection:0] forKey:[MysticFilterManager optionTag:cl.option]];
        }
    }
    self.allLayers = _newLayers;
    self.layerKeys = _newLayerKeys;
}




- (MysticFilterLayer *) recycledLayerForOption:(PackPotionOption *)option;
{
    MysticFilterLayer *layer = [self layerForOption:option];
    if(!layer) layer = [MysticFilterLayer layerFromOption:option];
    return layer;
}



- (BOOL) containsLayer:(MysticFilterLayer *)layer;
{
    return layer ? [self.allLayers containsObject:layer] : NO;
}



- (MysticFilterLayer *) removeLayer:(MysticFilterLayer *)removeLayer;
{

    if(!removeLayer) return nil;
    NSInteger indexPath = [self indexForOption:removeLayer.option];
    if(indexPath == NSNotFound) return nil;
    NSMutableArray *_layers = [NSMutableArray arrayWithArray:self.allLayers];
    if(_layers.count > indexPath)
    {
        MysticFilterLayer *l = [_layers objectAtIndex:indexPath];
        if(l)
        {
            [l retain];
            [_layers removeObjectAtIndex:indexPath];
            self.allLayers = _layers;
            return [l autorelease];
            
        }
    }
    return nil;
    
}




- (void) addLayers:(NSArray *)layersToAdd;
{
    if(!layersToAdd || !layersToAdd.count) return;
    for (MysticFilterLayer *l in layersToAdd) {
        [self addLayer:l];
    }
}




- (void) addLayer:(MysticFilterLayer *)layer;
{
    
    if(!layer || ![layer isKindOfClass:[MysticFilterLayer class]])
    {
        ErrorLog(@"trying to add bad layer: %@", layer);
        
        
        
        return;
    }
    if([self.allLayers containsObject:layer] || [self.layerKeys objectForKey:layer.tag])
    {
        FiltersLog(@"Layer already in layers for option: %@", layer.tag);
        return;
    };
    layer.index = self.allLayers.count;
    layer.added = YES;
    NSArray *siblingLayers = [[MysticOptions current].filters layersForOption:layer.option];
    layer.siblings = siblingLayers.count ? [NSArray arrayWithArray:siblingLayers] : nil;
    self.sourceNeedsProcess = YES;
    [self.allLayers addObject:layer];
    [self.layerKeys setObject:[NSIndexPath indexPathForItem:self.allLayers.count-1 inSection:0] forKey:layer.tag];
    

}




- (NSInteger) indexForOption:(MysticOption *)option;
{
    return [self indexForOption:option tag:nil];
}
- (NSInteger) indexForOption:(MysticOption *)option tag:(NSString *)layerTag;
{
    
    NSIndexPath *indexPath = [self.layerKeys objectForKey:[MysticFilterManager optionTag:(id)option layerTag:layerTag]];
    if(!indexPath)
    {
        NSString *optTag = [MysticFilterManager optionTag:(id)option layerTag:nil];
        for (NSString *lKey in self.layerKeys) {
            if([lKey hasPrefix:optTag])
            {
                indexPath = [self.layerKeys objectForKey:lKey];
                break;
            }
        }
    }
    return indexPath ? indexPath.item : NSNotFound;
}



- (MysticFilterLayer *)layerForOption:(MysticOption *)option;
{
    return [self layerForOption:option tag:nil];
}




- (MysticFilterLayer *)layerForOption:(MysticOption *)option tag:(NSString *)layerTag;
{
    if(!option) return nil;
    NSInteger indexPath = [self indexForOption:option tag:layerTag];
    MysticFilterLayer *layer = nil;
//    if(indexPath == NSNotFound) layer = nil;
    layer = indexPath != NSNotFound && self.allLayers.count > indexPath ? [self.allLayers objectAtIndex:indexPath] : nil;
    if(layer && layerTag && ![layerTag isEqualToString:layer.tag]) layer = nil;
    if(!layer)
    {
        for (MysticFilterLayer *l in self.allLayers) {
            if(l.option && [l.option isEqual:option])
            {
                layer = l; break;
            }
        }
    }
    return layer;
}





- (BOOL) processSourceImage;
{
    return [self processSourceImageWithCompletion:nil];
}
- (BOOL) processSourceImageWithCompletion:(MysticBlock)finished;
{
//    if(self.sourceNeedsProcess)
//    {
        __unsafe_unretained __block MysticBlock __finished = finished ? Block_copy(finished) : nil;
        [self.sourcePicture processImageWithCompletionHandler:__finished ? ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                __finished();
                Block_release(__finished);
            });

        } : ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *theName = MYSTIC_REFRESH_COMPLETE_NOTIFICATION;
                [[NSNotificationCenter defaultCenter] postNotificationName:theName object:nil];
            });
            
        }];
        
//        self.sourceNeedsProcess = NO;
        return YES;
//    }
//    return NO;
}




- (void) refresh:(PackPotionOption *)option;
{
    [self refresh:option completion:nil];
}
- (void) refresh:(PackPotionOption *)option completion:(MysticBlock)completed;
{
    for (MysticFilterLayer *layer in self.allLayers)
    {
//        DLog(@"refresh layer: %@ -> %@  : %@", MBOOL(layer.requiresRefresh && !layer.option.ignoreActualRender), MBOOL(!layer.option.ignoreActualRender), layer.debugDescription);
//        DLog(@"refresh layer filters: %@", layer.filterKeysDescription);
        if(layer.requiresRefresh && !layer.option.ignoreActualRender) [layer refresh:layer.option];
        else if(!layer.option.ignoreActualRender) [self.filter disableFrameCheck:layer.option.shaderIndex];
    }
    [self.filter updateFrame:completed];
}


+ (NSString *) optionTag:(PackPotionOption *)_option;
{
    return [self optionTag:_option layerTag:nil];
}
+ (NSString *) optionTag:(PackPotionOption *)option layerTag:(NSString *)layerTag;
{
    NSString *o = [NSString stringWithFormat:@"%@<%p>", option.tag, option];
    return !layerTag || [layerTag isEqualToString:o] ? o : [NSString stringWithFormat:@"%@%@", o, layerTag];
}



@end

