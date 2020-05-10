//
//  MysticEffectsManager.m
//  Mystic
//
//  Created by travis weerts on 7/19/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticEffectsManager.h"
#import "MysticLabelsView.h"
#import "MysticRenderQueue.h"
#import "MysticRenderOperation.h"
#import "UserPotion.h"
#import "MysticImage.h"
#import "MysticEmptyFilter.h"
#import "MysticCacheImage.h"
#import "MysticOptionsCacheManager.h"
#import "MysticShader.h"
#import "MysticController.h"



@implementation MysticEffectsManager

static UIImage *renderedPreviewImg = nil;
static NSInteger renderIndex = 0;
static NSDictionary *lastRenderedInfo = nil;
static BOOL __isReadyForRender = YES;

@synthesize options=_options, renderedOptions=_renderedOptions;

+ (MysticEffectsManager *) manager;
{
    static dispatch_once_t once1;
    static MysticEffectsManager* instance;
    dispatch_once(&once1, ^{
        instance = [[MysticEffectsManager alloc] init];
        instance.stopRefresh=NO;
    });
    return instance;
}
+ (MysticOptions *) options;
{
    if(![MysticEffectsManager manager].options) [MysticEffectsManager manager].options = [MysticOptions options];
    return [MysticEffectsManager manager].options;

}
+ (MysticOptions *) currentOptions;
{
    return [MysticEffectsManager options];
}
+ (MysticOptions *) renderedOptions;
{
    return [MysticEffectsManager manager].renderedOptions;
}

+ (void) cleanFrameBuffers;
{
    if(![[GPUImageContext sharedFramebufferCache] respondsToSelector:@selector(cleanAllBuffers)]) {
        return [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
    }
    MysticWait(1, ^{
        [[GPUImageContext sharedFramebufferCache] performSelector:@selector(cleanAllBuffers)];
    });

}
+ (void) setLastRender:(NSDictionary *)info;
{
    [lastRenderedInfo release]; lastRenderedInfo=nil;
    lastRenderedInfo = [info retain];
}
+ (void) setOptions:(MysticOptions *)manager;
{
    [MysticEffectsManager setOptions:manager rendered:nil];
}
+ (void) setOptions:(MysticOptions *)theOptions rendered:(MysticOptions *)theRenderedOptions;
{
//    if([theOptions isEqual:[MysticEffectsManager manager].options]) return;
    theOptions = theOptions.topSelf;
    if(!theOptions) return;
    if([[MysticEffectsManager manager].options isEqual:theOptions])
    {
        return;
    }
    

    if(!theOptions.isLive) theOptions.isLive = YES;
    [MysticEffectsManager manager].options = theOptions;

}
+ (void) clearMemory;
{
    [lastRenderedInfo release]; lastRenderedInfo=nil;

}
+ (CGSize) size:(MysticRenderOptions)settings;
{
    return [self sizeForSettings:settings];
}
+ (CGSize) sizeForSettings:(MysticRenderOptions)settings;
{
    CGSize size = CGSizeZero;
    if(settings & MysticRenderOptionsOriginal) size =  [UserPotion potion].originalImageSize;
    else if(settings & MysticRenderOptionsSource) size =  [UserPotion potion].sourceImageSize;
    else if(settings & MysticRenderOptionsPreview) size =  [UserPotion potion].previewSize;
    else if(settings & MysticRenderOptionsThumb) size =  MysticSizeThumbnail;
    else if(settings & MysticRenderOptionsBiggest) return CGSizeMax([UserPotion potion].originalImageSize, [UserPotion potion].sourceImageSize);
    else size = [UserPotion potion].sourceImageSize;
    return CGSizeConstrain(size, [MysticUser user].maximumRenderSize);
}

+ (UIImage *)renderedImage;
{
    UIImage *renderedImage = [MysticOptions current].currentRenderedImage;
    if(renderedImage)
    {
        ILog(@"rendered image current render", renderedImage);
        return renderedImage;
    }
    id finalFilter = [MysticOptions current].filters.lastOutput;
    
    DLog(@"renderedImage: final filter: %@", finalFilter);
    
    if(finalFilter)
    {
        GPUImageOutput<GPUImageInput> * lastFilter = (GPUImageOutput<GPUImageInput> *)finalFilter;
        if(![finalFilter isKindOfClass:[GPUImagePicture class]] && ![finalFilter isKindOfClass:[MysticEmptyFilter class]])
        {
            
            
            
//            PackPotionOptionFontStyle *fontOption = (PackPotionOptionFontStyle *)[UserPotion optionForType:MysticObjectTypeFontStyle];
//            if(fontOption && !fontOption.blended)
//            {
//                MysticLabelsView *view = (MysticLabelsView *)fontOption.view;
////                UIImage *imgOutput = [lastFilter imageFromCurrentlyProcessedOutput];
//                
//                [lastFilter useNextFrameForImageCapture];
//                UIImage *imgOutput = [lastFilter imageFromCurrentFramebuffer];
//                
//                
//                CGSize renderSize = [MysticImage sizeInPixels:imgOutput];
//                renderedImage = [MysticImage imageByRenderingView:imgOutput size:[MysticUI scaleDown:renderSize scale:[Mystic scale]] scale:[Mystic scale] view:view];
//                
//            }
//            else
//            {
//                renderedImage = [lastFilter imageFromCurrentlyProcessedOutput];
//                [lastFilter useNextFrameForImageCapture];
            DLog(@"current rendered image 4");

                renderedImage = [lastFilter imageFromCurrentFramebuffer];
            
            ILog(@"MysticEffectsManager renderedImage", renderedImage);
            
//            }
            return renderedImage;
        }
    }
    return [UserPotion potion].sourceImage;
    
}

+ (UIImage *)renderedPreviewImage;
{
    UIImage *img = [[self class] renderedImage];
    return img ? [[img retain] autorelease] : nil;
    
}

+ (void) renderOriginalImageProgress:(MysticBlockDownloadProgress)progressBlock complete:(MysticBlockObjBOOLObj)renderComplete;
{
    MysticOptions *options = [MysticOptions current];
    [options disable:MysticRenderOptionsPreview];
    [options disable:MysticRenderOptionsThumb];
    [options disable:MysticRenderOptionsOriginal];
    [options enable:MysticRenderOptionsSource];
    [options enable:MysticRenderOptionsForceProcess];
    [options disable:MysticRenderOptionsSaveImageOutput];
    
    CGSize renderSize = [MysticEffectsManager sizeForSettings:options.settings];
    CGSize originalSize = [MysticEffectsManager sizeForSettings:MysticRenderOptionsOriginal];
    __unsafe_unretained __block MysticBlockObjBOOLObj _complete = renderComplete ? Block_copy(renderComplete) : nil;
    CGSize constrainedSize = CGSizeGreater(renderSize, [MysticUser user].maximumRenderSize) ? [MysticUI scaleSize:renderSize bounds:[MysticUser user].maximumRenderSize] : renderSize;
    ALLog(@"Saving original photo", @[@"Render Size", SLogStr(renderSize),
                             @"Original Size", SLogStr(originalSize),
                             @"Max Render", SLogStr([MysticUser user].maximumRenderSize),
                             @"-",
                             @"Constrained Size", SLogStr(constrainedSize),
                             ]);
    
    
    [MysticEffectsManager imageOfSize:constrainedSize progress:progressBlock complete:^(UIImage *image, id obj, MysticOptions *completedOptions, BOOL isCancelled) {
        UIImage *i = [MysticEffectsManager renderedPreviewImageWithOverlaysForOptions:completedOptions image:image];
        image = i ? i : image;
        mdispatch(^{ if(_complete) { _complete(image, !isCancelled, nil); Block_release(_complete); }});
    }];
}

+ (void) image:(MysticRenderOptions)imageType progress:(MysticBlockDownloadProgress)progressBlock complete:(MysticBlockImageObjOptions)completedBlock;
{
    [[MysticOptions current] enable:imageType];
    [MysticEffectsManager render:nil size:[[self class] sizeForSettings:[MysticOptions current].settings] view:nil effects:[MysticOptions current] options:[MysticOptions current].settings progress:progressBlock complete:completedBlock];
}

+ (void) imageOfSize:(CGSize)size progress:(MysticBlockDownloadProgress)progressBlock complete:(MysticBlockImageObjOptions)completedBlock;
{
    [MysticEffectsManager render:nil size:size view:nil effects:[MysticOptions current] options:[MysticOptions current].settings progress:progressBlock complete:completedBlock];
}
+ (void)renderedPreviewImage:(MysticOptions *)effects complete:(MysticBlockImageObjOptions)complete;
{
    effects  = effects ? effects : [UserPotion renderEffects];
    [self render:[UserPotion potion].sourceImageResized size:[UserPotion potion].renderSize view:nil effects:effects complete:complete];    
}


+ (void) refresh;
{
    [self refresh:nil];
}
+ (void) refresh:(id)option;
{
    [self refresh:option completion:nil];
}
+ (void) refresh:(id)option completion:(MysticBlock)finished;
{
    mdispatch_high(^{
        if([MysticEffectsManager manager].stopRefresh) return;
        if([MysticShader shaderFileIsNewer])
        {
            [MysticEffectsManager manager].stopRefresh = YES;
            __unsafe_unretained __block MysticBlock _f = finished ? Block_copy(finished) : nil;
            __unsafe_unretained __block PackPotionOption *_option = option ? [option retain] : nil;
            [[MysticController controller] render:NO atSourceSize:NO complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
                mdispatch(^{
                    [MysticEffectsManager manager].stopRefresh = NO;
                    if(_f) { _f(); Block_release(_f); }
                    [MysticEffectsManager refresh:_option];
                    if(_option) [_option release];
                });
            }];
            return;
        }
        [[MysticEffectsManager manager].options.filters refresh:option completion:finished];
    });
}


+ (UIImage *) renderedPreviewImageForOptions:(MysticOptions *)options;
{
    UIImage *image = [[MysticOptionsCacheManager sharedManager] cachedImageForOptions:options];
    return image;
}
+ (UIImage *) renderedPreviewImageWithOverlaysForOptions:(MysticOptions *)options image:(UIImage *)image;
{
    PackPotionOptionFont *fontOption = (PackPotionOptionFont *)[options option:MysticObjectTypeFont];
    if(image && fontOption && !fontOption.blended)
    {
        MysticLabelsView *view = (MysticLabelsView *)fontOption.renderView;
        CGSize renderSize = [MysticImage sizeInPixels:image];
        renderSize = CGSizeEqualToSize(CGSizeZero, renderSize) ? view.frame.size : renderSize;
        UIImage *newImage = [MysticImage imageByRenderingView:image size:[MysticUI scaleDown:renderSize scale:[Mystic scale]] scale:[Mystic scale] view:view finished:nil];

        image = newImage ? newImage : image;
    }
    
    
    return image;
}



+ (void) render;
{
    MysticOptions *effects = [MysticEffectsManager manager].options;
    if(effects)
    {
        [effects clean];
        effects.tag = nil;
        effects.settings = effects.settings | MysticRenderOptionsRefresh;
        [MysticEffectsManager render:effects.sourceImage size:effects.size view:effects.imageView effects:effects options:effects.settings progress:nil complete:nil];
        effects.settings = effects.settings & ~MysticRenderOptionsRefresh;
    }
}
+ (void) render:(UIImage *)sourceImage effects:(MysticOptions *)effects complete:(MysticBlockImageObjOptions)completedBlock;

{
    [MysticEffectsManager render:sourceImage view:effects.imageView effects:effects complete:completedBlock];
}
                                                             
+ (void) render:(UIImage *)sourceImage view:(MysticGPUImageView *)imageView effects:(MysticOptions *)_effects complete:(MysticBlockImageObjOptions)completedBlock;
{
    CGSize sourceSize = CGSizeMake(CGImageGetWidth(sourceImage.CGImage), CGImageGetHeight(sourceImage.CGImage));
    CGSize renderSize = imageView ? [MysticUI scaleSize:imageView.frame.size scale:[Mystic scale]] : sourceSize;
    [self render:sourceImage size:renderSize view:imageView effects:_effects complete:completedBlock];
}
+ (void) render:(UIImage *)sourceImage size:(CGSize)renderSize view:(MysticGPUImageView *)imageView effects:(MysticOptions *)effects complete:(MysticBlockImageObjOptions)completedBlock;
{
    [self render:sourceImage size:renderSize view:imageView effects:effects options:effects.settings progress:nil complete:completedBlock];
}
+ (void) render:(UIImage *)sourceImageInput size:(CGSize)renderSize view:(MysticGPUImageView *)imageView effects:(MysticOptions *)effectsInput options:(MysticRenderOptions)settings progress:(MysticBlockDownloadProgress)progressBlock complete:(MysticBlockImageObjOptions)completedBlock;
{
    EffectsLog(@"MysticEffectsManager: Preparing to render: %2.3f x %2.3f", renderSize.width, renderSize.height);
    


    __block __unsafe_unretained MysticOptions *effects = effectsInput ? [effectsInput retain] : [[UserPotion renderEffects] retain];
    __block __unsafe_unretained UIImage *sourceImage = sourceImageInput ? [sourceImageInput retain] : nil;
    effects.size =renderSize;
    effects.imageView= imageView;
    effects.settings = settings;
    effects.sourceImage = sourceImage;
    
    @try {
        mdispatch_high(^{
            
        
            
            if ((effects.settings & MysticRenderOptionsRefresh) == NO && !effects.needsRender)
            {
                if(__isReadyForRender == NO)
                {
                    if(completedBlock) completedBlock(nil, nil, effects, NO);
                    [sourceImage release];
                    [effects release];
                    if(!__isReadyForRender) return;
                    __isReadyForRender = YES;
                    return;
                }
            }
            
            __isReadyForRender = NO;
            [[MysticRenderProcessQueue sharedQueue] cancelAllOperations];
            [effects prepareForRender];
            MysticRenderOperation *operation = [[MysticRenderOperation alloc] init];
            operation.options = effects;
            operation.completedBlock = completedBlock;
            operation.progressBlock = progressBlock;
            operation.index = renderIndex++;
            effects.renderIndex = operation.index;
            [operation setCompletionBlock:^{
                __isReadyForRender = YES;
                [[MysticEffectsManager manager].options finishedRendering];
            }];
            [[MysticRenderProcessQueue sharedQueue] addOperation:operation];
            [operation release];
            [effects release];
            if(sourceImage) [sourceImage release];
        });
    }
    @catch (NSException *exception) {
        ErrorLog(@"MysticEffectsManager: render: exception: %@", exception.reason);
    }
}

+ (void) renderFromGroundUp:(MysticOptions *)effectsInput progress:(MysticBlockDownloadProgress)progressBlock pass:(MysticBlockImageObjOptionsPass)finishedPassBlock complete:(MysticBlockImageObjOptions)completedBlock;
{
    CGSize renderSize = [MysticEffectsManager sizeForSettings:effectsInput.settings];
    __block __unsafe_unretained MysticOptions *effects = effectsInput ? effectsInput : [UserPotion renderEffects];
    __unsafe_unretained __block MysticBlockImageObjOptions _c = completedBlock ? Block_copy(completedBlock) : nil;

    __unsafe_unretained __block MysticBlockImageObjOptionsPass __fp = finishedPassBlock ? Block_copy(finishedPassBlock) : nil;
__block __unsafe_unretained MysticOptionsManager *manager = [[MysticOptionsManager managerWithOptions:effects passes:(id)@(1)] retain];
    [manager enable:MysticRenderOptionsForceProcess];
    [manager enable:MysticRenderOptionsSaveState];

    manager.size =renderSize;
    manager.ignoreOptionsWithoutInput=NO;
    __isReadyForRender = NO;

    @try {
        
        MysticBlockImageObjOptionsPass _finishedPassBlock = ^(UIImage *passImage, id lastOutputFromPass, MysticOptions *renderedPassOptions, BOOL isCancelled, MysticBlockImageObjOptions resumeBlock)
        {

            __unsafe_unretained __block MysticBlockImageObjOptions __resumeBlock = resumeBlock ? Block_copy(resumeBlock) : nil;
            __unsafe_unretained __block UIImage *__passImage = passImage ? [passImage retain] : nil;
            __unsafe_unretained __block id __lastOutput = lastOutputFromPass ? [lastOutputFromPass retain] : nil;
            __unsafe_unretained __block MysticOptions *__lastPassOptions = renderedPassOptions ? [renderedPassOptions retain] : nil;
            
            if(__fp) __fp(nil, __lastOutput, __lastPassOptions, isCancelled, nil);            
            if(__lastOutput && [__lastOutput respondsToSelector:@selector(useNextFrameForImageCapture)]) [lastOutputFromPass performSelector:@selector(useNextFrameForImageCapture)];
            
            [MysticEffectsManager saveLargePhoto:__lastPassOptions lastOutput:(id)(__passImage && [__passImage isKindOfClass:[UIImage class]] ? __passImage : __passImage) finished:^(UIImage *largePhoto, NSString *imageFilePath) {

                if(__fp) __fp(largePhoto, __lastOutput, __lastPassOptions, isCancelled, __resumeBlock);
                else if(__resumeBlock) __resumeBlock(largePhoto, __lastOutput, __lastPassOptions, isCancelled);
                if(__resumeBlock) Block_release(__resumeBlock);
                if(__lastOutput) [__lastOutput autorelease];
                if(__lastPassOptions) [__lastPassOptions autorelease];
            }];
            
        
        };
        [self renderFromGroundUpNextPass:manager progress:progressBlock pass:_finishedPassBlock complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
            __isReadyForRender = YES;
            [[MysticEffectsManager manager].options finishedRendering];
            if(__fp) Block_release(__fp);
            if(_c) { _c(image, obj, options, cancelled); Block_release(_c); _c=nil; }
        }];
    }
    @catch (NSException *exception) {
        ErrorLog(@"MysticEffectsManager: renderFromGroundUp: exception: %@", exception.reason);
    }
    
    
}
+ (void) renderFromGroundUpNextPass:(MysticOptionsManager *)manager progress:(MysticBlockDownloadProgress)progressBlock pass:(MysticBlockImageObjOptionsPass)finishedPassBlock complete:(MysticBlockImageObjOptions)completedBlock;
{
    __block MysticOptions *pass = [manager nextPass];
    if(pass)
    {
        [self renderFromGroundUpPass:pass progress:progressBlock pass:finishedPassBlock complete:completedBlock];
    }
}
+ (void) renderFromGroundUpPass:(MysticOptions *)pass progress:(MysticBlockDownloadProgress)progressBlock pass:(MysticBlockImageObjOptionsPass)finishedPassBlock complete:(MysticBlockImageObjOptions)completedBlock;
{
    CGSize renderSize = [MysticEffectsManager sizeForSettings:pass.settings];
    __block BOOL isLastPass = [pass isEnabled:MysticRenderOptionsPassLast];
    __unsafe_unretained __block MysticBlockImageObjOptions _c = completedBlock ? Block_copy(completedBlock) : nil;
    __unsafe_unretained __block MysticBlockImageObjOptionsPass __fp = finishedPassBlock ? Block_copy(finishedPassBlock) : nil;
    __unsafe_unretained __block MysticBlockDownloadProgress __progressBlock = progressBlock ? Block_copy(progressBlock) : nil;

    [pass disable:MysticRenderOptionsPass];
    [pass disable:MysticRenderOptionsPassLast];
    [pass enable:MysticRenderOptionsForceProcess];

    __block __unsafe_unretained MysticOptions *_pass = pass ? [pass retain] : nil;
    _pass.size =renderSize;
    
    @try
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

            [[MysticRenderProcessQueue sharedQueue] cancelAllOperations];
            [_pass prepareForRender];
            __unsafe_unretained __block MysticRenderOperation *operation = [[MysticRenderOperation alloc] init];
            operation.options = _pass;
            operation.progressBlock = progressBlock;
            operation.index = renderIndex++;
            _pass.renderIndex = operation.index;
            operation.completedBlock = ^(UIImage *img, id lastOutput, MysticOptions *options, BOOL isCancelled){
                
                if(isLastPass)
                {
                    int i = 0;
                    if(__fp)
                    {
                        MysticBlockImageObjOptions _resumeBlock = ^(UIImage *img2, id lastOutput2, MysticOptions *options2, BOOL isCancelled2)
                        {
                            if(_c) { _c(img2, lastOutput2, options2, isCancelled2); Block_release(_c); }
                            if(__fp) Block_release(__fp);
                        };
                        __fp(img, lastOutput, options, isCancelled, _resumeBlock);
                    }
                    [operation release];
                }
                else
                {
                    if(__fp)
                    {
                        MysticBlockImageObjOptions _resumeBlock = ^(UIImage *img2, id lastOutput2, MysticOptions *options2, BOOL isCancelled2)
                        {
                            [MysticEffectsManager renderFromGroundUpNextPass:options.manager progress:__progressBlock pass:__fp complete:_c];
                            if(__fp) Block_release(__fp);
                        };
                        __fp(img, lastOutput, options, isCancelled, _resumeBlock);
                    }
                    [operation release];
                }
            };
            [[MysticRenderProcessQueue sharedQueue] addOperation:operation];
            [_pass release];
        });
    }
    @catch (NSException *exception) {
        ErrorLog(@"MysticEffectsManager: render: exception: %@", exception.reason);
    }
    

}


+ (void) saveLargePhoto:(MysticOptions *)renderedOptions lastOutput:(GPUImageOutput *)lastOutput finished:(MysticBlockObjObj)finished;
{
    if([renderedOptions isEnabled:MysticRenderOptionsSaveState] && lastOutput)
    {
        __unsafe_unretained __block UIImage *_image = [lastOutput isKindOfClass:[UIImage class]] ? (id)lastOutput : [lastOutput imageFromCurrentFramebuffer];
        if(_image) [_image retain];
        __unsafe_unretained __block MysticBlockObjObj __finished = finished ? Block_copy(finished) : nil;
        __unsafe_unretained __block MysticOptions *__opts = renderedOptions ? [renderedOptions retain] : nil;
        CGSize _imageSize = _image ? CGSizeMake(CGImageGetWidth(_image.CGImage), CGImageGetHeight(_image.CGImage)) : CGSizeZero;

        [[UserPotion potion] preparePhoto:_image previewSize:[MysticUI screen] reset:YES finished:^(CGSize size, UIImage *preparedImage, NSString *imageFilePath) {
            renderedOptions.hasRendered = YES;
            [renderedOptions optimizeForOffScreen];
            if(__finished)
            {
                __finished(preparedImage, imageFilePath);
                Block_release(__finished);
            }
            if(__opts) [__opts autorelease];
        }];
        [_image release];
    }
}
#pragma mark - instance methods

- (void) setRenderedOptions:(MysticOptions *)renderedOptions;
{
    self.options = renderedOptions;
}
- (MysticOptions *) renderedOptions;
{
    return self.options;
}




@end
