//
//  UIImage (Mystic).m
//  Mystic
//
//  Created by Me on 9/24/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "UIImage+Mystic.h"
#import <float.h>



@implementation UIImage (Mystic)


- (UIImage *)crop:(CGRect)rect {
    if (self.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * self.scale,
                          rect.origin.y * self.scale,
                          rect.size.width * self.scale,
                          rect.size.height * self.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}


-(UIImage*)downsampleImage{
    NSData *imageAsData = UIImageJPEGRepresentation(self, 0.001);
    UIImage *downsampledImaged = [UIImage imageWithData:imageAsData];
    return downsampledImaged;
}


@end
