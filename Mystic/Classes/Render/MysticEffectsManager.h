//
//  MysticEffectsManager.h
//  Mystic
//
//  Created by travis weerts on 7/19/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mystic.h"
#import "MysticGPUImageView.h"





@interface MysticEffectsManager : NSObject
@property (nonatomic, assign) BOOL stopRefresh;
@property (nonatomic, retain) MysticOptions *options, *renderedOptions;
//@property (nonatomic, copy) MysticBlockImageObjOptionsPass finishedPassBlock;
//@property (nonatomic, copy) MysticBlockImageObjOptions completedBlock;

+ (MysticEffectsManager *) manager;


+ (void) cleanFrameBuffers;

+ (void) refresh;
+ (void) refresh:(PackPotionOption *)option;
+ (void) refresh:(id)option completion:(MysticBlock)finished;

+ (void) setOptions:(MysticOptions *)manager rendered:(MysticOptions *)rendered;
+ (void) setOptions:(MysticOptions *)manager;

+ (MysticOptions *) renderedOptions;
+ (MysticOptions *) currentOptions;
+ (MysticOptions *) options;
+ (UIImage *) renderedPreviewImageForOptions:(MysticOptions *)options;
+ (UIImage *) renderedPreviewImageWithOverlaysForOptions:(MysticOptions *)options image:(UIImage *)image;

+ (UIImage *)renderedImage;
+ (UIImage *)renderedPreviewImage;
+ (void)renderedPreviewImage:(MysticOptions *)effects complete:(MysticBlockImageObjOptions)complete;
+ (CGSize) sizeForSettings:(MysticRenderOptions)settings;
+ (CGSize) size:(MysticRenderOptions)settings;

+ (void) render;
+ (void) render:(UIImage *)sourceImage effects:(MysticOptions *)effects complete:(MysticBlockImageObjOptions)completedBlock;

+ (void) render:(UIImage *)sourceImage view:(MysticGPUImageView *)imageView effects:(MysticOptions *)effects complete:(MysticBlockImageObjOptions)completedBlock;

+ (void) render:(UIImage *)sourceImage size:(CGSize)renderSize view:(MysticGPUImageView *)imageView effects:(MysticOptions *)_effects complete:(MysticBlockImageObjOptions)completedBlock;

+ (void) render:(UIImage *)sourceImage size:(CGSize)renderSize view:(MysticGPUImageView *)imageView effects:(MysticOptions *)effects options:(MysticRenderOptions)settings progress:(MysticBlockDownloadProgress)progressBlock complete:(MysticBlockImageObjOptions)completedBlock;

+ (void) image:(MysticRenderOptions)imageType progress:(MysticBlockDownloadProgress)progressBlock complete:(MysticBlockImageObjOptions)completedBlock;
+ (void) imageOfSize:(CGSize)size progress:(MysticBlockDownloadProgress)progressBlock complete:(MysticBlockImageObjOptions)completedBlock;

+ (void) setLastRender:(NSDictionary *)info;

+ (void) clearMemory;
+ (void) renderOriginalImageProgress:(MysticBlockDownloadProgress)progressBlock complete:(MysticBlockObjBOOLObj)renderComplete;
+ (void) renderFromGroundUp:(MysticOptions *)effectsInput progress:(MysticBlockDownloadProgress)progressBlock pass:(MysticBlockImageObjOptionsPass)finishedPassBlock complete:(MysticBlockImageObjOptions)completedBlock;
+ (void) saveLargePhoto:(MysticOptions *)renderedOptions lastOutput:(GPUImageOutput *)lastOutput finished:(MysticBlockObjObj)finished;

@end

