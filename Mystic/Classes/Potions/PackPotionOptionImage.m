//
//  PackPotionOptionImage.m
//  Mystic
//
//  Created by Travis A. Weerts on 3/10/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "PackPotionOptionImage.h"
#import "MysticOptions.h"
#import "MysticImageLayer.h"

@implementation PackPotionOptionImage
- (BOOL) shouldBlendWithPreviousTextureFirst; { return YES; }
- (MysticObjectType) type; { return MysticObjectTypeImage; }
- (BOOL) canTransform; { return YES; }
- (BOOL) hasInput; { return YES; }
- (BOOL) hasImage; { return self.layerImagePath || self.originalLayerImagePath; }
- (BOOL) canFillTransformBackgroundColor; { return YES; }
- (BOOL) shouldApplyAdjustmentsFromSimilarOption; { return NO; }
- (UIColor *) backgroundColor; { return UIColor.clearColor; }
- (MysticImageLayer *) image:(MysticOptions *)effects;
{
    MysticImageLayer *image=nil;
    if(!self.forceReizeLayerImage && self.stretchMode == MysticStretchModeAuto)
    {
        if(!image || ([effects isEnabled:MysticRenderOptionsSource] && self.originalLayerImagePath))
        {
            image = [MysticImageLayer image:[MysticImageLayer imageWithContentsOfFile:self.originalLayerImagePath]];
        }
        if(!image || ([effects isEnabled:MysticRenderOptionsPreview] && self.layerImagePath))
        {
            image = [MysticImageLayer image:[MysticImageLayer imageWithContentsOfFile:self.layerImagePath]];
        }
    }
    return image ? image : [super image:effects];
}
- (NSString *) tag;
{
    NSString *tag = [super tag];
    tag = tag ? tag : @"";
    UIImage *cimg = self.customLayerImage;
    if(cimg)
    {
        tag = [tag stringByAppendingString:[NSString stringWithFormat:@"%p", cimg]];
    }
    return tag;
}
//- (id) sourceImageInput;
//{
//    id i = !self.layerImagePath ? nil : [MysticImageLayer imageWithContentsOfFile:self.layerImagePath];
//    i = !i && self.originalLayerImagePath ? [MysticImageLayer imageWithContentsOfFile:self.originalLayerImagePath] : i;
//    return i ? i : [super sourceImageInput];
//    
//}
- (id) setUserChoice;
{
    if(!self.isRenderableOption) return self;
    self.level = [self setUserChoiceLevel];
    self.hasChanged = YES;
    self.shouldRender = YES;
    self.blendingMode = nil;
    [[MysticOptions current] addOption:self];
    [[MysticOptions current] optionsOrderedByLevel];
    return self;
}

@end