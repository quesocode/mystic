//
//  MysticImageIcon.h
//  Mystic
//
//  Created by Me on 11/22/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import "MysticImage.h"

@interface MysticImageIcon : MysticImage

+ (MysticImageIcon *) imageNamed:(NSString *)imageName;

+ (MysticImageIcon *) imageWithCGImage:(CGImageRef)cgImage scale:(CGFloat)scale orientation:(UIImageOrientation)orientation;
+ (MysticImageIcon *) imageWithImage:(UIImage *)inImage;
+ (MysticImageIcon *) imageWithCGImage:(CGImageRef)cgImage;
+ (MysticImageIcon *) imageWithData:(NSData *)data;
+ (MysticImageIcon *) imageWithData:(NSData *)data scale:(CGFloat)scale;



@end

