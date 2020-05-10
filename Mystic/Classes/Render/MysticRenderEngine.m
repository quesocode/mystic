//
//  MysticRenderEngine.m
//  Mystic
//
//  Created by travis weerts on 8/20/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticRenderEngine.h"
#import "MysticFilterManager.h"
#import "UserPotion.h"
#import "MysticOptions.h"

@implementation MysticRenderEngine


+ (GPUImageOutput<GPUImageInput> *) adjustTarget:(GPUImageOutput<GPUImageInput> *)filter effect:(PackPotionOption *)effect layer:(MysticFilterLayer *)layer options:(MysticOptions *)options context:(NSDictionary *)context;
{
    NSDictionary *adjustments = effect.adjustmentsAndRefreshingAdjustments;
    if((adjustments && ![(NSArray *)[adjustments objectForKey:@"keys"] count] ) || !adjustments)
    {
        return filter;
    }
    
    GPUImageOutput<GPUImageInput> *firstFilter = [filter retain];
    
    MysticFilterOption filterOption = MysticFilterOptionAuto;
    if(context && [context objectForKey:@"options"]) filterOption = [[context objectForKey:@"options"] integerValue];
    NSArray *filterTypes = [effect filterTypesMatchingOptions:filterOption];
    NSMutableArray *filters = [NSMutableArray array];
    for (NSNumber *key in filterTypes)
    {
        filter = [MysticRenderEngine initFilter:[key integerValue] target:filter effect:effect layer:layer options:options];
        [filters addObject:filter];
        
    }
    if(filters.count > 10)
    {
        BOOL didAllocGroup = NO;
        MysticGPUImageFilterGroup *group = [self filterForKey:MysticLayerKeyGroup filterType:MysticObjectTypeUnknown effect:effect layer:layer];
        if(group)
        {
            [group removeAllTargets];
            [group removeAllFilters];
            group.initialFilters = nil;
            group.terminalFilter = nil;
        }
        else didAllocGroup = YES;
        
        group =  group ? group : [[MysticGPUImageFilterGroup alloc] init];
        for (GPUImageOutput<GPUImageInput> *member in filters) {
            [group addFilter:member];
        }
        
        GPUImageOutput<GPUImageInput> *prevMember = nil;
        NSInteger location = 0;
        for (GPUImageOutput<GPUImageInput> *member in filters) {
            if(![member isEqual:filters.firstObject])
            {
                [prevMember addTarget:member atTextureLocation:location];
            }
            prevMember = member;
            location++;
        }
        
        group.initialFilters = filters;
        group.terminalFilter = filters.lastObject;
        [firstFilter addTarget:group];
        
        filter = [group autorelease];
        [group useNextFrameForImageCapture];
        if(layer && didAllocGroup) [layer setFilter:filter forKey:MysticLayerKeyGroup];
    }
    [firstFilter autorelease];
    return filter;
}

+ (GPUImageOutput<GPUImageInput> *) initFilter:(MysticObjectType)filterType target:(GPUImageOutput<GPUImageInput> *)filter effect:(PackPotionOption *)effect layer:(MysticFilterLayer *)layer options:(MysticOptions *)options;
{
    GPUImageFilter *initFilter = nil;
    BOOL didAllocFilter = NO;
    layer = layer ? layer : effect.layer;
    BOOL hasInputFilter = filter != nil;
    CGScale scaledSize = CGScaleOfSizes(options.size,[UserPotion potion].previewSize);
//    DLog(@"initFilter: %@ -> %@ -> %@ -> %@", MysticObjectTypeToString(filterType), SLogStr(options.size), SLogStr([UserPotion potion].previewSize), sc(scaledSize));

    switch (filterType) {

        case MysticSettingVignette:
        {
            
            GPUImageVignetteFilter *effectFilter = [self filterForKey:MysticLayerKeySettingVignette filterType:filterType effect:effect layer:layer];
            if(effectFilter)
            {
                
                [effectFilter removeAllTargets];
            }
            else
            {
                
                didAllocFilter = YES;

                RenderEngineLog(@"alloc adjustment layer: %@ for: %@", MyString(filterType), MyString(effect.type));
            }

            effectFilter = effectFilter ? effectFilter : [[GPUImageVignetteFilter alloc] init];
            effectFilter.vignetteStart = effect.vignetteStart;
            effectFilter.vignetteEnd = effect.vignetteEnd;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingVignette ];
            
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingUnsharpMask:
        {
            GPUImageUnsharpMaskFilter *effectFilter = [self filterForKey:MysticLayerKeySettingUnsharpmask filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;


            effectFilter = effectFilter ? effectFilter : [[GPUImageUnsharpMaskFilter alloc] init];
            effectFilter.blurRadiusInPixels = kUnsharpMaskPixelSize * scaledSize.scale;
            effectFilter.intensity = effect.unsharpMask;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingUnsharpmask ];
            
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingHalfTone:
        {
            GPUImageHalftoneFilter *effectFilter = [self filterForKey:MysticLayerKeySettingHalftone filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            
            
            effectFilter = effectFilter ? effectFilter : [[GPUImageHalftoneFilter alloc] init];
            effectFilter.fractionalWidthOfAPixel = effect.halftonePixelWidth;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingHalftone];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingPixellate:
        {
            GPUImagePixellateFilter *effectFilter = [self filterForKey:MysticLayerKeySettingPixellate filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            
            
            effectFilter = effectFilter ? effectFilter : [[GPUImagePixellateFilter alloc] init];
            effectFilter.fractionalWidthOfAPixel = effect.pixellatePixelWidth;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingPixellate];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        
        case MysticSettingToon:
        {
            GPUImageSmoothToonFilter *effectFilter = [self filterForKey:MysticLayerKeySettingToon filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            effectFilter = effectFilter ? effectFilter : [[GPUImageSmoothToonFilter alloc] init];
            effectFilter.threshold = effect.toonThreshold;
            effectFilter.blurRadiusInPixels = 2* scaledSize.scale;

            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingToon];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingSketchFilter:
        {
            GPUImageSketchFilter *effectFilter = [self filterForKey:MysticLayerKeySettingSketchFilter filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            effectFilter = effectFilter ? effectFilter : [[GPUImageSketchFilter alloc] init];
            effectFilter.edgeStrength = effect.sketchStrength;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingSketchFilter];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingBlurCircle:
        {
            GPUImageGaussianSelectiveBlurFilter *effectFilter = [self filterForKey:MysticLayerKeySettingBlurCircle filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            effectFilter = effectFilter ? effectFilter : [[GPUImageGaussianSelectiveBlurFilter alloc] init];
            effectFilter.blurRadiusInPixels = effect.blurCircleRadius* scaledSize.scale;
            effectFilter.excludeCircleRadius = effect.blurCircleExcludeRadius;
            effectFilter.excludeBlurSize = effect.blurCircleExcludeSize;
            effectFilter.excludeCirclePoint = effect.blurCirclePoint;
            effectFilter.aspectRatio = effect.blurCircleAspectRatio;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingBlurCircle];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingBlurZoom:
        {
            GPUImageZoomBlurFilter *effectFilter = [self filterForKey:MysticLayerKeySettingBlurZoom filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            effectFilter = effectFilter ? effectFilter : [[GPUImageZoomBlurFilter alloc] init];
            effectFilter.blurSize = effect.blurZoomSize* scaledSize.scale;
            effectFilter.blurCenter = effect.blurZoomCenter;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingBlurZoom];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingBlurMotion:
        {
            GPUImageMotionBlurFilter *effectFilter = [self filterForKey:MysticLayerKeySettingBlurMotion filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            effectFilter = effectFilter ? effectFilter : [[GPUImageMotionBlurFilter alloc] init];
            effectFilter.blurSize = effect.blurMotionSize* scaledSize.scale;
            effectFilter.blurAngle = effect.blurMotionAngle;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingBlurMotion];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingBlur:
        case MysticSettingBlurGaussian:
        {
            GPUImageGaussianBlurFilter *effectFilter = [self filterForKey:MysticLayerKeySettingBlur filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            effectFilter = effectFilter ? effectFilter : [[GPUImageGaussianBlurFilter alloc] init];
            effectFilter.blurRadiusInPixels = effect.blurRadius* scaledSize.scale;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingBlur];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingDistortPinch:
        {
            id filterSetting = MysticLayerKeySettingDistortPinch;
            GPUImagePinchDistortionFilter *effectFilter = [self filterForKey:filterSetting filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            effectFilter = effectFilter ? effectFilter : [[GPUImagePinchDistortionFilter alloc] init];
            effectFilter.radius = effect.pinchRadius;
            effectFilter.center = effect.pinchCenter;
            effectFilter.scale = effect.pinchScale;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:filterSetting];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingDistortSwirl:
        {
            id filterSetting = MysticLayerKeySettingDistortSwirl;
            GPUImageSwirlFilter *effectFilter = [self filterForKey:filterSetting filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            effectFilter = effectFilter ? effectFilter : [[GPUImageSwirlFilter alloc] init];
            effectFilter.radius = effect.swirlRadius;
            effectFilter.center = effect.swirlCenter;
            effectFilter.angle = effect.swirlAngle;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:filterSetting];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingDistortBuldge:
        {
            id filterSetting = MysticLayerKeySettingDistortBuldge;
            GPUImageBulgeDistortionFilter *effectFilter = [self filterForKey:filterSetting filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            effectFilter = effectFilter ? effectFilter : [[GPUImageBulgeDistortionFilter alloc] init];
            effectFilter.radius = effect.buldgeRadius;
            effectFilter.center = effect.buldgeCenter;
            effectFilter.scale = effect.buldgeScale;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:filterSetting];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingDistortGlassSphere:
        {
            id filterSetting = MysticLayerKeySettingDistortGlassSphere;
            GPUImageGlassSphereFilter *effectFilter = [self filterForKey:filterSetting filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            effectFilter = effectFilter ? effectFilter : [[GPUImageGlassSphereFilter alloc] init];
            effectFilter.radius = effect.sphereRadius;
            effectFilter.center = effect.sphereCenter;
            effectFilter.refractiveIndex = effect.sphereRefractiveIndex;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:filterSetting];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        
        case MysticSettingDistortStretch:
        {
            id filterSetting = MysticLayerKeySettingDistortStretch;
            GPUImageStretchDistortionFilter *effectFilter = [self filterForKey:filterSetting filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            effectFilter = effectFilter ? effectFilter : [[GPUImageStretchDistortionFilter alloc] init];
            effectFilter.center = effect.stretchCenter;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:filterSetting];
            if(didAllocFilter) [effectFilter release];
            break;
        }
        case MysticSettingPosterize:
        {
            GPUImagePosterizeFilter *effectFilter = [self filterForKey:MysticLayerKeySettingPosterize filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;
            
            
            effectFilter = effectFilter ? effectFilter : [[GPUImagePosterizeFilter alloc] init];
            effectFilter.colorLevels = effect.posterizeLevels;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingPosterize];
            if(didAllocFilter) [effectFilter release];
            break;
        }

        case MysticSettingTiltShift:
        {
            GPUImageTiltShiftFilter *effectFilter = [self filterForKey:MysticLayerKeySettingTiltShift filterType:filterType effect:effect layer:layer];
            if(effectFilter) [effectFilter removeAllTargets];
            else didAllocFilter = YES;

            effectFilter = effectFilter ? effectFilter : [[GPUImageTiltShiftFilter alloc] init];
            effectFilter.blurRadiusInPixels = effect.tiltShiftBlurSizeInPixels * scaledSize.scale;
            [effectFilter setTopFocusLevel:effect.tiltShiftTop];
            [effectFilter setBottomFocusLevel:effect.tiltShiftBottom];
            [effectFilter setFocusFallOffRate:effect.tiltShiftFallOff];
            
            
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingTiltShift ];
            
            if(didAllocFilter) [effectFilter release];
            break;
        }

        case MysticSettingSharpness:
        {
            GPUImageSharpenFilter *effectFilter = [self filterForKey:MysticLayerKeySettingSharpness filterType:filterType effect:effect layer:layer];
            if(effectFilter)[effectFilter removeAllTargets];
            else didAllocFilter = YES;


            effectFilter = effectFilter ? effectFilter : [[GPUImageSharpenFilter alloc] init];
            effectFilter.sharpness = effect.sharpness;
            if(filter) [filter addTarget:effectFilter];
            filter = effectFilter;
            
            if(layer && didAllocFilter) [layer setFilter:filter forKey:MysticLayerKeySettingSharpness ];
            
            if(didAllocFilter) [effectFilter release];
            break;
        }
            
        default: break;
    }
    return filter;
}

+ (id) filterForKey:(id)filterKey filterType:(MysticObjectType)filterType effect:(PackPotionOption *)effect layer:(MysticFilterLayer *)layer;
{
    if(layer) return [layer filterForKey:filterKey];
    if(effect) return [effect filter:filterKey];
    return nil;
}
@end
