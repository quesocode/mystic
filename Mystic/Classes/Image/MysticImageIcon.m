//
//  MysticImageIcon.m
//  Mystic
//
//  Created by Me on 11/22/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticImageIcon.h"

@implementation MysticImageIcon

+ (MysticImageIcon *) imageNamed:(NSString *)imageName;
{
    return (MysticImageIcon *)[super imageNamed:imageName];
}
+ (MysticImageIcon *) imageWithCGImage:(CGImageRef)cgImage scale:(CGFloat)scale orientation:(UIImageOrientation)orientation;
{
    return (MysticImageIcon *)[super imageWithCGImage:cgImage scale:scale orientation:orientation];
}
+ (MysticImageIcon *) imageWithImage:(UIImage *)inImage;
{
    return (MysticImageIcon *)[super imageWithImage:inImage];
}
+ (MysticImageIcon *) imageWithCGImage:(CGImageRef)cgImage;
{
    return (MysticImageIcon *)[super imageWithCGImage:cgImage];
}
+ (MysticImageIcon *) imageWithData:(NSData *)data;
{
    return (MysticImageIcon *)[super imageWithData:data];
}
+ (MysticImageIcon *) imageWithData:(NSData *)data scale:(CGFloat)scale;
{
    return (MysticImageIcon *)[super imageWithData:data scale:scale];
}
@end
