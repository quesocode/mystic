//
//  MysticImage.m
//  Mystic
//
//  Created by travis weerts on 1/31/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MysticImage.h"
#import "MysticUI.h"
#import "UIColor+Mystic.h"
#import "UserPotionManager.h"
#import "MysticCacheImage.h"
#import "UIImage+PDF.h"
#import "MysticLayersView.h"
#import "JPNG.h"
#import "UIColor+Mystic.h"
#import "MysticShapesKit.h"
#import "MysticUtility.h"

@implementation MysticImage


@synthesize
    tag=_tag,
    cacheKey=_cacheKey,
    cache=__cache,
    type=_type,
    saveToDisk=_saveToDisk,
    saveToMemory=_saveToMemory,
    option=__option,
    quality=_quality,
    info=_info;

+ (id) imageNamed:(NSString *)imageName;
{
//    UIImage *img = [UIImage imageNamed:imageName];
//    return [[self class] imageWithImage:img];
    
    return [[self class] image:imageName];
}
+ (id) imageWithCGImage:(CGImageRef)cgImage scale:(CGFloat)scale orientation:(UIImageOrientation)orientation;
{
    MysticImage *img = [[[self class] alloc] initWithCGImage:cgImage scale:scale orientation:orientation];
    return [img autorelease];
}
+ (id) imageWithCGImage:(CGImageRef)cgImage;
{
    MysticImage *img = [[[self class] alloc] initWithCGImage:cgImage];
    return [img autorelease];
}
+ (id) imageWithData:(NSData *)data;
{
    MysticImage *img = [[[self class] alloc] initWithData:data];
    return [img autorelease];
}
+ (id) imageWithData:(NSData *)data scale:(CGFloat)scale;
{
    MysticImage *img = [[[self class] alloc] initWithData:data scale:scale];
    return [img autorelease];
}
+ (id) imageWithImage:(UIImage *)inImage;
{
    if(!inImage || [inImage isKindOfClass:[self class]]) return (MysticImage *)inImage;
    MysticImage *img = [[[self class] alloc] initWithCGImage:inImage.CGImage scale:inImage.scale orientation:inImage.imageOrientation];
    return [img autorelease];
}
+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+ (id)imageByApplyingAlpha:(CGFloat) alpha toImage:(UIImage *)inImage {
    UIGraphicsBeginImageContextWithOptions(inImage.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, inImage.size.width, inImage.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, inImage.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [MysticImage imageWithCGImage:newImage.CGImage];
}


+ (id) blurredImage:(UIImage *)img;
{
    return [[self class] blurredImage:img blur:1 tintColor:[UIColor clearColor]];
}
+ (id) blurredImage:(UIImage *)img blur:(CGFloat)blurLevel tintColor:(id)tintColor;
{
    return img;
}
+ (MysticImage*)downsampledImage:(UIImage *)img;
{
    NSData *imageAsData = UIImageJPEGRepresentation(img, 0.001);
    MysticImage *downsampledImaged = [MysticImage imageWithData:imageAsData];
    return downsampledImaged;
}

+ (id) image:(id)source ;
{
    return [[self class] image:source size:MysticSizeOriginal color:nil backgroundColor:nil contentMode:UIViewContentModeScaleToFill];

}



+ (id) image:(id)source color:(id)color;
{
    return [[self class] image:source size:MysticSizeOriginal color:color backgroundColor:nil contentMode:UIViewContentModeScaleToFill];


}
+ (id) image:(id)source size:(CGSize)size;
{
    return [[self class] image:source size:size color:nil backgroundColor:nil contentMode:UIViewContentModeScaleToFill];


}
+ (id) image:(id)source size:(CGSize)size color:(id)color;
{
    return [[self class] image:source size:size color:color backgroundColor:nil contentMode:UIViewContentModeScaleToFill];


}
+ (id) image:(id)source size:(CGSize)size contentMode:(UIViewContentMode)contentMode;
{
    return [[self class] image:source size:size color:nil backgroundColor:nil contentMode:contentMode];

}
+ (id) image:(id)source size:(CGSize)size color:(id)color  contentMode:(UIViewContentMode)contentMode;
{
    return [[self class] image:source size:size color:color backgroundColor:nil contentMode:contentMode];

}
+ (id) image:(id)source size:(CGSize)size color:(id)color backgroundColor:(id)bgColor;
{
    return [[self class] image:source size:size color:color backgroundColor:bgColor contentMode:UIViewContentModeScaleToFill];

}
+ (id) image:(id)_sourceImageInput size:(CGSize)atSize color:(id)color backgroundColor:(id)bgColor  contentMode:(UIViewContentMode)contentMode;
{
    if(CGSizeEqualToSize(atSize, CGSizeZero)) { DLogError(@"trying to draw 0 sized image"); return nil; }
    UIImage *img = nil;
    BOOL hasResized = CGSizeEqualToSize(atSize, MysticSizeOriginal);
    BOOL _hasResized = hasResized;
    BOOL hasColored = NO;
    if([_sourceImageInput isKindOfClass:[UIImage class]]) img = _sourceImageInput;
    else if([_sourceImageInput isKindOfClass:[NSString class]])
    {
        if([_sourceImageInput hasSuffix:@":"])
        {
            img = [MysticShapesKit image:NSSelectorFromString(_sourceImageInput) frame:CGRectSize(atSize) bounds:CGRectUnknown color:color scale:0 contentMode:contentMode quality:-1];
            hasResized = YES;
            hasColored = YES;
        }
        else
        {
            if([_sourceImageInput hasSuffix:@".pdf"] || [_sourceImageInput hasSuffix:@".asset"])
            {
                _sourceImageInput = [_sourceImageInput hasSuffix:@".asset"] ? [_sourceImageInput stringByReplacingOccurrencesOfString:@".asset" withString:@""] : _sourceImageInput;
                if(hasResized) img = [ UIImage originalSizeImageWithPDFNamed:_sourceImageInput ];
                else
                {
                    switch (contentMode) {
                        case UIViewContentModeScaleToFill:
                            if(!MysticSizeHasUnknown(atSize)) img = [ UIImage imageWithPDFNamed:_sourceImageInput fitSize:atSize ];
                            else if(MysticSizeWidthOnly(atSize)) img = [ UIImage imageWithPDFNamed:_sourceImageInput atWidth:atSize.width ];
                            else img = [ UIImage imageWithPDFNamed:_sourceImageInput atHeight:atSize.height ];
                            break;
                        default: img = [ UIImage imageWithPDFNamed:_sourceImageInput atSize:atSize ]; break;
                    }
                }
                hasResized = YES;
            }
            else img = [UIImage imageNamed:_sourceImageInput];
            
            if(color)
            {
                img = [[self class] image:img withColor:color backgroundColor:bgColor];
                hasColored = YES;
            }
        }
    }
    else if([_sourceImageInput isKindOfClass:[NSNumber class]])
    {
        img = (id)[MysticIcon iconForType:[_sourceImageInput integerValue] size:atSize color:color  backgroundColor:bgColor];
        hasColored = YES;
    }
    
    

    
    if(!hasResized && !CGSizeEqualToSize(img.size, atSize) && !CGSizeIsUnknownOrZero(atSize))
    {
        CGSize filteredSize = CGSizeFilterUnknown(atSize);
        CGRect imageBounds = [MysticUI rectWithSize:filteredSize];
        CGRect drawRect = [MysticUI rectWithSize:filteredSize];
        if(!CGSizeEqualRatio(img.size, filteredSize)) drawRect = [MysticUI aspectFit:[MysticUI rectWithSize:img.size] bounds:imageBounds];
        UIGraphicsBeginImageContextWithOptions(filteredSize, NO, img.scale);
        [img drawInRect:drawRect];
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    if(color && !hasColored) img = [[self class] image:img withColor:color  backgroundColor:bgColor];
    return img && ![img isKindOfClass:[MysticImage class]] ? [[self class] imageWithImage:img] : (MysticImage *)img;
}
+ (id) backgroundImageWithColor:(id)color;
{
    return [self backgroundImageWithColor:color size:CGSizeMake(10, 10)];
}
+ (id) backgroundImageWithColor:(id)color size:(CGSize)size;
{
    return [[self class] backgroundImageWithColor:color size:size scale:0];
}
+ (id) backgroundImageWithColor:(id)color size:(CGSize)size scale:(CGFloat)scale;
{
    if(!color || ([color isKindOfClass:[NSNumber class]] && MysticColorIsEmpty([color integerValue]))) return nil;
    if(![color isKindOfClass:[NSArray class]]) color = [MysticColor color:color];
    if(!color) return nil;
        
    
    NSString *imgTag = nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if([color isKindOfClass:[NSArray class]] && [(NSArray *)color count] <= 1)
    {
        color = [(NSArray *)color lastObject];
        color = color ? color : [UIColor blackColor];
    }
    if([color isKindOfClass:[UIColor class]])
    {
        UIColor *fillColor = (UIColor *)color;
        
        [fillColor setFill];
        CGContextFillRect(context, rect);
        imgTag = ColorToString(fillColor);
    }
    else if([color isKindOfClass:[NSArray class]])
    {
        NSArray *colors = color;
        int colorCount = colors.count;
        NSMutableArray *gradientColors = [[NSMutableArray alloc] initWithCapacity:colorCount];
        
        CGFloat locations[colorCount];
        
        CGFloat currentPosition = 0.0;
        CGFloat colorPosition = 0.0;
        CGFloat colorWidth = 1.0;
        CGFloat remainingPosition = 1.0;
        id _color;
        id _finalColor;
        int x = 0;
        int remainingColors = colorCount;
        UIColor *aColor;

        NSMutableArray *gradientTags = [NSMutableArray array];
        for(x=0;x<colorCount;x++)
        {
            _finalColor = nil;
            aColor = nil;
            _color = [colors objectAtIndex:x];
            colorWidth = (remainingPosition / remainingColors);
            
            
            colorPosition = ((x+1)==colorCount) ? 1.0 : (x == 0 ? 0 : currentPosition);
            
            if([_color isKindOfClass:[UIColor class]])
            {
                aColor = _color;
            }
            else
            {
                if([_color isKindOfClass:[NSString class]])
                {
                    _color = [_color isKindOfClass:[NSString class]] ? _color : [NSString stringWithFormat:@"%@", _color];
                    NSArray *colorInfo = [_color componentsSeparatedByString:@"|"];
                    if([colorInfo count] > 1)
                    {
                        colorPosition = (CGFloat)[[colorInfo objectAtIndex:1] floatValue];
                        _color = [colorInfo objectAtIndex:0];
                    }
                    
                }
                else if([_color isKindOfClass:[NSArray class]])
                {
                    id __color = [(NSArray *)_color objectAtIndex:0];
                    if([__color isKindOfClass:[UIColor class]])
                    {
                        aColor = __color;
                        _finalColor = __color;
                    }
                    if([(NSArray *)_color count] > 1)
                    {
                        colorPosition = [[(NSArray *)_color objectAtIndex:1] floatValue];
                    }
                    
                }
                if(!_finalColor)
                {
                    _finalColor = [_color isKindOfClass:[NSString class]] ? _color : [NSString stringWithFormat:@"%@", _color];
                    aColor = [UIColor string:_finalColor];
                }
            }
            
            if(aColor != nil)
            {
                [gradientColors addObject:(id)[aColor CGColor]];
            }
            [gradientTags addObject:[NSString stringWithFormat:@"rgb%@;pos(%2.2f);", ColorToString(aColor), colorPosition]];

            remainingPosition -= colorWidth;
            remainingColors--;
            

            
            locations[x] = colorPosition;
            currentPosition += colorWidth;
            
        }
        
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) gradientColors, locations);
        
        CGContextDrawLinearGradient(context,
                                    gradient,
                                    CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect)),
                                    CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect)),
                                    0);
        
        CGColorSpaceRelease(colorSpace);
        CGGradientRelease(gradient);
        [gradientColors release];
        imgTag = [gradientTags componentsJoinedByString:@"_"];
        
    }
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    newImage = [UIImage imageWithCGImage:newImage.CGImage scale:newImage.scale orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();
    MysticImage *img = [[self class] imageWithImage:newImage];
    img.tag = imgTag;
    return img;
}
+ (id) image:(UIImage *)img withColor:(id)color;
{
    return [[self class] image:img withColor:color backgroundColor:nil];
}
+ (id) image:(UIImage *)img withColor:(id)color backgroundColor:(id)bgColor;
{
    if(!img) return nil;
    if(!color || ([color isKindOfClass:[NSNumber class]] && MysticColorIsEmpty([color integerValue]))) return (MysticImage *)img;
    color = [MysticColor color:color];
    UIColor *c2 = [color isKindOfClass:[UIColor class]] ? (id)color : nil;
    if((!color || (c2.alpha <= 0)) && !bgColor) return img;
    
    CGRect rect = [MysticUI rectWithSize:img.size];
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, img.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *newBgColor = bgColor ? [MysticColor color:bgColor] : nil;
    if(newBgColor && newBgColor.alpha > 0)
    {
        [newBgColor setFill];
        CGContextFillRect(context, rect);
    }
    [MysticIcon draw:img color:color rect:rect context:context];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    newImage = [UIImage imageWithCGImage:newImage.CGImage scale:img.scale orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();
    return [[self class] imageWithImage:newImage];
}
#pragma mark - Drawing Context functions

+ (void) draw:(UIImage *)img color:(UIColor *)color context:(CGContextRef)context;
{
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    [self draw:img color:color rect:rect context:context];
}
+ (void) draw:(UIImage *)img color:(UIColor *)color rect:(CGRect)rect context:(CGContextRef)context;
{
    [self draw:img color:color rect:rect bounds:rect context:context];
}
+ (void) draw:(UIImage *)img color:(UIColor *)color rect:(CGRect)rect bounds:(CGRect)bounds context:(CGContextRef)context;
{
    [[self class] draw:img color:color rect:rect bounds:bounds context:context contentMode:UIViewContentModeScaleAspectFit];
}
+ (void) draw:(UIImage *)img color:(UIColor *)color rect:(CGRect)rect bounds:(CGRect)bounds context:(CGContextRef)context contentMode:(UIViewContentMode)contentMode;
{
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    [color setFill];
    
    CGRect aspectRect = rect;
    aspectRect = CGRectWithContentMode(rect, bounds, contentMode);



    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1, -1);

    CGContextClipToMask(context, aspectRect, img.CGImage);
    CGContextAddRect(context, aspectRect);
    CGContextDrawPath(context,kCGPathFill);
}
#pragma mark -
+ (UIImage *)constrainImage:(UIImage *)source toSize:(CGSize)size  withQuality:(CGInterpolationQuality)quality finished:(MysticBlockSender)finished;
{
    
    [source retain];
    CGSize aimgSize = [MysticImage sizeInPixels:source];
    
    if(aimgSize.width > size.width || aimgSize.height > size.height)
    {
        __block CGSize mysize = size;
        __block CGSize imgSize = aimgSize;
        
        [source retain];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
            
            
                UIImageOrientation sizeOr = UIImageOrientationUp;
                CGFloat aspect = imgSize.height/imgSize.width;
                if(aspect >= 1.0) { //square or portrait
                    mysize = CGSizeMake((mysize.height * imgSize.width)/imgSize.height,mysize.height);
                } else { // landscape
                    mysize = CGSizeMake(mysize.width,(mysize.width * imgSize.height)/imgSize.width);
                }
                NSString *imOr;
                switch(source.imageOrientation)
                {
                    case UIImageOrientationUp:
                    {
//                        imOr = @"UIImageOrientationUp";
                        break;
                    }
                    case UIImageOrientationDown:
                    {
//                        imOr = @"UIImageOrientationDown";
                        break;
                    }
                    case UIImageOrientationLeft:
                    {
//                        imOr = @"UIImageOrientationLeft";
                        mysize = CGSizeMake(mysize.height, mysize.width);
                        break;
                    }
                    case UIImageOrientationRight:
                    {
//                        imOr = @"UIImageOrientationRight";
                        mysize = CGSizeMake(mysize.height, mysize.width);
                        break;
                    }
                    case UIImageOrientationUpMirrored:
                    {
//                        imOr = @"UIImageOrientationUpMirrored";
                        break;
                    }
                    case UIImageOrientationDownMirrored:
                    {
//                        imOr = @"UIImageOrientationDownMirrored";
                        break;
                    }
                    case UIImageOrientationLeftMirrored:
                    {
//                        imOr = @"UIImageOrientationLeftMirrored";
                        mysize = CGSizeMake(mysize.height, mysize.width);
                        break;
                    }
                    case UIImageOrientationRightMirrored:
                    {
//                        imOr = @"UIImageOrientationRightMirrored";
                        mysize = CGSizeMake(mysize.height, mysize.width);
                        break;
                    }
                    default:
                    {
                        imOr = @"unknown";
                        break;
                    }
                }

                CGImageRef cgImage  = [MysticImage newScaledImage:source.CGImage withOrientation:source.imageOrientation toSize:mysize withQuality:quality];
                __unsafe_unretained __block UIImage * result = [[UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp] retain];
                CGImageRelease(cgImage);
                if(finished)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        finished([result autorelease]);
                        
                    });
                }
                else
                {
                    [result autorelease];
                }
                [source release];
            
        });
    }
    else if(finished)
    {
        __unsafe_unretained __block UIImage *_source = source ? [source retain] : nil;
        dispatch_async(dispatch_get_main_queue(), ^{

            finished([_source autorelease]);
        });
    }
    return [source autorelease];
}

+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect {
    
    //    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, imageToCrop.size.width, imageToCrop.size.height);
    
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [imageToCrop drawInRect:drawRect];
    
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
    
    //return [UIImage imageByCropping:imageToCrop toRect:aperture withOrientation:UIImageOrientationUp];
}

// Draw a full image into a crop-sized area and offset to produce a cropped, rotated image
+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)aperture withOrientation:(UIImageOrientation)orientation {
    
    // convert y coordinate to origin bottom-left
    CGFloat orgY = aperture.origin.y + aperture.size.height - imageToCrop.size.height,
    orgX = -aperture.origin.x,
    scaleX = 1.0,
    scaleY = 1.0,
    rot = 0.0;
    CGSize size;
    
    switch (orientation) {
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            size = CGSizeMake(aperture.size.height, aperture.size.width);
            break;
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            size = aperture.size;
            break;
        default:
            assert(NO);
            return nil;
    }
    
    
    switch (orientation) {
        case UIImageOrientationRight:
            rot = 1.0 * M_PI / 2.0;
            orgY -= aperture.size.height;
            break;
        case UIImageOrientationRightMirrored:
            rot = 1.0 * M_PI / 2.0;
            scaleY = -1.0;
            break;
        case UIImageOrientationDown:
            scaleX = scaleY = -1.0;
            orgX -= aperture.size.width;
            orgY -= aperture.size.height;
            break;
        case UIImageOrientationDownMirrored:
            orgY -= aperture.size.height;
            scaleY = -1.0;
            break;
        case UIImageOrientationLeft:
            rot = 3.0 * M_PI / 2.0;
            orgX -= aperture.size.height;
            break;
        case UIImageOrientationLeftMirrored:
            rot = 3.0 * M_PI / 2.0;
            orgY -= aperture.size.height;
            orgX -= aperture.size.width;
            scaleY = -1.0;
            break;
        case UIImageOrientationUp:
            break;
        case UIImageOrientationUpMirrored:
            orgX -= aperture.size.width;
            scaleX = -1.0;
            break;
    }
    
    // set the draw rect to pan the image to the right spot
    CGRect drawRect = CGRectMake(orgX, orgY, imageToCrop.size.width, imageToCrop.size.height);
    
    // create a context for the new image
    UIGraphicsBeginImageContextWithOptions(size, NO, imageToCrop.scale);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    // apply rotation and scaling
    CGContextRotateCTM(gc, rot);
    CGContextScaleCTM(gc, scaleX, scaleY);
    // draw the image to our clipped context using the offset rect
    CGContextDrawImage(gc, drawRect, imageToCrop.CGImage);
    
    // pull the image from our cropped context
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    
    // pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    // Note: this is autoreleased
    return cropped;
}
+ (UIImage *)scaleImage:(UIImage *)source scale:(float)scale;
{
    return [self scaleImage:source scale:scale withQuality:kCGInterpolationDefault];
}
+ (UIImage *)scaleImage:(UIImage *)source scale:(float)scale withQuality:(CGInterpolationQuality)quality;
{
    return [self scaledImage:source toSize:CGSizeScale(CGSizeImage(source), scale) withQuality:quality];
}
+ (UIImage *)scaledImage:(UIImage *)source toSize:(CGSize)size  withQuality:(CGInterpolationQuality)quality finished:(MysticBlockSender)finished;
{
    CGImageRef cgImage  = [MysticImage newScaledImage:source.CGImage withOrientation:source.imageOrientation toSize:size withQuality:quality];
    UIImage * result = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    if(finished) finished(result);
    return result;
}
+ (UIImage *)scaledImage:(UIImage *)source toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality;
{
    CGImageRef cgImage  = [MysticImage newScaledImage:source.CGImage withOrientation:source.imageOrientation toSize:size withQuality:quality];
    UIImage * result = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return result;
}
+ (UIImage *)scaledImageWithCGImage:(CGImageRef)source toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality;
{
    CGImageRef cgImage  = [MysticImage newScaledImage:source withOrientation:UIImageOrientationUp toSize:size withQuality:quality];
    UIImage * result = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return result;
}

+ (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality;
{
    CGSize srcSize = size;
    CGFloat rotation = 0.0;
    
    switch(orientation)
    {
        case UIImageOrientationDown: {
//        case UIImageOrientationUp: {
            rotation = 0;
        } break;
//        case UIImageOrientationDown: {
        case UIImageOrientationUp: {
            rotation = M_PI;
        } break;
        case UIImageOrientationLeft:{
            rotation = M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        case UIImageOrientationRight: {
            rotation = -M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        default: break;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
//    CGContextRef context = CGBitmapContextCreate(NULL,
//                                                 size.width,
//                                                 size.height,
//                                                 8, //CGImageGetBitsPerComponent(source),
//                                                 0,
//                                                 CGImageGetColorSpace(source),
//                                                 kCGImageAlphaNoneSkipFirst//CGImageGetBitmapInfo(source)
//                                                 );
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  (size.width/2),  size.height/2);
    CGContextScaleCTM(context, -1, 1);
    CGContextRotateCTM(context,rotation);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return resultRef;
}


+ (UIImage *) image:(UIImage *)inputImageObj size:(CGSize)newSize backgroundColor:(UIColor *)backgroundColor;
{
    return [self image:inputImageObj size:newSize backgroundColor:backgroundColor mode:MysticStretchModeAspectFit];
}

+ (UIImage *) image:(UIImage *)inputImageObj size:(CGSize)newSize backgroundColor:(UIColor *)backgroundColor mode:(MysticStretchMode)mode;
{
    UIImage *newImg = inputImageObj;
    CGRect bounds = [MysticUI rectWithSize:newSize];
    CGRect pos = [MysticUI rectWithSize:inputImageObj.size];
    
    switch (mode) {
        case MysticStretchModeFill:
        {
            pos = bounds;
            break;
        }
        case MysticStretchModeAspectFit:
        {
            pos = [MysticUI aspectFit:pos bounds:bounds];
            break;
        }
        case MysticStretchModeAspectFill:
        {
            CGFloat iratio = 1;
            if(bounds.size.width > bounds.size.height)
            {
                iratio = inputImageObj.size.width/inputImageObj.size.height;
                pos.size.width = bounds.size.width;
                pos.size.height = pos.size.width /iratio;
                
            }
            else
            {
                iratio = inputImageObj.size.height/inputImageObj.size.width;
                pos.size.height = bounds.size.height;
                pos.size.width = pos.size.height/iratio;
            }
            
            pos.origin.x = ((bounds.size.width)/2) - ((pos.size.width)/2);
            pos.origin.y = ((bounds.size.height)/2) - ((pos.size.height)/2);
            
            break;
        }
            
        default: break;
    }
    

    
    
    UIGraphicsBeginImageContextWithOptions(newSize, !backgroundColor ||  backgroundColor.alpha < 1 ? NO : YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationDefault);

    if(backgroundColor)
    {
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, newSize.width, newSize.height));
    }

    [inputImageObj drawInRect:pos];
    UIImage *rimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rimg;
    
    
}
+ (UIImage *) grayScaleImage:(UIImage*)originalImage;
{
    //create gray device colorspace.
    CGColorSpaceRef space = CGColorSpaceCreateDeviceGray();
    //create 8-bit bimap context without alpha channel.
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, originalImage.size.width, originalImage.size.height, 8, 0, space, kCGImageAlphaNone);
    CGColorSpaceRelease(space);
    //Draw image.
    CGRect bounds = CGRectMake(0.0, 0.0, originalImage.size.width, originalImage.size.height);
    CGContextDrawImage(bitmapContext, bounds, originalImage.CGImage);
    //Get image from bimap context.
    CGImageRef grayScaleImage = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    //image is inverted. UIImage inverts orientation while converting CGImage to UIImage.
    UIImage* image = [UIImage imageWithCGImage:grayScaleImage];
    CGImageRelease(grayScaleImage);
    return image;
}

+ (UIImage *) maskedImage:(UIImage *)sourceImage mask:(UIImage *)maskImage size:(CGSize)newSize;
{
    return [[self class] maskedImage:sourceImage mask:maskImage size:newSize backgroundColor:nil];
}
+ (id) maskedImage:(UIImage *)sourceImage mask:(UIImage *)maskImage size:(CGSize)newSize backgroundColor:(UIColor *)bgcolor;
{
    if(!maskImage) return sourceImage;
    // create image size rect
    CGRect newRect = CGRectZero;
    newRect.size = newSize;
//    BOOL isOpaque = bgcolor && bgcolor.alpha >= 1;
    // draw source image
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 1.0f);
    [sourceImage drawInRect:newRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // draw mask image
    [maskImage drawInRect:newRect blendMode:kCGBlendModeNormal alpha:1.0f];
    UIImage *maskImage2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *newImage2 = [MysticImage maskImage:newImage normalMask:maskImage2];
    newImage2 = [UIImage imageWithData:UIImagePNGRepresentation(newImage2)];
    if(bgcolor)
    {
        UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 1.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [bgcolor setFill];
        CGContextFillRect(context, CGRectMake(0, 0, newSize.width, newSize.height));
        [newImage2 drawInRect:newRect];
        newImage2 = [UIImage imageWithData:UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext())];
        UIGraphicsEndImageContext();


    }

    return newImage2;
}


+ (UIImage *)maskImage:(UIImage *)img normalMask:(UIImage *)maskImage;
{
    if(!maskImage) return img;
    CGFloat width = CGImageGetWidth(maskImage.CGImage);
    CGFloat height = CGImageGetHeight(maskImage.CGImage);
    CGFloat bitsPerPixel = CGImageGetBitsPerPixel(maskImage.CGImage);
    CGFloat bytesPerRow = CGImageGetBytesPerRow(maskImage.CGImage);
    CGDataProviderRef providerRef = CGImageGetDataProvider(maskImage.CGImage);
    CGImageRef imageMask = CGImageMaskCreate(width, height, 8, bitsPerPixel, bytesPerRow, providerRef, NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask(img.CGImage, imageMask);
    CGImageRelease(imageMask);
    
    
    CGContextRef context = CGBitmapContextCreate(nil,
                                                 CGImageGetWidth(maskedImageRef),
                                                 CGImageGetHeight(maskedImageRef),
                                                 CGImageGetBitsPerComponent(maskedImageRef),
                                                 CGImageGetBytesPerRow(maskedImageRef),
                                                 CGImageGetColorSpace(maskedImageRef),
                                                 CGImageGetBitmapInfo(maskedImageRef));
    
    CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(maskedImageRef), CGImageGetHeight(maskedImageRef));
    CGContextDrawImage(context, imageRect, maskedImageRef);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *maskedImage = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    CGContextRelease(context);
    CGImageRelease(maskedImageRef);
    
    return maskedImage;
    
//    
//    UIImage *returnImage = [UIImage imageWithCGImage:maskedImage];
//    CGImageRelease(maskedImage);
//    return returnImage;
}

+ (UIImage *)maskedColorImage:(UIColor *)imgColor mask:(UIImage *)maskImage;
{
    UIImage *grayMaskImg = [MysticImage grayScaleImage:maskImage];
    CGFloat width = CGImageGetWidth(grayMaskImg.CGImage);
    CGFloat height = CGImageGetHeight(grayMaskImg.CGImage);
    CGFloat bitsPerPixel = CGImageGetBitsPerPixel(grayMaskImg.CGImage);
    CGFloat bytesPerRow = CGImageGetBytesPerRow(grayMaskImg.CGImage);
    CGDataProviderRef providerRef = CGImageGetDataProvider(grayMaskImg.CGImage);
    CGImageRef imageMask = CGImageMaskCreate(width, height, 8, bitsPerPixel, bytesPerRow, providerRef, NULL, false);
    UIImage *img = [[self class] backgroundImageWithColor:imgColor size:maskImage.size scale:maskImage.scale];
    CGImageRef maskedImage = CGImageCreateWithMask(img.CGImage, imageMask);
    CGImageRelease(imageMask);
    UIImage *returnImage = [UIImage imageWithCGImage:maskedImage];
    CGImageRelease(maskedImage);
    return returnImage;
}
+ (UIImage *)maskImage:(UIImage *)img mask:(UIImage *)maskImage;
{
    UIImage *grayMaskImg = [MysticImage grayScaleImage:maskImage];
    CGFloat width = CGImageGetWidth(grayMaskImg.CGImage);
    CGFloat height = CGImageGetHeight(grayMaskImg.CGImage);
    CGFloat bitsPerPixel = CGImageGetBitsPerPixel(grayMaskImg.CGImage);
    CGFloat bytesPerRow = CGImageGetBytesPerRow(grayMaskImg.CGImage);
    CGDataProviderRef providerRef = CGImageGetDataProvider(grayMaskImg.CGImage);
    CGImageRef imageMask = CGImageMaskCreate(width, height, 8, bitsPerPixel, bytesPerRow, providerRef, NULL, false);
    
    CGImageRef maskedImage = CGImageCreateWithMask(img.CGImage, imageMask);
    CGImageRelease(imageMask);
    UIImage *returnImage = [UIImage imageWithCGImage:maskedImage];
    CGImageRelease(maskedImage);
    return returnImage;
}

+ (NSInteger)bytesInImage:(UIImage *)image; {
    CGImageRef imageRef = [image CGImage];
    return CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef);
}
+ (id)renderedImageWithBounds:(CGSize)bounds view:(UIView *)view finished:(MysticBlockObject)finished;
{
    CGSize renderSize;
    
    CGRect fit = [MysticUI aspectFit:[MysticUI rectWithSize:view.frame.size] bounds:[MysticUI rectWithSize:bounds]];
    renderSize = fit.size;
    return [self imageByRenderingView:nil size:renderSize scale:0 view:view finished:finished];
}
+ (id)renderedImageWithSize:(CGSize)renderSize  view:(UIView *)view finished:(MysticBlockObject)finished;
{
    return [self imageByRenderingView:nil size:renderSize scale:0 view:view finished:finished];
}
+ (id)imageByRenderingView:(UIImage *)img size:(CGSize)renderSize scale:(CGFloat)scale  view:(UIView *)view finished:(MysticBlockObject)finished;
{
    return [self imageByRenderingView:img size:renderSize scale:scale view:view bgColor:nil finished:finished];
}
+ (id)imageByRenderingView:(UIImage *)img size:(CGSize)renderSize scale:(CGFloat)scale view:(UIView *)view bgColor:(UIColor *)bgColor finished:(MysticBlockObject)finished;
{
    BOOL scaleCTM = YES;
    CGRect rect = CGRectZero;
    rect.size = renderSize;
    CGSize layersViewSize = view.bounds.size;
    CGRect originalFrame = CGRectSize(layersViewSize);
    CGSize bfls = layersViewSize;
    if(CGSizeIsUnknown(renderSize))
    {
        renderSize = view.frame.size;
//        scaleCTM = NO;
        rect.size = renderSize;
    }
    else if([view respondsToSelector:@selector(originalFrame)])
    {
        CGRect originalFrame1 = [(MysticLayersView *)view originalFrame];
        if(!(CGRectEqualToRect(originalFrame1, CGRectZero) || CGRectEqualToRect(originalFrame1, CGRectUnknown)))
        {
            originalFrame = originalFrame1;
            layersViewSize = originalFrame.size;
        }
    }
    CGScale scaleSize = CGScaleOfSizes(renderSize, layersViewSize);
    if([view respondsToSelector:@selector(prepareForImageCapture:scale:finished:)]) {
        __unsafe_unretained __block MysticBlockObject _f = finished ? Block_copy(finished) : nil;
        __unsafe_unretained __block UIImage *_img = img ? [img retain] : nil;
        __unsafe_unretained __block UIColor *_bgColor = bgColor ? [bgColor retain] : nil;
        __unsafe_unretained __block UIView *_view = view ? [view retain] : nil;
        [(MysticOverlaysView *)view prepareForImageCapture:renderSize scale:scaleSize finished:^{
            
            NSMutableString *str = [NSMutableString stringWithFormat:@"MysticImageRender:  \n\tView: %@  %@\n\tScale: %@\n\n\tSubs:", _view.class, f(_view.frame), sc(scaleSize)];
            [str appendString:subviewsShadowStr(_view, nil, 0)];
//            DLogRender(@"%@", str);
            
            
            UIGraphicsBeginImageContextWithOptions(rect.size, _view.opaque || (_bgColor && _bgColor.alpha >= 1), scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
            CGContextSetShouldSmoothFonts(context, YES);
            CGContextSetShouldAntialias(context, YES);
            if(_bgColor)
            {
                [_bgColor setFill];
                CGContextFillRect(context, rect);
            }
            if(_img)
            {
                CGContextSaveGState(context);
                CGRect irect = CGRectMake(0, 0, _img.size.width, _img.size.height);
                irect.origin = CGPointMake(rect.size.width/2 - irect.size.width/2, rect.size.height/2 - irect.size.height/2);
                irect.origin = CGPointZero;
                irect.size = rect.size;
                CGContextTranslateCTM(context, 0, rect.size.height);
                CGContextScaleCTM(context, 1.0, -1.0);
                CGContextDrawImage(context, irect, _img.CGImage);
                CGContextRestoreGState(context);
            }
            if(scaleCTM && (layersViewSize.width != renderSize.width || layersViewSize.height != renderSize.height)) CGContextScaleCTM(context, scaleSize.width, scaleSize.height);
            [_view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if([_view respondsToSelector:@selector(finishedImageCapture:scale:)]) [(MysticOverlaysView *)_view finishedImageCapture:renderSize scale:scaleSize];
            if(_f) { _f([MysticImage imageWithImage:resultingImage]); Block_release(_f); }
            if(_bgColor) [_bgColor release];
            if(_img) [_img release];
            if(_view) [_view release];
        }];
        return nil;
    }
//    DLog(@"render rect:  %@   img: %@   layers: %@  original: %@", f(rect), ILogStr(img), s(layersViewSize), f(originalFrame));
    UIGraphicsBeginImageContextWithOptions(rect.size, view.opaque || (bgColor && bgColor.alpha >= 1), scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldSmoothFonts(context, YES);
    CGContextSetShouldAntialias(context, YES);
    if(bgColor)
    {
        [bgColor setFill];
        CGContextFillRect(context, rect);
    }
    if(img)
    {
        CGContextSaveGState(context);
        CGRect irect = CGRectMake(0, 0, img.size.width, img.size.height);
        irect.origin = CGPointMake(rect.size.width/2 - irect.size.width/2, rect.size.height/2 - irect.size.height/2);
        irect.origin = CGPointZero;
        irect.size = rect.size;
        CGContextTranslateCTM(context, 0, rect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, irect, img.CGImage);
        CGContextRestoreGState(context);
    }
    if(scaleCTM && (layersViewSize.width != renderSize.width || layersViewSize.height != renderSize.height)) CGContextScaleCTM(context, scaleSize.width, scaleSize.height);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if([view respondsToSelector:@selector(finishedImageCapture:scale:)]) [(MysticOverlaysView *)view finishedImageCapture:renderSize scale:scaleSize];
    return [MysticImage imageWithImage:resultingImage];
}


+ (CGSize) maximumImageSize;
{
    GLint maxTextureSize = [GPUImageContext maximumTextureSizeForThisDevice];
    return CGSizeMake((CGFloat)maxTextureSize, (CGFloat)maxTextureSize);
//    int maxTextureSize;
//    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
//    
//    return (CGSize){(CGFloat)maxTextureSize, (CGFloat)maxTextureSize};
}
+ (CGSize) sizeInPixels:(UIImage *) source;
{
    CGSize imgSize = CGSizeMake(CGImageGetWidth(source.CGImage), CGImageGetHeight(source.CGImage));
    return imgSize;
}
+ (UIColor*) image:(UIImage *)img colorAtPoint:(CGPoint)point;
{
    return nil;
    
	UIColor* color = nil;
	CGImageRef inImage = img.CGImage;
    
    
	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    
    CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
    
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
    
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
    
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
    
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
    
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
    
    
	if (context == NULL) { return nil; /* error */ }
    
//    size_t w = CGImageGetWidth(inImage);
//	size_t h = CGImageGetHeight(inImage);
    size_t w = img.size.width;
//    size_t h = img.size.height;
    
	CGRect rect = {{0,0},img.size};
    
    
	// Draw the image to the bitmap context. Once we draw, the memory
	// allocated for the context for rendering will then contain the
	// raw image data in the specified color space.
	CGContextDrawImage(context, rect, inImage);
    
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
	unsigned char* data = CGBitmapContextGetData (context);
	if (data != NULL) {
		//offset locates the pixel in the data from x,y.
		//4 for 4 bytes of data per pixel, w is width of one row of data.
		int offset = 4*((w*round(point.y))+round(point.x));
		int alpha =  data[offset];
		int red = data[offset+1];
		int green = data[offset+2];
		int blue = data[offset+3];
		color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
	}
    
    
    
    
    
	// When finished, release the context
	CGContextRelease(context);
	// Free image data memory for the context
	if (data) { free(data); }
	return color;
}


+ (UIImage *) blendImage:(UIImage *)foregroundImage withImage:(UIImage *)bgImg blendMode:(MysticFilterType)blendMode alpha:(CGFloat)alpha;
{
    CGRect rect = CGRectMake(0, 0, CGImageGetWidth(foregroundImage.CGImage), CGImageGetHeight(foregroundImage.CGImage));

    UIImage *newImage;
    switch (blendMode) {
        case MysticFilterTypeBlendAdd:
        {
            GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:bgImg];
            GPUImagePicture *topImg = [[GPUImagePicture alloc] initWithImage:foregroundImage];
            
            GPUImageAddBlendFilter *filter = [[GPUImageAddBlendFilter alloc] init];
            [filter forceProcessingAtSize:rect.size];
            [source addTarget:filter];
            [topImg addTarget:filter];
            [filter useNextFrameForImageCapture];

            [source processImage];
            [topImg processImage];
//            newImage = [filter imageFromCurrentlyProcessedOutput];
            newImage = [filter imageFromCurrentFramebuffer];
            
            [filter release];
            [source release];
            [topImg release];
            
            break;
        }
        case MysticFilterTypeBlendSubtract:
        {
            GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:bgImg];
            GPUImagePicture *topImg = [[GPUImagePicture alloc] initWithImage:foregroundImage];
            
            GPUImageSubtractBlendFilter *filter = [[GPUImageSubtractBlendFilter alloc] init];
            [filter forceProcessingAtSize:rect.size];
            [source addTarget:filter];
            [topImg addTarget:filter];
            [filter useNextFrameForImageCapture];

            [source processImage];
            [topImg processImage];
//            newImage = [filter imageFromCurrentlyProcessedOutput];
            newImage = [filter imageFromCurrentFramebuffer];
            
            [filter release];
            [source release];
            [topImg release];
            
            break;
        }
        case MysticFilterTypeBlendDivide:
        {
            GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:bgImg];
            GPUImagePicture *topImg = [[GPUImagePicture alloc] initWithImage:foregroundImage];
            
            GPUImageDivideBlendFilter *filter = [[GPUImageDivideBlendFilter alloc] init];
            [filter forceProcessingAtSize:rect.size];
            [source addTarget:filter];
            [topImg addTarget:filter];
            [filter useNextFrameForImageCapture];

            [source processImage];
            [topImg processImage];
//            newImage = [filter imageFromCurrentlyProcessedOutput];
            newImage = [filter imageFromCurrentFramebuffer];
            
            [filter release];
            [source release];
            [topImg release];
            
            break;
        }
        case MysticFilterTypeBlendLinearBurn:
        {
            GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:bgImg];
            GPUImagePicture *topImg = [[GPUImagePicture alloc] initWithImage:foregroundImage];
            
            GPUImageLinearBurnBlendFilter *filter = [[GPUImageLinearBurnBlendFilter alloc] init];
            [filter forceProcessingAtSize:rect.size];
            [source addTarget:filter];
            [topImg addTarget:filter];
            [filter useNextFrameForImageCapture];

            [source processImage];
            [topImg processImage];
//            newImage = [filter imageFromCurrentlyProcessedOutput];
            newImage = [filter imageFromCurrentFramebuffer];
            
            [filter release];
            [source release];
            [topImg release];
            
            break;
        }
        default:
        {
            UIGraphicsBeginImageContext(rect.size);
            [bgImg drawInRect:rect];
            [foregroundImage drawInRect:rect blendMode:CGBlendModeFromMysticFilterType(blendMode) alpha:alpha];
            newImage = UIGraphicsGetImageFromCurrentImageContext();
            newImage = [UIImage imageWithCGImage:newImage.CGImage scale:foregroundImage.scale orientation:UIImageOrientationUp];
            UIGraphicsEndImageContext();
            break;
        }
    }
    return newImage;
}


#pragma mark - Instance Methods

+ (id) imageFromOptions:(MysticCacheImageKey *)options;
{
    MysticImage *newImage = nil;
    if(options)
    {
        if(options.cache && options.cacheKey)
        {
            UIImage *img = [options.cache cacheImageNamed:options.cacheKey];
            newImage = [MysticImage image:img options:options];
        }
    }
    return newImage;
}
+ (id) image:(UIImage *)img options:(MysticCacheImageKey *)options;
{
    if(!img || ![img respondsToSelector:@selector(CGImage)]) return nil;
    MysticImage *newImage = [[[self class] alloc] initWithCGImage:img.CGImage];
    [newImage setInfo:options];
    return [newImage autorelease];
}
- (void) dealloc;
{
    __cache = nil;
    __option = nil;
    [_cacheKey release], _cacheKey=nil;
    [_tag release], _tag = nil;
    [_info release], _info=nil;
    [_imageFilePath release], _imageFilePath = nil;
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        _saveToMemory = YES;
        _saveToDisk = NO;
        _tag = nil;
        _fromCache = NO;
        _cacheType = MysticCacheTypeNone;
        __option = nil;
        __cache = nil;
        _quality = 1.0f;
        _type = MysticImageTypeUnknown;
    }
    return self;
}
- (void) setCacheKey:(NSString *)cacheKey;
{
    if(_info) _info.cacheKey = cacheKey;
    [_cacheKey release], _cacheKey=nil;
    if(cacheKey) _cacheKey = [cacheKey retain];
}
- (void) setTag:(NSString *)value;
{
    if(_info) _info.tag = value;
    [_tag release], _tag=nil;
    if(value) _tag = [value retain];
}
- (void) setCache:(MysticCache *)value;
{
    if(_info) _info.cache = value;
    __cache=value;
}
- (void) setOption:(MysticOption *)value;
{
    if(_info) _info.option = value;
    __option=value;
}
- (void) setQuality:(CGFloat)value;
{
    if(_info) _info.quality = value;
    _quality = value;
}
- (void) setSaveToDisk:(BOOL)value;
{
    if(_info) _info.saveToDisk = value;
    _saveToDisk = value;
}
- (void) setSaveToMemory:(BOOL)value;
{
    if(_info) _info.saveToMemory = value;
    _saveToMemory = value;
}
- (void) setType:(MysticImageType)type;
{
    if(_info) _info.type = type;
    _type = type;
}
- (NSString *) cacheKey;
{
    return _info && _info.cacheKey ? _info.cacheKey : self.tag;
}
- (NSString *) tag;
{
    return _info && _info.tag ? _info.tag : _tag;
}
- (MysticOption *) option;
{
    return _info && _info.option ? _info.option : __option;
}
- (MysticCache *) cache;
{
    return _info && _info.cache ? _info.cache : __cache;
}
- (MysticImageType) type;
{
    return _info ? _info.type : _type;
}
- (BOOL) saveToDisk;
{
    return _info ? _info.saveToDisk : _saveToDisk;
}
- (BOOL) saveToMemory;
{
    return _info ? _info.saveToMemory : _saveToMemory;
}
- (CGFloat) quality;
{
    return _info ? _info.quality : _quality;
}
- (NSData *) imageData;
{
    switch (self.type) {
        case MysticImageTypeJPNG:
//            return CGImageJPNGRepresentation(self.CGImage, 1.0);
        case MysticImageTypePNG:
            return UIImagePNGRepresentation(self);
        default: break;
    }
    return UIImageJPEGRepresentation(self, (CGFloat)self.quality);
}


- (MysticCacheImageKey *) info;
{
    if(_info) return _info;
    return [MysticCacheImageKey optionsWithImage:self];
}

- (BOOL) saveToCache;
{
    if(self.cache)
    {
        [self.cache storeImage:self imageData:self.imageData forKey:self.cacheKey toDisk:self.saveToDisk toMemory:self.saveToMemory];
        
        ImageCacheLog(@"MysticImage: attempting to SAVE: \r\n\timage: <%p>\r\n\tOptions: %@\r\n\tkey: %@\r\n\tPath: %@\r\n\tCache: %@\r\n\r\n", self, _info, self.cacheKey, [self.cache cachePathForKey:self.cacheKey], self.cache);

        
        
        return YES;
    }
    return NO;
}
- (BOOL) storeToDisk;
{
    if(self.cache)
    {
        [self.cache storeImage:self imageData:self.imageData forKey:self.cacheKey toDisk:YES toMemory:NO];
        ImageCacheLog(@"MysticImage: attempting to store to disk: \r\n\timage: <%p>\r\n\tOptions: %@\r\n\tkey: %@\r\n\tPath: %@\r\n\tCache: %@\r\n\r\n", self, _info, self.cacheKey, [self.cache cachePathForKey:self.cacheKey], self.cache);
        
        return YES;
    }
    return NO;
}

- (BOOL) storeToMemory;
{
    if(self.cache)
    {
        [self.cache storeImage:self imageData:self.imageData forKey:self.cacheKey toDisk:NO toMemory:YES];
        ImageCacheLog(@"MysticImage: attempting to store to memory: \r\n\timage: <%p>\r\n\tOptions: %@\r\n\tkey: %@\r\n\tPath: %@\r\n\tCache: %@\r\n\r\n", self, _info, self.cacheKey, [self.cache cachePathForKey:self.cacheKey], self.cache);
        
        return YES;
    }
    return NO;
}


- (BOOL) storeTemporarily;
{
    MysticCache *tempCache = self.cache;
    
    
    
    
    tempCache = tempCache ? tempCache : [MysticCacheImage layerCache];
    
    DLog(@"STORING IMAGE FOR KEY: %@", self.cacheKey);
    
        [tempCache storeImage:self imageData:self.imageData forKey:self.cacheKey toDisk:NO toMemory:YES];
//        ImageCacheLog(@"MysticImage: attempting to store temporary: \r\n\timage: <%p>\r\n\tOptions: %@\r\n\tkey: %@\r\n\tPath: %@\r\n\tCache: %@\r\n\r\n", self, _info, self.cacheKey, [tempCache cachePathForKey:self.cacheKey], tempCache);
    
        return YES;
 
}


@end
