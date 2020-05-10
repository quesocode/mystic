//
//  UIImage+PECrop.m
//  PhotoCropEditor
//
//  Created by Ernesto Rivera on 2013/07/29.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "UIImage+PECrop.h"

@implementation UIImage (PECrop)

- (UIImage *)rotatedImageWithtransform:(CGAffineTransform)rotation
                         croppedToRect:(CGRect)rect size:(CGSize)size;
{
    UIImage *rotatedImage = [self rotatedImageWithtransform:rotation];
    
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(rotatedImage.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:croppedImage scale:self.scale orientation:rotatedImage.imageOrientation];
    
    
    CGImageRelease(croppedImage);
    UIGraphicsBeginImageContextWithOptions(size,
                                           YES,                     // Opaque
                                           1);             // Use image scale
    
    [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return image2;
}
- (UIImage *)rotatedImageWithtransform:(CGAffineTransform)rotation
                         croppedToRect:(CGRect)rect
{
    CGSize size = rect.size;
//    NSLog(@"crop image size:   %2.2f x %2.2f", size.width, size.height);
    UIImage *rotatedImage = [self rotatedImageWithtransform:rotation];
    
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(rotatedImage.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:croppedImage scale:self.scale orientation:rotatedImage.imageOrientation];


    CGImageRelease(croppedImage);
    UIGraphicsBeginImageContextWithOptions(size,
                                           YES,                     // Opaque
                                           self.scale);             // Use image scale

    [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return image2;
}

- (UIImage *)rotatedImageWithtransform:(CGAffineTransform)transform
{
    CGSize size = self.size;
    
    UIGraphicsBeginImageContextWithOptions(size,
                                           YES,                     // Opaque
                                           self.scale);             // Use image scale
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextConcatCTM(context, transform);
    CGContextTranslateCTM(context, size.width / -2, size.height / -2);
    [self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return rotatedImage;
}

@end
