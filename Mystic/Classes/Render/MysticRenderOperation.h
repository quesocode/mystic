//
//  MysticRenderOperation.h
//  Mystic
//
//  Created by travis weerts on 9/19/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"


@interface MysticRenderOperation : NSOperation

@property (nonatomic, retain) MysticOptions *options, *renderOptions;
@property (nonatomic, readonly) MysticOptions *lastRenderedOptions;
@property (nonatomic, readonly) MysticFilterManager *lastFilters;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL shouldRecycle, usingSubSetOptions, useOptionsAsIs;
@property (nonatomic, retain) id lastOutput;
@property (nonatomic, retain) UIImage *sourceImage, *renderedImage;
@property (nonatomic, copy) MysticBlockImageObjOptions completedBlock;
@property (nonatomic, copy) MysticBlockImageObjOptionsPass finishedPassBlock;
@property (nonatomic, copy) MysticBlockDownloadProgress progressBlock;

- (void) render:(id)sourceInputOrImage size:(CGSize)renderSize view:(GPUImageView *)imageView effects:(MysticOptions *)effects complete:(MysticBlockImageObjOptions)completedBlock;
- (void) renderPass:(UIImage *)sourceImage size:(CGSize)renderSize view:(GPUImageView *)imageView effects:(MysticOptions *)effects complete:(MysticBlockImageObjOptions)completedBlock;
+ (void) renderOperation:(MysticRenderOperation *)_operation source:(id)sourceInputOrImage size:(CGSize)renderSize view:(GPUImageView *)imageView effects:(MysticOptions *)effects complete:(MysticBlockImageObjOptions)completedBlock;

+ (UIImage *) errorImage:(CGSize)renderSize errorCount:(int)numOfErrors effectIndex:(int)effectIndex effect:(PackPotionOption *)effect;

@end
