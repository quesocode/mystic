//
//  PackPotionOptionCamLayer.m
//  Mystic
//
//  Created by travis weerts on 3/21/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOptionCamLayer.h"
#import "Mystic.h"
#import "SDImageCache.h"
#import "UserPotion.h"

@implementation PackPotionOptionCamLayer
@synthesize  previewSize, sourceSize;

+ (PackPotionOptionCamLayer *) optionWithName:(NSString *)name info:(NSDictionary *)info;
{
    NSMutableDictionary *ninfo = [NSMutableDictionary dictionaryWithDictionary:info];
    if([info objectForKey:@"media"]) [ninfo removeObjectForKey:@"media"];
    PackPotionOptionCamLayer *option = (PackPotionOptionCamLayer *)[super optionWithName:name info:ninfo];
    return option;
}
- (MysticObjectType) type; { return MysticObjectTypeCamLayer; }
- (BOOL) anchorTopLeft; { return YES; }
- (BOOL) ignoreAspectRatio; { return YES; }
- (BOOL) canFillTransformBackgroundColor; { return YES; }

- (BOOL) shouldBlendWithPreviousTextureFirst; { return YES; }

- (BOOL) hasForegroundColor; { return [self colorType:MysticOptionColorTypeForeground]!=MysticColorTypeAuto; }

- (BOOL) userProvidedImage; { return YES; }

- (void) setInverted:(BOOL)inverted;
{
    super.inverted = inverted;
    
    CGFloat newWhiteLevels = (kLevelsMax - self.blackLevels);
    CGFloat newBlackLevels = kLevelsMin + (kLevelsMax - self.whiteLevels);
    
    [UserPotion optionForType:self.type].whiteLevels = newWhiteLevels;
    [UserPotion optionForType:self.type].blackLevels = newBlackLevels;
}

- (void) setMediaInfo:(NSArray *)info finished:(MysticBlock)finished;
{
    UIImage *camLayerSource = [[info lastObject] objectForKey:UIImagePickerControllerEditedImage] ? [[[info lastObject] objectForKey:UIImagePickerControllerEditedImage] retain] : [[[info lastObject] objectForKey:UIImagePickerControllerOriginalImage] retain];
    
    
    
    if([[info lastObject] objectForKey:UIImagePickerControllerCropRect])
    {
        self.cropRect = [(NSValue *)[[info lastObject] objectForKey:UIImagePickerControllerCropRect] CGRectValue];
    }
    
    NSString *uniqueTag = [UserPotion potion].uniqueTag;
    
    NSString *camLayerOriginalPath = [UserPotionManager setImage:camLayerSource layerLevel:kCamLayerLayerLevel tag:[uniqueTag stringByAppendingString:@"camlayer_image"] type:MysticImageTypeJPG cacheType:MysticCacheTypeProject];
    
    self.layerImagePath = camLayerOriginalPath;
    self.originalLayerImagePath = camLayerOriginalPath;
    
    CGRect imageSourceSize = CGRectZero;
    imageSourceSize.size = camLayerSource.size;
    self.sourceSize = camLayerSource.size;
    self.previewSize = [MysticUI aspectFit:imageSourceSize bounds:[MysticUI bounds]].size;

    CGRect cropRect = [MysticUI aspectFit:CGRectMake(0, 0, self.previewSize.width, self.previewSize.height) bounds:imageSourceSize];
    UIImage *camLayerResize = [[camLayerSource imageByCroppingToRect:cropRect] imageScaledToSize:self.previewSize];
    self.previewSize = camLayerResize.size;
    
    NSString *pp = [UserPotionManager setImage:camLayerResize layerLevel:kCamLayerLayerLevel tag:[uniqueTag stringByAppendingString:@"camlayer_preview"] type:MysticImageTypeJPG cacheType:MysticCacheTypeProject finishedPath:^(NSString *string) {
       if(finished) finished(); 
    }];
    
    self.previewImagePath = pp;
    [camLayerSource release], camLayerSource = nil;
}




- (UIImage *) layerPreviewImage;
{
    UIImage *camLayerImage = [UserPotionManager getProjectImageForSize:[MysticUI scaleSize:self.previewSize scale:[Mystic scale]] layerLevel:kCamLayerLayerLevel tag:[[UserPotion potion].uniqueTag stringByAppendingString:@"camlayer_preview"]];
    return !camLayerImage && self.previewImagePath ? [UIImage imageWithContentsOfFile:self.previewImagePath] : camLayerImage;
}

- (BOOL) stretchLayerImage { return NO; }

- (void) confirmCancel;
{
    [super confirmCancel];
    
    BOOL success ;
    NSError *error;
    @try
    {
        success = [[NSFileManager defaultManager] removeItemAtPath:self.previewImagePath error:&error];
        success = [[NSFileManager defaultManager] removeItemAtPath:self.layerImagePath error:&error];
        success = [[NSFileManager defaultManager] removeItemAtPath:self.originalLayerImagePath error:&error];
//        [[SDImageCache MysticCacheImage] clearMemory];
//        [[SDImageCache mysticProjectCache] clearMemory];
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR - MysticConfigManager (clearConfigFiles): %@", [error description]);
        success = NO;
    }
}

@end
