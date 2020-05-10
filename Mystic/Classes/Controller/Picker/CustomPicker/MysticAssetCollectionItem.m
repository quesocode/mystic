//
//  MysticAssetCollectionItem.m
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticAssetCollectionItem.h"

@implementation MysticAssetCollectionItem

- (void) dealloc;
{
    if(_asset) [_asset release];
    [super dealloc];
}

- (NSDictionary *) assetInfo;
{
    ALAsset *a = [self.asset retain];

    UIImage *fullResImage = [UIImage imageWithCGImage:a.defaultRepresentation.fullResolutionImage];

    UIImage *editedImage = [self imageHasAdjustments] ? self.editedImage : nil;

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{UIImagePickerControllerMediaType: [a valueForProperty:ALAssetPropertyType],
             UIImagePickerControllerOriginalImage: fullResImage,
             UIImagePickerControllerReferenceURL: a.defaultRepresentation.url,
             UIImagePickerControllerMediaMetadata: self.mediaMetaData,
             @"__asset": a,
             }];
    if(editedImage) [dict setObject:editedImage forKey:UIImagePickerControllerEditedImage];
    [a autorelease];
    return dict;
             
             
}
- (BOOL) imageHasAdjustments;
{
    ALAssetRepresentation *assetRepresentation = self.asset.defaultRepresentation;
    NSString *adjustment = [[assetRepresentation metadata] objectForKey:@"AdjustmentXMP"];
    return adjustment ? YES : assetRepresentation.orientation != ALAssetOrientationUp;
}
- (UIImage *) editedImage;
{
    ALAssetRepresentation *assetRepresentation = self.asset.defaultRepresentation;
    CGImageRef fullResImage = assetRepresentation.fullResolutionImage;
    return [UIImage imageWithCGImage:fullResImage
                                          scale:[assetRepresentation scale]
                                    orientation:(UIImageOrientation)[assetRepresentation orientation]];
    
}

- (NSDictionary *) mediaMetaData;
{
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:self.asset.defaultRepresentation.metadata];
    if([self.asset valueForProperty:ALAssetPropertyType]) [data setObject:[self.asset valueForProperty:ALAssetPropertyType] forKey:ALAssetPropertyType];
    if([self.asset valueForProperty:ALAssetPropertyDate]) [data setObject:[self.asset valueForProperty:ALAssetPropertyDate] forKey:ALAssetPropertyDate];

    if([self.asset valueForProperty:ALAssetPropertyOrientation]) [data setObject:[self.asset valueForProperty:ALAssetPropertyOrientation] forKey:ALAssetPropertyOrientation];

    
    if([self.asset valueForProperty:ALAssetPropertyLocation]) [data setObject:[self.asset valueForProperty:ALAssetPropertyLocation] forKey:ALAssetPropertyLocation];

    if([self.asset valueForProperty:ALAssetPropertyAssetURL]) [data setObject:[self.asset valueForProperty:ALAssetPropertyAssetURL] forKey:ALAssetPropertyAssetURL];
    
    if([self.asset valueForProperty:ALAssetPropertyRepresentations]) [data setObject:[self.asset valueForProperty:ALAssetPropertyRepresentations] forKey:ALAssetPropertyRepresentations];
    
    if([self.asset valueForProperty:ALAssetPropertyURLs]) [data setObject:[self.asset valueForProperty:ALAssetPropertyURLs] forKey:ALAssetPropertyURLs];

    
    return data;

}

- (UIImageOrientation) imageOrientation;
{
    {
        UIImageOrientation orientation;
        switch (self.asset.defaultRepresentation.orientation) {
                
            case ALAssetOrientationUp:
                orientation = UIImageOrientationUp;
                break;
            case ALAssetOrientationLeft:
                orientation = UIImageOrientationLeft;
                break;
            case ALAssetOrientationRight:
                orientation = UIImageOrientationRight;
                break;
            case ALAssetOrientationDown:
                orientation = UIImageOrientationDown;
                break;
            case ALAssetOrientationDownMirrored:
                orientation = UIImageOrientationDownMirrored;
                break;
            case ALAssetOrientationUpMirrored:
                orientation = UIImageOrientationUpMirrored;
                break;
            case ALAssetOrientationLeftMirrored:
                orientation = UIImageOrientationLeftMirrored;
                break;
            case ALAssetOrientationRightMirrored:
                orientation = UIImageOrientationRightMirrored;
                break;
                
            default:
                orientation = UIImageOrientationUp;
                break;
        }
        return orientation;
    }
}
@end
