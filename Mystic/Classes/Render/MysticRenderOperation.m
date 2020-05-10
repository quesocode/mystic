//
//  MysticRenderOperation.m
//  Mystic
//
//  Created by travis weerts on 9/19/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import "MysticRenderOperation.h"
#import "MysticEffectsManager.h"
#import "NSString+Mystic.h"
//#import "MysticShaderString.h"
#import "MysticLabelsView.h"
#import "MysticConstants.h"
#import "UserPotion.h"
#import "MysticRenderEngine.h"
#import "MysticCacheImage.h"
#import "MysticEmptyFilter.h"
#import "MysticOneInputFilter.h"
#import "MysticTwoInputFilter.h"
#import "MysticThreeInputFilter.h"
#import "MysticFourInputFilter.h"
#import "MysticFiveInputFilter.h"
#import "MysticSixInputFilter.h"
#import "MysticOptionsCacheManager.h"
#import "MysticController.h"
#import "MysticShader.h"
#import "MysticFillFilter.h"

@interface MysticRenderOperation ()
{
    BOOL _isFinished, _isExecuting;
}

@end



@implementation MysticRenderOperation

static BOOL hasRenderedOnce = NO;
@synthesize sourceImage=_sourceImage, options=_options, index=_index, completedBlock=_completedBlock, progressBlock=_progressBlock, renderedImage=_renderedImage, lastOutput=_lastOutput, renderOptions=_renderOptions, shouldRecycle=_shouldRecycle, finishedPassBlock=_finishedPassBlock;

- (void) dealloc;
{
//    RenderProcessLog(@"RENDER PROCESS #%d: DEALLOC\r\n\r\n\r\n\r\n", self.index);
    [_renderedImage release];
    [_lastOutput release];
    [_sourceImage release];
    Block_release(_finishedPassBlock);
    Block_release(_completedBlock);
    Block_release(_progressBlock);
    [_renderOptions release];
    [_options release];
    [super dealloc];
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        _shouldRecycle = NO;
        _useOptionsAsIs = NO;
    }
    return self;
}
- (BOOL) isConcurrent; { return YES; }
- (MysticOptions *) lastRenderedOptions;
{
    return _isFinished ? nil : [MysticEffectsManager manager].options;
}
- (MysticFilterManager *) lastFilters;
{
    return self.lastRenderedOptions && self.lastRenderedOptions.hasFilters ? self.lastRenderedOptions.filters : nil;
}
- (double) threadPriority;
{
    return 1.0;
}
- (NSOperationQueuePriority) queuePriority;
{
    return NSOperationQueuePriorityVeryHigh;
}
- (void) cancel;
{
    
    RenderProcessLog(@"RENDER PROCESS #%d: Cancelling", (int)self.index);
//    if(self.completedBlock) self.completedBlock(nil, nil, nil, YES);
    [super cancel];
    self.renderOptions.isCancelled = YES;
    self.options.isCancelled = YES;
    self.threadPriority = 0.1f;

}

- (void)finish
{
//    RenderProcessLog(@"RENDER PROCESS #%d: Finished", self.index);
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];

    self.threadPriority = 0.3f;
    
    UIImage *img = [self.renderedImage retain];
    id lo = [self.renderOptions.filters.lastOutput retain];
    id o = [self.renderOptions retain];
    BOOL c = self.isCancelled;
    
    if(self.completedBlock) self.completedBlock(img, lo, o, c);

    self.renderedImage = nil;
//    self.lastOutput = nil;
    self.completedBlock = nil;
    self.finishedPassBlock=nil;
    self.progressBlock=nil;
    [img autorelease];
    [lo autorelease];
    [o autorelease];

    
    if([self isCancelled]) return;

}

- (void) start;
{
    @autoreleasepool {

        self.threadPriority = 1.0f;
        
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];
        BOOL useRenderOptionsAsIs = self.useOptionsAsIs;
        __unsafe_unretained __block id _imageView = self.options.imageView;
        __unsafe_unretained __block  MysticRenderOperation *weakSelf = self;
        UIImage *rimg = nil;
        MysticOptions *beforeOptions = nil;
        NSString *newTag, *_processTag;
        UIImage *sourceImage = [self.sourceImage retain];
        CGSize renderSize = self.options.size;
        renderSize = CGSizeGreater(renderSize, [MysticUser user].maximumRenderSize) ? CGSizeConstrain(renderSize, [MysticUser user].maximumRenderSize) : renderSize;

        RenderProcessLog(@"RENDER PROCESS #%d: Settings: %d  |  %2.1fx%2.1f ----------------------------", (int)self.index, self.options.settings, renderSize.width, renderSize.height);

        

        if(weakSelf.options.count)
        {
            
            
            weakSelf.renderOptions = [self.options render:self.renderOptions];
            weakSelf.renderOptions.isCancelled = NO;
            
//            if(NO && !weakSelf.renderOptions.requiresCompleteReload)
//            {
//                
//                MysticOptions *unchangedSubOptions = weakSelf.renderOptions.unchangedSubsetOfOptions;
//                MysticOptions *newRenderOptions = nil;
//                weakSelf.usingSubSetOptions = NO;
//                if(unchangedSubOptions)
//                {
//                    
//                    UIImage *unChangedSourceImage = nil;
//                    NSString *sourceImagePath = nil;
//                    if([[MysticOptionsCacheManager sharedManager] hasCacheForOptions:unchangedSubOptions])
//                    {
//                        unChangedSourceImage = [[MysticOptionsCacheManager sharedManager] cachedImageForOptions:unchangedSubOptions];
//                        if(unChangedSourceImage)
//                        {
//                            sourceImagePath = [[MysticOptionsCacheManager sharedManager] cachedImagePathForOptions:unchangedSubOptions];
//                            [sourceImage release];
//                            sourceImage = [[unChangedSourceImage retain] autorelease];
//                            newRenderOptions = [weakSelf.renderOptions copyWithOptionsInRange:NSMakeRange(unchangedSubOptions.count, weakSelf.renderOptions.sortedRenderOptions.count - unchangedSubOptions.count)];
//                            newRenderOptions.parentOptions = (id)weakSelf.renderOptions;
//                        }
//                    }
//                    else
//                    {
//                        // create a new manager object with preset passes
//                        useRenderOptionsAsIs = YES;
//                        
//                        NSMutableArray *newPasses = [NSMutableArray array];
//                        if(unchangedSubOptions.numberOfInputTextures > MYSTIC_PROCESS_LAYERS_PER_PASS)
//                        {
//                            MysticOptionsManager *unchangedSubOptionsManager = [MysticOptionsManager managerWithOptions:unchangedSubOptions];
//                            [newPasses addObjectsFromArray:unchangedSubOptionsManager.passes];
//                        }
//                        else
//                        {
//                            [newPasses addObject:unchangedSubOptions];
//                        }
//                        
//                        MysticOptions *changedSubOptions = weakSelf.renderOptions.changedSubsetOfOptions;
//                        if(changedSubOptions)
//                        {
//                            MysticOptionsManager *changedSubOptionsManager = [MysticOptionsManager managerWithOptions:changedSubOptions];
//                            [newPasses addObjectsFromArray:changedSubOptionsManager.passes];
//                        }
//                        
//                        newRenderOptions = (id)[[MysticOptionsManager managerWithOptions:weakSelf.renderOptions passes:newPasses] retain];
//                    }
//
//                    
//                    if(newRenderOptions) {
//                        weakSelf.usingSubSetOptions = YES;
//                        weakSelf.renderOptions = newRenderOptions;
//                        [newRenderOptions release];
//                    }
//                    
//                    
//                }
//            }
//            

            
            // if not source image is specified look for a rendered one
            if(!sourceImage)
            {
                [sourceImage release];
                UIImage *rimg = nil;
                BOOL renderOriginal = NO;
                if([self.renderOptions isEnabled:MysticRenderOptionsOriginal] || [self.renderOptions isEnabled:MysticRenderOptionsSource])
                {
                    renderOriginal = YES;
                }
                else
                {
                    rimg= [[UserPotion potion] imageForRenderSize:renderSize];
                }
                sourceImage = rimg ? rimg : [UserPotion potion].sourceImage;
            }
            [sourceImage retain];
            

            
            
            RenderDebugLog(@"RENDER PROCESS #%d: Rendering %d effects <%p>...", (int)self.index, (int)self.renderOptions.count, self.renderOptions);

            
            
            
            [weakSelf.renderOptions load:weakSelf.options.settings progress:weakSelf.progressBlock ready:^(MysticOptions *effectsManager){
                
                
                if([weakSelf isCancelled]) return;
                
                
                MysticBlockImageObjOptions processFinished = ^(UIImage *image, id obj, MysticOptions *lastOptions, BOOL pCancelled)
                {
                    if([weakSelf isCancelled]) return;
                    __unsafe_unretained __block MysticOptions * __lastOptions = lastOptions ? lastOptions : nil;
                    __unsafe_unretained __block UIImage * __image = image ? [image retain] : nil;
                    __block BOOL wasProcessed = NO;
                   
                    if(_imageView && obj)
                    {
                        if([MysticOptions current])
                        {
                            [(GPUImageOutput<GPUImageInput> *)[MysticOptions current].filters.lastOutput removeAllTargets];
                        }
                        [(GPUImageOutput<GPUImageInput> *)obj addTarget:_imageView];
                    }
                    lastOptions.filters.imageView = _imageView;
                    [MysticEffectsManager setOptions:__lastOptions];
                    [[MysticEffectsManager options] liveTargetOptions:__lastOptions];
                   
                    if(__lastOptions.hasChanged && (__lastOptions.filters.sourceNeedsProcess || (__lastOptions.settings & MysticRenderOptionsForceProcess)))
                    {
                        RenderDebugLog(@"RENDER PROCESS #%d: filters processSourceImageWithCompletion", (int)weakSelf.index);
                        __lastOptions.filters.sourceNeedsProcess = YES;
                        if(obj && [obj respondsToSelector:@selector(useNextFrameForImageCapture)] && [__lastOptions isEnabled:MysticRenderOptionsSaveImageOutput])
                        {
                            [obj performSelector:@selector(useNextFrameForImageCapture)];
                        }
                        @autoreleasepool {
                            wasProcessed = [__lastOptions.filters processSourceImageWithCompletion:^{
                                if(![weakSelf isCancelled])
                                {
                                    [[MysticOptionsCacheManager sharedManager] processQueue];
                                    weakSelf.renderedImage = __image;
                                    [weakSelf finish];
                                    hasRenderedOnce = YES;
                                    [__image release];
                                };
                            }];
                        }
                    }
                    if(!wasProcessed && ![weakSelf isCancelled])
                    {
                        [[MysticOptionsCacheManager sharedManager] processQueue];
                        weakSelf.renderedImage = __image;
                        [weakSelf finish];
                        hasRenderedOnce = YES;
                        [__image release];
                        
                    }
                };
                
                
    #pragma mark - Setup Final Options to be rendered (Manager or not)
                
                
                [[MysticOptionsCacheManager sharedManager] suspendQueue:YES];
                [MysticEffectsManager manager].renderedOptions.isLive = NO;
                MysticOptions *renderOptionsObj = nil;
                
                if(useRenderOptionsAsIs)
                {
                    renderOptionsObj = weakSelf.renderOptions;
                }
                else if(weakSelf.renderOptions.numberOfInputTextures > MYSTIC_PROCESS_LAYERS_PER_PASS)
                {
                    if(![weakSelf.renderOptions isKindOfClass:[MysticOptionsManager class]])
                    {
                        renderOptionsObj = [MysticOptionsManager managerWithOptions:weakSelf.renderOptions];
                    }
                    else
                    {
                        renderOptionsObj = weakSelf.renderOptions;
                        [(MysticOptionsManager *)renderOptionsObj resetManager];
                    }
                }
                else
                {
                    renderOptionsObj = weakSelf.renderOptions;
                    if([weakSelf.renderOptions isKindOfClass:[MysticOptionsManager class]])
                    {
                        [(MysticOptionsManager *)renderOptionsObj resetManager];
                    }
                }
                renderOptionsObj.size = renderSize;

                
                if([renderOptionsObj isKindOfClass:[MysticOptionsManager class]] && [(MysticOptionsManager *)renderOptionsObj numberOfPasses] > 1)
                {
                    __unsafe_unretained __block MysticBlockImageObjOptions _processFinished = Block_copy(processFinished);
                    MysticOptionsManager *renderOptionsObjManager = (MysticOptionsManager *)renderOptionsObj;
                    [weakSelf renderPass:sourceImage size:renderSize view:_imageView effects:[renderOptionsObjManager nextPass] complete:^(UIImage *__image, id __obj, MysticOptions * __options, BOOL __cancelled) {
                        _processFinished(__image, __obj, __options, __cancelled); Block_release(_processFinished);
                    }];
                }
                else
                {
                    __unsafe_unretained __block MysticBlockImageObjOptions _processFinished = Block_copy(processFinished);
                    __unsafe_unretained __block UIImage *__sourceImage = [sourceImage retain];
                    
                    
                    [weakSelf render:sourceImage size:renderSize view:_imageView effects:renderOptionsObj complete:^(UIImage *__image, id __obj, MysticOptions * __options, BOOL __cancelled) {
                        
                        _processFinished(__image, __obj, __options, __cancelled);
                        Block_release(_processFinished);
                        
                        if(__options)
                        {
                            
                            if(weakSelf.usingSubSetOptions)
                            {
                                __options.tag = __options.parentOptions.tag;
                                __options.sourceImage = __sourceImage;
                                
                            }
  
                            
                        }
                        
                        [__sourceImage release];
                    }];
                }
                [sourceImage release];
            }];
        }
        else
        {
            RenderProcessLog(@"RenderProcessOperation: ERROR: No Options need rendering: %@", self.options.fullDescription);

            
            if(weakSelf.options.totalCount) [weakSelf finish];
            else
            {
                if(!sourceImage)
                {
                    UIImage *rimg = [[UserPotion potion] imageForRenderSize:renderSize];
                    CGSize rsize = [MysticImage sizeInPixels:rimg];
                    [sourceImage release];
                    sourceImage = (renderSize.width <= rsize.width && renderSize.height <= rsize.height) ? rimg : [UserPotion potion].sourceImage;
                    [sourceImage retain];
                }
                

                
                [weakSelf render:sourceImage size:renderSize view:_imageView effects:self.options complete:^(UIImage *image, id obj, MysticOptions *theOptions, BOOL _isCancelled) {
                    
                    if(obj) [(GPUImageOutput<GPUImageInput> *)obj addTarget:_imageView];
                    if(theOptions.filters.sourcePicture) [theOptions.filters.sourcePicture processImage];

                    [weakSelf finish];
                }];
            }
            if(sourceImage) [sourceImage release];
        }
    }
}


- (BOOL) isExecuting;
{
    return _isExecuting;
}
- (BOOL) isFinished;
{
    return _isFinished;
}
- (void) setCompletedBlock:(MysticBlockImageObjOptions)value;
{
    Block_release(_completedBlock); _completedBlock=nil;
    if(value) _completedBlock = Block_copy(value);
}

- (void) setProgressBlock:(MysticBlockDownloadProgress)value;
{
    Block_release(_progressBlock); _progressBlock=nil;
    if(value) _progressBlock = Block_copy(value);
}
- (void) setFinishedPassBlock:(MysticBlockImageObjOptionsPass)value;
{
    Block_release(_finishedPassBlock); _finishedPassBlock=nil;
    if(value) _finishedPassBlock = Block_copy(value);
}



- (void) renderPass:(UIImage *)sourceImage size:(CGSize)renderSize view:(GPUImageView *)imageView effects:(MysticOptions *)effects complete:(MysticBlockImageObjOptions)completedBlock;
{
    if([self isCancelled]) return;
    __unsafe_unretained __block id finalView = imageView ? [imageView retain] : nil;
    __unsafe_unretained __block MysticRenderOperation *weakSelf = self;
    __unsafe_unretained __block MysticBlockImageObjOptions __completedBlock = completedBlock ? Block_copy(completedBlock) : nil;
    
    [self render:sourceImage size:renderSize view:finalView effects:effects complete:^(UIImage *_image, GPUImageOutput *__lastOutput, MysticOptions *_lastPassOptions, BOOL _isCancelled)
    {
        if([weakSelf isCancelled]) return;
        
        if(_lastPassOptions.settings & MysticRenderOptionsPass) [[MysticOptionsCacheManager sharedManager] cacheImage:_image forOptions:_lastPassOptions];
        
        if(weakSelf.finishedPassBlock)
        {
            weakSelf.finishedPassBlock(_image, __lastOutput, _lastPassOptions, _isCancelled, ^(UIImage *__image, id __obj, id __options, BOOL __cancelled){
                [weakSelf renderNextPass:__image size:renderSize view:finalView lastOutput:__obj effects:__options complete:__completedBlock];
                [finalView autorelease];
                if(__completedBlock) Block_release(__completedBlock);
            });
        }
        else
        {
            [weakSelf renderNextPass:_image size:renderSize view:finalView lastOutput:__lastOutput effects:_lastPassOptions complete:__completedBlock];
            [finalView autorelease];
            if(__completedBlock) Block_release(__completedBlock);
        }
    }];
}
- (void) renderNextPass:(UIImage *)image size:(CGSize)renderSize view:(GPUImageView *)imageView lastOutput:(id)lastOutput effects:(MysticOptions *)lastPassOptions complete:(MysticBlockImageObjOptions)completedBlock;
{
    if([self isCancelled]) return;
    
    __unsafe_unretained __block MysticRenderOperation *weakSelf = self;
    MysticOptions *next = [lastPassOptions.manager nextPass];
    if(next)
    {
        [weakSelf renderPass:(image?image:lastOutput) size:renderSize view:imageView effects:next complete:completedBlock];
    }
    else if(completedBlock)
    {
        if(lastPassOptions)
        {
            if(weakSelf.usingSubSetOptions)
            {
                lastPassOptions.tag = lastPassOptions.manager.tag;
                lastPassOptions.sourceImage = image;
                
            }
            if([lastPassOptions isEnabled:MysticRenderOptionsSaveImageOutput])
            {
                [[MysticOptionsCacheManager sharedManager] queueOptionsForCache:lastPassOptions];
            }
        }
        completedBlock(image, lastOutput, lastPassOptions, [weakSelf isCancelled]);
    }
    
}












- (void) render:(id)sourceInputOrImage size:(CGSize)renderSize view:(GPUImageView *)imageView effects:(MysticOptions *)effects complete:(MysticBlockImageObjOptions)completedBlock;
{
    [[self class] renderOperation:self source:sourceInputOrImage size:renderSize view:imageView effects:effects complete:completedBlock];
}


+ (void) renderOperation:(MysticRenderOperation *)_operation source:(id)sourceInputOrImage size:(CGSize)renderSize view:(GPUImageView *)imageView effects:(MysticOptions *)effects complete:(MysticBlockImageObjOptions)completedBlock;
{
//    DLogHidden(@"rendering... %p", effects);
    if([_operation isCancelled]) { RenderDebugLog(@"RENDER PROCESS #%d: Skipping is cancelled 1", (int)_operation.index); return; }
    
    UIImage *renderedImage = [sourceInputOrImage respondsToSelector:@selector(CGImage)] ? sourceInputOrImage : nil ;
    __unsafe_unretained __block GPUImageOutput<GPUImageInput> *layerFilter, *nextFilter, *filter, *lastOutput, *mainFilter;
    nextFilter = nil;
    filter = nil;
    mainFilter = nil;
    if(effects.count)
    {
        [effects updateInputs];
        effects.isLive = YES;
        NSArray *uniforms = nil;
        CGSize smallestSize = MysticSizeOriginal;
        effects.smallestTextureSize = smallestSize;
        Class imageFilterClass;
        NSMutableArray *textures = [[NSMutableArray alloc] init];
        NSArray *sortedRenderableEffects = [effects sortedRenderOptions];
        NSInteger effectIndex = 1;
        NSInteger numberOfInputs = [MysticOptions numberOfInputs:sortedRenderableEffects];
        NSInteger numberOfInputTextures = [MysticOptions numberOfInputTextures:sortedRenderableEffects];
        BOOL equalRatios;
        BOOL usedBlendedFont = NO;
        BOOL sourceRequiresRefresh = NO;
        MysticGPUImageLayerPicture *effectPicture = nil;
        MysticGPUImageSourcePicture *sourcePicture=nil;

        MysticShadersObject *shader = [MysticShadersObject shader:effects];
        PackPotionOptionSetting *settingsOption = (PackPotionOptionSetting *)[effects option:MysticObjectTypeSetting];
        PackPotionOptionSetting *sourceSettings = (PackPotionOptionSetting *)[(MysticOptions *)(effects.manager ? effects.manager : effects) option:MysticObjectTypeSetting];
        PackPotionOptionSetting *settingsOptionAfter = settingsOption && [settingsOption hasFiltersMatching:MysticFilterOptionAfterLayers] ? [settingsOption retain] : nil;
        PackPotionOptionSetting *settingsOptionBefore = settingsOption && [settingsOption hasFiltersMatching:MysticFilterOptionBeforeLayers] ? [settingsOption retain] : nil;

        settingsOption = settingsOption && settingsOption.ignoreActualRender ? nil : settingsOption;
        sourceSettings = sourceSettings && sourceSettings.ignoreActualRender ? nil : sourceSettings;

//        DLogRender(@"RENDER PROCESS #%d: Preparing settings option. Does it have a shader or use filters? SHADER: %@ Settings: %@  Before Effects: %@", (int)_operation.index, MBOOL(settingsOption.hasShader), MBOOL(settingsOption != nil), MBOOL(settingsOptionBefore != nil));
        
        settingsOption =  settingsOption && settingsOption.hasShader ? nil : settingsOption;
        sourceSettings =  sourceSettings && (!sourceSettings.hasShader || ![sourceSettings hasAdjusted:MysticSettingTransform]) ? nil : sourceSettings;
//        DLog(@"number of input textures for render: %d", (int)numberOfInputTextures);
        switch (numberOfInputTextures) {
            case 1: imageFilterClass = [MysticOneInputFilter class]; break;
            case 2: imageFilterClass = [MysticTwoInputFilter class]; break;
            case 3: imageFilterClass = [MysticThreeInputFilter class]; break;
            case 4: imageFilterClass = [MysticFourInputFilter class]; break;
            case 5: imageFilterClass = [MysticFiveInputFilter class]; break;
            case 6: imageFilterClass = [MysticSixInputFilter class]; break;
            default: filter = nil; [textures release]; return;
        }
        
//        ALLog(@"render", @[@"options", effects.description]);
        if(!mainFilter) mainFilter = shader.vertex ? [[imageFilterClass alloc] initWithVertexShaderFromString:shader.vertex fragmentShaderFromString:shader.shader] :[[imageFilterClass alloc] initWithFragmentShaderFromString:shader.shader];
        if([mainFilter respondsToSelector:@selector(applyUniformsFrom:)]) [(MysticImageFilter *)mainFilter applyUniformsFrom:effects];

        
        effects.filters.filter = (MysticImageFilter *)mainFilter;
        [effects.filters.filter forceProcessingAtSize:renderSize];
        UIImage *sourceImg = sourceInputOrImage && [sourceInputOrImage isKindOfClass:[UIImage class]] ? sourceInputOrImage : nil;
        NSMutableArray *sourceTextures = [NSMutableArray array];

        if(sourceInputOrImage && [sourceInputOrImage isKindOfClass:[UIImage class]])
        {
            sourceInputOrImage = [MysticImageSource imageWithImage:sourceInputOrImage];
            sourcePicture = [[MysticGPUImageSourcePicture alloc] initWithImage:sourceInputOrImage smoothlyScaleOutput:NO];
            [sourcePicture forceProcessingAtSize:renderSize];
            effects.filters.sourcePicture = sourcePicture;
            layerFilter = (GPUImageOutput<GPUImageInput> *)sourcePicture;
            if(settingsOptionBefore)
            {
                MysticFilterLayer *sourceLayer = [effects.filters layerFromOption:settingsOptionBefore tag:@"SettingsBefore"];
                if(sourceLayer)
                {
                    sourceLayer.isSourceLayer = YES;
                    sourceLayer.requiresRefresh = YES;
                    sourceLayer.forceRequiresRefresh = YES;
                    sourceLayer.sourcePicture = (MysticGPUImageLayerPicture *)sourcePicture;
                    layerFilter = [settingsOptionBefore addFilters:layerFilter layer:sourceLayer effects:effects context:@{@"options":@(MysticFilterOptionBeforeLayers)}];
                    [effects.filters addLayer:sourceLayer];
                    sourceRequiresRefresh = YES;
                }
                [settingsOptionBefore release];

            }
            if(sourceSettings && effects.index == 0 && ((effects.settings & MysticRenderOptionsSetupRender) || [sourceSettings hasAdjusted:MysticSettingTransform] || sourceSettings.numberOfInputTextures > 1))
            {
                MysticFilterLayer *sourceLayer = nil;
                if([sourceSettings numberOfFiltersMatchingOptions:MysticFilterOptionTransformLayers])
                {
                    sourceLayer = [effects.filters layerFromOption:sourceSettings tag:@"SettingsBefore"];
                    sourceLayer.isSourceLayer = YES;
                    sourceLayer.requiresRefresh = NO;
                    if(sourceLayer)
                    {
                        sourceLayer.sourcePicture = (MysticGPUImageLayerPicture *)sourcePicture;
                        [sourceSettings updateFiltersMatching:MysticFilterOptionTransformLayers];
                        layerFilter = [sourceSettings addFilters:layerFilter layer:sourceLayer effects:effects context:@{@"options":@(MysticFilterOptionBeforeLayers)}];
                        layerFilter = [sourceSettings addFilters:layerFilter layer:sourceLayer effects:effects context:@{@"options":@(MysticFilterOptionTransformLayers)}];
                        [effects.filters addLayer:sourceLayer];
                        sourceRequiresRefresh = YES;
                    }
                }
                
                
            }
        }
        else layerFilter = sourceInputOrImage;
        if(!layerFilter && sourcePicture)
        {
            [_operation cancel];
            if(completedBlock) { completedBlock(nil, nil, effects, YES); }
            return;
        }
        [textures addObject:@{@"location": @(0), @"filter": MNull(layerFilter ? layerFilter : sourcePicture), @"type": @"source",  @"requiresFrameRefresh": [NSNumber numberWithBool:sourceRequiresRefresh], @"textures":sourceTextures}];
        
        for (PackPotionOption *effect in sortedRenderableEffects)
        {
            if(!(![_operation isCancelled] && effect.readyForRender && !effects.isCancelled)) continue;
            @autoreleasepool {
                if((!effect.hasInput && effect.numberOfInputTextures < 2) || effect.ignoreActualRender) continue;
                BOOL effectRequiresRefresh = effect.requiresFrameRefresh;
                MysticFilterLayer *layer = [effects.filters layerFromOption:effect tag:[MysticFilterManager optionTag:effect]];
                [layer prepareForUse];
                effect.stackPosition = effectIndex;
                if(effect.hasInput && effect.hasImage)
                {
                    MysticImage *effectImage = [effect image:effects];
                    if(effectImage)
                    {
                        effectPicture = [[MysticGPUImageLayerPicture alloc] initWithImage:effectImage smoothlyScaleOutput:effect.smoothing];
                        layer.sourcePicture = effectPicture;
                        [effect updateAllFilters];
                        nextFilter = [effect addFilters:(GPUImageOutput<GPUImageInput> *)effectPicture layer:layer effects:effects context:nil];
                        effectImage = nil;
                    }
                }
                NSMutableArray *effectTextures = [NSMutableArray array];

                if(effect.numberOfInputTextures > 1)
                {
                    UIImage *effectInputImage = effect.maskImage;
                    if(effectInputImage)
                    {
                        MysticGPUImageLayerTexture *effectTexture = [[MysticGPUImageLayerTexture alloc] initWithImage:effectInputImage smoothlyScaleOutput:effect.smoothing];
                        [layer addTexture:effectTexture forKey:@(MysticFilterTypeBlendMaskShowBlack)];
                        if(effect.canTransform)
                        {
                            GPUImageTransformFilter *transformFilter = [[[GPUImageTransformFilter alloc] init] autorelease];
                            transformFilter.ignoreAspectRatio = effect.hasSetAdjustmentTransformRect;
                            [transformFilter forceProcessingAtSize:renderSize];
//                            transformFilter.affineTransform = effect.transformTextureXY;
                            [effectTexture addTarget:transformFilter];
                            [effectTextures addObject:transformFilter];
                            [layer addTextureFilter:transformFilter forKey:@"transform" textureKey:@(MysticFilterTypeBlendMaskShowBlack)];
                            
                        }
                        else [effectTextures addObject:effectTexture];
                    }
                    if(effect.adjustColorsFinal.count && effect.hasMapImage)
                    {
                        
                        MysticGPUImageLayerTextureMap *effectTexture = [[MysticGPUImageLayerTextureMap alloc] initWithImage:effect.mapImage smoothlyScaleOutput:effect.smoothing];
                        [layer addTexture:effectTexture forKey:@(MysticFilterTypeAdjustColor)];
                        layer.isSourceLayer = NO;
                        layer.requiresRefresh = NO;
                        [effectTextures addObject:effectTexture];
                        nextFilter = (id)effectTexture;
                    }

                    
                }
                if(nextFilter)
                {
                    [textures addObject:@{@"effect": MNull(effect), @"location": @(effectIndex), @"type": MNull(effect.shortDebugDescription),  @"filter": MNull(nextFilter), @"layer":MNull(layer), @"process":MNull(effectPicture), @"requiresFrameRefresh": [NSNumber numberWithBool:effectRequiresRefresh],@"textures":effectTextures}];
                    effectIndex++;
                }
                [effects.filters addLayer:layer];
                if(effectPicture) [effectPicture release];
            }
        }

        if(textures.count)
        {
            int index = 0;
            for (NSDictionary *texture in textures)
            {
                int tindex = [texture[@"location"] intValue];
                index = MAX(index, tindex);
                BOOL refresh = [texture[@"requiresFrameRefresh"] boolValue];
                id textureFilter = texture[@"filter"];
                PackPotionOption *effect = texture[@"effect"];

                if(effect.hasInput || [texture[@"type"] isEqualToString:@"source"])
                {
                    if(textureFilter && !isMNull(textureFilter)) [textureFilter addTarget:effects.filters.filter atTextureLocation:index];

                    switch (index) {
                        case 0: effects.filters.filter.firstTextureRequiresUpdate = refresh; break;
                        case 1: effects.filters.filter.secondTextureRequiresUpdate = refresh; break;
                        case 2: effects.filters.filter.thirdTextureRequiresUpdate = refresh; break;
                        case 3: effects.filters.filter.fourthTextureRequiresUpdate = refresh; break;
                        case 4: effects.filters.filter.fifthTextureRequiresUpdate = refresh; break;
                        case 5: effects.filters.filter.sixthTextureRequiresUpdate = refresh; break;
                        default: break;
                    }
                }
                else
                {
                    index -= 1;
                }
                for (int i=1; i<effect.numberOfInputTextures; i++) {
                    index+=i;
                    if(i-1 < 0 || i > [((NSArray *)texture[@"textures"]) count]) continue;
                    id effectTexture = [texture[@"textures"] objectAtIndex:i-1];
                    if(effectTexture && !isMNull(effectTexture)) [effectTexture addTarget:effects.filters.filter atTextureLocation:index];
                    switch (index) {
                        case 0: effects.filters.filter.firstTextureRequiresUpdate = refresh; break;
                        case 1: effects.filters.filter.secondTextureRequiresUpdate = refresh; break;
                        case 2: effects.filters.filter.thirdTextureRequiresUpdate = refresh; break;
                        case 3: effects.filters.filter.fourthTextureRequiresUpdate = refresh; break;
                        case 4: effects.filters.filter.fifthTextureRequiresUpdate = refresh; break;
                        case 5: effects.filters.filter.sixthTextureRequiresUpdate = refresh; break;
                        default: break;
                    }
                }
            }
            for (NSDictionary *texture in textures)
            {
                GPUImagePicture *img = [texture objectForKey:@"process"];
                if(img&&[img isKindOfClass:[GPUImagePicture class]]) [img processImage];
                MysticFilterLayer *layer = texture[@"layer"];
                for (NSDictionary *t in layer.textures.allValues) {
                    GPUImagePicture*tp = t[@"texture"]; [tp processImage];
                }
            }
        }
        lastOutput = mainFilter;
        if(settingsOptionAfter)
        {
            MysticFilterLayer *settingsLayerAfter = [effects.filters layerFromOption:settingsOptionAfter tag:@"SettingsAfter"];
            settingsLayerAfter.isSourceLayer = YES;
            if(settingsLayerAfter && settingsOptionAfter && lastOutput)
            {
                lastOutput = [settingsOptionAfter addFilters:lastOutput layer:settingsLayerAfter effects:effects context:@{@"options":@(MysticFilterOptionAfterLayers)}];
                settingsLayerAfter.refreshAll = YES;
                settingsLayerAfter.sourcePicture = (MysticGPUImageLayerPicture *)sourcePicture;
                if(settingsLayerAfter) [effects.filters addLayer:settingsLayerAfter];
            }
            [settingsOptionAfter release];
        }
        effects.filters.lastOutput = lastOutput;
        if(!imageView || effects.settings & MysticRenderOptionsPass)
        {
            [lastOutput useNextFrameForImageCapture];
            if(sourcePicture) [sourcePicture processImage];
            renderedImage = [lastOutput imageFromCurrentFramebuffer];
            renderedImage = [effects addOverlays:renderedImage];
        }
        if(imageView && !(effects.settings & MysticRenderOptionsPass))
        {
            if(completedBlock) {  completedBlock(nil, lastOutput, effects, [_operation isCancelled]); };
        }
        else if(completedBlock) {  completedBlock(renderedImage, lastOutput, effects, [_operation isCancelled]); }
        [sourcePicture release], sourcePicture = nil;
        if(mainFilter) [mainFilter release], mainFilter=nil;
        lastOutput = nil;
        layerFilter = nil;
        [textures release];
    }
    else
    {
        if(imageView && [sourceInputOrImage respondsToSelector:@selector(CGImage)])
        {
            if([_operation isCancelled]) return;
            if(!effects) { if(completedBlock) {  completedBlock(nil, nil, effects, [_operation isCancelled]); } }
            else
            {
                MysticGPUImageSourcePicture *sourcePicture = [[MysticGPUImageSourcePicture alloc] initWithImage:sourceInputOrImage smoothlyScaleOutput:NO];
                MysticOneInputFilter *mainFilter = [[MysticOneInputFilter alloc] initWithDefaultShader];
                id lastOutput = mainFilter;
                [(MysticImageFilter *)mainFilter setBackgroundColorRed:0.0 green:0 blue:0 alpha:1.0];
                effects.filters.filter = (MysticImageFilter *)mainFilter;
                [effects.filters.filter forceProcessingAtSizeRespectingAspectRatio:renderSize];
                effects.filters.sourcePicture = sourcePicture;
                effects.filters.lastOutput = (GPUImageOutput <GPUImageInput> *)lastOutput;
                effects.filters.imageView = (MysticGPUImageView *)imageView;
                [sourcePicture addTarget:effects.filters.filter atTextureLocation:0];
               [MysticEffectsManager setOptions:effects];
                if(completedBlock) {  completedBlock((id)sourcePicture, lastOutput, effects, [_operation isCancelled]); }
                [sourcePicture release];
                [mainFilter release];
            }
        }
        else if(completedBlock) {  completedBlock(renderedImage, nil, effects, [_operation isCancelled]); }
    }
}

+ (UIImage *) errorImage:(CGSize)renderSize errorCount:(int)numOfErrors effectIndex:(int)effectIndex effect:(PackPotionOption *)effect;
{
    UIGraphicsBeginImageContextWithOptions(renderSize, NO, 1);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [[[UIColor warningColor] colorWithAlphaComponent:0.7] setFill];
    CGContextFillRect(contextRef, CGRectMake(0, (105*numOfErrors)+20, renderSize.width/2, 100));
    [[UIColor blackColor] setFill];
    [[UIColor blackColor] setStroke];
    [@"ERROR: No Image Found" drawAtPoint:CGPointMake(20, (105*numOfErrors)+25) forWidth:(renderSize.width/2) - 20 withFont:[UIFont systemFontOfSize:20] fontSize:20 lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    [[NSString stringWithFormat:@"Layer #%d: %@ - %@", (int)effectIndex, MyString(effect.type), effect.name] drawAtPoint:CGPointMake(20, (105*numOfErrors)+50) forWidth:renderSize.width/2 withFont:[UIFont systemFontOfSize:20] fontSize:20 lineBreakMode:NSLineBreakByWordWrapping baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    UIImage *effectImageClear = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return effectImageClear;
}







@end
