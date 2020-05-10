//
//  MysticLibrary.m
//  Mystic
//
//  Created by Me on 10/22/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLibrary.h"

#import "MysticImage.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "MysticBlockObj.h"
@implementation MysticLibrary


+ (id) sharedLibrary;
{
    if(usingIOS8())
    {
        return [PHPhotoLibrary sharedPhotoLibrary];
    }
    return [self sharedAssetsLibrary];
}
+ (ALAssetsLibrary *) sharedAssetsLibrary;
{
    
//    static dispatch_once_t once;
//    static id library;
//    dispatch_once(&once, ^{library = library ? library : [[ALAssetsLibrary alloc] init];});
//    return library;
    return [[[ALAssetsLibrary alloc] init] autorelease];

}

+ (void) save:(UIImage *)image album:(NSString *)albumName finished:(MysticBlockObject)finished;
{
    if(!isM(albumName))
    {
        __block UIImage *_image = image ? [image retain] : nil;
        __block MysticBlockObject _f = finished ? Block_copy(finished) : nil;
        [MysticImageBlockObj save:image done:^(id error, MysticImageBlockObj *object) {
            if(_f)
            {
                _f(@{@"image":_image, @"error": error ? error : [NSNull null]}); Block_release(_f);
            }
            [_image release];
        }];
        return;
    }
    [[self sharedAssetsLibrary] saveImage:image toAlbum:albumName withCompletionBlock:finished];
}
+ (id) fetchAlbums:(MysticBlockObject)finished;
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if(status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted)
    {
        if(finished)
        {
            finished(nil);
        }
        return nil;
    }
    if(usingIOS8())
    {
        PHFetchOptions *fetchOptions = [PHFetchOptions new];
        
        id r = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:[fetchOptions autorelease]];
        if(finished) finished(r);
        return r;
    }
    __unsafe_unretained __block MysticBlockObject _f = finished ? Block_copy(finished) : nil;
    __unsafe_unretained __block NSMutableArray *groups = [[NSMutableArray array] retain];
    [(ALAssetsLibrary *)[self sharedLibrary] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group)
        {
            [groups addObject:group];
        }
        else
        {
            if(_f)
            {
                _f([groups lastObject]);
                Block_release(_f);
            }
        }
        
    } failureBlock:^(NSError *error) {
        if(_f)
        {
            _f(nil);
            Block_release(_f);
        }
        [groups release];
    }];
    
    return nil;
}

+ (id) fetchCameraRoll:(MysticBlockObject)finished;
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if(status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted)
    {
        if(finished)
        {
            finished(nil);
        }
        return nil;
    }
    if(usingIOS8())
    {
        PHFetchOptions *fetchOptions = [PHFetchOptions new];

        PHFetchResult *r = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:[fetchOptions autorelease]];
        if(finished) finished(r.lastObject);
        return r.lastObject;
    }
    __unsafe_unretained __block MysticBlockObject _f = finished ? Block_copy(finished) : nil;
    __unsafe_unretained __block NSMutableArray *groups = [[NSMutableArray array] retain];
    [(ALAssetsLibrary *)[self sharedLibrary] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group)
        {
            [groups addObject:group];
        }
        else
        {
            if(_f)
            {
                _f([groups lastObject]);
                Block_release(_f);
                
            }
            [groups release];
        }
        
    } failureBlock:^(NSError *error) {
        if(_f)
        {
            _f(nil);
            Block_release(_f);
        }
        [groups release];
    }];
    
    return nil;
}

+ (id) fetchCameraRollAssets:(MysticBlockObjObj)finished;
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if(status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted)
    {
        
        if(finished)
        {
            finished(nil, nil);
        }
        return nil;
    }
    
    if(usingIOS8())
    {
        PHFetchOptions *fetchOptions = [PHFetchOptions new];
        
        id assetCollection = [self fetchCameraRoll:nil];
        PHFetchResult *r = [PHAsset fetchAssetsInAssetCollection:assetCollection options:[fetchOptions autorelease]];
        if(finished) finished(r, assetCollection);
        
        return r;
    }
    __unsafe_unretained __block MysticBlockObjObj _f = finished ? Block_copy(finished) : nil;
    __unsafe_unretained __block NSMutableArray *assets = [[NSMutableArray array] retain];
    return [self fetchCameraRoll:^(ALAssetsGroup* group) {
        
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
           
            if(result)
            {
                [assets addObject:result];
            }
            else
            {
                if(_f)
                {
                    _f(assets, group);
                    Block_release(_f);
                }
                [assets release];
            }
            
        }];
        
    }];
    
}
+ (void) fetchLastCameraRollPhoto:(MysticBlockObjObj)finished;
{
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if(status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted)
    {
        if(finished)
        {
            finished(nil, @NO);
        }
        return;
    }
    
    __unsafe_unretained __block MysticBlockObjObj _f = finished ? Block_copy(finished) : nil;
    @autoreleasepool {
        
    
        if(usingIOS8())
        {
            [self fetchCameraRollAssets:^(PHFetchResult *object, id collection){

                id last = object.lastObject;
                PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
                requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
                requestOptions.version = PHImageRequestOptionsVersionCurrent;
                requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                [[PHImageManager defaultManager] requestImageForAsset:object.lastObject targetSize:[MysticImage maximumImageSize] contentMode:PHImageContentModeAspectFit options:[requestOptions autorelease] resultHandler:^(UIImage *result, NSDictionary *info) {
                    if(_f)
                    {
                        _f(result, info);
                        Block_release(_f);
                    }
                }];
            }];
            return;
        }
        [self fetchCameraRollAssets:^(ALAsset *object, ALAssetsGroup *group) {
            if(object)
            {
                ALAssetRepresentation *rep = object.defaultRepresentation;
                UIImage *result = [[[UIImage alloc] initWithCGImage:rep.fullResolutionImage scale:rep.scale orientation:UIImageOrientationUp] autorelease];
                if(_f)
                {
                    _f(result, object);
                    Block_release(_f);
                }
            }
            else
            {
                if(_f)
                {
                    _f(nil, nil);
                    Block_release(_f);
                }
            }
            
        }];
    }
}

+ (void) fetchLastCameraRollAsset:(MysticBlockObjObjObj)finished;
{
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if(status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted)
    {
        if(finished)
        {
            finished(nil, @NO, nil);
        }
        return;
    }
    
    __unsafe_unretained __block MysticBlockObjObjObj _f = finished ? Block_copy(finished) : nil;
    @autoreleasepool {
        
        
        if(usingIOS8())
        {
            
            [self fetchCameraRollAssets:^(PHFetchResult *object, PHAssetCollection *collection){
                
                id last = object.lastObject;
                PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
                requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
                requestOptions.version = PHImageRequestOptionsVersionCurrent;
                requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                if(_f)
                {
                    _f(last, collection, requestOptions);
                    Block_release(_f);
                }
            }];
            return;
        }
        [self fetchCameraRollAssets:^(ALAsset *object, ALAssetsGroup *group) {
            
            if(object)
            {
//                ALAssetRepresentation *rep = ;
//                UIImage *result = [[[UIImage alloc] initWithCGImage:rep.fullResolutionImage scale:rep.scale orientation:UIImageOrientationUp] autorelease];
                if(_f)
                {
                    _f(object, group, nil);
                    Block_release(_f);
                }
            }
            else
            {
                if(_f)
                {
                    _f(nil, nil, nil);
                    Block_release(_f);
                }
            }
            
        }];
    }
}
@end
