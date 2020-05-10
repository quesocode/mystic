//
//  MysticImage.h
//  Mystic
//
//  Created by travis weerts on 1/31/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

//#import "MysticImageLayer.h"
//#import "MysticImageSource.h"
//#import "MysticImageScreenshot.h"
//#import "MysticImageIcon.h"
//#import "MysticImageRender.h"
//#import "MysticImageRenderPreview.h"



#import <UIKit/UIKit.h>
#import "MysticConstants.h"
#import "GPUImage.h"
#import "MysticCacheImageKey.h"


@class MysticCacheImage, MysticOption;

@interface MysticImage : UIImage

@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSString *cacheKey, *imageFilePath;
@property (nonatomic, retain) MysticCacheImageKey *info;
@property (nonatomic, assign) MysticCache *cache;
@property (nonatomic, assign) MysticImageType type;
@property (nonatomic, assign) MysticOption *option;
@property (nonatomic, assign) BOOL saveToDisk, saveToMemory, fromCache;
@property (nonatomic, assign) CGFloat quality;
@property (nonatomic, readonly) NSData *imageData;
@property (nonatomic, assign) MysticCacheType cacheType;

+ (id)imageByApplyingAlpha:(CGFloat) alpha toImage:(UIImage *)inImage;

+ (id) image:(id)source ;

+ (id) image:(id)source color:(id)color;

+ (id) image:(id)source size:(CGSize)size;

+ (id) image:(id)source size:(CGSize)size color:(id)color;

+ (id) image:(id)source size:(CGSize)size contentMode:(UIViewContentMode)contentMode;
+ (id) image:(id)source size:(CGSize)atSize color:(id)color backgroundColor:(id)bgColor  contentMode:(UIViewContentMode)contentMode;
+ (id) image:(id)source size:(CGSize)atSize color:(id)color backgroundColor:(id)bgColor;

+ (id) image:(id)source size:(CGSize)size color:(id)color  contentMode:(UIViewContentMode)contentMode;
+ (id) image:(UIImage *)img withColor:(id)color;
+ (id) image:(UIImage *)img withColor:(id)color backgroundColor:(id)bgColor;

+ (id) imageWithCGImage:(CGImageRef)cgImage scale:(CGFloat)scale orientation:(UIImageOrientation)orientation;
+ (id) imageWithImage:(UIImage *)inImage;
+ (id) imageWithCGImage:(CGImageRef)cgImage;
+ (id) imageWithData:(NSData *)data;
+ (id) imageNamed:(NSString *)imageName;
+ (id) blurredImage:(UIImage *)img;
+ (id) blurredImage:(UIImage *)img blur:(CGFloat)blurLevel tintColor:(id)tintColor;
+ (id) downsampledImage:(UIImage *)img;

+ (id) imageWithData:(NSData *)data scale:(CGFloat)scale;

+ (id) backgroundImageWithColor:(id)color;
+ (id) backgroundImageWithColor:(id)color size:(CGSize)size;
+ (id) backgroundImageWithColor:(id)color size:(CGSize)size scale:(CGFloat)scale;
+ (UIImage *)maskImage:(UIImage *)img mask:(UIImage *)maskImage;
+ (UIImage *)maskedColorImage:(UIColor *)imgColor mask:(UIImage *)maskImage;


+ (void) draw:(UIImage *)img color:(UIColor *)color rect:(CGRect)rect bounds:(CGRect)bounds context:(CGContextRef)context;

+ (void) draw:(UIImage *)img color:(UIColor *)color rect:(CGRect)rect context:(CGContextRef)context;
+ (void) draw:(UIImage *)img color:(UIColor *)color context:(CGContextRef)context;

+ (id)imageByRenderingView:(UIImage *)img size:(CGSize)renderSize scale:(CGFloat)scale view:(UIView *)view bgColor:(UIColor *)bgColor finished:(MysticBlockObject)finished;
+ (id)imageByRenderingView:(UIImage *)img size:(CGSize)renderSize scale:(CGFloat)scale  view:(UIView *)view finished:(MysticBlockObject)finished;
+ (id)renderedImageWithBounds:(CGSize)bounds view:(UIView *)view finished:(MysticBlockObject)finished;
+ (id)renderedImageWithSize:(CGSize)renderSize  view:(UIView *)view finished:(MysticBlockObject)finished;


+ (UIImage *) imageWithView:(UIView *)view;
+ (UIImage *)scaledImage:(UIImage *)source toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality;
+ (UIImage *)scaleImage:(UIImage *)source scale:(float)scale;
+ (UIImage *)scaleImage:(UIImage *)source scale:(float)scale withQuality:(CGInterpolationQuality)quality;

+ (UIImage *)scaledImageWithCGImage:(CGImageRef)source toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality;

+ (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality;
+ (UIImage *)scaledImage:(UIImage *)source toSize:(CGSize)size  withQuality:(CGInterpolationQuality)quality finished:(MysticBlockSender)finished;
+ (CGSize) sizeInPixels:(UIImage *) source;
+ (UIImage *)constrainImage:(UIImage *)source toSize:(CGSize)size  withQuality:(CGInterpolationQuality)quality finished:(MysticBlockSender)finished;
+ (CGSize) maximumImageSize;

+ (NSInteger)bytesInImage:(UIImage *)image;
+ (MysticImage*) image:(UIImage *)img options:(MysticCacheImageKey *)options;
+ (UIColor*) image:(UIImage *)img colorAtPoint:(CGPoint)point;

+ (UIImage *) image:(UIImage *)inputImageObj size:(CGSize)newSize backgroundColor:(UIColor *)backgroundColor;
+ (UIImage *) image:(UIImage *)inputImageObj size:(CGSize)newSize backgroundColor:(UIColor *)backgroundColor mode:(MysticStretchMode)mode;

+ (UIImage *) maskedImage:(UIImage *)sourceImage mask:(UIImage *)maskImage size:(CGSize)newSize;
+ (id) maskedImage:(UIImage *)sourceImage mask:(UIImage *)maskImage size:(CGSize)newSize backgroundColor:(UIColor *)bgcolor;

+ (UIImage *) grayScaleImage:(UIImage*)originalImage;
+ (UIImage *)maskImage:(UIImage *)img normalMask:(UIImage *)maskImage;
+ (UIImage *) blendImage:(UIImage *)foregroundImage withImage:(UIImage *)bgImg blendMode:(MysticFilterType)blendMode alpha:(CGFloat)alpha;


+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)aperture withOrientation:(UIImageOrientation)orientation;
+ (void) draw:(UIImage *)img color:(UIColor *)color rect:(CGRect)rect bounds:(CGRect)bounds context:(CGContextRef)context contentMode:(UIViewContentMode)contentMode;

#pragma mark - Instance Methods

- (void) setInfo:(MysticCacheImageKey *)newInfo;
- (BOOL) saveToCache;
- (BOOL) storeToMemory;
- (BOOL) storeToDisk;
- (BOOL) storeTemporarily;

@end

